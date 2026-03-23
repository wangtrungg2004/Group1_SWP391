/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package model;

/**
 *
 * @author admin
 */
import java.util.Date;

public class ChangeApproval {
    private int id;
    private int changeId;
    private int approverId;
    private String decision;
    private String comment;
    private Date decidedAt;
    private String approverName; // join Users.FullName

    // Constructors
    public ChangeApproval() {}

    // Getters & Setters
    public int getId() { return id; }
    public void setId(int id) { this.id = id; }
    public int getChangeId() { return changeId; }
    public void setChangeId(int changeId) { this.changeId = changeId; }
    public int getApproverId() { return approverId; }
    public void setApproverId(int approverId) { this.approverId = approverId; }
    public String getDecision() { return decision; }
    public void setDecision(String decision) { this.decision = decision; }
    public String getComment() { return comment; }
    public void setComment(String comment) { this.comment = comment; }
    public Date getDecidedAt() { return decidedAt; }
    public void setDecidedAt(Date decidedAt) { this.decidedAt = decidedAt; }
    public String getApproverName() { return approverName; }
    public void setApproverName(String approverName) { this.approverName = approverName; }
}