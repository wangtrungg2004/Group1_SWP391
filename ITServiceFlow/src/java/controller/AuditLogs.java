/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */
package controller;

import dao.AuditLogDao;
import model.AuditLog;
import java.io.IOException;
import java.sql.Date;
import java.util.List;
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
@WebServlet(name = "AuditLogs", urlPatterns = { "/AuditLogs" })
public class AuditLogs extends HttpServlet {

    private AuditLogDao auditLogDao = new AuditLogDao();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession();
        if (session.getAttribute("user") == null) {
            response.sendRedirect("Login.jsp");
            return;
        }
        // Permission check can be added here (e.g., only Admin can view logs)

        String user = request.getParameter("user");
        String action = request.getParameter("action");
        String fromStr = request.getParameter("from");
        String toStr = request.getParameter("to");
        int page = 1;

        if (request.getParameter("page") != null) {
            try {
                page = Integer.parseInt(request.getParameter("page"));
            } catch (NumberFormatException e) {
                // Ignore
            }
        }

        Date from = null;
        Date to = null;
        if (fromStr != null && !fromStr.isEmpty()) {
            try {
                from = Date.valueOf(fromStr);
            } catch (Exception e) {
            }
        }
        if (toStr != null && !toStr.isEmpty()) {
            try {
                to = Date.valueOf(toStr);
            } catch (Exception e) {
            }
        }

        int pageSize = 15;
        int offset = (page - 1) * pageSize;

        List<AuditLog> logs = auditLogDao.getLogs(user, action, from, to, offset, pageSize);
        int totalLogs = auditLogDao.getTotalLogs(user, action, from, to);
        int totalPages = (int) Math.ceil((double) totalLogs / pageSize);

        request.setAttribute("logs", logs);
        request.setAttribute("currentPage", page);
        request.setAttribute("totalPages", totalPages);
        request.setAttribute("user", user);
        request.setAttribute("action", action);
        request.setAttribute("from", fromStr);
        request.setAttribute("to", toStr);

        request.getRequestDispatcher("audit-logs.jsp").forward(request, response);
    }
}
