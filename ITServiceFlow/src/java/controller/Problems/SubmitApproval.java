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
import java.util.ArrayList;
import java.util.List;
import model.Notifications;
import model.Problems;
import model.KnowErrors;
import service.KnowErrorService;
import service.ProblemService;
import service.NotificationService;
/**
 *
 * @author DELL
 */
@WebServlet(name = "SubmitApproval", urlPatterns = {"/SubmitApproval"})
public class SubmitApproval extends HttpServlet {

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
            out.println("<title>Servlet SubmitApproval</title>");
            out.println("</head>");
            out.println("<body>");
            out.println("<h1>Servlet SubmitApproval at " + request.getContextPath() + "</h1>");
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
    KnowErrorService knownErrorService = new KnowErrorService();
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        processRequest(request, response);
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
        
        HttpSession session = request.getSession();
        String role = (String) session.getAttribute("role");
        Integer userId = (Integer) session.getAttribute("userId");
        
        String problemId = request.getParameter("problemId");
        String status = request.getParameter("status");
        
        if(problemId == null)
        {
            return;
        }
        int id = Integer.parseInt(problemId);
        if(status.equals("REJECTED"))
        {
            String rejectedReason = request.getParameter("rejectedReason");
            if (rejectedReason != null) {
                rejectedReason = rejectedReason.trim();
            }
            Problems pro = problemService.getProblemById(id);
            if (pro != null) {
                pro.setStatus("REJECTED");
                pro.setRejectedReason(rejectedReason);
                problemService.updateProblem(pro);
            }
        }
        if(status.equals("APPROVED"))
        {
//            problemService.updateStatusProblem(id, status);
            
            Problems pro = problemService.getProblemById(id);
            
            if(pro != null)
            {
                KnowErrors kn = knownErrorService.findKnowErrorByProblemId(id);
                if(kn == null)
                {
                    knownErrorService.addKnowError(pro.getId(), pro.getTitle(), pro.getWorkaround());
                }
            }
        }
        boolean pro = problemService.updateStatusProblem(id, status);
        
        if("IT Support".equals(role))
        {
            response.sendRedirect("ITProblemListController");
        }
        else if("Manager".equals(role))
        {
            response.sendRedirect("ProblemPendingList");
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
