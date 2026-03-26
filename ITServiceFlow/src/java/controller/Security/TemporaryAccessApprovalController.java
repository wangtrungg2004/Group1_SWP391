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

public class TemporaryAccessApprovalController extends HttpServlet {

    private final TemporaryRoleAccessService temporaryRoleAccessService = new TemporaryRoleAccessService();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        Integer approverId = getSessionUserId(session);
        if (session == null || approverId == null || session.getAttribute("user") == null) {
            response.sendRedirect("Login.jsp");
            return;
        }

        String role = temporaryRoleAccessService.synchronizeSessionRole(session);
        if (role == null) {
            session.invalidate();
            response.sendRedirect("Login.jsp");
            return;
        }
        if (!isApprover(role) || !isBaseApprover(session)) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN, "You do not have permission to access this page.");
            return;
        }

        String tab = trim(request.getParameter("tab"));
        if (tab == null || tab.isEmpty()) {
            tab = "pending";
        }

        List<TemporaryRoleRequest> requests = "all".equalsIgnoreCase(tab)
                ? temporaryRoleAccessService.getAllRequests()
                : temporaryRoleAccessService.getPendingRequests();

        pullFlashMessage(session, request);
        request.setAttribute("canApproveTemporaryAccess", Boolean.TRUE);
        request.setAttribute("tab", tab);
        request.setAttribute("requests", requests);
        request.getRequestDispatcher("TemporaryAccessApproval.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        Integer approverId = getSessionUserId(session);
        if (session == null || approverId == null || session.getAttribute("user") == null) {
            response.sendRedirect("Login.jsp");
            return;
        }

        String role = temporaryRoleAccessService.synchronizeSessionRole(session);
        if (role == null) {
            session.invalidate();
            response.sendRedirect("Login.jsp");
            return;
        }
        if (!isApprover(role) || !isBaseApprover(session)) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN, "You do not have permission to perform this action.");
            return;
        }

        String action = trim(request.getParameter("action"));
        int requestId = parseInt(request.getParameter("requestId"));
        String comment = trim(request.getParameter("comment"));

        if (requestId <= 0) {
            pushFlashMessage(session, "error", "Invalid request ID.");
            response.sendRedirect("TemporaryAccessApproval");
            return;
        }

        TemporaryRoleAccessService.ActionResult result = temporaryRoleAccessService.processDecision(
                requestId,
                approverId,
                action,
                comment
        );

        pushFlashMessage(session, result.isSuccess() ? "success" : "error", result.getMessage());
        response.sendRedirect("TemporaryAccessApproval");
    }

    private boolean isApprover(String role) {
        if (role == null) {
            return false;
        }
        String normalized = role.trim();
        return "Admin".equalsIgnoreCase(normalized) || "Manager".equalsIgnoreCase(normalized);
    }

    private boolean isBaseApprover(HttpSession session) {
        if (session == null) {
            return false;
        }
        Object baseRoleObj = session.getAttribute("baseRole");
        return isApprover(baseRoleObj == null ? null : baseRoleObj.toString());
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
        session.setAttribute("jitApprovalFlashType", type);
        session.setAttribute("jitApprovalFlashMessage", message);
    }

    private void pullFlashMessage(HttpSession session, HttpServletRequest request) {
        if (session == null) {
            return;
        }
        Object type = session.getAttribute("jitApprovalFlashType");
        Object message = session.getAttribute("jitApprovalFlashMessage");
        if (type != null && message != null) {
            request.setAttribute("flashType", type);
            request.setAttribute("flashMessage", message);
        }
        session.removeAttribute("jitApprovalFlashType");
        session.removeAttribute("jitApprovalFlashMessage");
    }
}
