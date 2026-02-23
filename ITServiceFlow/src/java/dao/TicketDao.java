package dao;

import model.Tickets;
import Utils.DbContext;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class TicketDao extends DbContext {

    // 1. Unified Create Ticket (Cho cả Incident và Service Request)
    public boolean createTicket(Tickets t) {
        // Lưu ý: Các trường ngày tháng như CreatedAt, UpdatedAt sẽ để SQL tự sinh bằng GETDATE()
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
            if (t.getImpact() != null) ps.setInt(7, t.getImpact()); 
            else ps.setNull(7, Types.INTEGER);
            
            if (t.getUrgency() != null) ps.setInt(8, t.getUrgency()); 
            else ps.setNull(8, Types.INTEGER);
            
            if (t.getPriorityId() != null) ps.setInt(9, t.getPriorityId()); 
            else ps.setNull(9, Types.INTEGER);
            
            if (t.getServiceCatalogId() != null) ps.setInt(10, t.getServiceCatalogId()); 
            else ps.setNull(10, Types.INTEGER);
            
            // Xử lý Boolean
            if (t.getRequiresApproval() != null) ps.setBoolean(11, t.getRequiresApproval());
            else ps.setBoolean(11, false); // Mặc định không cần duyệt
            
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
        // Logic: Lấy ticket assign cho mình, hoặc ticket đang ở Level của mình mà chưa ai nhận
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
}