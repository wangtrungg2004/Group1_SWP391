package service;

import dao.ProblemDao;
import dao.TicketDAO;
import java.sql.Date;
import java.util.List;
import java.util.Map;
import model.Problems;
import model.Tickets;

/**
 * @author DELL
 */
public class TicketService {
    
    private TicketDAO ticketDao;
    private SLATrackingService slaTrackingService;

    public TicketService() {
        this.ticketDao = new TicketDAO();
        this.slaTrackingService = new SLATrackingService();
    }

    public List<Tickets> getAllTicket() {
        return ticketDao.getAllTickets();
    }

    public boolean createTicket(Tickets ticket) {
        // 1. Generate Ticket Number if missing
        if (ticket.getTicketNumber() == null || ticket.getTicketNumber().isEmpty()) {
            ticket.setTicketNumber(ticketDao.getNextTicketNumber(ticket.getTicketType()));
        }

        // 2. Ensure default status for insert paths using createTicket2()
        if (ticket.getStatus() == null || ticket.getStatus().trim().isEmpty()) {
            ticket.setStatus("New");
        }

        // 3. Create Ticket
        int ticketId = ticketDao.createTicket2(ticket);

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
    
    public List<Tickets> getIncidentsNotInProblem()
    {
        return ticketDao.getIncidentsNotInProblem();
    }
    
    public List<Tickets> searchIncidentsNotProblem(String keyword)
    {
        return ticketDao.searchIncidentsNotInProblem(keyword);
    }
    
    public int getTotalTicket()
    {
        return ticketDao.getTotalTicket();
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
}
