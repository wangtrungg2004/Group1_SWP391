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
import service.AuditLogService;
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
    AuditLogService auditLogService = new AuditLogService();
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

        if(problemId == null){
            response.sendRedirect("ProblemList");
            return;
        }

        int id = Integer.parseInt(problemId);

        Problems problem = problemService.getProblemById(id);

        if(problem == null){
            response.sendRedirect("ProblemList");
            return;
        }

        if("PENDING".equals(status)){

            problemService.updateStatusProblem(id, status);

            auditLogService.createAuditLog(userId,"SUBMIT","Problem",id);
        }

        else if("REJECTED".equals(status)){

            String rejectedReason = request.getParameter("rejectedReason");

            if(rejectedReason != null){
                rejectedReason = rejectedReason.trim();
            }
            if (rejectedReason == null || rejectedReason.isEmpty()) {
                response.sendRedirect("ProblemDetail?Id=" + id + "&error=rejected_reason_required");
                return;
            }

            problem.setStatus("REJECTED");
            problem.setRejectedReason(rejectedReason);

            problemService.updateProblem(problem);

            auditLogService.createAuditLog(userId,"REJECTED","Problem",id);
        }

        else if("APPROVED".equals(status)){

            problemService.updateStatusProblem(id,status);

            KnowErrors kn = knownErrorService.findKnowErrorByProblemId(id);

            if(kn == null){
                knownErrorService.addKnowError(problem.getId(),
                                               problem.getTitle(),
                                               problem.getWorkaround());
            }
            KnowErrors newKn = knownErrorService.findKnowErrorByProblemId(id);
            if (newKn != null) {
                auditLogService.createAuditLog(userId, "CREATE", "KnowError", newKn.getId());
            }

            auditLogService.createAuditLog(userId,"APPROVED","Problem",id);
        }

        if("IT Support".equals(role)){
            response.sendRedirect("ITProblemListController");
        }
        else if("Manager".equals(role)){
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
