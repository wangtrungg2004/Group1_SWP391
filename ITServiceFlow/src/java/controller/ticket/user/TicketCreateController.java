package controller.ticket.user;

import dao.CategoryDao;
import dao.ServiceCatalogDao;
import dao.TicketDao;
import model.Category;
import model.ServiceCatalog;
import model.Tickets;
import model.Users;
import java.io.IOException;
import java.util.List;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

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

        // ========================================================
        // XỬ LÝ NHÁNH 1: INCIDENT (SỰ CỐ)
        // ========================================================
        if ("Incident".equals(ticketType)) {

            String catStr = request.getParameter("categoryId");
            String impactStr = request.getParameter("impact");
            String urgencyStr = request.getParameter("urgency");

            // Check nếu User chưa chọn đến Tầng thứ 3 (Lỗi chi tiết)
            if (catStr == null || catStr.isEmpty() || "null".equals(catStr)) {
                request.setAttribute("errorMessage", "Vui lòng chọn đầy đủ đến mục 'Lỗi chi tiết' (Level 3).");
                doGet(request, response);
                return;
            }

            try {
                t.setCategoryId(Integer.parseInt(catStr));
                t.setImpact(Integer.parseInt(impactStr));
                t.setUrgency(Integer.parseInt(urgencyStr));
                t.setPriorityId(1); 
                
                // FIX QUAN TRỌNG: Gán giá trị mặc định để tránh NullPointer trong DAO
                t.setServiceCatalogId(null); 
                t.setRequiresApproval(false); 
                
            } catch (NumberFormatException e) {
                request.setAttribute("errorMessage", "Dữ liệu độ khẩn cấp/ảnh hưởng không hợp lệ.");
                doGet(request, response);
                return;
            }

        // ========================================================
        // XỬ LÝ NHÁNH 2: SERVICE REQUEST (DỊCH VỤ)
        // ========================================================
        } else if ("ServiceRequest".equals(ticketType)) {

            String serviceStr = request.getParameter("serviceCatalogId");

            if (serviceStr == null || serviceStr.isEmpty()) {
                request.setAttribute("errorMessage", "Vui lòng chọn dịch vụ cụ thể.");
                doGet(request, response);
                return;
            }

            try {
                int serviceId = Integer.parseInt(serviceStr);
                ServiceCatalogDao svcDao = new ServiceCatalogDao();
                ServiceCatalog svc = svcDao.getServiceById(serviceId);

                if (svc != null) {
                    t.setServiceCatalogId(serviceId);
                    t.setCategoryId(svc.getCategoryId()); // Gán category cha
                    t.setRequiresApproval(svc.isRequiresApproval());
                    
                    // FIX QUAN TRỌNG: Gán null cho các field của Incident để DB không bắt lỗi
                    t.setImpact(null);
                    t.setUrgency(null);
                    t.setPriorityId(null);
                } else {
                    request.setAttribute("errorMessage", "Dịch vụ không tồn tại trong hệ thống.");
                    doGet(request, response);
                    return;
                }
            } catch (Exception e) {
                request.setAttribute("errorMessage", "Lỗi dữ liệu dịch vụ.");
                doGet(request, response);
                return;
            }
        }

        // GỌI DAO ĐỂ LƯU XUỐNG DB
        TicketDao dao = new TicketDao();
        boolean isCreated = dao.createTicket(t);

        if (isCreated) {
            response.sendRedirect(request.getContextPath() + "/Tickets");
        } else {
            // Hiển thị lỗi rõ ràng thay vì im lặng
            request.setAttribute("errorMessage", "Lỗi hệ thống: Không thể lưu Ticket vào Database. Vui lòng thử lại.");
            doGet(request, response);
        }
    }
}