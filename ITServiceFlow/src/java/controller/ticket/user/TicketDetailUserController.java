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
import model.Tickets;
import model.Users;
import java.io.IOException;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet(name = "TicketDetailUser", urlPatterns = {"/TicketDetailUser"})
public class TicketDetailUserController extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        HttpSession session = request.getSession();
        Users currentUser = (Users) session.getAttribute("user");
        
        if (currentUser == null) {
            response.sendRedirect(request.getContextPath() + "/Login.jsp");
            return;
        }

        String idParam = request.getParameter("id");
        if (idParam == null || idParam.isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/MyTickets");
            return;
        }

        int ticketId = Integer.parseInt(idParam);
        TicketDao ticketDao = new TicketDao();
        Tickets ticket = ticketDao.getTicketById(ticketId);

        // BẢO MẬT: Kiểm tra vé có tồn tại không và User hiện tại có phải là người tạo không?
        if (ticket == null || ticket.getCreatedBy() != currentUser.getId()) {
            // Nếu không phải vé của mình -> Đá về trang danh sách
            response.sendRedirect(request.getContextPath() + "/MyTickets");
            return;
        }

        // Đẩy Ticket sang JSP
        request.setAttribute("ticket", ticket);

        // Đẩy thêm danh sách Category và Service để map tên thay vì hiển thị số ID
        CategoryDao catDao = new CategoryDao();
        ServiceCatalogDao svcDao = new ServiceCatalogDao();
        request.setAttribute("categories", catDao.getAllCategories());
        request.setAttribute("services", svcDao.getAllServices());

        request.getRequestDispatcher("/ticket/ticket_detail.jsp").forward(request, response);
    }
}
