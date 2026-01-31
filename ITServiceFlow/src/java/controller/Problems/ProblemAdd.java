/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */
package controller.Problems;

import java.io.IOException;
import java.io.PrintWriter;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import service.ProblemService;
/**
 *
 * @author DELL
 */
public class ProblemAdd extends HttpServlet {

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
            out.println("<title>Servlet ProblemAdd</title>");
            out.println("</head>");
            out.println("<body>");
            out.println("<h1>Servlet ProblemAdd at " + request.getContextPath() + "</h1>");
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
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.getRequestDispatcher("ProblemAdd.jsp").forward(request, response);
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

        String Title = request.getParameter("Title");
        String Description = request.getParameter("Description");
        String RootCause = request.getParameter("RootCause");
        String Workaround = request.getParameter("Workaround");
        String Status = request.getParameter("Status");
        String assignedToStr = request.getParameter("AssignedTo");

        int assignedTo = 0;
        if (assignedToStr != null && !assignedToStr.trim().isEmpty()) {
            try {
                assignedTo = Integer.parseInt(assignedToStr.trim());
            } catch (NumberFormatException e) {
                request.setAttribute("error", "Invalid Assigned To ID.");
                request.getRequestDispatcher("ProblemAdd.jsp").forward(request, response);
                return;
            }
        }

        HttpSession session = request.getSession();
        Integer userId = (Integer) session.getAttribute("userId");
        int createdBy = (userId != null) ? userId : 1;

        
        java.sql.Date createdAt = new java.sql.Date(System.currentTimeMillis());
        
        boolean success = problemService.insertProblem(
            null,
            Title,
            Description,
            RootCause,
            Workaround,
            Status,
            createdBy,
            assignedTo,
            createdAt
        );
        
        if (success) {
            response.sendRedirect("ProblemList?success=Problem added successfully!");
        } else {
            request.setAttribute("error", "Failed to add problem. Please try again.");
            request.getRequestDispatcher("ProblemAdd.jsp").forward(request, response);
        }
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
