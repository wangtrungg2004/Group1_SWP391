package controller;

import dao.TicketAttachmentDAO;
import dao.TicketDAO;
import java.io.IOException;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.Collection;
import java.util.List;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import jakarta.servlet.http.Part;
import model.SharedFile;
import model.Tickets;
import model.Users;
import service.SharedFileService;

@WebServlet(name = "CreateTicketController", urlPatterns = { "/ticket/create" })
@MultipartConfig
public class CreateTicketController extends HttpServlet {

    private final SharedFileService sharedFileService = new SharedFileService();
    private final TicketAttachmentDAO attachmentDAO = new TicketAttachmentDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        // TODO: Gọi MasterDataDao để lấy List<Categories> và List<ServiceCatalog>
        request.getRequestDispatcher("/CreateTicket.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession();
        Users currentUser = (Users) session.getAttribute("user");

        if (currentUser == null) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }

        String ticketType = request.getParameter("ticketType"); // "Incident" hoặc "ServiceRequest"

        Tickets t = new Tickets();
        // Sinh mã ngẫu nhiên tạm thời (Thực tế có thể dùng Format TKT-YYYYMMDD-XXX)
        t.setTicketNumber("TKT-" + System.currentTimeMillis());
        t.setTicketType(ticketType);
        t.setTitle(request.getParameter("title"));
        t.setDescription(request.getParameter("description"));
        t.setCreatedBy(currentUser.getId());
        t.setLocationId(currentUser.getLocationId()); // Lấy Location của người tạo
        t.setStatus("New");

        if ("Incident".equals(ticketType)) {
            t.setCategoryId(Integer.parseInt(request.getParameter("categoryId")));
            t.setImpact(Integer.parseInt(request.getParameter("impact")));
            t.setUrgency(Integer.parseInt(request.getParameter("urgency")));

            // TODO: Viết hàm tính PriorityId dựa trên ma trận Impact x Urgency
            // Tạm thời hardcode
            t.setPriorityId(1);

            t.setServiceCatalogId(null);
            t.setRequiresApproval(false);

        } else if ("ServiceRequest".equals(ticketType)) {
            int serviceId = Integer.parseInt(request.getParameter("serviceCatalogId"));
            t.setServiceCatalogId(serviceId);

            // Gán default category cho Request nếu form không có
            t.setCategoryId(Integer.parseInt(request.getParameter("categoryId")));

            t.setImpact(null);
            t.setUrgency(null);
            t.setPriorityId(null);

            // TODO: Check bảng ServiceCatalog xem dịch vụ này có cần duyệt không
            // (RequiresApproval)
            // Tạm thời set false
            t.setRequiresApproval(false);
        }

        TicketDAO dao = new TicketDAO();
        int ticketId = dao.createTicket2(t);

        if (ticketId <= 0) {
            request.setAttribute("errorMessage", "Hệ thống gặp lỗi, không thể tạo Ticket.");
            request.getRequestDispatcher("/CreateTicket.jsp").forward(request, response);
            return;
        }

        // Xử lý upload file đính kèm
        Collection<Part> parts = request.getParts();
        List<SharedFile> savedFiles = new ArrayList<>();
        for (Part p : parts) {
            if (!"attachments".equals(p.getName()) || p.getSize() == 0) {
                continue;
            }
            try {
                SharedFile sf = sharedFileService.saveUploadedPart(p, currentUser.getId(), getServletContext());
                if (sf != null) {
                    savedFiles.add(sf);
                }
            } catch (SQLException | IOException ex) {
                // Bỏ qua file lỗi để không chặn ticket, log nhẹ bằng attribute
                request.setAttribute("uploadWarning", "Một số file không lưu được: " + ex.getMessage());
            }
        }

        for (SharedFile sf : savedFiles) {
            try {
                attachmentDAO.addAttachment(ticketId, sf, currentUser.getId());
            } catch (SQLException e) {
                // Nếu lưu attachment lỗi, không rollback ticket, chỉ cảnh báo
                request.setAttribute("uploadWarning", "Lưu đính kèm lỗi: " + e.getMessage());
            }
        }

        response.sendRedirect(request.getContextPath() + "/ticket/list");
    }
}
