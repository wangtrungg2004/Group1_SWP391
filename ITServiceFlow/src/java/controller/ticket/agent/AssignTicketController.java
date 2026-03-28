package controller.ticket.agent;

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

@WebServlet(name = "AssignTicket", urlPatterns = {"/AssignTicket"})
public class AssignTicketController extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        processAssign(request, response, true);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        processAssign(request, response, false);
    }

    private void processAssign(HttpServletRequest request, HttpServletResponse response, boolean isAssignToMe) 
            throws IOException {
        
        HttpSession session = request.getSession();
        Users currentUser = (Users) session.getAttribute("user");
        String role = (String) session.getAttribute("role");

        if (currentUser == null || (!"Manager".equals(role) && !"IT Support".equals(role) && !"Admin".equals(role))) {
            response.sendRedirect(request.getContextPath() + "/Login.jsp");
            return;
        }

        try {
            int ticketId = Integer.parseInt(request.getParameter(isAssignToMe ? "id" : "ticketId"));
            int agentId;

            TicketDAO dao = new TicketDAO();
            Tickets ticket = dao.getTicketById(ticketId);

            if (ticket == null) {
                response.sendRedirect(request.getContextPath() + "/Queues");
                return;
            }

            boolean isManager = "Manager".equals(role);
            if (!isManager && ticket.getAssignedTo() != null && ticket.getAssignedTo() > 0 && ticket.getAssignedTo() != currentUser.getId()) {
                request.getSession().setAttribute("errorMessage", "Error: This ticket is already being handled by another agent. You cannot take over.");
                response.sendRedirect(request.getContextPath() + "/TicketAgentDetail?id=" + ticket.getId());
                return;
            }

            if (isAssignToMe) {
                agentId = currentUser.getId();
            } else {
                agentId = Integer.parseInt(request.getParameter("agentId"));
            }

            dao.assignTicket(ticketId, agentId);

            String referer = request.getHeader("Referer");
            if (referer != null && referer.contains("Queues")) {
                response.sendRedirect(request.getContextPath() + "/Queues");
            } else {
                response.sendRedirect(request.getContextPath() + "/TicketAgentDetail?id=" + ticketId);
            }
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/Queues");
        }
    }
}