package dao;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;
import model.ChangeApproval;
import model.ChangeRequests;
import model.Tickets;
import Utils.DbContext;
import java.time.Year;

public class ChangeRequestDao extends DbContext {

     // Cache schema check để tránh query sys.columns lặp lại nhiều lần
    private Boolean linkedTicketColumnExists = null;
    private String requestNumberColumn = null;

    private boolean hasChangeRequestColumn(String columnName) {
        String sql = "SELECT 1 FROM sys.columns "
                + "WHERE object_id = OBJECT_ID('dbo.ChangeRequests') "
                + "AND name = ?";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setString(1, columnName);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next();
            }
        } catch (Exception ex) {
            return false;
        }
    }

    private boolean hasLinkedTicketIdColumn() {
        if (linkedTicketColumnExists == null) {
            linkedTicketColumnExists = hasChangeRequestColumn("LinkedTicketId");
        }
        return linkedTicketColumnExists;
    }

    private String getRequestNumberColumn() {
        if (requestNumberColumn == null) {
            requestNumberColumn = hasChangeRequestColumn("RFCNumber")
                    ? "RFCNumber"
                    : "TicketNumber";
        }
        return requestNumberColumn;
    }
    // ── Sinh RFCNumber tự động ────────────────────────────────────────────────
    private String getNextRFCNumber() {
        int year = Year.now().getValue();
        String prefix = "CHG-" + year + "-";
        String sql = "SELECT MAX(RFCNumber) FROM ChangeRequests WHERE RFCNumber LIKE ?";
        int next = 1;
        try (PreparedStatement stm = connection.prepareStatement(sql)) {
            stm.setString(1, prefix + "%");
            ResultSet rs = stm.executeQuery();
            if (rs.next() && rs.getString(1) != null) {
                String last = rs.getString(1);
                next = Integer.parseInt(last.substring(last.lastIndexOf('-') + 1)) + 1;
            }
        } catch (SQLException ex) { ex.printStackTrace(); }
        return prefix + String.format("%03d", next);
    }

    // ── OLD signature (8 params) — backward compat ───────────────────────────
    public int createChangeRequest(int createdBy, String title, String description,
                                   String changeType, String riskLevel, String rollbackPlan,
                                   java.util.Date plannedStart, java.util.Date plannedEnd) {
        return createChangeRequest(createdBy, title, description, changeType,
                riskLevel, rollbackPlan, plannedStart, plannedEnd, null, false);
    }

    // ── NEW signature (10 params) ─────────────────────────────────────────────
    public int createChangeRequest(int createdBy, String title, String description,
                                   String changeType, String riskLevel, String rollbackPlan,
                                   java.util.Date plannedStart, java.util.Date plannedEnd,
                                   Integer linkedTicketId, boolean savedAsDraft) {
        if (riskLevel == null || riskLevel.trim().isEmpty()
                || rollbackPlan == null || rollbackPlan.trim().isEmpty()) return -1;

        String status = savedAsDraft ? "Draft" : "Pending Approval";
        String sql = "INSERT INTO ChangeRequests "
                + "(RFCNumber, Title, Description, ChangeType, RiskLevel, RollbackPlan, "
                + " PlannedStart, PlannedEnd, Status, CreatedBy, LinkedTicketId, CreatedAt) "
                + "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, GETDATE())";
        try (PreparedStatement stm = connection.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            stm.setString(1, getNextRFCNumber());
            stm.setString(2, title.trim());
            stm.setString(3, description != null ? description.trim() : null);
            stm.setString(4, changeType);
            stm.setString(5, riskLevel);
            stm.setString(6, rollbackPlan.trim());
            stm.setDate(7, plannedStart != null ? new java.sql.Date(plannedStart.getTime()) : null);
            stm.setDate(8, plannedEnd   != null ? new java.sql.Date(plannedEnd.getTime())   : null);
            stm.setString(9, status);
            stm.setInt(10, createdBy);
            if (linkedTicketId != null) stm.setInt(11, linkedTicketId);
            else stm.setNull(11, Types.INTEGER);
            stm.executeUpdate();
            ResultSet keys = stm.getGeneratedKeys();
            return keys.next() ? keys.getInt(1) : -1;
        } catch (Exception ex) { ex.printStackTrace(); return -1; }
    }

    // ── Submit Draft → Pending Approval ──────────────────────────────────────
    public boolean submitDraft(int changeId, int requestorId) {
        String sql = "UPDATE ChangeRequests SET Status = 'Pending Approval' "
                + "WHERE Id = ? AND CreatedBy = ? AND Status = 'Draft'";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, changeId); ps.setInt(2, requestorId);
            return ps.executeUpdate() > 0;
        } catch (Exception ex) { ex.printStackTrace(); return false; }
    }

    // ── Lấy 1 RFC theo Id (THÊM MỚI — dùng cho trang detail) ────────────────
    public ChangeRequests getById(int id) {
        String sql = "SELECT cr.*, u.FullName AS CreatedByName, "
                + " t.TicketNumber AS LinkedTicketNumber, t.Title AS LinkedTicketTitle, "
                + " (SELECT TOP 1 ca.Comment    FROM ChangeApprovals ca "
                + "  WHERE ca.ChangeId = cr.Id  ORDER BY ca.DecidedAt DESC) AS ApproverComment, "
                + " (SELECT TOP 1 ca.DecidedAt  FROM ChangeApprovals ca "
                + "  WHERE ca.ChangeId = cr.Id  ORDER BY ca.DecidedAt DESC) AS ApprovedAt "
                + "FROM ChangeRequests cr "
                + "LEFT JOIN Users u  ON cr.CreatedBy    = u.Id "
                + "LEFT JOIN Tickets t ON cr.LinkedTicketId = t.Id "
                + "WHERE cr.Id = ?";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, id);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) return mapCR(rs);
        } catch (Exception ex) { ex.printStackTrace(); }
        return null;
    }

    // ── Lấy Pending Approval ─────────────────────────────────────────────────
    public List<ChangeRequests> getPendingRequests() {
        return getByStatusFull("Pending Approval");
    }

    // ── Tất cả RFC ───────────────────────────────────────────────────────────
    public List<ChangeRequests> getAllRequests() {
        List<ChangeRequests> list = new ArrayList<>();
        String sql = "SELECT cr.*, u.FullName AS CreatedByName, "
                + " t.TicketNumber AS LinkedTicketNumber, t.Title AS LinkedTicketTitle, "
                + " (SELECT TOP 1 ca.Comment   FROM ChangeApprovals ca WHERE ca.ChangeId = cr.Id ORDER BY ca.DecidedAt DESC) AS ApproverComment, "
                + " (SELECT TOP 1 ca.DecidedAt FROM ChangeApprovals ca WHERE ca.ChangeId = cr.Id ORDER BY ca.DecidedAt DESC) AS ApprovedAt "
                + "FROM ChangeRequests cr "
                + "LEFT JOIN Users u  ON cr.CreatedBy     = u.Id "
                + "LEFT JOIN Tickets t ON cr.LinkedTicketId = t.Id "
                + "ORDER BY cr.CreatedAt DESC";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ResultSet rs = ps.executeQuery();
            while (rs.next()) list.add(mapCR(rs));
        } catch (Exception ex) { ex.printStackTrace(); }
        return list;
    }

    private List<ChangeRequests> getByStatusFull(String status) {
        List<ChangeRequests> list = new ArrayList<>();
        String sql = "SELECT cr.*, u.FullName AS CreatedByName, "
                + " t.TicketNumber AS LinkedTicketNumber, t.Title AS LinkedTicketTitle "
                + "FROM ChangeRequests cr "
                + "LEFT JOIN Users u  ON cr.CreatedBy     = u.Id "
                + "LEFT JOIN Tickets t ON cr.LinkedTicketId = t.Id "
                + "WHERE cr.Status = ? ORDER BY cr.CreatedAt DESC";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setString(1, status);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) list.add(mapCR(rs));
        } catch (Exception ex) { ex.printStackTrace(); }
        return list;
    }

    // ── RFC của 1 IT Support ─────────────────────────────────────────────────
    public List<ChangeRequests> getMyChangeRequests(int createdBy, String status) {
        List<ChangeRequests> list = new ArrayList<>();
        StringBuilder sql = new StringBuilder(
            "SELECT cr.*, u.FullName AS CreatedByName, "
            + " t.TicketNumber AS LinkedTicketNumber, t.Title AS LinkedTicketTitle "
            + "FROM ChangeRequests cr "
            + "LEFT JOIN Users u  ON cr.CreatedBy     = u.Id "
            + "LEFT JOIN Tickets t ON cr.LinkedTicketId = t.Id "
            + "WHERE cr.CreatedBy = ? "
        );
        if (status != null && !status.isEmpty() && !"all".equals(status))
            sql.append("AND cr.Status = ? ");
        sql.append("ORDER BY cr.CreatedAt DESC");
        try (PreparedStatement stm = connection.prepareStatement(sql.toString())) {
            stm.setInt(1, createdBy);
            if (status != null && !status.isEmpty() && !"all".equals(status))
                stm.setString(2, status);
            ResultSet rs = stm.executeQuery();
            while (rs.next()) list.add(mapCR(rs));
        } catch (Exception ex) { ex.printStackTrace(); }
        return list;
    }


    // ── Tìm kiếm RFC cho Manager (keyword + status tab) ──────────────────────
    public List<ChangeRequests> searchRequests(String keyword, String tab) {
        List<ChangeRequests> list = new ArrayList<>();
        boolean hasLinked = hasLinkedTicketIdColumn();
        String numberColumn = getRequestNumberColumn();
        String linkedSelect = hasLinked
                ? " t.TicketNumber AS LinkedTicketNumber, t.Title AS LinkedTicketTitle, "
                : " NULL AS LinkedTicketNumber, NULL AS LinkedTicketTitle, ";
        String linkedJoin = hasLinked ? "LEFT JOIN Tickets t ON cr.LinkedTicketId = t.Id " : "";

        StringBuilder sql = new StringBuilder(
            "SELECT cr." + numberColumn + " AS RFCNumber, cr.*, u.FullName AS CreatedByName, "
            + linkedSelect
            + " (SELECT TOP 1 ca.Comment   FROM ChangeApprovals ca WHERE ca.ChangeId = cr.Id ORDER BY ca.DecidedAt DESC) AS ApproverComment, "
            + " (SELECT TOP 1 ca.DecidedAt FROM ChangeApprovals ca WHERE ca.ChangeId = cr.Id ORDER BY ca.DecidedAt DESC) AS ApprovedAt "
            + "FROM ChangeRequests cr "
            + "LEFT JOIN Users u ON cr.CreatedBy = u.Id "
            + linkedJoin
            + "WHERE 1=1 "
        );

        boolean hasKeyword = keyword != null && !keyword.trim().isEmpty();
        boolean hasStatus  = tab != null && !tab.isEmpty() && !"all".equals(tab);

        if (hasKeyword) sql.append("AND (cr.Title LIKE ? OR u.FullName LIKE ? OR cr." + numberColumn + " LIKE ?) ");
        if (hasStatus)  sql.append("AND cr.Status = ? ");
        sql.append("ORDER BY cr.CreatedAt DESC");

        try (PreparedStatement ps = connection.prepareStatement(sql.toString())) {
            int idx = 1;
            if (hasKeyword) {
                String like = "%" + keyword.trim() + "%";
                ps.setString(idx++, like);
                ps.setString(idx++, like);
                ps.setString(idx++, like);
            }
            if (hasStatus) ps.setString(idx, "Pending Approval".equals(tab) ? "Pending Approval" : tab);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) list.add(mapCR(rs));
        } catch (Exception ex) { ex.printStackTrace(); }
        return list;
    }

    // ── Tìm kiếm RFC của IT Support (keyword + status) ───────────────────────
    public List<ChangeRequests> searchMyRequests(int createdBy, String keyword, String status) {
        List<ChangeRequests> list = new ArrayList<>();
        boolean hasLinked = hasLinkedTicketIdColumn();
        String numberColumn = getRequestNumberColumn();
        String linkedSelect = hasLinked
                ? " t.TicketNumber AS LinkedTicketNumber, t.Title AS LinkedTicketTitle "
                : " NULL AS LinkedTicketNumber, NULL AS LinkedTicketTitle ";
        String linkedJoin = hasLinked ? "LEFT JOIN Tickets t ON cr.LinkedTicketId = t.Id " : "";

        StringBuilder sql = new StringBuilder(
            "SELECT cr." + numberColumn + " AS RFCNumber, cr.*, u.FullName AS CreatedByName, "
            + linkedSelect
            + "FROM ChangeRequests cr "
            + "LEFT JOIN Users u ON cr.CreatedBy = u.Id "
            + linkedJoin
            + "WHERE cr.CreatedBy = ? "
        );

        boolean hasKeyword = keyword != null && !keyword.trim().isEmpty();
        boolean hasStatus  = status != null && !status.isEmpty() && !"all".equals(status);

        if (hasKeyword) sql.append("AND (cr.Title LIKE ? OR cr." + numberColumn + " LIKE ?) ");
        if (hasStatus)  sql.append("AND cr.Status = ? ");
        sql.append("ORDER BY cr.CreatedAt DESC");

        try (PreparedStatement ps = connection.prepareStatement(sql.toString())) {
            int idx = 1;
            ps.setInt(idx++, createdBy);
            if (hasKeyword) {
                String like = "%" + keyword.trim() + "%";
                ps.setString(idx++, like);
                ps.setString(idx++, like);
            }
            if (hasStatus) ps.setString(idx, status);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) list.add(mapCR(rs));
        } catch (Exception ex) { ex.printStackTrace(); }
        return list;
    }

    // ── Update status ─────────────────────────────────────────────────────────
    public boolean updateStatus(int changeId, String newStatus) {
        String sql = "UPDATE ChangeRequests SET Status = ? WHERE Id = ?";
        try (PreparedStatement stm = connection.prepareStatement(sql)) {
            stm.setString(1, newStatus); stm.setInt(2, changeId);
            return stm.executeUpdate() > 0;
        } catch (Exception ex) { ex.printStackTrace(); return false; }
    }

    // ── Thêm approval record ──────────────────────────────────────────────────
    public boolean addApproval(int changeId, int approverId, String decision, String comment) {
        String sql = "INSERT INTO ChangeApprovals (ChangeId, ApproverId, Decision, Comment, DecidedAt) "
                + "VALUES (?, ?, ?, ?, GETDATE())";
        try (PreparedStatement stm = connection.prepareStatement(sql)) {
            stm.setInt(1, changeId); stm.setInt(2, approverId);
            stm.setString(3, decision); stm.setString(4, comment);
            return stm.executeUpdate() > 0;
        } catch (Exception ex) { ex.printStackTrace(); return false; }
    }

    // ── Lịch sử duyệt ────────────────────────────────────────────────────────
    public List<ChangeApproval> getApprovals(int changeId) {
        List<ChangeApproval> list = new ArrayList<>();
        String sql = "SELECT ca.*, u.FullName AS ApproverName FROM ChangeApprovals ca "
                + "LEFT JOIN Users u ON ca.ApproverId = u.Id "
                + "WHERE ca.ChangeId = ? ORDER BY ca.DecidedAt DESC";
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
        } catch (Exception ex) { ex.printStackTrace(); }
        return list;
    }

    // ── Tickets để liên kết RFC ───────────────────────────────────────────────
    public List<Tickets> getAssignedTicketsForRFC(int itSupportId) {
        List<Tickets> list = new ArrayList<>();
        String sql = "SELECT t.Id, t.TicketNumber, t.Title, t.Status, t.TicketType "
                + "FROM Tickets t "
                + "WHERE (t.AssignedTo = ? OR t.CreatedBy = ?) AND t.Status != 'New' "
                + "ORDER BY t.UpdatedAt DESC";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, itSupportId); ps.setInt(2, itSupportId);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                Tickets t = new Tickets();
                t.setId(rs.getInt("Id"));
                t.setTicketNumber(rs.getString("TicketNumber"));
                t.setTitle(rs.getString("Title"));
                t.setStatus(rs.getString("Status"));
                t.setTicketType(rs.getString("TicketType"));
                list.add(t);
            }
        } catch (Exception ex) { ex.printStackTrace(); }
        return list;
    }

    // ── Tất cả Manager ───────────────────────────────────────────────────────
    public List<model.Users> getAllManagers() {
        List<model.Users> list = new ArrayList<>();
        String sql = "SELECT Id, FullName, Email FROM Users WHERE Role = 'Manager' AND IsActive = 1";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                model.Users u = new model.Users();
                u.setId(rs.getInt("Id"));
                u.setFullName(rs.getString("FullName"));
                u.setEmail(rs.getString("Email"));
                list.add(u);
            }
        } catch (Exception ex) { ex.printStackTrace(); }
        return list;
    }

    // ── Helper map ResultSet → ChangeRequests ─────────────────────────────────
    private ChangeRequests mapCR(ResultSet rs) throws SQLException {
        ChangeRequests cr = new ChangeRequests();
        cr.setId(rs.getInt("Id"));
        // Hỗ trợ cả model cũ (setTicketNumber) và mới (setRfcNumber)
        try { cr.setRfcNumber(rs.getString("RFCNumber")); }
        catch (Exception e) { try { cr.setTicketNumber(rs.getString("RFCNumber")); } catch (Exception ignored) {} }
        cr.setTitle(rs.getString("Title"));
        cr.setDescription(rs.getString("Description"));
        cr.setChangeType(rs.getString("ChangeType"));
        cr.setRiskLevel(rs.getString("RiskLevel"));
        cr.setRollbackPlan(rs.getString("RollbackPlan"));
        cr.setPlannedStart(rs.getDate("PlannedStart"));
        cr.setPlannedEnd(rs.getDate("PlannedEnd"));
        cr.setStatus(rs.getString("Status"));
        cr.setCreatedBy(rs.getInt("CreatedBy"));
        cr.setCreatedAt(rs.getTimestamp("CreatedAt"));
        try { cr.setLinkedTicketId((Integer) rs.getObject("LinkedTicketId")); }  catch (Exception e) {}
        try { cr.setCreatedByName(rs.getString("CreatedByName")); }               catch (Exception e) {}
        try { cr.setLinkedTicketNumber(rs.getString("LinkedTicketNumber")); }     catch (Exception e) {}
        try { cr.setLinkedTicketTitle(rs.getString("LinkedTicketTitle")); }       catch (Exception e) {}
        try { cr.setApproverComment(rs.getString("ApproverComment")); }           catch (Exception e) {}
        try { cr.setApprovedAt(rs.getTimestamp("ApprovedAt")); }                  catch (Exception e) {}
        return cr;
    }
}