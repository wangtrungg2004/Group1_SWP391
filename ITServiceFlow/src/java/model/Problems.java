/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package model;
import java.util.Date;
/**
 *
 * @author DELL
 */
public class Problems {
    private int id;
    private String ticketNumber;
    private String title;
    private String description;
    private String rootCause;
    private String workaround;
    private String status;
    private int createdBy;
    private String createdByName;
    private int assignedTo;
    private Date createdAt;

    public Problems(int id, String ticketNumber, String title, String description, String rootCause, String workaround, String status, int createdBy, String createdByName, int assignedTo, Date createdAt) {
        this.id = id;
        this.ticketNumber = ticketNumber;
        this.title = title;
        this.description = description;
        this.rootCause = rootCause;
        this.workaround = workaround;
        this.status = status;
        this.createdBy = createdBy;
        this.createdByName = createdByName;
        this.assignedTo = assignedTo;
        this.createdAt = createdAt;
    }

    public Problems() {
    }

    public int getAssignedTo() {
        return assignedTo;
    }

    public void setAssignedTo(int assignedTo) {
        this.assignedTo = assignedTo;
    }

    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public String getTicketNumber() {
        return ticketNumber;
    }

    public void setTicketNumber(String ticketNumber) {
        this.ticketNumber = ticketNumber;
    }

    public String getTitle() {
        return title;
    }

    public void setTitle(String title) {
        this.title = title;
    }

    public String getDescription() {
        return description;
    }

    public void setDescription(String description) {
        this.description = description;
    }

    public String getRootCause() {
        return rootCause;
    }

    public void setRootCause(String rootCause) {
        this.rootCause = rootCause;
    }

    public String getWorkaround() {
        return workaround;
    }

    public void setWorkaround(String workaround) {
        this.workaround = workaround;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public int getCreatedBy() {
        return createdBy;
    }

    public void setCreatedBy(int createdBy) {
        this.createdBy = createdBy;
    }

    public Date getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(Date createdAt) {
        this.createdAt = createdAt;
    }

    public String getCreatedByName() {
        return createdByName;
    }

    public void setCreatedByName(String createdByName) {
        this.createdByName = createdByName;
    }
    
    
}