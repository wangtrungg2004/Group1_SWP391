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
}
