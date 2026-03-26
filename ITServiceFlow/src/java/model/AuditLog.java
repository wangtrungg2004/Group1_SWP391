package model;

import java.sql.Timestamp;

public class AuditLog {
    private int id;
    private int userId;
    private String userName;

    private String action;
    private String screen;
    private String dataBefore;
    private String dataAfter;

    private String entity;
    private Integer entityId;

    private Timestamp createdAt;

    public AuditLog() {
    }

    public AuditLog(int userId, String action, String screen, String dataBefore, String dataAfter) {
        this.userId = userId;
        this.action = action;
        this.screen = screen;
        this.dataBefore = dataBefore;
        this.dataAfter = dataAfter;
    }

    public AuditLog(int id, int userId, String userName, String action, String screen,
                    String dataBefore, String dataAfter, String entity, Integer entityId, Timestamp createdAt) {
        this.id = id;
        this.userId = userId;
        this.userName = userName;
        this.action = action;
        this.screen = screen;
        this.dataBefore = dataBefore;
        this.dataAfter = dataAfter;
        this.entity = entity;
        this.entityId = entityId;
        this.createdAt = createdAt;
    }

    // Getters & Setters

    public int getId() { return id; }
    public void setId(int id) { this.id = id; }

    public int getUserId() { return userId; }
    public void setUserId(int userId) { this.userId = userId; }

    public String getUserName() { return userName; }
    public void setUserName(String userName) { this.userName = userName; }

    public String getAction() { return action; }
    public void setAction(String action) { this.action = action; }

    public String getScreen() { return screen; }
    public void setScreen(String screen) { this.screen = screen; }

    public String getDataBefore() { return dataBefore; }
    public void setDataBefore(String dataBefore) { this.dataBefore = dataBefore; }

    public String getDataAfter() { return dataAfter; }
    public void setDataAfter(String dataAfter) { this.dataAfter = dataAfter; }

    public String getEntity() { return entity; }
    public void setEntity(String entity) { this.entity = entity; }

    public Integer getEntityId() { return entityId; }
    public void setEntityId(Integer entityId) { this.entityId = entityId; }

    public Timestamp getCreatedAt() { return createdAt; }
    public void setCreatedAt(Timestamp createdAt) { this.createdAt = createdAt; }
}