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

    public java.util.Map<String, Integer> getSLAStatistics(java.sql.Date from, java.sql.Date to, Integer categoryId, Integer locationId) {
        return slaTrackingDao.getSLAStatistics(from, to, categoryId, locationId);
    }

    public java.util.List<java.util.Map<String, Object>> getBreachedTickets(int limit, java.sql.Date from, java.sql.Date to, Integer categoryId, Integer locationId) {
        return slaTrackingDao.getBreachedTickets(limit, from, to, categoryId, locationId);
    }

    public java.util.List<java.util.Map<String, Object>> getNearBreachTickets(int limit, java.sql.Date from, java.sql.Date to, Integer categoryId, Integer locationId) {
        return slaTrackingDao.getNearBreachTickets(limit, from, to, categoryId, locationId);
    }

    public java.util.List<java.util.Map<String, Object>> getBreachList(String team, String priority, String agent,
            String status, String sortBy, int offset, int limit) {
        return slaTrackingDao.getBreachList(team, priority, agent, status, sortBy, offset, limit);
    }

    public int countBreachList(String team, String priority, String agent, String status) {
        return slaTrackingDao.countBreachList(team, priority, agent, status);
    }

    public java.util.Map<String, Integer> getTicketTypeDistribution(java.sql.Date from, java.sql.Date to, Integer categoryId, Integer locationId) {
        return slaTrackingDao.getTicketTypeDistribution(from, to, categoryId, locationId);
    }
}
