/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package service;

/**
 *
 * @author admin
 */
import dao.ChangeRequestDao;
import model.ChangeApproval;
import model.ChangeRequests;
import java.util.List;

public class ApprovalService {
    private ChangeRequestDao dao = new ChangeRequestDao();

    public int submitChangeRequest(int createdBy, String title, String description, 
                                   String changeType, String riskLevel, String rollbackPlan,
                                   java.util.Date plannedStart, java.util.Date plannedEnd) {
        if (riskLevel == null || riskLevel.trim().isEmpty() || rollbackPlan == null || rollbackPlan.trim().isEmpty()) {
            return -1;
        }
        return dao.createChangeRequest(createdBy, title, description, changeType, riskLevel, rollbackPlan, plannedStart, plannedEnd);
    }

    public List<ChangeRequests> getPendingRequests() {
        return dao.getPendingRequests();
    }

    public List<ChangeRequests> getAllRequests() {
        return dao.getAllRequests();
    }

    public boolean processDecision(int changeId, int approverId, String decision, String comment) {
        String newStatus = decision; // Approved / Rejected / Escalated
        boolean updated = dao.updateStatus(changeId, newStatus);
        if (updated) {
            dao.addApproval(changeId, approverId, decision, comment);
            return true;
        }
        return false;
    }

    public List<ChangeApproval> getHistory(int changeId) {
        return dao.getApprovals(changeId);
    }
    public List<ChangeRequests> getMyRequests(int createdBy, String status) {
    return dao.getMyChangeRequests(createdBy, status);
}
}