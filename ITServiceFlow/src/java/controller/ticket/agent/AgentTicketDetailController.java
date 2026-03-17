/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package controller.ticket.agent;

/**
 *
 * @author Dumb Trung
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

@WebServlet(name = "AgentTicketDetail", urlPatterns = {"/TicketAgentDetail"})
public class AgentTicketDetailController extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        HttpSession session = request.getSession();
        Users currentUser = (Users) session.getAttribute("user");
        
        // Kiểm tra quyền Agent
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

        // 1. Lấy thông tin TICKET (Code của bạn)
        TicketDAO ticketDao = new TicketDAO();
        Tickets ticket = ticketDao.getTicketById(ticketId);
        
        if (ticket == null) {
            response.sendRedirect(request.getContextPath() + "/Queues");
            return;
        }

        // 2. Lấy danh sách FILE ĐÍNH KÈM (Code của Dev File)
        TicketAttachmentDAO fileDao = new TicketAttachmentDAO();
        try {
            List<TicketAttachments> attachments = fileDao.listByTicket(ticketId);
            request.setAttribute("attachments", attachments);
        } catch (Exception e) { e.printStackTrace(); }

        // 3. Lấy thông tin SLA (Code của Dev SLA)
        SLATrackingDao slaDao = new SLATrackingDao();
        SLATracking slaTracking = slaDao.getSLATrackingByTicketId(ticketId);
        if (slaTracking != null) {
            // Check realtime xem đã quá hạn chưa so với hiện tại
            boolean isBreachedRealtime = new Date().after(slaTracking.getResolutionDeadline());
            request.setAttribute("slaTracking", slaTracking);
            request.setAttribute("isSlaBreached", isBreachedRealtime);
        }

        // 4. Lấy thông tin PROBLEM (Code của Dev Problem)
        ProblemDao problemDao = new ProblemDao();
        Problems relatedProblem = problemDao.getProblemByTicketId(ticketId);
        request.setAttribute("relatedProblem", relatedProblem);

        
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

        // Chuyển toàn bộ dữ liệu ra JSP
        request.setAttribute("ticket", ticket);
        request.getRequestDispatcher("/ticket/agent_ticket_detail.jsp").forward(request, response);
    }
}
