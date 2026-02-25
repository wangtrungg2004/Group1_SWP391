package dao;

import Utils.DbContext;
import model.Assets;

import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Types;
import java.util.ArrayList;
import java.util.List;

/**
 * Data Access Object for Assets / Configuration Items.
 * Handles all database operations related to the Assets table.
 */
public class AssetsDAO extends DbContext {

    private static final String BASE_SELECT =
            "SELECT a.*, l.Name AS LocationName, u.FullName AS OwnerName " +
            "FROM Assets a " +
            "LEFT JOIN Locations l ON a.LocationId = l.Id " +
            "LEFT JOIN Users u ON a.OwnerId = u.Id ";

    public List<Assets> searchAssets(String keyword, String filterType, String status) {
        return searchAssets(keyword, filterType, status, null, null, null, null, null);
    }

    public List<Assets> searchAssets(String keyword, String filterType, String status,
                                     String assetTypeFilter, Integer locationIdFilter, Integer ownerIdFilter,
                                     java.sql.Date createdFrom, java.sql.Date createdTo) {

        List<Assets> list = new ArrayList<>();
        StringBuilder sql = new StringBuilder(BASE_SELECT).append(" WHERE 1=1");

        String normFilter = (filterType == null || filterType.trim().isEmpty()) ? "all" : filterType.trim();
        boolean hasKeyword = (keyword != null && !keyword.trim().isEmpty());

        java.sql.Date createdAtKeyword = null;
        if (hasKeyword) {
            try {
                java.time.format.DateTimeFormatter dmyFmt = java.time.format.DateTimeFormatter.ofPattern("dd/MM/yyyy");
                java.time.LocalDate localDate = java.time.LocalDate.parse(keyword.trim(), dmyFmt);
                createdAtKeyword = java.sql.Date.valueOf(localDate);
            } catch (java.time.format.DateTimeParseException ignored) {}

            if (createdAtKeyword == null) {
                try {
                    createdAtKeyword = java.sql.Date.valueOf(keyword.trim());
                } catch (IllegalArgumentException ignored) {}
            }
        }
        boolean useCreatedAtKeyword = (createdAtKeyword != null);

        if (hasKeyword) {
            switch (normFilter) {
                case "name": sql.append(" AND a.Name LIKE ?"); break;
                case "assetTag": sql.append(" AND a.AssetTag LIKE ?"); break;
                case "type": sql.append(" AND a.AssetType LIKE ?"); break;
                case "location": sql.append(" AND l.Name LIKE ?"); break;
                case "owner": sql.append(" AND u.FullName LIKE ?"); break;
                case "createdAt": if (useCreatedAtKeyword) sql.append(" AND CAST(a.CreatedAt AS DATE) = ?"); break;
                default:
                    if (useCreatedAtKeyword) {
                        sql.append(" AND (a.Name LIKE ? OR a.AssetType LIKE ? OR l.Name LIKE ? OR u.FullName LIKE ? OR CAST(a.CreatedAt AS DATE) = ?)");
                    } else {
                        sql.append(" AND (a.Name LIKE ? OR a.AssetType LIKE ? OR l.Name LIKE ? OR u.FullName LIKE ?)");
                    }
                    break;
            }
        }

        if (status != null && !status.trim().isEmpty() && !"all".equalsIgnoreCase(status.trim())) {
            sql.append(" AND a.Status = ?");
        }

        if (assetTypeFilter != null && !assetTypeFilter.trim().isEmpty()) sql.append(" AND a.AssetType LIKE ?");
        if (locationIdFilter != null) sql.append(" AND a.LocationId = ?");
        if (ownerIdFilter != null) sql.append(" AND a.OwnerId = ?");
        if (createdFrom != null) sql.append(" AND CAST(a.CreatedAt AS DATE) >= ?");
        if (createdTo != null) sql.append(" AND CAST(a.CreatedAt AS DATE) <= ?");

        sql.append(" ORDER BY a.CreatedAt DESC");

        try (PreparedStatement ps = connection.prepareStatement(sql.toString())) {
            int idx = 1;

            if (hasKeyword) {
                String term = "%" + keyword.trim() + "%";
                switch (normFilter) {
                    case "name": case "assetTag": case "type": case "location": case "owner":
                        ps.setString(idx++, term);
                        break;
                    case "createdAt":
                        if (useCreatedAtKeyword) ps.setDate(idx++, createdAtKeyword);
                        break;
                    default:
                        ps.setString(idx++, term);
                        ps.setString(idx++, term);
                        ps.setString(idx++, term);
                        ps.setString(idx++, term);
                        if (useCreatedAtKeyword) ps.setDate(idx++, createdAtKeyword);
                        break;
                }
            }

            if (status != null && !status.trim().isEmpty() && !"all".equalsIgnoreCase(status.trim())) {
                ps.setString(idx++, status.trim());
            }

            if (assetTypeFilter != null && !assetTypeFilter.trim().isEmpty()) ps.setString(idx++, "%" + assetTypeFilter.trim() + "%");
            if (locationIdFilter != null) ps.setInt(idx++, locationIdFilter);
            if (ownerIdFilter != null) ps.setInt(idx++, ownerIdFilter);
            if (createdFrom != null) ps.setDate(idx++, createdFrom);
            if (createdTo != null) ps.setDate(idx++, createdTo);

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapResultSetToAsset(rs));
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    public List<Assets> getAllAssets() {
        List<Assets> list = new ArrayList<>();
        String sql = BASE_SELECT + " ORDER BY a.CreatedAt DESC";
        try (PreparedStatement ps = connection.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                list.add(mapResultSetToAsset(rs));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    public Assets getAssetById(int id) {
        String sql = BASE_SELECT + " WHERE a.Id = ?";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return mapResultSetToAsset(rs);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    public boolean addAsset(Assets asset) {
        String sql = "INSERT INTO Assets (AssetTag, Name, AssetType, Status, LocationId, OwnerId, CreatedAt) " +
                     "VALUES (?, ?, ?, ?, ?, ?, GETDATE())";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setString(1, asset.getAssetTag());
            ps.setString(2, asset.getName());
            ps.setString(3, asset.getAssetType());
            ps.setString(4, asset.getStatus());
            ps.setInt(5, asset.getLocationId());
            if (asset.getOwnerId() > 0) {
                ps.setInt(6, asset.getOwnerId());
            } else {
                ps.setNull(6, Types.INTEGER);
            }
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    public boolean updateAsset(Assets asset) {
        String sql = "UPDATE Assets SET AssetTag = ?, Name = ?, AssetType = ?, Status = ?, " +
                     "LocationId = ?, OwnerId = ?, UpdatedAt = GETDATE() WHERE Id = ?";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setString(1, asset.getAssetTag());
            ps.setString(2, asset.getName());
            ps.setString(3, asset.getAssetType());
            ps.setString(4, asset.getStatus());
            ps.setInt(5, asset.getLocationId());
            if (asset.getOwnerId() > 0) {
                ps.setInt(6, asset.getOwnerId());
            } else {
                ps.setNull(6, Types.INTEGER);
            }
            ps.setInt(7, asset.getId());
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    public boolean deleteAsset(int id) {
        String sql = "DELETE FROM Assets WHERE Id = ?";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, id);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    private Assets mapResultSetToAsset(ResultSet rs) throws SQLException {
        Assets asset = new Assets();
        asset.setId(rs.getInt("Id"));
        asset.setAssetTag(rs.getString("AssetTag"));
        asset.setName(rs.getString("Name"));
        asset.setAssetType(rs.getString("AssetType"));
        asset.setStatus(rs.getString("Status"));
        asset.setLocationId(rs.getInt("LocationId"));
        asset.setOwnerId(rs.getInt("OwnerId"));
        asset.setCreatedAt(rs.getTimestamp("CreatedAt"));
        asset.setLocationName(rs.getString("LocationName"));
        asset.setOwnerName(rs.getString("OwnerName"));
        return asset;
    }
}
