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
import java.util.Map;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet(name = "UserDashboard", urlPatterns = {"/UserDashboard"})
public class UserDashboardController extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        HttpSession session = request.getSession();
        Users currentUser = (Users) session.getAttribute("user");
        String role = (String) session.getAttribute("role");

        // Kiểm tra bảo mật ngay tại "cửa ngõ" Controller
        if (currentUser == null || role == null || (!role.equals("Manager") && !role.equals("User"))) {
            response.sendRedirect(request.getContextPath() + "/Login.jsp");
            return;
        }

        TicketDao ticketDao = new TicketDao();
        
        // Lấy 5 vé gần nhất cho Dashboard (Server-side)
        List<Tickets> recentTickets = ticketDao.getTicketsByCreator(currentUser.getId(), 0, 5, "");
        
        // Lấy các con số thống kê KPI
        Map<String, Integer> kpis = ticketDao.getUserTicketKPIs(currentUser.getId());

        // Đẩy toàn bộ dữ liệu ra request attribute để JSP sử dụng qua EL
        request.setAttribute("recentTickets", recentTickets);
        request.setAttribute("kpis", kpis);
        
        request.getRequestDispatcher("/UserDashboard.jsp").forward(request, response);
    }
}
