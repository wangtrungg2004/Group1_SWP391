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
import model.Tickets;

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
            int ticketId = Integer.parseInt(request.getParameter("ticketId")); 

            TicketDAO ticketDao = new TicketDAO();
            Tickets ticket = ticketDao.getTicketById(ticketId);

            boolean isOwner = (ticket.getAssignedTo() != null && ticket.getAssignedTo() == currentUser.getId());

            if (!isOwner) {
                request.getSession().setAttribute("errorMessage", "Access Denied: You must assign this ticket to yourself for taking any action.");
                response.sendRedirect(request.getContextPath() + "/TicketAgentDetail?id=" + ticketId);
                return; 
            }
            
            int parentTicketId = Integer.parseInt(request.getParameter("ticketId"));
            String[] childTicketIds = request.getParameterValues("childTicketIds");

            if (childTicketIds != null && childTicketIds.length > 0) {
                TicketDAO dao = new TicketDAO();
                dao.linkChildTickets(parentTicketId, childTicketIds);
            }
            
            response.sendRedirect(request.getContextPath() + "/TicketAgentDetail?id=" + parentTicketId);

        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/Queues");
        }
    }
}
