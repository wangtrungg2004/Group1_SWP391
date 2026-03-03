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
import model.Problems;
import service.NotificationService;
import service.ProblemService;

/**
 *
 * @author DELL
 */
@WebServlet(name = "ITProblemListController", urlPatterns = {"/ITProblemListController"})
public class ITProblemListController extends HttpServlet {

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
            out.println("<title>Servlet ITProblemListController</title>");
            out.println("</head>");
            out.println("<body>");
            out.println("<h1>Servlet ITProblemListController at " + request.getContextPath() + "</h1>");
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
    NotificationService notificationService = new NotificationService();
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession();
        Integer userId = (Integer) session.getAttribute("userId");
        
        int pageSize = 10;
        int page = 1;

        String pageStr = request.getParameter("page");
        try {
            if (pageStr != null && !pageStr.isEmpty()) {
                page = Integer.parseInt(pageStr);
            }
            if (page < 1) page = 1;
        } catch (NumberFormatException e) {
            page = 1;
        }

        int totalRecords = problemService.getTotalAssignProblem(userId);
        int totalPages = (totalRecords + pageSize - 1) / pageSize;
        if (totalPages < 1) totalPages = 1;
        if (page > totalPages) page = totalPages;

        List<Problems> problems =
                problemService.getAssignProblemWithPage(userId, page, pageSize);

        request.setAttribute("problem", problems);
        request.setAttribute("currentPage", page);
        request.setAttribute("totalPages", totalPages);
        request.setAttribute("totalRecords", totalRecords);

        request.getRequestDispatcher("ITSupportProblemList.jsp").forward(request, response);

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
        HttpSession session = request.getSession(false);
        Integer userIdObj = (Integer) (session != null ? session.getAttribute("userId") : null);
        String role = session != null ? (String) session.getAttribute("role") : null;

        if (userIdObj == null || role == null || !"IT Support".equals(role)) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN, "Only IT Support can start investigation");
            return;
        }

        String ProblemId = request.getParameter("problemId");

        try {
            int id = Integer.parseInt(ProblemId);

            Problems pro = problemService.getProblemById(id);
            if (pro == null) {
                response.sendError(HttpServletResponse.SC_NOT_FOUND, "Problem not found");
                return;
            }

            boolean statusUpdated = problemService.updateAssignStatus(id);
            int timeLogId = problemService.startTimer(id, userIdObj);

            if (!statusUpdated || timeLogId <= 0) {
                response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Failed to start investigation timer");
                return;
            }

            session.setAttribute("activeTimeLogId_" + id, timeLogId);

            String fromDetail = request.getParameter("fromDetail");

            if (fromDetail != null) {
                response.sendRedirect("ProblemDetail?Id=" + id);
            } else {
                response.sendRedirect("ITProblemListController");
            }
        } catch (NumberFormatException e) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Invalid ProblemId format");
        } catch (NullPointerException e) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "ProblemId parameter is missing");
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
