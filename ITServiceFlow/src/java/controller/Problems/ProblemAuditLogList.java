/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */
package controller.Problems;

import java.io.IOException;
import java.io.PrintWriter;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.util.List;
import model.AuditLog;
import model.Problems;
import service.AuditLogService;
import service.ProblemService;

/**
 *
 * @author DELL
 */
@WebServlet(name = "ProblemAuditLogList", urlPatterns = {"/ProblemAuditLogList"})
public class ProblemAuditLogList extends HttpServlet {

    /**
     * Processes requests for both HTTP <code>GET</code> and <code>POST</code>
     * methods.
     *
     * @param request servlet request
     * @param response servlet response
     * @throws ServletException if a servlet-specific error occurs
     * @throws IOException if an I/O error occurs
     */
    protected void processRequest(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.setContentType("text/html;charset=UTF-8");
        try (PrintWriter out = response.getWriter()) {
            /* TODO output your page here. You may use following sample code. */
            out.println("<!DOCTYPE html>");
            out.println("<html>");
            out.println("<head>");
            out.println("<title>Servlet ProblemAuditLogList</title>");
            out.println("</head>");
            out.println("<body>");
            out.println("<h1>Servlet ProblemAuditLogList at " + request.getContextPath() + "</h1>");
            out.println("</body>");
            out.println("</html>");
        }
    }

    // <editor-fold defaultstate="collapsed" desc="HttpServlet methods. Click on the + sign on the left to edit the code.">
    /**
     * Handles the HTTP <code>GET</code> method.
     *
     * @param request servlet request
     * @param response servlet response
     * @throws ServletException if a servlet-specific error occurs
     * @throws IOException if an I/O error occurs
     */
    ProblemService problemService = new ProblemService();
    AuditLogService auditlogService = new AuditLogService();
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession();
        String role = (String) session.getAttribute("role");
        Integer userId = (Integer) session.getAttribute("userId");
        
        String idParam = request.getParameter("Id");

        // Check id hợp lệ
        if (idParam == null || idParam.isEmpty()) {
            response.sendRedirect("ProblemList");
            return;
        }

        int proId;
        try {
            proId = Integer.parseInt(idParam);
        } catch (NumberFormatException e) {
            response.sendRedirect("ProblemList");
            return;
        }

        Problems pro = problemService.getProblemById(proId);

        // Check problem tồn tại
        if (pro == null) {
            response.sendRedirect("ProblemList");
            return;
        }

        List<AuditLog> auditLogs = auditlogService.viewActivitiesHistory("Problem", proId);

        request.setAttribute("problem", pro);
        request.setAttribute("auditLogs", auditLogs);

        request.getRequestDispatcher("ProblemAuditLogList.jsp").forward(request, response);
            
    }

    /**
     * Handles the HTTP <code>POST</code> method.
     *
     * @param request servlet request
     * @param response servlet response
     * @throws ServletException if a servlet-specific error occurs
     * @throws IOException if an I/O error occurs
     */
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        processRequest(request, response);
    }

    /**
     * Returns a short description of the servlet.
     *
     * @return a String containing servlet description
     */
    @Override
    public String getServletInfo() {
        return "Short description";
    }// </editor-fold>

}
