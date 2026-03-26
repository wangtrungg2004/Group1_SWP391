/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */
package controller;

import java.io.IOException;
import java.sql.Date;
import java.util.Calendar;
import java.util.List;
import java.util.Map;
import dao.GeneralDao;
import dao.SLATrackingDao;
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
    private GeneralDao generalDao = new GeneralDao();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession();
        if (session.getAttribute("user") == null) {
            response.sendRedirect("Login.jsp");
            return;
        }

        // Default to current month
        Calendar cal = Calendar.getInstance();
        int month = cal.get(Calendar.MONTH) + 1;
        int year = cal.get(Calendar.YEAR);

        String monthParam = request.getParameter("month");
        String yearParam = request.getParameter("year");
        String locParam = request.getParameter("locationId");

        if (monthParam != null && !monthParam.isEmpty()) {
            month = Integer.parseInt(monthParam);
        }
        if (yearParam != null && !yearParam.isEmpty()) {
            year = Integer.parseInt(yearParam);
        }
        Integer locationId = (locParam != null && !locParam.isEmpty()) ? Integer.parseInt(locParam) : null;

        // Calculate Date Range for the month
        Calendar firstDay = Calendar.getInstance();
        firstDay.set(year, month - 1, 1, 0, 0, 0);
        firstDay.set(Calendar.MILLISECOND, 0);
        Date fromDate = new Date(firstDay.getTimeInMillis());

        Calendar lastDay = Calendar.getInstance();
        lastDay.set(year, month, 1, 0, 0, 0); // First day of next month
        lastDay.set(Calendar.MILLISECOND, 0);
        Date toDate = new Date(lastDay.getTimeInMillis());

        List<Map<String, Object>> agentStats = slaDao.getAgentPerformanceStats(fromDate, toDate, null, locationId);

        request.setAttribute("agentStats", agentStats);
        request.setAttribute("currentMonth", month);
        request.setAttribute("currentYear", year);
        request.setAttribute("locationId", locationId);
        
        request.setAttribute("locations", generalDao.getLocations());

        request.getRequestDispatcher("agent-performance-report.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        doGet(request, response);
    }
}
