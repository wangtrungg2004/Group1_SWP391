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

    // 1. Lấy tham số tìm kiếm, bộ lọc và trang hiện tại
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
    TicketDao ticketDao = new TicketDao();

    // 2. Thực hiện truy vấn Server-side với các tham số bộ lọc
    int totalTickets = ticketDao.getTotalTicketsCount(currentUser.getId(), search, status, type);
    int totalPages = (int) Math.ceil((double) totalTickets / pageSize);
    List<Tickets> myTicketList = ticketDao.getTicketsByCreator(currentUser.getId(), offset, pageSize, search, status, type);
    
    // 3. Lấy KPI và đẩy dữ liệu lên View
    request.setAttribute("kpis", ticketDao.getUserTicketKPIs(currentUser.getId()));
    request.setAttribute("myTicketList", myTicketList);
    request.setAttribute("currentPage", page);
    request.setAttribute("totalPages", totalPages);
    
    // Giữ lại trạng thái bộ lọc trên giao diện
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
