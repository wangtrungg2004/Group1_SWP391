<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<%@ taglib uri="jakarta.tags.fmt" prefix="fmt" %>
<%
    if (session == null || session.getAttribute("user") == null) {
        response.sendRedirect("Login.jsp");
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
    <title>Temporary Access Request - ITServiceFlow</title>

    <link rel="stylesheet" href="assets/fonts/fontawesome/css/fontawesome-all.min.css">
    <link rel="stylesheet" href="assets/plugins/animation/css/animate.min.css">
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
        .jit-table thead th {
            font-size: 12px;
            text-transform: uppercase;
            letter-spacing: .06em;
            color: #667085;
            background: #f8f9fc;
            border-top: 0;
        }
        .jit-help {
            font-size: 12px;
            color: #6b7280;
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
                                                        <c:when test="${role eq 'IT Support'}">
                                                            <a href="${pageContext.request.contextPath}/ITDashboard"><i class="feather icon-home"></i></a>
                                                        </c:when>
                                                        <c:when test="${role eq 'Manager'}">
                                                            <a href="ManagerDashboard"><i class="feather icon-home"></i></a>
                                                        </c:when>
                                                        <c:when test="${role eq 'Admin'}">
                                                            <a href="${pageContext.request.contextPath}/AdminDashboard"><i class="feather icon-home"></i></a>
                                                        </c:when>
                                                        <c:otherwise>
                                                            <a href="UserDashboard"><i class="feather icon-home"></i></a>
                                                        </c:otherwise>
                                                    </c:choose>
                                                </li>
                                                <li class="breadcrumb-item"><a href="#">Access Control</a></li>
                                                <li class="breadcrumb-item"><a href="TemporaryAccessRequest">Temporary Access Request</a></li>
                                            </ul>
                                        </div>
                                    </div>
                                </div>
                            </div>

                            <div class="row">
                                <div class="col-sm-12">
                                    <div class="d-flex justify-content-between align-items-start mb-4">
                                        <div>
                                            <h2 class="jit-title">Temporary Privileged Access</h2>
                                            <p class="jit-subtitle">Request short-term elevated permissions following least-privilege principle.</p>
                                        </div>
                                    </div>

                                    <c:if test="${not empty flashMessage}">
                                        <div class="alert ${flashType eq 'success' ? 'alert-success' : 'alert-danger'}">
                                            ${flashMessage}
                                        </div>
                                    </c:if>

                                    <c:if test="${not empty activeRequest}">
                                        <div class="alert alert-info d-md-flex justify-content-between align-items-center">
                                            <div>
                                                <strong>Active temporary role:</strong>
                                                ${activeRequest.requestedRole}
                                                <span class="ml-2">(expires at <fmt:formatDate value="${activeRequest.expiresAt}" pattern="dd/MM/yyyy HH:mm" />)</span>
                                                <c:if test="${not temporaryRoleActivated}">
                                                    <div class="jit-help mt-1">Temporary role is available but not active in this session.</div>
                                                </c:if>
                                            </div>
                                            <div class="d-flex mt-2 mt-md-0">
                                                <c:choose>
                                                    <c:when test="${temporaryRoleActivated}">
                                                        <a href="${dashboardUrl}" class="btn btn-sm btn-primary mr-2">
                                                            Go to ${currentRole} Dashboard
                                                        </a>
                                                        <form action="TemporaryAccessRequest" method="post" class="mb-0">
                                                            <input type="hidden" name="action" value="deactivate">
                                                            <button type="submit" class="btn btn-sm btn-outline-primary">Back to My Base Dashboard</button>
                                                        </form>
                                                    </c:when>
                                                    <c:otherwise>
                                                        <form action="TemporaryAccessRequest" method="post" class="mb-0">
                                                            <input type="hidden" name="action" value="activate">
                                                            <button type="submit" class="btn btn-sm btn-primary">
                                                                Go to ${activeRequest.requestedRole} Dashboard
                                                            </button>
                                                        </form>
                                                    </c:otherwise>
                                                </c:choose>
                                            </div>
                                        </div>
                                    </c:if>

                                    <div class="card jit-card mb-4">
                                        <div class="card-body">
                                            <h5 class="mb-3">Create New Request</h5>
                                            <p class="jit-help mb-3">Current effective role: <strong>${currentRole}</strong></p>

                                            <c:choose>
                                                <c:when test="${empty requestableRoles}">
                                                    <div class="alert alert-warning mb-0">No eligible temporary role available for your current role.</div>
                                                </c:when>
                                                <c:otherwise>
                                                    <form action="TemporaryAccessRequest" method="post">
                                                        <input type="hidden" name="action" value="create">

                                                        <div class="row">
                                                            <div class="col-md-4 form-group">
                                                                <label>Requested role</label>
                                                                <select class="form-control" name="requestedRole" required>
                                                                    <option value="">Select role</option>
                                                                    <c:forEach var="r" items="${requestableRoles}">
                                                                        <option value="${r}">${r}</option>
                                                                    </c:forEach>
                                                                </select>
                                                            </div>

                                                            <div class="col-md-4 form-group">
                                                                <label>Duration</label>
                                                                <select class="form-control" name="durationMinutes" required>
                                                                    <option value="">Select duration</option>
                                                                    <c:forEach var="duration" items="${durationOptions}">
                                                                        <option value="${duration}">
                                                                            <c:choose>
                                                                                <c:when test="${duration < 60}">${duration} minutes</c:when>
                                                                                <c:otherwise>${duration / 60} hours</c:otherwise>
                                                                            </c:choose>
                                                                        </option>
                                                                    </c:forEach>
                                                                </select>
                                                            </div>

                                                            <div class="col-md-4 form-group d-flex align-items-end">
                                                                <button type="submit" class="btn btn-primary btn-block">Submit Request</button>
                                                            </div>
                                                        </div>

                                                        <div class="form-group mb-0">
                                                            <label>Business reason</label>
                                                            <textarea class="form-control" name="reason" rows="3" maxlength="500" required
                                                                      placeholder="Why do you need elevated access and for what task?"></textarea>
                                                        </div>
                                                    </form>
                                                </c:otherwise>
                                            </c:choose>
                                        </div>
                                    </div>

                                    <div class="card jit-card">
                                        <div class="card-body p-0">
                                            <div class="p-3 border-bottom">
                                                <h5 class="mb-0">My Requests</h5>
                                            </div>

                                            <div class="table-responsive">
                                                <table class="table table-hover mb-0 jit-table">
                                                    <thead>
                                                        <tr>
                                                            <th>Requested Role</th>
                                                            <th>Duration</th>
                                                            <th>Reason</th>
                                                            <th>Status</th>
                                                            <th>Requested At</th>
                                                            <th>Expires At</th>
                                                            <th>Reviewed By</th>
                                                        </tr>
                                                    </thead>
                                                    <tbody>
                                                        <c:choose>
                                                            <c:when test="${empty myRequests}">
                                                                <tr>
                                                                    <td colspan="7" class="text-center text-muted py-4">No temporary access requests yet.</td>
                                                                </tr>
                                                            </c:when>
                                                            <c:otherwise>
                                                                <c:forEach var="req" items="${myRequests}">
                                                                    <tr>
                                                                        <td><strong>${req.requestedRole}</strong></td>
                                                                        <td>
                                                                            <c:choose>
                                                                                <c:when test="${req.durationMinutes < 60}">${req.durationMinutes} minutes</c:when>
                                                                                <c:otherwise>${req.durationMinutes / 60} hours</c:otherwise>
                                                                            </c:choose>
                                                                        </td>
                                                                        <td>${req.reason}</td>
                                                                        <td>
                                                                            <span class="jit-badge ${req.status == 'Pending' ? 'pending' : req.status == 'Approved' ? 'approved' : req.status == 'Rejected' ? 'rejected' : req.status == 'Revoked' ? 'revoked' : 'expired'}">
                                                                                ${req.status}
                                                                            </span>
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
                                                                                <c:when test="${not empty req.reviewerName}">
                                                                                    ${req.reviewerName}
                                                                                </c:when>
                                                                                <c:otherwise>-</c:otherwise>
                                                                            </c:choose>
                                                                            <c:if test="${not empty req.reviewComment}">
                                                                                <div class="jit-help mt-1">${req.reviewComment}</div>
                                                                            </c:if>
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
