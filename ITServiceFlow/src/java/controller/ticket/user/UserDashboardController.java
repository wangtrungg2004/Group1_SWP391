package controller.ticket.user;


import dao.TicketDAO;
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

        if (currentUser == null || role == null || (!role.equals("Manager") && !role.equals("User"))) {
            response.sendRedirect(request.getContextPath() + "/Login.jsp");
            return;
        }

        TicketDAO ticketDao = new TicketDAO();
        
        List<Tickets> recentTickets = ticketDao.getTicketsByCreator(
            currentUser.getId(), 0, 5, "", "all", "all"
        );
        
        Map<String, Integer> kpis = ticketDao.getUserTicketKPIs(currentUser.getId());

        request.setAttribute("recentTickets", recentTickets);
        request.setAttribute("kpis", kpis);
        
        request.getRequestDispatcher("/UserDashboard.jsp").forward(request, response);
    }
}