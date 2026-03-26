/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */
package controller.SLA;

import java.io.IOException;
import java.io.PrintWriter;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.util.List;
import java.util.Map;
import service.SLATrackingService;

/**
 *
 * @author DELL
 */
@WebServlet(name = "SLADashboard", urlPatterns = { "/SLADashboard" })
public class SLADashboard extends HttpServlet {

    private SLATrackingService slaTrackingService = new SLATrackingService();

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

        // Get Statistics
        Map<String, Integer> stats = slaTrackingService.getSLAStatistics();
        request.setAttribute("stats", stats);

        // Calculate Compliance Rate
        int total = stats.getOrDefault("TotalTracked", 0);
        int breached = stats.getOrDefault("Breached", 0);
        double complianceRate = total > 0 ? ((double) (total - breached) / total) * 100 : 100.0;
        request.setAttribute("complianceRate", String.format("%.1f", complianceRate));

        // Get Ticket Lists
        List<Map<String, Object>> nearBreachTickets = slaTrackingService.getNearBreachTickets(10);
        List<Map<String, Object>> breachedTickets = slaTrackingService.getBreachedTickets(10);

        request.setAttribute("nearBreachTickets", nearBreachTickets);
        request.setAttribute("breachedTickets", breachedTickets);

        request.getRequestDispatcher("sla-dashboard.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        doGet(request, response);
    }
}
