package dao;

import Utils.DbContext;
import model.CsatSurvey;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

/**
 * DAO cho bảng CsatSurveys (US20)
 * 
 * Tên cột DB thực tế (theo schema ITServiceFlow):
 *   CsatSurveys : Id, TicketId, UserId, Rating, Comment, SubmittedAt
 *   Tickets     : Id, TicketNumber, Title, Status, CreatedBy, AssignedTo, ClosedAt
 *   Users       : Id, FullName, Role
 * 
 * Extend DbContext (giống TicketDAO, ProblemDao, ... trong project)
 */
public class CsatSurveyDAO extends DbContext {

    // ─────────────────────────────────────────────────────────────────────────
    // 1. Submit survey mới
    // ─────────────────────────────────────────────────────────────────────────

    /**
     * INSERT một survey vào DB.
     * SubmittedAt dùng DEFAULT GETDATE() của DB.
     * @return true nếu thành công
     */
    public boolean submitSurvey(CsatSurvey survey) {
        String sql = "INSERT INTO CsatSurveys (TicketId, UserId, Rating, Comment) "
                   + "VALUES (?, ?, ?, ?)";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, survey.getTicketId());
            ps.setInt(2, survey.getUserId());
            ps.setInt(3, survey.getRating());
            if (survey.getComment() != null && !survey.getComment().trim().isEmpty()) {
                ps.setString(4, survey.getComment().trim());
            } else {
                ps.setNull(4, Types.NVARCHAR);
            }
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            System.err.println("[CsatSurveyDAO] submitSurvey error: " + e.getMessage());
            return false;
        }
    }

    // ─────────────────────────────────────────────────────────────────────────
    // 2. Kiểm tra user đã submit chưa
    // ─────────────────────────────────────────────────────────────────────────

    /**
     * Dùng UNIQUE constraint (TicketId, UserId) - chỉ cho phép submit 1 lần.
     */
    public boolean hasUserSubmitted(int ticketId, int userId) {
        String sql = "SELECT COUNT(1) FROM CsatSurveys WHERE TicketId = ? AND UserId = ?";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, ticketId);
            ps.setInt(2, userId);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) return rs.getInt(1) > 0;
        } catch (SQLException e) {
            System.err.println("[CsatSurveyDAO] hasUserSubmitted error: " + e.getMessage());
        }
        return false;
    }

    // ─────────────────────────────────────────────────────────────────────────
    // 3. Lấy survey theo TicketId (dùng trong ticket_detail để hiển thị)
    // ─────────────────────────────────────────────────────────────────────────

    /**
     * JOIN với Users để lấy FullName của người submit.
     * Dùng cột Users.FullName (đúng schema).
     */
    public CsatSurvey getSurveyByTicket(int ticketId) {
        String sql = "SELECT cs.Id, cs.TicketId, cs.UserId, cs.Rating, cs.Comment, cs.SubmittedAt, "
                   + "       u.FullName AS UserFullName "
                   + "FROM CsatSurveys cs "
                   + "JOIN Users u ON cs.UserId = u.Id "
                   + "WHERE cs.TicketId = ?";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, ticketId);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                CsatSurvey s = new CsatSurvey();
                s.setId(rs.getInt("Id"));
                s.setTicketId(rs.getInt("TicketId"));
                s.setUserId(rs.getInt("UserId"));
                s.setRating(rs.getInt("Rating"));
                s.setComment(rs.getString("Comment"));
                s.setSubmittedAt(rs.getTimestamp("SubmittedAt"));
                s.setUserFullName(rs.getString("UserFullName"));
                return s;
            }
        } catch (SQLException e) {
            System.err.println("[CsatSurveyDAO] getSurveyByTicket error: " + e.getMessage());
        }
        return null;
    }

    // ─────────────────────────────────────────────────────────────────────────
    // 4. Lấy tất cả surveys (Manager / Admin dashboard)
    // ─────────────────────────────────────────────────────────────────────────

    /**
     * JOIN Tickets + Users (người submit + assignee).
     * Dùng đúng tên cột: Tickets.Title, Tickets.TicketNumber, Tickets.AssignedTo,
     *                     Users.FullName
     */
    public List<CsatSurvey> getAllSurveys() {
        List<CsatSurvey> list = new ArrayList<>();
        String sql = "SELECT cs.Id, cs.TicketId, cs.UserId, cs.Rating, cs.Comment, cs.SubmittedAt, "
                   + "       t.TicketNumber, t.Title AS TicketTitle, "
                   + "       u.FullName AS UserFullName, "
                   + "       ISNULL(a.FullName, 'Unassigned') AS AssigneeName "
                   + "FROM CsatSurveys cs "
                   + "JOIN Tickets t ON cs.TicketId = t.Id "
                   + "JOIN Users u ON cs.UserId = u.Id "
                   + "LEFT JOIN Users a ON t.AssignedTo = a.Id "
                   + "ORDER BY cs.SubmittedAt DESC";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                CsatSurvey s = new CsatSurvey();
                s.setId(rs.getInt("Id"));
                s.setTicketId(rs.getInt("TicketId"));
                s.setUserId(rs.getInt("UserId"));
                s.setRating(rs.getInt("Rating"));
                s.setComment(rs.getString("Comment"));
                s.setSubmittedAt(rs.getTimestamp("SubmittedAt"));
                s.setTicketNumber(rs.getString("TicketNumber"));
                s.setTicketTitle(rs.getString("TicketTitle"));
                s.setUserFullName(rs.getString("UserFullName"));
                s.setAssigneeName(rs.getString("AssigneeName"));
                list.add(s);
            }
        } catch (SQLException e) {
            System.err.println("[CsatSurveyDAO] getAllSurveys error: " + e.getMessage());
        }
        return list;
    }

    // ─────────────────────────────────────────────────────────────────────────
    // 5. Thống kê (dùng cho Manager dashboard / performance-dashboard.jsp)
    // ─────────────────────────────────────────────────────────────────────────

    /** Điểm trung bình toàn bộ surveys */
    public double getAverageRating() {
        String sql = "SELECT AVG(CAST(Rating AS FLOAT)) FROM CsatSurveys";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ResultSet rs = ps.executeQuery();
            if (rs.next()) return rs.getDouble(1);
        } catch (SQLException e) {
            System.err.println("[CsatSurveyDAO] getAverageRating error: " + e.getMessage());
        }
        return 0.0;
    }

    /** Tổng số surveys đã submit */
    public int getTotalSurveys() {
        String sql = "SELECT COUNT(1) FROM CsatSurveys";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ResultSet rs = ps.executeQuery();
            if (rs.next()) return rs.getInt(1);
        } catch (SQLException e) {
            System.err.println("[CsatSurveyDAO] getTotalSurveys error: " + e.getMessage());
        }
        return 0;
    }

    /**
     * Phân bố rating: trả về int[5] — index 0 = số rating-1, index 4 = số rating-5
     */
    public int[] getRatingDistribution() {
        int[] dist = new int[5];
        String sql = "SELECT Rating, COUNT(1) AS Cnt FROM CsatSurveys GROUP BY Rating";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                int r = rs.getInt("Rating");
                if (r >= 1 && r <= 5) dist[r - 1] = rs.getInt("Cnt");
            }
        } catch (SQLException e) {
            System.err.println("[CsatSurveyDAO] getRatingDistribution error: " + e.getMessage());
        }
        return dist;
    }

    /**
     * Tỉ lệ phản hồi = số tickets Closed có survey / tổng tickets Closed
     * Dùng bảng Tickets có sẵn (cột Status, ClosedAt)
     */
    public double getResponseRate() {
        String sql = "SELECT "
                   + "  CAST(COUNT(cs.Id) AS FLOAT) / NULLIF(COUNT(t.Id), 0) * 100 "
                   + "FROM Tickets t "
                   + "LEFT JOIN CsatSurveys cs ON t.Id = cs.TicketId "
                   + "WHERE t.Status = 'Closed'";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ResultSet rs = ps.executeQuery();
            if (rs.next()) return rs.getDouble(1);
        } catch (SQLException e) {
            System.err.println("[CsatSurveyDAO] getResponseRate error: " + e.getMessage());
        }
        return 0.0;
    }
}