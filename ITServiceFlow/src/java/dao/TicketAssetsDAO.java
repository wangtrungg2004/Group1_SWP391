package dao;

import Utils.DbContext;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import model.Assets;

public class TicketAssetsDAO extends DbContext {

    // Lấy danh sách CI (Assets) đã liên kết với một Ticket
    public List<Assets> getLinkedCIsByTicketId(int ticketId) {
        List<Assets> linkedCIs = new ArrayList<>();
        String sql = "SELECT a.* " +
                     "FROM TicketAssets ta " +
                     "INNER JOIN Assets a ON ta.AssetId = a.Id " +
                     "WHERE ta.TicketId = ? " +
                     "ORDER BY a.AssetTag";

        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, ticketId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Assets ci = new Assets();
                    ci.setId(rs.getInt("Id"));
                    ci.setAssetTag(rs.getString("AssetTag"));
                    ci.setName(rs.getString("Name"));
                    ci.setAssetType(rs.getString("AssetType"));
                    ci.setStatus(rs.getString("Status"));
                    ci.setLocationId(rs.getInt("LocationId"));
                    ci.setOwnerId(rs.getInt("OwnerId"));
                    ci.setCreatedAt(rs.getTimestamp("CreatedAt"));
                    linkedCIs.add(ci);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return linkedCIs;
    }

    // Thêm liên kết mới giữa Ticket và CI (Asset)
    public boolean addLink(int ticketId, int assetId) {
        if (isLinked(ticketId, assetId)) {
            return false;
        }

        String sql = "INSERT INTO TicketAssets (TicketId, AssetId) VALUES (?, ?)";

        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, ticketId);
            ps.setInt(2, assetId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    // Xóa liên kết giữa Ticket và CI
    public boolean removeLink(int ticketId, int assetId) {
        String sql = "DELETE FROM TicketAssets WHERE TicketId = ? AND AssetId = ?";

        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, ticketId);
            ps.setInt(2, assetId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    // Kiểm tra xem CI đã được liên kết với Ticket chưa
    public boolean isLinked(int ticketId, int assetId) {
        String sql = "SELECT COUNT(*) FROM TicketAssets WHERE TicketId = ? AND AssetId = ?";

        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, ticketId);
            ps.setInt(2, assetId);

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1) > 0;
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    // Lấy danh sách Ticket liên quan đến một CI
    public List<Integer> getTicketIdsByAssetId(int assetId) {
        List<Integer> ticketIds = new ArrayList<>();
        String sql = "SELECT TicketId FROM TicketAssets WHERE AssetId = ?";

        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, assetId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    ticketIds.add(rs.getInt("TicketId"));
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return ticketIds;
    }

    // Lấy danh sách liên kết Ticket - CI, có hỗ trợ tìm kiếm theo keyword
    public List<Map<String, Object>> getTicketAssetLinks(String keyword) {
        List<Map<String, Object>> list = new ArrayList<>();

        StringBuilder sql = new StringBuilder(
                "SELECT ta.TicketId, ta.AssetId, "
                + "t.TicketNumber, t.TicketType, t.Status AS TicketStatus, p.Level AS TicketPriority, "
                + "a.AssetTag, a.AssetType, l.Name AS LocationName, u.FullName AS OwnerName "
                + "FROM TicketAssets ta "
                + "INNER JOIN Tickets t ON ta.TicketId = t.Id "
                + "INNER JOIN Assets a ON ta.AssetId = a.Id "
                + "LEFT JOIN Priorities p ON t.PriorityId = p.Id "
                + "LEFT JOIN Locations l ON a.LocationId = l.Id "
                + "LEFT JOIN Users u ON a.OwnerId = u.Id "
                + "WHERE 1=1 "
        );

        boolean hasKeyword = keyword != null && !keyword.trim().isEmpty();
        if (hasKeyword) {
            sql.append(" AND (t.TicketNumber LIKE ? OR t.TicketType LIKE ? OR t.Status LIKE ? OR p.Level LIKE ? OR a.AssetTag LIKE ? OR a.AssetType LIKE ? OR l.Name LIKE ? OR u.FullName LIKE ?) ");
        }

        sql.append(" ORDER BY t.CreatedAt DESC, a.AssetTag ASC");

        try (PreparedStatement ps = connection.prepareStatement(sql.toString())) {
            if (hasKeyword) {
                String term = "%" + keyword.trim() + "%";
                ps.setString(1, term);
                ps.setString(2, term);
                ps.setString(3, term);
                ps.setString(4, term);
                ps.setString(5, term);
                ps.setString(6, term);
                ps.setString(7, term);
                ps.setString(8, term);
            }

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Map<String, Object> row = new HashMap<>();
                    row.put("ticketId", rs.getInt("TicketId"));
                    row.put("assetId", rs.getInt("AssetId"));
                    row.put("ticketNumber", rs.getString("TicketNumber"));
                    row.put("ticketType", rs.getString("TicketType"));
                    row.put("ticketStatus", rs.getString("TicketStatus"));
                    row.put("ticketPriority", rs.getString("TicketPriority"));
                    row.put("assetTag", rs.getString("AssetTag"));
                    row.put("assetType", rs.getString("AssetType"));
                    row.put("locationName", rs.getString("LocationName"));
                    row.put("ownerName", rs.getString("OwnerName"));
                    list.add(row);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }

        return list;
    }

    public void closeConnection() {
        try {
            if (connection != null && !connection.isClosed()) {
                connection.close();
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }
}