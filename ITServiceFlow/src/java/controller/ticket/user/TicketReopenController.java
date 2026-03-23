package controller.ticket.user;

import dao.NotificationDao;
import dao.TicketCommentsDAO;
import dao.TicketDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import model.TicketComments;
import model.Tickets;
import model.Users;
import service.AuditLogService;

@WebServlet(name = "TicketReopen", urlPatterns = {"/TicketReopen"})
public class TicketReopenController extends HttpServlet {

    private static final int MAX_REASON_LENGTH = 500;

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        Users currentUser = session == null ? null : (Users) session.getAttribute("user");
        if (currentUser == null) {
            response.sendRedirect(request.getContextPath() + "/Login.jsp");
            return;
        }

        int ticketId = parseInt(request.getParameter("ticketId"));
        String reason = trim(request.getParameter("reopenReason"));

        if (ticketId <= 0) {
            setFlash(session, "error", "Invalid ticket.");
            response.sendRedirect(request.getContextPath() + "/Tickets");
            return;
        }

        if (reason == null || reason.isEmpty()) {
            setFlash(session, "error", "Reopen reason is required.");
            response.sendRedirect(request.getContextPath() + "/TicketDetailUser?id=" + ticketId);
            return;
        }

        if (reason.length() > MAX_REASON_LENGTH) {
            setFlash(session, "error", "Reopen reason cannot exceed " + MAX_REASON_LENGTH + " characters.");
            response.sendRedirect(request.getContextPath() + "/TicketDetailUser?id=" + ticketId);
            return;
        }

        TicketDAO ticketDao = new TicketDAO();
        Tickets ticket = ticketDao.getTicketById(ticketId);

        if (ticket == null || ticket.getCreatedBy() != currentUser.getId()) {
            setFlash(session, "error", "You do not have permission to reopen this ticket.");
            response.sendRedirect(request.getContextPath() + "/Tickets");
            return;
        }

        if (!("Resolved".equalsIgnoreCase(ticket.getStatus()) || "Closed".equalsIgnoreCase(ticket.getStatus()))) {
            setFlash(session, "error", "Only Resolved/Closed tickets can be reopened.");
            response.sendRedirect(request.getContextPath() + "/TicketDetailUser?id=" + ticketId);
            return;
        }

        boolean reopened = ticketDao.reopenTicketForUser(ticketId, currentUser.getId());
        if (!reopened) {
            setFlash(session, "error", "Failed to reopen ticket. It may have been updated by someone else.");
            response.sendRedirect(request.getContextPath() + "/TicketDetailUser?id=" + ticketId);
            return;
        }

        String normalizedReason = reason.replace("\r", "").trim();

        TicketComments reopenComment = new TicketComments();
        reopenComment.setTicketId(ticketId);
        reopenComment.setUserId(currentUser.getId());
        reopenComment.setInternal(false);
        reopenComment.setContent("[Ticket Reopen Request] " + normalizedReason);
        new TicketCommentsDAO().addComment(reopenComment);

        sendReopenNotifications(ticket, ticketId, normalizedReason);
        new AuditLogService().createAuditLog(currentUser.getId(), "TICKET_REOPEN_REQUEST", "Ticket", ticketId);

        setFlash(session, "success", "Ticket reopened successfully and reassigned to previous queue/agent.");
        response.sendRedirect(request.getContextPath() + "/TicketDetailUser?id=" + ticketId);
    }

    private void sendReopenNotifications(Tickets ticket, int ticketId, String reason) {
        NotificationDao notificationDao = new NotificationDao();
        String ticketNumber = ticket.getTicketNumber() == null ? ("#" + ticketId) : ticket.getTicketNumber();
        String compactReason = reason.length() > 200 ? reason.substring(0, 200) + "..." : reason;

        String title = "Ticket Reopened";
        String message = "Requester reopened ticket " + ticketNumber + ". Reason: " + compactReason;

        Integer assignedTo = ticket.getAssignedTo();
        if (assignedTo != null && assignedTo > 0) {
            notificationDao.addNotification(assignedTo, message, ticketId, false, title, "Ticket");
            return;
        }

        notificationDao.addBroadcastNotification(
                "Ticket " + ticketNumber + " has been reopened and is waiting for assignment. Reason: " + compactReason,
                ticketId,
                title,
                "Ticket"
        );
    }

    private int parseInt(String value) {
        try {
            return Integer.parseInt(value == null ? "" : value.trim());
        } catch (Exception ex) {
            return -1;
        }
    }

    private String trim(String value) {
        return value == null ? null : value.trim();
    }

    private void setFlash(HttpSession session, String type, String message) {
        if (session == null) {
            return;
        }
        session.setAttribute("ticketDetailFlashType", type);
        session.setAttribute("ticketDetailFlashMessage", message);
    }
}
