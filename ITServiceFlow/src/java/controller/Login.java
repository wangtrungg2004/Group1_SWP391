/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */
package controller;

import Utils.GoogleAuthUtil;
import java.io.IOException;
import java.io.PrintWriter;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import model.Users;
import service.TemporaryRoleAccessService;
import service.UserService;
import dao.AuditLogDao;
import model.AuditLog;

/**
 *
 * @author DELL
 */
@WebServlet(name = "Login", urlPatterns = {"/Login"})
public class Login extends HttpServlet {

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
            out.println("<title>Servlet Login</title>");
            out.println("</head>");
            out.println("<body>");
            out.println("<h1>Servlet Login at " + request.getContextPath() + "</h1>");
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
    UserService userService = new UserService();
    TemporaryRoleAccessService temporaryRoleAccessService = new TemporaryRoleAccessService();
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        forwardLogin(request, response);
    }

    /**
     * Handles the HTTP <code>POST</code> method.
     *
     * @param request servlet request
     * @param response servlet response
     * @throws ServletException if a servlet-specific error occurs
     * @throws IOException if an I/O error occurs
     */
    private AuditLogDao auditLogDao = new AuditLogDao();

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        try {
            String username = request.getParameter("username");
            String password = request.getParameter("password");
            
            // Trim whitespace từ form input
            if (username != null) {
                username = username.trim();
            }
            if (password != null) {
                password = password.trim();
            }

            // [PASSWORD_HASH] userService.login sẽ hash password rồi so sánh với DB; khi bỏ hash chỉ cần đổi bên UserService/UserDao
            Users existedUser = userService.getUserByUsername(username);
            if (existedUser != null && !existedUser.isActive()) {
                request.setAttribute("error", "Your account has been deactivated. Please contact administrator.");
                forwardLogin(request, response);
                return;
            }

            Users user = userService.login(username, password);

            if (user == null) {
                request.setAttribute("error", "Invalid username or password. Please check your credentials or contact administrator if database connection fails.");
                forwardLogin(request, response);
                return;
            }

        HttpSession session = request.getSession();
        session.setAttribute("user", user);
        session.setAttribute("baseRole", user.getRole());
        session.setAttribute("effectiveRole", user.getRole());
        session.setAttribute("role", user.getRole());
        session.setAttribute("userId", user.getId());
        session.setAttribute(TemporaryRoleAccessService.SESSION_TEMP_ROLE_ACTIVATED, false);
        temporaryRoleAccessService.synchronizeSessionRole(session);
        

        // Redirect theo role goc, temporary role chi active khi user bam nut trong trang TemporaryAccessRequest

        // Add audit log
        AuditLog log = new AuditLog();
        log.setUserId(user.getId());
        log.setAction("LOGIN");
        log.setScreen("Login");
        log.setDataBefore("N/A");
        log.setDataAfter("User logged in: " + user.getUsername());
        auditLogDao.insertLog(log);
        
        // Redirect theo role

        String role = user.getRole();
        if (role != null) {
            switch (role) {
                case "Admin":
                    response.sendRedirect(request.getContextPath() + "/AdminDashboard");
                    break;
                case "Manager":
                    response.sendRedirect(request.getContextPath() + "/ManagerDashboard");
                    break;
                case "User":
                    response.sendRedirect(request.getContextPath() + "/UserDashboard");
                    break;
                case "IT Support":
                    response.sendRedirect(request.getContextPath() + "/ITDashboard");
                    break;
                default:
                    request.setAttribute("error", "Role không hợp lệ. Vui lòng liên hệ quản trị viên.");
                    forwardLogin(request, response);
                    return;
            }
        } else {
            request.setAttribute("error", "Không thể xác định role. Vui lòng đăng nhập lại.");
            forwardLogin(request, response);
        }
        } catch (Exception e) {
            // Log lỗi và hiển thị thông báo cho user
            System.err.println("Login error: " + e.getMessage());
            e.printStackTrace();
            request.setAttribute("error", "Database connection error. Please contact administrator.");
            forwardLogin(request, response);
        }
    }

    private void forwardLogin(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setAttribute("googleClientId", GoogleAuthUtil.getGoogleClientId());
        request.getRequestDispatcher("Login.jsp").forward(request, response);
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
