package model;

import java.sql.Timestamp;

public class AuditLog {
    private int id;
    private int userId;
    private String action;
    private String entity;
    private int entityId;
    private Timestamp createdAt;
    private String userName;
    // Constructors
    public AuditLog() {}

    public AuditLog(int userId, String action, String entity, int entityId) {
        this.userId = userId;
        this.action = action;
        this.entity = entity;
        this.entityId = entityId;
    }

    public AuditLog(int id, int userId, String action, String entity, int entityId, Timestamp createdAt, String userName) {
        this.id = id;
        this.userId = userId;
        this.action = action;
        this.entity = entity;
        this.entityId = entityId;
        this.createdAt = createdAt;
        this.userName = userName;
    }

    public String getUserName() {
        return userName;
    }

    public void setUserName(String userName) {
        this.userName = userName;
    }
    
    
    // Getters & Setters
    public int getId() { return id; }
    public void setId(int id) { this.id = id; }

    public int getUserId() { return userId; }
    public void setUserId(int userId) { this.userId = userId; }

    public String getAction() { return action; }
    public void setAction(String action) { this.action = action; }

    public String getEntity() { return entity; }
    public void setEntity(String entity) { this.entity = entity; }

    public int getEntityId() { return entityId; }
    public void setEntityId(int entityId) { this.entityId = entityId; }

    public Timestamp getCreatedAt() { return createdAt; }
    public void setCreatedAt(Timestamp createdAt) { this.createdAt = createdAt; }
}