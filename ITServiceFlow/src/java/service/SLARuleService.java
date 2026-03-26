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

    public SLARule getActiveRuleByTypeAndPriority(String ticketType, int priorityId) {
        return slaRuleDao.getActiveRuleByTypeAndPriority(ticketType, priorityId);
    }

    public List<SLARule> searchSLARules(String name, String type, Integer priorityId, String status, int page,
            int pageSize) {
        return slaRuleDao.searchSLARules(name, type, priorityId, status, page, pageSize);
    }

    public int countSLARules(String name, String type, Integer priorityId, String status) {
        return slaRuleDao.countSLARules(name, type, priorityId, status);
    }
<<<<<<< HEAD
=======

    public List<String> getDistinctTypes() {
        return slaRuleDao.getDistinctTypes();
    }

    public List<String> getDistinctStatuses() {
        return slaRuleDao.getDistinctStatuses();
    }

    public boolean isSlaNameExists(String name, Integer excludeId) {
        return slaRuleDao.isSlaNameExists(name, excludeId);
    }
>>>>>>> HoangNV4
}
