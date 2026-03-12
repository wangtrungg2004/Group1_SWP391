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
<<<<<<< HEAD
=======
<<<<<<< HEAD
>>>>>>> b5f2af4f1f8516f4efa1cf4f2223e16fbcd340f3

    public java.util.List<java.util.Map<String, Object>> getBreachList(String team, String priority, String agent,
            String status, String sortBy, int offset, int limit) {
        return slaTrackingDao.getBreachList(team, priority, agent, status, sortBy, offset, limit);
    }
<<<<<<< HEAD
=======
=======
>>>>>>> d2154b86978d31b564b8846d8826925bf10e211d
>>>>>>> b5f2af4f1f8516f4efa1cf4f2223e16fbcd340f3
}
