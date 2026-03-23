package model;

import java.util.Date;

/**
 * Model dùng chung cho cả TimeLogs (Ticket) và ProblemTimeLogs (Problem).
 *
 * Quy ước:
 *  - Khi dùng với ProblemTimeLogs: set problemId (hoặc ticketId đều được, đồng bộ nhau)
 *  - Khi dùng với TimeLogs       : set ticketId
 */
public class TimeLog {
    private int id;

    // problemId và ticketId được giữ đồng bộ nhau qua setter
    private int ticketId;   // = ProblemId khi context là Problem
    private int problemId;  // alias rõ ràng cho Problem context

    private int userId;
    private Date startTime;
    private Date endTime;
    private double hours;   // tính tự động (start→stop) hoặc nhập thủ công
    private Date logDate;

    /**
     * Mô tả công việc đã làm trong phiên này.
     * Bắt buộc khi log giờ thủ công; có thể null khi dùng start/stop timer.
     */
    private String note;

    private String fullName; // join từ bảng Users

    // ─── Getters & Setters ───────────────────────────────────────

    public int getId() { return id; }
    public void setId(int id) { this.id = id; }

    /** Dùng được cho cả Problem và Ticket context. */
    public int getTicketId() { return ticketId; }
    public void setTicketId(int ticketId) {
        this.ticketId = ticketId;
        this.problemId = ticketId;
    }

    /** Alias rõ ràng khi context là Problem. */
    public int getProblemId() { return problemId; }
    public void setProblemId(int problemId) {
        this.problemId = problemId;
        this.ticketId = problemId;
    }

    public int getUserId() { return userId; }
    public void setUserId(int userId) { this.userId = userId; }

    public Date getStartTime() { return startTime; }
    public void setStartTime(Date startTime) { this.startTime = startTime; }

    public Date getEndTime() { return endTime; }
    public void setEndTime(Date endTime) { this.endTime = endTime; }

    public double getHours() { return hours; }
    public void setHours(double hours) { this.hours = hours; }

    public Date getLogDate() { return logDate; }
    public void setLogDate(Date logDate) { this.logDate = logDate; }

    public String getNote() { return note; }
    public void setNote(String note) { this.note = note; }

    public String getFullName() { return fullName; }
    public void setFullName(String fullName) { this.fullName = fullName; }

    // ─── Helper methods ──────────────────────────────────────────

    /** Trả về true nếu phiên đang chạy (chưa có endTime). */
    public boolean isRunning() {
        return endTime == null && startTime != null;
    }

    /**
     * Số giờ đã chạy tính đến thời điểm hiện tại.
     * Dùng để hiển thị live trên UI phía server nếu cần.
     */
    public double getElapsedHours() {
        if (startTime == null) return 0;
        Date end = (endTime != null) ? endTime : new Date();
        return (end.getTime() - startTime.getTime()) / 3_600_000.0;
    }
}