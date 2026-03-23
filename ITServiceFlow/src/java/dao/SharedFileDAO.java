package dao;

import Utils.DbContext;
import model.SharedFile;

import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.List;

public class SharedFileDAO extends DbContext {

    public int addFile(String originalName, String storedName, String mimeType, long sizeBytes, String storagePath, int uploadedBy) throws SQLException {
        String sql = "INSERT INTO SharedFiles (OriginalName, StoredName, MimeType, SizeBytes, StoragePath, UploadedBy, UploadedAt) "
                + "VALUES (?, ?, ?, ?, ?, ?, GETDATE());";
        try (PreparedStatement ps = connection.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setString(1, originalName);
            ps.setString(2, storedName);
            ps.setString(3, mimeType);
            ps.setLong(4, sizeBytes);
            ps.setString(5, storagePath);
            ps.setInt(6, uploadedBy);
            ps.executeUpdate();

            try (ResultSet rs = ps.getGeneratedKeys()) {
                if (rs.next()) {
                    return rs.getInt(1);
                }
            }
        }
        return -1;
    }

    public SharedFile save(SharedFile file) throws SQLException {
        String sql = "INSERT INTO SharedFiles (OriginalName, StoredName, MimeType, SizeBytes, StoragePath, UploadedBy, UploadedAt) "
                +
                "VALUES (?, ?, ?, ?, ?, ?, GETDATE());";
        try (PreparedStatement ps = connection.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setString(1, file.getOriginalName());
            ps.setString(2, file.getStoredName());
            ps.setString(3, file.getMimeType());
            ps.setLong(4, file.getSizeBytes());
            ps.setString(5, file.getStoragePath());
            ps.setInt(6, file.getUploadedBy());
            ps.executeUpdate();

            try (ResultSet rs = ps.getGeneratedKeys()) {
                if (rs.next()) {
                    file.setId(rs.getInt(1));
                }
            }
        }
        return file;
    }

    public SharedFile findById(int id) throws SQLException {
        String sql = "SELECT * FROM SharedFiles WHERE Id = ?";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, id);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                return map(rs);
            }
        }
        return null;
    }

    public List<SharedFile> listRecent(int limit) throws SQLException {
        String sql = "SELECT TOP (?) * FROM SharedFiles ORDER BY UploadedAt DESC";
        List<SharedFile> list = new ArrayList<>();
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, limit);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                list.add(map(rs));
            }
        }
        return list;
    }

    private SharedFile map(ResultSet rs) throws SQLException {
        SharedFile f = new SharedFile();
        f.setId(rs.getInt("Id"));
        f.setOriginalName(rs.getString("OriginalName"));
        f.setStoredName(rs.getString("StoredName"));
        f.setMimeType(rs.getString("MimeType"));
        f.setSizeBytes(rs.getLong("SizeBytes"));
        f.setStoragePath(rs.getString("StoragePath"));
        f.setUploadedBy(rs.getInt("UploadedBy"));
        f.setUploadedAt(rs.getTimestamp("UploadedAt"));
        return f;
    }
}
