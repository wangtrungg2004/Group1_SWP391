package controller.ticket.agent;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import service.AuditLogService;
import service.TimeLogService;

import java.io.IOException;

/**
 * Xử lý tất cả hành động Time Tracking cho Ticket:
 *   - action=startTimer   : bắt đầu phiên làm việc
 *   - action=stopTimer    : dừng phiên đang chạy
 *   - action=logManual    : ghi giờ thủ công
 *
 * Sau mỗi action đều redirect về trang chi tiết ticket.
 */
@WebServlet(name = "TicketTimeLog", urlPatterns = {"/TicketTimeLog"})
public class TicketTimeLogController extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        TimeLogService timeLogService = new TimeLogService();
        AuditLogService auditLogService = new AuditLogService();

        HttpSession session = request.getSession(false);
        if (session == null) {
            response.sendRedirect(request.getContextPath() + "/Login.jsp");
            return;
        }

        Integer userId = (Integer) session.getAttribute("userId");
        String role    = (String)  session.getAttribute("role");

        // Chỉ IT Support mới được log giờ
        if (userId == null || !"IT Support".equals(role)) {
            response.sendRedirect(request.getContextPath() + "/Login.jsp");
            return;
        }

        String action      = request.getParameter("action");
        String ticketIdStr = request.getParameter("ticketId");

        // Validate ticketId
        int ticketId;
        try {
            ticketId = Integer.parseInt(ticketIdStr);
        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/Queues");
            return;
        }

        String redirectUrl = request.getContextPath() + "/TicketAgentDetail?id=" + ticketId;

        // ── START TIMER ─────────────────────────────────────────
        if ("startTimer".equals(action)) {
            int result = timeLogService.startTimer(ticketId, userId);

            if (result > 0) {
                // Lưu ID phiên đang chạy vào session
                session.setAttribute("activeTimeLogId_ticket_" + ticketId, result);
                auditLogService.createAuditLog(userId, "START_TIMER", "Ticket", ticketId);
                setFlash(session, "success", "Bắt đầu tính giờ làm việc.");
            } else if (result == -2) {
                // Đã có phiên — khôi phục từ DB vào session
                int existingId = timeLogService.getActiveTimerId(ticketId, userId);
                if (existingId > 0) {
                    session.setAttribute("activeTimeLogId_ticket_" + ticketId, existingId);
                }
                setFlash(session, "info", "Đang có phiên làm việc chạy sẵn.");
            } else {
                setFlash(session, "error", "Không thể bắt đầu timer. Vui lòng thử lại.");
            }

        // ── STOP TIMER ──────────────────────────────────────────
        } else if ("stopTimer".equals(action)) {
            int timeLogId = resolveActiveTimeLogId(request, session, ticketId, userId, timeLogService);

            if (timeLogId < 0) {
                setFlash(session, "error", "Không tìm thấy phiên làm việc đang chạy.");
                response.sendRedirect(redirectUrl);
                return;
            }

            boolean stopped = timeLogService.stopTimer(timeLogId);
            if (stopped) {
                session.removeAttribute("activeTimeLogId_ticket_" + ticketId);
                auditLogService.createAuditLog(userId, "STOP_TIMER", "Ticket", ticketId);
                setFlash(session, "success", "Đã dừng và ghi nhận thời gian làm việc.");
            } else {
                setFlash(session, "error", "Không dừng được timer (có thể đã dừng trước đó).");
            }

        // ── MANUAL LOG ──────────────────────────────────────────
        } else if ("logManual".equals(action)) {

            // Kiểm tra status — chỉ cho log khi ticket đã Resolved hoặc Closed
            model.Tickets ticket = new dao.TicketDAO().getTicketById(ticketId);
            if (ticket == null) {
                setFlash(session, "error", "Không tìm thấy ticket.");
                response.sendRedirect(redirectUrl); return;
            }
            String ticketStatus = ticket.getStatus();
            if (!"Resolved".equals(ticketStatus) && !"Closed".equals(ticketStatus)) {
                setFlash(session, "error", "Chỉ được log time sau khi ticket đã Resolved hoặc Closed.");
                response.sendRedirect(redirectUrl); return;
            }

            String hoursStr = request.getParameter("hours");
            String note     = request.getParameter("note");

            if (hoursStr == null || note == null || note.isBlank()) {
                setFlash(session, "error", "Vui lòng nhập số giờ và mô tả công việc.");
                response.sendRedirect(redirectUrl);
                return;
            }

            double hours;
            try {
                hours = Double.parseDouble(hoursStr);
                if (hours <= 0 || hours > 24) throw new NumberFormatException();
            } catch (NumberFormatException e) {
                setFlash(session, "error", "Số giờ không hợp lệ (0.1 – 24).");
                response.sendRedirect(redirectUrl);
                return;
            }

            boolean logged = timeLogService.logManual(ticketId, userId, hours, note);
            if (logged) {
                auditLogService.createAuditLog(userId, "LOG_TIME_MANUAL", "Ticket", ticketId);
                setFlash(session, "success",
                    String.format("Đã ghi nhận %.2f giờ: \"%s\"", hours, note));
            } else {
                setFlash(session, "error", "Lỗi khi ghi nhận thời gian. Vui lòng thử lại.");
            }

        } else {
            setFlash(session, "error", "Action không hợp lệ.");
        }

        response.sendRedirect(redirectUrl);
    }

    // ─────────────────────────────────────────────────────────
    // HELPERS
    // ─────────────────────────────────────────────────────────

    /**
     * Lấy activeTimeLogId theo thứ tự ưu tiên:
     *   1. Tham số form (timeLogId)
     *   2. Session (activeTimeLogId_ticket_{ticketId})
     *   3. DB (fallback khi session hết hạn / server restart)
     *
     * @return ID > 0 hoặc -1 nếu không tìm thấy.
     */
    private int resolveActiveTimeLogId(HttpServletRequest request, HttpSession session,
                                        int ticketId, int userId, TimeLogService timeLogService) {
        // 1. Từ form
        String fromForm = request.getParameter("timeLogId");
        if (fromForm != null && !fromForm.isBlank()) {
            try { return Integer.parseInt(fromForm); } catch (NumberFormatException ignored) {}
        }
        // 2. Từ session
        Object fromSession = session.getAttribute("activeTimeLogId_ticket_" + ticketId);
        if (fromSession instanceof Integer) return (Integer) fromSession;
        // 3. Từ DB
        int fromDb = timeLogService.getActiveTimerId(ticketId, userId);
        if (fromDb > 0) {
            session.setAttribute("activeTimeLogId_ticket_" + ticketId, fromDb);
            return fromDb;
        }
        return -1;
    }

    /** Ghi flash message vào session để JSP đọc sau redirect. */
    private void setFlash(HttpSession session, String type, String message) {
        session.setAttribute("timeLogFlash", type + ":" + message);
    }
}