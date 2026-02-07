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
}
