/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package model;

/**
 *
 * @author DELL
 */
public class Priority {
    private int id;
    private int impact;
    private int urgency;
    private String level; // P1, P2, P3...
    private int responseHours;
    private int resolutionHours;

    public Priority() {
    }

    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public int getImpact() {
        return impact;
    }

    public void setImpact(int impact) {
        this.impact = impact;
    }

    public int getUrgency() {
        return urgency;
    }

    public void setUrgency(int urgency) {
        this.urgency = urgency;
    }

    public String getLevel() {
        return level;
    }

    public void setLevel(String level) {
        this.level = level;
    }

    public int getResponseHours() {
        return responseHours;
    }

    public void setResponseHours(int responseHours) {
        this.responseHours = responseHours;
    }

    public int getResolutionHours() {
        return resolutionHours;
    }

    public void setResolutionHours(int resolutionHours) {
        this.resolutionHours = resolutionHours;
    }

}
