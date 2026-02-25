/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package controller.ticket.user;

/**
 *
 * @author Dumb Trung
 */

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


public class TicketCreateController extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        // 1. Khởi tạo DAO
        CategoryDao catDao = new CategoryDao();
        ServiceCatalogDao svcDao = new ServiceCatalogDao();
        
        // 2. Kéo dữ liệu từ DB
        List<Category> categoryList = catDao.getAllCategories();
        List<ServiceCatalog> serviceList = svcDao.getAllServices();
        
        // 3. Đẩy sang JSP
        request.setAttribute("categoryList", categoryList);
        request.setAttribute("serviceList", serviceList);
        
        // 4. Chuyển hướng tới file JSP của Dev 2
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
        // Tránh null location nếu User chưa cập nhật Location
        t.setLocationId(currentUser.getLocationId() > 0 ? currentUser.getLocationId() : 1); 

        if ("Incident".equals(ticketType)) {
            t.setCategoryId(Integer.parseInt(request.getParameter("categoryId")));
            t.setImpact(Integer.parseInt(request.getParameter("impact")));
            t.setUrgency(Integer.parseInt(request.getParameter("urgency")));
            t.setPriorityId(1); // Tạm fix Priority 1 để demo
            
        } else if ("ServiceRequest".equals(ticketType)) {
            int serviceId = Integer.parseInt(request.getParameter("serviceCatalogId"));
            t.setServiceCatalogId(serviceId);
            t.setCategoryId(1); // Default category
        }

        TicketDao dao = new TicketDao();
        boolean isCreated = dao.createTicket(t);

        if (isCreated) {
            // Chuyển hướng tới trang "Tickets của tôi" sau khi tạo thành công
            response.sendRedirect(request.getContextPath() + "/MyTickets"); 
        } else {
            request.setAttribute("errorMessage", "Lỗi hệ thống! Không thể tạo Ticket.");
            doGet(request, response); // Load lại form với dữ liệu động
        }
    }
}
