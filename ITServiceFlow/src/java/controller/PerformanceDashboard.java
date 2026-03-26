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
@WebServlet(name = "PerformanceDashboard", urlPatterns = { "/PerformanceDashboard" })
public class PerformanceDashboard extends HttpServlet {

    private SLATrackingDao slaDao = new SLATrackingDao();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession();
        if (session.getAttribute("user") == null) {
            response.sendRedirect("Login.jsp");
            return;
        }

        // Default Date Range: Last 30 Days
        Date toDate = new Date(System.currentTimeMillis());
        Calendar cal = Calendar.getInstance();
        cal.add(Calendar.DAY_OF_MONTH, -30);
        Date fromDate = new Date(cal.getTimeInMillis());

        String fromParam = request.getParameter("from");
        String toParam = request.getParameter("to");

        if (fromParam != null && !fromParam.isEmpty()) {
            try {
                fromDate = Date.valueOf(fromParam);
            } catch (IllegalArgumentException e) {
                // Ignore, keep default
            }
        }
        if (toParam != null && !toParam.isEmpty()) {
            try {
                toDate = Date.valueOf(toParam);
            } catch (IllegalArgumentException e) {
                // Ignore, keep default
            }
        }

        Map<String, Object> performanceStats = slaDao.getPerformanceStats(fromDate, toDate);
        Map<String, Object> complianceStats = slaDao.getSLAComplianceStats(fromDate, toDate);
        java.util.List<Map<String, Object>> trendData = slaDao.getTrendData(fromDate, toDate);

        request.setAttribute("performanceStats", performanceStats);
        request.setAttribute("complianceStats", complianceStats);
        request.setAttribute("trendData", trendData);

        request.setAttribute("fromDate", fromDate);
        request.setAttribute("toDate", toDate);

        request.getRequestDispatcher("performance-dashboard.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        doGet(request, response);
    }
}
