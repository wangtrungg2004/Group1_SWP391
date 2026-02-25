package controller.ticket;


import dao.TicketDAO;
import model.Tickets;
import model.Users;
import java.io.IOException;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet(name = "CreateTicketController", urlPatterns = {"/ticket/create"})
public class CreateTicketController extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        // TODO: Gọi MasterDataDao để lấy List<Categories> và List<ServiceCatalog>
        request.getRequestDispatcher("/ticket/create.jsp").forward(request, response);
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
            
            // TODO: Check bảng ServiceCatalog xem dịch vụ này có cần duyệt không (RequiresApproval)
            // Tạm thời set false
            t.setRequiresApproval(false); 
        }

        TicketDAO dao = new TicketDAO();
        boolean isCreated = dao.createTicket(t);

        if (isCreated) {
            // Thành công -> chuyển về danh sách hoặc trang báo thành công
            response.sendRedirect(request.getContextPath() + "/ticket/list"); 
        } else {
            // Thất bại -> báo lỗi
            request.setAttribute("errorMessage", "Hệ thống gặp lỗi, không thể tạo Ticket.");
            request.getRequestDispatcher("/ticket/create.jsp").forward(request, response);
        }
    }
}