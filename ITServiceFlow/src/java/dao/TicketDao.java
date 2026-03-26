<<<<<<< HEAD
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

    public String createTicket(Tickets t) {
        // Lưu ý: Các trường ngày tháng như CreatedAt, UpdatedAt sẽ để SQL tự sinh bằng
        // GETDATE()
        // Status mặc định là 'New', CurrentLevel mặc định là 1
        String sql = "INSERT INTO Tickets ("
                + "TicketNumber, TicketType, Title, Description, CategoryId, LocationId, "
                + "Impact, Urgency, PriorityId, ServiceCatalogId, RequiresApproval, "
                + "Status, CreatedBy, CurrentLevel, CreatedAt, UpdatedAt"
                + ") VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, 'New', ?, 1, GETDATE(), GETDATE())";

        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setString(1, t.getTicketNumber());
            ps.setString(2, t.getTicketType());
            ps.setString(3, t.getTitle());
            ps.setString(4, t.getDescription());
            ps.setInt(5, t.getCategoryId());
            ps.setInt(6, t.getLocationId());

            // Xử lý cẩn thận các trường Integer có thể NULL
            if (t.getImpact() != null)
                ps.setInt(7, t.getImpact());
            else
                ps.setNull(7, Types.INTEGER);

            if (t.getUrgency() != null)
                ps.setInt(8, t.getUrgency());
            else
                ps.setNull(8, Types.INTEGER);

            if (t.getPriorityId() != null)
                ps.setInt(9, t.getPriorityId());
            else
                ps.setNull(9, Types.INTEGER);

            if (t.getServiceCatalogId() != null)
                ps.setInt(10, t.getServiceCatalogId());
            else
                ps.setNull(10, Types.INTEGER);

            // Xử lý Boolean
            if (t.getRequiresApproval() != null)
                ps.setBoolean(11, t.getRequiresApproval());
            else
                ps.setBoolean(11, false); // Mặc định không cần duyệt

            ps.setInt(12, t.getCreatedBy());

            int rowsAffected = ps.executeUpdate();
            return rowsAffected > 0 ? "ok" : "Lỗi: Không có dòng nào được tạo.";

        } catch (SQLException e) {
            System.err.println("Error creating ticket: " + e.getMessage());
            e.printStackTrace();
            return "Lỗi SQL: " + e.getMessage();
        }
    }

    // 2. Load Tickets cho Dashboard (L1, L2, L3)
    public List<Tickets> getTicketsForAgent(int currentAgentId, int currentAgentLevel) {
        List<Tickets> list = new ArrayList<>();
        // Logic: Lấy ticket assign cho mình, hoặc ticket đang ở Level của mình mà chưa
        // ai nhận
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

                // Tránh NullPointerException khi lấy Integer
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

                // Level của Priority (Critical/High/Medium/Low)
                t.setPriorityLevel(rs.getString("PriorityLevel"));

                list.add(t);
            }
        } catch (Exception ex) {
            ex.printStackTrace();
        }
        return list;
    }

    // Lookup Category.Id theo Category.Name (case-insensitive)
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

    // Lookup Priorities.Id theo Priorities.Level (case-insensitive)
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

    // Update nhanh các field cơ bản cho Ticket Detail
    public boolean updateTicketBasicFields(int ticketId, String ticketType, Integer categoryId, Integer priorityId, String status) {
        // Nếu categoryId hoặc priorityId null -> giữ nguyên giá trị cũ trong DB
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

    // 3. Lấy danh sách Ticket cho End-User (My Tickets)
    public List<Tickets> getTicketsByCreator(int userId) {
        List<Tickets> list = new ArrayList<>();
        // Dùng LEFT JOIN để lấy luôn tên Priority, Assignee và Category
        String sql = "SELECT t.Id, t.TicketNumber, t.TicketType, t.Title, t.Status, t.CreatedAt, t.UpdatedAt, "
                + "p.Level AS PriorityLevel, u.FullName AS AssigneeName, c.Name AS CategoryName "
                + "FROM [dbo].[Tickets] t "
                + "LEFT JOIN [dbo].[Priorities] p ON t.PriorityId = p.Id "
                + "LEFT JOIN [dbo].[Users] u ON t.AssignedTo = u.Id "
                + "LEFT JOIN [dbo].[Categories] c ON t.CategoryId = c.Id "
                + "WHERE t.CreatedBy = ? "
                + "ORDER BY t.CreatedAt DESC";

        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, userId);
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

                // Set các trường hiển thị mới thêm
                t.setPriorityLevel(rs.getString("PriorityLevel"));
                t.setAssigneeName(rs.getString("AssigneeName"));
                t.setCategoryName(rs.getString("CategoryName"));

                list.add(t);
            }
        } catch (Exception e) {
            System.err.println("Lỗi khi lấy danh sách My Tickets: " + e.getMessage());
            e.printStackTrace();
        }
        return list;
    }

    // 3b. Lấy chi tiết ticket theo TicketNumber (dùng cho TicketResolutionReview)
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

    // 4. Lấy chi tiết 1 Ticket theo ID - ĐÃ NÂNG CẤP JOIN
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

                // Set các trường hiển thị
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

    // Search ticket by ID (support Long_TicketDetailServlet)
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

    // 5. Lấy danh sách ticket đã Resolved (với bộ lọc từ khóa và loại ticket)
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

    // 5. Tạo ticket và trả về ID sinh ra (cho SLA tracking)
    public int createTicket2(Tickets ticket) {
=======
/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package dao;

import Utils.DbContext;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.List;
import model.Tickets;

/**
 *
 * @author DELL
 */
public class TicketDao extends DbContext {

    // This method returns the generated ID for SLA tracking
    public int createTicket(Tickets ticket) {
>>>>>>> HoangNV4
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

    // Helper to generate Ticket Number
    public String getNextTicketNumber(String type) {
        String prefix = type.equals("Incident") ? "INC-" : "SR-";
<<<<<<< HEAD
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

    public static void main(String[] args) {

        TicketDAO dao = new TicketDAO();

        List<Tickets> list = dao.getIncidentsNotInProblem();

        System.out.println("Danh sach incident chua gan vao problem:");

        for (Tickets t : list) {
            System.out.println(
                    t.getId() + " | " +
                            t.getTicketNumber() + " | " +
                            t.getTitle() + " | " +
                            t.getStatus());
        }

    }
    

    
    

    // 3. Ly danh sch Ticket cho End-User (My Tickets)
   public List<Tickets> getTicketsByCreator(int userId, int offset, int limit, String search, String status, String type) {
        List<Tickets> list = new ArrayList<>();
        
        // S dng StringBuilder  linh hot ni chui SQL
        StringBuilder sql = new StringBuilder(
            "SELECT t.Id, t.TicketNumber, t.TicketType, t.Title, t.Status, t.CreatedAt, t.UpdatedAt, "
            + "p.Level AS PriorityLevel, u.FullName AS AssigneeName, c.Name AS CategoryName "
            + "FROM [dbo].[Tickets] t "
            + "LEFT JOIN [dbo].[Priorities] p ON t.PriorityId = p.Id "
            + "LEFT JOIN [dbo].[Users] u ON t.AssignedTo = u.Id "
            + "LEFT JOIN [dbo].[Categories] c ON t.CategoryId = c.Id "
            + "WHERE t.CreatedBy = ? "
        );

        // Ni thm iu kin tm kim nu c
        if (search != null && !search.trim().isEmpty()) {
            sql.append("AND (t.TicketNumber LIKE ? OR t.Title LIKE ?) ");
        }
        
        // Ni thm iu kin Status nu khng phi 'all'
        if (status != null && !status.equals("all")) {
            sql.append("AND t.Status = ? ");
        }
        
        // Ni thm iu kin Type nu khng phi 'all'
        if (type != null && !type.equals("all")) {
            sql.append("AND t.TicketType = ? ");
        }

        sql.append("ORDER BY t.CreatedAt DESC OFFSET ? ROWS FETCH NEXT ? ROWS ONLY"); 
                   
        try (PreparedStatement ps = connection.prepareStatement(sql.toString())) {
            int paramIndex = 1;
            ps.setInt(paramIndex++, userId);
            
            // Set params tng ng vi th t ni chui
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

    
    
    // 6. Ly thng k KPI cho Dashboard ca ngi dng
    public java.util.Map<String, Integer> getUserTicketKPIs(int userId) {
        java.util.Map<String, Integer> kpis = new java.util.HashMap<>();
        kpis.put("open", 0);
        kpis.put("inProgress", 0);
        kpis.put("awaiting", 0);
        kpis.put("resolved7d", 0);

        // Gp 4 php tnh vo 1 cu query duy nht  ti u tc 
        String sql = "SELECT "
                   + "SUM(CASE WHEN Status IN ('New', 'Reopened') THEN 1 ELSE 0 END) AS OpenCount, "
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
            System.err.println("Error while calculating KPI: " + e.getMessage());
            e.printStackTrace();
        }
        return kpis;
    }
    
    // 7. m tng s v  tnh tng s trang
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
    
    // =========================================================================
    // CODE DNH CHO LUNG AGENT (DEV 2)
    // =========================================================================

    // 7. Ly danh sch Hng i (Queue) cho Agent c Filter
    public List<Tickets> getAgentQueues(int agentId, String queueType, int offset, int limit, String search, String status, String type) {
        List<Tickets> list = new ArrayList<>();
        
        StringBuilder sql = new StringBuilder(
            "SELECT t.*, p.Level AS PriorityLevel, u.FullName AS AssigneeName, c.Name AS CategoryName " +
            "FROM [dbo].[Tickets] t " +
            "LEFT JOIN [dbo].[Priorities] p ON t.PriorityId = p.Id " +
            "LEFT JOIN [dbo].[Users] u ON t.AssignedTo = u.Id " +
            "LEFT JOIN [dbo].[Categories] c ON t.CategoryId = c.Id WHERE 1=1 "
        );

        // Lc theo Queue Type
        if ("unassigned".equals(queueType)) {
            sql.append("AND t.AssignedTo IS NULL AND t.Status != 'Closed' AND t.Status != 'Resolved' ");
        } else if ("mine".equals(queueType)) {
            sql.append("AND t.AssignedTo = ? AND t.Status != 'Closed' AND t.Status != 'Resolved' ");
        } else if ("resolved".equals(queueType)) {
            sql.append("AND t.Status = 'Resolved' ");
        } else { // all_active
            sql.append("AND t.Status != 'Closed' AND t.Status != 'Resolved' ");
        }

        // Lc theo thanh Search & Filter
        if (search != null && !search.trim().isEmpty()) {
            sql.append("AND (t.TicketNumber LIKE ? OR t.Title LIKE ?) ");
        }
        if (status != null && !status.equals("all")) sql.append("AND t.Status = ? ");
        if (type != null && !type.equals("all")) sql.append("AND t.TicketType = ? ");

        sql.append("ORDER BY t.CreatedAt ASC OFFSET ? ROWS FETCH NEXT ? ROWS ONLY");

        try (PreparedStatement ps = connection.prepareStatement(sql.toString())) {
            int paramIdx = 1;
            if ("mine".equals(queueType)) ps.setInt(paramIdx++, agentId);
            
            if (search != null && !search.trim().isEmpty()) {
                ps.setString(paramIdx++, "%" + search + "%");
                ps.setString(paramIdx++, "%" + search + "%");
            }
            if (status != null && !status.equals("all")) ps.setString(paramIdx++, status);
            if (type != null && !type.equals("all")) ps.setString(paramIdx++, type);
            
            ps.setInt(paramIdx++, offset);
            ps.setInt(paramIdx++, limit);
            
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                Tickets t = new Tickets();
                // Map d liu
                t.setId(rs.getInt("Id"));
                t.setTicketNumber(rs.getString("TicketNumber"));
                t.setTicketType(rs.getString("TicketType"));
                t.setTitle(rs.getString("Title"));
                t.setStatus(rs.getString("Status"));
                t.setCreatedAt(rs.getTimestamp("CreatedAt"));
                t.setPriorityLevel(rs.getString("PriorityLevel"));
                t.setAssigneeName(rs.getString("AssigneeName"));
                list.add(t);
            }
        } catch (Exception e) { e.printStackTrace(); }
        return list;
    }

    // 8. m tng s v ca Queue (Phc v phn trang)
    public int getTotalAgentQueuesCount(int agentId, String queueType, String search, String status, String type) {
        StringBuilder sql = new StringBuilder("SELECT COUNT(*) FROM [dbo].[Tickets] t WHERE 1=1 ");

        if ("unassigned".equals(queueType)) {
            sql.append("AND t.AssignedTo IS NULL AND t.Status != 'Closed' AND t.Status != 'Resolved' ");
        } else if ("mine".equals(queueType)) {
            sql.append("AND t.AssignedTo = ? AND t.Status != 'Closed' AND t.Status != 'Resolved' ");
        } else if ("resolved".equals(queueType)) {
            sql.append("AND t.Status = 'Resolved' ");
        } else {
            sql.append("AND t.Status != 'Closed' AND t.Status != 'Resolved' ");
        }

        if (search != null && !search.trim().isEmpty()) sql.append("AND (t.TicketNumber LIKE ? OR t.Title LIKE ?) ");
        if (status != null && !status.equals("all")) sql.append("AND t.Status = ? ");
        if (type != null && !type.equals("all")) sql.append("AND t.TicketType = ? ");

        try (PreparedStatement ps = connection.prepareStatement(sql.toString())) {
            int paramIdx = 1;
            if ("mine".equals(queueType)) ps.setInt(paramIdx++, agentId);
            if (search != null && !search.trim().isEmpty()) {
                ps.setString(paramIdx++, "%" + search + "%");
                ps.setString(paramIdx++, "%" + search + "%");
            }
            if (status != null && !status.equals("all")) ps.setString(paramIdx++, status);
            if (type != null && !type.equals("all")) ps.setString(paramIdx++, type);
            
            ResultSet rs = ps.executeQuery();
            if (rs.next()) return rs.getInt(1);
        } catch (Exception e) { e.printStackTrace(); }
        return 0;
    }
    
    // =========================================================================
    // CODE ACTION CHO AGENT 
    // =========================================================================

    // 9. Phn cng v cho Agent (Assign to me)
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

    // 10. Cap nhat trang thai ve (Workflow: In Progress, Resolved, Closed)
    public boolean updateTicketStatus(int ticketId, String status) {
        // Tu dong set moc thoi gian khi ticket duoc Resolved/Closed.
        String sql = "UPDATE [dbo].[Tickets] SET Status = ?, UpdatedAt = GETDATE() ";
        
        if ("Resolved".equals(status)) {
            sql += ", ResolvedAt = GETDATE() ";
        } else if ("Closed".equals(status)) {
            sql += ", ClosedAt = GETDATE() ";
        }
        sql += "WHERE Id = ?";
        
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setString(1, status);
            ps.setInt(2, ticketId);
            int rows = ps.executeUpdate();
            
            // ===== HIỆU ỨNG DOMINO (CASCADE UPDATE) =====
            // Nếu vé cha được Resolved hoặc Closed, TỰ ĐỘNG cập nhật toàn bộ vé con
            if (rows > 0 && ("Resolved".equals(status) || "Closed".equals(status))) {
                String cascadeSql = "UPDATE [dbo].[Tickets] SET Status = ?, UpdatedAt = GETDATE() ";
                if ("Resolved".equals(status)) cascadeSql += ", ResolvedAt = GETDATE() ";
                if ("Closed".equals(status)) cascadeSql += ", ClosedAt = GETDATE() ";
                cascadeSql += "WHERE ParentTicketId = ? AND Status NOT IN ('Resolved', 'Closed')";
                
                try (PreparedStatement psCascade = connection.prepareStatement(cascadeSql)) {
                    psCascade.setString(1, status);
                    psCascade.setInt(2, ticketId);
                    psCascade.executeUpdate(); // Chạy lệnh đồng bộ vé con ngầm
                }
            }
            return true;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
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

    /**
     * KPI dashboard cho IT Support agent c th.
     * Tr v Map vi cc key:
     *   - myNew        : ticket mi cha assign hoc assign cho agent ny
     *   - myInProgress : ticket ang x l (AssignedTo = agentId, Status = In Progress)
     *   - myResolved   : ticket  resolved trong 7 ngy gn nht
     *   - myTotal      : tng ticket assign cho agent
     *   - slaBreaching : ticket sp breach SLA (ResolutionDeadline trong vng 2 gi ti)
     */
    public java.util.Map<String, Integer> getAgentKPIs(int agentId) {
        java.util.Map<String, Integer> kpis = new java.util.HashMap<>();
        kpis.put("myNew", 0);
        kpis.put("myInProgress", 0);
        kpis.put("myResolved", 0);
        kpis.put("myTotal", 0);
        kpis.put("slaBreaching", 0);

        String sql = "SELECT "
                   + "  SUM(CASE WHEN t.Status IN ('New','Reopened') AND (t.AssignedTo = ? OR t.AssignedTo IS NULL) THEN 1 ELSE 0 END) AS MyNew, "
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

        // SLA breaching: ticket ca agent ny c ResolutionDeadline trong 2 gi ti
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

    // =========================================================================
    // MANAGER DASHBOARD STATS
    // =========================================================================

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
 * 6 thng gn nht (t c  mi), mi thng: s  x l + s cha x l.
 */
    public Map<String, Object> getTicketStatsLast6Months() {
        List<String> labels = new ArrayList<>();
        int[] daXuLy = new int[6];
        int[] chuaXuLy = new int[6];

        // Thng hin ti
        YearMonth thangHienTai = YearMonth.from(LocalDate.now());

        // Duyt 6 thng: t (hin ti - 5) n hin ti
        for (int i = 0; i < 6; i++) {
            YearMonth thang = thangHienTai.minusMonths(5 - i); // i=0  thng c nht

            labels.add(thang.getMonthValue() + "/" + thang.getYear());

            if (connection == null) {
                continue;
            }

            // Ngy u thng v ngy u thng sau (dng < thng sau = ht thng ny)
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
    
    // =========================================================================
    // CODE US03: PARENT - CHILD INCIDENTS (GOM NHÓM VÉ)
    // =========================================================================

    // 1. Lấy danh sách các vé con (Child Tickets) của 1 vé cha
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

    // 2. Lấy thông tin vé cha (Parent Ticket) của 1 vé con
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

    // 3. Lấy danh sách các vé CÓ THỂ LIÊN KẾT (Để hiển thị trong Modal chọn vé con)
    // Điều kiện: Không phải là chính nó, chưa bị đóng, và chưa làm con của thằng nào khác
    public List<Tickets> getAvailableTicketsForLinking(int currentTicketId) {
        List<Tickets> list = new ArrayList<>();
        String sql = "SELECT Id, TicketNumber, Title, Status FROM [dbo].[Tickets] " +
                     "WHERE Id != ? AND Status NOT IN ('Resolved', 'Closed') " +
                     "AND ParentTicketId IS NULL";
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

    // 4. Hàm thực thi việc gán vé con vào vé cha
    public boolean linkChildTickets(int parentId, String[] childIds) {
        if (childIds == null || childIds.length == 0) return false;
        
        // Tạo chuỗi ?,?,? tương ứng với số lượng vé con được chọn
        StringBuilder placeholders = new StringBuilder();
        for (int i = 0; i < childIds.length; i++) {
            placeholders.append("?");
            if (i < childIds.length - 1) placeholders.append(",");
        }
        
        String sql = "UPDATE [dbo].[Tickets] SET ParentTicketId = ?, UpdatedAt = GETDATE() WHERE Id IN (" + placeholders.toString() + ")";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, parentId);
            for (int i = 0; i < childIds.length; i++) {
                ps.setInt(i + 2, Integer.parseInt(childIds[i]));
            }
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    /**  x l: ng/duyt trong khong [tuNgay, denNgay) */
    private int getAllTicketSolvedFromTo(Date from, Date to) {
        // ResolvedAt c th NULL, dng UpdatedAt fallback  chart c d liu.
        String sql = "SELECT COUNT(*) FROM Tickets " +
                "WHERE Status IN ('Resolved','Closed','Approved') " +
                "AND COALESCE(ResolvedAt, UpdatedAt) >= ? AND COALESCE(ResolvedAt, UpdatedAt) < ?";

        try (PreparedStatement ps = connection.prepareStatement(sql)) {

            ps.setDate(1, from); // t ngy
            ps.setDate(2, to);   // n ngy

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

    /** Cha x l: vn m v c to trong khong [tuNgay, denNgay) */
    private int getAllTicketUnSolvedFromTo(Date from, Date to) {
        String sql = "SELECT COUNT(*) FROM Tickets " +
                "WHERE Status IN ('New','Open','In Progress','Reopened') " +
                "AND CreatedAt >= ? AND CreatedAt < ?";

        try (PreparedStatement ps = connection.prepareStatement(sql)) {

            ps.setDate(1, from); // t ngy
            ps.setDate(2, to);   // n ngy

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
    
    public List<Tickets> getAgentQueues(int agentId, int currentLevel, String queueType, int offset, int limit, String search, String status, String type) {
        List<Tickets> list = new ArrayList<>();
        
        StringBuilder sql = new StringBuilder(
            "SELECT t.*, p.Level AS PriorityLevel, u.FullName AS AssigneeName, c.Name AS CategoryName, st.ResolutionDeadline " +
            "FROM [dbo].[Tickets] t " +
            "LEFT JOIN [dbo].[Priorities] p ON t.PriorityId = p.Id " +
            "LEFT JOIN [dbo].[Users] u ON t.AssignedTo = u.Id " +
            "LEFT JOIN [dbo].[Categories] c ON t.CategoryId = c.Id " +
            "LEFT JOIN [dbo].[SLATracking] st ON t.Id = st.TicketId WHERE 1=1 "
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
        if (status != null && !status.equals("all")) sql.append("AND t.Status = ? ");
        if (type != null && !type.equals("all")) sql.append("AND t.TicketType = ? ");

        sql.append("ORDER BY t.CreatedAt ASC OFFSET ? ROWS FETCH NEXT ? ROWS ONLY");

        try (PreparedStatement ps = connection.prepareStatement(sql.toString())) {
            int paramIdx = 1;
            if ("mine".equals(queueType)) ps.setInt(paramIdx++, agentId);
            
            if (search != null && !search.trim().isEmpty()) {
                ps.setString(paramIdx++, "%" + search + "%");
                ps.setString(paramIdx++, "%" + search + "%");
            }
            if (status != null && !status.equals("all")) ps.setString(paramIdx++, status);
            if (type != null && !type.equals("all")) ps.setString(paramIdx++, type);
            
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
                
                // Lấy SLA Deadline từ DB
                t.setResolutionDeadline(rs.getTimestamp("ResolutionDeadline"));
                list.add(t);
            }
        } catch (Exception e) { e.printStackTrace(); }
        return list;
    }

    public boolean processApproval(int ticketId, int managerId, boolean isApproved) {
        String sql;
        if (isApproved) {
            // DUYỆT: Lưu người duyệt, đổi trạng thái thành New, trả về Level 1 cho IT Support xử lý
            sql = "UPDATE [dbo].[Tickets] SET "
                + "ApprovedBy = ?, ApprovedAt = GETDATE(), "
                + "Status = 'New', CurrentLevel = 1, UpdatedAt = GETDATE() "
                + "WHERE Id = ?";
        } else {
            // TỪ CHỐI: Đóng vé luôn, giữ nguyên Level
            sql = "UPDATE [dbo].[Tickets] SET "
                + "ApprovedBy = ?, ApprovedAt = GETDATE(), "
                + "Status = 'Closed', UpdatedAt = GETDATE() "
                + "WHERE Id = ?";
        }

        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, managerId);
            ps.setInt(2, ticketId);
            int rows = ps.executeUpdate();
            
            if (rows > 0 && isApproved) {
                // Query ngược lại để lấy thông tin PriorityId và Type của vé
                Tickets t = getTicketById(ticketId); 
                if (t != null && t.getPriorityId() != null && t.getPriorityId() > 0) {
                    SLATrackingDao slaDao = new SLATrackingDao();
                    // Tính thời gian SLA bắt đầu từ giây phút này!
                    slaDao.applySLAForTicket(ticketId, t.getTicketType(), t.getPriorityId());
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
            
            // Xử lý an toàn cho Integer có thể Null (trường hợp Service Request)
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
        public List<model.Users> getActiveAgents() {
        List<model.Users> list = new ArrayList<>();
        // Lấy tất cả trừ End User, sắp xếp theo Role để dễ nhìn
        String sql = "SELECT Id, FullName, Role FROM [dbo].[Users] "
                   + "WHERE Role IN ('IT Support', 'Manager') AND IsActive = 1 "
                   + "ORDER BY Role, FullName";
        try (PreparedStatement ps = connection.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                model.Users u = new model.Users();
                u.setId(rs.getInt("Id"));
                // Format tên hiển thị: Nguyễn Văn A (IT Support)
                u.setFullName(rs.getString("FullName") + " (" + rs.getString("Role") + ")");
                list.add(u);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }
         public int getTotalAgentQueuesCount(int agentId, int currentLevel, String queueType, String search, String status, String type) {
        StringBuilder sql = new StringBuilder("SELECT COUNT(*) FROM [dbo].[Tickets] t WHERE 1=1 ");

        // ĐÃ SỬA: Bỏ lọc theo CurrentLevel
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

        try (PreparedStatement ps = connection.prepareStatement(sql.toString())) {
            int paramIdx = 1;
            if ("mine".equals(queueType)) ps.setInt(paramIdx++, agentId);
            if (search != null && !search.trim().isEmpty()) {
                ps.setString(paramIdx++, "%" + search + "%");
                ps.setString(paramIdx++, "%" + search + "%");
            }
            if (status != null && !status.equals("all")) ps.setString(paramIdx++, status);
            if (type != null && !type.equals("all")) ps.setString(paramIdx++, type);
            
            ResultSet rs = ps.executeQuery();
            if (rs.next()) return rs.getInt(1);
        } catch (Exception e) { e.printStackTrace(); }
        return 0;
    }
}
=======
        // Simple logic for demo, better use DB sequence or Max check
        return prefix + System.currentTimeMillis();
    }

    public Tickets getTicketById(int id) {
        String sql = "SELECT * FROM [dbo].[Tickets] WHERE Id = ?";
        try {
            PreparedStatement stm = connection.prepareStatement(sql);
            stm.setInt(1, id);
            ResultSet rs = stm.executeQuery();
            if (rs.next()) {
                Tickets t = new Tickets();
                t.setId(rs.getInt("Id"));
                t.setTicketNumber(rs.getString("TicketNumber"));
                t.setTicketType(rs.getString("TicketType"));
                t.setTitle(rs.getString("Title"));
                t.setDescription(rs.getString("Description"));
                t.setCategoryId(rs.getInt("CategoryId"));
                t.setLocationId(rs.getInt("LocationId"));
                t.setImpact(rs.getObject("Impact") != null ? rs.getInt("Impact") : null);
                t.setUrgency(rs.getObject("Urgency") != null ? rs.getInt("Urgency") : null);
                t.setPriorityId(rs.getObject("PriorityId") != null ? rs.getInt("PriorityId") : null);
                t.setServiceCatalogId(rs.getObject("ServiceCatalogId") != null ? rs.getInt("ServiceCatalogId") : null);
                t.setRequiresApproval(
                        rs.getObject("RequiresApproval") != null ? rs.getBoolean("RequiresApproval") : null);
                t.setStatus(rs.getString("Status"));
                t.setCreatedBy(rs.getInt("CreatedBy"));
                t.setAssignedTo(rs.getObject("AssignedTo") != null ? rs.getInt("AssignedTo") : null);
                t.setCreatedAt(rs.getTimestamp("CreatedAt"));
                // Add other fields if necessary
                return t;
            }
        } catch (Exception ex) {
            ex.printStackTrace();
        }
        return null;
    }
    public List<String> getDistinctStatuses() {
        List<String> list = new ArrayList<>();
        String sql = "SELECT DISTINCT Status FROM [dbo].[Tickets] WHERE Status IS NOT NULL ORDER BY Status";
        try {
            PreparedStatement stm = connection.prepareStatement(sql);
            ResultSet rs = stm.executeQuery();
            while (rs.next()) {
                list.add(rs.getString("Status"));
            }
        } catch (Exception ex) {
            ex.printStackTrace();
        }
        return list;
    }
}
>>>>>>> HoangNV4
