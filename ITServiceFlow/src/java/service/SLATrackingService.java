/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package service;

import dao.SLARuleDao;
import dao.SLATrackingDao;
import java.util.Calendar;
import java.util.Date;
import java.util.List;
import model.SLARule;
import model.SLATracking;

/**
 *
 * @author DELL
 */
public class SLATrackingService {
    private SLATrackingDao slaTrackingDao;
    private SLARuleDao slaRuleDao;

    public SLATrackingService() {
        this.slaTrackingDao = new SLATrackingDao();
        this.slaRuleDao = new SLARuleDao();
    }

    public void applySLARuleToTicket(int ticketId, String ticketType, int priorityId) {
        // 1. Find matching SLA Rule
<<<<<<< HEAD
        SLARule matchedRule = slaRuleDao.getActiveRuleByTypeAndPriority(ticketType, priorityId);
=======
<<<<<<< HEAD
        SLARule matchedRule = slaRuleDao.getActiveRuleByTypeAndPriority(ticketType, priorityId);
=======
<<<<<<< HEAD
        SLARule matchedRule = slaRuleDao.getActiveRuleByTypeAndPriority(ticketType, priorityId);
=======
        List<SLARule> rules = slaRuleDao.getAllSLARules(); // In real scenario, filter by Type/Priority
        SLARule matchedRule = null;

        for (SLARule rule : rules) {
            if ("Active".equals(rule.getStatus()) &&
                    rule.getTicketType().equalsIgnoreCase(ticketType) &&
                    rule.getPriorityId() == priorityId) {
                matchedRule = rule;
                break;
            }
        }
>>>>>>> 1763278990a4a240d89ada2a865acfd8b2595d22
>>>>>>> 21fb2ceca814b602237c1a9239d60577738016e8
>>>>>>> 3dd5aa557803e4dbc9a9b39c17449ccda9d3d815

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
<<<<<<< HEAD

    public java.util.Map<String, Integer> getSLAStatistics() {
        return slaTrackingDao.getSLAStatistics();
    }

    public java.util.List<java.util.Map<String, Object>> getBreachedTickets(int limit) {
        return slaTrackingDao.getBreachedTickets(limit);
    }

    public java.util.List<java.util.Map<String, Object>> getNearBreachTickets(int limit) {
        return slaTrackingDao.getNearBreachTickets(limit);
    }
=======
>>>>>>> 3dd5aa557803e4dbc9a9b39c17449ccda9d3d815
}
