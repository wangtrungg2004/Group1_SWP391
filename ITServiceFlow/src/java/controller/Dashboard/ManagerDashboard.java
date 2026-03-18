/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */
package controller.Dashboard;

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


import model.Problems;
import model.Users;
import model.KnowErrors;
import model.Tickets;
import service.ApprovalService;
import service.ProblemService;
import service.SLATrackingService;
import service.TicketService;
import service.UserService;
/**
 *
 * @author DELL
 */
@WebServlet(name = "ManagerDashboard", urlPatterns = {"/ManagerDashboard"})
public class ManagerDashboard extends HttpServlet {

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
            out.println("<title>Servlet ManagerDashboard</title>");
            out.println("</head>");
            out.println("<body>");
            out.println("<h1>Servlet ManagerDashboard at " + request.getContextPath() + "</h1>");
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
    SLATrackingService slaService = new SLATrackingService();
    TicketService ticketService = new TicketService();
    ProblemService problemService = new ProblemService();
    ApprovalService approvalService = new ApprovalService();
    UserService userService = new UserService();
//    CsatSurveyService csatService = new CsatSurveyService();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession();
        Users user = (Users) session.getAttribute("user");
        String role = (String) session.getAttribute("role");
        if (user == null || !"Manager".equals(role)) {
            response.sendRedirect(request.getContextPath() + "/Login.jsp");
            return;
        }
        int totalProblem = problemService.getTotalProblem();
        int totalUsers = userService.getTotalUser();
        int totalTicket = ticketService.getTotalTicket();
        int totalTicketThisMonth = ticketService.getTotalTicketThisMonth();
        List<Users> topAgents = userService.getTopAgentsThisMonth();
        Map<String, Object> chart = ticketService.getTicketChartLast6Months();
        int totalPendingProblem = problemService.getNumberPendingProblems();
        List<Tickets> UnAssignedTicket = ticketService.get10UnAssignedTicket();
        
        request.setAttribute("UnAssignedTicket", UnAssignedTicket);
        request.setAttribute("totalPendingProblem", totalPendingProblem);
        request.setAttribute("chartLabels",   chart.get("labels"));
        request.setAttribute("chartDaXuLy",   chart.get("daXuLy"));
        request.setAttribute("chartChuaXuLy", chart.get("chuaXuLy"));
        request.setAttribute("topAgents", topAgents);
        request.setAttribute("totalTicketThisMonth", totalTicketThisMonth);
        request.setAttribute("totalTicket", totalTicket);
        request.setAttribute("totalUsers", totalUsers);
        request.setAttribute("totalProblem", totalProblem);
        request.getRequestDispatcher("ManagerDashboard.jsp").forward(request, response);
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
