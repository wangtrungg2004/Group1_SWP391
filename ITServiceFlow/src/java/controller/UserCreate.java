package controller;

import dao.UserDao;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.util.Arrays;
import java.util.List;
import java.util.Map;
import model.Users;
import service.UserService;

@WebServlet(name = "UserCreate", urlPatterns = {"/UserCreate"})
public class UserCreate extends HttpServlet {

    private final UserService userService = new UserService();
    private final UserDao userDao = new UserDao();

    private static final List<String> FIXED_ROLES = Arrays.asList("Admin", "Manager", "IT Support", "User");

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        if (!isAdmin(request.getSession(false))) {
            response.sendRedirect("Login.jsp");
            return;
        }
        loadFormOptions(request);
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
        String departmentRaw = trim(request.getParameter("departmentId"));
        String locationRaw = trim(request.getParameter("locationId"));

        Integer departmentId = parseNullableInt(departmentRaw);
        Integer locationId = parseNullableInt(locationRaw);

        Map<Integer, String> departmentOptions = userDao.getDepartmentOptions();
        Map<Integer, String> locationOptions = userDao.getLocationOptions();
        request.setAttribute("roleOptions", FIXED_ROLES);
        request.setAttribute("departmentOptions", departmentOptions);
        request.setAttribute("locationOptions", locationOptions);
        bindFormValues(request, username, email, fullName, role, departmentRaw, locationRaw);
        loadRecentUsers(request);

        if (isBlank(username) || isBlank(email) || isBlank(password) || isBlank(confirmPassword) || isBlank(role)) {
            request.setAttribute("error", "Username, email, password, confirm password, role are required.");
            request.getRequestDispatcher("UserCreate.jsp").forward(request, response);
            return;
        }
        if (!isValidEmail(email)) {
            request.setAttribute("error", "Email format is invalid.");
            request.getRequestDispatcher("UserCreate.jsp").forward(request, response);
            return;
        }
        if (!FIXED_ROLES.contains(role)) {
            request.setAttribute("error", "Role is not supported.");
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
        if (!isBlank(departmentRaw) && departmentId == null) {
            request.setAttribute("error", "Department is invalid.");
            request.getRequestDispatcher("UserCreate.jsp").forward(request, response);
            return;
        }
        if (departmentId != null && !departmentOptions.containsKey(departmentId)) {
            request.setAttribute("error", "Department is invalid.");
            request.getRequestDispatcher("UserCreate.jsp").forward(request, response);
            return;
        }
        if (locationId == null || !locationOptions.containsKey(locationId)) {
            request.setAttribute("error", "Please select a valid location.");
            request.getRequestDispatcher("UserCreate.jsp").forward(request, response);
            return;
        }

        boolean success = userService.createUser(username, email, password, fullName, role, departmentId, locationId);
        if (!success) {
            request.setAttribute("error", "Create user failed. Username/email may already exist.");
            request.getRequestDispatcher("UserCreate.jsp").forward(request, response);
            return;
        }

        clearFormValues(request);
        request.setAttribute("message", "Create user success.");
        loadRecentUsers(request);
        request.getRequestDispatcher("UserCreate.jsp").forward(request, response);
    }

    private void loadRecentUsers(HttpServletRequest request) {
        List<Users> users = userService.getAllUser();
        request.setAttribute("recentUsers", users);
    }

    private void loadFormOptions(HttpServletRequest request) {
        request.setAttribute("roleOptions", FIXED_ROLES);
        request.setAttribute("departmentOptions", userDao.getDepartmentOptions());
        request.setAttribute("locationOptions", userDao.getLocationOptions());
    }

    private void bindFormValues(HttpServletRequest request, String username, String email, String fullName,
            String role, String departmentId, String locationId) {
        request.setAttribute("formUsername", username == null ? "" : username);
        request.setAttribute("formEmail", email == null ? "" : email);
        request.setAttribute("formFullName", fullName == null ? "" : fullName);
        request.setAttribute("formRole", role == null ? "" : role);
        request.setAttribute("formDepartmentId", departmentId == null ? "" : departmentId);
        request.setAttribute("formLocationId", locationId == null ? "" : locationId);
    }

    private void clearFormValues(HttpServletRequest request) {
        bindFormValues(request, "", "", "", "", "", "");
    }

    private boolean isAdmin(HttpSession session) {
        return session != null && "Admin".equals(session.getAttribute("role"));
    }

    private boolean isValidEmail(String email) {
        return email != null && email.matches("^[\\w.+-]+@[\\w-]+\\.[\\w.-]+$");
    }

    private Integer parseNullableInt(String value) {
        if (isBlank(value)) {
            return null;
        }
        try {
            return Integer.valueOf(value);
        } catch (NumberFormatException ex) {
            return null;
        }
    }

    private String trim(String value) {
        return value == null ? null : value.trim();
    }

    private boolean isBlank(String value) {
        return value == null || value.isEmpty();
    }
}
