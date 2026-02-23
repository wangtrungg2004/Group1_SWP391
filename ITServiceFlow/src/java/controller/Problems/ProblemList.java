/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */
package controller.Problems;

import com.sun.nio.sctp.Notification;
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
import service.ProblemService;
import service.NotificationService;
/**
 *
 * @author DELL
 */
@WebServlet(name = "ProblemList", urlPatterns = {"/ProblemList"})
public class ProblemList extends HttpServlet {

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
            out.println("<title>Servlet ProblemList</title>");
            out.println("</head>");
            out.println("<body>");
            out.println("<h1>Servlet ProblemList at " + request.getContextPath() + "</h1>");
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
        
        String keyword = request.getParameter("keyword");
        if (keyword == null) {
            keyword = "";
        }

        HttpSession session = request.getSession();
        String role = (String) session.getAttribute("role");
        Integer userId = (Integer) session.getAttribute("userId");

        List<Notifications> notifications = new ArrayList<>();
        if (role != null && userId != null) {
            if ("Admin".equals(role) || "Manager".equals(role)) {
                notifications = notificationService.getAllNotification();
            } else {
                notifications = notificationService.getAllUserNotification(userId);
            }
        }

        int page = 1;
        int pageSize = 10;
        String pageParam = request.getParameter("page");

        try {
            if (pageParam != null && !pageParam.isEmpty()) {
                page = Integer.parseInt(pageParam);
            }
            if (page < 1) page = 1;
        } catch (NumberFormatException e) {
            page = 1;
        }

        List<Problems> problems;
        int totalRecords;
        int totalPages;

        if (!keyword.isEmpty()) {
            problems = problemService.searchProblem(keyword);
            totalRecords = problems.size();
            totalPages = 1;
            page = 1;
        } else {
            totalRecords = problemService.getTotalProblem();
            totalPages = (totalRecords + pageSize - 1) / pageSize;
            if (totalPages < 1) totalPages = 1;
            if (page > totalPages) page = totalPages;
            problems = problemService.getProblemsWithPages(page, pageSize);
        }

        request.setAttribute("problem", problems);
        request.setAttribute("notifications", notifications);
        request.setAttribute("currentPage", page);
        request.setAttribute("totalPages", totalPages);
        request.setAttribute("totalRecords", totalRecords);
        request.setAttribute("pageSize", pageSize);
        request.setAttribute("filterKeyword", keyword);

        request.getRequestDispatcher("ProblemList.jsp").forward(request, response);
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
       String ProblemId = request.getParameter("Id");
        
        try {
            int id = Integer.parseInt(ProblemId);
            
            // Kiểm tra user có tồn tại không
            Problems pro = problemService.getProblemById(id);
            if (pro == null) {
                response.sendError(HttpServletResponse.SC_NOT_FOUND, "Problem not found");
                return;
            }
            
            // Thực hiện delete
            boolean deleted = problemService.deleteProblem(id);
            if (!deleted) {
                response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Failed to delete user");
                return;
            }
            
            // Redirect về danh sách users sau khi delete thành công
            response.sendRedirect("ProblemList");
        } catch (NumberFormatException e) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Invalid ProblemId format");
        } catch (NullPointerException e) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "ProblemId parameter is missing");
        }
    }
}
