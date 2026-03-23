/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package service;

import dao.NotificationDao;
import dao.SLARuleDao;
import dao.SLATrackingDao;
import java.text.SimpleDateFormat;
import java.util.Calendar;
import java.util.Date;
import java.util.LinkedHashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;
import model.SLARule;
import model.SLATracking;

/**
 *
 * @author DELL
 */
public class SLATrackingService {
    private static final int THRESHOLD_NEAR_2H_MINUTES = 120;
    private static final int THRESHOLD_NEAR_30M_MINUTES = 30;

    private final SLATrackingDao slaTrackingDao;
    private final SLARuleDao slaRuleDao;
    private final NotificationDao notificationDao;
    private final AuditLogService auditLogService;

    public SLATrackingService() {
        this.slaTrackingDao = new SLATrackingDao();
        this.slaRuleDao = new SLARuleDao();
        this.notificationDao = new NotificationDao();
        this.auditLogService = new AuditLogService();
    }

    public void applySLARuleToTicket(int ticketId, String ticketType, int priorityId) {
        // 1. Find matching SLA Rule
        SLARule matchedRule = slaRuleDao.getActiveRuleByTypeAndPriority(ticketType, priorityId);

        if (matchedRule != null) {
            // 2. Calculate Deadlines
            Date now = new Date();
            Calendar calendar = Calendar.getInstance();

            calendar.setTime(now);
            calendar.add(Calendar.HOUR, matchedRule.getResponseTime());
            Date responseDeadline = calendar.getTime();

            calendar.setTime(now);
            calendar.add(Calendar.HOUR, matchedRule.getResolutionTime());
            Date resolutionDeadline = calendar.getTime();

            // 3. Create SLATracking entry
            SLATracking tracking = new SLATracking();
            tracking.setTicketId(ticketId);
            tracking.setResponseDeadline(responseDeadline);
            tracking.setResolutionDeadline(resolutionDeadline);

            slaTrackingDao.addSLATracking(tracking);
        }
    }

    public java.util.Map<String, Integer> getSLAStatistics() {
        return slaTrackingDao.getSLAStatistics();
    }

    public java.util.List<java.util.Map<String, Object>> getBreachedTickets(int limit) {
        return slaTrackingDao.getBreachedTickets(limit);
    }

    public java.util.List<java.util.Map<String, Object>> getNearBreachTickets(int limit) {
        return slaTrackingDao.getNearBreachTickets(limit);
    }

    public java.util.List<java.util.Map<String, Object>> getBreachList(String team, String priority, String agent,
            String status, String sortBy, int offset, int limit) {
        return slaTrackingDao.getBreachList(team, priority, agent, status, sortBy, offset, limit);
    }

    public EscalationRunResult runEscalationSweep() {
        EscalationRunResult result = new EscalationRunResult();
        if (!slaTrackingDao.isEscalationHistoryReady()) {
            result.setMessage("Escalation history table is not ready. Run DB migration first.");
            return result;
        }

        List<Map<String, Object>> candidates = slaTrackingDao.getEscalationCandidates();
        result.setCheckedCount(candidates.size());

        List<Integer> managerIds = slaTrackingDao.getActiveUserIdsByRole("Manager");

        for (Map<String, Object> candidate : candidates) {
            int ticketId = toInt(candidate.get("TicketId"));
            Date deadline = toDate(candidate.get("ResolutionDeadline"));
            if (ticketId <= 0 || deadline == null) {
                result.incrementSkipped();
                continue;
            }

            int remainingMinutes = toInt(candidate.get("RemainingMinutes"));
            String stageCode = resolveStageCode(remainingMinutes);
            if (stageCode == null) {
                result.incrementSkipped();
                continue;
            }

            if (slaTrackingDao.hasEscalationEvent(ticketId, stageCode, deadline)) {
                result.incrementSkipped();
                continue;
            }

            StageMeta stage = buildStage(stageCode);
            if (stage == null) {
                result.incrementSkipped();
                continue;
            }

            Integer assignedTo = toNullableInt(candidate.get("AssignedTo"));
            Integer createdBy = toNullableInt(candidate.get("CreatedBy"));
            String ticketNumber = safeString(candidate.get("TicketNumber"), "#" + ticketId);
            String title = stage.notificationTitle;
            String message = buildNotificationMessage(ticketNumber, deadline, remainingMinutes, stageCode);

            Set<Integer> recipients = new LinkedHashSet<>();
            if (assignedTo != null && assignedTo > 0) {
                recipients.add(assignedTo);
            }
            if (stage.notifyManagers) {
                recipients.addAll(managerIds);
            }

            String targetType;
            Integer targetId = null;
            if (recipients.isEmpty()) {
                notificationDao.addBroadcastNotification(message, ticketId, title, "SLA");
                targetType = "BROADCAST";
            } else {
                for (Integer userId : recipients) {
                    if (userId != null && userId > 0) {
                        notificationDao.addNotification(userId, message, ticketId, false, title, "SLA");
                    }
                }
                targetId = recipients.iterator().next();
                targetType = stage.notifyManagers ? "ASSIGNEE_AND_MANAGER" : "ASSIGNEE";
            }

            if ("BREACHED".equals(stageCode)) {
                slaTrackingDao.markBreachedTicket(ticketId);
            }

            Integer escalatedToUserId = null;
            if (stage.notifyManagers && !managerIds.isEmpty()) {
                escalatedToUserId = managerIds.get(0);
            }

            slaTrackingDao.createEscalationEvent(
                    ticketId,
                    stageCode,
                    stage.stageLabel,
                    deadline,
                    remainingMinutes,
                    targetType,
                    targetId,
                    title,
                    message,
                    stage.autoAction,
                    stage.notifyManagers ? "Manager" : null,
                    escalatedToUserId
            );

            int auditUserId = resolveAuditUserId(createdBy, assignedTo, managerIds);
            if (auditUserId > 0) {
                auditLogService.createAuditLog(auditUserId, stage.auditAction, "Ticket", ticketId);
            }
            result.incrementTriggered();
        }

        result.setMessage("Escalation sweep completed.");
        return result;
    }

    public List<Map<String, Object>> getRecentEscalationEvents(int limit) {
        return slaTrackingDao.getRecentEscalationEvents(limit);
    }

    private String resolveStageCode(int remainingMinutes) {
        if (remainingMinutes < 0) {
            return "BREACHED";
        }
        if (remainingMinutes <= THRESHOLD_NEAR_30M_MINUTES) {
            return "NEAR_BREACH_30M";
        }
        if (remainingMinutes <= THRESHOLD_NEAR_2H_MINUTES) {
            return "NEAR_BREACH_2H";
        }
        return null;
    }

    private StageMeta buildStage(String stageCode) {
        if ("NEAR_BREACH_2H".equals(stageCode)) {
            return new StageMeta(
                    "Near Breach (2h)",
                    "SLA Warning: < 2h remaining",
                    false,
                    "Notify assignee",
                    "SLA_NEAR_BREACH_2H"
            );
        }
        if ("NEAR_BREACH_30M".equals(stageCode)) {
            return new StageMeta(
                    "Near Breach (30m)",
                    "SLA Critical: < 30m remaining",
                    true,
                    "Notify assignee and manager",
                    "SLA_NEAR_BREACH_30M"
            );
        }
        if ("BREACHED".equals(stageCode)) {
            return new StageMeta(
                    "Breached",
                    "SLA Breached",
                    true,
                    "Mark breached and notify manager",
                    "SLA_BREACHED"
            );
        }
        return null;
    }

    private String buildNotificationMessage(String ticketNumber, Date deadline, int remainingMinutes, String stageCode) {
        String deadlineText = new SimpleDateFormat("dd/MM/yyyy HH:mm").format(deadline);
        if ("BREACHED".equals(stageCode)) {
            return "Ticket " + ticketNumber + " has breached SLA at " + deadlineText
                    + " (" + Math.abs(remainingMinutes) + " minutes overdue).";
        }
        return "Ticket " + ticketNumber + " is approaching SLA deadline at " + deadlineText
                + " (" + remainingMinutes + " minutes remaining).";
    }

    private int resolveAuditUserId(Integer createdBy, Integer assignedTo, List<Integer> managerIds) {
        if (createdBy != null && createdBy > 0) {
            return createdBy;
        }
        if (assignedTo != null && assignedTo > 0) {
            return assignedTo;
        }
        if (managerIds != null && !managerIds.isEmpty()) {
            return managerIds.get(0);
        }
        return -1;
    }

    private String safeString(Object value, String fallback) {
        if (value == null) {
            return fallback;
        }
        String text = value.toString().trim();
        return text.isEmpty() ? fallback : text;
    }

    private int toInt(Object value) {
        if (value instanceof Number) {
            return ((Number) value).intValue();
        }
        if (value == null) {
            return 0;
        }
        try {
            return Integer.parseInt(value.toString().trim());
        } catch (Exception ex) {
            return 0;
        }
    }

    private Integer toNullableInt(Object value) {
        if (value == null) {
            return null;
        }
        if (value instanceof Number) {
            return ((Number) value).intValue();
        }
        try {
            return Integer.parseInt(value.toString().trim());
        } catch (Exception ex) {
            return null;
        }
    }

    private Date toDate(Object value) {
        if (value == null) {
            return null;
        }
        if (value instanceof java.util.Date) {
            return (Date) value;
        }
        return null;
    }

    private static class StageMeta {
        private final String stageLabel;
        private final String notificationTitle;
        private final boolean notifyManagers;
        private final String autoAction;
        private final String auditAction;

        private StageMeta(String stageLabel, String notificationTitle, boolean notifyManagers, String autoAction, String auditAction) {
            this.stageLabel = stageLabel;
            this.notificationTitle = notificationTitle;
            this.notifyManagers = notifyManagers;
            this.autoAction = autoAction;
            this.auditAction = auditAction;
        }
    }

    public static class EscalationRunResult {
        private int checkedCount;
        private int triggeredCount;
        private int skippedCount;
        private String message;

        public int getCheckedCount() {
            return checkedCount;
        }

        public void setCheckedCount(int checkedCount) {
            this.checkedCount = checkedCount;
        }

        public int getTriggeredCount() {
            return triggeredCount;
        }

        public int getSkippedCount() {
            return skippedCount;
        }

        public String getMessage() {
            return message;
        }

        public void setMessage(String message) {
            this.message = message;
        }

        public void incrementTriggered() {
            this.triggeredCount++;
        }

        public void incrementSkipped() {
            this.skippedCount++;
        }
    }
}
