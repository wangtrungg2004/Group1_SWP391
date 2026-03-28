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
import dao.SLATrackingDao;
import model.Tickets;
import model.Users;
import java.io.IOException;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet(name = "EditTicket", urlPatterns = {"/EditTicket"})
public class TicketEditController extends HttpServlet {

    private int calculatePriority(int impact, int urgency) {
        int score = impact + urgency;
        if (score <= 2) {
            return 1; // Critical
        }
        if (score <= 4) {
            return 2; // High
        }
        if (score <= 5) {
            return 3; // Medium
        }
        return 4; // Low
    }

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
            int categoryId = Integer.parseInt(request.getParameter("categoryId"));

            TicketDAO dao = new TicketDAO();
            Tickets t = dao.getTicketById(ticketId);

            TicketDAO ticketDao = new TicketDAO();
            Tickets ticket = ticketDao.getTicketById(ticketId);

             boolean isOwner = (ticket.getAssignedTo() != null && ticket.getAssignedTo() == currentUser.getId());

            if (!isOwner) {
                request.getSession().setAttribute("errorMessage", "Access Denied: You must assign this ticket to yourself for taking any action.");
                response.sendRedirect(request.getContextPath() + "/TicketAgentDetail?id=" + ticketId);
                return; 
            }

            Integer impact = null;
            Integer urgency = null;
            Integer priorityId = null;

            if ("Incident".equals(t.getTicketType())) {
                impact = Integer.parseInt(request.getParameter("impact"));
                urgency = Integer.parseInt(request.getParameter("urgency"));
                priorityId = calculatePriority(impact, urgency);
            }

            boolean isUpdated = dao.updateTicketTriage(ticketId, categoryId, impact, urgency, priorityId);

            if (isUpdated && "Incident".equals(t.getTicketType()) && priorityId != null) {
                SLATrackingDao slaDao = new SLATrackingDao();
                slaDao.applySLAForTicket(ticketId, t.getTicketType(), priorityId);
            }

            response.sendRedirect(request.getContextPath() + "/TicketAgentDetail?id=" + ticketId);
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/Queues");
        }
    }
}
