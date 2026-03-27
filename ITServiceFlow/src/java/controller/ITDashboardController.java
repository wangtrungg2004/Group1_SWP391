package controller;

import dao.ProblemDao;
import dao.TicketDAO;
import model.Tickets;
import model.Users;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.util.List;
import java.util.Map;

/**
 * Controller cho IT Support Dashboard.
 * URL: /ITDashboard
 * Role: IT Support
 *
 * Load data thực từ DB:
 *  - agentKPIs     : Map KPI cá nhân (myNew, myInProgress, myResolved, myTotal, slaBreaching)
 *  - recentTickets : 5 ticket gần nhất assign cho agent
 *  - urgentTickets : ticket sắp breach SLA (dùng lại từ SLATracking)
 *  - myProblems    : số problem đang assign cho agent này
 */
@WebServlet(name = "ITDashboardController", urlPatterns = {"/ITDashboard"})
public class ITDashboardController extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null) {
            response.sendRedirect(request.getContextPath() + "/Login.jsp");
            return;
        }

        Users user = (Users) session.getAttribute("user");
        String role = (String) session.getAttribute("role");

        if (user == null || !"IT Support".equals(role)) {
            response.sendRedirect(request.getContextPath() + "/Login.jsp");
            return;
        }

        int agentId = user.getId();
        TicketDAO ticketDAO = new TicketDAO();
        ProblemDao problemDao = new ProblemDao();

        // 1. KPI cá nhân của agent
        Map<String, Integer> agentKPIs = ticketDAO.getAgentKPIs(agentId);

        // 2. 5 ticket gần nhất assign cho agent (đang mở)
        int currentLevel = ("Manager".equals(role) || "Admin".equals(role)) ? 2 : 1;
        List<Tickets> recentTickets = ticketDAO.getAgentQueues(
                agentId, currentLevel, "mine", 0, 5, "", "all", "all", "");

        // 3. Số problem đang assign cho agent
        int myProblems = problemDao.getTotalAssignProblems(agentId);

        request.setAttribute("agentKPIs",     agentKPIs);
        request.setAttribute("recentTickets", recentTickets);
        request.setAttribute("myProblems",    myProblems);

        request.getRequestDispatcher("/ITDashboard.jsp").forward(request, response);
    }
}