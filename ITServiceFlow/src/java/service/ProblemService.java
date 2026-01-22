/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package service;
import dao.ProblemDao;
import java.util.List;
import model.Problems;
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
}
