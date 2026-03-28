package dao;

import Utils.DbContext;
import model.TicketComments;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;

public class TicketCommentsDAO extends DbContext {

    public boolean addComment(TicketComments c) {
        String sql = "INSERT INTO [dbo].[TicketComments] (TicketId, UserId, Content, IsInternal, CreatedAt) VALUES (?, ?, ?, ?, GETDATE())";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, c.getTicketId());
            ps.setInt(2, c.getUserId());
            ps.setString(3, c.getContent());
            ps.setBoolean(4, c.isInternal());
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    public boolean addComment(int ticketId, int userId, String content, boolean isInternal) {
        String sql = "INSERT INTO [dbo].[TicketComments] (TicketId, UserId, Content, IsInternal, CreatedAt) VALUES (?, ?, ?, ?, GETDATE())";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, ticketId);
            ps.setInt(2, userId);
            ps.setString(3, content);
            ps.setBoolean(4, isInternal);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    public List<TicketComments> getCommentsByTicketId(int ticketId, boolean isAgentOrManager) {
        List<TicketComments> list = new ArrayList<>();
        String sql = "SELECT c.*, u.FullName, u.Role FROM [dbo].[TicketComments] c " +
                     "JOIN [dbo].[Users] u ON c.UserId = u.Id " +
                     "WHERE c.TicketId = ? ";
                     
        if (!isAgentOrManager) {
            sql += "AND c.IsInternal = 0 ";
        }
        sql += "ORDER BY c.CreatedAt DESC";

        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, ticketId);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                TicketComments c = new TicketComments();
                c.setId(rs.getInt("Id"));
                c.setTicketId(rs.getInt("TicketId"));
                c.setUserId(rs.getInt("UserId"));
                c.setContent(rs.getString("Content"));
                c.setInternal(rs.getBoolean("IsInternal"));
                c.setCreatedAt(rs.getTimestamp("CreatedAt"));
                c.setUserFullName(rs.getString("FullName"));
                c.setUserRole(rs.getString("Role"));
                list.add(c);
            }
        } catch (Exception e) { e.printStackTrace(); }
        return list;
    }
}