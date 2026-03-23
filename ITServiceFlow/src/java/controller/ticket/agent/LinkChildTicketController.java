/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package controller.ticket.agent;

/**
 *
 * @author Dumb Trung
 */

import dao.TicketDAO;
import model.Users;
import java.io.IOException;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet(name = "LinkChildTicket", urlPatterns = {"/LinkChildTicket"})
public class LinkChildTicketController extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        HttpSession session = request.getSession();
        Users currentUser = (Users) session.getAttribute("user");
        String role = (String) session.getAttribute("role");

        if (currentUser == null || (!"IT Support".equals(role) && !"Manager".equals(role) && !"Admin".equals(role))) {
            response.sendRedirect(request.getContextPath() + "/Login.jsp");
            return;
        }

        try {
            int parentTicketId = Integer.parseInt(request.getParameter("ticketId"));
            String[] childTicketIds = request.getParameterValues("childTicketIds");

            if (childTicketIds != null && childTicketIds.length > 0) {
                TicketDAO dao = new TicketDAO();
                // Thực thi link vào DB
                dao.linkChildTickets(parentTicketId, childTicketIds);
            }
            
            // Link xong tải lại trang chi tiết vé Cha
            response.sendRedirect(request.getContextPath() + "/TicketAgentDetail?id=" + parentTicketId);

        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/Queues");
        }
    }
}
