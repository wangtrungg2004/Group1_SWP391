/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */
package controller.KnowErrors;

import java.io.IOException;
import java.io.PrintWriter;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.util.ArrayList;
import java.util.List;
import model.Notifications;
import model.Problems;
import model.KnowErrors;
import service.ProblemService;
import service.NotificationService;
import service.KnowErrorService;
/**
 *
 * @author DELL
 */
@WebServlet(name = "KnowErrorList", urlPatterns = {"/KnowErrorList"})
public class KnowErrorList extends HttpServlet {

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
            out.println("<title>Servlet KnowErrorList</title>");
            out.println("</head>");
            out.println("<body>");
            out.println("<h1>Servlet KnowErrorList at " + request.getContextPath() + "</h1>");
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
    KnowErrorService knowErrorService = new KnowErrorService();
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession();
        String role = (String) session.getAttribute("role");
        String keyword = request.getParameter("keyword");
        boolean activeOnly = "User".equals(role);
        
        List<KnowErrors> knowError;
        if (keyword != null && !keyword.trim().isEmpty()) {
            knowError = knowErrorService.searchKnowError(keyword.trim(), activeOnly);
            request.setAttribute("filterKeyword", keyword.trim());
        } else {
            if (activeOnly) {
                knowError = knowErrorService.getAllActiveKnowError();
            } else {
                knowError = knowErrorService.getAllKnowError();
            }
        }
        request.setAttribute("knowError", knowError);
        request.getRequestDispatcher("KnowErrorList.jsp").forward(request, response);
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
        String knId = request.getParameter("Id");
        String Status = request.getParameter("status");
        if(knId != null)
        {
            int id = Integer.parseInt(knId);
            knowErrorService.closedKnowError(id, Status);
            response.sendRedirect("KnowErrorList");
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
