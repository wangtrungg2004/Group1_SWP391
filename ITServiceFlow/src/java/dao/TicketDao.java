package dao;

import model.Tickets;
import Utils.DbContext;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;
import org.apache.tomcat.dbcp.dbcp2.PoolingConnection;

public class TicketDAO extends DbContext {

    // 1. Unified Create Ticket (Cho cả Incident và Service Request)
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
        String sql = "SELECT [Id]\n" +
                "      ,[TicketNumber]\n" +
                "      ,[TicketType]\n" +
                "      ,[Title]\n" +
                "      ,[Description]\n" +
                "      ,[CategoryId]\n" +
                "      ,[LocationId]\n" +
                "      ,[Impact]\n" +
                "      ,[Urgency]\n" +
                "      ,[PriorityId]\n" +
                "      ,[ServiceCatalogId]\n" +
                "      ,[RequiresApproval]\n" +
                "      ,[ApprovedBy]\n" +
                "      ,[ApprovedAt]\n" +
                "      ,[Status]\n" +
                "      ,[CreatedBy]\n" +
                "      ,[AssignedTo]\n" +
                "      ,[ParentTicketId]\n" +
                "      ,[ResolvedAt]\n" +
                "      ,[ClosedAt]\n" +
                "      ,[CreatedAt]\n" +
                "      ,[UpdatedAt]\n" +
                "      ,[CurrentLevel]\n" +
                "  FROM [dbo].[Tickets]";
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

                list.add(t);
            }
        } catch (Exception ex) {
            ex.printStackTrace();
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

    // 3. Lấy danh sách Ticket cho End-User (My Tickets)
   public List<Tickets> getTicketsByCreator(int userId, int offset, int limit, String search, String status, String type) {
        List<Tickets> list = new ArrayList<>();
        
        // Sử dụng StringBuilder để linh hoạt nối chuỗi SQL
        StringBuilder sql = new StringBuilder(
            "SELECT t.Id, t.TicketNumber, t.TicketType, t.Title, t.Status, t.CreatedAt, t.UpdatedAt, "
            + "p.Level AS PriorityLevel, u.FullName AS AssigneeName, c.Name AS CategoryName "
            + "FROM [dbo].[Tickets] t "
            + "LEFT JOIN [dbo].[Priorities] p ON t.PriorityId = p.Id "
            + "LEFT JOIN [dbo].[Users] u ON t.AssignedTo = u.Id "
            + "LEFT JOIN [dbo].[Categories] c ON t.CategoryId = c.Id "
            + "WHERE t.CreatedBy = ? "
        );

        // Nối thêm điều kiện tìm kiếm nếu có
        if (search != null && !search.trim().isEmpty()) {
            sql.append("AND (t.TicketNumber LIKE ? OR t.Title LIKE ?) ");
        }
        
        // Nối thêm điều kiện Status nếu không phải 'all'
        if (status != null && !status.equals("all")) {
            sql.append("AND t.Status = ? ");
        }
        
        // Nối thêm điều kiện Type nếu không phải 'all'
        if (type != null && !type.equals("all")) {
            sql.append("AND t.TicketType = ? ");
        }

        sql.append("ORDER BY t.CreatedAt DESC OFFSET ? ROWS FETCH NEXT ? ROWS ONLY"); 
                   
        try (PreparedStatement ps = connection.prepareStatement(sql.toString())) {
            int paramIndex = 1;
            ps.setInt(paramIndex++, userId);
            
            // Set params tương ứng với thứ tự nối chuỗi
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

    // 5. Lấy danh sách ticket đã Resolved (có thể lọc theo keyword TicketNumber)
    public List<Tickets> getResolvedTickets(String keyword) {
        List<Tickets> list = new ArrayList<>();
        String baseSql = "SELECT t.Id, t.TicketNumber, t.TicketType, t.Title, t.Status, t.ResolvedAt "
                + "FROM [dbo].[Tickets] t WHERE t.Status = 'Resolved'";
        boolean hasKeyword = keyword != null && !keyword.trim().isEmpty();
        String sql = hasKeyword ? baseSql + " AND t.TicketNumber LIKE ?" : baseSql;
        sql += " ORDER BY t.ResolvedAt DESC";

        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            if (hasKeyword) {
                ps.setString(1, "%" + keyword.trim() + "%");
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

    // 5. Tạo ticket và trả về ID sinh ra (cho SLA tracking)
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
    
    // 6. Lấy thống kê KPI cho Dashboard của người dùng
    public java.util.Map<String, Integer> getUserTicketKPIs(int userId) {
        java.util.Map<String, Integer> kpis = new java.util.HashMap<>();
        kpis.put("open", 0);
        kpis.put("inProgress", 0);
        kpis.put("awaiting", 0);
        kpis.put("resolved7d", 0);

        // Gộp 4 phép tính vào 1 câu query duy nhất để tối ưu tốc độ
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
    
    // 7. Đếm tổng số vé để tính tổng số trang
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

    // Helper to generate Ticket Number
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
    
    // =========================================================================
    // CODE DÀNH CHO LUỒNG AGENT (DEV 2)
    // =========================================================================

    // 7. Lấy danh sách Hàng đợi (Queue) cho Agent có Filter
    public List<Tickets> getAgentQueues(int agentId, String queueType, int offset, int limit, String search, String status, String type) {
        List<Tickets> list = new ArrayList<>();
        
        StringBuilder sql = new StringBuilder(
            "SELECT t.*, p.Level AS PriorityLevel, u.FullName AS AssigneeName, c.Name AS CategoryName " +
            "FROM [dbo].[Tickets] t " +
            "LEFT JOIN [dbo].[Priorities] p ON t.PriorityId = p.Id " +
            "LEFT JOIN [dbo].[Users] u ON t.AssignedTo = u.Id " +
            "LEFT JOIN [dbo].[Categories] c ON t.CategoryId = c.Id WHERE 1=1 "
        );

        // Lọc theo Queue Type
        if ("unassigned".equals(queueType)) {
            sql.append("AND t.AssignedTo IS NULL AND t.Status != 'Closed' AND t.Status != 'Resolved' ");
        } else if ("mine".equals(queueType)) {
            sql.append("AND t.AssignedTo = ? AND t.Status != 'Closed' AND t.Status != 'Resolved' ");
        } else if ("resolved".equals(queueType)) {
            sql.append("AND t.Status = 'Resolved' ");
        } else { // all_active
            sql.append("AND t.Status != 'Closed' AND t.Status != 'Resolved' ");
        }

        // Lọc theo thanh Search & Filter
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
                // Map dữ liệu
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

    // 8. Đếm tổng số vé của Queue (Phục vụ phân trang)
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

    // 9. Phân công vé cho Agent (Assign to me)
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

    // 10. Cập nhật trạng thái vé (Workflow: In Progress, Resolved, Closed)
    public boolean updateTicketStatus(int ticketId, String status) {
        // Cấu trúc SQL động: Tự động chốt thời gian nếu vé hoàn thành
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
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
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
}