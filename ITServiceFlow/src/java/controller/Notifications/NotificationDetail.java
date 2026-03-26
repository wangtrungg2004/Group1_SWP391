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
import model.Notifications;
import service.NotificationService;

/**
 *
 * @author DELL
 */
@WebServlet(name = "NotificationDetail", urlPatterns = {"/NotificationDetail"})
public class NotificationDetail extends HttpServlet {

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
            out.println("<title>Servlet NotificationDetail</title>");
            out.println("</head>");
            out.println("<body>");
            out.println("<h1>Servlet NotificationDetail at " + request.getContextPath() + "</h1>");
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
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession();
        String role = (String) session.getAttribute("role");
        Integer userId = (Integer) session.getAttribute("userId");
        
        String idParam = request.getParameter("Id");
        
        if (idParam == null || idParam.trim().isEmpty()) {
            response.sendRedirect("ITSupportNotificationList");
            return;
        }
        int id = Integer.parseInt(idParam);
        Notifications notification = notificationService.getNotificationsById(id);
        if (notification == null) {
            response.sendRedirect("ITSupportNotificationList");
            return;
        }
        // Chi danh dau da doc voi notification gui rieng (1 user). Broadcast khong danh dau de tranh 1 nguoi danh dau cho tat ca.
        boolean isBroadcast = notification.isIsBroadcast();
        boolean isMyNotification = notification.getUserId() != null && notification.getUserId().equals(userId);
        boolean canMarkRead = ("User".equals(role) || "IT Support".equals(role)) && isMyNotification && !isBroadcast;
        if (canMarkRead) {
            notificationService.readNotification(id);
        }

        String notificationListUrl;
        if ("Manager".equals(role)) {
            notificationListUrl = "NotificationList";
        } else if ("IT Support".equals(role)) {
            notificationListUrl = "ITSupportNotificationList";
        } else if ("User".equals(role) || "Admin".equals(role)) {
            notificationListUrl = "UserNotificationList";
        } else {
            notificationListUrl = "UserNotificationList"; // fallback
        }
//        request.setAttribute("notificationListUrl", notificationListUrl);
        request.setAttribute("notification", notification);
        request.setAttribute("notificationListUrl", notificationListUrl);
        request.setAttribute("role", role != null ? role : "");
        request.getRequestDispatcher("NotificationDetail.jsp").forward(request, response);
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
