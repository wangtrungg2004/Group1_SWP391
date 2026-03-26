/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */
package controller;

import java.io.IOException;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import dao.AuditLogDao;
import model.AuditLog;
import model.Users;

/**
 *
 * @author DELL
 */
@WebServlet(name = "Logout", urlPatterns = {"/Logout"})
public class Logout extends HttpServlet {
    private AuditLogDao auditLogDao = new AuditLogDao();

    /**
     * Processes requests for both HTTP <code>GET</code> and <code>POST</code>
     * methods.
     *
     * @param request servlet request
     * @param response servlet response
     * @throws ServletException if a servlet-specific error occurs
     * @throws IOException if an I/O error occurs
     */
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        processLogout(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        processLogout(request, response);
    }
    
    private void processLogout(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        
        if (session != null) {
            Users user = (Users) session.getAttribute("user");
            if (user != null) {
                // Add audit log
                AuditLog log = new AuditLog();
                log.setUserId(user.getId());
                log.setAction("LOGOUT");
                log.setScreen("Layout");
                log.setDataBefore("N/A");
                log.setDataAfter("User logged out: " + user.getUsername());
                auditLogDao.insertLog(log);
            }
            // Xóa tất cả các attribute trong session
            session.invalidate();
        }
        
        // Redirect về trang login
        response.sendRedirect(request.getContextPath() + "/Login.jsp");
    }

    /**
     * Returns a short description of the servlet.
     *
     * @return a String containing servlet description
     */
    @Override
    public String getServletInfo() {
        return "Logout servlet";
    }
}
