<<<<<<< HEAD
=======
/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
>>>>>>> HoangNV4
package model;

import java.sql.Timestamp;

<<<<<<< HEAD
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
=======
/**
 *
 * @author DELL
 */
public class AuditLog {
    private int id;
    private int userId;
    private String userName; // For display
    private String action;
    private String screen;
    private String dataBefore;
    private String dataAfter;
    private Timestamp createdAt;

    private String entity;
    private Integer entityId;

    public AuditLog() {
    }

    public AuditLog(int userId, String action, String screen, String dataBefore, String dataAfter) {
        this.userId = userId;
        this.action = action;
        this.screen = screen;
        this.dataBefore = dataBefore;
        this.dataAfter = dataAfter;
    }

    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public int getUserId() {
        return userId;
    }

    public void setUserId(int userId) {
        this.userId = userId;
>>>>>>> HoangNV4
    }

    public String getUserName() {
        return userName;
    }

    public void setUserName(String userName) {
        this.userName = userName;
    }
<<<<<<< HEAD
    
    
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
=======

    public String getAction() {
        return action;
    }

    public void setAction(String action) {
        this.action = action;
    }

    public String getScreen() {
        return screen;
    }

    public void setScreen(String screen) {
        this.screen = screen;
    }

    public String getDataBefore() {
        return dataBefore;
    }

    public void setDataBefore(String dataBefore) {
        this.dataBefore = dataBefore;
    }

    public String getDataAfter() {
        return dataAfter;
    }

    public void setDataAfter(String dataAfter) {
        this.dataAfter = dataAfter;
    }

    public Timestamp getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(Timestamp createdAt) {
        this.createdAt = createdAt;
    }

    public String getEntity() {
        return entity;
    }

    public void setEntity(String entity) {
        this.entity = entity;
    }

    public Integer getEntityId() {
        return entityId;
    }

    public void setEntityId(Integer entityId) {
        this.entityId = entityId;
    }
}
>>>>>>> HoangNV4
