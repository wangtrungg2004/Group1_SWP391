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
public class Users {
    private int Id;
    private String Username;
    private String Email;
    private String PasswordHash;
    private String FullName;
    private String Role;
    private int DepartmentId;
    private int LocationId;
    private boolean Status;
    private Date CreatedAt;

    public Users() {
    }

    public Users(int Id, String Username, String Email, String PasswordHash, String FullName, String Role, int DepartmentId, int LocationId, boolean Status, Date CreatedAt) {
        this.Id = Id;
        this.Username = Username;
        this.Email = Email;
        this.PasswordHash = PasswordHash;
        this.FullName = FullName;
        this.Role = Role;
        this.DepartmentId = DepartmentId;
        this.LocationId = LocationId;
        this.Status = Status;
        this.CreatedAt = CreatedAt;
    }

    

    public String getPasswordHash() {
        return PasswordHash;
    }

    public void setPasswordHash(String PasswordHash) {
        this.PasswordHash = PasswordHash;
    }
    
    public int getId() {
        return Id;
    }

    public void setId(int Id) {
        this.Id = Id;
    }

    public String getUsername() {
        return Username;
    }

    public void setUsername(String Username) {
        this.Username = Username;
    }

    public String getEmail() {
        return Email;
    }

    public void setEmail(String Email) {
        this.Email = Email;
    }

    public String getFullName() {
        return FullName;
    }

    public void setFullName(String FullName) {
        this.FullName = FullName;
    }

    public String getRole() {
        return Role;
    }

    public void setRole(String Role) {
        this.Role = Role;
    }

    public int getDepartmentId() {
        return DepartmentId;
    }

    public void setDepartmentId(int DepartmentId) {
        this.DepartmentId = DepartmentId;
    }

    public boolean isStatus() {
        return Status;
    }

    public void setStatus(boolean Status) {
        this.Status = Status;
    }

    public Date getCreatedAt() {
        return CreatedAt;
    }

    public void setCreatedAt(Date CreatedAt) {
        this.CreatedAt = CreatedAt;
    }

    public int getLocationId() {
        return LocationId;
    }

    public void setLocationId(int LocationId) {
        this.LocationId = LocationId;
    }
    
    
}
