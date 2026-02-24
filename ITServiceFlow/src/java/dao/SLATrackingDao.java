/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package dao;

import Utils.DbContext;
import java.sql.PreparedStatement;
import model.SLATracking;

/**
 *
 * @author DELL
 */
public class SLATrackingDao extends DbContext {

    public boolean addSLATracking(SLATracking tracking) {
        String sql = "INSERT INTO [dbo].[SLATracking] (TicketId, ResponseDeadline, ResolutionDeadline, IsBreached, CreatedAt) "
                + "VALUES (?, ?, ?, 0, GETDATE())";
        try {
            PreparedStatement stm = connection.prepareStatement(sql);
            stm.setInt(1, tracking.getTicketId());
            stm.setTimestamp(2, new java.sql.Timestamp(tracking.getResponseDeadline().getTime()));
            stm.setTimestamp(3, new java.sql.Timestamp(tracking.getResolutionDeadline().getTime()));
            return stm.executeUpdate() > 0;
        } catch (Exception ex) {
            ex.printStackTrace();
        }
        return false;
    }

    public java.util.Map<String, Integer> getSLAStatistics() {
        java.util.Map<String, Integer> stats = new java.util.HashMap<>();
        String sql = "SELECT " +
                "  SUM(CASE WHEN t.Status NOT IN ('Resolved', 'Closed', 'Cancelled') AND st.ResolutionDeadline < GETDATE() THEN 1 ELSE 0 END) AS Breached, "
                +
                "  SUM(CASE WHEN t.Status NOT IN ('Resolved', 'Closed', 'Cancelled') AND st.ResolutionDeadline BETWEEN GETDATE() AND DATEADD(hour, 2, GETDATE()) THEN 1 ELSE 0 END) AS NearBreach, "
                +
                "  COUNT(*) AS TotalTracked " +
                "FROM [dbo].[SLATracking] st " +
                "JOIN [dbo].[Tickets] t ON st.TicketId = t.Id";
        try {
            PreparedStatement stm = connection.prepareStatement(sql);
            java.sql.ResultSet rs = stm.executeQuery();
            if (rs.next()) {
                stats.put("Breached", rs.getInt("Breached"));
                stats.put("NearBreach", rs.getInt("NearBreach"));
                stats.put("TotalTracked", rs.getInt("TotalTracked"));
            }
        } catch (Exception ex) {
            ex.printStackTrace();
        }
        return stats;
    }

    public java.util.List<java.util.Map<String, Object>> getBreachedTickets(int limit) {
        return getTicketsByCondition(
                "t.Status NOT IN ('Resolved', 'Closed', 'Cancelled') AND st.ResolutionDeadline < GETDATE()", limit);
    }

    public java.util.List<java.util.Map<String, Object>> getNearBreachTickets(int limit) {
        return getTicketsByCondition(
                "t.Status NOT IN ('Resolved', 'Closed', 'Cancelled') AND st.ResolutionDeadline BETWEEN GETDATE() AND DATEADD(hour, 2, GETDATE())",
                limit);
    }

    private java.util.List<java.util.Map<String, Object>> getTicketsByCondition(String condition, int limit) {
        java.util.List<java.util.Map<String, Object>> list = new java.util.ArrayList<>();
        String sql = "SELECT TOP (?) t.Id, t.TicketNumber, t.Title, t.Status, p.Level as Priority, st.ResolutionDeadline, u.FullName as AssignedTo "
                +
                "FROM [dbo].[SLATracking] st " +
                "JOIN [dbo].[Tickets] t ON st.TicketId = t.Id " +
                "LEFT JOIN [dbo].[Priorities] p ON t.PriorityId = p.Id " +
                "LEFT JOIN [dbo].[Users] u ON t.AssignedTo = u.Id " +
                "WHERE " + condition + " " +
                "ORDER BY st.ResolutionDeadline ASC";
        try {
            PreparedStatement stm = connection.prepareStatement(sql);
            stm.setInt(1, limit);
            java.sql.ResultSet rs = stm.executeQuery();
            while (rs.next()) {
                java.util.Map<String, Object> map = new java.util.HashMap<>();
                map.put("Id", rs.getInt("Id"));
                map.put("TicketNumber", rs.getString("TicketNumber"));
                map.put("Title", rs.getString("Title"));
                map.put("Status", rs.getString("Status"));
                map.put("Priority", rs.getString("Priority"));
                map.put("ResolutionDeadline", rs.getTimestamp("ResolutionDeadline"));
                map.put("AssignedTo", rs.getString("AssignedTo"));
                list.add(map);
            }
        } catch (Exception ex) {
            ex.printStackTrace();
        }
        return list;
    }
}
