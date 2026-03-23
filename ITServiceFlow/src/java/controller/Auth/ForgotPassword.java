package controller.Auth;

import Utils.EmailUtil;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import service.UserService;

@WebServlet(name = "AuthForgotPassword", urlPatterns = {"/auth/ForgotPassword"})
public class ForgotPassword extends HttpServlet {

    private final UserService userService = new UserService();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.getRequestDispatcher("ForgotPassword.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String email = safeTrim(request.getParameter("email"));

        if (isBlank(email)) {
            request.setAttribute("error", "Please enter your email.");
            request.getRequestDispatcher("ForgotPassword.jsp").forward(request, response);
            return;
        }

        var user = userService.getUserByEmail(email);
        if (user == null) {
            request.setAttribute("error", "Email does not exist in system.");
            request.getRequestDispatcher("ForgotPassword.jsp").forward(request, response);
            return;
        }

        String token = userService.createPasswordResetToken(email);
        if (token == null) {
            request.setAttribute("error", "Cannot create reset link. Please try again.");
            request.getRequestDispatcher("ForgotPassword.jsp").forward(request, response);
            return;
        }

        String resetLink = buildResetLink(request, token);
        boolean sent = EmailUtil.sendForgotPasswordEmail(email, user.getUsername(), resetLink);
        if (!sent) {
            request.setAttribute("error", "Cannot send reset email. Please check mail config.");
            request.getRequestDispatcher("ForgotPassword.jsp").forward(request, response);
            return;
        }

        request.setAttribute("message", "Reset link has been sent to your email.");
        request.getRequestDispatcher("ForgotPassword.jsp").forward(request, response);
    }

    private String safeTrim(String value) {
        return value == null ? null : value.trim();
    }

    private boolean isBlank(String value) {
        return value == null || value.isEmpty();
    }

    private String buildResetLink(HttpServletRequest request, String token) {
        return request.getScheme() + "://"
                + request.getServerName() + ":"
                + request.getServerPort()
                + request.getContextPath()
                + "/ResetPassword?token=" + token;
    }
}

