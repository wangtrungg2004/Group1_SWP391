/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package dao;

import Utils.DbContext;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;
import model.Priority;
import model.SLARule;

/**
 *
 * @author DELL
 */
public class SLARuleDao extends DbContext {

<<<<<<< HEAD
    private void deactivateRulesByTypeAndPriority(String ticketType, int priorityId) {
        String sql = "UPDATE [dbo].[SLARules] SET Status = 'Inactive', UpdatedAt = GETDATE() "
                + "WHERE TicketType = ? AND PriorityId = ? AND Status = 'Active'";
        try {
            PreparedStatement stm = connection.prepareStatement(sql);
            stm.setString(1, ticketType);
            stm.setInt(2, priorityId);
            stm.executeUpdate();
        } catch (Exception ex) {
            ex.printStackTrace();
        }
    }

=======
>>>>>>> 1763278990a4a240d89ada2a865acfd8b2595d22
    public List<SLARule> getAllSLARules() {
        List<SLARule> list = new ArrayList<>();
        String sql = "SELECT s.Id, s.SLAName, s.TicketType, s.PriorityId, s.ResponseTime, s.ResolutionTime, s.Status, s.CreatedBy, s.CreatedAt, s.UpdatedAt, "
                + "p.Level as PriorityName, u.FullName as CreatedByName "
                + "FROM [dbo].[SLARules] s "
                + "LEFT JOIN [dbo].[Priorities] p ON s.PriorityId = p.Id "
                + "LEFT JOIN [dbo].[Users] u ON s.CreatedBy = u.Id "
                + "ORDER BY s.Id";
        try {
            PreparedStatement stm = connection.prepareStatement(sql);
            ResultSet rs = stm.executeQuery();
            while (rs.next()) {
                SLARule sla = new SLARule();
                sla.setId(rs.getInt("Id"));
                sla.setSlaName(rs.getString("SLAName"));
                sla.setTicketType(rs.getString("TicketType"));
                sla.setPriorityId(rs.getInt("PriorityId"));
                sla.setResponseTime(rs.getInt("ResponseTime"));
                sla.setResolutionTime(rs.getInt("ResolutionTime"));
                sla.setStatus(rs.getString("Status"));
                sla.setCreatedBy(rs.getInt("CreatedBy"));
                sla.setCreatedAt(rs.getDate("CreatedAt"));
                sla.setUpdatedAt(rs.getDate("UpdatedAt"));
                sla.setPriorityName(rs.getString("PriorityName"));
                sla.setCreatedByName(rs.getString("CreatedByName"));
                list.add(sla);
            }
        } catch (Exception ex) {
            ex.printStackTrace();
        }
        return list;
    }

    public List<Priority> getAllPriorities() {
        List<Priority> list = new ArrayList<>();
        String sql = "SELECT * FROM [dbo].[Priorities]";
        try {
            PreparedStatement stm = connection.prepareStatement(sql);
            ResultSet rs = stm.executeQuery();
            while (rs.next()) {
                Priority p = new Priority();
                p.setId(rs.getInt("Id"));
                p.setImpact(rs.getInt("Impact"));
                p.setUrgency(rs.getInt("Urgency"));
                p.setLevel(rs.getString("Level"));
                p.setResponseHours(rs.getInt("ResponseHours"));
                p.setResolutionHours(rs.getInt("ResolutionHours"));
                list.add(p);
            }
        } catch (Exception ex) {
            ex.printStackTrace();
        }
        return list;
    }

    public boolean addSLARule(SLARule sla) {
<<<<<<< HEAD
        try {
            if ("Active".equalsIgnoreCase(sla.getStatus())) {
                deactivateRulesByTypeAndPriority(sla.getTicketType(), sla.getPriorityId());
            }

            String sql = "INSERT INTO [dbo].[SLARules] (SLAName, TicketType, PriorityId, ResponseTime, ResolutionTime, Status, CreatedBy, CreatedAt, UpdatedAt) "
                    + "VALUES (?, ?, ?, ?, ?, ?, ?, GETDATE(), GETDATE())";

=======
        String sql = "INSERT INTO [dbo].[SLARules] (SLAName, TicketType, PriorityId, ResponseTime, ResolutionTime, Status, CreatedBy, CreatedAt, UpdatedAt) "
                + "VALUES (?, ?, ?, ?, ?, ?, ?, GETDATE(), GETDATE())";
        try {
>>>>>>> 1763278990a4a240d89ada2a865acfd8b2595d22
            PreparedStatement stm = connection.prepareStatement(sql);
            stm.setString(1, sla.getSlaName());
            stm.setString(2, sla.getTicketType());
            stm.setInt(3, sla.getPriorityId());
            stm.setInt(4, sla.getResponseTime());
            stm.setInt(5, sla.getResolutionTime());
            stm.setString(6, sla.getStatus());
            stm.setInt(7, sla.getCreatedBy());
            return stm.executeUpdate() > 0;
        } catch (Exception ex) {
            ex.printStackTrace();
        }
        return false;
    }

    public boolean updateSLARule(SLARule sla) {
        String sql = "UPDATE [dbo].[SLARules] SET SLAName=?, TicketType=?, PriorityId=?, ResponseTime=?, ResolutionTime=?, Status=?, UpdatedAt=GETDATE() WHERE Id=?";
        try {
            PreparedStatement stm = connection.prepareStatement(sql);
            stm.setString(1, sla.getSlaName());
            stm.setString(2, sla.getTicketType());
            stm.setInt(3, sla.getPriorityId());
            stm.setInt(4, sla.getResponseTime());
            stm.setInt(5, sla.getResolutionTime());
            stm.setString(6, sla.getStatus());
            stm.setInt(7, sla.getId());
            return stm.executeUpdate() > 0;
        } catch (Exception ex) {
            ex.printStackTrace();
        }
        return false;
    }

    public boolean deleteSLARule(int id) {
        String sql = "DELETE FROM [dbo].[SLARules] WHERE Id=?";
        try {
            PreparedStatement stm = connection.prepareStatement(sql);
            stm.setInt(1, id);
            return stm.executeUpdate() > 0;
        } catch (Exception ex) {
            ex.printStackTrace();
        }
        return false;
    }

    public SLARule getSLARuleById(int id) {
        String sql = "SELECT * FROM [dbo].[SLARules] WHERE Id=?";
        try {
            PreparedStatement stm = connection.prepareStatement(sql);
            stm.setInt(1, id);
            ResultSet rs = stm.executeQuery();
            if (rs.next()) {
                SLARule sla = new SLARule();
                sla.setId(rs.getInt("Id"));
                sla.setSlaName(rs.getString("SLAName"));
                sla.setTicketType(rs.getString("TicketType"));
                sla.setPriorityId(rs.getInt("PriorityId"));
                sla.setResponseTime(rs.getInt("ResponseTime"));
                sla.setResolutionTime(rs.getInt("ResolutionTime"));
                sla.setStatus(rs.getString("Status"));
                sla.setCreatedBy(rs.getInt("CreatedBy"));
                sla.setCreatedAt(rs.getDate("CreatedAt"));
                sla.setUpdatedAt(rs.getDate("UpdatedAt"));
                return sla;
            }
        } catch (Exception ex) {
            ex.printStackTrace();
        }
        return null;
    }

<<<<<<< HEAD
    public SLARule getActiveRuleByTypeAndPriority(String ticketType, int priorityId) {
        String sql = "SELECT * FROM [dbo].[SLARules] WHERE TicketType = ? AND PriorityId = ? AND Status = 'Active'";
        try {
            PreparedStatement stm = connection.prepareStatement(sql);
            stm.setString(1, ticketType);
            stm.setInt(2, priorityId);
            ResultSet rs = stm.executeQuery();
            if (rs.next()) {
                SLARule sla = new SLARule();
                sla.setId(rs.getInt("Id"));
                sla.setSlaName(rs.getString("SLAName"));
                sla.setTicketType(rs.getString("TicketType"));
                sla.setPriorityId(rs.getInt("PriorityId"));
                sla.setResponseTime(rs.getInt("ResponseTime"));
                sla.setResolutionTime(rs.getInt("ResolutionTime"));
                sla.setStatus(rs.getString("Status"));
                return sla;
            }
        } catch (Exception ex) {
            ex.printStackTrace();
        }
        return null;
    }

=======
>>>>>>> 1763278990a4a240d89ada2a865acfd8b2595d22
    public List<SLARule> searchSLARules(String name, String type, Integer priorityId, String status, int page,
            int pageSize) {
        List<SLARule> list = new ArrayList<>();
        StringBuilder sql = new StringBuilder(
                "SELECT s.Id, s.SLAName, s.TicketType, s.PriorityId, s.ResponseTime, s.ResolutionTime, s.Status, s.CreatedBy, s.CreatedAt, s.UpdatedAt, "
                        + "p.Level as PriorityName, u.FullName as CreatedByName "
                        + "FROM [dbo].[SLARules] s "
                        + "LEFT JOIN [dbo].[Priorities] p ON s.PriorityId = p.Id "
                        + "LEFT JOIN [dbo].[Users] u ON s.CreatedBy = u.Id "
                        + "WHERE 1=1 ");

        List<Object> params = new ArrayList<>();

        if (name != null && !name.isEmpty()) {
            sql.append("AND s.SLAName LIKE ? ");
            params.add("%" + name + "%");
        }
        if (type != null && !type.isEmpty()) {
            sql.append("AND s.TicketType = ? ");
            params.add(type);
        }
        if (priorityId != null && priorityId > 0) {
            sql.append("AND s.PriorityId = ? ");
            params.add(priorityId);
        }
        if (status != null && !status.isEmpty()) {
            sql.append("AND s.Status = ? ");
            params.add(status);
        }

        sql.append("ORDER BY s.Id OFFSET ? ROWS FETCH NEXT ? ROWS ONLY");
        params.add((page - 1) * pageSize);
        params.add(pageSize);

        try {
            PreparedStatement stm = connection.prepareStatement(sql.toString());
            for (int i = 0; i < params.size(); i++) {
                stm.setObject(i + 1, params.get(i));
            }
            ResultSet rs = stm.executeQuery();
            while (rs.next()) {
                SLARule sla = new SLARule();
                sla.setId(rs.getInt("Id"));
                sla.setSlaName(rs.getString("SLAName"));
                sla.setTicketType(rs.getString("TicketType"));
                sla.setPriorityId(rs.getInt("PriorityId"));
                sla.setResponseTime(rs.getInt("ResponseTime"));
                sla.setResolutionTime(rs.getInt("ResolutionTime"));
                sla.setStatus(rs.getString("Status"));
                sla.setCreatedBy(rs.getInt("CreatedBy"));
                sla.setCreatedAt(rs.getDate("CreatedAt"));
                sla.setUpdatedAt(rs.getDate("UpdatedAt"));
                sla.setPriorityName(rs.getString("PriorityName"));
                sla.setCreatedByName(rs.getString("CreatedByName"));
                list.add(sla);
            }
        } catch (Exception ex) {
            ex.printStackTrace();
        }
        return list;
    }

    public int countSLARules(String name, String type, Integer priorityId, String status) {
        StringBuilder sql = new StringBuilder("SELECT COUNT(*) FROM [dbo].[SLARules] s WHERE 1=1 ");
        List<Object> params = new ArrayList<>();

        if (name != null && !name.isEmpty()) {
            sql.append("AND s.SLAName LIKE ? ");
            params.add("%" + name + "%");
        }
        if (type != null && !type.isEmpty()) {
            sql.append("AND s.TicketType = ? ");
            params.add(type);
        }
        if (priorityId != null && priorityId > 0) {
            sql.append("AND s.PriorityId = ? ");
            params.add(priorityId);
        }
        if (status != null && !status.isEmpty()) {
            sql.append("AND s.Status = ? ");
            params.add(status);
        }

        try {
            PreparedStatement stm = connection.prepareStatement(sql.toString());
            for (int i = 0; i < params.size(); i++) {
                stm.setObject(i + 1, params.get(i));
            }
            ResultSet rs = stm.executeQuery();
            if (rs.next()) {
                return rs.getInt(1);
            }
        } catch (Exception ex) {
            ex.printStackTrace();
        }
        return 0;
    }
}
