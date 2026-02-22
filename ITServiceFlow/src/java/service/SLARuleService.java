/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package service;

import dao.SLARuleDao;
import java.util.List;
import model.Priority;
import model.SLARule;

/**
 *
 * @author DELL
 */
public class SLARuleService {
    private SLARuleDao slaRuleDao;

    public SLARuleService() {
        this.slaRuleDao = new SLARuleDao();
    }

    public List<SLARule> getAllSLARules() {
        return slaRuleDao.getAllSLARules();
    }

    public List<Priority> getAllPriorities() {
        return slaRuleDao.getAllPriorities();
    }

    public boolean addSLARule(SLARule sla) {
        return slaRuleDao.addSLARule(sla);
    }

    public boolean updateSLARule(SLARule sla) {
        return slaRuleDao.updateSLARule(sla);
    }

    public boolean deleteSLARule(int id) {
        return slaRuleDao.deleteSLARule(id);
    }

    public SLARule getSLARuleById(int id) {
        return slaRuleDao.getSLARuleById(id);
    }

<<<<<<< HEAD
=======
<<<<<<< HEAD
=======
<<<<<<< HEAD
>>>>>>> 21fb2ceca814b602237c1a9239d60577738016e8
>>>>>>> 3dd5aa557803e4dbc9a9b39c17449ccda9d3d815
    public SLARule getActiveRuleByTypeAndPriority(String ticketType, int priorityId) {
        return slaRuleDao.getActiveRuleByTypeAndPriority(ticketType, priorityId);
    }

<<<<<<< HEAD
=======
<<<<<<< HEAD
=======
=======
>>>>>>> 1763278990a4a240d89ada2a865acfd8b2595d22
>>>>>>> 21fb2ceca814b602237c1a9239d60577738016e8
>>>>>>> 3dd5aa557803e4dbc9a9b39c17449ccda9d3d815
    public List<SLARule> searchSLARules(String name, String type, Integer priorityId, String status, int page,
            int pageSize) {
        return slaRuleDao.searchSLARules(name, type, priorityId, status, page, pageSize);
    }

    public int countSLARules(String name, String type, Integer priorityId, String status) {
        return slaRuleDao.countSLARules(name, type, priorityId, status);
    }
}
