package service;

import dao.TimeLogDAO;
import model.TimeLog;
import java.util.List;

/**
 * Service xử lý nghiệp vụ Time Tracking cho Ticket.
 *
 * Hai luồng sử dụng:
 *  1. Timer tự động : startTimer() → agent làm việc → stopTimer()
 *  2. Manual log    : logManual(hours, note) — agent nhập thủ công
 */
public class TimeLogService {

    // ─────────────────────────────────────────────────────────
    // TIMER
    // ─────────────────────────────────────────────────────────

    public int startTimer(int ticketId, int userId) {
        return new TimeLogDAO().startTimer(ticketId, userId);
    }

    public boolean stopTimer(int timeLogId) {
        return new TimeLogDAO().stopTimer(timeLogId);
    }

    public int getActiveTimerId(int ticketId, int userId) {
        return new TimeLogDAO().getActiveTimerId(ticketId, userId);
    }

    public boolean hasActiveTimer(int ticketId, int userId) {
        return new TimeLogDAO().hasActiveTimer(ticketId, userId);
    }

    // ─────────────────────────────────────────────────────────
    // MANUAL LOG
    // ─────────────────────────────────────────────────────────

    public boolean logManual(int ticketId, int userId, double hours, String note) {
        if (hours <= 0 || hours > 24) return false;
        if (note == null || note.isBlank()) return false;
        return new TimeLogDAO().addManualLog(ticketId, userId, hours, note);
    }

    // ─────────────────────────────────────────────────────────
    // QUERY
    // ─────────────────────────────────────────────────────────

    public List<TimeLog> getByTicket(int ticketId) {
        return new TimeLogDAO().getByTicketId(ticketId);
    }

    public double getTotalHours(int ticketId) {
        return new TimeLogDAO().getTotalHours(ticketId);
    }
}