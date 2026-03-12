package controller.ticket.user;

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

        // 1. Kiểm tra bảo mật (Authentication & Authorization)
        if (currentUser == null || role == null || (!role.equals("Manager") && !role.equals("User"))) {
            response.sendRedirect(request.getContextPath() + "/Login.jsp");
            return;
        }

        TicketDao ticketDao = new TicketDao();
        
        // 2. Lấy 5 vé gần nhất (Offset 0, Limit 5)
        // CẬP NHẬT: Truyền đầy đủ các tham số lọc rỗng ("", "all", "all") để lấy toàn bộ vé mới nhất
        List<Tickets> recentTickets = ticketDao.getTicketsByCreator(
            currentUser.getId(), 0, 5, "", "all", "all"
        );
        
        // 3. Lấy dữ liệu thống kê cho các thẻ KPI
        Map<String, Integer> kpis = ticketDao.getUserTicketKPIs(currentUser.getId());

        // 4. Đẩy dữ liệu sang JSP thông qua Request Attribute
        request.setAttribute("recentTickets", recentTickets);
        request.setAttribute("kpis", kpis);
        
        request.getRequestDispatcher("/UserDashboard.jsp").forward(request, response);
    }
}