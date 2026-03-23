package dao;

import Utils.DbContext;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Types;
import java.util.ArrayList;
import java.util.HashSet;
import java.util.List;
import java.util.Set;
import model.CsatSurvey;

public class CsatSurveyDAO extends DbContext {

    private volatile Boolean csatTableAvailable;

    private boolean isCsatTableAvailable() {
        Boolean cached = csatTableAvailable;
        if (cached != null) {
            return cached;
        }
        boolean available = hasTable("CsatSurveys");
        csatTableAvailable = available;
        return available;
    }

    private boolean isReady() {
        return hasConnection() && isCsatTableAvailable();
    }

    public boolean submitSurvey(CsatSurvey survey) {
        if (!isReady()) {
            return false;
        }
        String sql = "INSERT INTO CsatSurveys (TicketId, UserId, Rating, Comment) VALUES (?, ?, ?, ?)";
        try (PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setInt(1, survey.getTicketId());
            statement.setInt(2, survey.getUserId());
            statement.setInt(3, survey.getRating());
            if (survey.getComment() != null && !survey.getComment().trim().isEmpty()) {
                statement.setString(4, survey.getComment().trim());
            } else {
                statement.setNull(4, Types.NVARCHAR);
            }
            return statement.executeUpdate() > 0;
        } catch (SQLException ex) {
            System.err.println("[CsatSurveyDAO] submitSurvey error: " + ex.getMessage());
            return false;
        }
    }

    public boolean hasUserSubmitted(int ticketId, int userId) {
        if (!isReady()) {
            return false;
        }
        String sql = "SELECT COUNT(1) FROM CsatSurveys WHERE TicketId = ? AND UserId = ?";
        try (PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setInt(1, ticketId);
            statement.setInt(2, userId);
            ResultSet rs = statement.executeQuery();
            if (rs.next()) {
                return rs.getInt(1) > 0;
            }
        } catch (SQLException ex) {
            System.err.println("[CsatSurveyDAO] hasUserSubmitted error: " + ex.getMessage());
        }
        return false;
    }

    public CsatSurvey getSurveyByTicket(int ticketId) {
        if (!isReady()) {
            return null;
        }
        String sql = "SELECT cs.Id, cs.TicketId, cs.UserId, cs.Rating, cs.Comment, cs.SubmittedAt, "
                + "u.FullName AS UserFullName "
                + "FROM CsatSurveys cs "
                + "JOIN Users u ON cs.UserId = u.Id "
                + "WHERE cs.TicketId = ?";
        try (PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setInt(1, ticketId);
            ResultSet rs = statement.executeQuery();
            if (rs.next()) {
                CsatSurvey survey = new CsatSurvey();
                survey.setId(rs.getInt("Id"));
                survey.setTicketId(rs.getInt("TicketId"));
                survey.setUserId(rs.getInt("UserId"));
                survey.setRating(rs.getInt("Rating"));
                survey.setComment(rs.getString("Comment"));
                survey.setSubmittedAt(rs.getTimestamp("SubmittedAt"));
                survey.setUserFullName(rs.getString("UserFullName"));
                return survey;
            }
        } catch (SQLException ex) {
            System.err.println("[CsatSurveyDAO] getSurveyByTicket error: " + ex.getMessage());
        }
        return null;
    }

    public List<CsatSurvey> getAllSurveys() {
        List<CsatSurvey> list = new ArrayList<>();
        if (!isReady()) {
            return list;
        }

        String sql = "SELECT cs.Id, cs.TicketId, cs.UserId, cs.Rating, cs.Comment, cs.SubmittedAt, "
                + "t.TicketNumber, t.Title AS TicketTitle, "
                + "u.FullName AS UserFullName, "
                + "ISNULL(a.FullName, 'Unassigned') AS AssigneeName "
                + "FROM CsatSurveys cs "
                + "JOIN Tickets t ON cs.TicketId = t.Id "
                + "JOIN Users u ON cs.UserId = u.Id "
                + "LEFT JOIN Users a ON t.AssignedTo = a.Id "
                + "ORDER BY cs.SubmittedAt DESC";
        try (PreparedStatement statement = connection.prepareStatement(sql)) {
            ResultSet rs = statement.executeQuery();
            while (rs.next()) {
                CsatSurvey survey = new CsatSurvey();
                survey.setId(rs.getInt("Id"));
                survey.setTicketId(rs.getInt("TicketId"));
                survey.setUserId(rs.getInt("UserId"));
                survey.setRating(rs.getInt("Rating"));
                survey.setComment(rs.getString("Comment"));
                survey.setSubmittedAt(rs.getTimestamp("SubmittedAt"));
                survey.setTicketNumber(rs.getString("TicketNumber"));
                survey.setTicketTitle(rs.getString("TicketTitle"));
                survey.setUserFullName(rs.getString("UserFullName"));
                survey.setAssigneeName(rs.getString("AssigneeName"));
                list.add(survey);
            }
        } catch (SQLException ex) {
            System.err.println("[CsatSurveyDAO] getAllSurveys error: " + ex.getMessage());
        }
        return list;
    }

    public double getAverageRating() {
        if (!isReady()) {
            return 0.0;
        }
        String sql = "SELECT AVG(CAST(Rating AS FLOAT)) FROM CsatSurveys";
        try (PreparedStatement statement = connection.prepareStatement(sql)) {
            ResultSet rs = statement.executeQuery();
            if (rs.next()) {
                return rs.getDouble(1);
            }
        } catch (SQLException ex) {
            System.err.println("[CsatSurveyDAO] getAverageRating error: " + ex.getMessage());
        }
        return 0.0;
    }

    public int getTotalSurveys() {
        if (!isReady()) {
            return 0;
        }
        String sql = "SELECT COUNT(1) FROM CsatSurveys";
        try (PreparedStatement statement = connection.prepareStatement(sql)) {
            ResultSet rs = statement.executeQuery();
            if (rs.next()) {
                return rs.getInt(1);
            }
        } catch (SQLException ex) {
            System.err.println("[CsatSurveyDAO] getTotalSurveys error: " + ex.getMessage());
        }
        return 0;
    }

    public int[] getRatingDistribution() {
        int[] distribution = new int[5];
        if (!isReady()) {
            return distribution;
        }
        String sql = "SELECT Rating, COUNT(1) AS Cnt FROM CsatSurveys GROUP BY Rating";
        try (PreparedStatement statement = connection.prepareStatement(sql)) {
            ResultSet rs = statement.executeQuery();
            while (rs.next()) {
                int rating = rs.getInt("Rating");
                if (rating >= 1 && rating <= 5) {
                    distribution[rating - 1] = rs.getInt("Cnt");
                }
            }
        } catch (SQLException ex) {
            System.err.println("[CsatSurveyDAO] getRatingDistribution error: " + ex.getMessage());
        }
        return distribution;
    }

    public Set<Integer> getSubmittedTicketIdsByUser(int userId) {
        Set<Integer> ids = new HashSet<>();
        if (!isReady()) {
            return ids;
        }
        String sql = "SELECT TicketId FROM CsatSurveys WHERE UserId = ?";
        try (PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setInt(1, userId);
            ResultSet rs = statement.executeQuery();
            while (rs.next()) {
                ids.add(rs.getInt("TicketId"));
            }
        } catch (SQLException ex) {
            System.err.println("[CsatSurveyDAO] getSubmittedTicketIdsByUser error: " + ex.getMessage());
        }
        return ids;
    }

    public double getResponseRate() {
        if (!isReady()) {
            return 0.0;
        }
        String sql = "SELECT CAST(COUNT(cs.Id) AS FLOAT) / NULLIF(COUNT(t.Id), 0) * 100 "
                + "FROM Tickets t "
                + "LEFT JOIN CsatSurveys cs ON t.Id = cs.TicketId "
                + "WHERE t.Status = 'Closed'";
        try (PreparedStatement statement = connection.prepareStatement(sql)) {
            ResultSet rs = statement.executeQuery();
            if (rs.next()) {
                return rs.getDouble(1);
            }
        } catch (SQLException ex) {
            System.err.println("[CsatSurveyDAO] getResponseRate error: " + ex.getMessage());
        }
        return 0.0;
    }

    public List<Object[]> getAvgRatingByAgent() {
        List<Object[]> list = new ArrayList<>();
        if (!isReady()) {
            return list;
        }
        String sql = "SELECT a.FullName AS AgentName, "
                + "AVG(CAST(cs.Rating AS FLOAT)) AS AvgRating, "
                + "COUNT(cs.Id) AS TotalSurveys "
                + "FROM CsatSurveys cs "
                + "JOIN Tickets t ON cs.TicketId = t.Id "
                + "JOIN Users a ON t.AssignedTo = a.Id "
                + "GROUP BY a.Id, a.FullName "
                + "ORDER BY AvgRating DESC";
        try (PreparedStatement statement = connection.prepareStatement(sql)) {
            ResultSet rs = statement.executeQuery();
            while (rs.next()) {
                list.add(new Object[]{
                    rs.getString("AgentName"),
                    rs.getDouble("AvgRating"),
                    rs.getInt("TotalSurveys")
                });
            }
        } catch (SQLException ex) {
            System.err.println("[CsatSurveyDAO] getAvgRatingByAgent error: " + ex.getMessage());
        }
        return list;
    }
}
