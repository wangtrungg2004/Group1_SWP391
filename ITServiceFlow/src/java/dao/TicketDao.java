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
