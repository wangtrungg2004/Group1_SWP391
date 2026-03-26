/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package model;

/**
 *
 * @author DELL
 */
public class Department {
    private int Id;
    private String Name;
    private Integer LocationId;
    private Integer CategoryId;
    private Integer ManagerId;
    private boolean IsActive;

    public Department() {
    }

    public Department(int Id, String Name, Integer LocationId, Integer CategoryId, Integer ManagerId, boolean IsActive) {
        this.Id = Id;
        this.Name = Name;
        this.LocationId = LocationId;
        this.CategoryId = CategoryId;
        this.ManagerId = ManagerId;
        this.IsActive = IsActive;
    }

    public int getId() {
        return Id;
    }

    public void setId(int Id) {
        this.Id = Id;
    }

    public String getName() {
        return Name;
    }

    public void setName(String Name) {
        this.Name = Name;
    }

    public Integer getLocationId() {
        return LocationId;
    }

    public void setLocationId(Integer LocationId) {
        this.LocationId = LocationId;
    }

    public Integer getCategoryId() {
        return CategoryId;
    }

    public void setCategoryId(Integer CategoryId) {
        this.CategoryId = CategoryId;
    }

    public Integer getManagerId() {
        return ManagerId;
    }

    public void setManagerId(Integer ManagerId) {
        this.ManagerId = ManagerId;
    }

    public boolean IsActive() {
        return IsActive;
    }

    public void IsActive(boolean IsActive) {
        this.IsActive = IsActive;
    }
}
