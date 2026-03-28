/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package controller.ticket.user;

/**
 *
 * @author Dumb Trung
 */

import dao.CsatSurveyDAO;
import dao.TicketDAO;
import model.Tickets;
import model.Users;
import java.io.IOException;
import java.util.List;
import java.util.Set;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet(name = "MyTickets", urlPatterns = { "/Tickets" })
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

    String search = request.getParameter("search");
    if (search == null) search = "";
    
    String status = request.getParameter("status");
    if (status == null) status = "all";
    
    String type = request.getParameter("type");
    if (type == null) type = "all";
    
    int page = 1;
    int pageSize = 10;
    String pageStr = request.getParameter("page");
    if (pageStr != null && !pageStr.isEmpty()) {
        try { page = Integer.parseInt(pageStr); } catch (Exception e) { page = 1; }
    }
    
    int offset = (page - 1) * pageSize;
    TicketDAO ticketDao = new TicketDAO();

    int totalTickets = ticketDao.getTotalTicketsCount(currentUser.getId(), search, status, type);
    int totalPages = (int) Math.ceil((double) totalTickets / pageSize);
    List<Tickets> myTicketList = ticketDao.getTicketsByCreator(currentUser.getId(), offset, pageSize, search, status, type);
    
    request.setAttribute("kpis", ticketDao.getUserTicketKPIs(currentUser.getId()));
    request.setAttribute("myTicketList", myTicketList);
    request.setAttribute("currentPage", page);
    request.setAttribute("totalPages", totalPages);

    CsatSurveyDAO csatDao = new CsatSurveyDAO();
    Set<Integer> ratedTicketIds = csatDao.getSubmittedTicketIdsByUser(currentUser.getId());
    request.setAttribute("ratedTicketIds", ratedTicketIds);
    
    request.setAttribute("search", search); 
    request.setAttribute("selectedStatus", status);
    request.setAttribute("selectedType", type);
    
    request.getRequestDispatcher("/ticket/my_tickets.jsp").forward(request, response);
}

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        doGet(request, response);
    }
}