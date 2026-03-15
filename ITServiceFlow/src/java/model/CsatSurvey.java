package model;

import java.util.Date;

/**
 * Model cho bảng CsatSurveys (US20)
 * Tên cột theo đúng schema ITServiceFlow:
 *   Id, TicketId, UserId, Rating (tinyint 1-5), Comment (nvarchar 1000), SubmittedAt
 */
public class CsatSurvey {

    // === Columns trong DB ===
    private int id;
    private int ticketId;
    private int userId;        // = Tickets.CreatedBy  (user gửi survey)
    private int rating;        // 1 – 5
    private String comment;
    private Date submittedAt;

    // === Join fields (SELECT JOIN, không lưu DB) ===
    private String ticketNumber;   // Tickets.TicketNumber
    private String ticketTitle;    // Tickets.Title
    private String userFullName;   // Users.FullName  (người submit)
    private String assigneeName;   // Users.FullName  (Tickets.AssignedTo)

    public CsatSurvey() {}

    public CsatSurvey(int ticketId, int userId, int rating, String comment) {
        this.ticketId = ticketId;
        this.userId   = userId;
        this.rating   = rating;
        this.comment  = comment;
    }

    public int getId() { return id; }
    public void setId(int id) { this.id = id; }

    public int getTicketId() { return ticketId; }
    public void setTicketId(int ticketId) { this.ticketId = ticketId; }

    public int getUserId() { return userId; }
    public void setUserId(int userId) { this.userId = userId; }

    public int getRating() { return rating; }
    public void setRating(int rating) { this.rating = rating; }

    public String getComment() { return comment; }
    public void setComment(String comment) { this.comment = comment; }

    public Date getSubmittedAt() { return submittedAt; }
    public void setSubmittedAt(Date submittedAt) { this.submittedAt = submittedAt; }

    public String getTicketNumber() { return ticketNumber; }
    public void setTicketNumber(String ticketNumber) { this.ticketNumber = ticketNumber; }

    public String getTicketTitle() { return ticketTitle; }
    public void setTicketTitle(String ticketTitle) { this.ticketTitle = ticketTitle; }

    public String getUserFullName() { return userFullName; }
    public void setUserFullName(String userFullName) { this.userFullName = userFullName; }

    public String getAssigneeName() { return assigneeName; }
    public void setAssigneeName(String assigneeName) { this.assigneeName = assigneeName; }
}