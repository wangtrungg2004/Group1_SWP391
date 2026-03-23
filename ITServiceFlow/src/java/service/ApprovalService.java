package service;

import dao.ChangeRequestDao;
import dao.NotificationDao;
import model.ChangeApproval;
import model.ChangeRequests;
import model.Tickets;
import model.Users;
import java.util.List;

public class ApprovalService {
    private final ChangeRequestDao dao     = new ChangeRequestDao();
    private final NotificationDao  notifDao = new NotificationDao();

    // ── OLD signature (8 params) — backward compat với controller cũ ─────────
    public int submitChangeRequest(int createdBy, String title, String description,
                                   String changeType, String riskLevel, String rollbackPlan,
                                   java.util.Date plannedStart, java.util.Date plannedEnd) {
        return submitChangeRequest(createdBy, title, description, changeType,
                riskLevel, rollbackPlan, plannedStart, plannedEnd, null, false);
    }

    // ── NEW signature (10 params) ─────────────────────────────────────────────
    public int submitChangeRequest(int createdBy, String title, String description,
                                   String changeType, String riskLevel, String rollbackPlan,
                                   java.util.Date plannedStart, java.util.Date plannedEnd,
                                   Integer linkedTicketId, boolean savedAsDraft) {
        if (riskLevel == null || riskLevel.trim().isEmpty()
                || rollbackPlan == null || rollbackPlan.trim().isEmpty()) return -1;

        int rfcId = dao.createChangeRequest(createdBy, title, description, changeType,
                riskLevel, rollbackPlan, plannedStart, plannedEnd, linkedTicketId, savedAsDraft);

        if (rfcId > 0 && !savedAsDraft) {
            ChangeRequests cr = dao.getById(rfcId);
            String rfcNum = (cr != null) ? cr.getRfcNumber() : "RFC mới";
            for (Users mgr : dao.getAllManagers()) {
                notifDao.addNotification(mgr.getId(),
                    "RFC mới cần duyệt: [" + rfcNum + "] " + title,
                    null, false, "Change Request Mới", "ChangeRequest");
            }
        }
        return rfcId;
    }

    // ── Submit Draft ──────────────────────────────────────────────────────────
    public boolean submitDraft(int changeId, int requestorId) {
        boolean ok = dao.submitDraft(changeId, requestorId);
        if (ok) {
            ChangeRequests cr = dao.getById(changeId);
            if (cr != null) {
                for (Users mgr : dao.getAllManagers()) {
                    notifDao.addNotification(mgr.getId(),
                        "RFC cần duyệt: [" + cr.getRfcNumber() + "] " + cr.getTitle(),
                        null, false, "Change Request Cần Duyệt", "ChangeRequest");
                }
            }
        }
        return ok;
    }

    // ── Approve / Reject ──────────────────────────────────────────────────────
    public boolean processDecision(int changeId, int approverId, String decision, String comment) {
        boolean updated = dao.updateStatus(changeId, decision);
        if (!updated) return false;
        dao.addApproval(changeId, approverId, decision, comment);
        ChangeRequests cr = dao.getById(changeId);
        if (cr != null) {
            String msg = "RFC [" + cr.getRfcNumber() + "] của bạn đã được "
                    + ("Approved".equals(decision) ? "DUYỆT ✓" : "TỪ CHỐI ✗")
                    + ("Rejected".equals(decision) && comment != null && !comment.isBlank()
                        ? " — Lý do: " + comment : "");
            notifDao.addNotification(cr.getCreatedBy(), msg, null, false,
                "RFC " + ("Approved".equals(decision) ? "Đã duyệt" : "Bị từ chối"),
                "ChangeRequest");
        }
        return true;
    }

    // ── Getters (THÊM getById) ────────────────────────────────────────────────
    public ChangeRequests getById(int id)            { return dao.getById(id); }
    public List<ChangeRequests> getPendingRequests() { return dao.getPendingRequests(); }
    public List<ChangeRequests> getAllRequests()     { return dao.getAllRequests(); }
    public List<ChangeApproval> getHistory(int id)  { return dao.getApprovals(id); }
    public List<Users> getAllManagers()              { return dao.getAllManagers(); }

    public List<ChangeRequests> getMyRequests(int userId, String status) {
        return dao.getMyChangeRequests(userId, status);
    }
    public List<Tickets> getAssignedTicketsForRFC(int itSupportId) {
        return dao.getAssignedTicketsForRFC(itSupportId);
    }
}