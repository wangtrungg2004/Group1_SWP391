package controller;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;

/**
 * Legacy OAuth callback endpoint.
 *
 * The current login flow uses Google ID token POST to /GoogleLogin, so this
 * callback only redirects users back to the login page safely.
 */
@WebServlet(name = "GoogleAuthCallback", urlPatterns = {"/GoogleAuthCallback"})
public class GoogleAuthCallback extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String error = request.getParameter("error");

        if (error != null && !error.isBlank()) {
            request.getSession().setAttribute("error", "Google sign-in failed: " + error);
        }

        response.sendRedirect("Login");
    }
}
