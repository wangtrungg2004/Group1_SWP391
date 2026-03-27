package dao;

import Utils.DbContext;
import java.sql.PreparedStatement;
import java.sql.SQLException;
import java.util.Calendar;
import java.util.Date;
import java.util.HashMap;
import java.util.List;
import java.util.ArrayList;
import java.util.Map;
import model.SLARule;
import model.SLATracking;

public class SLATrackingDao extends DbContext {

    public boolean addSLATracking(SLATracking tracking) {
        String sql = "INSERT INTO [dbo].[SLATracking] (TicketId, ResponseDeadline, ResolutionDeadline, IsBreached, CreatedAt) "
                + "VALUES (?, ?, ?, 0, GETDATE())";
        try (PreparedStatement stm = connection.prepareStatement(sql)) {
            stm.setInt(1, tracking.getTicketId());
            stm.setTimestamp(2, new java.sql.Timestamp(tracking.getResponseDeadline().getTime()));
            stm.setTimestamp(3, new java.sql.Timestamp(tracking.getResolutionDeadline().getTime()));
            return stm.executeUpdate() > 0;
        } catch (Exception ex) {
            ex.printStackTrace();
        }
        return false;
    }

    // =========================================================================
    // CODE TÍCH HỢP SLA (TỰ ĐỘNG TÍNH TOÁN DEADLINE CHO CREATE & EDIT)
    // =========================================================================

    public void applySLAForTicket(int ticketId, String ticketType, Integer priorityId) {
        // Nếu là Service Request không có Priority (hoặc chưa phân loại) -> Bỏ qua
        if (priorityId == null || priorityId <= 0) return; 

        SLARuleDao ruleDao = new SLARuleDao();
        // Lấy Rule SLA đang Active tương ứng với Type và Priority
        model.SLARule rule = ruleDao.getActiveRuleByTypeAndPriority(ticketType, priorityId);
        
        if (rule != null) {
            java.util.Date now = new java.util.Date();
            
            // Đổi số giờ (Hours) quy định thành Milliseconds (1h = 3,600,000 ms)
            long responseMillis = rule.getResponseTime() * 3600000L;
            long resolutionMillis = rule.getResolutionTime() * 3600000L;
            
            // Tính toán Deadline
            java.util.Date responseDeadline = new java.util.Date(now.getTime() + responseMillis);
            java.util.Date resolutionDeadline = new java.util.Date(now.getTime() + resolutionMillis);
            
            // Kiểm tra xem vé này đã có Track SLA chưa (Phục vụ cho luồng Edit)
            SLATracking existing = getSLATrackingByTicketId(ticketId);
            if (existing != null) {
                // Đã có -> Cập nhật lại Deadline mới
                updateSLATrackingDeadlines(ticketId, responseDeadline, resolutionDeadline);
            } else {
                // Chưa có -> Tạo mới Track SLA
                SLATracking tracking = new SLATracking();
                tracking.setTicketId(ticketId);
                tracking.setResponseDeadline(responseDeadline);
                tracking.setResolutionDeadline(resolutionDeadline);
                addSLATracking(tracking);
            }
        }
    }

    public boolean updateSLATrackingDeadlines(int ticketId, java.util.Date resp, java.util.Date res) {
        String sql = "UPDATE [dbo].[SLATracking] SET ResponseDeadline = ?, ResolutionDeadline = ? WHERE TicketId = ?";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
             ps.setTimestamp(1, new java.sql.Timestamp(resp.getTime()));
             ps.setTimestamp(2, new java.sql.Timestamp(res.getTime()));
             ps.setInt(3, ticketId);
             return ps.executeUpdate() > 0;
        } catch (Exception e) { 
             e.printStackTrace(); 
             return false; 
        }
    }

    public SLATracking getSLATrackingByTicketId(int ticketId) {
        String sql = "SELECT TOP 1 * FROM [dbo].[SLATracking] WHERE TicketId = ?";
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

    public Map<String, Integer> getSLAStatistics() {
        return getSLAStatistics(null, null, null, null);
    }

    public Map<String, Integer> getSLAStatistics(java.sql.Date from, java.sql.Date to, Integer categoryId, Integer locationId) {
        Map<String, Integer> stats = new HashMap<>();
        StringBuilder sql = new StringBuilder("SELECT "
                + "SUM(CASE WHEN t.Status NOT IN ('Resolved', 'Closed', 'Cancelled') AND st.ResolutionDeadline < GETDATE() THEN 1 ELSE 0 END) AS Breached, "
                + "SUM(CASE WHEN t.Status NOT IN ('Resolved', 'Closed', 'Cancelled') AND st.ResolutionDeadline BETWEEN GETDATE() AND DATEADD(hour, 2, GETDATE()) THEN 1 ELSE 0 END) AS NearBreach, "
                + "COUNT(*) AS TotalTracked "
                + "FROM [dbo].[SLATracking] st "
                + "JOIN [dbo].[Tickets] t ON st.TicketId = t.Id WHERE 1=1 ");

        if (from != null) sql.append(" AND t.CreatedAt >= ? ");
        if (to != null) sql.append(" AND t.CreatedAt < ? ");
        if (categoryId != null && categoryId > 0) sql.append(" AND t.CategoryId = ? ");
        if (locationId != null && locationId > 0) sql.append(" AND t.LocationId = ? ");

        try (PreparedStatement stm = connection.prepareStatement(sql.toString())) {
            int idx = 1;
            if (from != null) stm.setDate(idx++, from);
            if (to != null) stm.setDate(idx++, to);
            if (categoryId != null && categoryId > 0) stm.setInt(idx++, categoryId);
            if (locationId != null && locationId > 0) stm.setInt(idx++, locationId);
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

    public List<Map<String, Object>> getBreachedTickets(int limit) {
        return getBreachedTickets(limit, null, null, null, null);
    }

    public List<Map<String, Object>> getNearBreachTickets(int limit) {
        return getNearBreachTickets(limit, null, null, null, null);
    }

    public List<Map<String, Object>> getBreachedTickets(int limit, java.sql.Date from, java.sql.Date to, Integer categoryId, Integer locationId) {
        return getTicketsByCondition("t.Status NOT IN ('Resolved', 'Closed', 'Cancelled') AND st.ResolutionDeadline < GETDATE()", limit, from, to, categoryId, locationId);
    }

    public List<Map<String, Object>> getNearBreachTickets(int limit, java.sql.Date from, java.sql.Date to, Integer categoryId, Integer locationId) {
        return getTicketsByCondition("t.Status NOT IN ('Resolved', 'Closed', 'Cancelled') AND st.ResolutionDeadline BETWEEN GETDATE() AND DATEADD(hour, 2, GETDATE())", limit, from, to, categoryId, locationId);
    }

    private List<Map<String, Object>> getTicketsByCondition(String condition, int limit, java.sql.Date from, java.sql.Date to, Integer categoryId, Integer locationId) {
        List<Map<String, Object>> list = new ArrayList<>();
        StringBuilder sql = new StringBuilder("SELECT TOP (?) t.Id, t.TicketNumber, t.Title, t.Status, p.Level as Priority, st.ResolutionDeadline, u.FullName as AssignedTo "
                + "FROM [dbo].[SLATracking] st "
                + "JOIN [dbo].[Tickets] t ON st.TicketId = t.Id "
                + "LEFT JOIN [dbo].[Priorities] p ON t.PriorityId = p.Id "
                + "LEFT JOIN [dbo].[Users] u ON t.AssignedTo = u.Id "
                + "WHERE (" + condition + ") ");
        if (from != null) sql.append(" AND t.CreatedAt >= ? ");
        if (to != null) sql.append(" AND t.CreatedAt < ? ");
        if (categoryId != null && categoryId > 0) sql.append(" AND t.CategoryId = ? ");
        if (locationId != null && locationId > 0) sql.append(" AND t.LocationId = ? ");
        sql.append(" ORDER BY st.ResolutionDeadline ASC");

        try (PreparedStatement stm = connection.prepareStatement(sql.toString())) {
            int idx = 1;
            stm.setInt(idx++, limit);
            if (from != null) stm.setDate(idx++, from);
            if (to != null) stm.setDate(idx++, to);
            if (categoryId != null && categoryId > 0) stm.setInt(idx++, categoryId);
            if (locationId != null && locationId > 0) stm.setInt(idx++, locationId);

            java.sql.ResultSet rs = stm.executeQuery();
            while (rs.next()) {
                Map<String, Object> map = new HashMap<>();
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

    public List<Map<String, Object>> getBreachList(String team, String priority, String agent, String status, String sortBy, int offset, int limit) {
        List<Map<String, Object>> list = new ArrayList<>();
        StringBuilder sql = new StringBuilder("SELECT t.Id, t.TicketNumber, t.Title, t.Status, p.Level as Priority, st.ResolutionDeadline, u.FullName as AssignedTo, "
                + "DATEDIFF(MINUTE, GETDATE(), st.ResolutionDeadline) as RemainingMinutes "
                + "FROM [dbo].[SLATracking] st "
                + "JOIN [dbo].[Tickets] t ON st.TicketId = t.Id "
                + "LEFT JOIN [dbo].[Priorities] p ON t.PriorityId = p.Id "
                + "LEFT JOIN [dbo].[Users] u ON t.AssignedTo = u.Id "
                + "WHERE 1=1 ");
        if (priority != null && !priority.isEmpty()) sql.append("AND t.PriorityId = ? ");
        if (status != null && !status.isEmpty()) sql.append("AND t.Status = ? ");
        if (agent != null && !agent.isEmpty()) sql.append("AND u.FullName LIKE ? ");
        sql.append("AND t.Status NOT IN ('Resolved', 'Closed', 'Cancelled') ");
        sql.append("AND st.ResolutionDeadline < DATEADD(hour, 2, GETDATE()) ");
        sql.append("ORDER BY st.ResolutionDeadline ASC ");
        sql.append("OFFSET ? ROWS FETCH NEXT ? ROWS ONLY");

        try (PreparedStatement stm = connection.prepareStatement(sql.toString())) {
            int paramIndex = 1;
            if (priority != null && !priority.isEmpty()) stm.setInt(paramIndex++, Integer.parseInt(priority));
            if (status != null && !status.isEmpty()) stm.setString(paramIndex++, status);
            if (agent != null && !agent.isEmpty()) stm.setString(paramIndex++, "%" + agent + "%");
            stm.setInt(paramIndex++, offset);
            stm.setInt(paramIndex++, limit);

            java.sql.ResultSet rs = stm.executeQuery();
            while (rs.next()) {
                Map<String, Object> map = new HashMap<>();
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

    public int countBreachList(String team, String priority, String agent, String status) {
        StringBuilder sql = new StringBuilder("SELECT COUNT(*) "
                + "FROM [dbo].[SLATracking] st "
                + "JOIN [dbo].[Tickets] t ON st.TicketId = t.Id "
                + "LEFT JOIN [dbo].[Users] u ON t.AssignedTo = u.Id "
                + "WHERE 1=1 ");
        if (priority != null && !priority.isEmpty()) sql.append("AND t.PriorityId = ? ");
        if (status != null && !status.isEmpty()) sql.append("AND t.Status = ? ");
        if (agent != null && !agent.isEmpty()) sql.append("AND u.FullName LIKE ? ");
        sql.append("AND t.Status NOT IN ('Resolved', 'Closed', 'Cancelled') ");
        sql.append("AND st.ResolutionDeadline < DATEADD(hour, 2, GETDATE()) ");
        try (PreparedStatement stm = connection.prepareStatement(sql.toString())) {
            int paramIndex = 1;
            if (priority != null && !priority.isEmpty()) stm.setInt(paramIndex++, Integer.parseInt(priority));
            if (status != null && !status.isEmpty()) stm.setString(paramIndex++, status);
            if (agent != null && !agent.isEmpty()) stm.setString(paramIndex++, "%" + agent + "%");
            java.sql.ResultSet rs = stm.executeQuery();
            return rs.next() ? rs.getInt(1) : 0;
        } catch (Exception ex) {
            ex.printStackTrace();
        }
        return 0;
    }

    public boolean isEscalationHistoryEnabled() {
        String sql = "SELECT OBJECT_ID('dbo.SLAEscalationHistory', 'U') AS TableId";
        try (PreparedStatement stm = connection.prepareStatement(sql);
             java.sql.ResultSet rs = stm.executeQuery()) {
            return rs.next() && rs.getObject("TableId") != null;
        } catch (Exception ex) {
            ex.printStackTrace();
        }
        return false;
    }

    public int markBreachedTickets() {
        String sql = "UPDATE st "
                + "SET st.IsBreached = 1 "
                + "FROM [dbo].[SLATracking] st "
                + "INNER JOIN [dbo].[Tickets] t ON t.Id = st.TicketId "
                + "WHERE t.Status NOT IN ('Resolved', 'Closed', 'Cancelled') "
                + "AND st.ResolutionDeadline < GETDATE() "
                + "AND ISNULL(st.IsBreached, 0) = 0";
        try (PreparedStatement stm = connection.prepareStatement(sql)) {
            return stm.executeUpdate();
        } catch (Exception ex) {
            ex.printStackTrace();
        }
        return 0;
    }

    public List<Map<String, Object>> getEscalationCandidates() {
        List<Map<String, Object>> list = new ArrayList<>();
        String sql = "SELECT st.TicketId, t.TicketNumber, t.Title, t.CreatedBy, t.AssignedTo, st.ResolutionDeadline, "
                + "DATEDIFF(MINUTE, GETDATE(), st.ResolutionDeadline) AS RemainingMinutes "
                + "FROM [dbo].[SLATracking] st "
                + "INNER JOIN [dbo].[Tickets] t ON t.Id = st.TicketId "
                + "WHERE t.Status NOT IN ('Resolved', 'Closed', 'Cancelled') "
                + "AND st.ResolutionDeadline <= DATEADD(HOUR, 2, GETDATE()) "
                + "ORDER BY st.ResolutionDeadline ASC";
        try (PreparedStatement stm = connection.prepareStatement(sql);
             java.sql.ResultSet rs = stm.executeQuery()) {
            while (rs.next()) {
                Map<String, Object> map = new HashMap<>();
                map.put("TicketId", rs.getInt("TicketId"));
                map.put("TicketNumber", rs.getString("TicketNumber"));
                map.put("Title", rs.getString("Title"));
                map.put("CreatedBy", rs.getInt("CreatedBy"));
                Object assignedObj = rs.getObject("AssignedTo");
                map.put("AssignedTo", assignedObj == null ? null : ((Number) assignedObj).intValue());
                map.put("ResolutionDeadline", rs.getTimestamp("ResolutionDeadline"));
                map.put("RemainingMinutes", rs.getInt("RemainingMinutes"));
                list.add(map);
            }
        } catch (Exception ex) {
            ex.printStackTrace();
        }
        return list;
    }

    public boolean hasEscalationHistory(int ticketId, String stageCode, Date resolutionDeadline) {
        if (resolutionDeadline == null || stageCode == null || stageCode.trim().isEmpty()) return false;
        String sql = "SELECT TOP 1 1 FROM [dbo].[SLAEscalationHistory] WHERE TicketId = ? AND StageCode = ? AND ResolutionDeadline = ?";
        try (PreparedStatement stm = connection.prepareStatement(sql)) {
            stm.setInt(1, ticketId);
            stm.setString(2, stageCode);
            stm.setTimestamp(3, new java.sql.Timestamp(resolutionDeadline.getTime()));
            try (java.sql.ResultSet rs = stm.executeQuery()) {
                return rs.next();
            }
        } catch (Exception ex) {
            ex.printStackTrace();
        }
        return false;
    }

    public boolean addEscalationHistory(int ticketId, String stageCode, String stageLabel, Date resolutionDeadline,
            Integer remainingMinutes, String notificationTargetType, Integer notificationTargetId, String notificationTitle,
            String notificationMessage, String autoAction, String escalatedToRole, Integer escalatedToUserId) {
        String sql = "INSERT INTO [dbo].[SLAEscalationHistory] "
                + "(TicketId, StageCode, StageLabel, ResolutionDeadline, RemainingMinutes, NotificationTargetType, NotificationTargetId, NotificationTitle, NotificationMessage, AutoAction, EscalatedToRole, EscalatedToUserId, TriggeredAt) "
                + "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, GETDATE())";
        try (PreparedStatement stm = connection.prepareStatement(sql)) {
            stm.setInt(1, ticketId);
            stm.setString(2, stageCode);
            stm.setString(3, stageLabel);
            stm.setTimestamp(4, new java.sql.Timestamp(resolutionDeadline.getTime()));
            if (remainingMinutes == null) stm.setNull(5, java.sql.Types.INTEGER); else stm.setInt(5, remainingMinutes);
            stm.setString(6, notificationTargetType == null ? "BROADCAST" : notificationTargetType);
            if (notificationTargetId == null) stm.setNull(7, java.sql.Types.INTEGER); else stm.setInt(7, notificationTargetId);
            stm.setString(8, notificationTitle);
            stm.setString(9, notificationMessage);
            if (autoAction == null || autoAction.trim().isEmpty()) stm.setNull(10, java.sql.Types.NVARCHAR); else stm.setString(10, autoAction);
            if (escalatedToRole == null || escalatedToRole.trim().isEmpty()) stm.setNull(11, java.sql.Types.NVARCHAR); else stm.setString(11, escalatedToRole);
            if (escalatedToUserId == null) stm.setNull(12, java.sql.Types.INTEGER); else stm.setInt(12, escalatedToUserId);
            return stm.executeUpdate() > 0;
        } catch (SQLException ex) {
            if (ex.getErrorCode() == 2601 || ex.getErrorCode() == 2627) return false;
            ex.printStackTrace();
        } catch (Exception ex) {
            ex.printStackTrace();
        }
        return false;
    }

    public Map<String, Object> getPerformanceStats(java.sql.Date from, java.sql.Date to) {
        return getPerformanceStats(from, to, null, null);
    }

    public java.util.Map<String, Object> getPerformanceStats(java.sql.Date from, java.sql.Date to, Integer categoryId, Integer locationId) {
        java.util.Map<String, Object> stats = new java.util.HashMap<>();
        StringBuilder sql = new StringBuilder("SELECT " +
                "COUNT(*) as Total, " +
                "SUM(CASE WHEN Status IN ('Open', 'In Progress', 'On Hold') THEN 1 ELSE 0 END) as OpenTickets, " +
                "SUM(CASE WHEN Status = 'Resolved' THEN 1 ELSE 0 END) as ResolvedTickets, " +
                "AVG(CASE WHEN Status = 'Resolved' AND ResolvedAt IS NOT NULL THEN CAST(DATEDIFF(HOUR, CreatedAt, ResolvedAt) AS FLOAT) ELSE NULL END) as AvgResolutionTime "
                +
                "FROM Tickets WHERE CreatedAt >= ? AND CreatedAt < ?");
        
        if (categoryId != null && categoryId > 0) sql.append(" AND CategoryId = ? ");
        if (locationId != null && locationId > 0) sql.append(" AND LocationId = ? ");

        try {
            PreparedStatement stm = connection.prepareStatement(sql.toString());
            int idx = 1;
            stm.setDate(idx++, from);
            stm.setDate(idx++, to);
            if (categoryId != null && categoryId > 0) stm.setInt(idx++, categoryId);
            if (locationId != null && locationId > 0) stm.setInt(idx++, locationId);
            
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

    public Map<String, Object> getSLAComplianceStats(java.sql.Date from, java.sql.Date to) {
        return getSLAComplianceStats(from, to, null, null);
    }

    public Map<String, Object> getSLAComplianceStats(java.sql.Date from, java.sql.Date to, Integer categoryId, Integer locationId) {
        Map<String, Object> stats = new HashMap<>();
        StringBuilder sql = new StringBuilder("SELECT COUNT(*) as TotalTracked, "
                + "SUM(CASE WHEN (t.ResolvedAt IS NOT NULL AND t.ResolvedAt > st.ResolutionDeadline) OR (t.ResolvedAt IS NULL AND st.ResolutionDeadline < GETDATE()) THEN 1 ELSE 0 END) as Breached "
                + "FROM SLATracking st JOIN Tickets t ON st.TicketId = t.Id WHERE t.CreatedAt >= ? AND t.CreatedAt < ?");
        if (categoryId != null && categoryId > 0) sql.append(" AND t.CategoryId = ? ");
        if (locationId != null && locationId > 0) sql.append(" AND t.LocationId = ? ");

        try (PreparedStatement stm = connection.prepareStatement(sql.toString())) {
            int idx = 1;
            stm.setDate(idx++, from);
            stm.setDate(idx++, to);
            if (categoryId != null && categoryId > 0) stm.setInt(idx++, categoryId);
            if (locationId != null && locationId > 0) stm.setInt(idx++, locationId);
            java.sql.ResultSet rs = stm.executeQuery();
            if (rs.next()) {
                int total = rs.getInt("TotalTracked");
                int breached = rs.getInt("Breached");
                stats.put("TotalTracked", total);
                stats.put("Breached", breached);
                stats.put("Met", total - breached);
                stats.put("ComplianceRate", (int) ((total > 0) ? ((double) (total - breached) / total) * 100 : 100));
            }
        } catch (Exception ex) {
            ex.printStackTrace();
        }
        return stats;
    }

    public List<Map<String, Object>> getTrendData(java.sql.Date from, java.sql.Date to) {
        return getTrendData(from, to, null, null);
    }

    public List<Map<String, Object>> getTrendData(java.sql.Date from, java.sql.Date to, Integer categoryId, Integer locationId) {
        List<Map<String, Object>> list = new ArrayList<>();
        StringBuilder sql = new StringBuilder("SELECT CAST(CreatedAt AS DATE) as Date, COUNT(*) as Created, "
                + "SUM(CASE WHEN Status='Resolved' THEN 1 ELSE 0 END) as Resolved FROM Tickets WHERE CreatedAt >= ? AND CreatedAt < ?");
        if (categoryId != null && categoryId > 0) sql.append(" AND CategoryId = ? ");
        if (locationId != null && locationId > 0) sql.append(" AND LocationId = ? ");
        sql.append(" GROUP BY CAST(CreatedAt AS DATE) ORDER BY CAST(CreatedAt AS DATE)");

        try (PreparedStatement stm = connection.prepareStatement(sql.toString())) {
            int idx = 1;
            stm.setDate(idx++, from);
            stm.setDate(idx++, to);
            if (categoryId != null && categoryId > 0) stm.setInt(idx++, categoryId);
            if (locationId != null && locationId > 0) stm.setInt(idx++, locationId);
            java.sql.ResultSet rs = stm.executeQuery();
            while (rs.next()) {
                Map<String, Object> map = new HashMap<>();
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

    public List<Map<String, Object>> getAgentPerformanceStats(java.sql.Date from, java.sql.Date to, Integer categoryId, Integer locationId) {
        List<Map<String, Object>> list = new ArrayList<>();
        StringBuilder sql = new StringBuilder("SELECT u.Id as UserId, u.FullName, COUNT(t.Id) as TotalAssigned, "
                + "SUM(CASE WHEN t.Status = 'Resolved' THEN 1 ELSE 0 END) as ResolvedCount, "
                + "AVG(CASE WHEN t.Status IN ('Resolved', 'Closed') AND t.ResolvedAt IS NOT NULL THEN CAST(DATEDIFF(HOUR, t.CreatedAt, t.ResolvedAt) AS FLOAT) ELSE NULL END) as AvgResolutionTime, "
                + "SUM(CASE WHEN st.TicketId IS NOT NULL AND ((t.ResolvedAt IS NOT NULL AND t.ResolvedAt > st.ResolutionDeadline) OR (t.ResolvedAt IS NULL AND st.ResolutionDeadline < GETDATE())) THEN 1 ELSE 0 END) as BreachedCount "
                + "FROM Users u JOIN Tickets t ON u.Id = t.AssignedTo LEFT JOIN SLATracking st ON t.Id = st.TicketId "
                + "WHERE t.CreatedAt >= ? AND t.CreatedAt < ?");
        if (categoryId != null && categoryId > 0) sql.append(" AND t.CategoryId = ? ");
        if (locationId != null && locationId > 0) sql.append(" AND t.LocationId = ? ");
        sql.append(" GROUP BY u.Id, u.FullName ORDER BY ResolvedCount DESC");

        try (PreparedStatement stm = connection.prepareStatement(sql.toString())) {
            int idx = 1;
            stm.setDate(idx++, from);
            stm.setDate(idx++, to);
            if (categoryId != null && categoryId > 0) stm.setInt(idx++, categoryId);
            if (locationId != null && locationId > 0) stm.setInt(idx++, locationId);
            java.sql.ResultSet rs = stm.executeQuery();
            while (rs.next()) {
                Map<String, Object> map = new HashMap<>();
                map.put("UserId", rs.getInt("UserId"));
                map.put("FullName", rs.getString("FullName"));
                map.put("TotalAssigned", rs.getInt("TotalAssigned"));
                map.put("ResolvedCount", rs.getInt("ResolvedCount"));
                map.put("AvgResolutionTime", rs.getDouble("AvgResolutionTime"));
                int breached = rs.getInt("BreachedCount");
                int total = rs.getInt("TotalAssigned");
                map.put("BreachedCount", breached);
                map.put("SLACompliance", (int) (total > 0 ? 100.0 - ((double) breached / total * 100.0) : 100.0));
                list.add(map);
            }
        } catch (Exception ex) {
            ex.printStackTrace();
        }
        return list;
    }

    public Map<String, Integer> getTicketTypeDistribution(java.sql.Date from, java.sql.Date to, Integer categoryId, Integer locationId) {
        Map<String, Integer> distribution = new HashMap<>();
        StringBuilder sql = new StringBuilder("SELECT TicketType, COUNT(*) as Count FROM Tickets WHERE CreatedAt >= ? AND CreatedAt < ?");
        if (categoryId != null && categoryId > 0) sql.append(" AND CategoryId = ? ");
        if (locationId != null && locationId > 0) sql.append(" AND LocationId = ? ");
        sql.append(" GROUP BY TicketType");

        try (PreparedStatement stm = connection.prepareStatement(sql.toString())) {
            int idx = 1;
            stm.setDate(idx++, from);
            stm.setDate(idx++, to);
            if (categoryId != null && categoryId > 0) stm.setInt(idx++, categoryId);
            if (locationId != null && locationId > 0) stm.setInt(idx++, locationId);
            java.sql.ResultSet rs = stm.executeQuery();
            while (rs.next()) {
                distribution.put(rs.getString("TicketType"), rs.getInt("Count"));
            }
        } catch (Exception ex) {
            ex.printStackTrace();
        }
        return distribution;
    }
}
