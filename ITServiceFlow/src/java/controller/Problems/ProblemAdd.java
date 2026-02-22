/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */
package controller.Problems;

import dao.NotificationDao;
import java.io.IOException;
import java.io.PrintWriter;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.util.List;
import service.ProblemService;
import model.Users;
import service.UserService;
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
    NotificationDao notificationDao = new NotificationDao();
    UserService userService = new UserService();
    
    private String trimOrNull(String value) {
        return (value == null || value.trim().isEmpty()) ? null : value.trim();
    }
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        List<Users> assignees = userService.getAllUser();
        request.setAttribute("assignees", assignees);
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

        String Title       = trimOrNull(request.getParameter("Title"));
        String Description = trimOrNull(request.getParameter("Description"));
        String RootCause   = trimOrNull(request.getParameter("RootCause"));
        String Workaround  = trimOrNull(request.getParameter("Workaround"));
//        String Status      = trimOrNull(request.getParameter("Status"));
        String assignedToStr = request.getParameter("AssignedTo");

        final String defaultStatus = "New";
        
        int assignedTo = 0;
        if (assignedToStr != null && !assignedToStr.trim().isEmpty()) {
            try {
                assignedTo = Integer.parseInt(assignedToStr.trim());
            } catch (NumberFormatException e) {
                request.setAttribute("error", "Invalid Assigned To ID.");
                request.setAttribute("assignees", userService.getAllUser());
                request.getRequestDispatcher("ProblemAdd.jsp").forward(request, response);
                return;
            }
        }

        // Validate bắt buộc cho Title (NOT NULL trên DB)
        if (Title == null) {
            request.setAttribute("error", "Title is required.");
            request.setAttribute("assignees", userService.getAllUser());
            request.getRequestDispatcher("ProblemAdd.jsp").forward(request, response);
            return;
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
            defaultStatus,
            createdBy,
            assignedTo,
            createdAt
        );

        if (success) {
            int newProblemId = problemService.getLatestProblemId();
            if (newProblemId > 0) {
                String message = "New problem: " + Title + " (Status: " + defaultStatus + ")";

                // Gửi notification cho người được assign (nếu có)
                if (assignedTo > 0) {
                    notificationDao.addNotification(assignedTo, message, null, false);
                }
            }
            response.sendRedirect("ProblemList?success=Problem added successfully!");
        } else {
            request.setAttribute("error", "Failed to add problem. Please try again.");
            request.setAttribute("assignees", userService.getAllUser());
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
