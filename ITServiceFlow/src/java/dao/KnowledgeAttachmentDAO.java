package dao;

import Utils.DbContext;
import model.KnowledgeAttachment;
import model.SharedFile;

import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.List;

public class KnowledgeAttachmentDAO extends DbContext {

    public KnowledgeAttachment add(KnowledgeAttachment att) throws SQLException {
        String sql = "INSERT INTO KnowledgeAttachments (ArticleId, FileId, AddedBy, AddedAt) VALUES (?, ?, ?, GETDATE());";
        try (PreparedStatement ps = connection.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setInt(1, att.getArticleId());
            ps.setInt(2, att.getFileId());
            ps.setInt(3, att.getAddedBy());
            ps.executeUpdate();
        }
        return att;
    }

    public List<KnowledgeAttachment> listByArticle(int articleId) throws SQLException {
        String sql = "SELECT * FROM KnowledgeAttachments WHERE ArticleId = ? ORDER BY AddedAt DESC";
        List<KnowledgeAttachment> list = new ArrayList<>();
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, articleId);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                list.add(map(rs));
            }
        }
        return list;
    }

    public List<SharedFile> listFilesByArticle(int articleId) throws SQLException {
        String sql = "SELECT sf.* FROM KnowledgeAttachments ka "
                + "JOIN SharedFiles sf ON ka.FileId = sf.Id "
                + "WHERE ka.ArticleId = ? ORDER BY ka.AddedAt DESC";
        List<SharedFile> list = new ArrayList<>();
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, articleId);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                list.add(mapSharedFile(rs));
            }
        }
        return list;
    }

    public void delete(int articleId, int fileId) throws SQLException {
        String sql = "DELETE FROM KnowledgeAttachments WHERE ArticleId = ? AND FileId = ?";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, articleId);
            ps.setInt(2, fileId);
            ps.executeUpdate();
        }
    }

    private KnowledgeAttachment map(ResultSet rs) throws SQLException {
        KnowledgeAttachment a = new KnowledgeAttachment();
        a.setArticleId(rs.getInt("ArticleId"));
        a.setFileId(rs.getInt("FileId"));
        a.setAddedBy(rs.getInt("AddedBy"));
        a.setAddedAt(rs.getTimestamp("AddedAt"));
        return a;
    }

    private SharedFile mapSharedFile(ResultSet rs) throws SQLException {
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
