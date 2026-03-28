package controller.ticket.agent;

/**
 * @author Dumb Trung (updated: time tracking integration)
 */
import dao.*;
import model.*;
import java.io.IOException;
import java.util.List;
import java.util.Date;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.util.ArrayList;
import service.TimeLogService;

@WebServlet(name = "AgentTicketDetail", urlPatterns = {"/TicketAgentDetail"})
public class AgentTicketDetailController extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession();
        Users currentUser = (Users) session.getAttribute("user");

        if (currentUser == null || (!"Manager".equals(session.getAttribute("role")) && !"IT Support".equals(session.getAttribute("role")))) {
            response.sendRedirect(request.getContextPath() + "/Login.jsp");
            return;
        }

        int ticketId;
        try {
            ticketId = Integer.parseInt(request.getParameter("id"));
        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/Queues");
            return;
        }

        TicketDAO ticketDao = new TicketDAO();
        Tickets ticket = ticketDao.getTicketById(ticketId);
        if (ticket == null) {
            response.sendRedirect(request.getContextPath() + "/Queues");
            return;
        }

        SLATrackingDao slaDao = new SLATrackingDao();
        SLATracking slaTracking = slaDao.getSLATrackingByTicketId(ticketId);
        if (slaTracking != null) {
            request.setAttribute("slaTracking", slaTracking);
            request.setAttribute("isSlaBreached", new Date().after(slaTracking.getResolutionDeadline()));
        }

        ProblemDao problemDao = new ProblemDao();
        request.setAttribute("relatedProblem", problemDao.getProblemByTicketId(ticketId));

        CategoryDao catDao = new CategoryDao();
        List<Category> allCategories = catDao.getAllCategories();

        List<Category> mainCategories = new ArrayList<>();
        List<Category> subCategories = new ArrayList<>();

        for (Category cat : allCategories) {
            if (cat.getParentId() == null || cat.getParentId() == 0) {
                mainCategories.add(cat);
            } else {
                subCategories.add(cat);
            }
        }

        Integer ticketParentCatId = 0;
        for (Category cat : subCategories) {
            if (cat.getId() == ticket.getCategoryId()) {
                ticketParentCatId = cat.getParentId();
                break;
            }
        }

        request.setAttribute("mainCategories", mainCategories);
        request.setAttribute("subCategories", subCategories);
        request.setAttribute("ticketParentCatId", ticketParentCatId);
        // ==========================================

        Integer parentId = ticket.getParentTicketId();
        if (parentId != null && parentId > 0) {
            Tickets parentTicket = ticketDao.getParentTicket(parentId);
            request.setAttribute("parentTicket", parentTicket);
        } else {
            List<Tickets> childTickets = ticketDao.getLinkedChildTickets(ticketId);
            request.setAttribute("childTickets", childTickets);

            List<Tickets> availableTicketsForLinking = ticketDao.getAvailableTicketsForLinking(ticketId);
            request.setAttribute("availableTicketsForLinking", availableTicketsForLinking);
        }

        TicketCommentsDAO commentDao = new TicketCommentsDAO();
        List<TicketComments> comments = commentDao.getCommentsByTicketId(ticketId, true);
        request.setAttribute("comments", comments);

        TicketAssetsDAO assetDao = new TicketAssetsDAO();
        request.setAttribute("linkedAssets", assetDao.getLinkedCIsByTicketId(ticketId));

        Integer userId = (Integer) session.getAttribute("userId");
        if (userId != null) {
            TimeLogService timeLogService = new TimeLogService();

            request.setAttribute("timeLogs", timeLogService.getByTicket(ticketId));
            request.setAttribute("totalHours", timeLogService.getTotalHours(ticketId));

            Integer activeTimeLogId = (Integer) session.getAttribute("activeTimeLogId_ticket_" + ticketId);
            if (activeTimeLogId == null && timeLogService.hasActiveTimer(ticketId, userId)) {
                int dbId = timeLogService.getActiveTimerId(ticketId, userId);
                if (dbId > 0) {
                    activeTimeLogId = dbId;
                    session.setAttribute("activeTimeLogId_ticket_" + ticketId, dbId);
                }
            }
            request.setAttribute("activeTimeLogId", activeTimeLogId);
        }

        Object flash = session.getAttribute("timeLogFlash");
        if (flash != null) {
            String f = flash.toString();
            int c = f.indexOf(':');
            if (c > 0) {
                request.setAttribute("timeLogFlashType", f.substring(0, c));
                request.setAttribute("timeLogFlashMsg", f.substring(c + 1));
            }
            session.removeAttribute("timeLogFlash");
        }

        if ("Manager".equals(session.getAttribute("role"))) {
            request.setAttribute("itSupportList", ticketDao.getActiveAgents());
        }

        request.setAttribute("ticket", ticket);

        if ("ServiceRequest".equals(ticket.getTicketType())) {
            request.getRequestDispatcher("/ticket/service_request_detail.jsp").forward(request, response);
        } else {
            request.getRequestDispatcher("/ticket/agent_ticket_detail.jsp").forward(request, response);
        }
    }
}
