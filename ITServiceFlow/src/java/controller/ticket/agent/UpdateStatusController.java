/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package controller.ticket.agent;

/**
 *
 * @author Dumb Trung
 */


import dao.TicketDao;
import model.Users;
import java.io.IOException;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import dao.NotificationDao;
import dao.UsersDAO;
import model.Tickets;
import service.NotificationService;

@WebServlet(name = "UpdateTicketStatus", urlPatterns = {"/UpdateStatus"})
public class UpdateStatusController extends HttpServlet {

    NotificationService notificationService = new NotificationService();
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        HttpSession session = request.getSession();
        Users currentUser = (Users) session.getAttribute("user");
        String role = (String) session.getAttribute("role");

        if (currentUser == null || (!"Manager".equals(role) && !"IT Support".equals(role))) {
            response.sendRedirect(request.getContextPath() + "/Login.jsp");
            return;
        }

        String idParam = request.getParameter("id");
        String status = request.getParameter("status"); // VD: "In Progress", "Resolved"
        
        if (idParam != null && !idParam.isEmpty() && status != null && !status.isEmpty()) {
            int ticketId = Integer.parseInt(idParam);
            TicketDao ticketDao = new TicketDao();
            Tickets ticket = ticketDao.searchTicketById(ticketId);
            // Đổi trạng thái vé
            ticketDao.updateTicketStatus(ticketId, status);
            
            if ("Resolved".equals(status) || "Closed".equals(status)) {
            Tickets t = ticketDao.getTicketById(ticketId);

            if (t != null && t.getCreatedBy() > 0) {
                UsersDAO usersDAO = new UsersDAO();
                Users creator = usersDAO.getUserById(t.getCreatedBy());

                // Chỉ gửi cho role User
                if (creator != null && "User".equalsIgnoreCase(creator.getRole())) {
                    String title = "Ticket " + (t.getTicketNumber() != null ? t.getTicketNumber() : "#" + ticketId);
                    String msg = "Your ticket " + (t.getTitle() != null ? t.getTitle() : "") + " has been " + status + ".";

                    notificationService.createNotification(
                            creator.getId(),
                            msg,
                            ticketId,
                            false,
                            title,
                            "Ticket"
                    );
                }
            }
        }
            
            
            // CẬP NHẬT GIAO DIỆN: Tự động tải lại trang để hiển thị trạng thái mới
            response.sendRedirect(request.getContextPath() + "/TicketAgentDetail?id=" + ticketId);
        } else {
            response.sendRedirect(request.getContextPath() + "/Queues");
        }
    }
}