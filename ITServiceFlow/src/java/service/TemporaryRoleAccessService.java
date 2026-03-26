package service;

import dao.TemporaryRoleRequestDao;
import dao.UserDao;
import jakarta.servlet.http.HttpSession;
import java.sql.Timestamp;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collections;
import java.util.Date;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import model.TemporaryRoleRequest;
import model.Users;

public class TemporaryRoleAccessService {

    public static final String SESSION_TEMP_ROLE_ACTIVATED = "jitTemporaryRoleActivated";

    private final TemporaryRoleRequestDao temporaryRoleDao = new TemporaryRoleRequestDao();
    private final UserDao userDao = new UserDao();
    private final AuditLogService auditLogService = new AuditLogService();

    private static final List<Integer> DURATION_OPTIONS = Collections.unmodifiableList(
            Arrays.asList(30, 60, 120, 240, 480)
    );

    private static final List<String> REQUESTABLE_ROLES = Collections.unmodifiableList(
            Arrays.asList("IT Support", "Manager")
    );

    private static final Map<String, Integer> ROLE_RANK;

    static {
        Map<String, Integer> rank = new LinkedHashMap<>();
        rank.put("User", 1);
        rank.put("IT Support", 2);
        rank.put("Manager", 3);
        rank.put("Admin", 4);
        ROLE_RANK = Collections.unmodifiableMap(rank);
    }

    public ActionResult submitRequest(int userId, String currentRole, String requestedRole, int durationMinutes, String reason) {
        return submitRequestInternal(
                userId,
                currentRole,
                requestedRole,
                durationMinutes,
                reason,
                false,
                "JIT_REQUEST_CREATE",
                "Temporary access request submitted successfully."
        );
    }

    public ActionResult requestExtension(int userId, int sourceRequestId, int durationMinutes, String reason) {
        if (userId <= 0 || sourceRequestId <= 0) {
            return ActionResult.fail("Invalid request.");
        }

        TemporaryRoleRequest source = temporaryRoleDao.getById(sourceRequestId);
        if (source == null || source.getUserId() != userId) {
            return ActionResult.fail("Request not found.");
        }

        TemporaryRoleRequest activeApproved = temporaryRoleDao.getActiveApprovedRequestForUser(userId);
        if (activeApproved == null) {
            return ActionResult.fail("No active temporary access found to extend.");
        }

        String activeRole = normalizeRole(activeApproved.getRequestedRole());
        String sourceRole = normalizeRole(source.getRequestedRole());
        if (activeRole == null || !activeRole.equals(sourceRole)) {
            return ActionResult.fail("You can only extend your current active temporary role.");
        }

        Users dbUser = userDao.getUserById(userId);
        String currentBaseRole = dbUser == null ? null : normalizeRole(dbUser.getRole());
        if (currentBaseRole == null) {
            return ActionResult.fail("Cannot determine your current base role.");
        }

        String normalizedReason = reason == null ? "" : reason.trim();
        if (normalizedReason.isEmpty()) {
            normalizedReason = "Request extension for temporary role " + activeRole + ".";
        }

        return submitRequestInternal(
                userId,
                currentBaseRole,
                activeRole,
                durationMinutes,
                normalizedReason,
                true,
                "JIT_REQUEST_EXTENSION",
                "Temporary access extension request submitted successfully."
        );
    }

    private ActionResult submitRequestInternal(
            int userId,
            String currentRole,
            String requestedRole,
            int durationMinutes,
            String reason,
            boolean allowWhenActive,
            String auditAction,
            String successMessage
    ) {
        if (userId <= 0) {
            return ActionResult.fail("Invalid user.");
        }

        String normalizedCurrentRole = normalizeRole(currentRole);
        String normalizedRequestedRole = normalizeRole(requestedRole);
        String normalizedReason = reason == null ? "" : reason.trim();

        if (normalizedCurrentRole == null) {
            return ActionResult.fail("Cannot determine your current role.");
        }
        if (normalizedRequestedRole == null) {
            return ActionResult.fail("Requested role is required.");
        }
        if (!DURATION_OPTIONS.contains(durationMinutes)) {
            return ActionResult.fail("Invalid temporary access duration.");
        }
        if (normalizedReason.isEmpty()) {
            return ActionResult.fail("Business reason is required.");
        }
        if (normalizedReason.length() > 500) {
            return ActionResult.fail("Business reason cannot exceed 500 characters.");
        }
        if (!isRequestedRoleAllowed(normalizedCurrentRole, normalizedRequestedRole)) {
            return ActionResult.fail("Requested role is not allowed for your account.");
        }
        if (temporaryRoleDao.hasPendingRequest(userId)) {
            return ActionResult.fail("You already have a pending temporary access request.");
        }

        TemporaryRoleRequest activeApproved = temporaryRoleDao.getActiveApprovedRequestForUser(userId);
        if (activeApproved != null) {
            String activeRole = normalizeRole(activeApproved.getRequestedRole());
            boolean sameTargetRole = activeRole != null && activeRole.equals(normalizedRequestedRole);
            if (!allowWhenActive || !sameTargetRole) {
                String expiresAtText = formatDateTime(activeApproved.getExpiresAt());
                return ActionResult.fail("You already have an active temporary role: "
                        + activeApproved.getRequestedRole()
                        + " (expires at " + expiresAtText + "). Revoke it or wait until expiry.");
            }

            normalizedReason = "[Extension] " + normalizedReason;
            if (normalizedReason.length() > 500) {
                normalizedReason = normalizedReason.substring(0, 500);
            }
            if (normalizedReason.trim().isEmpty()) {
                return ActionResult.fail("Extension reason is required.");
            }
        }

        boolean created = temporaryRoleDao.createRequest(
                userId,
                normalizedCurrentRole,
                normalizedRequestedRole,
                durationMinutes,
                normalizedReason
        );

        if (!created) {
            return ActionResult.fail("Failed to create temporary access request.");
        }

        TemporaryRoleRequest createdRequest = temporaryRoleDao.getLatestRequestByUser(userId);
        if (createdRequest != null) {
            auditLogService.createAuditLog(userId, auditAction, "TemporaryRoleRequest", createdRequest.getId());
        }

        return ActionResult.ok(successMessage);
    }

    public ActionResult processDecision(int requestId, int approverId, String decision, String comment) {
        if (requestId <= 0 || approverId <= 0) {
            return ActionResult.fail("Invalid request.");
        }

        String normalizedDecision = decision == null ? "" : decision.trim().toLowerCase();
        String normalizedComment = comment == null ? "" : comment.trim();

        if (!"approve".equals(normalizedDecision)
                && !"reject".equals(normalizedDecision)
                && !"revoke".equals(normalizedDecision)) {
            return ActionResult.fail("Unsupported action.");
        }

        TemporaryRoleRequest request = temporaryRoleDao.getById(requestId);
        if (request == null) {
            return ActionResult.fail("Request not found.");
        }
        if (request.getUserId() == approverId) {
            return ActionResult.fail("You cannot review your own temporary access request.");
        }

        if (("reject".equals(normalizedDecision) || "revoke".equals(normalizedDecision))
                && normalizedComment.isEmpty()) {
            return ActionResult.fail(("revoke".equals(normalizedDecision)
                    ? "Revoke reason is required."
                    : "Reject reason is required."));
        }
        if (normalizedComment.length() > 500) {
            return ActionResult.fail("Comment cannot exceed 500 characters.");
        }

        boolean changed;
        boolean extensionApproval = false;
        if ("approve".equals(normalizedDecision)) {
            TemporaryRoleRequest activeApproved = temporaryRoleDao.getActiveApprovedRequestForUser(request.getUserId());
            if (activeApproved != null) {
                String activeRole = normalizeRole(activeApproved.getRequestedRole());
                String requestRole = normalizeRole(request.getRequestedRole());
                boolean isExtensionApproval = activeRole != null && activeRole.equals(requestRole);
                if (!isExtensionApproval) {
                    return ActionResult.fail("User already has an active temporary role: "
                            + activeApproved.getRequestedRole()
                            + " (expires at " + formatDateTime(activeApproved.getExpiresAt()) + ").");
                }

                Date now = new Date();
                Date baseExpiry = activeApproved.getExpiresAt() != null && activeApproved.getExpiresAt().after(now)
                        ? activeApproved.getExpiresAt()
                        : now;
                long extensionMillis = request.getDurationMinutes() * 60L * 1000L;
                Date newExpiry = new Date(baseExpiry.getTime() + extensionMillis);

                changed = temporaryRoleDao.approveRequestWithCustomExpiry(
                        requestId,
                        approverId,
                        normalizedComment,
                        new Timestamp(newExpiry.getTime())
                );
                if (changed) {
                    temporaryRoleDao.revokeRequest(
                            activeApproved.getId(),
                            approverId,
                            "Superseded by approved extension request #" + requestId
                    );
                    extensionApproval = true;
                }
            } else {
                changed = temporaryRoleDao.approveRequest(requestId, approverId, normalizedComment);
            }
        } else if ("revoke".equals(normalizedDecision)) {
            changed = temporaryRoleDao.revokeRequest(requestId, approverId, normalizedComment);
        } else {
            changed = temporaryRoleDao.rejectRequest(requestId, approverId, normalizedComment);
        }

        if (!changed) {
            if ("revoke".equals(normalizedDecision)) {
                return ActionResult.fail("Request cannot be revoked. It may be expired, already revoked, or not approved.");
            }
            return ActionResult.fail("Request was not updated. It may already be processed.");
        }

        String auditAction;
        String successMessage;
        if ("approve".equals(normalizedDecision)) {
            if (extensionApproval) {
                auditAction = "JIT_REQUEST_EXTENSION_APPROVE";
                successMessage = "Temporary access extension approved.";
            } else {
                auditAction = "JIT_REQUEST_APPROVE";
                successMessage = "Temporary access request approved.";
            }
        } else if ("revoke".equals(normalizedDecision)) {
            auditAction = "JIT_ROLE_MANUAL_REVOKE";
            successMessage = "Temporary access revoked successfully.";
        } else {
            auditAction = "JIT_REQUEST_REJECT";
            successMessage = "Temporary access request rejected.";
        }

        auditLogService.createAuditLog(
                approverId,
                auditAction,
                "TemporaryRoleRequest",
                requestId
        );

        return ActionResult.ok(successMessage);
    }

    public ActionResult activateTemporaryRole(HttpSession session) {
        if (session == null || session.getAttribute("user") == null) {
            return ActionResult.fail("Please login again.");
        }

        session.setAttribute(SESSION_TEMP_ROLE_ACTIVATED, true);
        String synchronizedRole = synchronizeSessionRole(session);
        if (synchronizedRole == null) {
            return ActionResult.fail("Cannot activate temporary role right now.");
        }

        Object activeRequestObj = session.getAttribute("activeTemporaryRoleRequest");
        if (!(activeRequestObj instanceof TemporaryRoleRequest)) {
            session.setAttribute(SESSION_TEMP_ROLE_ACTIVATED, false);
            synchronizeSessionRole(session);
            return ActionResult.fail("No active temporary role found.");
        }

        return ActionResult.ok("Temporary role activated.");
    }

    public ActionResult deactivateTemporaryRole(HttpSession session) {
        if (session == null || session.getAttribute("user") == null) {
            return ActionResult.fail("Please login again.");
        }

        session.setAttribute(SESSION_TEMP_ROLE_ACTIVATED, false);
        String synchronizedRole = synchronizeSessionRole(session);
        if (synchronizedRole == null) {
            return ActionResult.fail("Cannot switch back to base role right now.");
        }
        return ActionResult.ok("Switched back to your base role.");
    }

    public String synchronizeSessionRole(HttpSession session) {
        if (session == null) {
            return null;
        }

        Integer userId = parseSessionUserId(session);
        if (userId == null || userId <= 0) {
            return null;
        }

        expireApprovedRequestsAndAudit();

        Users dbUser = userDao.getUserById(userId);
        if (dbUser == null || !dbUser.isActive()) {
            return null;
        }

        String baseRole = normalizeRole(dbUser.getRole());
        if (baseRole == null) {
            return null;
        }

        TemporaryRoleRequest activeRequest = temporaryRoleDao.getActiveApprovedRequestForUser(userId);
        String temporaryGrantedRole = activeRequest != null
                ? normalizeRole(activeRequest.getRequestedRole())
                : null;
        boolean temporaryRoleActivated = Boolean.TRUE.equals(session.getAttribute(SESSION_TEMP_ROLE_ACTIVATED));
        boolean canApplyTemporaryRole = temporaryGrantedRole != null && isRoleHigherThan(baseRole, temporaryGrantedRole);
        if (!canApplyTemporaryRole) {
            temporaryRoleActivated = false;
        }

        String effectiveRole = temporaryRoleActivated ? temporaryGrantedRole : baseRole;

        session.setAttribute("baseRole", baseRole);
        session.setAttribute("effectiveRole", effectiveRole);
        session.setAttribute("role", effectiveRole);
        session.setAttribute("activeTemporaryRoleRequest", activeRequest);
        session.setAttribute(SESSION_TEMP_ROLE_ACTIVATED, temporaryRoleActivated);

        Object sessionUserObj = session.getAttribute("user");
        if (sessionUserObj instanceof Users) {
            ((Users) sessionUserObj).setRole(effectiveRole);
        }

        return effectiveRole;
    }

    public List<TemporaryRoleRequest> getMyRequests(int userId) {
        return temporaryRoleDao.getRequestsByUser(userId);
    }

    public List<TemporaryRoleRequest> getPendingRequests() {
        expireApprovedRequestsAndAudit();
        return temporaryRoleDao.getPendingRequests();
    }

    public List<TemporaryRoleRequest> getAllRequests() {
        expireApprovedRequestsAndAudit();
        return temporaryRoleDao.getAllRequests();
    }

    public TemporaryRoleRequest getActiveRequestForUser(int userId) {
        expireApprovedRequestsAndAudit();
        return temporaryRoleDao.getActiveApprovedRequestForUser(userId);
    }

    public List<Integer> getDurationOptions() {
        return DURATION_OPTIONS;
    }

    public List<String> getRequestableRolesFor(String currentRole) {
        String normalizedCurrentRole = normalizeRole(currentRole);
        if (normalizedCurrentRole == null) {
            return Collections.emptyList();
        }

        List<String> options = new ArrayList<>();
        for (String targetRole : REQUESTABLE_ROLES) {
            if (isRequestedRoleAllowed(normalizedCurrentRole, targetRole)) {
                options.add(targetRole);
            }
        }
        return options;
    }

    private void expireApprovedRequestsAndAudit() {
        List<TemporaryRoleRequest> expired = temporaryRoleDao.expireApprovedRequests();
        for (TemporaryRoleRequest request : expired) {
            auditLogService.createAuditLog(
                    request.getUserId(),
                    "JIT_ROLE_AUTO_REVOKE",
                    "TemporaryRoleRequest",
                    request.getId()
            );
        }
    }

    private boolean isRequestedRoleAllowed(String currentRole, String requestedRole) {
        if (!REQUESTABLE_ROLES.contains(requestedRole)) {
            return false;
        }
        return isRoleHigherThan(currentRole, requestedRole);
    }

    private boolean isRoleHigherThan(String currentRole, String requestedRole) {
        Integer currentRank = ROLE_RANK.get(currentRole);
        Integer requestedRank = ROLE_RANK.get(requestedRole);
        return currentRank != null && requestedRank != null && requestedRank > currentRank;
    }

    private String normalizeRole(String role) {
        if (role == null) {
            return null;
        }

        String trimmed = role.trim();
        if (trimmed.isEmpty()) {
            return null;
        }

        for (String knownRole : ROLE_RANK.keySet()) {
            if (knownRole.equalsIgnoreCase(trimmed)) {
                return knownRole;
            }
        }
        return trimmed;
    }

    private Integer parseSessionUserId(HttpSession session) {
        Object userIdObj = session.getAttribute("userId");
        if (userIdObj instanceof Integer) {
            return (Integer) userIdObj;
        }
        if (userIdObj instanceof Number) {
            return ((Number) userIdObj).intValue();
        }
        return null;
    }

    private String formatDateTime(java.util.Date value) {
        if (value == null) {
            return "N/A";
        }
        return new SimpleDateFormat("dd/MM/yyyy HH:mm").format(value);
    }

    public static class ActionResult {
        private final boolean success;
        private final String message;

        private ActionResult(boolean success, String message) {
            this.success = success;
            this.message = message;
        }

        public static ActionResult ok(String message) {
            return new ActionResult(true, message);
        }

        public static ActionResult fail(String message) {
            return new ActionResult(false, message);
        }

        public boolean isSuccess() {
            return success;
        }

        public String getMessage() {
            return message;
        }
    }
}
