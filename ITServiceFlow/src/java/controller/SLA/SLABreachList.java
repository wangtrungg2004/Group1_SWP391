/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */
package controller.SLA;

import dao.SLARuleDao;

import java.io.IOException;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.util.List;
import java.util.Map;
import model.Priority;
import service.SLATrackingService;

/**
 *
 * @author DELL
 */
@WebServlet(name = "SLABreachList", urlPatterns = { "/SLABreachList" })
public class SLABreachList extends HttpServlet {

    private SLATrackingService slaTrackingService = new SLATrackingService();
    private SLARuleDao slaRuleDao = new SLARuleDao();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession();
        String role = (String) session.getAttribute("role");

        if (session.getAttribute("user") == null) {
            response.sendRedirect("Login.jsp");
            return;
        }


        // Only Admin and Manager can access this screen
        if (role == null || (!"Admin".equals(role) && !"Manager".equals(role))) {
            response.sendRedirect("Login.jsp");
            return;
        }


        // Get Parameters
        String searchAgent = request.getParameter("agent");
        String priority = request.getParameter("priority");
        String status = request.getParameter("status");
        String sortBy = request.getParameter("sortBy");
        String pageStr = request.getParameter("page");

        int page = 1;
        int limit = 10;

        if (pageStr != null && !pageStr.isEmpty()) {
            try {
                page = Integer.parseInt(pageStr);
            } catch (NumberFormatException e) {
                page = 1;
            }
        }
        int offset = (page - 1) * limit;

        // Get Data
        List<Map<String, Object>> tickets = slaTrackingService.getBreachList(null, priority, searchAgent, status,
                sortBy, offset, limit);


        int totalRecords = slaTrackingService.countBreachList(null, priority, searchAgent, status);
        int totalPages = (int) Math.ceil((double) totalRecords / limit);
        if (totalPages < 1)
            totalPages = 1;

        // Get Available Filters
        List<Priority> priorities = slaRuleDao.getAllPriorities();
        List<String> availableStatuses = slaRuleDao.getDistinctStatuses();


        // Set Attributes
        request.setAttribute("tickets", tickets);
        request.setAttribute("priorities", priorities);

        request.setAttribute("currentPage", page);
        // Note: Total pages calculation would require a count query, skipping for now
        // as per simplified requirement or adding later if needed.
        // For now, simple Previous/Next logic if list size == limit could be used, or
        // just simple list.

        request.setAttribute("availableStatuses", availableStatuses);
        request.setAttribute("currentPage", page);
        request.setAttribute("totalPages", totalPages);
        request.setAttribute("totalRecords", totalRecords);
        request.setAttribute("paramPriority", priority);
        request.setAttribute("paramStatus", status);
        request.setAttribute("paramAgent", searchAgent);


        request.getRequestDispatcher("sla-breach-list.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        doGet(request, response);
    }
}
