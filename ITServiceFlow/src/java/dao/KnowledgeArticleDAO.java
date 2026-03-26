package dao;

import Utils.DbContext;
import model.KnowledgeArticles;

import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

/**
 * DAO for KnowledgeArticles table.
 */
public class KnowledgeArticleDAO extends DbContext {

    // ── Search articles by keyword (title or content), only Published ──────
    public List<KnowledgeArticles> searchArticles(String keyword) {
        List<KnowledgeArticles> list = new ArrayList<>();
        String sql;
        boolean hasKeyword = (keyword != null && !keyword.trim().isEmpty());

        if (hasKeyword) {
            sql = "SELECT * FROM KnowledgeArticles WHERE Status = 'Published' " +
                  "AND (Title LIKE ? OR Content LIKE ?) ORDER BY CreatedAt DESC";
        } else {
            sql = "SELECT * FROM KnowledgeArticles WHERE Status = 'Published' ORDER BY CreatedAt DESC";
        }

        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            if (hasKeyword) {
                String pattern = "%" + keyword.trim() + "%";
                ps.setString(1, pattern);
                ps.setString(2, pattern);
            }
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                list.add(mapRow(rs));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    // ── Get article by ID and increment view count ─────────────────────────
    public KnowledgeArticles getArticleById(int id) {
        String sql = "SELECT * FROM KnowledgeArticles WHERE Id = ?";
        KnowledgeArticles article = null;
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, id);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                article = mapRow(rs);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        if (article != null) {
            incrementViewCount(id);
        }
        return article;
    }

    // ── Increment view count ───────────────────────────────────────────────
    private void incrementViewCount(int id) {
        String sql = "UPDATE KnowledgeArticles SET ViewCount = ISNULL(ViewCount, 0) + 1 WHERE Id = ?";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, id);
            ps.executeUpdate();
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }

    // ── Update ticket resolution fields (Title, Description, ResolutionNotes) ──
    public boolean updateTicketResolution(int ticketId, String title,
                                          String description, String resolutionNotes) {
       
        String sql = "UPDATE Tickets SET Title = ?, Description = ?, " +
                     "ResolutionNotes = ?, UpdatedAt = GETDATE() WHERE Id = ? AND Status = 'Resolved'";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setString(1, title);
            ps.setString(2, description);
            ps.setString(3, resolutionNotes);
            ps.setInt(4, ticketId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            // If ResolutionNotes column doesn't exist, fall back
            if (e.getMessage() != null && e.getMessage().contains("ResolutionNotes")) {
                return updateTicketResolutionFallback(ticketId, title, description, resolutionNotes);
            }
            e.printStackTrace();
            return false;
        }
    }

    private boolean updateTicketResolutionFallback(int ticketId, String title,
                                                    String description, String resolutionNotes) {
        String combined = description + "\n\n[Resolution Steps]\n" + resolutionNotes;
        String sql = "UPDATE Tickets SET Title = ?, Description = ?, UpdatedAt = GETDATE() " +
                     "WHERE Id = ? AND Status = 'Resolved'";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setString(1, title);
            ps.setString(2, combined);
            ps.setInt(3, ticketId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

   
    private KnowledgeArticles mapRow(ResultSet rs) throws SQLException {
        KnowledgeArticles a = new KnowledgeArticles();
        a.setId(rs.getInt("Id"));
        a.setArticleNumber(rs.getString("ArticleNumber"));
        a.setTitle(rs.getString("Title"));
        a.setContent(rs.getString("Content"));
        a.setCategoryId((Integer) rs.getObject("CategoryId"));
        a.setStatus(rs.getString("Status"));
        a.setViewCount((Integer) rs.getObject("ViewCount"));
        a.setCreatedBy(rs.getInt("CreatedBy"));
        a.setCreatedAt(rs.getTimestamp("CreatedAt"));
        return a;
    }
}
