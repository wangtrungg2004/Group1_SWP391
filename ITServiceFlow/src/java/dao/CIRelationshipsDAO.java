package dao;

import Utils.DbContext;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;
import model.CIRelationships;

public class CIRelationshipsDAO extends DbContext {

    // Lấy tất cả mối quan hệ của một CI cụ thể (làm nguồn hoặc đích)
    public List<CIRelationships> getAllRelationships() {
        List<CIRelationships> list = new ArrayList<>();
        String sql = "SELECT * FROM CIRelationships";
        try (PreparedStatement ps = connection.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                CIRelationships rel = new CIRelationships();
                rel.setId(rs.getInt("Id"));
                rel.setSourceCIId(rs.getInt("SourceCIId"));
                rel.setTargetCIId(rs.getInt("TargetCIId"));
                rel.setRelationshipType(rs.getString("RelationshipType"));
                rel.setDescription(rs.getString("Description"));
                list.add(rel);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    public List<CIRelationships> getRelationshipsByCIId(int ciId) {
        List<CIRelationships> list = new ArrayList<>();
        String sql = "SELECT * FROM CIRelationships "
                   + "WHERE SourceCIId = ? OR TargetCIId = ? "
                   + "ORDER BY CreatedAt DESC";

        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, ciId);
            ps.setInt(2, ciId);

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    CIRelationships rel = mapRowToRelationship(rs);
                    list.add(rel);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    // Lấy mối quan hệ theo ID
    public CIRelationships getById(int id) {
        String sql = "SELECT * FROM CIRelationships WHERE Id = ?";

        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapRowToRelationship(rs);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    // Thêm mới một mối quan hệ giữa hai CI
    public boolean addRelationship(CIRelationships rel) {
        String sql = "INSERT INTO CIRelationships (SourceCIId, TargetCIId, RelationshipType, Description, CreatedAt) "
                   + "VALUES (?, ?, ?, ?, GETDATE())";

        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, rel.getSourceCIId());
            ps.setInt(2, rel.getTargetCIId());
            ps.setString(3, rel.getRelationshipType());
            ps.setString(4, rel.getDescription());

            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    // Cập nhật mối quan hệ (thường chỉ description hoặc type)
    public boolean updateRelationship(CIRelationships rel) {
        String sql = "UPDATE CIRelationships SET "
                   + "RelationshipType = ?, Description = ? "
                   + "WHERE Id = ?";

        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setString(1, rel.getRelationshipType());
            ps.setString(2, rel.getDescription());
            ps.setInt(3, rel.getId());

            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    // Xóa một mối quan hệ
    public boolean deleteRelationship(int id) {
        String sql = "DELETE FROM CIRelationships WHERE Id = ?";

        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, id);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    // Kiểm tra xem hai CI đã có mối quan hệ nào chưa (tránh duplicate)
    public boolean existsRelationship(int sourceCIId, int targetCIId, String relationshipType) {
        String sql = "SELECT COUNT(*) FROM CIRelationships "
                   + "WHERE SourceCIId = ? AND TargetCIId = ? AND RelationshipType = ?";

        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, sourceCIId);
            ps.setInt(2, targetCIId);
            ps.setString(3, relationshipType);

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

    // Helper: map ResultSet -> CIRelationship
    private CIRelationships mapRowToRelationship(ResultSet rs) throws SQLException {
        CIRelationships rel = new CIRelationships();
        rel.setId(rs.getInt("Id"));
        rel.setSourceCIId(rs.getInt("SourceCIId"));
        rel.setTargetCIId(rs.getInt("TargetCIId"));
        rel.setRelationshipType(rs.getString("RelationshipType"));
        rel.setDescription(rs.getString("Description"));
        rel.setCreatedAt(rs.getTimestamp("CreatedAt"));
        return rel;
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