/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package dao;

/**
 *
 * @author admin
 */
import java.sql.*;
import java.util.ArrayList;
import java.util.List;
import model.ChangeApproval;
import model.ChangeRequests;
import Utils.DbContext;
import java.time.Year;
import java.sql.Date;
public class ChangeRequestDao extends DbContext {

    // Sinh TicketNumber cho Change Request: CHG-YYYY-XXX
    private String getNextTicketNumber() {
        int year = Year.now().getValue();
        String prefix = "CHG-" + year + "-";
        String sql = "SELECT MAX(TicketNumber) FROM ChangeRequests WHERE TicketNumber LIKE ?";
        int next = 1;
        try (PreparedStatement stm = connection.prepareStatement(sql)) {
            stm.setString(1, prefix + "%");
            ResultSet rs = stm.executeQuery();
            if (rs.next() && rs.getString(1) != null) {
                String last = rs.getString(1);
                String seq = last.substring(last.lastIndexOf('-') + 1);
                next = Integer.parseInt(seq) + 1;
            }
        } catch (SQLException ex) {
            ex.printStackTrace();
        }
        return prefix + String.format("%03d", next);
    }

    // IT Support tạo Change Request mới (RiskLevel & RollbackPlan bắt buộc)
    public int createChangeRequest(int createdBy, String title, String description, 
                               String changeType, String riskLevel, String rollbackPlan,
                               java.util.Date plannedStart, java.util.Date plannedEnd) {
    if (riskLevel == null || riskLevel.trim().isEmpty() || 
        rollbackPlan == null || rollbackPlan.trim().isEmpty()) {
        return -1; // Lỗi bắt buộc
    }

    String sql = "INSERT INTO ChangeRequests (TicketNumber, Title, Description, ChangeType, RiskLevel, " +
                 "RollbackPlan, PlannedStart, PlannedEnd, Status, CreatedBy, CreatedAt) " +
                 "VALUES (?, ?, ?, ?, ?, ?, ?, ?, 'Pending Approval', ?, GETDATE())";
    try (PreparedStatement stm = connection.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
        stm.setString(1, getNextTicketNumber());
        stm.setString(2, title);
        stm.setString(3, description);
        stm.setString(4, changeType);
        stm.setString(5, riskLevel);
        stm.setString(6, rollbackPlan);
        
        // Convert java.util.Date sang java.sql.Date
        stm.setDate(7, plannedStart != null ? new java.sql.Date(plannedStart.getTime()) : null);
        stm.setDate(8, plannedEnd != null ? new java.sql.Date(plannedEnd.getTime()) : null);
        
        stm.setInt(9, createdBy);
        stm.executeUpdate();

        ResultSet rs = stm.getGeneratedKeys();
        if (rs.next()) {
            return rs.getInt(1);
        }
    } catch (Exception ex) {
        ex.printStackTrace();
    }
    return -1;
}

    // Lấy danh sách Pending Approval
    public List<ChangeRequests> getPendingRequests() {
        return getChangeRequestsByStatus("Pending Approval");
    }

    // Lấy tất cả Change Requests
    public List<ChangeRequests> getAllRequests() {
        List<ChangeRequests> list = new ArrayList<>();
        String sql = "SELECT cr.*, u.FullName AS CreatedByName FROM ChangeRequests cr " +
                     "LEFT JOIN Users u ON cr.CreatedBy = u.Id ORDER BY cr.CreatedAt DESC";
        try (PreparedStatement stm = connection.prepareStatement(sql)) {
            ResultSet rs = stm.executeQuery();
            while (rs.next()) {
                ChangeRequests cr = new ChangeRequests();
                cr.setId(rs.getInt("Id"));
                cr.setTicketNumber(rs.getString("TicketNumber"));
                cr.setTitle(rs.getString("Title"));
                cr.setDescription(rs.getString("Description"));
                cr.setChangeType(rs.getString("ChangeType"));
                cr.setRiskLevel(rs.getString("RiskLevel"));
                cr.setRollbackPlan(rs.getString("RollbackPlan"));
                cr.setStatus(rs.getString("Status"));
                cr.setCreatedBy(rs.getInt("CreatedBy"));
                cr.setCreatedAt(rs.getDate("CreatedAt"));
                cr.setCreatedByName(rs.getString("CreatedByName"));
                list.add(cr);
            }
        } catch (Exception ex) {
            ex.printStackTrace();
        }
        return list;
    }

    // Lấy theo status
    public List<ChangeRequests> getChangeRequestsByStatus(String status) {
        List<ChangeRequests> list = new ArrayList<>();
        String sql = "SELECT cr.*, u.FullName AS CreatedByName FROM ChangeRequests cr " +
                     "LEFT JOIN Users u ON cr.CreatedBy = u.Id " +
                     "WHERE cr.Status = ? ORDER BY cr.CreatedAt DESC";
        try (PreparedStatement stm = connection.prepareStatement(sql)) {
            stm.setString(1, status);
            ResultSet rs = stm.executeQuery();
            while (rs.next()) {
                ChangeRequests cr = new ChangeRequests();
                cr.setId(rs.getInt("Id"));
                cr.setTicketNumber(rs.getString("TicketNumber"));
                cr.setTitle(rs.getString("Title"));
                cr.setDescription(rs.getString("Description"));
                cr.setChangeType(rs.getString("ChangeType"));
                cr.setRiskLevel(rs.getString("RiskLevel"));
                cr.setRollbackPlan(rs.getString("RollbackPlan"));
                cr.setStatus(rs.getString("Status"));
                cr.setCreatedBy(rs.getInt("CreatedBy"));
                cr.setCreatedAt(rs.getDate("CreatedAt"));
                cr.setCreatedByName(rs.getString("CreatedByName"));
                list.add(cr);
            }
        } catch (Exception ex) {
            ex.printStackTrace();
        }
        return list;
    }

    // Update status Change Request
    public boolean updateStatus(int changeId, String newStatus) {
        String sql = "UPDATE ChangeRequests SET Status = ? WHERE Id = ?";
        try (PreparedStatement stm = connection.prepareStatement(sql)) {
            stm.setString(1, newStatus);
            stm.setInt(2, changeId);
            return stm.executeUpdate() > 0;
        } catch (Exception ex) {
            ex.printStackTrace();
            return false;
        }
    }

    // Thêm lịch sử duyệt (khớp tên cột bảng bạn)
    public boolean addApproval(int changeId, int approverId, String decision, String comment) {
        String sql = "INSERT INTO ChangeApprovals (ChangeId, ApproverId, Decision, Comment) " +
                     "VALUES (?, ?, ?, ?)";
        try (PreparedStatement stm = connection.prepareStatement(sql)) {
            stm.setInt(1, changeId);
            stm.setInt(2, approverId);
            stm.setString(3, decision);
            stm.setString(4, comment);
            return stm.executeUpdate() > 0;
        } catch (Exception ex) {
            ex.printStackTrace();
            return false;
        }
    }

    // Lấy lịch sử duyệt cho 1 Change Request
    public List<ChangeApproval> getApprovals(int changeId) {
        List<ChangeApproval> list = new ArrayList<>();
        String sql = "SELECT ca.*, u.FullName AS ApproverName FROM ChangeApprovals ca " +
                     "LEFT JOIN Users u ON ca.ApproverId = u.Id " +
                     "WHERE ca.ChangeId = ? ORDER BY ca.DecidedAt DESC";
        try (PreparedStatement stm = connection.prepareStatement(sql)) {
            stm.setInt(1, changeId);
            ResultSet rs = stm.executeQuery();
            while (rs.next()) {
                ChangeApproval ca = new ChangeApproval();
                ca.setId(rs.getInt("Id"));
                ca.setChangeId(rs.getInt("ChangeId"));
                ca.setApproverId(rs.getInt("ApproverId"));
                ca.setDecision(rs.getString("Decision"));
                ca.setComment(rs.getString("Comment"));
                ca.setDecidedAt(rs.getTimestamp("DecidedAt"));
                ca.setApproverName(rs.getString("ApproverName"));
                list.add(ca);
            }
        } catch (Exception ex) {
            ex.printStackTrace();
        }
        return list;
    }
    // Lấy Change Requests do người dùng cụ thể tạo
public List<ChangeRequests> getMyChangeRequests(int createdBy, String status) {
    List<ChangeRequests> list = new ArrayList<>();
    String sql = "SELECT cr.*, u.FullName AS CreatedByName FROM ChangeRequests cr " +
                 "LEFT JOIN Users u ON cr.CreatedBy = u.Id " +
                 "WHERE cr.CreatedBy = ? ";
    if (status != null && !status.isEmpty() && !"all".equals(status)) {
        sql += "AND cr.Status = ? ";
    }
    sql += "ORDER BY cr.CreatedAt DESC";
    
    try (PreparedStatement stm = connection.prepareStatement(sql)) {
        stm.setInt(1, createdBy);
        if (status != null && !status.isEmpty() && !"all".equals(status)) {
            stm.setString(2, status);
        }
        ResultSet rs = stm.executeQuery();
        while (rs.next()) {
            ChangeRequests cr = new ChangeRequests();
            cr.setId(rs.getInt("Id"));
            cr.setTicketNumber(rs.getString("TicketNumber"));
            cr.setTitle(rs.getString("Title"));
            cr.setDescription(rs.getString("Description"));
            cr.setChangeType(rs.getString("ChangeType"));
            cr.setRiskLevel(rs.getString("RiskLevel"));
            cr.setRollbackPlan(rs.getString("RollbackPlan"));
            cr.setStatus(rs.getString("Status"));
            cr.setCreatedBy(rs.getInt("CreatedBy"));
            cr.setCreatedAt(rs.getDate("CreatedAt"));
            cr.setCreatedByName(rs.getString("CreatedByName"));
            list.add(cr);
        }
    } catch (Exception ex) {
        ex.printStackTrace();
    }
    return list;
}
}
