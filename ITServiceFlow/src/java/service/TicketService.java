/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package service;

import dao.TicketDao;
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
        int ticketId = ticketDao.createTicket(ticket);

        if (ticketId > 0) {
            // 4. Apply SLA
            if (ticket.getPriorityId() != null && ticket.getPriorityId() > 0) {
                slaTrackingService.applySLARuleToTicket(ticketId, ticket.getTicketType(), ticket.getPriorityId());
            }
            return true;
        }
        return false;
<<<<<<< HEAD
        
=======
<<<<<<< HEAD
        
=======
<<<<<<< HEAD
    
=======
<<<<<<< HEAD
        return false;
=======
<<<<<<< HEAD
     
=======
<<<<<<< HEAD
       
>>>>>>> b5f2af4f1f8516f4efa1cf4f2223e16fbcd340f3
>>>>>>> 966b29719721540e67a1f1c02a14ac5a25f18dc5
>>>>>>> d964ee0d9be5877a86f0b424d259db0a76555507
>>>>>>> ece779355ca83a81f87be3e036dab2107b9fd596
>>>>>>> 6aa9f0b6a4ce1233c4a2880f9e492405f7cdac35
    }

    public Tickets getTicketById(int id) {
        return ticketDao.getTicketById(id);
<<<<<<< HEAD
=======
<<<<<<< HEAD
=======
<<<<<<< HEAD
=======
<<<<<<< HEAD
=======
<<<<<<< HEAD
=======
=======
>>>>>>> d2154b86978d31b564b8846d8826925bf10e211d
>>>>>>> b5f2af4f1f8516f4efa1cf4f2223e16fbcd340f3
>>>>>>> 966b29719721540e67a1f1c02a14ac5a25f18dc5
>>>>>>> d964ee0d9be5877a86f0b424d259db0a76555507
>>>>>>> ece779355ca83a81f87be3e036dab2107b9fd596
>>>>>>> 6aa9f0b6a4ce1233c4a2880f9e492405f7cdac35
    }
}
