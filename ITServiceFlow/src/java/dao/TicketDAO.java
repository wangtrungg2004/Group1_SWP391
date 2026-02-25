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

public class TicketDAO extends DbContext {

    private static final Logger LOGGER = Logger.getLogger(TicketDAO.class.getName());

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

    // Tạo mới Ticket, trả về ID vừa tạo hoặc -1 nếu lỗi
    public int createTicket(Tickets ticket) {
        String sql = "INSERT INTO Tickets (TicketNumber, TicketType, Title, Description, CategoryId, "
                + "LocationId, Impact, Urgency, PriorityId, ServiceCatalogId, RequiresApproval, "
                + "Status, CreatedBy, AssignedTo, ParentTicketId, CreatedAt, UpdatedAt, CurrentLevel) "
                + "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, GETDATE(), GETDATE(), ?)";

        try (PreparedStatement ps = connection.prepareStatement(sql, PreparedStatement.RETURN_GENERATED_KEYS)) {

            ps.setString(1, ticket.getTicketNumber());
            ps.setString(2, ticket.getTicketType());
            ps.setString(3, ticket.getTitle());
            ps.setString(4, ticket.getDescription());
            ps.setInt(5, ticket.getCategoryId());
            ps.setInt(6, ticket.getLocationId());
            ps.setObject(7, ticket.getImpact(), java.sql.Types.INTEGER);
            ps.setObject(8, ticket.getUrgency(), java.sql.Types.INTEGER);
            ps.setObject(9, ticket.getPriorityId(), java.sql.Types.INTEGER);
            ps.setObject(10, ticket.getServiceCatalogId(), java.sql.Types.INTEGER);
            ps.setBoolean(11, ticket.isRequiresApproval());
            ps.setString(12, ticket.getStatus());
            ps.setInt(13, ticket.getCreatedBy());
            ps.setObject(14, ticket.getAssignedTo(), java.sql.Types.INTEGER);
            ps.setObject(15, ticket.getParentTicketId(), java.sql.Types.INTEGER);
            ps.setInt(16, ticket.getCurrentLevel());

            int affectedRows = ps.executeUpdate();
            if (affectedRows == 0) {
                throw new SQLException("Creating ticket failed, no rows affected.");
            }

            try (ResultSet generatedKeys = ps.getGeneratedKeys()) {
                if (generatedKeys.next()) {
                    return generatedKeys.getInt(1);
                } else {
                    throw new SQLException("Creating ticket failed, no ID obtained.");
                }
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error creating ticket", e);
            return -1;
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
        ticket.setImpact(rs.getInt("Impact"));
        ticket.setUrgency(rs.getInt("Urgency"));
        ticket.setPriorityId(rs.getInt("PriorityId"));
        ticket.setServiceCatalogId(rs.getInt("ServiceCatalogId"));
        ticket.setRequiresApproval(rs.getBoolean("RequiresApproval"));
        ticket.setApprovedBy(rs.getInt("ApprovedBy"));
        ticket.setApprovedAt(rs.getTimestamp("ApprovedAt"));
        ticket.setStatus(rs.getString("Status"));
        ticket.setCreatedBy(rs.getInt("CreatedBy"));
        ticket.setAssignedTo(rs.getInt("AssignedTo"));
        ticket.setParentTicketId(rs.getInt("ParentTicketId"));
        ticket.setResolvedAt(rs.getTimestamp("ResolvedAt"));
        ticket.setClosedAt(rs.getTimestamp("ClosedAt"));
        ticket.setCreatedAt(rs.getTimestamp("CreatedAt"));
        ticket.setUpdatedAt(rs.getTimestamp("UpdatedAt"));
        ticket.setCurrentLevel(rs.getInt("CurrentLevel"));
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