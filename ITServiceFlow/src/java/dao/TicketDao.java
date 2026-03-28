package dao;

import model.Tickets;
import Utils.DbContext;
import java.sql.*;
import java.time.LocalDate;
import java.time.YearMonth;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

public class TicketDAO extends DbContext {

    public int createTicket(Tickets t) {
        String sql = "INSERT INTO Tickets ("
                + "TicketNumber, TicketType, Title, Description, CategoryId, LocationId, "
                + "Impact, Urgency, PriorityId, ServiceCatalogId, RequiresApproval, "
                + "AssignedTo, Status, CreatedBy, CurrentLevel, CreatedAt, UpdatedAt"
                + ") VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, GETDATE(), GETDATE())";

        try (PreparedStatement ps = connection.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setString(1, t.getTicketNumber());
            ps.setString(2, t.getTicketType());
            ps.setString(3, t.getTitle());
            ps.setString(4, t.getDescription());
            ps.setInt(5, t.getCategoryId());
            ps.setInt(6, t.getLocationId());

            if (t.getImpact() != null) ps.setInt(7, t.getImpact()); else ps.setNull(7, Types.INTEGER);
            if (t.getUrgency() != null) ps.setInt(8, t.getUrgency()); else ps.setNull(8, Types.INTEGER);
            if (t.getPriorityId() != null) ps.setInt(9, t.getPriorityId()); else ps.setNull(9, Types.INTEGER);
            if (t.getServiceCatalogId() != null) ps.setInt(10, t.getServiceCatalogId()); else ps.setNull(10, Types.INTEGER);
            if (t.getRequiresApproval() != null) ps.setBoolean(11, t.getRequiresApproval()); else ps.setBoolean(11, false);

            if (t.getAssignedTo() != null && t.getAssignedTo() > 0) ps.setInt(12, t.getAssignedTo()); else ps.setNull(12, Types.INTEGER);

            ps.setString(13, t.getStatus() != null ? t.getStatus() : "New");
            ps.setInt(14, t.getCreatedBy());
            ps.setInt(15, t.getCurrentLevel());

            int rowsAffected = ps.executeUpdate();
            if (rowsAffected > 0) {
                try (ResultSet rs = ps.getGeneratedKeys()) {
                    if (rs.next()) {
                        return rs.getInt(1); 
                    }
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return -1; 
    }

    public List<Tickets> getTicketsForAgent(int currentAgentId, int currentAgentLevel) {
        List<Tickets> list = new ArrayList<>();
        String sql = "SELECT * FROM Tickets "
                + "WHERE AssignedTo = ? OR (CurrentLevel = ? AND Status = 'New' AND AssignedTo IS NULL) "
                + "ORDER BY CreatedAt DESC";

        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, currentAgentId);
            ps.setInt(2, currentAgentLevel);

            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                Tickets t = new Tickets();
                t.setId(rs.getInt("Id"));
                t.setTicketNumber(rs.getString("TicketNumber"));
                t.setTicketType(rs.getString("TicketType"));
                t.setTitle(rs.getString("Title"));
                t.setStatus(rs.getString("Status"));
                t.setCurrentLevel(rs.getInt("CurrentLevel"));

                t.setPriorityId((Integer) rs.getObject("PriorityId"));
                t.setAssignedTo((Integer) rs.getObject("AssignedTo"));

                t.setCreatedAt(rs.getDate("CreatedAt"));
                list.add(t);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

        public List<Tickets> getAllTickets() {
        List<Tickets> list = new ArrayList<>();
        String sql = "SELECT t.[Id]\n"
                + "      ,t.[TicketNumber]\n"
                + "      ,t.[TicketType]\n"
                + "      ,t.[Title]\n"
                + "      ,t.[Description]\n"
                + "      ,t.[CategoryId]\n"
                + "      ,t.[LocationId]\n"
                + "      ,t.[Impact]\n"
                + "      ,t.[Urgency]\n"
                + "      ,t.[PriorityId]\n"
                + "      ,t.[ServiceCatalogId]\n"
                + "      ,t.[RequiresApproval]\n"
                + "      ,t.[ApprovedBy]\n"
                + "      ,t.[ApprovedAt]\n"
                + "      ,t.[Status]\n"
                + "      ,t.[CreatedBy]\n"
                + "      ,t.[AssignedTo]\n"
                + "      ,t.[ParentTicketId]\n"
                + "      ,t.[ResolvedAt]\n"
                + "      ,t.[ClosedAt]\n"
                + "      ,t.[CreatedAt]\n"
                + "      ,t.[UpdatedAt]\n"
                + "      ,t.[CurrentLevel]\n"
                + "      ,p.[Level] AS PriorityLevel\n"
                + "  FROM [dbo].[Tickets] t\n"
                + "  LEFT JOIN [dbo].[Priorities] p ON t.PriorityId = p.Id";
        try {
            PreparedStatement stm = connection.prepareStatement(sql);
            ResultSet rs = stm.executeQuery();
            while (rs.next()) {
                Tickets t = new Tickets();
                t.setId(rs.getInt("Id"));
                t.setTicketNumber(rs.getString("TicketNumber"));
                t.setTicketType(rs.getString("TicketType"));
                t.setTitle(rs.getString("Title"));
                t.setDescription(rs.getString("Description"));

                t.setCategoryId(rs.getInt("CategoryId"));
                t.setLocationId(rs.getInt("LocationId"));

                t.setImpact((Integer) rs.getObject("Impact"));
                t.setUrgency((Integer) rs.getObject("Urgency"));
                t.setPriorityId((Integer) rs.getObject("PriorityId"));
                t.setServiceCatalogId((Integer) rs.getObject("ServiceCatalogId"));

                t.setRequiresApproval((Boolean) rs.getObject("RequiresApproval"));
                t.setApprovedBy((Integer) rs.getObject("ApprovedBy"));
                t.setApprovedAt(rs.getTimestamp("ApprovedAt"));

                t.setStatus(rs.getString("Status"));
                t.setCreatedBy(rs.getInt("CreatedBy"));
                t.setAssignedTo((Integer) rs.getObject("AssignedTo"));
                t.setParentTicketId((Integer) rs.getObject("ParentTicketId"));

                t.setResolvedAt(rs.getTimestamp("ResolvedAt"));
                t.setClosedAt(rs.getTimestamp("ClosedAt"));
                t.setCreatedAt(rs.getTimestamp("CreatedAt"));
                t.setUpdatedAt(rs.getTimestamp("UpdatedAt"));

                t.setCurrentLevel((Integer) rs.getObject("CurrentLevel"));

                t.setPriorityLevel(rs.getString("PriorityLevel"));

                list.add(t);
            }
        } catch (Exception ex) {
            ex.printStackTrace();
        }
        return list;
    }
    
    public List<model.Users> getActiveAgents() {
        List<model.Users> list = new ArrayList<>();
        String sql = "SELECT Id, FullName, Role FROM [dbo].[Users] "
                   + "WHERE Role IN ('IT Support', 'Manager') AND IsActive = 1 "
                   + "ORDER BY Role, FullName";
        try (PreparedStatement ps = connection.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                model.Users u = new model.Users();
                u.setId(rs.getInt("Id"));
                u.setFullName(rs.getString("FullName") + " (" + rs.getString("Role") + ")");
                list.add(u);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }
    
    

    // public static void main(String[] args) {
    //
    // TicketDao dao = new TicketDao();
    // List<Tickets> tickets = dao.getAllTickets();
    //
    // if (tickets.isEmpty()) {
    // System.out.println("❌ Không có ticket nào!");
    // return;
    // }
    //
    // System.out.println("===== DANH SÁCH TICKETS =====");
    //
    // for (Tickets t : tickets) {
    // System.out.println(
    // "ID: " + t.getId()
    // + " | TicketNumber: " + t.getTicketNumber()
    // + " | Title: " + t.getTitle()
    // + " | Status: " + t.getStatus()
    // + " | AssignedTo: " + t.getAssignedTo()
    // + " | Level: " + t.getCurrentLevel()
    // + " | CreatedAt: " + t.getCreatedAt()
    // );
    // }
    // }

   public List<Tickets> getTicketsByCreator(int userId, int offset, int limit, String search, String status, String type) {
        List<Tickets> list = new ArrayList<>();
        
        StringBuilder sql = new StringBuilder(
            "SELECT t.Id, t.TicketNumber, t.TicketType, t.Title, t.Status, t.CreatedAt, t.UpdatedAt, "
            + "p.Level AS PriorityLevel, u.FullName AS AssigneeName, c.Name AS CategoryName "
            + "FROM [dbo].[Tickets] t "
            + "LEFT JOIN [dbo].[Priorities] p ON t.PriorityId = p.Id "
            + "LEFT JOIN [dbo].[Users] u ON t.AssignedTo = u.Id "
            + "LEFT JOIN [dbo].[Categories] c ON t.CategoryId = c.Id "
            + "WHERE t.CreatedBy = ? "
        );

        if (search != null && !search.trim().isEmpty()) {
            sql.append("AND (t.TicketNumber LIKE ? OR t.Title LIKE ?) ");
        }

        if (status != null && !status.equals("all")) {
            sql.append("AND t.Status = ? ");
        }

        if (type != null && !type.equals("all")) {
            sql.append("AND t.TicketType = ? ");
        }

        sql.append("ORDER BY t.CreatedAt DESC OFFSET ? ROWS FETCH NEXT ? ROWS ONLY"); 
                   
        try (PreparedStatement ps = connection.prepareStatement(sql.toString())) {
            int paramIndex = 1;
            ps.setInt(paramIndex++, userId);
            
            if (search != null && !search.trim().isEmpty()) {
                ps.setString(paramIndex++, "%" + search + "%");
                ps.setString(paramIndex++, "%" + search + "%");
            }
            if (status != null && !status.equals("all")) {
                ps.setString(paramIndex++, status);
            }
            if (type != null && !type.equals("all")) {
                ps.setString(paramIndex++, type);
            }
            
            ps.setInt(paramIndex++, offset);
            ps.setInt(paramIndex++, limit);
            
            ResultSet rs = ps.executeQuery();

            while (rs.next()) {
                Tickets t = new Tickets();
                t.setId(rs.getInt("Id"));
                t.setTicketNumber(rs.getString("TicketNumber"));
                t.setTicketType(rs.getString("TicketType"));
                t.setTitle(rs.getString("Title"));
                t.setStatus(rs.getString("Status"));
                t.setCreatedAt(rs.getTimestamp("CreatedAt"));
                t.setUpdatedAt(rs.getTimestamp("UpdatedAt"));
                t.setPriorityLevel(rs.getString("PriorityLevel"));
                t.setAssigneeName(rs.getString("AssigneeName"));
                t.setCategoryName(rs.getString("CategoryName"));
                list.add(t);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    public Tickets getTicketByNumber(String ticketNumber) {
        String sql = "SELECT t.*, "
                + "p.Level AS PriorityLevel, u.FullName AS AssigneeName, "
                + "c.Name AS CategoryName, s.Name AS ServiceName "
                + "FROM [dbo].[Tickets] t "
                + "LEFT JOIN [dbo].[Priorities] p ON t.PriorityId = p.Id "
                + "LEFT JOIN [dbo].[Users] u ON t.AssignedTo = u.Id "
                + "LEFT JOIN [dbo].[Categories] c ON t.CategoryId = c.Id "
                + "LEFT JOIN [dbo].[ServiceCatalog] s ON t.ServiceCatalogId = s.Id "
                + "WHERE t.TicketNumber = ?";

        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setString(1, ticketNumber);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                Tickets t = new Tickets();
                t.setId(rs.getInt("Id"));
                t.setTicketNumber(rs.getString("TicketNumber"));
                t.setTicketType(rs.getString("TicketType"));
                t.setTitle(rs.getString("Title"));
                t.setDescription(rs.getString("Description"));
                t.setCategoryId(rs.getInt("CategoryId"));
                t.setLocationId(rs.getInt("LocationId"));
                t.setImpact((Integer) rs.getObject("Impact"));
                t.setUrgency((Integer) rs.getObject("Urgency"));
                t.setPriorityId((Integer) rs.getObject("PriorityId"));
                t.setServiceCatalogId((Integer) rs.getObject("ServiceCatalogId"));
                t.setRequiresApproval((Boolean) rs.getObject("RequiresApproval"));
                t.setApprovedBy((Integer) rs.getObject("ApprovedBy"));
                t.setApprovedAt(rs.getTimestamp("ApprovedAt"));
                t.setStatus(rs.getString("Status"));
                t.setCreatedBy(rs.getInt("CreatedBy"));
                t.setAssignedTo((Integer) rs.getObject("AssignedTo"));
                t.setParentTicketId((Integer) rs.getObject("ParentTicketId"));
                t.setResolvedAt(rs.getTimestamp("ResolvedAt"));
                t.setClosedAt(rs.getTimestamp("ClosedAt"));
                t.setCreatedAt(rs.getTimestamp("CreatedAt"));
                t.setUpdatedAt(rs.getTimestamp("UpdatedAt"));
                t.setCurrentLevel((Integer) rs.getObject("CurrentLevel"));
                t.setPriorityLevel(rs.getString("PriorityLevel"));
                t.setAssigneeName(rs.getString("AssigneeName"));
                t.setCategoryName(rs.getString("CategoryName"));
                t.setServiceName(rs.getString("ServiceName"));
                return t;
            }
        } catch (Exception ex) {
            ex.printStackTrace();
        }
        return null;
    }

    public Tickets getTicketById(int id) {
        String sql = "SELECT t.*, "
                + "p.Level AS PriorityLevel, u.FullName AS AssigneeName, "
                + "c.Name AS CategoryName, s.Name AS ServiceName "
                + "FROM [dbo].[Tickets] t "
                + "LEFT JOIN [dbo].[Priorities] p ON t.PriorityId = p.Id "
                + "LEFT JOIN [dbo].[Users] u ON t.AssignedTo = u.Id "
                + "LEFT JOIN [dbo].[Categories] c ON t.CategoryId = c.Id "
                + "LEFT JOIN [dbo].[ServiceCatalog] s ON t.ServiceCatalogId = s.Id "
                + "WHERE t.Id = ?";

        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, id);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                Tickets t = new Tickets();
                t.setId(rs.getInt("Id"));
                t.setTicketNumber(rs.getString("TicketNumber"));
                t.setTicketType(rs.getString("TicketType"));
                t.setTitle(rs.getString("Title"));
                t.setDescription(rs.getString("Description"));
                t.setCategoryId(rs.getInt("CategoryId"));
                t.setLocationId(rs.getInt("LocationId"));
                t.setImpact((Integer) rs.getObject("Impact"));
                t.setUrgency((Integer) rs.getObject("Urgency"));
                t.setPriorityId((Integer) rs.getObject("PriorityId"));
                t.setServiceCatalogId((Integer) rs.getObject("ServiceCatalogId"));
                t.setStatus(rs.getString("Status"));
                t.setCreatedBy(rs.getInt("CreatedBy"));
                t.setCreatedAt(rs.getTimestamp("CreatedAt"));
                t.setUpdatedAt(rs.getTimestamp("UpdatedAt"));
                
                t.setAssignedTo((Integer) rs.getObject("AssignedTo"));
                t.setCurrentLevel((Integer) rs.getObject("CurrentLevel"));
                t.setRequiresApproval((Boolean) rs.getObject("RequiresApproval"));
                t.setApprovedBy((Integer) rs.getObject("ApprovedBy"));
                t.setParentTicketId((Integer) rs.getObject("ParentTicketId"));

                t.setPriorityLevel(rs.getString("PriorityLevel"));
                t.setAssigneeName(rs.getString("AssigneeName"));
                t.setCategoryName(rs.getString("CategoryName"));
                t.setServiceName(rs.getString("ServiceName"));

                return t;
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    public Tickets searchTicketById(int ticketId) {
        String sql = "SELECT t.*, "
                + "p.Level AS PriorityLevel, u.FullName AS AssigneeName, "
                + "c.Name AS CategoryName, s.Name AS ServiceName "
                + "FROM [dbo].[Tickets] t "
                + "LEFT JOIN [dbo].[Priorities] p ON t.PriorityId = p.Id "
                + "LEFT JOIN [dbo].[Users] u ON t.AssignedTo = u.Id "
                + "LEFT JOIN [dbo].[Categories] c ON t.CategoryId = c.Id "
                + "LEFT JOIN [dbo].[ServiceCatalog] s ON t.ServiceCatalogId = s.Id "
                + "WHERE t.Id = ?";

        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, ticketId);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                Tickets t = new Tickets();
                t.setId(rs.getInt("Id"));
                t.setTicketNumber(rs.getString("TicketNumber"));
                t.setTicketType(rs.getString("TicketType"));
                t.setTitle(rs.getString("Title"));
                t.setDescription(rs.getString("Description"));
                t.setCategoryId(rs.getInt("CategoryId"));
                t.setLocationId(rs.getInt("LocationId"));
                t.setImpact((Integer) rs.getObject("Impact"));
                t.setUrgency((Integer) rs.getObject("Urgency"));
                t.setPriorityId((Integer) rs.getObject("PriorityId"));
                t.setServiceCatalogId((Integer) rs.getObject("ServiceCatalogId"));
                t.setStatus(rs.getString("Status"));
                t.setCreatedBy(rs.getInt("CreatedBy"));
                t.setAssignedTo((Integer) rs.getObject("AssignedTo"));
                t.setCreatedAt(rs.getTimestamp("CreatedAt"));
                t.setUpdatedAt(rs.getTimestamp("UpdatedAt"));
                t.setCurrentLevel((Integer) rs.getObject("CurrentLevel"));

                t.setPriorityLevel(rs.getString("PriorityLevel"));
                t.setAssigneeName(rs.getString("AssigneeName"));
                t.setCategoryName(rs.getString("CategoryName"));
                t.setServiceName(rs.getString("ServiceName"));

                return t;
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    public List<Tickets> getResolvedTickets(String keyword, int assignedToId) {
        List<Tickets> list = new ArrayList<>();
        String baseSql = "SELECT t.Id, t.TicketNumber, t.TicketType, t.Title, t.Status, t.ResolvedAt "
                + "FROM [dbo].[Tickets] t WHERE t.Status = 'Resolved' AND t.AssignedTo = ?";
        boolean hasKeyword = keyword != null && !keyword.trim().isEmpty();
        String sql = hasKeyword ? baseSql + " AND t.TicketNumber LIKE ?" : baseSql;
        sql += " ORDER BY t.ResolvedAt DESC";

        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, assignedToId);
            if (hasKeyword) {
                ps.setString(2, "%" + keyword.trim() + "%");
            }
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                Tickets t = new Tickets();
                t.setId(rs.getInt("Id"));
                t.setTicketNumber(rs.getString("TicketNumber"));
                t.setTicketType(rs.getString("TicketType"));
                t.setTitle(rs.getString("Title"));
                t.setStatus(rs.getString("Status"));
                t.setResolvedAt(rs.getTimestamp("ResolvedAt"));
                list.add(t);
            }
        } catch (Exception ex) {
            ex.printStackTrace();
        }
        return list;
    }

    // Create Ticket and return its Id for SLA tracking
    public int createTicket2(Tickets ticket) {
        String sql = "INSERT INTO [dbo].[Tickets] (TicketNumber, TicketType, Title, Description, CategoryId, LocationId, Impact, Urgency, PriorityId, ServiceCatalogId, RequiresApproval, Status, CreatedBy, CreatedAt) "
                + "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, GETDATE())";
        try {
            PreparedStatement stm = connection.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS);
            stm.setString(1, ticket.getTicketNumber());
            stm.setString(2, ticket.getTicketType());
            stm.setString(3, ticket.getTitle());
            stm.setString(4, ticket.getDescription());
            stm.setInt(5, ticket.getCategoryId());
            stm.setInt(6, ticket.getLocationId());

            if (ticket.getImpact() != null && ticket.getImpact() > 0)
                stm.setInt(7, ticket.getImpact());
            else
                stm.setNull(7, java.sql.Types.INTEGER);
            if (ticket.getUrgency() != null && ticket.getUrgency() > 0)
                stm.setInt(8, ticket.getUrgency());
            else
                stm.setNull(8, java.sql.Types.INTEGER);
            if (ticket.getPriorityId() != null && ticket.getPriorityId() > 0)
                stm.setInt(9, ticket.getPriorityId());
            else
                stm.setNull(9, java.sql.Types.INTEGER);
            if (ticket.getServiceCatalogId() != null && ticket.getServiceCatalogId() > 0)
                stm.setInt(10, ticket.getServiceCatalogId());
            else
                stm.setNull(10, java.sql.Types.INTEGER);

            if (ticket.getRequiresApproval() != null)
                stm.setBoolean(11, ticket.getRequiresApproval());
            else
                stm.setNull(11, java.sql.Types.BIT);
            stm.setString(12, ticket.getStatus());
            stm.setInt(13, ticket.getCreatedBy());

            int affectedRows = stm.executeUpdate();
            if (affectedRows > 0) {
                try (ResultSet generatedKeys = stm.getGeneratedKeys()) {
                    if (generatedKeys.next()) {
                        return generatedKeys.getInt(1);
                    }
                }
            }
        } catch (Exception ex) {
            ex.printStackTrace();
        }
        return -1;
    }
    
    public java.util.Map<String, Integer> getUserTicketKPIs(int userId) {
        java.util.Map<String, Integer> kpis = new java.util.HashMap<>();
        kpis.put("open", 0);
        kpis.put("inProgress", 0);
        kpis.put("awaiting", 0);
        kpis.put("resolved7d", 0);

        String sql = "SELECT "
                   + "SUM(CASE WHEN Status = 'New' THEN 1 ELSE 0 END) AS OpenCount, "
                   + "SUM(CASE WHEN Status = 'In Progress' THEN 1 ELSE 0 END) AS InProgressCount, "
                   + "SUM(CASE WHEN RequiresApproval = 1 AND ApprovedBy IS NULL AND Status NOT IN ('Closed', 'Resolved') THEN 1 ELSE 0 END) AS AwaitingCount, "
                   + "SUM(CASE WHEN Status = 'Resolved' AND CreatedAt >= DATEADD(day, -7, GETDATE()) THEN 1 ELSE 0 END) AS Resolved7dCount "
                   + "FROM [dbo].[Tickets] WHERE CreatedBy = ?";

        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, userId);
            ResultSet rs = ps.executeQuery();
            
            if (rs.next()) {
                kpis.put("open", rs.getInt("OpenCount"));
                kpis.put("inProgress", rs.getInt("InProgressCount"));
                kpis.put("awaiting", rs.getInt("AwaitingCount"));
                kpis.put("resolved7d", rs.getInt("Resolved7dCount"));
            }
        } catch (Exception e) {
            System.err.println("Lỗi khi tính KPI: " + e.getMessage());
            e.printStackTrace();
        }
        return kpis;
    }
    
public int getTotalTicketsCount(int userId, String search, String status, String type) {
        StringBuilder sql = new StringBuilder(
            "SELECT COUNT(*) FROM [dbo].[Tickets] WHERE CreatedBy = ? "
        );
        
        if (search != null && !search.trim().isEmpty()) {
            sql.append("AND (TicketNumber LIKE ? OR Title LIKE ?) ");
        }
        if (status != null && !status.equals("all")) {
            sql.append("AND Status = ? ");
        }
        if (type != null && !type.equals("all")) {
            sql.append("AND TicketType = ? ");
        }

        try (PreparedStatement ps = connection.prepareStatement(sql.toString())) {
            int paramIndex = 1;
            ps.setInt(paramIndex++, userId);
            
            if (search != null && !search.trim().isEmpty()) {
                ps.setString(paramIndex++, "%" + search + "%");
                ps.setString(paramIndex++, "%" + search + "%");
            }
            if (status != null && !status.equals("all")) {
                ps.setString(paramIndex++, status);
            }
            if (type != null && !type.equals("all")) {
                ps.setString(paramIndex++, type);
            }
            
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                return rs.getInt(1);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return 0;
    }

    public String getNextTicketNumber(String type) {
        String prefix = type.equals("Incident") ? "INC-" : "SR-";
        return prefix + System.currentTimeMillis();
    }

    public List<Tickets> getIncidentsNotInProblem() {
        List<Tickets> list = new ArrayList<>();

        String sql = "SELECT t.Id, t.TicketNumber, t.Title, t.Status " +
                "FROM Tickets t " +
                "WHERE t.TicketType = 'INCIDENT' " +
                "AND NOT EXISTS ( " +
                "    SELECT 1 FROM ProblemTickets pt " +
                "    WHERE pt.TicketId = t.Id" +
                ")";

        try {
            PreparedStatement stm = connection.prepareStatement(sql);
            ResultSet rs = stm.executeQuery();

            while (rs.next()) {
                Tickets t = new Tickets();
                t.setId(rs.getInt("Id"));
                t.setTicketNumber(rs.getString("TicketNumber"));
                t.setTitle(rs.getString("Title"));
                t.setStatus(rs.getString("Status"));

                list.add(t);
            }

        } catch (Exception ex) {
            ex.printStackTrace();
        }

        return list;
    }
    
    public List<Tickets> searchIncidentsNotInProblem(String search)
    {
        List<Tickets> list = new ArrayList<>();
        String  sql = "SELECT t.Id, t.TicketNumber, t.Title, t.Status " +
                     "FROM Tickets t " +
                     "WHERE t.TicketType = 'INCIDENT' " +
                     "AND NOT EXISTS ( " +
                     "    SELECT 1 FROM ProblemTickets pt " +
                     "    WHERE pt.TicketId = t.Id" +
                     ")" +
                     " AND (t.TicketNumber LIKE ? OR t.Title LIKE ?)";
        
        try
        {
            PreparedStatement stm = connection.prepareStatement(sql);
            String searchValue = "%" + search + "%";
            stm.setString(1, searchValue);
            stm.setString(2, searchValue);
            ResultSet rs = stm.executeQuery();
            while(rs.next())
            {
                Tickets t = new Tickets();
                t.setId(rs.getInt("Id"));
                t.setTicketNumber(rs.getString("TicketNumber"));
                t.setTitle(rs.getString("Title"));
                t.setStatus(rs.getString("Status"));
                list.add(t);
            }
            return list;
        }
        catch(Exception ex)
        {
            ex.printStackTrace();
            return null;
        }
        
    }
    
  
    public List<Tickets> getAgentQueues(int agentId, int currentLevel, String queueType, int offset, int limit, String search, String status, String type, String priority) {
        List<Tickets> list = new ArrayList<>();

        StringBuilder sql = new StringBuilder(
                "SELECT t.*, p.Level AS PriorityLevel, u.FullName AS AssigneeName, c.Name AS CategoryName, st.ResolutionDeadline "
                + "FROM [dbo].[Tickets] t "
                + "LEFT JOIN [dbo].[Priorities] p ON t.PriorityId = p.Id "
                + "LEFT JOIN [dbo].[Users] u ON t.AssignedTo = u.Id "
                + "LEFT JOIN [dbo].[Categories] c ON t.CategoryId = c.Id "
                + "LEFT JOIN [dbo].[SLATracking] st ON t.Id = st.TicketId WHERE 1=1 "
        );

        if ("unassigned".equals(queueType)) {
            sql.append("AND t.AssignedTo IS NULL AND t.Status NOT IN ('Closed', 'Resolved') ");
        } else if ("mine".equals(queueType)) {
            sql.append("AND t.AssignedTo = ? AND t.Status NOT IN ('Closed', 'Resolved') ");
        } else if ("resolved".equals(queueType)) {
            sql.append("AND t.Status = 'Resolved' ");
        } else { 
            sql.append("AND t.Status NOT IN ('Closed', 'Resolved') ");
        }

        if (search != null && !search.trim().isEmpty()) {
            sql.append("AND (t.TicketNumber LIKE ? OR t.Title LIKE ?) ");
        }
        if (status != null && !status.equals("all")) {
            sql.append("AND t.Status = ? ");
        }
        if (type != null && !type.equals("all")) {
            sql.append("AND t.TicketType = ? ");
        }
        if (priority != null && !priority.equals("all")) {
            sql.append("AND p.Level = ? ");
        }

        sql.append("ORDER BY t.CreatedAt DESC OFFSET ? ROWS FETCH NEXT ? ROWS ONLY");

        try (PreparedStatement ps = connection.prepareStatement(sql.toString())) {
            int paramIdx = 1;
            
            if ("mine".equals(queueType)) {
                ps.setInt(paramIdx++, agentId);
            }

            if (search != null && !search.trim().isEmpty()) {
                ps.setString(paramIdx++, "%" + search + "%");
                ps.setString(paramIdx++, "%" + search + "%");
            }
            if (status != null && !status.equals("all")) {
                ps.setString(paramIdx++, status);
            }
            if (type != null && !type.equals("all")) {
                ps.setString(paramIdx++, type);
            }
            if (priority != null && !priority.equals("all")) {
                ps.setString(paramIdx++, priority);
            }

            ps.setInt(paramIdx++, offset);
            ps.setInt(paramIdx++, limit);

            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                Tickets t = new Tickets();
                t.setId(rs.getInt("Id"));
                t.setTicketNumber(rs.getString("TicketNumber"));
                t.setTicketType(rs.getString("TicketType"));
                t.setTitle(rs.getString("Title"));
                t.setStatus(rs.getString("Status"));
                t.setCreatedAt(rs.getTimestamp("CreatedAt"));
                t.setPriorityLevel(rs.getString("PriorityLevel"));
                t.setAssigneeName(rs.getString("AssigneeName"));

                try {
                    t.setResolutionDeadline(rs.getTimestamp("ResolutionDeadline"));
                } catch (Exception e) {
                }
                
                list.add(t);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    public int getTotalAgentQueuesCount(int agentId, int currentLevel, String queueType, String search, String status, String type, String priority) {
        StringBuilder sql = new StringBuilder("SELECT COUNT(*) FROM [dbo].[Tickets] t LEFT JOIN [dbo].[Priorities] p ON t.PriorityId = p.Id WHERE 1=1 ");

        if ("unassigned".equals(queueType)) {
            sql.append("AND t.AssignedTo IS NULL AND t.Status NOT IN ('Closed', 'Resolved') ");
        } else if ("mine".equals(queueType)) {
            sql.append("AND t.AssignedTo = ? AND t.Status NOT IN ('Closed', 'Resolved') ");
        } else if ("resolved".equals(queueType)) {
            sql.append("AND t.Status = 'Resolved' ");
        } else {
            sql.append("AND t.Status NOT IN ('Closed', 'Resolved') ");
        }

        if (search != null && !search.trim().isEmpty()) sql.append("AND (t.TicketNumber LIKE ? OR t.Title LIKE ?) ");
        if (status != null && !status.equals("all")) sql.append("AND t.Status = ? ");
        if (type != null && !type.equals("all")) sql.append("AND t.TicketType = ? ");
        if (priority != null && !priority.equals("all")) sql.append("AND p.Level = ? ");

        try (PreparedStatement ps = connection.prepareStatement(sql.toString())) {
            int paramIdx = 1;
            if ("mine".equals(queueType)) ps.setInt(paramIdx++, agentId);
            if (search != null && !search.trim().isEmpty()) {
                ps.setString(paramIdx++, "%" + search + "%");
                ps.setString(paramIdx++, "%" + search + "%");
            }
            if (status != null && !status.equals("all")) ps.setString(paramIdx++, status);
            if (type != null && !type.equals("all")) ps.setString(paramIdx++, type);
            if (priority != null && !priority.equals("all")) ps.setString(paramIdx++, priority);
            
            ResultSet rs = ps.executeQuery();
            if (rs.next()) return rs.getInt(1);
        } catch (Exception e) { e.printStackTrace(); }
        return 0;
    }


    public boolean assignTicket(int ticketId, int agentId) {
        String sql = "UPDATE [dbo].[Tickets] SET AssignedTo = ?, UpdatedAt = GETDATE() WHERE Id = ?";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, agentId);
            ps.setInt(2, ticketId);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    public boolean updateTicketStatus(int ticketId, String status) {
        String sql = "UPDATE [dbo].[Tickets] SET Status = ?, UpdatedAt = GETDATE() ";
        if ("Resolved".equals(status)) sql += ", ResolvedAt = GETDATE() ";
        else if ("Closed".equals(status)) sql += ", ClosedAt = GETDATE() ";
        sql += "WHERE Id = ?";
        
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setString(1, status);
            ps.setInt(2, ticketId);
            int rows = ps.executeUpdate();
            
            if (rows > 0 && ("Resolved".equals(status) || "Closed".equals(status))) {

                String cascadeSql = "UPDATE [dbo].[Tickets] SET Status = ?, UpdatedAt = GETDATE() ";
                if ("Resolved".equals(status)) cascadeSql += ", ResolvedAt = GETDATE() ";
                if ("Closed".equals(status)) cascadeSql += ", ClosedAt = GETDATE() ";
                cascadeSql += "WHERE ParentTicketId = ? AND Status NOT IN ('Resolved', 'Closed')";
                
                try (PreparedStatement psCascade = connection.prepareStatement(cascadeSql)) {
                    psCascade.setString(1, status);
                    psCascade.setInt(2, ticketId);
                    psCascade.executeUpdate(); 
                }
            }
            return true;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }
    
    /**
     * KPI dashboard cho IT Support agent cụ thể.
     * Trả về Map với các key:
     *   - myNew        : ticket mới chưa assign hoặc assign cho agent này
     *   - myInProgress : ticket đang xử lý (AssignedTo = agentId, Status = In Progress)
     *   - myResolved   : ticket đã resolved trong 7 ngày gần nhất
     *   - myTotal      : tổng ticket assign cho agent
     *   - slaBreaching : ticket sắp breach SLA (ResolutionDeadline trong vòng 2 giờ tới)
     */
    public java.util.Map<String, Integer> getAgentKPIs(int agentId) {
        java.util.Map<String, Integer> kpis = new java.util.HashMap<>();
        kpis.put("myNew", 0);
        kpis.put("myInProgress", 0);
        kpis.put("myResolved", 0);
        kpis.put("myTotal", 0);
        kpis.put("slaBreaching", 0);

        String sql = "SELECT "
                   + "  SUM(CASE WHEN t.Status = 'New' AND (t.AssignedTo = ? OR t.AssignedTo IS NULL) THEN 1 ELSE 0 END) AS MyNew, "
                   + "  SUM(CASE WHEN t.Status = 'In Progress' AND t.AssignedTo = ? THEN 1 ELSE 0 END) AS MyInProgress, "
                   + "  SUM(CASE WHEN t.Status = 'Resolved' AND t.AssignedTo = ? "
                   + "       AND t.ResolvedAt >= DATEADD(day, -7, GETDATE()) THEN 1 ELSE 0 END) AS MyResolved, "
                   + "  SUM(CASE WHEN t.AssignedTo = ? AND t.Status NOT IN ('Closed','Resolved') THEN 1 ELSE 0 END) AS MyTotal "
                   + "FROM Tickets t";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, agentId);
            ps.setInt(2, agentId);
            ps.setInt(3, agentId);
            ps.setInt(4, agentId);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                kpis.put("myNew",        rs.getInt("MyNew"));
                kpis.put("myInProgress", rs.getInt("MyInProgress"));
                kpis.put("myResolved",   rs.getInt("MyResolved"));
                kpis.put("myTotal",      rs.getInt("MyTotal"));
            }
        } catch (Exception e) { e.printStackTrace(); }

        String slaSql = "SELECT COUNT(*) FROM SLATracking st "
                      + "JOIN Tickets t ON st.TicketId = t.Id "
                      + "WHERE t.AssignedTo = ? "
                      + "  AND t.Status NOT IN ('Closed','Resolved') "
                      + "  AND st.IsBreached = 0 "
                      + "  AND st.ResolutionDeadline <= DATEADD(hour, 2, GETDATE())";
        try (PreparedStatement ps = connection.prepareStatement(slaSql)) {
            ps.setInt(1, agentId);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) kpis.put("slaBreaching", rs.getInt(1));
        } catch (Exception e) { e.printStackTrace(); }

        return kpis;
    }

    public int getTotalTicketThisMonth()
    {
        String sql = "SELECT COUNT(*)"
                + " FROM [dbo].[Tickets]"
                + "WHERE YEAR(CreatedAt) = YEAR(GETDATE()) AND MONTH(CreatedAt) = MONTH(GETDATE())";
        try (PreparedStatement ps = connection.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            if (rs.next()) return rs.getInt(1);
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return 0;
    }
    
    public int getTotalTicket()
    {
        String sql = "SELECT COUNT(*) "
                + "FROM [dbo].[Tickets]";
        try (PreparedStatement ps = connection.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            if (rs.next()) return rs.getInt(1);
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return 0;
    }
    
/**
 * 
 */
    public Map<String, Object> getTicketStatsLast6Months() {
        List<String> labels = new ArrayList<>();
        int[] daXuLy = new int[6];
        int[] chuaXuLy = new int[6];

        YearMonth thangHienTai = YearMonth.from(LocalDate.now());

        for (int i = 0; i < 6; i++) {
            YearMonth thang = thangHienTai.minusMonths(5 - i);

            labels.add(thang.getMonthValue() + "/" + thang.getYear());

            if (connection == null) {
                continue;
            }

            Date tuNgay  = Date.valueOf(thang.atDay(1));
            Date denNgay = Date.valueOf(thang.plusMonths(1).atDay(1));

            daXuLy[i]   = getAllTicketSolvedFromTo(tuNgay, denNgay);
            chuaXuLy[i] = getAllTicketUnSolvedFromTo(tuNgay, denNgay);
        }

        Map<String, Object> ketQua = new LinkedHashMap<>();
        ketQua.put("labels", labels);
        ketQua.put("daXuLy", daXuLy);
        ketQua.put("chuaXuLy", chuaXuLy);
        return ketQua;
    }

    public List<Tickets> getLinkedChildTickets(int parentId) {
        List<Tickets> list = new ArrayList<>();
        String sql = "SELECT t.*, u.FullName AS AssigneeName " +
                     "FROM [dbo].[Tickets] t " +
                     "LEFT JOIN [dbo].[Users] u ON t.AssignedTo = u.Id " +
                     "WHERE t.ParentTicketId = ? ORDER BY t.CreatedAt DESC";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, parentId);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                Tickets t = new Tickets();
                t.setId(rs.getInt("Id"));
                t.setTicketNumber(rs.getString("TicketNumber"));
                t.setTitle(rs.getString("Title"));
                t.setStatus(rs.getString("Status"));
                t.setAssigneeName(rs.getString("AssigneeName"));
                t.setCreatedAt(rs.getTimestamp("CreatedAt"));
                list.add(t);
            }
        } catch (Exception e) { e.printStackTrace(); }
        return list;
    }

    public Tickets getParentTicket(int parentTicketId) {
        if (parentTicketId <= 0) return null;
        String sql = "SELECT * FROM [dbo].[Tickets] WHERE Id = ?";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, parentTicketId);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                Tickets t = new Tickets();
                t.setId(rs.getInt("Id"));
                t.setTicketNumber(rs.getString("TicketNumber"));
                t.setTitle(rs.getString("Title"));
                t.setStatus(rs.getString("Status"));
                return t;
            }
        } catch (Exception e) { e.printStackTrace(); }
        return null;
    }


    public List<Tickets> getAvailableTicketsForLinking(int currentTicketId) {
        List<Tickets> list = new ArrayList<>();
        String sql = "SELECT Id, TicketNumber, Title, Status FROM [dbo].[Tickets] " +
                     "WHERE Id != ? AND Status NOT IN ('Resolved', 'Closed') " +
                     "AND ParentTicketId IS NULL AND TicketType = 'Incident'";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, currentTicketId);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                Tickets t = new Tickets();
                t.setId(rs.getInt("Id"));
                t.setTicketNumber(rs.getString("TicketNumber"));
                t.setTitle(rs.getString("Title"));
                t.setStatus(rs.getString("Status"));
                list.add(t);
            }
        } catch (Exception e) { e.printStackTrace(); }
        return list;
    }

   
    public boolean linkChildTickets(int parentId, String[] childIds) {
        if (childIds == null || childIds.length == 0) return false;

        Tickets parent = getTicketById(parentId);
        Integer parentAssigneeId = null;
        if (parent != null && parent.getAssignedTo() != null && parent.getAssignedTo() > 0) {
            parentAssigneeId = parent.getAssignedTo();
        }

        StringBuilder placeholders = new StringBuilder();
        for (int i = 0; i < childIds.length; i++) {
            placeholders.append("?");
            if (i < childIds.length - 1) placeholders.append(",");
        }
        
        String sql = "UPDATE [dbo].[Tickets] SET ParentTicketId = ?, UpdatedAt = GETDATE() ";
        
        if (parentAssigneeId != null) {
            sql += ", AssignedTo = COALESCE(AssignedTo, ?) ";
        }
        
        sql += "WHERE Id IN (" + placeholders.toString() + ")";
        
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            int paramIndex = 1;
            ps.setInt(paramIndex++, parentId); // Set ParentId
            
            if (parentAssigneeId != null) {
                ps.setInt(paramIndex++, parentAssigneeId);
            }
            
            for (int i = 0; i < childIds.length; i++) {
                ps.setInt(paramIndex++, Integer.parseInt(childIds[i]));
            }
            
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    private int getAllTicketSolvedFromTo(Date from, Date to) {
        String sql = "SELECT COUNT(*) FROM Tickets " +
                "WHERE Status IN ('Resolved','Closed','Approved') " +
                "AND COALESCE(ResolvedAt, UpdatedAt) >= ? AND COALESCE(ResolvedAt, UpdatedAt) < ?";

        try (PreparedStatement ps = connection.prepareStatement(sql)) {

            ps.setDate(1, from); 
            ps.setDate(2, to);   

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1);
                }
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }

        return 0;
    }

    /** Chưa xử lý: vẫn mở và được tạo trong khoảng [tuNgay, denNgay) */
    private int getAllTicketUnSolvedFromTo(Date from, Date to) {
        String sql = "SELECT COUNT(*) FROM Tickets " +
                "WHERE Status IN ('New','Open','In Progress') " +
                "AND CreatedAt >= ? AND CreatedAt < ?";

        try (PreparedStatement ps = connection.prepareStatement(sql)) {

            ps.setDate(1, from); 
            ps.setDate(2, to);  

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1);
                }
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }

        return 0;
    }
    
    public List<Tickets> get10UnassignedTickets() {
        List<Tickets> list = new ArrayList<>();

        String sql = "SELECT TOP 10 Id, TicketNumber, Title, Status, CreatedAt " +
                     "FROM [dbo].[Tickets] " +
                     "WHERE AssignedTo IS NULL " +
                     "AND Status NOT IN ('Closed','Resolved') " +
                     "ORDER BY CreatedAt DESC";

        try (PreparedStatement ps = connection.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                Tickets t = new Tickets();
                t.setId(rs.getInt("Id"));
                t.setTicketNumber(rs.getString("TicketNumber"));
                t.setTitle(rs.getString("Title"));
                t.setStatus(rs.getString("Status"));
                t.setCreatedAt(rs.getTimestamp("CreatedAt"));

                list.add(t);
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return list;
    }
    

    public void applyRouting(Tickets t) {

        t.setAssignedTo(null); 
        
        t.setCurrentLevel(1); 

    if (t.getRequiresApproval() != null && t.getRequiresApproval()) {
        t.setCurrentLevel(2); 
        t.setStatus("Awaiting Approval"); 
        t.setAssignedTo(null);
        return;
    }

        if ("Incident".equals(t.getTicketType()) && t.getPriorityId() != null && t.getPriorityId() == 1) {
            t.setCurrentLevel(2);
            return;
        }
    }
    

    public boolean processApproval(int ticketId, int managerId, boolean isApproved) {
        String sql;
        if (isApproved) {
            sql = "UPDATE [dbo].[Tickets] SET "
                + "ApprovedBy = ?, ApprovedAt = GETDATE(), "
                + "Status = 'New', CurrentLevel = 1, UpdatedAt = GETDATE() "
                + "WHERE Id = ?";
        } else {
            sql = "UPDATE [dbo].[Tickets] SET "
                + "ApprovedBy = NULL, ApprovedAt = GETDATE(), "
                + "Status = 'Closed', UpdatedAt = GETDATE() "
                + "WHERE Id = ?";
        }

        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            if (isApproved) {
                ps.setInt(1, managerId);
                ps.setInt(2, ticketId);
            } else {
                ps.setInt(1, ticketId);
            }
            int rows = ps.executeUpdate();
            
            // Trigger SLA Activation
            if (rows > 0 && isApproved) {
                Tickets t = getTicketById(ticketId); 
                if (t != null) {
                    SLATrackingDao slaDao = new SLATrackingDao();
                    
                    if ("ServiceRequest".equals(t.getTicketType()) && t.getServiceCatalogId() != null && t.getServiceCatalogId() > 0) {
                        
                        int estimatedHours = 24; 
                        String sqlCat = "SELECT EstimatedDeliveryDays FROM [dbo].[ServiceCatalog] WHERE Id = ?";
                        try (PreparedStatement psCat = connection.prepareStatement(sqlCat)) {
                            psCat.setInt(1, t.getServiceCatalogId());
                            ResultSet rsCat = psCat.executeQuery();
                            if (rsCat.next() && rsCat.getObject("EstimatedDeliveryDays") != null) {
                                estimatedHours = rsCat.getInt("EstimatedDeliveryDays");
                            }
                        } catch (Exception e) { e.printStackTrace(); }

                        int mappedPriorityId = 3;
                        if (estimatedHours <= 8) mappedPriorityId = 1;       // Critical 
                        else if (estimatedHours <= 16) mappedPriorityId = 2; // High 
                        else if (estimatedHours <= 24) mappedPriorityId = 3; // Medium
                        else mappedPriorityId = 4;                           // Low 

                        try (PreparedStatement psPrio = connection.prepareStatement("UPDATE [dbo].[Tickets] SET PriorityId = ? WHERE Id = ?")) {
                            psPrio.setInt(1, mappedPriorityId);
                            psPrio.setInt(2, ticketId);
                            psPrio.executeUpdate();
                        } catch (Exception e) { e.printStackTrace(); }


                        slaDao.applySLAForTicket(ticketId, t.getTicketType(), mappedPriorityId);
                        
                    } 
                    else if ("Incident".equals(t.getTicketType()) && t.getPriorityId() != null && t.getPriorityId() > 0) {
                        slaDao.applySLAForTicket(ticketId, t.getTicketType(), t.getPriorityId());
                    }
                }
            }
            return rows > 0;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    public boolean updateTicketTriage(int ticketId, int categoryId, Integer impact, Integer urgency, Integer priorityId) {
        String sql = "UPDATE [dbo].[Tickets] SET CategoryId = ?, Impact = ?, Urgency = ?, PriorityId = ?, UpdatedAt = GETDATE() WHERE Id = ?";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, categoryId);
            
            if (impact != null) ps.setInt(2, impact); else ps.setNull(2, Types.INTEGER);
            if (urgency != null) ps.setInt(3, urgency); else ps.setNull(3, Types.INTEGER);
            if (priorityId != null) ps.setInt(4, priorityId); else ps.setNull(4, Types.INTEGER);
            
            ps.setInt(5, ticketId);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

public List<Tickets> getResolvedTickets(String keyword, String type) {
        List<Tickets> list = new ArrayList<>();
        StringBuilder sql = new StringBuilder(
                "SELECT t.Id, t.TicketNumber, t.TicketType, t.Title, t.Status, t.ResolvedAt, c.Name as CategoryName "
                        + "FROM [dbo].[Tickets] t "
                        + "LEFT JOIN [dbo].[Categories] c ON t.CategoryId = c.Id "
                        + "WHERE t.Status = 'Resolved' ");

        boolean hasKeyword = keyword != null && !keyword.trim().isEmpty();
        boolean hasType = type != null && !type.trim().isEmpty() && !type.equalsIgnoreCase("All");

        if (hasKeyword) {
            sql.append("AND (t.TicketNumber LIKE ? OR t.Title LIKE ?) ");
        }
        if (hasType) {
            sql.append("AND t.TicketType = ? ");
        }
        sql.append("ORDER BY t.ResolvedAt DESC");

        try (PreparedStatement ps = connection.prepareStatement(sql.toString())) {
            int paramIdx = 1;
            if (hasKeyword) {
                String pattern = "%" + keyword.trim() + "%";
                ps.setString(paramIdx++, pattern);
                ps.setString(paramIdx++, pattern);
            }
            if (hasType) {
                ps.setString(paramIdx++, type);
            }
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                Tickets t = new Tickets();
                t.setId(rs.getInt("Id"));
                t.setTicketNumber(rs.getString("TicketNumber"));
                t.setTicketType(rs.getString("TicketType"));
                t.setTitle(rs.getString("Title"));
                t.setStatus(rs.getString("Status"));
                t.setResolvedAt(rs.getTimestamp("ResolvedAt"));
                t.setCategoryName(rs.getString("CategoryName"));
                list.add(t);
            }
        } catch (Exception ex) {
            ex.printStackTrace();
        }
        return list;
    }

public boolean reopenTicketForUser(int ticketId, int userId) {
        String sql = "UPDATE [dbo].[Tickets] "
                + "SET Status = 'Reopened', "
                + "    UpdatedAt = GETDATE(), "
                + "    ResolvedAt = NULL, "
                + "    ClosedAt = NULL "
                + "WHERE Id = ? "
                + "  AND CreatedBy = ? "
                + "  AND Status IN ('Resolved', 'Closed')";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, ticketId);
            ps.setInt(2, userId);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }
 public Integer getCategoryIdByName(String categoryName) {
        if (categoryName == null || categoryName.trim().isEmpty()) {
            return null;
        }
        String sql = "SELECT TOP 1 Id FROM [dbo].[Categories] WHERE LOWER(Name) = LOWER(?) AND IsActive = 1";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setString(1, categoryName.trim());
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt("Id");
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }
 public Integer getPriorityIdByLevel(String level) {
        if (level == null || level.trim().isEmpty()) {
            return null;
        }
        String sql = "SELECT TOP 1 Id FROM [dbo].[Priorities] WHERE LOWER([Level]) = LOWER(?)";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setString(1, level.trim());
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt("Id");
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }
 public boolean updateTicketBasicFields(int ticketId, String ticketType, Integer categoryId, Integer priorityId, String status) {
        Integer effectiveCategoryId = categoryId;
        Integer effectivePriorityId = priorityId;

        String selectSql = "SELECT CategoryId, PriorityId FROM [dbo].[Tickets] WHERE Id = ?";
        try (PreparedStatement sel = connection.prepareStatement(selectSql)) {
            sel.setInt(1, ticketId);
            try (ResultSet rs = sel.executeQuery()) {
                if (rs.next()) {
                    if (effectiveCategoryId == null) {
                        Object catObj = rs.getObject("CategoryId");
                        if (catObj != null) {
                            effectiveCategoryId = (Integer) catObj;
                        }
                    }
                    if (effectivePriorityId == null) {
                        Object priObj = rs.getObject("PriorityId");
                        if (priObj != null) {
                            effectivePriorityId = (Integer) priObj;
                        }
                    }
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }

        String sql = "UPDATE [dbo].[Tickets] "
                + "SET TicketType = ?, CategoryId = ?, PriorityId = ?, Status = ?, UpdatedAt = GETDATE() "
                + "WHERE Id = ?";

        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setString(1, ticketType);

            if (effectiveCategoryId != null) {
                ps.setInt(2, effectiveCategoryId);
            } else {
                ps.setNull(2, Types.INTEGER);
            }

            if (effectivePriorityId != null) {
                ps.setInt(3, effectivePriorityId);
            } else {
                ps.setNull(3, Types.INTEGER);
            }

            ps.setString(4, status);
            ps.setInt(5, ticketId);

            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }


}