<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<%@ taglib uri="jakarta.tags.fmt" prefix="fmt" %>
<%
    if (session == null || session.getAttribute("user") == null) {
        response.sendRedirect("Login.jsp");
        return;
    }
    String currentRole = (String) session.getAttribute("role");
    if (!"Admin".equals(currentRole) && !"Manager".equals(currentRole)) {
        response.sendError(403, "You do not have permission to access this page.");
        return;
    }
%>
<c:set var="role" value="${sessionScope.role}" />
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0, user-scalable=0, minimal-ui">
    <meta http-equiv="X-UA-Compatible" content="IE=edge" />
    <title>Temporary Access Approval - ITServiceFlow</title>

    <link rel="stylesheet" href="assets/fonts/fontawesome/css/fontawesome-all.min.css">
    <link rel="stylesheet" href="assets/plugins/bootstrap/css/bootstrap.min.css">
    <link rel="stylesheet" href="assets/css/style.css">
    <style>
        body {
            background: #f4f6fb;
        }
        .jit-card {
            border-radius: 12px;
            border: 1px solid #e6eaf2;
            box-shadow: 0 6px 24px rgba(17, 24, 39, 0.05);
        }
        .jit-title {
            font-size: 28px;
            font-weight: 800;
            margin-bottom: 8px;
            color: #111827;
        }
        .jit-subtitle {
            color: #677287;
            margin-bottom: 0;
        }
        .jit-tab {
            display: inline-block;
            padding: 8px 14px;
            border-radius: 8px;
            font-weight: 600;
            color: #3f4a62;
            text-decoration: none;
            background: #edf1f9;
            margin-right: 6px;
        }
        .jit-tab.active {
            color: #ffffff;
            background: #1f379d;
        }
        .jit-table thead th {
            font-size: 12px;
            text-transform: uppercase;
            letter-spacing: .06em;
            color: #667085;
            background: #f8f9fc;
            border-top: 0;
        }
        .jit-badge {
            display: inline-flex;
            align-items: center;
            padding: 4px 10px;
            border-radius: 999px;
            font-size: 11px;
            font-weight: 700;
            letter-spacing: .02em;
        }
        .jit-badge.pending { background: #fff4d9; color: #9a6700; }
        .jit-badge.approved { background: #dff8e7; color: #17693b; }
        .jit-badge.rejected { background: #ffe7e7; color: #9f1f1f; }
        .jit-badge.revoked { background: #ffece2; color: #a53f00; }
        .jit-badge.expired { background: #eceff4; color: #5a6475; }
        .jit-comment {
            min-width: 220px;
        }
    </style>
</head>
<body>
    <jsp:include page="includes/sidebar.jsp"/>
    <jsp:include page="includes/header.jsp"/>

    <div class="pcoded-main-container">
        <div class="pcoded-wrapper">
            <div class="pcoded-content">
                <div class="pcoded-inner-content">
                    <div class="main-body">
                        <div class="page-wrapper">

                            <div class="page-header">
                                <div class="page-block">
                                    <div class="row align-items-center">
                                        <div class="col-md-12">
                                            <div class="page-header-title">
                                                <h5 class="m-b-10">Security & Access</h5>
                                            </div>
                                            <ul class="breadcrumb">
                                                <li class="breadcrumb-item">
                                                    <c:choose>
                                                        <c:when test="${role eq 'Admin'}">
                                                            <a href="${pageContext.request.contextPath}/AdminDashboard"><i class="feather icon-home"></i></a>
                                                        </c:when>
                                                        <c:otherwise>
                                                            <a href="ManagerDashboard"><i class="feather icon-home"></i></a>
                                                        </c:otherwise>
                                                    </c:choose>
                                                </li>
                                                <li class="breadcrumb-item"><a href="#">Access Control</a></li>
                                                <li class="breadcrumb-item"><a href="TemporaryAccessApproval">Temporary Access Approval</a></li>
                                            </ul>
                                        </div>
                                    </div>
                                </div>
                            </div>

                            <div class="row">
                                <div class="col-sm-12">
                                    <div class="d-flex justify-content-between align-items-start mb-4">
                                        <div>
                                            <h2 class="jit-title">Temporary Access Approvals</h2>
                                            <p class="jit-subtitle">Review and process just-in-time privileged access requests.</p>
                                        </div>
                                    </div>

                                    <c:if test="${not empty flashMessage}">
                                        <div class="alert ${flashType eq 'success' ? 'alert-success' : 'alert-danger'}">
                                            ${flashMessage}
                                        </div>
                                    </c:if>

                                    <div class="mb-3">
                                        <a href="TemporaryAccessApproval?tab=pending" class="jit-tab ${tab eq 'pending' ? 'active' : ''}">Pending</a>
                                        <a href="TemporaryAccessApproval?tab=all" class="jit-tab ${tab eq 'all' ? 'active' : ''}">All Requests</a>
                                    </div>

                                    <div class="card jit-card">
                                        <div class="card-body p-0">
                                            <div class="table-responsive">
                                                <table class="table table-hover mb-0 jit-table">
                                                    <thead>
                                                        <tr>
                                                            <th>Requester</th>
                                                            <th>Role Change</th>
                                                            <th>Duration</th>
                                                            <th>Reason</th>
                                                            <th>Status</th>
                                                            <th>Requested At</th>
                                                            <th>Expires At</th>
                                                            <th>Action</th>
                                                        </tr>
                                                    </thead>
                                                    <tbody>
                                                        <c:choose>
                                                            <c:when test="${empty requests}">
                                                                <tr>
                                                                    <td colspan="8" class="text-center text-muted py-4">No requests found.</td>
                                                                </tr>
                                                            </c:when>
                                                            <c:otherwise>
                                                                <c:forEach var="req" items="${requests}">
                                                                    <tr>
                                                                        <td>
                                                                            <strong>${req.requesterName}</strong>
                                                                            <div class="text-muted">User ID #${req.userId}</div>
                                                                        </td>
                                                                        <td>
                                                                            ${req.currentRole}
                                                                            <i class="feather icon-arrow-right mx-1"></i>
                                                                            <strong>${req.requestedRole}</strong>
                                                                        </td>
                                                                        <td>
                                                                            <c:choose>
                                                                                <c:when test="${req.durationMinutes < 60}">${req.durationMinutes} minutes</c:when>
                                                                                <c:otherwise>${req.durationMinutes / 60} hours</c:otherwise>
                                                                            </c:choose>
                                                                        </td>
                                                                        <td style="max-width: 280px;">${req.reason}</td>
                                                                        <td>
                                                                            <span class="jit-badge ${req.status == 'Pending' ? 'pending' : req.status == 'Approved' ? 'approved' : req.status == 'Rejected' ? 'rejected' : req.status == 'Revoked' ? 'revoked' : 'expired'}">
                                                                                ${req.status}
                                                                            </span>
                                                                            <c:if test="${not empty req.reviewerName}">
                                                                                <div class="text-muted mt-1">by ${req.reviewerName}</div>
                                                                            </c:if>
                                                                            <c:if test="${not empty req.reviewComment}">
                                                                                <div class="text-muted mt-1">${req.reviewComment}</div>
                                                                            </c:if>
                                                                        </td>
                                                                        <td><fmt:formatDate value="${req.requestedAt}" pattern="dd/MM/yyyy HH:mm"/></td>
                                                                        <td>
                                                                            <c:choose>
                                                                                <c:when test="${req.expiresAt != null}">
                                                                                    <fmt:formatDate value="${req.expiresAt}" pattern="dd/MM/yyyy HH:mm"/>
                                                                                </c:when>
                                                                                <c:otherwise>-</c:otherwise>
                                                                            </c:choose>
                                                                        </td>
                                                                        <td>
                                                                            <c:choose>
                                                                                <c:when test="${req.status == 'Pending'}">
                                                                                    <c:choose>
                                                                                        <c:when test="${req.userId eq sessionScope.userId}">
                                                                                            <span class="text-muted">Self-review not allowed</span>
                                                                                        </c:when>
                                                                                        <c:otherwise>
                                                                                            <form action="TemporaryAccessApproval" method="post" class="mb-2">
                                                                                                <input type="hidden" name="requestId" value="${req.id}">
                                                                                                <input type="text" name="comment" class="form-control form-control-sm jit-comment mb-2" placeholder="Comment (required for reject)">
                                                                                                <div class="d-flex">
                                                                                                    <button type="submit" name="action" value="approve" class="btn btn-success btn-sm mr-2">Approve</button>
                                                                                                    <button type="submit" name="action" value="reject" class="btn btn-outline-danger btn-sm">Reject</button>
                                                                                                </div>
                                                                                            </form>
                                                                                        </c:otherwise>
                                                                                    </c:choose>
                                                                                </c:when>
                                                                                <c:when test="${req.status == 'Approved'}">
                                                                                    <c:choose>
                                                                                        <c:when test="${req.userId eq sessionScope.userId}">
                                                                                            <span class="text-muted">Self-revoke not allowed</span>
                                                                                        </c:when>
                                                                                        <c:otherwise>
                                                                                            <form action="TemporaryAccessApproval" method="post" class="mb-2">
                                                                                                <input type="hidden" name="requestId" value="${req.id}">
                                                                                                <input type="text" name="comment" class="form-control form-control-sm jit-comment mb-2" placeholder="Revoke reason (required)" required>
                                                                                                <button type="submit" name="action" value="revoke" class="btn btn-warning btn-sm">Revoke</button>
                                                                                            </form>
                                                                                        </c:otherwise>
                                                                                    </c:choose>
                                                                                </c:when>
                                                                                <c:otherwise>
                                                                                    <span class="text-muted">Processed</span>
                                                                                </c:otherwise>
                                                                            </c:choose>
                                                                        </td>
                                                                    </tr>
                                                                </c:forEach>
                                                            </c:otherwise>
                                                        </c:choose>
                                                    </tbody>
                                                </table>
                                            </div>
                                        </div>
                                    </div>

                                </div>
                            </div>

                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <script src="assets/plugins/jquery/js/jquery.min.js"></script>
    <script src="assets/js/vendor-all.min.js"></script>
    <script src="assets/plugins/bootstrap/js/bootstrap.min.js"></script>
    <script src="assets/js/pcoded.min.js"></script>
</body>
</html>
