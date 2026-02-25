package dao;

import Utils.DbContext;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;
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