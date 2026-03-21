package dao;

import Utils.DbContext;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Types;
import java.util.ArrayList;
import java.util.List;
import model.TemporaryRoleRequest;

public class TemporaryRoleRequestDao extends DbContext {

    private static final String BASE_SELECT = """
        SELECT
            tr.Id, tr.UserId, tr.CurrentRole, tr.RequestedRole, tr.Reason,
            tr.DurationMinutes, tr.Status, tr.RequestedAt, tr.ReviewedBy,
            tr.ReviewComment, tr.ReviewedAt, tr.ApprovedAt, tr.ExpiresAt, tr.RevokedAt,
            requester.FullName AS RequesterName,
            reviewer.FullName AS ReviewerName
        FROM TemporaryRoleRequests tr
        INNER JOIN Users requester ON requester.Id = tr.UserId
        LEFT JOIN Users reviewer ON reviewer.Id = tr.ReviewedBy
    """;

    public boolean createRequest(int userId, String currentRole, String requestedRole, int durationMinutes, String reason) {
        if (connection == null) {
            return false;
        }

        String sql = """
            INSERT INTO TemporaryRoleRequests
            (UserId, CurrentRole, RequestedRole, Reason, DurationMinutes, Status, RequestedAt)
            VALUES (?, ?, ?, ?, ?, 'Pending', GETDATE())
        """;

        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, userId);
            ps.setString(2, currentRole);
            ps.setString(3, requestedRole);
            ps.setString(4, reason);
            ps.setInt(5, durationMinutes);
            return ps.executeUpdate() > 0;
        } catch (Exception ex) {
            ex.printStackTrace();
        }
        return false;
    }

    public boolean hasPendingRequest(int userId) {
        if (connection == null || userId <= 0) {
            return false;
        }

        String sql = """
            SELECT COUNT(1)
            FROM TemporaryRoleRequests
            WHERE UserId = ?
              AND Status = 'Pending'
        """;

        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, userId);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                return rs.getInt(1) > 0;
            }
        } catch (Exception ex) {
            ex.printStackTrace();
        }
        return false;
    }

    public TemporaryRoleRequest getLatestRequestByUser(int userId) {
        if (connection == null || userId <= 0) {
            return null;
        }

        String sql = BASE_SELECT + """
            WHERE tr.UserId = ?
            ORDER BY tr.Id DESC
            OFFSET 0 ROWS FETCH NEXT 1 ROWS ONLY
        """;

        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, userId);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                return mapRow(rs);
            }
        } catch (Exception ex) {
            ex.printStackTrace();
        }
        return null;
    }

    public TemporaryRoleRequest getById(int requestId) {
        if (connection == null || requestId <= 0) {
            return null;
        }

        String sql = BASE_SELECT + " WHERE tr.Id = ?";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, requestId);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                return mapRow(rs);
            }
        } catch (Exception ex) {
            ex.printStackTrace();
        }
        return null;
    }

    public List<TemporaryRoleRequest> getRequestsByUser(int userId) {
        List<TemporaryRoleRequest> list = new ArrayList<>();
        if (connection == null || userId <= 0) {
            return list;
        }

        String sql = BASE_SELECT + """
            WHERE tr.UserId = ?
            ORDER BY tr.RequestedAt DESC, tr.Id DESC
        """;

        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, userId);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                list.add(mapRow(rs));
            }
        } catch (Exception ex) {
            ex.printStackTrace();
        }
        return list;
    }

    public List<TemporaryRoleRequest> getPendingRequests() {
        return getByStatus("Pending");
    }

    public List<TemporaryRoleRequest> getAllRequests() {
        List<TemporaryRoleRequest> list = new ArrayList<>();
        if (connection == null) {
            return list;
        }

        String sql = BASE_SELECT + " ORDER BY tr.RequestedAt DESC, tr.Id DESC";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                list.add(mapRow(rs));
            }
        } catch (Exception ex) {
            ex.printStackTrace();
        }
        return list;
    }

    public TemporaryRoleRequest getActiveApprovedRequestForUser(int userId) {
        if (connection == null || userId <= 0) {
            return null;
        }

        String sql = BASE_SELECT + """
            WHERE tr.UserId = ?
              AND tr.Status = 'Approved'
              AND tr.ExpiresAt > GETDATE()
              AND tr.RevokedAt IS NULL
            ORDER BY tr.ExpiresAt DESC, tr.Id DESC
            OFFSET 0 ROWS FETCH NEXT 1 ROWS ONLY
        """;

        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, userId);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                return mapRow(rs);
            }
        } catch (Exception ex) {
            ex.printStackTrace();
        }
        return null;
    }

    public boolean approveRequest(int requestId, int approverId, String comment) {
        if (connection == null || requestId <= 0 || approverId <= 0) {
            return false;
        }

        String sql = """
            UPDATE TemporaryRoleRequests
            SET Status = 'Approved',
                ReviewedBy = ?,
                ReviewComment = ?,
                ReviewedAt = GETDATE(),
                ApprovedAt = GETDATE(),
                ExpiresAt = DATEADD(MINUTE, DurationMinutes, GETDATE()),
                RevokedAt = NULL
            WHERE Id = ?
              AND Status = 'Pending'
        """;

        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, approverId);
            if (comment == null || comment.trim().isEmpty()) {
                ps.setNull(2, Types.NVARCHAR);
            } else {
                ps.setString(2, comment.trim());
            }
            ps.setInt(3, requestId);
            return ps.executeUpdate() > 0;
        } catch (Exception ex) {
            ex.printStackTrace();
        }
        return false;
    }

    public boolean rejectRequest(int requestId, int approverId, String comment) {
        if (connection == null || requestId <= 0 || approverId <= 0) {
            return false;
        }

        String sql = """
            UPDATE TemporaryRoleRequests
            SET Status = 'Rejected',
                ReviewedBy = ?,
                ReviewComment = ?,
                ReviewedAt = GETDATE()
            WHERE Id = ?
              AND Status = 'Pending'
        """;

        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, approverId);
            if (comment == null || comment.trim().isEmpty()) {
                ps.setNull(2, Types.NVARCHAR);
            } else {
                ps.setString(2, comment.trim());
            }
            ps.setInt(3, requestId);
            return ps.executeUpdate() > 0;
        } catch (Exception ex) {
            ex.printStackTrace();
        }
        return false;
    }

    public boolean revokeRequest(int requestId, int approverId, String comment) {
        if (connection == null || requestId <= 0 || approverId <= 0) {
            return false;
        }

        String sql = """
            UPDATE TemporaryRoleRequests
            SET Status = 'Revoked',
                ReviewedBy = ?,
                ReviewComment = ?,
                ReviewedAt = GETDATE(),
                RevokedAt = GETDATE()
            WHERE Id = ?
              AND Status = 'Approved'
              AND ExpiresAt > GETDATE()
              AND RevokedAt IS NULL
        """;

        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, approverId);
            if (comment == null || comment.trim().isEmpty()) {
                ps.setNull(2, Types.NVARCHAR);
            } else {
                ps.setString(2, comment.trim());
            }
            ps.setInt(3, requestId);
            return ps.executeUpdate() > 0;
        } catch (Exception ex) {
            ex.printStackTrace();
        }
        return false;
    }

    public List<TemporaryRoleRequest> expireApprovedRequests() {
        List<TemporaryRoleRequest> expired = new ArrayList<>();
        if (connection == null) {
            return expired;
        }

        String selectSql = BASE_SELECT + """
            WHERE tr.Status = 'Approved'
              AND tr.ExpiresAt IS NOT NULL
              AND tr.ExpiresAt <= GETDATE()
              AND tr.RevokedAt IS NULL
            ORDER BY tr.ExpiresAt ASC
        """;

        String updateSql = """
            UPDATE TemporaryRoleRequests
            SET Status = 'Expired',
                RevokedAt = GETDATE()
            WHERE Id = ?
              AND Status = 'Approved'
              AND ExpiresAt <= GETDATE()
              AND RevokedAt IS NULL
        """;

        try (PreparedStatement selectPs = connection.prepareStatement(selectSql);
             ResultSet rs = selectPs.executeQuery()) {

            List<TemporaryRoleRequest> candidates = new ArrayList<>();
            while (rs.next()) {
                candidates.add(mapRow(rs));
            }

            for (TemporaryRoleRequest item : candidates) {
                try (PreparedStatement updatePs = connection.prepareStatement(updateSql)) {
                    updatePs.setInt(1, item.getId());
                    if (updatePs.executeUpdate() > 0) {
                        item.setStatus("Expired");
                        expired.add(item);
                    }
                }
            }
        } catch (Exception ex) {
            ex.printStackTrace();
        }

        return expired;
    }

    private List<TemporaryRoleRequest> getByStatus(String status) {
        List<TemporaryRoleRequest> list = new ArrayList<>();
        if (connection == null || status == null || status.trim().isEmpty()) {
            return list;
        }

        String sql = BASE_SELECT + """
            WHERE tr.Status = ?
            ORDER BY tr.RequestedAt DESC, tr.Id DESC
        """;
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setString(1, status.trim());
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                list.add(mapRow(rs));
            }
        } catch (Exception ex) {
            ex.printStackTrace();
        }
        return list;
    }

    private TemporaryRoleRequest mapRow(ResultSet rs) throws Exception {
        TemporaryRoleRequest item = new TemporaryRoleRequest();
        item.setId(rs.getInt("Id"));
        item.setUserId(rs.getInt("UserId"));
        item.setCurrentRole(rs.getString("CurrentRole"));
        item.setRequestedRole(rs.getString("RequestedRole"));
        item.setReason(rs.getString("Reason"));
        item.setDurationMinutes(rs.getInt("DurationMinutes"));
        item.setStatus(rs.getString("Status"));
        item.setRequestedAt(rs.getTimestamp("RequestedAt"));
        Object reviewedByObj = rs.getObject("ReviewedBy");
        if (reviewedByObj instanceof Number) {
            item.setReviewedBy(((Number) reviewedByObj).intValue());
        }
        item.setReviewComment(rs.getString("ReviewComment"));
        item.setReviewedAt(rs.getTimestamp("ReviewedAt"));
        item.setApprovedAt(rs.getTimestamp("ApprovedAt"));
        item.setExpiresAt(rs.getTimestamp("ExpiresAt"));
        item.setRevokedAt(rs.getTimestamp("RevokedAt"));
        item.setRequesterName(rs.getString("RequesterName"));
        item.setReviewerName(rs.getString("ReviewerName"));
        return item;
    }
}
