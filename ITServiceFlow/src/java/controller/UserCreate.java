package controller;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.util.List;
import model.Users;
import service.UserService;

@WebServlet(name = "UserCreate", urlPatterns = {"/UserCreate"})
public class UserCreate extends HttpServlet {

    private final UserService userService = new UserService();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        if (!isAdmin(request.getSession(false))) {
            response.sendRedirect("Login.jsp");
            return;
        }
        loadRecentUsers(request);
        request.getRequestDispatcher("UserCreate.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        if (!isAdmin(request.getSession(false))) {
            response.sendRedirect("Login.jsp");
            return;
        }

        String username = trim(request.getParameter("username"));
        String email = trim(request.getParameter("email"));
        String password = trim(request.getParameter("password"));
        String confirmPassword = trim(request.getParameter("confirmPassword"));
        String fullName = trim(request.getParameter("fullName"));
        String role = trim(request.getParameter("role"));

        if (isBlank(username) || isBlank(email) || isBlank(password) || isBlank(confirmPassword) || isBlank(role)) {
            request.setAttribute("error", "Username, email, password, confirm password, role are required.");
            request.getRequestDispatcher("UserCreate.jsp").forward(request, response);
            return;
        }
        if (password.length() < 6) {
            request.setAttribute("error", "Password must be at least 6 characters.");
            request.getRequestDispatcher("UserCreate.jsp").forward(request, response);
            return;
        }
        if (!password.equals(confirmPassword)) {
            request.setAttribute("error", "Confirm password does not match.");
            request.getRequestDispatcher("UserCreate.jsp").forward(request, response);
            return;
        }

        boolean success = userService.createUser(username, email, password, fullName, role, null);
        if (!success) {
            request.setAttribute("error", "Create user failed. Username/email may already exist.");
            loadRecentUsers(request);
            request.getRequestDispatcher("UserCreate.jsp").forward(request, response);
            return;
        }

        request.setAttribute("message", "Create user success.");
        loadRecentUsers(request);
        request.getRequestDispatcher("UserCreate.jsp").forward(request, response);
    }

    private void loadRecentUsers(HttpServletRequest request) {
        List<Users> users = userService.getAllUser();
        request.setAttribute("recentUsers", users);
    }

    private boolean isAdmin(HttpSession session) {
        return session != null && "Admin".equals(session.getAttribute("role"));
    }

    private String trim(String value) {
        return value == null ? null : value.trim();
    }

    private boolean isBlank(String value) {
        return value == null || value.isEmpty();
    }
}
