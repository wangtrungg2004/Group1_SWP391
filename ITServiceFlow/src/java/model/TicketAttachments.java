package model;

import java.util.Date;

public class TicketAttachments {
    private int id;
    private int ticketId;
    private int uploadedBy;
    private String fileName;
    private String filePath;
    private String fileType;
    private Date uploadedAt;

    public TicketAttachments() {
    }

    public TicketAttachments(int id, int ticketId, int uploadedBy, 
                             String fileName, String filePath, 
                             String fileType, Date uploadedAt) {
        this.id = id;
        this.ticketId = ticketId;
        this.uploadedBy = uploadedBy;
        this.fileName = fileName;
        this.filePath = filePath;
        this.fileType = fileType;
        this.uploadedAt = uploadedAt;
    }

    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public int getTicketId() {
        return ticketId;
    }

    public void setTicketId(int ticketId) {
        this.ticketId = ticketId;
    }

    public int getUploadedBy() {
        return uploadedBy;
    }

    public void setUploadedBy(int uploadedBy) {
        this.uploadedBy = uploadedBy;
    }

    public String getFileName() {
        return fileName;
    }

    public void setFileName(String fileName) {
        this.fileName = fileName;
    }

    public String getFilePath() {
        return filePath;
    }

    public void setFilePath(String filePath) {
        this.filePath = filePath;
    }

    public String getFileType() {
        return fileType;
    }

    public void setFileType(String fileType) {
        this.fileType = fileType;
    }

    public Date getUploadedAt() {
        return uploadedAt;
    }

    public void setUploadedAt(Date uploadedAt) {
        this.uploadedAt = uploadedAt;
    }
}