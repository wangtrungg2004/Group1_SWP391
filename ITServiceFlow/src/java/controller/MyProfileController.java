package controller;
 
import Utils.PasswordUtil;
import dao.LocationsDAO;
import dao.TicketDAO;
import dao.UsersDAO;
import dao.UserDao;
import model.Locations;
import model.Users;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.util.List;
import java.util.Map;
 
/**
 * Controller cho trang My Profile.
 * URL: /MyProfile
 *
 * GET  → Hiển thị thông tin profile + ticket stats + danh sách locations
 * POST → Xử lý 2 action:
 *   - action=updateInfo     : Cập nhật FullName, Email, LocationId
 *   - action=changePassword : Đổi mật khẩu (xác minh mật khẩu cũ)
 */
@WebServlet(name = "MyProfileController", urlPatterns = {"/MyProfile"})
public class MyProfileController extends HttpServlet {
 
    private final UsersDAO  usersDAO  = new UsersDAO();
    private final UserDao   userDao   = new UserDao();
    private final TicketDAO ticketDAO = new TicketDAO();
 
    // ─── GET ─────────────────────────────────────────────────────────────────
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
 
        HttpSession session = request.getSession(false);
        if (session == null) { response.sendRedirect(request.getContextPath() + "/Login.jsp"); return; }
 
        Integer userId = (Integer) session.getAttribute("userId");
        if (userId == null) { response.sendRedirect(request.getContextPath() + "/Login.jsp"); return; }
 
        // 1. Load user mới nhất từ DB
        Users user = usersDAO.getUserById(userId);
        if (user == null) { response.sendRedirect(request.getContextPath() + "/Login.jsp"); return; }
 
        // 2. Danh sách locations để dropdown
        LocationsDAO locDAO = new LocationsDAO();
        List<Locations> locations = locDAO.getAllLocations();
        request.setAttribute("locations", locations);
 
        // 3. Tên location hiện tại
        Locations currentLoc = locDAO.getLocationById(user.getLocationId());
        if (currentLoc != null) request.setAttribute("currentLocation", currentLoc);
 
        // 4. Ticket stats
        Map<String, Integer> kpis = ticketDAO.getUserTicketKPIs(userId);
        int totalTickets = ticketDAO.getTotalTicketsCount(userId, "", "all", "all");
        request.setAttribute("kpis", kpis);
        request.setAttribute("totalTickets", totalTickets);
 
        // 5. Flash message
        String flash = (String) session.getAttribute("profileFlash");
        if (flash != null) {
            session.removeAttribute("profileFlash");
            int sep = flash.indexOf(':');
            if (sep > 0) {
                request.setAttribute("flashType", flash.substring(0, sep));
                request.setAttribute("flashMsg",  flash.substring(sep + 1));
            }
        }
 
        request.setAttribute("profileUser", user);
        request.getRequestDispatcher("/MyProfile.jsp").forward(request, response);
    }
 
    // ─── POST ────────────────────────────────────────────────────────────────
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
 
        request.setCharacterEncoding("UTF-8");
 
        HttpSession session = request.getSession(false);
        if (session == null) { response.sendRedirect(request.getContextPath() + "/Login.jsp"); return; }
 
        Integer userId = (Integer) session.getAttribute("userId");
        if (userId == null) { response.sendRedirect(request.getContextPath() + "/Login.jsp"); return; }
 
        String action = request.getParameter("action");
 
        // ══ ACTION: Cập nhật thông tin cá nhân ═══════════════════
        if ("updateInfo".equals(action)) {
            String fullName    = request.getParameter("fullName");
            String email       = request.getParameter("email");
            String locationStr = request.getParameter("locationId");
 
            // Validate fullName
            if (fullName == null || fullName.isBlank()) {
                setFlash(session, "error", "Họ tên không được để trống.");
                response.sendRedirect(request.getContextPath() + "/MyProfile"); return;
            }
            // Validate email
            if (email == null || !email.matches("^[\\w.+-]+@[\\w-]+\\.[\\w.]+$")) {
                setFlash(session, "error", "Email không hợp lệ.");
                response.sendRedirect(request.getContextPath() + "/MyProfile"); return;
            }
            // Validate locationId
            int locationId;
            try {
                locationId = Integer.parseInt(locationStr);
                if (locationId <= 0) throw new NumberFormatException();
            } catch (NumberFormatException e) {
                setFlash(session, "error", "Vui lòng chọn địa điểm.");
                response.sendRedirect(request.getContextPath() + "/MyProfile"); return;
            }
 
            // Kiểm tra email trùng với user khác
            Users existingByEmail = userDao.getUserByEmail(email.trim());
            if (existingByEmail != null && existingByEmail.getId() != userId) {
                setFlash(session, "error", "Email này đã được sử dụng bởi tài khoản khác.");
                response.sendRedirect(request.getContextPath() + "/MyProfile"); return;
            }
 
            // Dùng updateProfile — không động đến Role/IsActive
            boolean updated = usersDAO.updateProfile(userId, fullName.trim(), email.trim(), locationId);
            if (updated) {
                // Sync lại object trong session để header hiển thị đúng ngay
                Users sessionUser = (Users) session.getAttribute("user");
                if (sessionUser != null) {
                    sessionUser.setFullName(fullName.trim());
                    sessionUser.setEmail(email.trim());
                    sessionUser.setLocationId(locationId);
                }
                setFlash(session, "success", "Cập nhật thông tin thành công.");
            } else {
                setFlash(session, "error", "Cập nhật thất bại. Vui lòng thử lại.");
            }
 
        // ══ ACTION: Đổi mật khẩu ═════════════════════════════════
        } else if ("changePassword".equals(action)) {
            String currentPassword = request.getParameter("currentPassword");
            String newPassword     = request.getParameter("newPassword");
            String confirmPassword = request.getParameter("confirmPassword");
 
            if (currentPassword == null || currentPassword.isBlank()
                    || newPassword == null || newPassword.isBlank()
                    || confirmPassword == null || confirmPassword.isBlank()) {
                setFlash(session, "error", "Vui lòng điền đầy đủ tất cả các trường mật khẩu.");
                response.sendRedirect(request.getContextPath() + "/MyProfile"); return;
            }
            if (!newPassword.equals(confirmPassword)) {
                setFlash(session, "error", "Mật khẩu mới và xác nhận không khớp.");
                response.sendRedirect(request.getContextPath() + "/MyProfile"); return;
            }
            if (newPassword.length() < 6) {
                setFlash(session, "error", "Mật khẩu mới phải có ít nhất 6 ký tự.");
                response.sendRedirect(request.getContextPath() + "/MyProfile"); return;
            }
 
            // Xác minh mật khẩu hiện tại
            Users user = usersDAO.getUserById(userId);
            String currentHash = PasswordUtil.sha256(currentPassword);
            Users verified = userDao.login(user.getUsername(), currentHash);
            if (verified == null) {
                setFlash(session, "error", "Mật khẩu hiện tại không đúng.");
                response.sendRedirect(request.getContextPath() + "/MyProfile"); return;
            }
 
            // Không cho dùng lại mật khẩu cũ
            String newHash = PasswordUtil.sha256(newPassword);
            if (newHash.equals(currentHash)) {
                setFlash(session, "error", "Mật khẩu mới không được trùng với mật khẩu hiện tại.");
                response.sendRedirect(request.getContextPath() + "/MyProfile"); return;
            }
 
            boolean changed = userDao.updatePasswordByUserId(userId, newHash);
            if (changed) {
                setFlash(session, "success", "Đổi mật khẩu thành công.");
            } else {
                setFlash(session, "error", "Đổi mật khẩu thất bại. Vui lòng thử lại.");
            }
 
        } else {
            setFlash(session, "error", "Yêu cầu không hợp lệ.");
        }
 
        response.sendRedirect(request.getContextPath() + "/MyProfile");
    }
 
    private void setFlash(HttpSession session, String type, String message) {
        session.setAttribute("profileFlash", type + ":" + message);
    }
}
 