package dao;

import Utils.DbContext;
import model.SharedFile;
import model.TicketAttachments;

import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

public class TicketAttachmentDAO extends DbContext {

    public TicketAttachments addAttachment(int ticketId, SharedFile file, int uploadedBy) throws SQLException {
        String sql = "INSERT INTO TicketAttachments (TicketId, UploadedBy, FileName, FilePath, FileType, FileId, UploadedAt) "
                + "VALUES (?, ?, ?, ?, ?, ?, GETDATE())";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, ticketId);
            ps.setInt(2, uploadedBy);
            ps.setString(3, file.getOriginalName());
            ps.setString(4, file.getStoragePath());
            ps.setString(5, file.getMimeType());
            ps.setInt(6, file.getId());
            ps.executeUpdate();
        }
        TicketAttachments ta = new TicketAttachments();
        ta.setTicketId(ticketId);
        ta.setUploadedBy(uploadedBy);
        ta.setFileName(file.getOriginalName());
        ta.setFilePath(file.getStoragePath());
        ta.setFileType(file.getMimeType());
        ta.setFileId(file.getId());
        return ta;
    }

    public List<TicketAttachments> listByTicket(int ticketId) throws SQLException {
        String sql = "SELECT * FROM TicketAttachments WHERE TicketId = ? ORDER BY UploadedAt DESC";
        List<TicketAttachments> list = new ArrayList<>();
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, ticketId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    TicketAttachments ta = new TicketAttachments();
                    ta.setId(rs.getInt("Id"));
                    ta.setTicketId(rs.getInt("TicketId"));
                    ta.setUploadedBy(rs.getInt("UploadedBy"));
                    ta.setFileName(rs.getString("FileName"));
                    ta.setFilePath(rs.getString("FilePath"));
                    ta.setFileType(rs.getString("FileType"));
                    ta.setUploadedAt(rs.getTimestamp("UploadedAt"));
                    ta.setFileId((Integer) rs.getObject("FileId"));
                    list.add(ta);
                }
            }
        }
        return list;
    }
}
