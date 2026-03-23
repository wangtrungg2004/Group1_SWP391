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
import java.util.List;
import java.util.Locale;
import java.util.Map;
import model.SLARule;
import model.SLATracking;

/**
 *
 * @author DELL
 */
public class SLATrackingService {
    private SLATrackingDao slaTrackingDao;
    private SLARuleDao slaRuleDao;
    private NotificationDao notificationDao;

    public SLATrackingService() {
        this.slaTrackingDao = new SLATrackingDao();
        this.slaRuleDao = new SLARuleDao();
        this.notificationDao = new NotificationDao();
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

    public void runEscalationSweep() {
        // Always keep IsBreached in sync for unresolved tickets.
        slaTrackingDao.markBreachedTickets();

        // Escalation event/history relies on this table. If migration is not applied yet,
        // skip to avoid duplicate notifications every request.
        if (!slaTrackingDao.isEscalationHistoryEnabled()) {
            return;
        }

        List<Map<String, Object>> candidates = slaTrackingDao.getEscalationCandidates();
        for (Map<String, Object> item : candidates) {
            processEscalationCandidate(item);
        }
    }

    private void processEscalationCandidate(Map<String, Object> item) {
        Integer ticketId = toInteger(item.get("TicketId"));
        Date deadline = toDate(item.get("ResolutionDeadline"));
        Integer remainingMinutes = toInteger(item.get("RemainingMinutes"));
        if (ticketId == null || deadline == null || remainingMinutes == null) {
            return;
        }

        if (remainingMinutes < 0) {
            String title = "SLA Breached: " + getTicketDisplay(item, ticketId);
            String message = "Ticket " + getTicketDisplay(item, ticketId)
                    + " da breach SLA (deadline: " + formatDateTime(deadline) + ")."
                    + " Vui long uu tien xu ly ngay.";
            triggerEscalation(item, "BREACHED", "SLA breached", deadline, remainingMinutes,
                    "BROADCAST", null, title, message, "ESCALATE_TO_MANAGER", "Manager", null);
            return;
        }

        Integer assignedTo = toInteger(item.get("AssignedTo"));
        String targetType = assignedTo == null ? "BROADCAST" : "USER";
        Integer targetUserId = assignedTo;

        if (remainingMinutes <= 30) {
            String title = "SLA Warning (30m): " + getTicketDisplay(item, ticketId);
            String message = "Ticket " + getTicketDisplay(item, ticketId)
                    + " con " + Math.max(0, remainingMinutes)
                    + " phut truoc han SLA. Can hoan tat gap.";
            triggerEscalation(item, "NEAR_BREACH_30M", "Near breach 30m", deadline, remainingMinutes,
                    targetType, targetUserId, title, message, null, null, null);
            return;
        }

        if (remainingMinutes <= 120) {
            String title = "SLA Warning (2h): " + getTicketDisplay(item, ticketId);
            String message = "Ticket " + getTicketDisplay(item, ticketId)
                    + " dang sap breach SLA. Con " + remainingMinutes + " phut.";
            triggerEscalation(item, "NEAR_BREACH_2H", "Near breach 2h", deadline, remainingMinutes,
                    targetType, targetUserId, title, message, null, null, null);
        }
    }

    private void triggerEscalation(Map<String, Object> item,
                                   String stageCode,
                                   String stageLabel,
                                   Date deadline,
                                   Integer remainingMinutes,
                                   String notificationTargetType,
                                   Integer notificationTargetId,
                                   String notificationTitle,
                                   String notificationMessage,
                                   String autoAction,
                                   String escalatedToRole,
                                   Integer escalatedToUserId) {
        Integer ticketId = toInteger(item.get("TicketId"));
        if (ticketId == null) {
            return;
        }

        if (slaTrackingDao.hasEscalationHistory(ticketId, stageCode, deadline)) {
            return;
        }

        boolean notificationSent;
        if ("USER".equalsIgnoreCase(notificationTargetType) && notificationTargetId != null) {
            notificationSent = notificationDao.addNotification(
                    notificationTargetId,
                    notificationMessage,
                    ticketId,
                    false,
                    notificationTitle,
                    "Ticket");
        } else {
            notificationSent = notificationDao.addBroadcastNotification(
                    notificationMessage,
                    ticketId,
                    notificationTitle,
                    "Ticket");
            notificationTargetType = "BROADCAST";
            notificationTargetId = null;
        }

        if (!notificationSent) {
            return;
        }

        slaTrackingDao.addEscalationHistory(
                ticketId,
                stageCode,
                stageLabel,
                deadline,
                remainingMinutes,
                notificationTargetType,
                notificationTargetId,
                notificationTitle,
                notificationMessage,
                autoAction,
                escalatedToRole,
                escalatedToUserId);
    }

    private Integer toInteger(Object value) {
        if (value == null) {
            return null;
        }
        if (value instanceof Number) {
            return ((Number) value).intValue();
        }
        try {
            return Integer.parseInt(String.valueOf(value));
        } catch (Exception ex) {
            return null;
        }
    }

    private Date toDate(Object value) {
        if (value instanceof Date) {
            return (Date) value;
        }
        return null;
    }

    private String getTicketDisplay(Map<String, Object> item, int ticketId) {
        Object ticketNumberObj = item.get("TicketNumber");
        if (ticketNumberObj != null) {
            String ticketNumber = String.valueOf(ticketNumberObj).trim();
            if (!ticketNumber.isEmpty()) {
                return ticketNumber;
            }
        }
        return "#" + ticketId;
    }

    private String formatDateTime(Date date) {
        SimpleDateFormat fmt = new SimpleDateFormat("dd/MM/yyyy HH:mm", Locale.ENGLISH);
        return fmt.format(date);
    }
}
