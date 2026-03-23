package model;

import java.util.Date;

public class TicketComments {
    private int id;
    private int ticketId;
    private int userId;
    private String content;
    private boolean isInternal;
    private Date createdAt;
     // --- THÊM 2 THUỘC TÍNH NÀY ĐỂ PHỤC VỤ HIỂN THỊ UI ---
    private String userFullName;
    private String userRole;

    public TicketComments() {
    }

    public TicketComments(int id, int ticketId, int userId, String content, 
                          boolean isInternal, Date createdAt) {
        this.id = id;
        this.ticketId = ticketId;
        this.userId = userId;
        this.content = content;
        this.isInternal = isInternal;
        this.createdAt = createdAt;
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

    public int getUserId() {
        return userId;
    }

    public void setUserId(int userId) {
        this.userId = userId;
    }

    public String getContent() {
        return content;
    }

    public void setContent(String content) {
        this.content = content;
    }

    public boolean isInternal() {
        return isInternal;
    }

    public void setInternal(boolean isInternal) {
        this.isInternal = isInternal;
    }

    public Date getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(Date createdAt) {
        this.createdAt = createdAt;
    }
    
   

    public String getUserFullName() {
        return userFullName;
    }

    public void setUserFullName(String userFullName) {
        this.userFullName = userFullName;
    }

    public String getUserRole() {
        return userRole;
    }

    public void setUserRole(String userRole) {
        this.userRole = userRole;
    }
}