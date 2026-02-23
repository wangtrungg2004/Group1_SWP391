/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package controller.ticket;

/**
 *
 * @author Dumb Trung
 */
import dao.TicketDao;
import model.Tickets;
import model.Users;
import java.io.IOException;
import jakarta.servlet.ServletException; // Hoặc javax.servlet tùy phiên bản Tomcat
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet(name = "CreateTicketController", urlPatterns = {"/ticket/create"})
public class CreateTicketController extends HttpServlet {

    // GET: Hiển thị form
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        // TODO: Gọi MasterDataDao lấy Category list và Service list để đẩy sang JSP
        // request.setAttribute("categories", categoryList);
        // request.setAttribute("services", serviceList);
        request.getRequestDispatcher("/ticket/create.jsp").forward(request, response);
    }

    // POST: Xử lý submit form
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        HttpSession session = request.getSession();
        Users user = (Users) session.getAttribute("user"); // Lấy session từ Login của Dev 4
        
        if (user == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        String type = request.getParameter("ticketType"); // "Incident" or "ServiceRequest"
        
        Tickets t = new Tickets();
        t.setTicketNumber("TKT-" + System.currentTimeMillis()); // Sinh mã tạm
        t.setTicketType(type);
        t.setTitle(request.getParameter("title"));
        t.setDescription(request.getParameter("description"));
        t.setCreatedBy(user.getId());
        t.setLocationId(user.getLocationId());
        
        // Logic Unified Form
        if ("Incident".equals(type)) {
            t.setCategoryId(Integer.parseInt(request.getParameter("categoryId")));
            t.setImpact(Integer.parseInt(request.getParameter("impact")));
            t.setUrgency(Integer.parseInt(request.getParameter("urgency")));
        } else {
            // Service Request logic
            t.setServiceCatalogId(Integer.parseInt(request.getParameter("serviceId")));
            // Request thì Category lấy từ Service Catalog (cần query thêm), tạm thời hardcode hoặc query DB
            t.setCategoryId(1); 
        }

        TicketDao dao = new TicketDao();
        boolean success = dao.createTicket(t);

        if (success) {
            response.sendRedirect("ticket/list"); // Chuyển hướng về danh sách
        } else {
            request.setAttribute("error", "Failed to create ticket");
            request.getRequestDispatcher("/ticket/create.jsp").forward(request, response);
        }
    }
}
