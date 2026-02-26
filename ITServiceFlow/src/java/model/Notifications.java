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
public class Notifications {
   private int Id;
   private int UserId;
   private String Message;
   private int RelatedTicketId;
   private boolean IsRead;
   private Date CreatedAt;
   private String Title;
   private String Type;

    public Notifications() {
    }

    public Notifications(int Id, int UserId, String Message, int RelatedTicketId, boolean IsRead, Date CreatedAt, String Title, String Type) {
        this.Id = Id;
        this.UserId = UserId;
        this.Message = Message;
        this.RelatedTicketId = RelatedTicketId;
        this.IsRead = IsRead;
        this.CreatedAt = CreatedAt;
        this.Title = Title;
        this.Type = Type;
    }

    public int getId() {
        return Id;
    }

    public void setId(int Id) {
        this.Id = Id;
    }

    public int getUserId() {
        return UserId;
    }

    public void setUserId(int UserId) {
        this.UserId = UserId;
    }

    public String getMessage() {
        return Message;
    }

    public void setMessage(String Message) {
        this.Message = Message;
    }

    public int getRelatedTicketId() {
        return RelatedTicketId;
    }

    public void setRelatedTicketId(int RelatedTicketId) {
        this.RelatedTicketId = RelatedTicketId;
    }

    public boolean isIsRead() {
        return IsRead;
    }

    public void setIsRead(boolean IsRead) {
        this.IsRead = IsRead;
    }

    public Date getCreatedAt() {
        return CreatedAt;
    }

    public void setCreatedAt(Date CreatedAt) {
        this.CreatedAt = CreatedAt;
    }

    public String getTitle() {
        return Title;
    }

    public void setTitle(String Title) {
        this.Title = Title;
    }

    public String getType() {
        return Type;
    }

    public void setType(String Type) {
        this.Type = Type;
    }
   
}
