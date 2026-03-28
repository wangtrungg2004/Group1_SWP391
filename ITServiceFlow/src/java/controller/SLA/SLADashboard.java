package controller.SLA;

import java.io.IOException;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.util.List;
import java.util.Map;
import service.SLATrackingService;

@WebServlet(name = "SLADashboard", urlPatterns = { "/SLADashboard" })
public class SLADashboard extends HttpServlet {

    private SLATrackingService slaTrackingService = new SLATrackingService();
    private dao.GeneralDao generalDao = new dao.GeneralDao();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession();
        String role = (String) session.getAttribute("role");

        // Only Admin and Manager can access
        if (role == null || (!"Admin".equals(role) && !"Manager".equals(role))) {
            response.sendRedirect("Login.jsp");
            return;
        }

        slaTrackingService.runEscalationSweep();

        // Default Date Range: Last 30 Days 
        java.sql.Date toDate = new java.sql.Date(System.currentTimeMillis());
        java.util.Calendar cal = java.util.Calendar.getInstance();
        cal.add(java.util.Calendar.DAY_OF_MONTH, -30); 
        java.sql.Date fromDate = new java.sql.Date(cal.getTimeInMillis());

        String fromParam = request.getParameter("from");
        String toParam = request.getParameter("to");
        String catParam = request.getParameter("categoryId");
        String locParam = request.getParameter("locationId");

        Integer categoryId = (catParam != null && !catParam.isEmpty()) ? Integer.parseInt(catParam) : null;
        Integer locationId = (locParam != null && !locParam.isEmpty()) ? Integer.parseInt(locParam) : null;

        if (fromParam != null && !fromParam.isEmpty()) {
            try { fromDate = java.sql.Date.valueOf(fromParam); } catch (Exception e) {}
        }
        if (toParam != null && !toParam.isEmpty()) {
            try { toDate = java.sql.Date.valueOf(toParam); } catch (Exception e) {}
        }

        java.util.Calendar endCal = java.util.Calendar.getInstance();
        endCal.setTime(toDate);
        endCal.add(java.util.Calendar.DAY_OF_MONTH, 1);
        java.sql.Date queryToDate = new java.sql.Date(endCal.getTimeInMillis());

        // Get Statistics (Dùng queryToDate thay vì toDate)
        Map<String, Integer> stats = slaTrackingService.getSLAStatistics(fromDate, queryToDate, categoryId, locationId);
        request.setAttribute("stats", stats);

        // Calculate Compliance Rate
        int total = stats.getOrDefault("TotalTracked", 0);
        int breached = stats.getOrDefault("Breached", 0);
        double complianceRate = total > 0 ? ((double) (total - breached) / total) * 100 : 100.0;
        request.setAttribute("complianceRate", String.format("%.1f", complianceRate));

        // Get Ticket Lists 
        List<Map<String, Object>> nearBreachTickets = slaTrackingService.getNearBreachTickets(10, fromDate, queryToDate, categoryId, locationId);
        List<Map<String, Object>> breachedTickets = slaTrackingService.getBreachedTickets(10, fromDate, queryToDate, categoryId, locationId);

        request.setAttribute("nearBreachTickets", nearBreachTickets);
        request.setAttribute("breachedTickets", breachedTickets);

        // Get Ticket Type Distribution for Pie Chart
        java.util.Map<String, Integer> ticketTypeStats = slaTrackingService.getTicketTypeDistribution(fromDate, queryToDate, categoryId, locationId);
        request.setAttribute("ticketTypeStats", ticketTypeStats);
        
        // Metadata for filters
        request.setAttribute("categories", generalDao.getCategories());
        request.setAttribute("locations", generalDao.getLocations());
        
        // Keep parameters
        request.setAttribute("fromDate", fromDate);
        request.setAttribute("toDate", toDate);
        request.setAttribute("categoryId", categoryId);
        request.setAttribute("locationId", locationId);

        request.getRequestDispatcher("sla-dashboard.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        doGet(request, response);
    }
}
