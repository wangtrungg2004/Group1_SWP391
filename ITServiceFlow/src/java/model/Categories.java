package model;

public class Categories {
    private int id;
    private String name;
    private int parentId;
    private int level;
    private String fullPath;
    private boolean isActive;

    public Categories() {
    }

    public Categories(int id, String name, int parentId, int level, String fullPath, boolean isActive) {
        this.id = id;
        this.name = name;
        this.parentId = parentId;
        this.level = level;
        this.fullPath = fullPath;
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

    public int getParentId() {
        return parentId;
    }

    public void setParentId(int parentId) {
        this.parentId = parentId;
    }

    public int getLevel() {
        return level;
    }

    public void setLevel(int level) {
        this.level = level;
    }

    public String getFullPath() {
        return fullPath;
    }

    public void setFullPath(String fullPath) {
        this.fullPath = fullPath;
    }

    public boolean isActive() {
        return isActive;
    }

    public void setActive(boolean isActive) {
        this.isActive = isActive;
    }
}