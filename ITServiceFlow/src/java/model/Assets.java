package model;

import java.util.Date;

public class Assets {
    private int id;
    private String assetTag;
    private String name;
    private String assetType;
    private String status;
    private int locationId;
    private int ownerId;
    private Date createdAt;
    private String locationName;
    private String ownerName;
    // Thêm vào class Assets
private  int relatedTicketCount;
private  Date linkedAt; // Dùng cho TicketLinkCI

// Getters & Setters


public int getRelatedTicketCount() { return relatedTicketCount; }
public void setRelatedTicketCount(int relatedTicketCount) { this.relatedTicketCount = relatedTicketCount; }

public Date getLinkedAt() { return linkedAt; }
public void setLinkedAt(Date linkedAt) { this.linkedAt = linkedAt; }

    public Assets() {
    }

    public Assets(int id, String assetTag, String name, String assetType, String status, 
                  int locationId, int ownerId, Date createdAt) {
        this.id = id;
        this.assetTag = assetTag;
        this.name = name;
        this.assetType = assetType;
        this.status = status;
        this.locationId = locationId;
        this.ownerId = ownerId;
        this.createdAt = createdAt;
    }

    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public String getAssetTag() {
        return assetTag;
    }

    public void setAssetTag(String assetTag) {
        this.assetTag = assetTag;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public String getAssetType() {
        return assetType;
    }

    public void setAssetType(String assetType) {
        this.assetType = assetType;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public int getLocationId() {
        return locationId;
    }

    public void setLocationId(int locationId) {
        this.locationId = locationId;
    }

    public int getOwnerId() {
        return ownerId;
    }

    public void setOwnerId(int ownerId) {
        this.ownerId = ownerId;
    }

    public Date getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(Date createdAt) {
        this.createdAt = createdAt;
    }

    public String getLocationName() {
        return locationName;
    }

    public void setLocationName(String locationName) {
        this.locationName = locationName;
    }

    public String getOwnerName() {
        return ownerName;
    }

    public void setOwnerName(String ownerName) {
        this.ownerName = ownerName;
    }
    
}