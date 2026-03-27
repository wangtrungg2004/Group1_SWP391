
package model;

import java.util.Date;
import java.util.List;

public class KnowledgeArticles {
    private List<SharedFile> attachments;

    public List<SharedFile> getAttachments() {
        return attachments;
    }

    public void setAttachments(List<SharedFile> attachments) {
        this.attachments = attachments;
    }

    private int id;
    private String articleNumber;
    private String title;
    private String content;
    private Integer categoryId;
    private String status;
    private Integer viewCount;
    private int createdBy;
    private Date createdAt;

    public KnowledgeArticles() {
    }

    public KnowledgeArticles(int id, String articleNumber, String title, String content,
            Integer categoryId, String status, Integer viewCount,
            int createdBy, Date createdAt) {
        this.id = id;
        this.articleNumber = articleNumber;
        this.title = title;
        this.content = content;
        this.categoryId = categoryId;
        this.status = status;
        this.viewCount = viewCount;
        this.createdBy = createdBy;
        this.createdAt = createdAt;
    }

    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public String getArticleNumber() {
        return articleNumber;
    }

    public void setArticleNumber(String articleNumber) {
        this.articleNumber = articleNumber;
    }

    public String getTitle() {
        return title;
    }

    public void setTitle(String title) {
        this.title = title;
    }

    public String getContent() {
        return content;
    }

    public void setContent(String content) {
        this.content = content;
    }

    public Integer getCategoryId() {
        return categoryId;
    }

    public void setCategoryId(Integer categoryId) {
        this.categoryId = categoryId;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public Integer getViewCount() {
        return viewCount;
    }

    public void setViewCount(Integer viewCount) {
        this.viewCount = viewCount;
    }

    public int getCreatedBy() {
        return createdBy;
    }

    public void setCreatedBy(int createdBy) {
        this.createdBy = createdBy;
    }

    public Date getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(Date createdAt) {
        this.createdAt = createdAt;
    }
}
