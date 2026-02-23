/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package dao;

/**
 *
 * @author Dumb Trung
 */
import model.Tickets;
import Utils.DbContext;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class TicketDao extends DbContext {

    // 1. Unified Create Function (Xử lý cả Incident và Request)
    public boolean createTicket(Tickets t) {
        String sql = "INSERT INTO Tickets (TicketNumber, TicketType, Title, Description, CategoryId, LocationId, "
                   + "Impact, Urgency, ServiceCatalogId, Status, CreatedBy, CurrentLevel, CreatedAt) "
                   + "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, 'New', ?, 1, GETDATE())"; 
                   // Mặc định CurrentLevel = 1 (Vào Helpdesk trước)

        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setString(1, t.getTicketNumber()); // Logic sinh mã làm ở Service
            ps.setString(2, t.getTicketType());
            ps.setString(3, t.getTitle());
            ps.setString(4, t.getDescription());
            ps.setInt(5, t.getCategoryId());
            ps.setInt(6, t.getLocationId());
            
            // Xử lý Nullable cho Incident/Request
            if (t.getImpact() != null) ps.setInt(7, t.getImpact()); else ps.setNull(7, Types.INTEGER);
            if (t.getUrgency() != null) ps.setInt(8, t.getUrgency()); else ps.setNull(8, Types.INTEGER);
            if (t.getServiceCatalogId() != null) ps.setInt(9, t.getServiceCatalogId()); else ps.setNull(9, Types.INTEGER);

            ps.setInt(10, t.getCreatedBy());
            
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    // 2. Get Tickets cho IT Support (Phân tầng L1-L3)
    public List<Tickets> getTicketsForSupport(int agentId, int agentLevel) {
        List<Tickets> list = new ArrayList<>();
        // Logic SQL: Lấy vé được gán cho mình HOẶC vé đang ở Level của mình mà chưa ai nhận (Status=New/Escalated)
        String sql = "SELECT * FROM Tickets WHERE AssignedTo = ? OR (CurrentLevel = ? AND AssignedTo IS NULL)";
        
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, agentId);
            ps.setInt(2, agentLevel);
            
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                Tickets t = new Tickets();
                t.setId(rs.getInt("Id"));
                t.setTitle(rs.getString("Title"));
                t.setStatus(rs.getString("Status"));
                t.setTicketType(rs.getString("TicketType"));
                t.setPriorityId(rs.getInt("PriorityId"));
                t.setCreatedAt(rs.getDate("CreatedAt"));
                list.add(t);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }
}
