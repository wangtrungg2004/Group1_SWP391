/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package controller.ticket.user;

/**
 *
 * @author Dumb Trung
 */
import dao.TicketDao;
import model.Tickets;
import model.Users;
import java.io.IOException;
import java.util.List;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.util.Map;

@WebServlet(name = "MyTickets", urlPatterns = {"/Tickets"})
public class MyTicketsController extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        HttpSession session = request.getSession();
        Users currentUser = (Users) session.getAttribute("user");
        
        if (currentUser == null) {
            response.sendRedirect(request.getContextPath() + "/Login.jsp");
            return;
        }

        int page = 1;
        int pageSize = 10; 
        
        String pageStr = request.getParameter("page");
        if (pageStr != null && !pageStr.isEmpty()) {
            try {
                page = Integer.parseInt(pageStr);
            } catch (NumberFormatException e) {
                page = 1;
            }
        }
        
        int offset = (page - 1) * pageSize;

        TicketDao ticketDao = new TicketDao();
        
        List<Tickets> myTicketList = ticketDao.getTicketsByCreator(currentUser.getId(), offset, pageSize);
        
        Map<String, Integer> kpis = ticketDao.getUserTicketKPIs(currentUser.getId());
        
        request.setAttribute("kpis", kpis);
        request.setAttribute("myTicketList", myTicketList);
        request.setAttribute("currentPage", page); 
        
        request.getRequestDispatcher("/ticket/my_tickets.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        doGet(request, response);
    }
}
