package dao;

import Utils.DbContext;
import model.TimeLog;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

/**
 * DAO xử lý bảng TimeLogs — time tracking cho Ticket.
 * (Phân biệt với ProblemTimeLogs trong ProblemDao dùng cho Problem)
 */
public class TimeLogDAO extends DbContext {

    // ─────────────────────────────────────────────────────────
    // START / STOP TIMER  (tự động tính giờ)
    // ─────────────────────────────────────────────────────────

    /**
     * Bắt đầu một phiên làm việc mới cho ticket.
     * Chỉ insert StartTime; Hours và EndTime điền khi stopTimer.
     *
     * @return ID bản ghi mới (> 0), -2 nếu đã có phiên đang chạy, -1 nếu lỗi DB.
     */
    public int startTimer(int ticketId, int userId) {
        if (hasActiveTimer(ticketId, userId)) {
            return -2; // đã có phiên đang chạy
        }
        String sql = "INSERT INTO TimeLogs (TicketId, UserId, StartTime, LogDate) "
                   + "VALUES (?, ?, GETDATE(), CONVERT(date, GETDATE()))";
        try (PreparedStatement ps = connection.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setInt(1, ticketId);
            ps.setInt(2, userId);
            ps.executeUpdate();
            ResultSet rs = ps.getGeneratedKeys();
            if (rs.next()) return rs.getInt(1);
        } catch (Exception e) {
            e.printStackTrace();
        }
        return -1;
    }

    /**
     * Kết thúc phiên làm việc: điền EndTime và tính Hours tự động.
     * Chỉ update nếu EndTime chưa có (tránh double-stop).
     */
    public boolean stopTimer(int timeLogId) {
        String sql = "UPDATE TimeLogs "
                   + "SET EndTime = GETDATE(), "
                   + "    Hours = DATEDIFF(SECOND, StartTime, GETDATE()) / 3600.0 "
                   + "WHERE Id = ? AND EndTime IS NULL";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, timeLogId);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    // ─────────────────────────────────────────────────────────
    // MANUAL LOG  (nhập giờ + mô tả thủ công)
    // ─────────────────────────────────────────────────────────

    /**
     * Log giờ thủ công — agent tự nhập số giờ và mô tả công việc.
     * Không dùng start/stop timer.
     *
     * @param note Mô tả công việc (bắt buộc, không được blank)
     */
    public boolean addManualLog(int ticketId, int userId, double hours, String note) {
        if (note == null || note.isBlank()) {
            throw new IllegalArgumentException("Note không được để trống khi log giờ thủ công");
        }
        String sql = "INSERT INTO TimeLogs (TicketId, UserId, Hours, LogDate, Note) "
                   + "VALUES (?, ?, ?, CONVERT(date, GETDATE()), ?)";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, ticketId);
            ps.setInt(2, userId);
            ps.setDouble(3, hours);
            ps.setString(4, note);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    // ─────────────────────────────────────────────────────────
    // QUERY
    // ─────────────────────────────────────────────────────────

    /**
     * Lấy tất cả time logs của một ticket, mới nhất lên trên.
     */
    public List<TimeLog> getByTicketId(int ticketId) {
        List<TimeLog> list = new ArrayList<>();
        String sql = "SELECT tl.Id, tl.TicketId, tl.UserId, "
                   + "       tl.StartTime, tl.EndTime, tl.Hours, tl.LogDate, tl.Note, "
                   + "       u.FullName "
                   + "FROM TimeLogs tl "
                   + "LEFT JOIN Users u ON tl.UserId = u.Id "
                   + "WHERE tl.TicketId = ? "
                   + "ORDER BY tl.StartTime DESC, tl.Id DESC";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, ticketId);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                list.add(mapRow(rs));
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    /**
     * Tổng số giờ đã log cho một ticket (timer đã stop + manual).
     */
    public double getTotalHours(int ticketId) {
        String sql = "SELECT ISNULL(SUM(Hours), 0) FROM TimeLogs WHERE TicketId = ?";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, ticketId);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) return rs.getDouble(1);
        } catch (Exception e) {
            e.printStackTrace();
        }
        return 0.0;
    }

    /**
     * Kiểm tra có phiên timer đang chạy (EndTime IS NULL) không.
     */
    public boolean hasActiveTimer(int ticketId, int userId) {
        String sql = "SELECT COUNT(*) FROM TimeLogs "
                   + "WHERE TicketId = ? AND UserId = ? AND EndTime IS NULL AND StartTime IS NOT NULL";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, ticketId);
            ps.setInt(2, userId);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) return rs.getInt(1) > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    /**
     * Lấy ID phiên timer đang chạy (EndTime IS NULL).
     * Dùng để phục hồi activeTimeLogId khi session bị mất.
     *
     * @return ID bản ghi đang chạy, hoặc -1 nếu không có.
     */
    public int getActiveTimerId(int ticketId, int userId) {
        String sql = "SELECT TOP 1 Id FROM TimeLogs "
                   + "WHERE TicketId = ? AND UserId = ? AND EndTime IS NULL AND StartTime IS NOT NULL "
                   + "ORDER BY StartTime DESC";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, ticketId);
            ps.setInt(2, userId);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) return rs.getInt("Id");
        } catch (Exception e) {
            e.printStackTrace();
        }
        return -1;
    }

    // ─────────────────────────────────────────────────────────
    // HELPER
    // ─────────────────────────────────────────────────────────

    private TimeLog mapRow(ResultSet rs) throws SQLException {
        TimeLog log = new TimeLog();
        log.setId(rs.getInt("Id"));
        log.setTicketId(rs.getInt("TicketId"));
        log.setUserId(rs.getInt("UserId"));
        log.setStartTime(rs.getTimestamp("StartTime"));
        log.setEndTime(rs.getTimestamp("EndTime"));
        log.setHours(rs.getDouble("Hours"));
        log.setLogDate(rs.getDate("LogDate"));
        log.setNote(rs.getString("Note"));
        log.setFullName(rs.getString("FullName"));
        return log;
    }
}