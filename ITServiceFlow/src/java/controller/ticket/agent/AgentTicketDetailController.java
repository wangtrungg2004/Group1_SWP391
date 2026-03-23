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

        // 1. Ticket
        TicketDAO ticketDao = new TicketDAO();
        Tickets ticket = ticketDao.getTicketById(ticketId);
        if (ticket == null) {
            response.sendRedirect(request.getContextPath() + "/Queues");
            return;
        }

        // 2. Attachments
        TicketAttachmentDAO fileDao = new TicketAttachmentDAO();
        try {
            request.setAttribute("attachments", fileDao.listByTicket(ticketId));
        } catch (Exception e) { e.printStackTrace(); }

        // 3. SLA
        SLATrackingDao slaDao = new SLATrackingDao();
        SLATracking slaTracking = slaDao.getSLATrackingByTicketId(ticketId);
        if (slaTracking != null) {
            request.setAttribute("slaTracking", slaTracking);
            request.setAttribute("isSlaBreached", new Date().after(slaTracking.getResolutionDeadline()));
        }

        // 4. Related Problem
        ProblemDao problemDao = new ProblemDao();
        request.setAttribute("relatedProblem", problemDao.getProblemByTicketId(ticketId));

        
        // ==========================================
        // 8. LẤY DỮ LIỆU CHO US03: PARENT - CHILD
        // ==========================================
        // Nếu vé này là vé con (Có ParentId) -> Lấy thông tin vé Cha
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
        
        // Lấy danh sách Comment
        TicketCommentsDAO commentDao = new TicketCommentsDAO();
        // Truyền 'true' vì Agent có quyền xem Internal Note
        List<TicketComments> comments = commentDao.getCommentsByTicketId(ticketId, true);
        request.setAttribute("comments", comments);
        // 5. Linked Assets
        TicketAssetsDAO assetDao = new TicketAssetsDAO();
        request.setAttribute("linkedAssets", assetDao.getLinkedCIsByTicketId(ticketId));

        
        // 7. ── TIME TRACKING ──────────────────────────────────
        Integer userId = (Integer) session.getAttribute("userId");
        if (userId != null) {
            TimeLogService timeLogService = new TimeLogService();

            request.setAttribute("timeLogs",   timeLogService.getByTicket(ticketId));
            request.setAttribute("totalHours", timeLogService.getTotalHours(ticketId));

            // Phục hồi activeTimeLogId: session trước, fallback DB
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

        // Flash message từ TicketTimeLogController
        Object flash = session.getAttribute("timeLogFlash");
        if (flash != null) {
            String f = flash.toString();
            int c = f.indexOf(':');
            if (c > 0) {
                request.setAttribute("timeLogFlashType", f.substring(0, c));
                request.setAttribute("timeLogFlashMsg",  f.substring(c + 1));
            }
            session.removeAttribute("timeLogFlash");
        }
        
        // Nếu là Manager, lấy danh sách IT Support để phục vụ Modal "Assign To..."
        // Sửa trong cả 2 file Controller (AgentTicketDetail và AgentQueue)
        if ("Manager".equals(session.getAttribute("role")) || "Admin".equals(session.getAttribute("role"))) {
            request.setAttribute("itSupportList", ticketDao.getActiveAgents());
        }

        // [CÁC ĐOẠN CODE LẤY DỮ LIỆU TICKET, COMMENT, ASSET... GIỮ NGUYÊN BÊN TRÊN]

        request.setAttribute("ticket", ticket);
        
        // 🚀 BỘ ĐỊNH TUYẾN GIAO DIỆN (Y-FORK ROUTING)
        if ("ServiceRequest".equals(ticket.getTicketType())) {
            // Nếu là Yêu cầu dịch vụ -> Trả về giao diện chuyên biệt cho Request
            request.getRequestDispatcher("/ticket/service_request_detail.jsp").forward(request, response);
        } else {
            // Mặc định là Incident -> Trả về giao diện Xử lý sự cố (bản đã làm)
            request.getRequestDispatcher("/ticket/agent_ticket_detail.jsp").forward(request, response);
        }
    }
}