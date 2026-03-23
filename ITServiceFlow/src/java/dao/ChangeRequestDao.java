package dao;

import Utils.DbContext;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.sql.Types;
import java.time.Year;
import java.util.ArrayList;
import java.util.List;
import model.ChangeApproval;
import model.ChangeRequests;
import model.Tickets;

public class ChangeRequestDao extends DbContext {

    private volatile Boolean linkedTicketColumnAvailable;
    private volatile String requestNumberColumn;

    private boolean isLinkedTicketIdAvailable() {
        Boolean cached = linkedTicketColumnAvailable;
        if (cached != null) {
            return cached;
        }
        boolean available = hasColumn("ChangeRequests", "LinkedTicketId");
        linkedTicketColumnAvailable = available;
        return available;
    }

    private String getRequestNumberColumn() {
        String cached = requestNumberColumn;
        if (cached != null) {
            return cached;
        }
        String resolved = hasColumn("ChangeRequests", "RFCNumber") ? "RFCNumber" : "TicketNumber";
        requestNumberColumn = resolved;
        return resolved;
    }

    private String getNextRFCNumber() {
        int year = Year.now().getValue();
        String prefix = "CHG-" + year + "-";
        if (!hasConnection()) {
            return prefix + "001";
        }

        String numberColumn = getRequestNumberColumn();
        String sql = "SELECT MAX(" + numberColumn + ") FROM ChangeRequests WHERE " + numberColumn + " LIKE ?";
        int next = 1;
        try (PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setString(1, prefix + "%");
            ResultSet rs = statement.executeQuery();
            if (rs.next() && rs.getString(1) != null) {
                String last = rs.getString(1);
                next = Integer.parseInt(last.substring(last.lastIndexOf('-') + 1)) + 1;
            }
        } catch (Exception ex) {
            ex.printStackTrace();
        }
        return prefix + String.format("%03d", next);
    }

    public int createChangeRequest(int createdBy, String title, String description,
            String changeType, String riskLevel, String rollbackPlan,
            java.util.Date plannedStart, java.util.Date plannedEnd) {
        return createChangeRequest(createdBy, title, description, changeType,
                riskLevel, rollbackPlan, plannedStart, plannedEnd, null, false);
    }

    public int createChangeRequest(int createdBy, String title, String description,
            String changeType, String riskLevel, String rollbackPlan,
            java.util.Date plannedStart, java.util.Date plannedEnd,
            Integer linkedTicketId, boolean savedAsDraft) {
        if (!hasConnection()) {
            return -1;
        }
        if (riskLevel == null || riskLevel.trim().isEmpty()
                || rollbackPlan == null || rollbackPlan.trim().isEmpty()) {
            return -1;
        }

        String status = savedAsDraft ? "Draft" : "Pending Approval";
        String numberColumn = getRequestNumberColumn();
        String sql;
        if (isLinkedTicketIdAvailable()) {
            sql = "INSERT INTO ChangeRequests "
                    + "(" + numberColumn + ", Title, Description, ChangeType, RiskLevel, RollbackPlan, "
                    + " PlannedStart, PlannedEnd, Status, CreatedBy, LinkedTicketId, CreatedAt) "
                    + "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, GETDATE())";
        } else {
            sql = "INSERT INTO ChangeRequests "
                    + "(" + numberColumn + ", Title, Description, ChangeType, RiskLevel, RollbackPlan, "
                    + " PlannedStart, PlannedEnd, Status, CreatedBy, CreatedAt) "
                    + "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, GETDATE())";
        }

        try (PreparedStatement statement = connection.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            statement.setString(1, getNextRFCNumber());
            statement.setString(2, title == null ? null : title.trim());
            statement.setString(3, description == null ? null : description.trim());
            statement.setString(4, changeType);
            statement.setString(5, riskLevel);
            statement.setString(6, rollbackPlan.trim());
            statement.setDate(7, plannedStart == null ? null : new java.sql.Date(plannedStart.getTime()));
            statement.setDate(8, plannedEnd == null ? null : new java.sql.Date(plannedEnd.getTime()));
            statement.setString(9, status);
            statement.setInt(10, createdBy);

            if (isLinkedTicketIdAvailable()) {
                if (linkedTicketId == null) {
                    statement.setNull(11, Types.INTEGER);
                } else {
                    statement.setInt(11, linkedTicketId);
                }
            }

            statement.executeUpdate();
            ResultSet keys = statement.getGeneratedKeys();
            return keys.next() ? keys.getInt(1) : -1;
        } catch (Exception ex) {
            ex.printStackTrace();
            return -1;
        }
    }

    public boolean submitDraft(int changeId, int requestorId) {
        if (!hasConnection()) {
            return false;
        }
        String sql = "UPDATE ChangeRequests SET Status = 'Pending Approval' "
                + "WHERE Id = ? AND CreatedBy = ? AND Status = 'Draft'";
        try (PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setInt(1, changeId);
            statement.setInt(2, requestorId);
            return statement.executeUpdate() > 0;
        } catch (Exception ex) {
            ex.printStackTrace();
            return false;
        }
    }

    public ChangeRequests getById(int id) {
        if (!hasConnection()) {
            return null;
        }

        String numberColumn = getRequestNumberColumn();
        String sql;
        if (isLinkedTicketIdAvailable()) {
            sql = "SELECT cr." + numberColumn + " AS RFCNumber, cr.*, u.FullName AS CreatedByName, "
                    + " t.TicketNumber AS LinkedTicketNumber, t.Title AS LinkedTicketTitle, "
                    + " (SELECT TOP 1 ca.Comment FROM ChangeApprovals ca "
                    + "  WHERE ca.ChangeId = cr.Id ORDER BY ca.DecidedAt DESC) AS ApproverComment, "
                    + " (SELECT TOP 1 ca.DecidedAt FROM ChangeApprovals ca "
                    + "  WHERE ca.ChangeId = cr.Id ORDER BY ca.DecidedAt DESC) AS ApprovedAt "
                    + "FROM ChangeRequests cr "
                    + "LEFT JOIN Users u ON cr.CreatedBy = u.Id "
                    + "LEFT JOIN Tickets t ON cr.LinkedTicketId = t.Id "
                    + "WHERE cr.Id = ?";
        } else {
            sql = "SELECT cr." + numberColumn + " AS RFCNumber, cr.*, u.FullName AS CreatedByName, "
                    + " NULL AS LinkedTicketNumber, NULL AS LinkedTicketTitle, "
                    + " (SELECT TOP 1 ca.Comment FROM ChangeApprovals ca "
                    + "  WHERE ca.ChangeId = cr.Id ORDER BY ca.DecidedAt DESC) AS ApproverComment, "
                    + " (SELECT TOP 1 ca.DecidedAt FROM ChangeApprovals ca "
                    + "  WHERE ca.ChangeId = cr.Id ORDER BY ca.DecidedAt DESC) AS ApprovedAt "
                    + "FROM ChangeRequests cr "
                    + "LEFT JOIN Users u ON cr.CreatedBy = u.Id "
                    + "WHERE cr.Id = ?";
        }

        try (PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setInt(1, id);
            ResultSet rs = statement.executeQuery();
            if (rs.next()) {
                return mapCR(rs);
            }
        } catch (Exception ex) {
            ex.printStackTrace();
        }
        return null;
    }

    public List<ChangeRequests> getPendingRequests() {
        return getByStatusFull("Pending Approval");
    }

    public List<ChangeRequests> getAllRequests() {
        List<ChangeRequests> list = new ArrayList<>();
        if (!hasConnection()) {
            return list;
        }

        String numberColumn = getRequestNumberColumn();
        String sql;
        if (isLinkedTicketIdAvailable()) {
            sql = "SELECT cr." + numberColumn + " AS RFCNumber, cr.*, u.FullName AS CreatedByName, "
                    + " t.TicketNumber AS LinkedTicketNumber, t.Title AS LinkedTicketTitle, "
                    + " (SELECT TOP 1 ca.Comment FROM ChangeApprovals ca WHERE ca.ChangeId = cr.Id ORDER BY ca.DecidedAt DESC) AS ApproverComment, "
                    + " (SELECT TOP 1 ca.DecidedAt FROM ChangeApprovals ca WHERE ca.ChangeId = cr.Id ORDER BY ca.DecidedAt DESC) AS ApprovedAt "
                    + "FROM ChangeRequests cr "
                    + "LEFT JOIN Users u ON cr.CreatedBy = u.Id "
                    + "LEFT JOIN Tickets t ON cr.LinkedTicketId = t.Id "
                    + "ORDER BY cr.CreatedAt DESC";
        } else {
            sql = "SELECT cr." + numberColumn + " AS RFCNumber, cr.*, u.FullName AS CreatedByName, "
                    + " NULL AS LinkedTicketNumber, NULL AS LinkedTicketTitle, "
                    + " (SELECT TOP 1 ca.Comment FROM ChangeApprovals ca WHERE ca.ChangeId = cr.Id ORDER BY ca.DecidedAt DESC) AS ApproverComment, "
                    + " (SELECT TOP 1 ca.DecidedAt FROM ChangeApprovals ca WHERE ca.ChangeId = cr.Id ORDER BY ca.DecidedAt DESC) AS ApprovedAt "
                    + "FROM ChangeRequests cr "
                    + "LEFT JOIN Users u ON cr.CreatedBy = u.Id "
                    + "ORDER BY cr.CreatedAt DESC";
        }

        try (PreparedStatement statement = connection.prepareStatement(sql)) {
            ResultSet rs = statement.executeQuery();
            while (rs.next()) {
                list.add(mapCR(rs));
            }
        } catch (Exception ex) {
            ex.printStackTrace();
        }
        return list;
    }

    private List<ChangeRequests> getByStatusFull(String status) {
        List<ChangeRequests> list = new ArrayList<>();
        if (!hasConnection()) {
            return list;
        }

        String numberColumn = getRequestNumberColumn();
        String sql;
        if (isLinkedTicketIdAvailable()) {
            sql = "SELECT cr." + numberColumn + " AS RFCNumber, cr.*, u.FullName AS CreatedByName, "
                    + " t.TicketNumber AS LinkedTicketNumber, t.Title AS LinkedTicketTitle "
                    + "FROM ChangeRequests cr "
                    + "LEFT JOIN Users u ON cr.CreatedBy = u.Id "
                    + "LEFT JOIN Tickets t ON cr.LinkedTicketId = t.Id "
                    + "WHERE cr.Status = ? ORDER BY cr.CreatedAt DESC";
        } else {
            sql = "SELECT cr." + numberColumn + " AS RFCNumber, cr.*, u.FullName AS CreatedByName, "
                    + " NULL AS LinkedTicketNumber, NULL AS LinkedTicketTitle "
                    + "FROM ChangeRequests cr "
                    + "LEFT JOIN Users u ON cr.CreatedBy = u.Id "
                    + "WHERE cr.Status = ? ORDER BY cr.CreatedAt DESC";
        }

        try (PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setString(1, status);
            ResultSet rs = statement.executeQuery();
            while (rs.next()) {
                list.add(mapCR(rs));
            }
        } catch (Exception ex) {
            ex.printStackTrace();
        }
        return list;
    }

    public List<ChangeRequests> getMyChangeRequests(int createdBy, String status) {
        List<ChangeRequests> list = new ArrayList<>();
        if (!hasConnection()) {
            return list;
        }

        String numberColumn = getRequestNumberColumn();
        StringBuilder sql = new StringBuilder();
        if (isLinkedTicketIdAvailable()) {
            sql.append("SELECT cr.").append(numberColumn).append(" AS RFCNumber, cr.*, u.FullName AS CreatedByName, ")
                    .append(" t.TicketNumber AS LinkedTicketNumber, t.Title AS LinkedTicketTitle ")
                    .append("FROM ChangeRequests cr ")
                    .append("LEFT JOIN Users u ON cr.CreatedBy = u.Id ")
                    .append("LEFT JOIN Tickets t ON cr.LinkedTicketId = t.Id ")
                    .append("WHERE cr.CreatedBy = ? ");
        } else {
            sql.append("SELECT cr.").append(numberColumn).append(" AS RFCNumber, cr.*, u.FullName AS CreatedByName, ")
                    .append(" NULL AS LinkedTicketNumber, NULL AS LinkedTicketTitle ")
                    .append("FROM ChangeRequests cr ")
                    .append("LEFT JOIN Users u ON cr.CreatedBy = u.Id ")
                    .append("WHERE cr.CreatedBy = ? ");
        }

        if (status != null && !status.isEmpty() && !"all".equals(status)) {
            sql.append("AND cr.Status = ? ");
        }
        sql.append("ORDER BY cr.CreatedAt DESC");

        try (PreparedStatement statement = connection.prepareStatement(sql.toString())) {
            statement.setInt(1, createdBy);
            if (status != null && !status.isEmpty() && !"all".equals(status)) {
                statement.setString(2, status);
            }
            ResultSet rs = statement.executeQuery();
            while (rs.next()) {
                list.add(mapCR(rs));
            }
        } catch (Exception ex) {
            ex.printStackTrace();
        }
        return list;
    }

    public boolean updateStatus(int changeId, String newStatus) {
        if (!hasConnection()) {
            return false;
        }
        String sql = "UPDATE ChangeRequests SET Status = ? WHERE Id = ?";
        try (PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setString(1, newStatus);
            statement.setInt(2, changeId);
            return statement.executeUpdate() > 0;
        } catch (Exception ex) {
            ex.printStackTrace();
            return false;
        }
    }

    public boolean addApproval(int changeId, int approverId, String decision, String comment) {
        if (!hasConnection()) {
            return false;
        }
        String sql = "INSERT INTO ChangeApprovals (ChangeId, ApproverId, Decision, Comment, DecidedAt) "
                + "VALUES (?, ?, ?, ?, GETDATE())";
        try (PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setInt(1, changeId);
            statement.setInt(2, approverId);
            statement.setString(3, decision);
            statement.setString(4, comment);
            return statement.executeUpdate() > 0;
        } catch (Exception ex) {
            ex.printStackTrace();
            return false;
        }
    }

    public List<ChangeApproval> getApprovals(int changeId) {
        List<ChangeApproval> list = new ArrayList<>();
        if (!hasConnection()) {
            return list;
        }

        String sql = "SELECT ca.*, u.FullName AS ApproverName FROM ChangeApprovals ca "
                + "LEFT JOIN Users u ON ca.ApproverId = u.Id "
                + "WHERE ca.ChangeId = ? ORDER BY ca.DecidedAt DESC";
        try (PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setInt(1, changeId);
            ResultSet rs = statement.executeQuery();
            while (rs.next()) {
                ChangeApproval approval = new ChangeApproval();
                approval.setId(rs.getInt("Id"));
                approval.setChangeId(rs.getInt("ChangeId"));
                approval.setApproverId(rs.getInt("ApproverId"));
                approval.setDecision(rs.getString("Decision"));
                approval.setComment(rs.getString("Comment"));
                approval.setDecidedAt(rs.getTimestamp("DecidedAt"));
                approval.setApproverName(rs.getString("ApproverName"));
                list.add(approval);
            }
        } catch (Exception ex) {
            ex.printStackTrace();
        }
        return list;
    }

    public List<Tickets> getAssignedTicketsForRFC(int itSupportId) {
        List<Tickets> list = new ArrayList<>();
        if (!hasConnection()) {
            return list;
        }

        String sql = "SELECT t.Id, t.TicketNumber, t.Title, t.Status, t.TicketType "
                + "FROM Tickets t "
                + "WHERE (t.AssignedTo = ? OR t.CreatedBy = ?) AND t.Status != 'New' "
                + "ORDER BY t.UpdatedAt DESC";
        try (PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setInt(1, itSupportId);
            statement.setInt(2, itSupportId);
            ResultSet rs = statement.executeQuery();
            while (rs.next()) {
                Tickets ticket = new Tickets();
                ticket.setId(rs.getInt("Id"));
                ticket.setTicketNumber(rs.getString("TicketNumber"));
                ticket.setTitle(rs.getString("Title"));
                ticket.setStatus(rs.getString("Status"));
                ticket.setTicketType(rs.getString("TicketType"));
                list.add(ticket);
            }
        } catch (Exception ex) {
            ex.printStackTrace();
        }
        return list;
    }

    public List<model.Users> getAllManagers() {
        List<model.Users> list = new ArrayList<>();
        if (!hasConnection()) {
            return list;
        }

        String sql = "SELECT Id, FullName, Email FROM Users WHERE Role = 'Manager' AND IsActive = 1";
        try (PreparedStatement statement = connection.prepareStatement(sql)) {
            ResultSet rs = statement.executeQuery();
            while (rs.next()) {
                model.Users user = new model.Users();
                user.setId(rs.getInt("Id"));
                user.setFullName(rs.getString("FullName"));
                user.setEmail(rs.getString("Email"));
                list.add(user);
            }
        } catch (Exception ex) {
            ex.printStackTrace();
        }
        return list;
    }

    private ChangeRequests mapCR(ResultSet rs) throws SQLException {
        ChangeRequests request = new ChangeRequests();
        request.setId(rs.getInt("Id"));

        String number = null;
        try {
            number = rs.getString("RFCNumber");
        } catch (Exception ignored) {
        }
        if (number == null) {
            try {
                number = rs.getString("TicketNumber");
            } catch (Exception ignored) {
            }
        }
        request.setRfcNumber(number);

        request.setTitle(rs.getString("Title"));
        request.setDescription(rs.getString("Description"));
        request.setChangeType(rs.getString("ChangeType"));
        request.setRiskLevel(rs.getString("RiskLevel"));
        request.setRollbackPlan(rs.getString("RollbackPlan"));
        request.setPlannedStart(rs.getDate("PlannedStart"));
        request.setPlannedEnd(rs.getDate("PlannedEnd"));
        request.setStatus(rs.getString("Status"));
        request.setCreatedBy(rs.getInt("CreatedBy"));
        request.setCreatedAt(rs.getTimestamp("CreatedAt"));

        try {
            request.setLinkedTicketId((Integer) rs.getObject("LinkedTicketId"));
        } catch (Exception ignored) {
        }
        try {
            request.setCreatedByName(rs.getString("CreatedByName"));
        } catch (Exception ignored) {
        }
        try {
            request.setLinkedTicketNumber(rs.getString("LinkedTicketNumber"));
        } catch (Exception ignored) {
        }
        try {
            request.setLinkedTicketTitle(rs.getString("LinkedTicketTitle"));
        } catch (Exception ignored) {
        }
        try {
            request.setApproverComment(rs.getString("ApproverComment"));
        } catch (Exception ignored) {
        }
        try {
            request.setApprovedAt(rs.getTimestamp("ApprovedAt"));
        } catch (Exception ignored) {
        }

        return request;
    }
}
