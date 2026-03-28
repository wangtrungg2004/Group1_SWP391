package controller.ticket.agent;

import dao.TicketDAO;
import dao.TicketCommentsDAO;
import model.Users;
import java.io.IOException;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import dao.UsersDAO;
import model.Tickets;
import service.NotificationService;

@WebServlet(name = "UpdateTicketStatus", urlPatterns = {"/UpdateStatus"})
public class UpdateStatusController extends HttpServlet {

    NotificationService notificationService = new NotificationService();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        processStatusUpdate(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        processStatusUpdate(request, response);
    }

    private void processStatusUpdate(HttpServletRequest request, HttpServletResponse response) throws IOException {
        HttpSession session = request.getSession();
        Users currentUser = (Users) session.getAttribute("user");
        String role = (String) session.getAttribute("role");

        if (currentUser == null || (!"Manager".equals(role) && !"IT Support".equals(role))) {
            response.sendRedirect(request.getContextPath() + "/Login.jsp");
            return;
        }

        String idParam = request.getParameter("id");
        String status = request.getParameter("status");
        String breachReason = request.getParameter("breachReason"); 

        if (idParam != null && !idParam.isEmpty() && status != null && !status.isEmpty()) {
            int ticketId = Integer.parseInt(idParam); 
            TicketDAO ticketDao = new TicketDAO();
            Tickets ticket = ticketDao.getTicketById(ticketId);

            boolean isOwner = (ticket.getAssignedTo() != null && ticket.getAssignedTo() == currentUser.getId());

            if (!isOwner) {
                request.getSession().setAttribute("errorMessage", "Access Denied: You must assign this ticket to yourself to take any action.");
                response.sendRedirect(request.getContextPath() + "/TicketAgentDetail?id=" + ticketId);
                return; 
            }

            String currentStatus = ticket.getStatus();
            boolean canUpdate = false;

            if ("Closed".equals(currentStatus)) {
                canUpdate = false; 
            } else if ("Resolved".equals(currentStatus)) {
                if ("Closed".equals(status)) canUpdate = true; 
            } else if ("In Progress".equals(currentStatus)) {
                if ("Resolved".equals(status) || "Closed".equals(status)) canUpdate = true; 
            } else if ("New".equals(currentStatus) || "Reopened".equals(currentStatus)) {
                if ("In Progress".equals(status) || "Resolved".equals(status) || "Closed".equals(status)) canUpdate = true; 
            }

            if (!canUpdate) {
                request.getSession().setAttribute("errorMessage", "Business Logic Error: Cannot revert status from [" + currentStatus + "] to [" + status + "].");
                response.sendRedirect(request.getContextPath() + "/TicketAgentDetail?id=" + ticketId);
                return;
            }

            ticketDao.updateTicketStatus(ticketId, status);

            if (breachReason != null && !breachReason.trim().isEmpty()) {
                TicketCommentsDAO commentDao = new TicketCommentsDAO();
                commentDao.addComment(ticketId, currentUser.getId(), "️SLA BREACH REASON (Root Cause):\n" + breachReason, true);
            }


            if ("Resolved".equals(status) || "Closed".equals(status)) {
                Tickets t = ticketDao.getTicketById(ticketId);
                if (t != null && t.getCreatedBy() > 0) {
                    UsersDAO usersDAO = new UsersDAO();
                    Users creator = usersDAO.getUserById(t.getCreatedBy());

                    if (creator != null && "User".equalsIgnoreCase(creator.getRole())) {
                        String title = "Ticket " + (t.getTicketNumber() != null ? t.getTicketNumber() : "#" + ticketId);
                        String msg = "Your ticket " + (t.getTitle() != null ? t.getTitle() : "") + " has been " + status + ".";
                        notificationService.createNotification(creator.getId(), msg, ticketId, false, title, "Ticket");
                    }
                }
            }
            response.sendRedirect(request.getContextPath() + "/TicketAgentDetail?id=" + ticketId);
        } else {
            response.sendRedirect(request.getContextPath() + "/Queues");
        }
    }
}