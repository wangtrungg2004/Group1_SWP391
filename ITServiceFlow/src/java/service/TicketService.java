/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package service;

import dao.TicketDao;
import java.util.List;
import java.util.Map;
import model.Tickets;

/**
 *
 * @author DELL
 */
public class TicketService {
    private TicketDao ticketDao;
    private SLATrackingService slaTrackingService;

    public TicketService() {
        this.ticketDao = new TicketDao();
        this.slaTrackingService = new SLATrackingService();
    }

    public boolean createTicket(Tickets ticket) {
        // 1. Generate Ticket Number if missing
        if (ticket.getTicketNumber() == null || ticket.getTicketNumber().isEmpty()) {
            ticket.setTicketNumber(ticketDao.getNextTicketNumber(ticket.getTicketType()));
        }

        // 2. Determine Priority if Impact/Urgency provided (Logic could be here or DB)
        // For now assuming PriorityId is set or derived in controller

        // 3. Create Ticket
        int ticketId = Integer.parseInt(ticketDao.createTicket(ticket));

        if (ticketId > 0) {
            // 4. Apply SLA
            if (ticket.getPriorityId() != null && ticket.getPriorityId() > 0) {
                slaTrackingService.applySLARuleToTicket(ticketId, ticket.getTicketType(), ticket.getPriorityId());
            }
            return true;
        }
        return false;
        
    }

    public Tickets getTicketById(int id) {
        return ticketDao.getTicketById(id);
    }
     public int getTotalTicket()
    {
        return ticketDao.getTotalTicket();
    }
     
    public List<Tickets> getAllTicket() {
        return ticketDao.getAllTickets();
    }
    
    public int getTotalTicketThisMonth()
    {
        return ticketDao.getTotalTicketThisMonth();
    }
    
    public Map<String, Object> getTicketChartLast6Months() {
        return ticketDao.getTicketStatsLast6Months();
    }
    
    public List<Tickets> get10UnAssignedTicket()
    {
        return ticketDao.get10UnassignedTickets();
    }
      public List<Tickets> getIncidentsNotInProblem()
    {
        return ticketDao.getIncidentsNotInProblem();
    }
    
    public List<Tickets> searchIncidentsNotProblem(String keyword)
    {
        return ticketDao.searchIncidentsNotInProblem(keyword);
    }
}
