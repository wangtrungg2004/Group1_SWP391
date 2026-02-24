/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package service;
import dao.ProblemDao;
import java.sql.Date;
import java.util.List;
import model.Problems;
import model.Tickets;
import dao.TicketDao;
/**
 *
 * @author DELL
 */
public class TicketService {
    private TicketDao dao = new TicketDao();
    
    public List<Tickets> getAllTicket()
    {
        return dao.getAllTickets();
    }
}
