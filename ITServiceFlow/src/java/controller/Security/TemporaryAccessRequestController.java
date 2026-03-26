package controller.Security;

import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.util.List;
import model.TemporaryRoleRequest;
import service.TemporaryRoleAccessService;
import service.TemporaryRoleAccessService.ActionResult;

public class TemporaryAccessRequestController extends HttpServlet {

    private final TemporaryRoleAccessService temporaryRoleAccessService = new TemporaryRoleAccessService();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        Integer userId = getSessionUserId(session);
        if (session == null || userId == null || session.getAttribute("user") == null) {
            response.sendRedirect("Login.jsp");
            return;
        }

        String currentRole = temporaryRoleAccessService.synchronizeSessionRole(session);
        if (currentRole == null) {
            session.invalidate();
            response.sendRedirect("Login.jsp");
            return;
        }

        String baseRole = trim((String) session.getAttribute("baseRole"));
        if (baseRole == null || baseRole.isEmpty()) {
            baseRole = currentRole;
        }

        List<String> requestableRoles = temporaryRoleAccessService.getRequestableRolesFor(baseRole);
        List<Integer> durationOptions = temporaryRoleAccessService.getDurationOptions();
        List<TemporaryRoleRequest> myRequests = temporaryRoleAccessService.getMyRequests(userId);
        TemporaryRoleRequest activeRequest = temporaryRoleAccessService.getActiveRequestForUser(userId);
        boolean temporaryRoleActivated = Boolean.TRUE.equals(
                session.getAttribute(TemporaryRoleAccessService.SESSION_TEMP_ROLE_ACTIVATED)
        );

        pullFlashMessage(session, request);
        request.setAttribute("currentRole", currentRole);
        request.setAttribute("baseRole", baseRole);
        request.setAttribute("dashboardUrl", resolveDashboardUrl(currentRole));
        request.setAttribute("temporaryRoleActivated", temporaryRoleActivated);
        request.setAttribute("baseDashboardUrl", resolveDashboardUrl(session.getAttribute("baseRole")));
        request.setAttribute("requestableRoles", requestableRoles);
        request.setAttribute("durationOptions", durationOptions);
        request.setAttribute("myRequests", myRequests);
        request.setAttribute("activeRequest", activeRequest);
        request.setAttribute("activeScopeSummary", resolveScopeSummary(activeRequest == null ? null : activeRequest.getRequestedRole()));
        request.getRequestDispatcher("TemporaryAccessRequest.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        Integer userId = getSessionUserId(session);
        if (session == null || userId == null || session.getAttribute("user") == null) {
            response.sendRedirect("Login.jsp");
            return;
        }

        String synchronizedRole = temporaryRoleAccessService.synchronizeSessionRole(session);
        if (synchronizedRole == null) {
            session.invalidate();
            response.sendRedirect("Login.jsp");
            return;
        }

        String action = trim(request.getParameter("action"));
        if ("activate".equals(action)) {
            handleActivate(session, response);
            return;
        }

        if ("deactivate".equals(action)) {
            handleDeactivate(session, response);
            return;
        }

        if ("request_extension".equals(action)) {
            handleRequestExtension(request, session, userId, response);
            return;
        }

        if (!"create".equals(action)) {
            pushFlashMessage(session, "error", "Unsupported action.");
            response.sendRedirect("TemporaryAccessRequest");
            return;
        }

        String requestedRole = trim(request.getParameter("requestedRole"));
        int durationMinutes = parseInt(request.getParameter("durationMinutes"));
        String reason = trim(request.getParameter("reason"));
        String baseRole = trim((String) session.getAttribute("baseRole"));
        if (baseRole == null || baseRole.isEmpty()) {
            baseRole = synchronizedRole;
        }

        TemporaryRoleAccessService.ActionResult result = temporaryRoleAccessService.submitRequest(
                userId,
                baseRole,
                requestedRole,
                durationMinutes,
                reason
        );

        pushFlashMessage(session, result.isSuccess() ? "success" : "error", result.getMessage());
        response.sendRedirect("TemporaryAccessRequest");
    }

    private void handleRequestExtension(HttpServletRequest request, HttpSession session, int userId, HttpServletResponse response)
            throws IOException {
        int sourceRequestId = parseInt(request.getParameter("sourceRequestId"));
        int durationMinutes = parseInt(request.getParameter("durationMinutes"));
        String reason = trim(request.getParameter("reason"));
        ActionResult result = temporaryRoleAccessService.requestExtension(userId, sourceRequestId, durationMinutes, reason);
        pushFlashMessage(session, result.isSuccess() ? "success" : "error", result.getMessage());
        response.sendRedirect("TemporaryAccessRequest");
    }

    private void handleActivate(HttpSession session, HttpServletResponse response) throws IOException {
        ActionResult result = temporaryRoleAccessService.activateTemporaryRole(session);
        if (!result.isSuccess()) {
            pushFlashMessage(session, "error", result.getMessage());
            response.sendRedirect("TemporaryAccessRequest");
            return;
        }

        String targetRole = trim((String) session.getAttribute("role"));
        String targetDashboard = resolveDashboardUrl(targetRole);
        response.sendRedirect(targetDashboard);
    }

    private void handleDeactivate(HttpSession session, HttpServletResponse response) throws IOException {
        ActionResult result = temporaryRoleAccessService.deactivateTemporaryRole(session);
        pushFlashMessage(session, result.isSuccess() ? "success" : "error", result.getMessage());
        if (result.isSuccess()) {
            String baseRole = trim((String) session.getAttribute("baseRole"));
            response.sendRedirect(resolveDashboardUrl(baseRole));
            return;
        }
        response.sendRedirect("TemporaryAccessRequest");
    }

    private Integer getSessionUserId(HttpSession session) {
        if (session == null) {
            return null;
        }
        Object userIdObj = session.getAttribute("userId");
        if (userIdObj instanceof Integer) {
            return (Integer) userIdObj;
        }
        if (userIdObj instanceof Number) {
            return ((Number) userIdObj).intValue();
        }
        return null;
    }

    private int parseInt(String value) {
        try {
            return Integer.parseInt(trim(value));
        } catch (Exception ex) {
            return -1;
        }
    }

    private String trim(String value) {
        return value == null ? null : value.trim();
    }

    private void pushFlashMessage(HttpSession session, String type, String message) {
        if (session == null) {
            return;
        }
        session.setAttribute("jitRequestFlashType", type);
        session.setAttribute("jitRequestFlashMessage", message);
    }

    private void pullFlashMessage(HttpSession session, HttpServletRequest request) {
        if (session == null) {
            return;
        }
        Object type = session.getAttribute("jitRequestFlashType");
        Object message = session.getAttribute("jitRequestFlashMessage");
        if (type != null && message != null) {
            request.setAttribute("flashType", type);
            request.setAttribute("flashMessage", message);
        }
        session.removeAttribute("jitRequestFlashType");
        session.removeAttribute("jitRequestFlashMessage");
    }

    private String resolveDashboardUrl(String role) {
        if (role == null) {
            return "Login";
        }
        switch (role) {
            case "Admin":
                return "AdminDashboard.jsp";
            case "Manager":
                return "ManagerDashboard";
            case "IT Support":
                return "ITDashboard.jsp";
            case "User":
                return "UserDashboard";
            default:
                return "Login";
        }
    }

    private String resolveDashboardUrl(Object roleObj) {
        return resolveDashboardUrl(roleObj == null ? null : roleObj.toString());
    }

    private String resolveScopeSummary(String requestedRole) {
        if (requestedRole == null) {
            return "No scope assigned.";
        }
        String normalized = requestedRole.trim();
        if ("IT Support".equalsIgnoreCase(normalized)) {
            return "Operational support scope: queue handling, assignment, and ticket processing.";
        }
        if ("Manager".equalsIgnoreCase(normalized)) {
            return "Managerial approval scope: RFC and temporary access approval functions.";
        }
        if ("Admin".equalsIgnoreCase(normalized)) {
            return "Administrative scope: system-wide management and configuration.";
        }
        return "Scope follows permissions of role: " + requestedRole + ".";
    }
}
