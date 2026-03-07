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
public class KnowErrors {
    private int Id;
    private int ProblemId;
    private String Title;
    private String WorkAround;
    private String Status;
    private int ViewCount;
    private Date CreatedAt;

    public KnowErrors(int Id, int ProblemId, String Title, String WorkAround, String Status, int ViewCount, Date CreatedAt) {
        this.Id = Id;
        this.ProblemId = ProblemId;
        this.Title = Title;
        this.WorkAround = WorkAround;
        this.Status = Status;
        this.ViewCount = ViewCount;
        this.CreatedAt = CreatedAt;
    }

    public KnowErrors() {
    }

    public int getId() {
        return Id;
    }

    public void setId(int Id) {
        this.Id = Id;
    }

    public int getProblemId() {
        return ProblemId;
    }

    public void setProblemId(int ProblemId) {
        this.ProblemId = ProblemId;
    }

    public String getTitle() {
        return Title;
    }

    public void setTitle(String Title) {
        this.Title = Title;
    }

    public String getWorkAround() {
        return WorkAround;
    }

    public void setWorkAround(String WorkAround) {
        this.WorkAround = WorkAround;
    }

    public String getStatus() {
        return Status;
    }

    public void setStatus(String Status) {
        this.Status = Status;
    }

    public int getViewCount() {
        return ViewCount;
    }

    public void setViewCount(int ViewCount) {
        this.ViewCount = ViewCount;
    }

    public Date getCreatedAt() {
        return CreatedAt;
    }

    public void setCreatedAt(Date CreatedAt) {
        this.CreatedAt = CreatedAt;
    }

    @Override
    public String toString() {
        return "KnowErrors{" + "Id=" + Id + ", ProblemId=" + ProblemId + ", Title=" + Title + ", WorkAround=" + WorkAround + ", Status=" + Status + ", ViewCount=" + ViewCount + ", CreatedAt=" + CreatedAt + '}';
    }
    
}
