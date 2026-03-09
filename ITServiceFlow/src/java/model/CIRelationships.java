package model;

import java.util.Date;

public class CIRelationships {
    private int id;
    private int sourceCIId;
    private int targetCIId;
    private String relationshipType;
    private String description;
    private Date createdAt;
    
    // Thêm vào class CIRelationship
private String targetName;
private String targetAssetTag;
private String sourceName;

// Getters & Setters
public String getTargetName() { return targetName; }
public void setTargetName(String targetName) { this.targetName = targetName; }

public String getTargetAssetTag() { return targetAssetTag; }
public void setTargetAssetTag(String targetAssetTag) { this.targetAssetTag = targetAssetTag; }

public String getSourceName() { return sourceName; }
public void setSourceName(String sourceName) { this.sourceName = sourceName; }

    public CIRelationships() {
    }

    public CIRelationships(int id, int sourceCIId, int targetCIId, String relationshipType, 
                          String description, Date createdAt) {
        this.id = id;
        this.sourceCIId = sourceCIId;
        this.targetCIId = targetCIId;
        this.relationshipType = relationshipType;
        this.description = description;
        this.createdAt = createdAt;
    }

    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public int getSourceCIId() {
        return sourceCIId;
    }

    public void setSourceCIId(int sourceCIId) {
        this.sourceCIId = sourceCIId;
    }

    public int getTargetCIId() {
        return targetCIId;
    }

    public void setTargetCIId(int targetCIId) {
        this.targetCIId = targetCIId;
    }

    public String getRelationshipType() {
        return relationshipType;
    }

    public void setRelationshipType(String relationshipType) {
        this.relationshipType = relationshipType;
    }

    public String getDescription() {
        return description;
    }

    public void setDescription(String description) {
        this.description = description;
    }

    public Date getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(Date createdAt) {
        this.createdAt = createdAt;
    }
}