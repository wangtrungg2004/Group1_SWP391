package controller.ticket.user;

import dao.CategoryDao;
import dao.ServiceCatalogDao;
import dao.TicketDAO;
import model.ServiceCatalog;
import model.Tickets;
import model.Users;
import java.io.IOException;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet(name = "CreateTicket", urlPatterns = { "/CreateTicket" })
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

        if ("Incident".equals(ticketType)) {

            String catStr = request.getParameter("categoryId");
            String impactStr = request.getParameter("impact");
            String urgencyStr = request.getParameter("urgency");

            if (catStr == null || catStr.isEmpty() || "null".equals(catStr)) {
                request.setAttribute("errorMessage", "Vui lòng chọn đầy đủ đến mục 'Lỗi chi tiết'.");
                doGet(request, response);
                return;
            }

            try {
                t.setCategoryId(Integer.parseInt(catStr));
                t.setImpact(Integer.parseInt(impactStr));
                t.setUrgency(Integer.parseInt(urgencyStr));
                t.setPriorityId(1);

                t.setServiceCatalogId(null);
                t.setRequiresApproval(false);

            } catch (NumberFormatException e) {
                request.setAttribute("errorMessage", "Dữ liệu độ khẩn cấp/ảnh hưởng không hợp lệ.");
                doGet(request, response);
                return;
            }

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
                    t.setCategoryId(svc.getCategoryId());
                    t.setRequiresApproval(svc.isRequiresApproval());

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

        TicketDAO dao = new TicketDAO();
        boolean isCreated = dao.createTicket(t);

        if (isCreated) {
            response.sendRedirect(request.getContextPath() + "/Tickets");
        } else {
            request.setAttribute("errorMessage", "Lỗi hệ thống: Không thể lưu Ticket vào Database. Vui lòng thử lại.");
            doGet(request, response);
        }
    }
}