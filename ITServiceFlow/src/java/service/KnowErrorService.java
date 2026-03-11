/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package service;
import dao.ChangeRequestDao;
import dao.KnowErrorDao;
import model.ChangeApproval;
import model.ChangeRequests;
import model.KnowErrors;
import model.Problems;
import java.util.List;
/**
 *
 * @author DELL
 */
public class KnowErrorService {
    KnowErrorDao dao = new KnowErrorDao();
    public List<KnowErrors> getAllActiveKnowError()
    {
        return dao.getAllActiveKnowErrors();
    }
    
    public boolean addKnowError(int problemId, String title, String workAround)
    {
        return dao.addNewKnowError(problemId, title, workAround);
    }
    
    public KnowErrors findKnowErrorByProblemId(int problemId)
    {
        return dao.findKnowErrorByProblemId(problemId);
    }
    
    public KnowErrors getKnowErrorById(int Id)
    {
        return dao.getKnowErrorById(Id);
    }

    public boolean updateKnowError(int id, String title, String workAround)
    {
        return dao.updateKnowError(id, title, workAround);
    }
    
    public boolean closedKnowError(int id, String status)
    {
        return dao.closedKnowError(id, status);
    }
    
    public List<KnowErrors> getAllKnowError()
    {
        return dao.getAllKnowErrors();
    }
    
    public List<KnowErrors> searchKnowError(String keyword, boolean active)
    {
        return dao.searchKnowErrors(keyword,active);
    }
}
