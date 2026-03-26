package service;

import dao.TicketDAO;
import java.util.List;
import java.util.Map;
import model.Tickets;

public class TicketService {

    private final TicketDAO ticketDao;
    private final SLATrackingService slaTrackingService;

    public TicketService() {
        this.ticketDao = new TicketDAO();
        this.slaTrackingService = new SLATrackingService();
    }

    public List<Tickets> getAllTicket() {
        return ticketDao.getAllTickets();
    }

    public boolean createTicket(Tickets ticket) {
        if (ticket.getTicketNumber() == null || ticket.getTicketNumber().isEmpty()) {
            ticket.setTicketNumber(ticketDao.getNextTicketNumber(ticket.getTicketType()));
        }

        int ticketId = ticketDao.createTicket(ticket);
        if (ticketId > 0) {
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

    public List<Tickets> getIncidentsNotInProblem() {
        return ticketDao.getIncidentsNotInProblem();
    }

    public List<Tickets> searchIncidentsNotProblem(String keyword) {
        return ticketDao.searchIncidentsNotInProblem(keyword);
    }

    public int getTotalTicket() {
        return ticketDao.getTotalTicket();
    }

    public int getTotalTicketThisMonth() {
        return ticketDao.getTotalTicketThisMonth();
    }

    public Map<String, Object> getTicketChartLast6Months() {
        return ticketDao.getTicketStatsLast6Months();
    }

    public List<Tickets> get10UnAssignedTicket() {
        return ticketDao.get10UnassignedTickets();
    }
}
