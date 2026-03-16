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

    public java.util.List<java.util.Map<String, Object>> getBreachList(String team, String priority, String agent,
            String status, String sortBy, int offset, int limit) {
        java.util.List<java.util.Map<String, Object>> list = new java.util.ArrayList<>();
        StringBuilder sql = new StringBuilder(
                "SELECT t.Id, t.TicketNumber, t.Title, t.Status, p.Level as Priority, st.ResolutionDeadline, u.FullName as AssignedTo, "
                        +
                        "DATEDIFF(MINUTE, GETDATE(), st.ResolutionDeadline) as RemainingMinutes " +
                        "FROM [dbo].[SLATracking] st " +
                        "JOIN [dbo].[Tickets] t ON st.TicketId = t.Id " +
                        "LEFT JOIN [dbo].[Priorities] p ON t.PriorityId = p.Id " +
                        "LEFT JOIN [dbo].[Users] u ON t.AssignedTo = u.Id " +
                        "WHERE 1=1 ");

        if (priority != null && !priority.isEmpty()) {
            sql.append("AND t.PriorityId = ? ");
        }
        if (status != null && !status.isEmpty()) {
            sql.append("AND t.Status = ? ");
        }
        if (agent != null && !agent.isEmpty()) {
            sql.append("AND u.FullName LIKE ? ");
        }
        sql.append("AND t.Status NOT IN ('Resolved', 'Closed', 'Cancelled') ");
        sql.append("AND st.ResolutionDeadline < DATEADD(hour, 4, GETDATE()) ");

        if ("remaining".equals(sortBy)) {
            sql.append("ORDER BY st.ResolutionDeadline ASC ");
        } else {
            sql.append("ORDER BY st.ResolutionDeadline ASC ");
        }

        sql.append("OFFSET ? ROWS FETCH NEXT ? ROWS ONLY");

        try {
            PreparedStatement stm = connection.prepareStatement(sql.toString());
            int paramIndex = 1;
            if (priority != null && !priority.isEmpty()) {
                stm.setInt(paramIndex++, Integer.parseInt(priority));
            }
            if (status != null && !status.isEmpty()) {
                stm.setString(paramIndex++, status);
            }
            if (agent != null && !agent.isEmpty()) {
                stm.setString(paramIndex++, "%" + agent + "%");
            }
            stm.setInt(paramIndex++, offset);
            stm.setInt(paramIndex++, limit);

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
                map.put("RemainingMinutes", rs.getInt("RemainingMinutes"));
                list.add(map);
            }
        } catch (Exception ex) {
            ex.printStackTrace();
        }
        return list;
    }

    public java.util.Map<String, Object> getPerformanceStats(java.sql.Date from, java.sql.Date to) {
        java.util.Map<String, Object> stats = new java.util.HashMap<>();
        String sql = "SELECT " +
                "COUNT(*) as Total, " +
                "SUM(CASE WHEN Status IN ('Open', 'In Progress', 'On Hold') THEN 1 ELSE 0 END) as OpenTickets, " +
                "SUM(CASE WHEN Status = 'Resolved' THEN 1 ELSE 0 END) as ResolvedTickets, " +
                "AVG(CASE WHEN Status IN ('Resolved', 'Closed') AND ResolvedAt IS NOT NULL THEN DATEDIFF(HOUR, CreatedAt, ResolvedAt) ELSE NULL END) as AvgResolutionTime "
                +
                "FROM Tickets WHERE CreatedAt >= ? AND CreatedAt <= ?";
        try {
            PreparedStatement stm = connection.prepareStatement(sql);
            stm.setDate(1, from);
            stm.setDate(2, to);
            java.sql.ResultSet rs = stm.executeQuery();
            if (rs.next()) {
                stats.put("Total", rs.getInt("Total"));
                stats.put("OpenTickets", rs.getInt("OpenTickets"));
                stats.put("ResolvedTickets", rs.getInt("ResolvedTickets"));
                stats.put("AvgResolutionTime", rs.getDouble("AvgResolutionTime"));

                double total = rs.getInt("Total");
                double resolved = rs.getInt("ResolvedTickets");
                double rate = (total > 0) ? (resolved / total) * 100 : 0;
                stats.put("ResolutionRate", (int) rate);
            }
        } catch (Exception ex) {
            ex.printStackTrace();
        }
        return stats;
    }

    public java.util.Map<String, Object> getSLAComplianceStats(java.sql.Date from, java.sql.Date to) {
        java.util.Map<String, Object> stats = new java.util.HashMap<>();
        String sql = "SELECT " +
                "COUNT(*) as TotalTracked, " +
                "SUM(CASE WHEN (t.ResolvedAt IS NOT NULL AND t.ResolvedAt > st.ResolutionDeadline) " +
                "OR (t.ResolvedAt IS NULL AND st.ResolutionDeadline < GETDATE()) THEN 1 ELSE 0 END) as Breached " +
                "FROM SLATracking st " +
                "JOIN Tickets t ON st.TicketId = t.Id " +
                "WHERE t.CreatedAt >= ? AND t.CreatedAt <= ?";
        try {
            PreparedStatement stm = connection.prepareStatement(sql);
            stm.setDate(1, from);
            stm.setDate(2, to);
            java.sql.ResultSet rs = stm.executeQuery();
            if (rs.next()) {
                int total = rs.getInt("TotalTracked");
                int breached = rs.getInt("Breached");
                stats.put("TotalTracked", total);
                stats.put("Breached", breached);
                stats.put("Met", total - breached);
                double compliance = (total > 0) ? ((double) (total - breached) / total) * 100 : 100;
                stats.put("ComplianceRate", (int) compliance);
            }
        } catch (Exception ex) {
            ex.printStackTrace();
        }
        return stats;
    }

    public java.util.List<java.util.Map<String, Object>> getTrendData(java.sql.Date from, java.sql.Date to) {
        java.util.List<java.util.Map<String, Object>> list = new java.util.ArrayList<>();
        String sql = "SELECT CAST(CreatedAt AS DATE) as Date, COUNT(*) as Created, " +
                "SUM(CASE WHEN Status='Resolved' THEN 1 ELSE 0 END) as Resolved " +
                "FROM Tickets " +
                "WHERE CreatedAt >= ? AND CreatedAt <= ? " +
                "GROUP BY CAST(CreatedAt AS DATE) " +
                "ORDER BY CAST(CreatedAt AS DATE)";
        try {
            PreparedStatement stm = connection.prepareStatement(sql);
            stm.setDate(1, from);
            stm.setDate(2, to);
            java.sql.ResultSet rs = stm.executeQuery();
            while (rs.next()) {
                java.util.Map<String, Object> map = new java.util.HashMap<>();
                map.put("Date", rs.getDate("Date").toString());
                map.put("Created", rs.getInt("Created"));
                map.put("Resolved", rs.getInt("Resolved"));
                list.add(map);
            }
        } catch (Exception ex) {
            ex.printStackTrace();
        }
        return list;
    }
    
    // --- THÊM VÀO SLATrackingDao ---
    public SLATracking getSLATrackingByTicketId(int ticketId) {
        String sql = "SELECT * FROM [dbo].[SLATracking] WHERE TicketId = ?";
        try (PreparedStatement stm = connection.prepareStatement(sql)) {
            stm.setInt(1, ticketId);
            try (java.sql.ResultSet rs = stm.executeQuery()) {
                if (rs.next()) {
                    SLATracking sla = new SLATracking();
                    sla.setId(rs.getInt("Id"));
                    sla.setTicketId(rs.getInt("TicketId"));
                    sla.setResponseDeadline(rs.getTimestamp("ResponseDeadline"));
                    sla.setResolutionDeadline(rs.getTimestamp("ResolutionDeadline"));
                    sla.setIsBreached(rs.getBoolean("IsBreached"));
                    return sla;
                }
            }
        } catch (Exception ex) {
            ex.printStackTrace();
        }
        return null;
    }
}
