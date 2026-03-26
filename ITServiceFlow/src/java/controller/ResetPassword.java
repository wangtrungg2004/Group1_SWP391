/*
 * Reset Password: nhập mật khẩu mới với token từ email/link
 */
package controller;

import java.io.IOException;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import service.UserService;

@WebServlet(name = "ResetPassword", urlPatterns = {"/ResetPassword"})
public class ResetPassword extends HttpServlet {

    private final UserService userService = new UserService();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String token = request.getParameter("token");
        if (token == null || token.isEmpty()) {
            request.setAttribute("error", "Link không hợp lệ hoặc đã hết hạn.");
            request.getRequestDispatcher("ResetPassword.jsp").forward(request, response);
            return;
        }
        request.setAttribute("token", token);
        request.getRequestDispatcher("ResetPassword.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        response.setContentType("text/html; charset=UTF-8");

        String token = request.getParameter("token");
        String password = request.getParameter("password");
        String confirm = request.getParameter("confirmPassword");

        if (token == null || token.isEmpty()) {
            request.setAttribute("error", "Link không hợp lệ hoặc đã hết hạn.");
            request.getRequestDispatcher("ResetPassword.jsp").forward(request, response);
            return;
        }
        if (password == null || password.trim().length() < 6) {
            request.setAttribute("error", "Mật khẩu mới phải có ít nhất 6 ký tự.");
            request.setAttribute("token", token);
            request.getRequestDispatcher("ResetPassword.jsp").forward(request, response);
            return;
        }
        if (!password.equals(confirm)) {
            request.setAttribute("error", "Mật khẩu xác nhận không khớp.");
            request.setAttribute("token", token);
            request.getRequestDispatcher("ResetPassword.jsp").forward(request, response);
            return;
        }

        boolean ok = userService.resetPassword(token, password);
        if (!ok) {
            request.setAttribute("error", "Link không hợp lệ hoặc đã hết hạn. Vui lòng yêu cầu link mới.");
            request.setAttribute("token", token);
            request.getRequestDispatcher("ResetPassword.jsp").forward(request, response);
            return;
        }

        request.setAttribute("success", true);
        request.getRequestDispatcher("ResetPassword.jsp").forward(request, response);
    }
}
