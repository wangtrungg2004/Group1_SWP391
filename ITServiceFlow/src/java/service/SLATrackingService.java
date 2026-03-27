package service;

import dao.NotificationDao;
import dao.SLARuleDao;
import dao.SLATrackingDao;
import dao.UserDao;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Calendar;
import java.util.Date;
import java.util.LinkedHashSet;
import java.util.List;
import java.util.Locale;
import java.util.Map;
import java.util.Set;
import model.SLARule;
import model.SLATracking;

public class SLATrackingService {
    private final SLATrackingDao slaTrackingDao;
    private final SLARuleDao slaRuleDao;
    private final NotificationDao notificationDao;
    private final UserDao userDao;

    public SLATrackingService() {
        this.slaTrackingDao = new SLATrackingDao();
        this.slaRuleDao = new SLARuleDao();
        this.notificationDao = new NotificationDao();
        this.userDao = new UserDao();
    }

    public void applySLARuleToTicket(int ticketId, String ticketType, int priorityId) {
        SLARule matchedRule = slaRuleDao.getActiveRuleByTypeAndPriority(ticketType, priorityId);
        if (matchedRule == null) {
            return;
        }

        Date now = new Date();
        Calendar calendar = Calendar.getInstance();
        calendar.setTime(now);
        calendar.add(Calendar.HOUR, matchedRule.getResponseTime());
        Date responseDeadline = calendar.getTime();

        calendar.setTime(now);
        calendar.add(Calendar.HOUR, matchedRule.getResolutionTime());
        Date resolutionDeadline = calendar.getTime();

        SLATracking tracking = new SLATracking();
        tracking.setTicketId(ticketId);
        tracking.setResponseDeadline(responseDeadline);
        tracking.setResolutionDeadline(resolutionDeadline);
        slaTrackingDao.addSLATracking(tracking);
    }

    public Map<String, Integer> getSLAStatistics() {
        return slaTrackingDao.getSLAStatistics();
    }

    public Map<String, Integer> getSLAStatistics(java.sql.Date from, java.sql.Date to, Integer categoryId, Integer locationId) {
        return slaTrackingDao.getSLAStatistics(from, to, categoryId, locationId);
    }

    public List<Map<String, Object>> getBreachedTickets(int limit) {
        return slaTrackingDao.getBreachedTickets(limit);
    }

    public List<Map<String, Object>> getBreachedTickets(int limit, java.sql.Date from, java.sql.Date to, Integer categoryId, Integer locationId) {
        return slaTrackingDao.getBreachedTickets(limit, from, to, categoryId, locationId);
    }

    public List<Map<String, Object>> getNearBreachTickets(int limit) {
        return slaTrackingDao.getNearBreachTickets(limit);
    }

    public List<Map<String, Object>> getNearBreachTickets(int limit, java.sql.Date from, java.sql.Date to, Integer categoryId, Integer locationId) {
        return slaTrackingDao.getNearBreachTickets(limit, from, to, categoryId, locationId);
    }

    public List<Map<String, Object>> getBreachList(String team, String priority, String agent,
            String status, String sortBy, int offset, int limit) {
        return slaTrackingDao.getBreachList(team, priority, agent, status, sortBy, offset, limit);
    }

    public int countBreachList(String team, String priority, String agent, String status) {
        return slaTrackingDao.countBreachList(team, priority, agent, status);
    }

    public Map<String, Integer> getTicketTypeDistribution(java.sql.Date from, java.sql.Date to, Integer categoryId, Integer locationId) {
        return slaTrackingDao.getTicketTypeDistribution(from, to, categoryId, locationId);
    }

    public void runEscalationSweep() {
        slaTrackingDao.markBreachedTickets();
        if (!slaTrackingDao.isEscalationHistoryEnabled()) {
            return;
        }

        List<Integer> managerIds = userDao.getActiveUserIdsByRoles(Arrays.asList("Manager"));
        List<Map<String, Object>> candidates = slaTrackingDao.getEscalationCandidates();
        for (Map<String, Object> item : candidates) {
            processEscalationCandidate(item, managerIds);
        }
    }

    private void processEscalationCandidate(Map<String, Object> item, List<Integer> managerIds) {
        Integer ticketId = toInteger(item.get("TicketId"));
        Date deadline = toDate(item.get("ResolutionDeadline"));
        Integer remainingMinutes = toInteger(item.get("RemainingMinutes"));
        if (ticketId == null || deadline == null || remainingMinutes == null) {
            return;
        }

        Integer assignedTo = toInteger(item.get("AssignedTo"));
        Integer createdBy = toInteger(item.get("CreatedBy"));
        List<Integer> recipients = collectRecipientUserIds(createdBy, assignedTo, managerIds);

        if (remainingMinutes < 0) {
            String title = "SLA Breached: " + getTicketDisplay(item, ticketId);
            String message = "Ticket " + getTicketDisplay(item, ticketId)
                    + " da breach SLA (deadline: " + formatDateTime(deadline) + ")."
                    + " Vui long uu tien xu ly ngay.";
            triggerEscalation(item, "BREACHED", "SLA breached", deadline, remainingMinutes,
                    recipients, title, message, "ESCALATE_TO_MANAGER", "Manager", null);
            return;
        }

        if (remainingMinutes <= 30) {
            String title = "SLA Warning (30m): " + getTicketDisplay(item, ticketId);
            String message = "Ticket " + getTicketDisplay(item, ticketId)
                    + " con " + Math.max(0, remainingMinutes)
                    + " phut truoc han SLA. Can hoan tat gap.";
            triggerEscalation(item, "NEAR_BREACH_30M", "Near breach 30m", deadline, remainingMinutes,
                    recipients, title, message, null, "Manager", null);
            return;
        }

        if (remainingMinutes <= 120) {
            String title = "SLA Warning (2h): " + getTicketDisplay(item, ticketId);
            String message = "Ticket " + getTicketDisplay(item, ticketId)
                    + " dang sap breach SLA. Con " + remainingMinutes + " phut.";
            triggerEscalation(item, "NEAR_BREACH_2H", "Near breach 2h", deadline, remainingMinutes,
                    recipients, title, message, null, "Manager", null);
        }
    }

    private void triggerEscalation(Map<String, Object> item,
            String stageCode,
            String stageLabel,
            Date deadline,
            Integer remainingMinutes,
            List<Integer> recipientUserIds,
            String notificationTitle,
            String notificationMessage,
            String autoAction,
            String escalatedToRole,
            Integer escalatedToUserId) {
        Integer ticketId = toInteger(item.get("TicketId"));
        if (ticketId == null || recipientUserIds == null || recipientUserIds.isEmpty()) {
            return;
        }
        if (slaTrackingDao.hasEscalationHistory(ticketId, stageCode, deadline)) {
            return;
        }

        int sentCount = 0;
        for (Integer recipientId : recipientUserIds) {
            if (recipientId == null || recipientId <= 0) {
                continue;
            }
            boolean sent = notificationDao.addNotification(
                    recipientId,
                    notificationMessage,
                    ticketId,
                    false,
                    notificationTitle,
                    "Ticket");
            if (sent) {
                sentCount++;
            }
        }
        if (sentCount <= 0) {
            return;
        }

        String notificationTargetType = recipientUserIds.size() == 1 ? "USER" : "GROUP";
        Integer notificationTargetId = recipientUserIds.size() == 1 ? recipientUserIds.get(0) : null;

        slaTrackingDao.addEscalationHistory(
                ticketId, stageCode, stageLabel, deadline, remainingMinutes,
                notificationTargetType, notificationTargetId, notificationTitle, notificationMessage,
                autoAction, escalatedToRole, escalatedToUserId);
    }

    private List<Integer> collectRecipientUserIds(Integer createdBy, Integer assignedTo, List<Integer> managerIds) {
        Set<Integer> recipients = new LinkedHashSet<>();
        if (createdBy != null && createdBy > 0) {
            recipients.add(createdBy);
        }
        if (assignedTo != null && assignedTo > 0) {
            recipients.add(assignedTo);
        }
        if (managerIds != null) {
            for (Integer managerId : managerIds) {
                if (managerId != null && managerId > 0) {
                    recipients.add(managerId);
                }
            }
        }
        return new ArrayList<>(recipients);
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
        return (value instanceof Date) ? (Date) value : null;
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
