package controller;

import Utils.EmailUtil;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.util.Arrays;
import java.util.List;
import model.Users;
import service.AuditLogService;
import service.UserService;
import dao.UserDao;

@WebServlet(name = "UserManagementController", urlPatterns = {"/UserManagement"})
public class UserManagementController extends HttpServlet {

    private final UserDao userDao = new UserDao();
    private final UserService userService = new UserService();
    private final AuditLogService auditLogService = new AuditLogService();

    private static final List<String> FIXED_ROLES = Arrays.asList("Admin", "Manager", "IT Support", "User");
    private static final int PAGE_SIZE = 4;

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (!isAdmin(session)) {
            response.sendRedirect("Login.jsp");
            return;
        }

        String search = trim(request.getParameter("search"));
        String roleFilter = trim(request.getParameter("role"));
        String status = trim(request.getParameter("status"));
        if (status == null || status.isEmpty()) {
            status = "all";
        }

        int currentPage = parsePositiveInt(request.getParameter("page"), 1);
        int totalUsers = userDao.countUsersForManagement(search, roleFilter, status);
        int totalPages = (int) Math.ceil(totalUsers / (double) PAGE_SIZE);
        if (totalPages <= 0) {
            totalPages = 1;
        }
        if (currentPage > totalPages) {
            currentPage = totalPages;
        }

        int offset = (currentPage - 1) * PAGE_SIZE;
        List<Users> users = userDao.searchUsersForManagement(search, roleFilter, status, offset, PAGE_SIZE);

        int startItem = totalUsers == 0 ? 0 : offset + 1;
        int endItem = totalUsers == 0 ? 0 : Math.min(offset + users.size(), totalUsers);

        request.setAttribute("users", users);
        request.setAttribute("roleOptions", FIXED_ROLES);
        request.setAttribute("departmentOptions", userDao.getDepartmentOptions());
        request.setAttribute("locationOptions", userDao.getLocationOptions());
        request.setAttribute("search", search == null ? "" : search);
        request.setAttribute("selectedRole", roleFilter == null ? "" : roleFilter);
        request.setAttribute("selectedStatus", status);
        request.setAttribute("currentPage", currentPage);
        request.setAttribute("totalPages", totalPages);
        request.setAttribute("totalUsers", totalUsers);
        request.setAttribute("startItem", startItem);
        request.setAttribute("endItem", endItem);
        request.setAttribute("pageSize", PAGE_SIZE);

        pullFlashMessage(session, request);
        request.getRequestDispatcher("UserManagement.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (!isAdmin(session)) {
            response.sendRedirect("Login.jsp");
            return;
        }

        Integer currentUserId = (Integer) session.getAttribute("userId");
        String action = trim(request.getParameter("action"));

        if (action == null || action.isEmpty()) {
            pushFlashMessage(session, "error", "Invalid action.");
            response.sendRedirect("UserManagement");
            return;
        }

        switch (action) {
            case "updateInfo":
                handleUpdateInfo(request, session, currentUserId);
                break;
            case "changeRole":
                handleChangeRole(request, session, currentUserId);
                break;
            case "update":
                handleUpdateLegacy(request, session, currentUserId);
                break;
            case "activate":
                handleSetActive(request, session, currentUserId, true);
                break;
            case "deactivate":
                handleSetActive(request, session, currentUserId, false);
                break;
            case "resetPasswordEmail":
                handleResetPasswordEmail(request, session, currentUserId);
                break;
            default:
                pushFlashMessage(session, "error", "Unsupported action.");
                break;
        }

        response.sendRedirect("UserManagement");
    }

    private void handleUpdateInfo(HttpServletRequest request, HttpSession session, Integer currentUserId) {
        int targetId = parseInt(request.getParameter("id"));
        String fullName = trim(request.getParameter("fullName"));
        String email = trim(request.getParameter("email"));
        Integer departmentId = parseNullableInt(request.getParameter("departmentId"));
        Integer locationId = parseNullableInt(request.getParameter("locationId"));

        if (targetId <= 0 || email == null || email.isEmpty()) {
            pushFlashMessage(session, "error", "Missing required fields for user info update.");
            return;
        }

        if (!isValidEmail(email)) {
            pushFlashMessage(session, "error", "Email format is invalid.");
            return;
        }

        Users existing = userDao.getUserById(targetId);
        if (existing == null) {
            pushFlashMessage(session, "error", "User not found.");
            return;
        }

        if (locationId == null && existing.getLocationId() > 0) {
            locationId = existing.getLocationId();
        }
        if (departmentId == null && existing.getDepartmentId() > 0) {
            departmentId = existing.getDepartmentId();
        }
        if (fullName == null || fullName.isEmpty()) {
            fullName = existing.getFullName();
        }

        if (userDao.isEmailUsedByOtherUser(email, targetId)) {
            pushFlashMessage(session, "error", "Email is already used by another user.");
            return;
        }

        boolean updated = userDao.updateUserInfoForAdmin(targetId, fullName, email, departmentId, locationId);
        if (updated) {
            if (currentUserId != null) {
                auditLogService.createAuditLog(currentUserId, "USER_UPDATE_INFO", "User", targetId);
            }
            pushFlashMessage(session, "success", "User information updated successfully.");
        } else {
            pushFlashMessage(session, "error", "Failed to update user information.");
        }
    }

    private void handleChangeRole(HttpServletRequest request, HttpSession session, Integer currentUserId) {
        int targetId = parseInt(request.getParameter("id"));
        String role = trim(request.getParameter("role"));

        if (targetId <= 0 || role == null || role.isEmpty()) {
            pushFlashMessage(session, "error", "Missing required fields for role change.");
            return;
        }

        if (!FIXED_ROLES.contains(role)) {
            pushFlashMessage(session, "error", "Role is not supported.");
            return;
        }

        Users existing = userDao.getUserById(targetId);
        if (existing == null) {
            pushFlashMessage(session, "error", "User not found.");
            return;
        }

        if (role.equals(existing.getRole())) {
            pushFlashMessage(session, "success", "Role is unchanged.");
            return;
        }

        boolean changed = userDao.updateUserRoleForAdmin(targetId, role);
        if (changed) {
            if (currentUserId != null) {
                auditLogService.createAuditLog(currentUserId, "USER_CHANGE_ROLE", "User", targetId);
            }
            pushFlashMessage(session, "success", "Role updated successfully.");
        } else {
            pushFlashMessage(session, "error", "Failed to update role.");
        }
    }

    private void handleUpdateLegacy(HttpServletRequest request, HttpSession session, Integer currentUserId) {
        int targetId = parseInt(request.getParameter("id"));
        String fullName = trim(request.getParameter("fullName"));
        String email = trim(request.getParameter("email"));
        String role = trim(request.getParameter("role"));
        Integer departmentId = parseNullableInt(request.getParameter("departmentId"));
        Integer locationId = parseNullableInt(request.getParameter("locationId"));

        if (targetId <= 0 || email == null || email.isEmpty() || role == null || role.isEmpty()) {
            pushFlashMessage(session, "error", "Missing required fields for update.");
            return;
        }

        if (!isValidEmail(email)) {
            pushFlashMessage(session, "error", "Email format is invalid.");
            return;
        }

        if (!FIXED_ROLES.contains(role)) {
            pushFlashMessage(session, "error", "Role is not supported.");
            return;
        }

        Users existing = userDao.getUserById(targetId);
        if (existing == null) {
            pushFlashMessage(session, "error", "User not found.");
            return;
        }

        if (locationId == null && existing.getLocationId() > 0) {
            locationId = existing.getLocationId();
        }
        if (departmentId == null && existing.getDepartmentId() > 0) {
            departmentId = existing.getDepartmentId();
        }
        if (fullName == null || fullName.isEmpty()) {
            fullName = existing.getFullName();
        }

        if (userDao.isEmailUsedByOtherUser(email, targetId)) {
            pushFlashMessage(session, "error", "Email is already used by another user.");
            return;
        }

        boolean updated = userDao.updateUserForAdmin(targetId, fullName, email, role, departmentId, locationId);
        if (updated) {
            if (currentUserId != null) {
                auditLogService.createAuditLog(currentUserId, "USER_UPDATE", "User", targetId);
            }
            pushFlashMessage(session, "success", "User updated successfully.");
        } else {
            pushFlashMessage(session, "error", "Failed to update user.");
        }
    }

    private void handleSetActive(HttpServletRequest request, HttpSession session, Integer currentUserId, boolean active) {
        int targetId = parseInt(request.getParameter("id"));
        if (targetId <= 0) {
            pushFlashMessage(session, "error", "Invalid user id.");
            return;
        }

        if (!active && currentUserId != null && targetId == currentUserId) {
            pushFlashMessage(session, "error", "You cannot deactivate your own account.");
            return;
        }

        boolean changed = userDao.setUserActiveStatus(targetId, active);
        if (changed) {
            if (currentUserId != null) {
                auditLogService.createAuditLog(
                        currentUserId,
                        active ? "USER_ACTIVATE" : "USER_DEACTIVATE",
                        "User",
                        targetId
                );
            }
            pushFlashMessage(session, "success", active ? "User activated." : "User deactivated.");
        } else {
            pushFlashMessage(session, "error", "Failed to change user status.");
        }
    }

    private void handleResetPasswordEmail(HttpServletRequest request, HttpSession session, Integer currentUserId) {
        int targetId = parseInt(request.getParameter("id"));
        if (targetId <= 0) {
            pushFlashMessage(session, "error", "Invalid user id.");
            return;
        }

        Users target = userDao.getUserById(targetId);
        if (target == null) {
            pushFlashMessage(session, "error", "User not found.");
            return;
        }
        if (!target.isActive()) {
            pushFlashMessage(session, "error", "Cannot reset password for an inactive user.");
            return;
        }

        String token = userService.createPasswordResetToken(target.getEmail());
        if (token == null) {
            pushFlashMessage(session, "error", "Cannot create reset token.");
            return;
        }

        String resetLink = buildResetLink(request, token);
        boolean sent = EmailUtil.sendForgotPasswordEmail(target.getEmail(), target.getUsername(), resetLink);
        if (!sent) {
            pushFlashMessage(session, "error", "Failed to send reset email. Check mail config.");
            return;
        }

        if (currentUserId != null) {
            auditLogService.createAuditLog(currentUserId, "USER_RESET_PASSWORD_EMAIL", "User", targetId);
        }
        pushFlashMessage(session, "success", "Password reset email sent.");
    }

    private boolean isAdmin(HttpSession session) {
        return session != null && "Admin".equals(session.getAttribute("role"));
    }

    private boolean isValidEmail(String email) {
        return email != null && email.matches("^[\\w.+-]+@[\\w-]+\\.[\\w.-]+$");
    }

    private String buildResetLink(HttpServletRequest request, String token) {
        return request.getScheme() + "://"
                + request.getServerName() + ":"
                + request.getServerPort()
                + request.getContextPath()
                + "/ResetPassword?token=" + token;
    }

    private int parseInt(String value) {
        try {
            return Integer.parseInt(trim(value));
        } catch (Exception ex) {
            return -1;
        }
    }

    private int parsePositiveInt(String value, int defaultValue) {
        try {
            int parsed = Integer.parseInt(trim(value));
            return parsed > 0 ? parsed : defaultValue;
        } catch (Exception ex) {
            return defaultValue;
        }
    }

    private Integer parseNullableInt(String value) {
        String trimmed = trim(value);
        if (trimmed == null || trimmed.isEmpty()) {
            return null;
        }
        try {
            return Integer.valueOf(trimmed);
        } catch (Exception ex) {
            return null;
        }
    }

    private String trim(String value) {
        return value == null ? null : value.trim();
    }

    private void pushFlashMessage(HttpSession session, String type, String message) {
        if (session != null) {
            session.setAttribute("umFlashType", type);
            session.setAttribute("umFlashMessage", message);
        }
    }

    private void pullFlashMessage(HttpSession session, HttpServletRequest request) {
        if (session == null) {
            return;
        }
        Object type = session.getAttribute("umFlashType");
        Object message = session.getAttribute("umFlashMessage");
        if (type != null && message != null) {
            request.setAttribute("flashType", type);
            request.setAttribute("flashMessage", message);
        }
        session.removeAttribute("umFlashType");
        session.removeAttribute("umFlashMessage");
    }
}
