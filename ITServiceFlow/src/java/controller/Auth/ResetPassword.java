package controller.Auth;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import service.UserService;

@WebServlet(name = "AuthResetPassword", urlPatterns = {"/auth/ResetPassword"})
public class ResetPassword extends HttpServlet {

    private final UserService userService = new UserService();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String token = trim(request.getParameter("token"));
        if (isBlank(token) || !userService.isValidResetToken(token)) {
            request.setAttribute("error", "Invalid or expired reset link.");
            request.getRequestDispatcher("ForgotPassword.jsp").forward(request, response);
            return;
        }
        request.setAttribute("token", token);
        request.getRequestDispatcher("ResetPassword.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String token = trim(request.getParameter("token"));
        String newPassword = trim(request.getParameter("newPassword"));
        String confirmPassword = trim(request.getParameter("confirmPassword"));

        if (isBlank(token) || !userService.isValidResetToken(token)) {
            request.setAttribute("error", "Invalid or expired reset link.");
            request.getRequestDispatcher("ForgotPassword.jsp").forward(request, response);
            return;
        }
        if (isBlank(newPassword) || isBlank(confirmPassword)) {
            request.setAttribute("error", "Please fill all fields.");
            request.setAttribute("token", token);
            request.getRequestDispatcher("ResetPassword.jsp").forward(request, response);
            return;
        }
        if (newPassword.length() < 6) {
            request.setAttribute("error", "New password must be at least 6 characters.");
            request.setAttribute("token", token);
            request.getRequestDispatcher("ResetPassword.jsp").forward(request, response);
            return;
        }
        if (!newPassword.equals(confirmPassword)) {
            request.setAttribute("error", "Confirm password does not match.");
            request.setAttribute("token", token);
            request.getRequestDispatcher("ResetPassword.jsp").forward(request, response);
            return;
        }

        boolean updated = userService.resetPasswordByToken(token, newPassword);
        if (!updated) {
            request.setAttribute("error", "Cannot reset password. Link may be expired.");
            request.getRequestDispatcher("ForgotPassword.jsp").forward(request, response);
            return;
        }

        request.setAttribute("message", "Password reset successful. Please login.");
        request.getRequestDispatcher("Login.jsp").forward(request, response);
    }

    private String trim(String value) {
        return value == null ? null : value.trim();
    }

    private boolean isBlank(String value) {
        return value == null || value.isEmpty();
    }
}

