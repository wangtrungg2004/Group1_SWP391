/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package dao;

/**
 *
 * @author Dumb Trung
 */

import Utils.DbContext;
import model.TicketComments;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;

public class TicketCommentsDAO extends DbContext {

    public boolean addComment(TicketComments c) {
        // Khớp 100% với các cột trong CSDL của bạn
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

    public List<TicketComments> getCommentsByTicketId(int ticketId, boolean isAgentOrManager) {
        List<TicketComments> list = new ArrayList<>();
        // Join với bảng Users để lấy Tên và Role
        String sql = "SELECT c.*, u.FullName, u.Role FROM [dbo].[TicketComments] c " +
                     "JOIN [dbo].[Users] u ON c.UserId = u.Id " +
                     "WHERE c.TicketId = ? ";
                     
        // Nếu là User thường, KHÔNG lấy các Comment nội bộ
        if (!isAgentOrManager) {
            sql += "AND c.IsInternal = 0 ";
        }
        sql += "ORDER BY c.CreatedAt DESC"; // Sắp xếp giảm dần để comment mới lên đầu

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
                
                // Thuộc tính UI
                c.setUserFullName(rs.getString("FullName"));
                c.setUserRole(rs.getString("Role"));
                list.add(c);
            }
        } catch (Exception e) { e.printStackTrace(); }
        return list;
    }
}
