/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package service;
import dao.ProblemDao;
import java.sql.Date;
import java.util.List;
import model.Problems;
import model.Tickets;
import model.TimeLog;
/**
 *
 * @author DELL
 */
public class ProblemService {
    private ProblemDao dao = new ProblemDao();
    public List<Problems> getAllProblems()
    {
        return dao.getAllProblems();
    }
    public Problems getProblemById(int pId)
    {
        return dao.getProblemById(pId);
    }
    public boolean updateProblem(Problems problem)
    {
        if (problem == null) return false;
        if (problem.getId() <= 0) return false;
        if (problem.getTitle() == null || problem.getTitle().isBlank()) return false;

        return dao.updateProblem(problem);
    }
    
    public String getNextTicketNumber() {
        return dao.getNextTicketNumber();
    }
    public boolean insertProblem(String TicketNumber, String Title, String Description,
            String RootCause, String WalkAround, String Status, int CreatedBy, int AssignedTo, Date CreatedAt)
    {
        return dao.addProblem(Title, Description, RootCause, WalkAround, Status, CreatedBy, AssignedTo, CreatedAt);
    }
    public boolean deleteProblem(int Id)
    {
        return dao.deleteProblem(Id);
    }
    public List<Problems> searchProblem(String keyword)
    {
        if(keyword == null || keyword.isBlank())
        {
            return dao.getAllProblems();
        }
        return dao.searchProblem(keyword);
    }
    public List<Tickets> getRelatedTicket(int Id)
    {
        return dao.viewRelatedTicket(Id);
    }
    public int getLatestProblemId() {
        return dao.getLatestProblemId();
    }
    
    public List<Problems> getProblemsWithPages(int page, int pageSize) {
        return dao.getProblemsWithPages(page, pageSize);
    }
    
    public int getTotalProblem() {
        return dao.getTotalProblem();
    }
    
    public List<Problems> getAssignProblemWithPage(int id, int page, int pageSize)
    {
        return dao.getAssignProblems(id, page, pageSize);
    }
    
    public int getTotalAssignProblem(int id)
    {
        return dao.getTotalAssignProblems(id);
    }
    
    public boolean updateAssignStatus(int Id)
    {
        return dao.startInvestigation(Id);
    }
    
    public List<Problems> filterByStatus(String status) {
        return dao.filterByStatus(status);
    }

    public List<Problems> filterByDateRange(Date fromDate, Date toDate) {
        return dao.filterByDateRange(fromDate, toDate);
    }
    
    public List<Problems> searchAssignedProblems(int id, String keyword)
    {
        return dao.searchAssignedProblem(id, keyword);
    }
    
    public List<Problems> getProblemsPending(int page, int pageSize)
    {
        return dao.getProblemsPendingWithPages(page, pageSize);
    }
    
    public boolean updateStatusProblem(int problemId, String status)
    {
        return dao.updateProblemStatus(problemId, status);
    }
    
    public boolean linkProblemTicket(int problemId, List<Integer> tickets)
    {
        return dao.addProblemTickets(problemId, tickets);
    }
    
    public boolean unlinkProblemTicket(int problemId, int ticketId)
    {
        return dao.unlinkProblemTicket(problemId, ticketId);
    }
    
    public boolean unlinkAllProblemTickets(int problemId)
    {
        return dao.unlinkAllProblemTickets(problemId);
    }
    
    public int getTotalProblemExcludingStatus(String excludeStatus) 
    {
        return dao.getTotalProblemExcludingStatus(excludeStatus);
    }

    public List<Problems> getProblemsWithPagesExcludingStatus(int page, int pageSize, String excludeStatus)
    {
        return dao.getProblemsWithPagesExcludingStatus(page, pageSize, excludeStatus);
    }
    
    public int getNumberPendingProblems() {
        return dao.getTotalProblemPendingProblem("Pending");
    }
    
    public boolean logTime(int problemId, int userId, double hours) {
    if (hours <= 0) return false;
    return dao.addTimeLog(problemId, userId, hours);
}

public List<TimeLog> getTimeLogs(int problemId) {
    return dao.getTimeLogsByProblemId(problemId);
}

public double getTotalTimeSpent(int problemId) {
    return dao.getTotalHoursByProblem(problemId);
}

public int startTimer(int problemId, int userId) {
    return dao.startTimer(problemId, userId);
}

public boolean stopTimer(int timeLogId) {
    return dao.stopTimer(timeLogId);
}
    
    
}
