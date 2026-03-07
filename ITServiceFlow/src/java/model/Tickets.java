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
public class Tickets {
    private int Id;
    private String TicketNumber;
    private String TicketType;
    private String Title;
    private String Description;
    private int CategoryId;
    private int LocationId;
    private Integer Impact;
    private Integer Urgency;
    private Integer PriorityId;
    private Integer ServiceCatalogId;
    private Boolean RequiresApproval;
    private Integer ApprovedBy;
    private Date ApprovedAt;
    private String Status;
    private int CreatedBy;
    private Integer AssignedTo;
    private Integer ParentTicketId;
    private Date ResolvedAt;
    private Date ClosedAt;
    private Date CreatedAt;
    private Date UpdatedAt;
    private Integer CurrentLevel;
    // --- CÁC TRƯỜNG BỔ SUNG ĐỂ HIỂN THỊ LÊN VIEW (JSP) ---
    private String priorityLevel; // Lấy từ bảng Priorities
    private String assigneeName;  // Lấy từ bảng Users
    private String categoryName;  // Lấy từ bảng Categories
    private String serviceName;   // Lấy từ bảng ServiceCatalog

    public Tickets() {
    }

    public Tickets(int Id, String TicketNumber, String TicketType, String Title, String Description, int CategoryId, int LocationId, Integer Impact, Integer Urgency, Integer PriorityId, Integer ServiceCatalogId, Boolean RequiresApproval, Integer ApprovedBy, Date ApprovedAt, String Status, int CreatedBy, Integer AssignedTo, Integer ParentTicketId, Date ResolvedAt, Date ClosedAt, Date CreatedAt, Date UpdatedAt, Integer CurrentLevel) {
        this.Id = Id;
        this.TicketNumber = TicketNumber;
        this.TicketType = TicketType;
        this.Title = Title;
        this.Description = Description;
        this.CategoryId = CategoryId;
        this.LocationId = LocationId;
        this.Impact = Impact;
        this.Urgency = Urgency;
        this.PriorityId = PriorityId;
        this.ServiceCatalogId = ServiceCatalogId;
        this.RequiresApproval = RequiresApproval;
        this.ApprovedBy = ApprovedBy;
        this.ApprovedAt = ApprovedAt;
        this.Status = Status;
        this.CreatedBy = CreatedBy;
        this.AssignedTo = AssignedTo;
        this.ParentTicketId = ParentTicketId;
        this.ResolvedAt = ResolvedAt;
        this.ClosedAt = ClosedAt;
        this.CreatedAt = CreatedAt;
        this.UpdatedAt = UpdatedAt;
        this.CurrentLevel = CurrentLevel;
    }

    public int getId() {
        return Id;
    }

    public void setId(int Id) {
        this.Id = Id;
    }

    public String getTicketNumber() {
        return TicketNumber;
    }

    public void setTicketNumber(String TicketNumber) {
        this.TicketNumber = TicketNumber;
    }

    public String getTicketType() {
        return TicketType;
    }

    public void setTicketType(String TicketType) {
        this.TicketType = TicketType;
    }

    public String getTitle() {
        return Title;
    }

    public void setTitle(String Title) {
        this.Title = Title;
    }

    public String getDescription() {
        return Description;
    }

    public void setDescription(String Description) {
        this.Description = Description;
    }

    public int getCategoryId() {
        return CategoryId;
    }

    public void setCategoryId(int CategoryId) {
        this.CategoryId = CategoryId;
    }

    public int getLocationId() {
        return LocationId;
    }

    public void setLocationId(int LocationId) {
        this.LocationId = LocationId;
    }

    public Integer getImpact() {
        return Impact;
    }

    public void setImpact(Integer Impact) {
        this.Impact = Impact;
    }

    public Integer getUrgency() {
        return Urgency;
    }

    public void setUrgency(Integer Urgency) {
        this.Urgency = Urgency;
    }

    public Integer getPriorityId() {
        return PriorityId;
    }

    public void setPriorityId(Integer PriorityId) {
        this.PriorityId = PriorityId;
    }

    public Integer getServiceCatalogId() {
        return ServiceCatalogId;
    }

    public void setServiceCatalogId(Integer ServiceCatalogId) {
        this.ServiceCatalogId = ServiceCatalogId;
    }

    public Boolean getRequiresApproval() {
        return RequiresApproval;
    }

    public void setRequiresApproval(Boolean RequiresApproval) {
        this.RequiresApproval = RequiresApproval;
    }

    public Integer getApprovedBy() {
        return ApprovedBy;
    }

    public void setApprovedBy(Integer ApprovedBy) {
        this.ApprovedBy = ApprovedBy;
    }

    public Date getApprovedAt() {
        return ApprovedAt;
    }

    public void setApprovedAt(Date ApprovedAt) {
        this.ApprovedAt = ApprovedAt;
    }

    public String getStatus() {
        return Status;
    }

    public void setStatus(String Status) {
        this.Status = Status;
    }

    public int getCreatedBy() {
        return CreatedBy;
    }

    public void setCreatedBy(int CreatedBy) {
        this.CreatedBy = CreatedBy;
    }

    public Integer getAssignedTo() {
        return AssignedTo;
    }

    public void setAssignedTo(Integer AssignedTo) {
        this.AssignedTo = AssignedTo;
    }

    public Integer getParentTicketId() {
        return ParentTicketId;
    }

    public void setParentTicketId(Integer ParentTicketId) {
        this.ParentTicketId = ParentTicketId;
    }

    public Date getResolvedAt() {
        return ResolvedAt;
    }

    public void setResolvedAt(Date ResolvedAt) {
        this.ResolvedAt = ResolvedAt;
    }

    public Date getClosedAt() {
        return ClosedAt;
    }

    public void setClosedAt(Date ClosedAt) {
        this.ClosedAt = ClosedAt;
    }

    public Date getCreatedAt() {
        return CreatedAt;
    }

    public void setCreatedAt(Date CreatedAt) {
        this.CreatedAt = CreatedAt;
    }

    public Date getUpdatedAt() {
        return UpdatedAt;
    }

    public void setUpdatedAt(Date UpdatedAt) {
        this.UpdatedAt = UpdatedAt;
    }

    public Integer getCurrentLevel() {
        return CurrentLevel;
    }

    public void setCurrentLevel(Integer CurrentLevel) {
        this.CurrentLevel = CurrentLevel;
    }

    public String getPriorityLevel() {
        return priorityLevel;
    }

    public void setPriorityLevel(String priorityLevel) {
        this.priorityLevel = priorityLevel;
    }

    public String getAssigneeName() {
        return assigneeName;
    }

    public void setAssigneeName(String assigneeName) {
        this.assigneeName = assigneeName;
    }

    public String getCategoryName() {
        return categoryName;
    }

    public void setCategoryName(String categoryName) {
        this.categoryName = categoryName;
    }

    public String getServiceName() {
        return serviceName;
    }

    public void setServiceName(String serviceName) {
        this.serviceName = serviceName;
    }
    
    

}
