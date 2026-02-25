package dao;

import Utils.DbContext;
import model.Tickets;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;
import java.sql.*;

public class TicketDAO extends DbContext {

    private static final Logger LOGGER = Logger.getLogger(TicketDAO.class.getName());

    // 1. Unified Create Ticket (Cho cả Incident và Service Request)
    public boolean createTicket(Tickets t) {
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
            // Model uses primitive boolean; default false when unset
            ps.setBoolean(11, t.isRequiresApproval());

            ps.setInt(12, t.getCreatedBy());

            int rowsAffected = ps.executeUpdate();
            return rowsAffected > 0;

        } catch (SQLException e) {
            System.err.println("Error creating ticket: " + e.getMessage());
            e.printStackTrace();
            return false;
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

    // This method returns the generated ID for SLA tracking
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
            // Model uses primitive boolean; default false when unset
            stm.setBoolean(11, ticket.isRequiresApproval());
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
        // Simple logic for demo, better use DB sequence or Max check
        return prefix + System.currentTimeMillis();
    }

    // Lấy Ticket theo ID, có join thêm CategoryName, LocationName, PriorityLevel
    public Tickets getTicketById(int ticketId) {
        String sql = "SELECT t.*, "
                + "c.Name AS CategoryName, "
                + "l.Name AS LocationName, "
                + "p.Level AS PriorityLevel "
                + "FROM Tickets t "
                + "LEFT JOIN Categories c ON t.CategoryId = c.Id "
                + "LEFT JOIN Locations l ON t.LocationId = l.Id "
                + "LEFT JOIN Priorities p ON t.PriorityId = p.Id "
                + "WHERE t.Id = ?";

        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, ticketId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    Tickets ticket = mapResultSetToTicket(rs);
                    ticket.setCategoryName(rs.getString("CategoryName"));
                    ticket.setLocationName(rs.getString("LocationName"));
                    ticket.setPriorityLevel(rs.getInt("PriorityLevel"));
                    return ticket;
                }
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error getting ticket by ID: " + ticketId, e);
        }
        return null;
    }

    // Lấy tất cả Tickets
    public List<Tickets> getAllTickets() {
        List<Tickets> list = new ArrayList<>();
        String sql = "SELECT * FROM Tickets ORDER BY CreatedAt DESC";

        try (PreparedStatement ps = connection.prepareStatement(sql);
                ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                list.add(mapResultSetToTicket(rs));
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error getting all tickets", e);
        }
        return list;
    }

    // Cập nhật trạng thái Ticket
    public boolean updateTicketStatus(int ticketId, String newStatus) {
        String sql = "UPDATE Tickets SET Status = ?, UpdatedAt = GETDATE() WHERE Id = ?";

        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setString(1, newStatus);
            ps.setInt(2, ticketId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error updating ticket status: " + ticketId, e);
            return false;
        }
    }

    // Helper: map ResultSet -> Tickets object
    private Tickets mapResultSetToTicket(ResultSet rs) throws SQLException {
        Tickets ticket = new Tickets();
        ticket.setId(rs.getInt("Id"));
        ticket.setTicketNumber(rs.getString("TicketNumber"));
        ticket.setTicketType(rs.getString("TicketType"));
        ticket.setTitle(rs.getString("Title"));
        ticket.setDescription(rs.getString("Description"));
        ticket.setCategoryId(rs.getInt("CategoryId"));
        ticket.setLocationId(rs.getInt("LocationId"));
        ticket.setImpact((Integer) rs.getObject("Impact"));
        ticket.setUrgency((Integer) rs.getObject("Urgency"));
        ticket.setPriorityId((Integer) rs.getObject("PriorityId"));
        ticket.setServiceCatalogId((Integer) rs.getObject("ServiceCatalogId"));
        ticket.setRequiresApproval(rs.getBoolean("RequiresApproval"));
        ticket.setApprovedBy((Integer) rs.getObject("ApprovedBy"));
        ticket.setApprovedAt(rs.getTimestamp("ApprovedAt"));
        ticket.setStatus(rs.getString("Status"));
        ticket.setCreatedBy(rs.getInt("CreatedBy"));
        ticket.setAssignedTo((Integer) rs.getObject("AssignedTo"));
        ticket.setParentTicketId((Integer) rs.getObject("ParentTicketId"));
        ticket.setResolvedAt(rs.getTimestamp("ResolvedAt"));
        ticket.setClosedAt(rs.getTimestamp("ClosedAt"));
        ticket.setCreatedAt(rs.getTimestamp("CreatedAt"));
        ticket.setUpdatedAt(rs.getTimestamp("UpdatedAt"));
        ticket.setCurrentLevel((Integer) rs.getObject("CurrentLevel"));
        return ticket;
    }

    public void closeConnection() {
        try {
            if (connection != null && !connection.isClosed()) {
                connection.close();
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error closing connection", e);
        }
    }
}