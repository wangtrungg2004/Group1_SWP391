/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package model;

/**
 *
 * @author admin
 */

public class ServiceCatalog {
    private int Id;
    private String Name;
    private String Description;
    private int CategoryId;
    private boolean RequiresApproval;
    private int EstimatedDeliveryDays;
    private boolean IsActive;

    public ServiceCatalog() {}

    public ServiceCatalog(int Id, String Name, String Description, int CategoryId,
                          boolean RequiresApproval, int EstimatedDeliveryDays, boolean IsActive) {
        this.Id = Id;
        this.Name = Name;
        this.Description = Description;
        this.CategoryId = CategoryId;
        this.RequiresApproval = RequiresApproval;
        this.EstimatedDeliveryDays = EstimatedDeliveryDays;
        this.IsActive = IsActive;
    }

    public int getId() { return Id; }
    public void setId(int Id) { this.Id = Id; }

    public String getName() { return Name; }
    public void setName(String Name) { this.Name = Name; }

    public String getDescription() { return Description; }
    public void setDescription(String Description) { this.Description = Description; }

    public int getCategoryId() { return CategoryId; }
    public void setCategoryId(int CategoryId) { this.CategoryId = CategoryId; }

    public boolean isRequiresApproval() { return RequiresApproval; }
    public void setRequiresApproval(boolean RequiresApproval) { this.RequiresApproval = RequiresApproval; }

    public int getEstimatedDeliveryDays() { return EstimatedDeliveryDays; }
    public void setEstimatedDeliveryDays(int EstimatedDeliveryDays) { this.EstimatedDeliveryDays = EstimatedDeliveryDays; }

    public boolean isIsActive() { return IsActive; }
    public void setIsActive(boolean IsActive) { this.IsActive = IsActive; }
}






