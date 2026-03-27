package controller.ticket.user;

import dao.AssetsDAO;
import dao.CategoryDao;
import dao.ServiceCatalogDao;
import dao.SLATrackingDao;
import dao.TicketAssetsDAO;
import dao.TicketDAO;
import model.Assets;
import model.ServiceCatalog;
import model.Tickets;
import model.Users;
import java.io.IOException;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@MultipartConfig(
        fileSizeThreshold = 1024 * 1024 * 2,
        maxFileSize       = 1024 * 1024 * 15,
        maxRequestSize    = 1024 * 1024 * 50
)
@WebServlet(name = "CreateTicket", urlPatterns = {"/CreateTicket"})
public class TicketCreateController extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        CategoryDao catDao = new CategoryDao();
        ServiceCatalogDao svcDao = new ServiceCatalogDao();
        request.setAttribute("categoryList", catDao.getAllCategories());
        request.setAttribute("serviceList", svcDao.getAllServices());
        request.getRequestDispatcher("/ticket/create.jsp").forward(request, response);
    }

    private int calculatePriority(int impact, int urgency) {
        int score = impact + urgency;
        if (score <= 2) return 1;
        if (score <= 4) return 2;
        if (score <= 5) return 3;
        return 4;
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession();
        Users currentUser = (Users) session.getAttribute("user");

        if (currentUser == null) {
            response.sendRedirect("Login.jsp");
            return;
        }

        String ticketType = request.getParameter("ticketType");

        Tickets t = new Tickets();
        t.setTicketNumber("TKT-" + System.currentTimeMillis());
        t.setTicketType(ticketType);
        t.setTitle(request.getParameter("title"));
        t.setDescription(request.getParameter("description"));
        t.setCreatedBy(currentUser.getId());
        t.setLocationId(currentUser.getLocationId() > 0 ? currentUser.getLocationId() : 1);

        // ── Incident ────────────────────────────────────────────────────────
        if ("Incident".equals(ticketType)) {
            String catStr = request.getParameter("categoryId");
            if (catStr == null || catStr.isEmpty() || "null".equals(catStr)) {
                request.setAttribute("errorMessage", "Vui lòng chọn đầy đủ đến mục 'Lỗi chi tiết'.");
                preserveFormForError(request, ticketType);
                doGet(request, response);
                return;
            }
            try {
                int impact = Integer.parseInt(request.getParameter("impact"));
                int urgency = Integer.parseInt(request.getParameter("urgency"));
                t.setCategoryId(Integer.parseInt(catStr));
                t.setImpact(impact);
                t.setUrgency(urgency);
                t.setPriorityId(calculatePriority(impact, urgency));
                t.setServiceCatalogId(null);
                t.setRequiresApproval(false);
            } catch (NumberFormatException e) {
                request.setAttribute("errorMessage", "Dữ liệu độ khẩn cấp/ảnh hưởng không hợp lệ.");
                preserveFormForError(request, ticketType);
                doGet(request, response);
                return;
            }

        // ── ServiceRequest ──────────────────────────────────────────────────
        } else if ("ServiceRequest".equals(ticketType)) {
            String serviceStr = request.getParameter("serviceCatalogId");
            if (serviceStr == null || serviceStr.isEmpty()) {
                request.setAttribute("errorMessage", "Vui lòng chọn dịch vụ cụ thể.");
                preserveFormForError(request, ticketType);
                doGet(request, response);
                return;
            }
            try {
                int serviceId = Integer.parseInt(serviceStr);
                ServiceCatalogDao svcDao = new ServiceCatalogDao();
                ServiceCatalog svc = svcDao.getServiceById(serviceId);
                if (svc != null) {
                    t.setServiceCatalogId(serviceId);
                    t.setCategoryId(svc.getCategoryId());
                    t.setRequiresApproval(svc.isRequiresApproval());
                    t.setImpact(null);
                    t.setUrgency(null);
                    t.setPriorityId(null);
                } else {
                    request.setAttribute("errorMessage", "Dịch vụ không tồn tại trong hệ thống.");
                    preserveFormForError(request, ticketType);
                    doGet(request, response);
                    return;
                }
            } catch (Exception e) {
                request.setAttribute("errorMessage", "Lỗi dữ liệu dịch vụ.");
                preserveFormForError(request, ticketType);
                doGet(request, response);
                return;
            }
        }

        // ── Kiểm tra Asset tag (Optional) ──────────────────────────────────
        String assetTag = request.getParameter("assetTag");
        Assets asset = null;
        if (assetTag != null && !assetTag.trim().isEmpty()) {
            AssetsDAO assetsDAO = new AssetsDAO();
            asset = assetsDAO.getAssetByTag(assetTag.trim());
            if (asset == null) {
                request.setAttribute("errorMessage", "Asset tag không tồn tại trong hệ thống.");
                preserveFormForError(request, ticketType);
                doGet(request, response);
                return;
            }
        }

        // ── Tạo Ticket ──────────────────────────────────────────────────────
        TicketDAO dao = new TicketDAO();
        // GỌI BỘ ĐIỀU PHỐI ITIL ĐỂ XẾP HÀNG ĐỢI
        dao.applyITILRouting(t);
        // Lưu Database lấy ID
        int newTicketId = dao.createTicket(t);

        if (newTicketId > 0) {
            // 1. Map Asset vào Ticket (nếu có)
            if (asset != null) {
                TicketAssetsDAO ticketAssetsDAO = new TicketAssetsDAO();
                ticketAssetsDAO.addLink(newTicketId, asset.getId());
            }

            // 2. TÍCH HỢP SLA MODULE TỰ ĐỘNG (CÓ ĐIỀU KIỆN ITIL)
            if (t.getPriorityId() != null && t.getPriorityId() > 0) {
                // Kiểm tra xem vé này có phải là Service Request đang bị khóa chờ duyệt không
                boolean isPendingApproval = "ServiceRequest".equals(t.getTicketType())
                        && t.getRequiresApproval() != null
                        && t.getRequiresApproval();

                // Nếu KHÔNG PHẢI vé chờ duyệt -> Khởi động đồng hồ SLA ngay lập tức
                if (!isPendingApproval) {
                    SLATrackingDao slaDao = new SLATrackingDao();
                    slaDao.applySLAForTicket(newTicketId, t.getTicketType(), t.getPriorityId());
                }
            }

            // 3. Chuyển hướng thành công
            response.sendRedirect(request.getContextPath() + "/Tickets?created=1");
            return;

        } else {
            // Xử lý khi Insert thất bại (newTicketId <= 0)
            preserveFormForError(request, ticketType);
            request.setAttribute("errorMessage", "Lỗi hệ thống: Không thể tạo Ticket.");
            doGet(request, response);
        }
    }

    private void preserveFormForError(HttpServletRequest request, String ticketType) {
        request.setAttribute("ticketType_val", ticketType);
        request.setAttribute("title_val", request.getParameter("title"));
        request.setAttribute("description_val", request.getParameter("description"));
        request.setAttribute("categoryId_val", request.getParameter("categoryId"));
        request.setAttribute("impact_val", request.getParameter("impact"));
        request.setAttribute("urgency_val", request.getParameter("urgency"));
        request.setAttribute("serviceCatalogId_val", request.getParameter("serviceCatalogId"));
        request.setAttribute("assetTag_val", request.getParameter("assetTag"));
    }
}