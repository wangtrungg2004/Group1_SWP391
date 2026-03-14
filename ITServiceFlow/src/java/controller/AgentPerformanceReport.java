/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */
package controller;

import dao.SLATrackingDao;
import java.io.IOException;
import java.sql.Date;
import java.util.Calendar;
import java.util.Map;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

/**
 *
 * @author DELL
 */
@WebServlet(name = "AgentPerformanceReport", urlPatterns = { "/AgentPerformanceReport" })
public class AgentPerformanceReport extends HttpServlet {

    private SLATrackingDao slaDao = new SLATrackingDao();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession();
        if (session.getAttribute("user") == null) {
            response.sendRedirect("Login.jsp");
            return;
        }

        // Default: Current Month
        Calendar cal = Calendar.getInstance();
        int year = cal.get(Calendar.YEAR);
        int month = cal.get(Calendar.MONTH) + 1; // 1-12

        String yearParam = request.getParameter("year");
        String monthParam = request.getParameter("month");

        if (yearParam != null && !yearParam.isEmpty()) {
            try {
                year = Integer.parseInt(yearParam);
            } catch (NumberFormatException e) {
                // Ignore
            }
        }
        if (monthParam != null && !monthParam.isEmpty()) {
            try {
                month = Integer.parseInt(monthParam);
            } catch (NumberFormatException e) {
                // Ignore
            }
        }

        // Calculate Start and End Date of the Month
        cal.set(Calendar.YEAR, year);
        cal.set(Calendar.MONTH, month - 1);
        cal.set(Calendar.DAY_OF_MONTH, 1);
        Date fromDate = new Date(cal.getTimeInMillis());

        cal.set(Calendar.DAY_OF_MONTH, cal.getActualMaximum(Calendar.DAY_OF_MONTH));
        Date toDate = new Date(cal.getTimeInMillis());

        java.util.List<Map<String, Object>> agentStats = slaDao.getAgentPerformanceStats(fromDate, toDate);

        request.setAttribute("agentStats", agentStats);
        request.setAttribute("year", year);
        request.setAttribute("month", month);

        request.getRequestDispatcher("agent-performance-report.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        doGet(request, response);
    }
}
