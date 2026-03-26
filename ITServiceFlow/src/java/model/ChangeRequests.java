package model;

import java.util.Date;

public class ChangeRequests {

    // ── DB columns ──
    private int id;
    private String rfcNumber;       // cột RFCNumber trong DB (CHG-YYYY-NNN)
    private String title;
    private String description;
    private String changeType;
    private String riskLevel;
    private String rollbackPlan;
    private Date plannedStart;
    private Date plannedEnd;
    private String status;
    private int createdBy;
    private Date createdAt;
    private Integer linkedTicketId; // cột LinkedTicketId (mới thêm)

    // ── Join fields (không lưu DB) ──
    private String createdByName;
    private String linkedTicketNumber;
    private String linkedTicketTitle;
    private String approverComment;
    private Date approvedAt;

    public ChangeRequests() {}

    // ── rfcNumber getter/setter (tên mới, khớp cột DB RFCNumber) ──
    public String getRfcNumber() { return rfcNumber; }
    public void setRfcNumber(String rfcNumber) { this.rfcNumber = rfcNumber; }

    // ── ticketNumber alias (backward compat với code cũ dùng getTicketNumber) ──
    public String getTicketNumber() { return rfcNumber; }
    public void setTicketNumber(String ticketNumber) { this.rfcNumber = ticketNumber; }

    // ── Các field còn lại ──
    public int getId() { return id; }
    public void setId(int id) { this.id = id; }

    public String getTitle() { return title; }
    public void setTitle(String title) { this.title = title; }

    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }

    public String getChangeType() { return changeType; }
    public void setChangeType(String changeType) { this.changeType = changeType; }

    public String getRiskLevel() { return riskLevel; }
    public void setRiskLevel(String riskLevel) { this.riskLevel = riskLevel; }

    public String getRollbackPlan() { return rollbackPlan; }
    public void setRollbackPlan(String rollbackPlan) { this.rollbackPlan = rollbackPlan; }

    public Date getPlannedStart() { return plannedStart; }
    public void setPlannedStart(Date plannedStart) { this.plannedStart = plannedStart; }

    public Date getPlannedEnd() { return plannedEnd; }
    public void setPlannedEnd(Date plannedEnd) { this.plannedEnd = plannedEnd; }

    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }

    public int getCreatedBy() { return createdBy; }
    public void setCreatedBy(int createdBy) { this.createdBy = createdBy; }

    public Date getCreatedAt() { return createdAt; }
    public void setCreatedAt(Date createdAt) { this.createdAt = createdAt; }

    public Integer getLinkedTicketId() { return linkedTicketId; }
    public void setLinkedTicketId(Integer linkedTicketId) { this.linkedTicketId = linkedTicketId; }

    public String getCreatedByName() { return createdByName; }
    public void setCreatedByName(String createdByName) { this.createdByName = createdByName; }

    public String getLinkedTicketNumber() { return linkedTicketNumber; }
    public void setLinkedTicketNumber(String linkedTicketNumber) { this.linkedTicketNumber = linkedTicketNumber; }

    public String getLinkedTicketTitle() { return linkedTicketTitle; }
    public void setLinkedTicketTitle(String linkedTicketTitle) { this.linkedTicketTitle = linkedTicketTitle; }

    public String getApproverComment() { return approverComment; }
    public void setApproverComment(String approverComment) { this.approverComment = approverComment; }

    public Date getApprovedAt() { return approvedAt; }
    public void setApprovedAt(Date approvedAt) { this.approvedAt = approvedAt; }
}