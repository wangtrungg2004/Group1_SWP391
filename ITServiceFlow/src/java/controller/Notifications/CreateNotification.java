/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */
package controller.Notifications;

import java.io.IOException;
import java.io.PrintWriter;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.util.List;
import model.Users;
import service.NotificationService;
import service.UserService;

/**
 *
 * @author DELL
 */
@WebServlet(name = "CreateNotification", urlPatterns = {"/CreateNotification"})
public class CreateNotification extends HttpServlet {

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
            out.println("<title>Servlet CreateNotification</title>");
            out.println("</head>");
            out.println("<body>");
            out.println("<h1>Servlet CreateNotification at " + request.getContextPath() + "</h1>");
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
    NotificationService notificationService = new NotificationService();
    UserService userService = new UserService();
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession();
        List<Users> users = userService.getAllUser();
        String role = (String) session.getAttribute("role");
        // Chỉ Admin/Manager
        if (role == null || (!"Admin".equals(role) && !"Manager".equals(role))) {
            response.sendRedirect(request.getContextPath() + "/Login.jsp");
            return;
        }
        request.setAttribute("users", users);
        request.getRequestDispatcher("CreateNotification.jsp").forward(request, response);

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
        request.setCharacterEncoding("UTF-8");
        
        HttpSession session = request.getSession();
        String role = (String) session.getAttribute("role");
        if (role == null || (!"Admin".equals(role) && !"Manager".equals(role))) {
            response.sendRedirect(request.getContextPath() + "/Login.jsp");
            return;
        }
        
        String title = request.getParameter("title");
        String message = request.getParameter("message");
        String type = request.getParameter("type");
        String target = request.getParameter("target"); // "one" hoặc "all"
        String userIdParam = request.getParameter("userId"); // khi target = one

        if (title == null || title.trim().isEmpty() || message == null || message.trim().isEmpty()) {
            request.setAttribute("error", "Title and Message are required.");
            request.getRequestDispatcher("CreateNotification.jsp").forward(request, response);
            return;
        }
        if (type == null || type.trim().isEmpty()) type = "General";
        Integer relatedTicketId = null;

        if ("all".equalsIgnoreCase(target)) {
            boolean ok = notificationService.addBroadcastNotification(message, relatedTicketId, title.trim(), type.trim());
            if (ok) {
                response.sendRedirect(request.getContextPath() + "/NotificationList?success=Broadcast sent to all users.");
                return;
            }
            request.setAttribute("error", "Failed to send broadcast notification.");
            request.getRequestDispatcher("CreateNotification.jsp").forward(request, response);
            return;
        }

        if (userIdParam == null || userIdParam.trim().isEmpty()) {
            request.setAttribute("error", "Please enter User ID when sending to one user.");
            request.getRequestDispatcher("CreateNotification.jsp").forward(request, response);
            return;
        }
        if(target.equals("one"))
        {
            int userId;
            try {
                userId = Integer.parseInt(userIdParam.trim());
            } catch (NumberFormatException e) {
                request.setAttribute("error", "Invalid user ID.");
                request.getRequestDispatcher("CreateNotification.jsp").forward(request, response);
                return;
            }
            boolean ok = notificationService.createNotification(userId, message, relatedTicketId, false, title.trim(), type.trim());
            if (ok) {
                response.sendRedirect(request.getContextPath() + "/NotificationList?success=Notification sent.");
            } else {
                request.setAttribute("error", "Failed to send notification.");
                request.getRequestDispatcher("CreateNotification.jsp").forward(request, response);
            } 
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
