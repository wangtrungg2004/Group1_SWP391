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

    private final TimeLogDAO dao = new TimeLogDAO();

    // ─────────────────────────────────────────────────────────
    // TIMER
    // ─────────────────────────────────────────────────────────

    /**
     * Bắt đầu timer.
     *
     * @return ID bản ghi mới (> 0)
     *         -2 nếu đã có phiên đang chạy (trả về activeTimerId nếu cần khôi phục)
     *         -1 nếu lỗi DB
     */
    public int startTimer(int ticketId, int userId) {
        return dao.startTimer(ticketId, userId);
    }

    /**
     * Dừng timer — tính Hours = DATEDIFF(StartTime, GETDATE()).
     *
     * @return true nếu stop thành công (bản ghi tồn tại và EndTime chưa có)
     */
    public boolean stopTimer(int timeLogId) {
        return dao.stopTimer(timeLogId);
    }

    /**
     * Lấy ID phiên timer đang chạy từ DB.
     * Dùng để phục hồi khi session server bị mất (restart, timeout).
     *
     * @return ID > 0 nếu có phiên đang chạy, -1 nếu không.
     */
    public int getActiveTimerId(int ticketId, int userId) {
        return dao.getActiveTimerId(ticketId, userId);
    }

    /** Kiểm tra xem ticket + user có phiên đang chạy không. */
    public boolean hasActiveTimer(int ticketId, int userId) {
        return dao.hasActiveTimer(ticketId, userId);
    }

    // ─────────────────────────────────────────────────────────
    // MANUAL LOG
    // ─────────────────────────────────────────────────────────

    /**
     * Log giờ thủ công — yêu cầu hours > 0 và note không rỗng.
     *
     * @param hours Số giờ làm việc (> 0, tối đa 24)
     * @param note  Mô tả công việc đã làm (bắt buộc)
     * @return true nếu ghi thành công
     */
    public boolean logManual(int ticketId, int userId, double hours, String note) {
        if (hours <= 0 || hours > 24) return false;
        if (note == null || note.isBlank()) return false;
        return dao.addManualLog(ticketId, userId, hours, note);
    }

    // ─────────────────────────────────────────────────────────
    // QUERY
    // ─────────────────────────────────────────────────────────

    /**
     * Lấy tất cả time logs của ticket, sắp xếp mới nhất lên trên.
     */
    public List<TimeLog> getByTicket(int ticketId) {
        return dao.getByTicketId(ticketId);
    }

    /**
     * Tổng số giờ đã log cho ticket (chỉ tính các bản ghi đã có Hours).
     */
    public double getTotalHours(int ticketId) {
        return dao.getTotalHours(ticketId);
    }
}