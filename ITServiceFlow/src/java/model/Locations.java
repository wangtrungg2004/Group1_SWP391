package model;

public class Locations {
    private int id;
    private String name;
    private String code;
    private boolean isActive;

    public Locations() {
    }

    public Locations(int id, String name, String code, boolean isActive) {
        this.id = id;
        this.name = name;
        this.code = code;
        this.isActive = isActive;
    }

    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public String getCode() {
        return code;
    }

    public void setCode(String code) {
        this.code = code;
    }

    public boolean isActive() {
        return isActive;
    }

    public void setIsActive(boolean isActive) {
        this.isActive = isActive;
    }
}