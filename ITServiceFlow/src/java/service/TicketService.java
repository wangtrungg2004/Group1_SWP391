package service;

import dao.ProblemDao;
import dao.TicketDao;
import java.sql.Date;
import java.util.List;
import model.Problems;
import model.Tickets;

/**
 * @author DELL
 */
public class TicketService {
    
    private TicketDao ticketDao;
    private SLATrackingService slaTrackingService;

    public TicketService() {
        this.ticketDao = new TicketDao();
        this.slaTrackingService = new SLATrackingService();
    }

    // Hàm lấy danh sách ticket (Của Minh)
    public List<Tickets> getAllTicket() {
        return ticketDao.getAllTickets();
    }

    // Hàm tạo ticket mới (Của HoangVN)
    public boolean createTicket(Tickets ticket) {
        // 1. Generate Ticket Number if missing
        if (ticket.getTicketNumber() == null || ticket.getTicketNumber().isEmpty()) {
            ticket.setTicketNumber(ticketDao.getNextTicketNumber(ticket.getTicketType()));
        }

        // 2. Create Ticket
        int ticketId = ticketDao.createTicket2(ticket);

        if (ticketId > 0) {
            // 3. Apply SLA
            if (ticket.getPriorityId() != null && ticket.getPriorityId() > 0) {
                slaTrackingService.applySLARuleToTicket(ticketId, ticket.getTicketType(), ticket.getPriorityId());
            }
            return true;
        }
        return false;
    }
    
    public List<Tickets> getIncidentsNotInProblem()
    {
        return ticketDao.getIncidentsNotInProblem();
    }
}