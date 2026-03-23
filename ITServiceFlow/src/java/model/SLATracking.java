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
public class SLATracking {
    private int id;
    private int ticketId;
    private Date responseDeadline;
    private Date resolutionDeadline;
    private boolean isBreached;
    private Date createdAt;

    public SLATracking() {
    }

    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public int getTicketId() {
        return ticketId;
    }

    public void setTicketId(int ticketId) {
        this.ticketId = ticketId;
    }

    public Date getResponseDeadline() {
        return responseDeadline;
    }

    public void setResponseDeadline(Date responseDeadline) {
        this.responseDeadline = responseDeadline;
    }

    public Date getResolutionDeadline() {
        return resolutionDeadline;
    }

    public void setResolutionDeadline(Date resolutionDeadline) {
        this.resolutionDeadline = resolutionDeadline;
    }

    public boolean isIsBreached() {
        return isBreached;
    }

    public void setIsBreached(boolean isBreached) {
        this.isBreached = isBreached;
    }

    public Date getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(Date createdAt) {
        this.createdAt = createdAt;
    }

}
