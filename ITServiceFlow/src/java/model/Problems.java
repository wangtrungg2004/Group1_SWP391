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
    private int Id;
    private String TicketNumber;
    private String Title;
    private String Description;
    private String RootCause;
    private String Workaround;
    private String Status;
    private int CreatedBy;
    private String CreatedByName;
    private int AssignedTo;
    private String AssignedToName;
    private Date CreatedAt;

    public Problems(int Id, String TicketNumber, String Title, String Description, String RootCause, String Workaround, String Status, int CreatedBy, String CreatedByName, int AssignedTo, String AssignedToName, Date CreatedAt) {
        this.Id = Id;
        this.TicketNumber = TicketNumber;
        this.Title = Title;
        this.Description = Description;
        this.RootCause = RootCause;
        this.Workaround = Workaround;
        this.Status = Status;
        this.CreatedBy = CreatedBy;
        this.CreatedByName = CreatedByName;
        this.AssignedTo = AssignedTo;
        this.AssignedToName = AssignedToName;
        this.CreatedAt = CreatedAt;
    }

    public Problems() {
    }

    public String getAssignedToName() {
        return AssignedToName;
    }

    public void setAssignedToName(String AssignedToName) {
        this.AssignedToName = AssignedToName;
    }
    
    public int getAssignedTo() {
        return AssignedTo;
    }

    public void setAssignedTo(int AssignedTo) {
        this.AssignedTo = AssignedTo;
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

    public String getRootCause() {
        return RootCause;
    }

    public void setRootCause(String RootCause) {
        this.RootCause = RootCause;
    }

    public String getWorkaround() {
        return Workaround;
    }

    public void setWorkaround(String Workaround) {
        this.Workaround = Workaround;
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

    public Date getCreatedAt() {
        return CreatedAt;
    }

    public void setCreatedAt(Date CreatedAt) {
        this.CreatedAt = CreatedAt;
    }

    public String getCreatedByName() {
        return CreatedByName;
    }

    public void setCreatedByName(String CreatedByName) {
        this.CreatedByName = CreatedByName;
    }
    
    
}
