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
    <title>User Management - ITServiceFlow</title>

    <link rel="stylesheet" href="assets/fonts/fontawesome/css/fontawesome-all.min.css">
    <link rel="stylesheet" href="assets/plugins/animation/css/animate.min.css">
    <link rel="stylesheet" href="assets/plugins/bootstrap/css/bootstrap.min.css">
    <link rel="stylesheet" href="assets/css/style.css">
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800&display=swap" rel="stylesheet">
    <style>
        .pcoded-wrapper,
        .pcoded-content,
        .pcoded-inner-content,
        .main-body,
        .page-wrapper {
            max-width: 100% !important;
            width: 100% !important;
        }
        .pcoded-main-container {
            width: 100% !important;
            margin-left: 264px !important;
        }
        .pcoded-navbar.navbar-collapsed ~ .pcoded-main-container {
            margin-left: 80px !important;
        }
        body {
            overflow-x: hidden;
            font-family: 'Inter', sans-serif;
            background: #f4f6fb;
        }
        .table td {
            vertical-align: top;
        }
        .small-help {
            font-size: 12px;
            color: #6c757d;
        }
        .um-title {
            font-size: 40px;
            font-weight: 800;
            color: #161b28;
            margin: 0;
            line-height: 1.1;
        }
        .um-subtitle {
            margin-top: 8px;
            margin-bottom: 0;
            color: #5e6678;
            font-size: 15px;
            font-weight: 500;
        }
        .um-filter-card,
        .um-table-card {
            border-radius: 14px;
            border: 1px solid #e7ebf3;
            box-shadow: 0 6px 20px rgba(22, 27, 40, 0.04);
            overflow: hidden;
        }
        .um-table-card .card-body {
            background: #ffffff;
        }
        .um-user-table {
            margin: 0;
        }
        .um-user-table thead th {
            border-top: 0;
            border-bottom: 1px solid #e7ebf3;
            background: #f7f9fc;
            font-size: 11px;
            text-transform: uppercase;
            letter-spacing: 0.08em;
            color: #667085;
            font-weight: 800;
            padding: 14px 16px;
        }
        .um-user-table tbody td {
            border-top: 1px solid #edf1f7;
            padding: 14px 16px;
            vertical-align: middle;
            background: #ffffff;
        }
        .um-user-table tbody tr:hover td {
            background: #fafcff;
        }
        .um-user-name {
            font-size: 16px;
            font-weight: 700;
            color: #111827;
        }
        .um-user-meta {
            font-size: 12px;
            color: #6b7280;
            margin-top: 3px;
        }
        .um-role-select {
            min-width: 170px;
            border-color: #dbe1ea;
            border-radius: 8px;
            font-size: 13px;
            font-weight: 600;
        }
        .um-status-pill {
            display: inline-flex;
            align-items: center;
            padding: 4px 11px;
            border-radius: 999px;
            font-size: 11px;
            font-weight: 800;
            letter-spacing: 0.02em;
        }
        .um-status-pill.is-active {
            background: #d9f8df;
            color: #1f8a46;
        }
        .um-status-pill.is-inactive {
            background: #e9ecf2;
            color: #576075;
        }
        .um-actions .btn {
            display: block;
            width: 100%;
            border-radius: 8px;
            font-weight: 600;
            font-size: 12px;
            padding: 6px 10px;
        }
        .um-actions .btn + .btn {
            margin-top: 8px;
        }
        .um-pagination-wrap {
            border-top: 1px solid #e7ebf3;
            padding: 14px 16px;
            background: #fbfcfe;
        }
        .um-pagination-text {
            font-size: 12px;
            color: #616b7f;
            font-weight: 500;
        }
        .um-pagination .page-link {
            border: 0;
            margin: 0 2px;
            border-radius: 8px;
            min-width: 32px;
            height: 32px;
            display: inline-flex;
            align-items: center;
            justify-content: center;
            color: #3f4a62;
            font-size: 12px;
            font-weight: 700;
            background: transparent;
        }
        .um-pagination .page-item.active .page-link {
            background: #1f379d;
            color: #ffffff;
        }
        .um-pagination .page-link:hover {
            background: #e8edf8;
            color: #1f379d;
        }
        .um-filters label {
            font-size: 12px;
            color: #6a7386;
            font-weight: 700;
            margin-bottom: 6px;
        }
        .um-filters .form-control {
            border-radius: 8px;
            border-color: #dbe1ea;
            font-size: 13px;
        }
        .um-head-actions .btn {
            border-radius: 10px;
            font-weight: 700;
        }
    </style>
</head>
<body>
    <div class="loader-bg">
        <div class="loader-track">
            <div class="loader-fill"></div>
        </div>
    </div>

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
                                                <h5 class="m-b-10">System Administration</h5>
                                            </div>
                                            <ul class="breadcrumb">
                                                <li class="breadcrumb-item"><a href="${pageContext.request.contextPath}/AdminDashboard"><i class="feather icon-home"></i></a></li>
                                                <li class="breadcrumb-item"><a href="#!">Administration</a></li>
                                                <li class="breadcrumb-item"><a href="UserManagement">User Management</a></li>
                                            </ul>
                                        </div>
                                    </div>
                                </div>
                            </div>

                            <div class="row">
                                <div class="col-sm-12">
                                    <div class="d-flex flex-wrap justify-content-between align-items-start mb-4">
                                        <div class="mb-3 mb-md-0">
                                            <h2 class="um-title">User Directory</h2>
                                            <p class="um-subtitle">Manage permissions, roles and account access across the organization.</p>
                                        </div>
                                        <div class="um-head-actions">
                                            <a href="UserCreate" class="btn btn-primary">Create User Account</a>
                                        </div>
                                    </div>

                                    <c:if test="${not empty flashMessage}">
                                        <div class="alert ${flashType eq 'success' ? 'alert-success' : 'alert-danger'}">
                                            ${flashMessage}
                                        </div>
                                    </c:if>

                                    <div class="card um-filter-card mb-3">
                                        <div class="card-body">
                                            <form action="UserManagement" method="get" class="row um-filters align-items-end">
                                                <input type="hidden" name="page" value="1">
                                                <div class="col-md-4 form-group">
                                                    <label>Search (username/email/full name)</label>
                                                    <input type="text" class="form-control" name="search" value="${search}">
                                                </div>
                                                <div class="col-md-3 form-group">
                                                    <label>Role</label>
                                                    <select class="form-control" name="role">
                                                        <option value="">All</option>
                                                        <c:forEach var="r" items="${roleOptions}">
                                                            <option value="${r}" ${selectedRole eq r ? 'selected' : ''}>${r}</option>
                                                        </c:forEach>
                                                    </select>
                                                </div>
                                                <div class="col-md-3 form-group">
                                                    <label>Status</label>
                                                    <select class="form-control" name="status">
                                                        <option value="all" ${selectedStatus eq 'all' ? 'selected' : ''}>All</option>
                                                        <option value="active" ${selectedStatus eq 'active' ? 'selected' : ''}>Active</option>
                                                        <option value="inactive" ${selectedStatus eq 'inactive' ? 'selected' : ''}>Inactive</option>
                                                    </select>
                                                </div>
                                                <div class="col-md-2 form-group d-flex align-items-end">
                                                    <div class="w-100">
                                                        <button type="submit" class="btn btn-primary btn-block mb-2">Filter</button>
                                                        <a href="UserManagement" class="btn btn-outline-secondary btn-block">Clear Filter</a>
                                                    </div>
                                                </div>
                                            </form>
                                        </div>
                                    </div>

                                    <div class="card um-table-card">
                                        <div class="card-body p-0">
                                            <div class="table-responsive">
                                                <table class="table um-user-table mb-0">
                                                    <thead>
                                                        <tr>
                                                            <th style="min-width: 240px;">User Info</th>
                                                            <th style="min-width: 220px;">Role</th>
                                                            <th style="min-width: 220px;">Status</th>
                                                            <th style="min-width: 180px;" class="text-right">Actions</th>
                                                        </tr>
                                                    </thead>
                                                    <tbody>
                                                        <c:choose>
                                                            <c:when test="${empty users}">
                                                                <tr>
                                                                    <td colspan="4" class="text-center text-muted">No users found.</td>
                                                                </tr>
                                                            </c:when>
                                                            <c:otherwise>
                                                                <c:forEach var="u" items="${users}">
                                                                    <tr>
                                                                        <td>
                                                                            <div class="um-user-name">${u.fullName}</div>
                                                                            <div class="um-user-meta">${u.email} &#8226; ${u.username}</div>
                                                                            <div class="um-user-meta">Created <fmt:formatDate value="${u.createdAt}" pattern="dd MMM, yyyy"/></div>
                                                                        </td>
                                                                        <td>
                                                                            <form action="UserManagement" method="post" class="mb-0">
                                                                                <input type="hidden" name="action" value="changeRole">
                                                                                <input type="hidden" name="id" value="${u.id}">
                                                                                <div class="form-group mb-2">
                                                                                    <select class="form-control form-control-sm um-role-select" name="role" required>
                                                                                        <c:forEach var="r" items="${roleOptions}">
                                                                                            <option value="${r}" ${u.role eq r ? 'selected' : ''}>${r}</option>
                                                                                        </c:forEach>
                                                                                    </select>
                                                                                </div>
                                                                                <button type="submit" class="btn btn-light btn-sm btn-block border">Update Role</button>
                                                                            </form>
                                                                        </td>
                                                                        <td>
                                                                            <div class="mb-2">
                                                                                <span class="um-status-pill ${u.active ? 'is-active' : 'is-inactive'}">
                                                                                    ${u.active ? 'Active' : 'Inactive'}
                                                                                </span>
                                                                            </div>
                                                                            <c:choose>
                                                                                <c:when test="${u.active}">
                                                                                    <form action="UserManagement" method="post" class="mb-2">
                                                                                        <input type="hidden" name="action" value="deactivate">
                                                                                        <input type="hidden" name="id" value="${u.id}">
                                                                                        <button type="submit" class="btn btn-outline-warning btn-sm btn-block">Deactivate</button>
                                                                                    </form>
                                                                                </c:when>
                                                                                <c:otherwise>
                                                                                    <form action="UserManagement" method="post" class="mb-2">
                                                                                        <input type="hidden" name="action" value="activate">
                                                                                        <input type="hidden" name="id" value="${u.id}">
                                                                                        <button type="submit" class="btn btn-outline-success btn-sm btn-block">Activate</button>
                                                                                    </form>
                                                                                </c:otherwise>
                                                                            </c:choose>
                                                                            <form action="UserManagement" method="post">
                                                                                <input type="hidden" name="action" value="resetPasswordEmail">
                                                                                <input type="hidden" name="id" value="${u.id}">
                                                                                <button type="submit" class="btn btn-outline-primary btn-sm btn-block">Reset Password</button>
                                                                            </form>
                                                                        </td>
                                                                        <td class="um-actions text-right">
                                                                            <button type="button"
                                                                                    class="btn btn-outline-secondary btn-sm"
                                                                                    data-toggle="modal"
                                                                                    data-target="#detailsModal${u.id}">
                                                                                Details
                                                                            </button>
                                                                            <button type="button"
                                                                                    class="btn btn-primary btn-sm"
                                                                                    data-toggle="modal"
                                                                                    data-target="#editInfoModal${u.id}">
                                                                                Edit
                                                                            </button>
                                                                        </td>
                                                                    </tr>
                                                                </c:forEach>
                                                            </c:otherwise>
                                                        </c:choose>
                                                    </tbody>
                                                </table>
                                            </div>
                                        </div>
                                        <div class="um-pagination-wrap d-flex flex-wrap justify-content-between align-items-center">
                                            <div class="um-pagination-text">
                                                Showing ${startItem} to ${endItem} of ${totalUsers} users
                                            </div>
                                            <c:if test="${totalUsers > 0}">
                                                <ul class="pagination pagination-sm mb-0 um-pagination">
                                                    <li class="page-item ${currentPage <= 1 ? 'disabled' : ''}">
                                                        <c:choose>
                                                            <c:when test="${currentPage <= 1}">
                                                                <a class="page-link" href="#">&lsaquo;</a>
                                                            </c:when>
                                                            <c:otherwise>
                                                                <c:url var="prevUrl" value="UserManagement">
                                                                    <c:param name="search" value="${search}" />
                                                                    <c:param name="role" value="${selectedRole}" />
                                                                    <c:param name="status" value="${selectedStatus}" />
                                                                    <c:param name="page" value="${currentPage - 1}" />
                                                                </c:url>
                                                                <a class="page-link" href="${prevUrl}">&lsaquo;</a>
                                                            </c:otherwise>
                                                        </c:choose>
                                                    </li>
                                                    <c:forEach begin="1" end="${totalPages}" var="i">
                                                        <li class="page-item ${i == currentPage ? 'active' : ''}">
                                                            <c:url var="pageUrl" value="UserManagement">
                                                                <c:param name="search" value="${search}" />
                                                                <c:param name="role" value="${selectedRole}" />
                                                                <c:param name="status" value="${selectedStatus}" />
                                                                <c:param name="page" value="${i}" />
                                                            </c:url>
                                                            <a class="page-link" href="${pageUrl}">${i}</a>
                                                        </li>
                                                    </c:forEach>
                                                    <li class="page-item ${currentPage >= totalPages ? 'disabled' : ''}">
                                                        <c:choose>
                                                            <c:when test="${currentPage >= totalPages}">
                                                                <a class="page-link" href="#">&rsaquo;</a>
                                                            </c:when>
                                                            <c:otherwise>
                                                                <c:url var="nextUrl" value="UserManagement">
                                                                    <c:param name="search" value="${search}" />
                                                                    <c:param name="role" value="${selectedRole}" />
                                                                    <c:param name="status" value="${selectedStatus}" />
                                                                    <c:param name="page" value="${currentPage + 1}" />
                                                                </c:url>
                                                                <a class="page-link" href="${nextUrl}">&rsaquo;</a>
                                                            </c:otherwise>
                                                        </c:choose>
                                                    </li>
                                                </ul>
                                            </c:if>
                                        </div>
                                    </div>

                                    <c:if test="${not empty users}">
                                        <c:forEach var="u" items="${users}">
                                            <div class="modal fade" id="detailsModal${u.id}" tabindex="-1" role="dialog" aria-labelledby="detailsModalLabel${u.id}" aria-hidden="true">
                                                <div class="modal-dialog modal-lg" role="document">
                                                    <div class="modal-content">
                                                        <div class="modal-header">
                                                            <h5 class="modal-title" id="detailsModalLabel${u.id}">User Details</h5>
                                                            <button type="button" class="close" data-dismiss="modal" aria-label="Close">
                                                                <span aria-hidden="true">&times;</span>
                                                            </button>
                                                        </div>
                                                        <div class="modal-body">
                                                            <table class="table table-sm table-bordered mb-0">
                                                                <tbody>
                                                                    <tr>
                                                                        <th style="width: 220px;">Full Name</th>
                                                                        <td>${u.fullName}</td>
                                                                    </tr>
                                                                    <tr>
                                                                        <th>Username</th>
                                                                        <td>${u.username}</td>
                                                                    </tr>
                                                                    <tr>
                                                                        <th>Email</th>
                                                                        <td>${u.email}</td>
                                                                    </tr>
                                                                    <tr>
                                                                        <th>Role</th>
                                                                        <td>${u.role}</td>
                                                                    </tr>
                                                                    <tr>
                                                                        <th>Department</th>
                                                                        <td>${empty u.departmentName ? 'N/A' : u.departmentName}</td>
                                                                    </tr>
                                                                    <tr>
                                                                        <th>Location</th>
                                                                        <td>${empty u.locationName ? 'N/A' : u.locationName}</td>
                                                                    </tr>
                                                                    <tr>
                                                                        <th>Status</th>
                                                                        <td>${u.active ? 'Active' : 'Inactive'}</td>
                                                                    </tr>
                                                                    <tr>
                                                                        <th>Created At</th>
                                                                        <td>
                                                                            <fmt:formatDate value="${u.createdAt}" pattern="dd/MM/yyyy HH:mm"/>
                                                                        </td>
                                                                    </tr>
                                                                </tbody>
                                                            </table>
                                                        </div>
                                                        <div class="modal-footer">
                                                            <button type="button" class="btn btn-secondary" data-dismiss="modal">Close</button>
                                                        </div>
                                                    </div>
                                                </div>
                                            </div>

                                            <div class="modal fade" id="editInfoModal${u.id}" tabindex="-1" role="dialog" aria-labelledby="editInfoModalLabel${u.id}" aria-hidden="true">
                                                <div class="modal-dialog" role="document">
                                                    <div class="modal-content">
                                                        <form action="UserManagement" method="post">
                                                            <input type="hidden" name="action" value="updateInfo">
                                                            <input type="hidden" name="id" value="${u.id}">
                                                            <div class="modal-header">
                                                                <h5 class="modal-title" id="editInfoModalLabel${u.id}">Edit User Information</h5>
                                                                <button type="button" class="close" data-dismiss="modal" aria-label="Close">
                                                                    <span aria-hidden="true">&times;</span>
                                                                </button>
                                                            </div>
                                                            <div class="modal-body">
                                                                <div class="form-group">
                                                                    <label>Full Name</label>
                                                                    <input class="form-control" type="text" name="fullName" value="${u.fullName}">
                                                                </div>
                                                                <div class="form-group">
                                                                    <label>Email</label>
                                                                    <input class="form-control" type="email" name="email" value="${u.email}" required>
                                                                </div>
                                                                <div class="form-group">
                                                                    <label>Department</label>
                                                                    <select class="form-control" name="departmentId">
                                                                        <option value="">Select Department</option>
                                                                        <c:forEach var="dep" items="${departmentOptions}">
                                                                            <option value="${dep.key}" ${u.departmentId == dep.key ? 'selected' : ''}>${dep.value}</option>
                                                                        </c:forEach>
                                                                    </select>
                                                                </div>
                                                                <div class="form-group mb-0">
                                                                    <label>Location</label>
                                                                    <select class="form-control" name="locationId">
                                                                        <option value="">Select Location</option>
                                                                        <c:forEach var="loc" items="${locationOptions}">
                                                                            <option value="${loc.key}" ${u.locationId == loc.key ? 'selected' : ''}>${loc.value}</option>
                                                                        </c:forEach>
                                                                    </select>
                                                                </div>
                                                            </div>
                                                            <div class="modal-footer">
                                                                <button type="button" class="btn btn-secondary" data-dismiss="modal">Cancel</button>
                                                                <button type="submit" class="btn btn-success">Save Info</button>
                                                            </div>
                                                        </form>
                                                    </div>
                                                </div>
                                            </div>
                                        </c:forEach>
                                    </c:if>
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
    <script>
        $(document).ready(function () {
            $('.fixed-button').remove();
        });
    </script>
</body>
</html>
