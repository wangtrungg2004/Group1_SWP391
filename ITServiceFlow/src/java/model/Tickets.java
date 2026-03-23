package model;

import java.util.Date;
import java.util.List;

public class Tickets {
    private int id;
    private String ticketNumber;
    private String ticketType;
    private String title;
    private String description;
    private int categoryId;
    private int locationId;
    private Integer impact;
    private Integer urgency;
    private Integer priorityId;
    private Integer serviceCatalogId;
    private Boolean requiresApproval;
    private Integer approvedBy;
    private Date approvedAt;
    private String status;
    private int createdBy;
    private Integer assignedTo;
    private Integer parentTicketId;
    private Date resolvedAt;
    private Date closedAt;
    private Date createdAt;
    private Date updatedAt;
    private Integer currentLevel;
    private String categoryName;
    private String locationName;
    private String priorityLevel;
    private String assigneeName;
    private String serviceName;

    private String assetTag;
    private String assetName;
    private String assetType;
    private List<Assets> linkedAssets;

    
    // Thêm thuộc tính này vào model
    private java.util.Date resolutionDeadline;


    public Tickets() {
    }

    public Tickets(int id, String ticketNumber, String ticketType, String title, String description,
            int categoryId, int locationId, Integer impact, Integer urgency, Integer priorityId,
            Integer serviceCatalogId, Boolean requiresApproval, Integer approvedBy, Date approvedAt,
            String status, int createdBy, Integer assignedTo, Integer parentTicketId,
            Date resolvedAt, Date closedAt, Date createdAt, Date updatedAt, Integer currentLevel) {
        this.id = id;
        this.ticketNumber = ticketNumber;
        this.ticketType = ticketType;
        this.title = title;
        this.description = description;
        this.categoryId = categoryId;
        this.locationId = locationId;
        this.impact = impact;
        this.urgency = urgency;
        this.priorityId = priorityId;
        this.serviceCatalogId = serviceCatalogId;
        this.requiresApproval = requiresApproval;
        this.approvedBy = approvedBy;
        this.approvedAt = approvedAt;
        this.status = status;
        this.createdBy = createdBy;
        this.assignedTo = assignedTo;
        this.parentTicketId = parentTicketId;
        this.resolvedAt = resolvedAt;
        this.closedAt = closedAt;
        this.createdAt = createdAt;
        this.updatedAt = updatedAt;
        this.currentLevel = currentLevel;
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

    public String getTicketType() {
        return ticketType;
    }

    public void setTicketType(String ticketType) {
        this.ticketType = ticketType;
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

    public int getCategoryId() {
        return categoryId;
    }

    public void setCategoryId(int categoryId) {
        this.categoryId = categoryId;
    }

    public int getLocationId() {
        return locationId;
    }

    public void setLocationId(int locationId) {
        this.locationId = locationId;
    }

    public Integer getImpact() {
        return impact;
    }

    public void setImpact(Integer impact) {
        this.impact = impact;
    }

    public Integer getUrgency() {
        return urgency;
    }

    public void setUrgency(Integer urgency) {
        this.urgency = urgency;
    }

    public Integer getPriorityId() {
        return priorityId;
    }

    public void setPriorityId(Integer priorityId) {
        this.priorityId = priorityId;
    }

    public Integer getServiceCatalogId() {
        return serviceCatalogId;
    }

    public void setServiceCatalogId(Integer serviceCatalogId) {
        this.serviceCatalogId = serviceCatalogId;
    }

    public Boolean isRequiresApproval() {
        return requiresApproval;
    }

    public void setRequiresApproval(Boolean requiresApproval) {
        this.requiresApproval = requiresApproval;
    }

    // Alias getter to match DAO usage
    public Boolean getRequiresApproval() {
        return requiresApproval;
    }

    public Integer getApprovedBy() {
        return approvedBy;
    }

    public void setApprovedBy(Integer approvedBy) {
        this.approvedBy = approvedBy;
    }

    public Date getApprovedAt() {
        return approvedAt;
    }

    public void setApprovedAt(Date approvedAt) {
        this.approvedAt = approvedAt;
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

    public Integer getAssignedTo() {
        return assignedTo;
    }

    public void setAssignedTo(Integer assignedTo) {
        this.assignedTo = assignedTo;
    }

    public Integer getParentTicketId() {
        return parentTicketId;
    }

    public void setParentTicketId(Integer parentTicketId) {
        this.parentTicketId = parentTicketId;
    }

    public Date getResolvedAt() {
        return resolvedAt;
    }

    public void setResolvedAt(Date resolvedAt) {
        this.resolvedAt = resolvedAt;
    }

    public Date getClosedAt() {
        return closedAt;
    }

    public void setClosedAt(Date closedAt) {
        this.closedAt = closedAt;
    }

    public Date getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(Date createdAt) {
        this.createdAt = createdAt;
    }

    public Date getUpdatedAt() {
        return updatedAt;
    }

    public void setUpdatedAt(Date updatedAt) {
        this.updatedAt = updatedAt;
    }

    public Integer getCurrentLevel() {
        return currentLevel;
    }

    public void setCurrentLevel(Integer currentLevel) {
        this.currentLevel = currentLevel;
    }

    public String getCategoryName() {
        return categoryName;
    }

    public void setCategoryName(String categoryName) {
        this.categoryName = categoryName;
    }

    public String getLocationName() {
        return locationName;
    }

    public void setLocationName(String locationName) {
        this.locationName = locationName;
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

    public String getServiceName() {
        return serviceName;
    }

    public void setServiceName(String serviceName) {
        this.serviceName = serviceName;
    }
    
    

    // Thêm Getter / Setter
    public java.util.Date getResolutionDeadline() {
        return resolutionDeadline;
    }

    public void setResolutionDeadline(java.util.Date resolutionDeadline) {
        this.resolutionDeadline = resolutionDeadline;
    }

    public String getAssetTag() {
        return assetTag;
    }

    public void setAssetTag(String assetTag) {
        this.assetTag = assetTag;
    }

    public String getAssetName() {
        return assetName;
    }

    public void setAssetName(String assetName) {
        this.assetName = assetName;
    }

    public String getAssetType() {
        return assetType;
    }

    public void setAssetType(String assetType) {
        this.assetType = assetType;
    }

    public List<Assets> getLinkedAssets() {
        return linkedAssets;
    }

    public void setLinkedAssets(List<Assets> linkedAssets) {
        this.linkedAssets = linkedAssets;
    }

}