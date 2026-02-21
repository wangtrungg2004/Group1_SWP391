<%@ page contentType="text/html;charset=UTF-8" language="java" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<%@ page import="dao.NotificationDao" %>
<%@ page import="model.Notifications" %>
<%@ page import="java.util.List" %>

<%
    if (session.getAttribute("user") == null) {
        response.sendRedirect("Login.jsp");
        return;
    }
    
    String role = (String) session.getAttribute("role");
    model.Users user = (model.Users) session.getAttribute("user");
    
    List<Notifications> notifications = new java.util.ArrayList<>();
    NotificationDao notificationDao = new NotificationDao();
    notifications = notificationDao.getAllNotifications();
    request.setAttribute("notifications", notifications);
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0, user-scalable=0, minimal-ui">
    <meta http-equiv="X-UA-Compatible" content="IE=edge" />

    <title>Service Catalog Management</title>

    <!-- fontawesome icon -->
    <link rel="stylesheet" href="assets/fonts/fontawesome/css/fontawesome-all.min.css">
    <!-- animation css -->
    <link rel="stylesheet" href="assets/plugins/animation/css/animate.min.css">
    <!-- vendor css -->
    <link rel="stylesheet" href="assets/css/style.css">

    <!-- Bootstrap 5 CSS (for your ServiceCatalog table/form) -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    
    <style>
        .table th, .table td { vertical-align: middle; }
        .form-label { font-weight: 500; }
        .alert-dismissible { margin-bottom: 1.5rem; }
        .action-btn { min-width: 90px; }
        /* Optional: make Bootstrap cards blend better with pcoded style */
        .card { border: none; box-shadow: 0 0 20px 0 rgba(0,0,0,0.08); }
    </style>
</head>

<body class="">
    <!-- [ Pre-loader ] start -->
    <div class="loader-bg">
        <div class="loader-track">
            <div class="loader-fill"></div>
        </div>
    </div>
    <!-- [ Pre-loader ] End -->

    <!-- [ navigation menu ] start -->
    <nav class="pcoded-navbar menupos-fixed menu-light brand-blue">
        <div class="navbar-wrapper">
            <div class="navbar-brand header-logo">
                <a href="AdminDashboard.jsp" class="b-brand">
                    <!-- Logo here if needed -->
                </a>
                <a class="mobile-menu" id="mobile-collapse" href="#!"><span></span></a>
            </div>
            <div class="navbar-content scroll-div">
                <ul class="nav pcoded-inner-navbar">
                    <li class="nav-item pcoded-menu-caption">
                        <label>Navigation</label>
                    </li>
                    <li class="nav-item">
                        <a href="AdminDashboard.jsp" class="nav-link">
                            <span class="pcoded-micon"><i class="feather icon-home"></i></span>
                            <span class="pcoded-mtext">Dashboard</span>
                        </a>
                    </li>

                    <li class="nav-item pcoded-menu-caption">
                        <label>Forms & Table</label>
                    </li>
                    <li class="nav-item">
                        <a href="ProblemList" class="nav-link">
                            <span class="pcoded-micon"><i class="feather icon-file-text"></i></span>
                            <span class="pcoded-mtext">Problem List</span>
                        </a>
                    </li>
                    <li class="nav-item active">
                        <a href="ServiceCatalog?action=list" class="nav-link">
                            <span class="pcoded-micon"><i class="feather icon-grid"></i></span>
                            <span class="pcoded-mtext">Service Catalog</span>
                        </a>
                    </li>
                    <li class="nav-item">
                        <a href="tbl_bootstrap.html" class="nav-link">
                            <span class="pcoded-micon"><i class="feather icon-align-justify"></i></span>
                            <span class="pcoded-mtext">Bootstrap table</span>
                        </a>
                    </li>

                    <!-- Keep your other menu items (role-based) as in AdminDashboard -->
                    <c:if test="${role == 'Admin'}">
                        <li class="nav-item pcoded-menu-caption">
                            <label>System Management</label>
                        </li>
                        <li class="nav-item">
                            <a href="UserManagement" class="nav-link">
                                <span class="pcoded-micon"><i class="feather icon-users"></i></span>
                                <span class="pcoded-mtext">User Management</span>
                            </a>
                        </li>
                        <!-- ... other admin menus ... -->
                    </c:if>

                    <!-- Add other role-based menus similarly -->

                </ul>
            </div>
        </div>
    </nav>
    <!-- [ navigation menu ] end -->

    <!-- [ Header ] start -->
    <header class="navbar pcoded-header navbar-expand-lg navbar-light headerpos-fixed">
        <div class="m-header">
            <a class="mobile-menu" id="mobile-collapse1" href="#!"><span></span></a>
            <a href="AdminDashboard.jsp" class="b-brand">
                <!-- Logo -->
            </a>
        </div>
        <a class="mobile-menu" id="mobile-header" href="#!">
            <i class="feather icon-more-horizontal"></i>
        </a>
        <div class="collapse navbar-collapse">
            <a href="#!" class="mob-toggler"></a>
            <ul class="navbar-nav mr-auto">
                <li class="nav-item">
                    <div class="main-search open">
                        <div class="input-group">
                            <input type="text" id="m-search" class="form-control" placeholder="Search . . .">
                            <a href="#!" class="input-group-append search-close">
                                <i class="feather icon-x input-group-text"></i>
                            </a>
                            <span class="input-group-append search-btn btn btn-primary">
                                <i class="feather icon-search input-group-text"></i>
                            </span>
                        </div>
                    </div>
                </li>
            </ul>
            <ul class="navbar-nav ml-auto">
                <li>
                    <div class="dropdown">
                        <a class="dropdown-toggle" href="#" data-toggle="dropdown">
                            <i class="icon feather icon-bell"></i>
                        </a>
                        <div class="dropdown-menu dropdown-menu-right notification">
                            <div class="noti-head">
                                <h6 class="d-inline-block m-b-0">Notifications</h6>
                                <div class="float-right">
                                    <a href="#!" class="m-r-10">mark as read</a>
                                    <a href="#!">clear all</a>
                                </div>
                            </div>
                            <ul class="noti-body">
                                <c:choose>
                                    <c:when test="${empty notifications}">
                                        <li class="notification"><p class="text-muted m-2">No notifications</p></li>
                                    </c:when>
                                    <c:otherwise>
                                        <c:forEach items="${notifications}" var="notification">
                                            <li class="notification">
                                                <div class="media">
                                                    <img class="img-radius" src="assets/images/user/avatar-1.jpg" alt="">
                                                    <div class="media-body">
                                                        <p>
                                                            <span class="n-time text-muted">
                                                                <i class="icon feather icon-clock m-r-10"></i>
                                                                <fmt:formatDate value="${notification.createdAt}" pattern="dd/MM/yyyy HH:mm"/>
                                                            </span>
                                                        </p>
                                                        <p><c:out value="${notification.message}"/></p>
                                                    </div>
                                                </div>
                                            </li>
                                        </c:forEach>
                                    </c:otherwise>
                                </c:choose>
                            </ul>
                            <div class="noti-footer">
                                <a href="#!">show all</a>
                            </div>
                        </div>
                    </div>
                </li>
                <li>
                    <div class="dropdown drp-user">
                        <a href="#" class="dropdown-toggle" data-toggle="dropdown">
                            <i class="icon feather icon-settings"></i>
                        </a>
                        <div class="dropdown-menu dropdown-menu-right profile-notification">
                            <div class="pro-head">
                                <img src="assets/images/user/avatar-1.jpg" class="img-radius" alt="User-Profile-Image">
                                <span><%= user != null ? user.getFullName() : "User" %></span>
                                <span style="display: block; font-size: 11px; color: #999;"><%= role != null ? role : "" %></span>
                                <a href="Logout" class="dud-logout" title="Logout">
                                    <i class="feather icon-log-out"></i>
                                </a>
                            </div>
                            <ul class="pro-body">
                                <li><a href="#!" class="dropdown-item"><i class="feather icon-settings"></i> Settings</a></li>
                                <li><a href="#!" class="dropdown-item"><i class="feather icon-user"></i> Profile</a></li>
                                <li><a href="message.html" class="dropdown-item"><i class="feather icon-mail"></i> My Messages</a></li>
                                <li><a href="Logout" class="dropdown-item"><i class="feather icon-log-out"></i> Logout</a></li>
                            </ul>
                        </div>
                    </div>
                </li>
            </ul>
        </div>
    </header>
    <!-- [ Header ] end -->

    <!-- [ Main Content ] start -->
    <div class="pcoded-main-container">
        <div class="pcoded-wrapper">
            <div class="pcoded-content">
                <div class="pcoded-inner-content">
                    <div class="main-body">
                        <div class="page-wrapper">

                            <!-- [ breadcrumb ] start -->
                            <div class="page-header">
                                <div class="page-block">
                                    <div class="row align-items-center">
                                        <div class="col-md-12">
                                            <div class="page-header-title">
                                                <h5>Service Catalog</h5>
                                            </div>
                                            <ul class="breadcrumb">
                                                <li class="breadcrumb-item"><a href="AdminDashboard.jsp"><i class="feather icon-home"></i></a></li>
                                                <li class="breadcrumb-item"><a href="#!">Management</a></li>
                                                <li class="breadcrumb-item"><a href="ServiceCatalog?action=list">Service Catalog</a></li>
                                            </ul>
                                        </div>
                                    </div>
                                </div>
                            </div>
                            <!-- [ breadcrumb ] end -->

                            <!-- [ Main Content - ServiceCatalog ] start -->
                            <div class="row">
                                <div class="col-sm-12">

                                    <div class="d-flex justify-content-between align-items-center mb-4">
                                        <h3 class="mb-0">Service Catalog Management</h3>
                                        <a href="ServiceCatalog?action=add" class="btn btn-primary">+ Add New Service</a>
                                    </div>

                                    <%-- Success messages --%>
                                    <c:if test="${not empty param.msg}">
                                        <div class="alert alert-success alert-dismissible fade show" role="alert">
                                            <c:choose>
                                                <c:when test="${param.msg == 'added'}">Service added successfully!</c:when>
                                                <c:when test="${param.msg == 'updated'}">Service updated successfully!</c:when>
                                                <c:when test="${param.msg == 'deleted'}">Service deleted successfully!</c:when>
                                                <c:otherwise>${param.msg}</c:otherwise>
                                            </c:choose>
                                            <button type="button" class="close" data-dismiss="alert" aria-label="Close">
                                                <span aria-hidden="true">&times;</span>
                                            </button>
                                        </div>
                                    </c:if>

                                    <%-- Error messages --%>
                                    <c:if test="${not empty requestScope.error}">
                                        <div class="alert alert-danger alert-dismissible fade show" role="alert">
                                            ${requestScope.error}
                                            <button type="button" class="close" data-dismiss="alert" aria-label="Close">
                                                <span aria-hidden="true">&times;</span>
                                            </button>
                                        </div>
                                    </c:if>

                                    <%-- ADD / EDIT FORM --%>
                                    <c:if test="${not empty requestScope.service || param.action == 'add'}">
                                        <div class="card">
                                            <div class="card-header">
                                                <h5>
                                                    <c:choose>
                                                        <c:when test="${not empty requestScope.service}">Edit Service</c:when>
                                                        <c:otherwise>Add New Service</c:otherwise>
                                                    </c:choose>
                                                </h5>
                                            </div>
                                            <div class="card-body">
                                                <form action="ServiceCatalog" method="post" class="row g-3">
                                                    <input type="hidden" name="action" value="${not empty requestScope.service ? 'edit' : 'add'}">
                                                    <c:if test="${not empty requestScope.service}">
                                                        <input type="hidden" name="id" value="${requestScope.service.id}">
                                                    </c:if>

                                                    <div class="col-md-6">
                                                        <label for="name" class="form-label">Service Name <span class="text-danger">*</span></label>
                                                        <input type="text" class="form-control" id="name" name="name" required value="${requestScope.service.name}">
                                                    </div>

                                                    <div class="col-md-3">
                                                        <label for="categoryId" class="form-label">Category</label>
                                                        <input type="number" class="form-control" id="categoryId" name="categoryId" required
                                                               value="${requestScope.service != null ? requestScope.service.categoryId : '1'}">
                                                        <small class="form-text text-muted">Enter category ID (temporary)</small>
                                                    </div>

                                                    <div class="col-md-3">
                                                        <label for="estimatedDeliveryDays" class="form-label">Estimated Delivery (days)</label>
                                                        <input type="number" class="form-control" id="estimatedDeliveryDays" name="estimatedDeliveryDays"
                                                               min="1" required value="${requestScope.service.estimatedDeliveryDays}">
                                                    </div>

                                                    <div class="col-12">
                                                        <label for="description" class="form-label">Description</label>
                                                        <textarea class="form-control" id="description" name="description" rows="3">${requestScope.service.description}</textarea>
                                                    </div>

                                                    <div class="col-md-4">
                                                        <div class="form-check form-switch mt-4">
                                                            <input class="form-check-input" type="checkbox" id="requiresApproval" name="requiresApproval"
                                                                   ${requestScope.service.requiresApproval ? 'checked' : ''}>
                                                            <label class="form-check-label" for="requiresApproval">Requires Approval</label>
                                                        </div>
                                                    </div>

                                                    <div class="col-md-4">
                                                        <div class="form-check form-switch mt-4">
                                                            <input class="form-check-input" type="checkbox" id="isActive" name="isActive"
                                                                   ${requestScope.service == null || requestScope.service.isActive ? 'checked' : ''}>
                                                            <label class="form-check-label" for="isActive">Active</label>
                                                        </div>
                                                    </div>

                                                    <div class="col-12 mt-4">
                                                        <button type="submit" class="btn btn-success px-4">
                                                            <c:choose>
                                                                <c:when test="${not empty requestScope.service}">Update</c:when>
                                                                <c:otherwise>Add</c:otherwise>
                                                            </c:choose>
                                                        </button>
                                                        <a href="ServiceCatalog?action=list" class="btn btn-secondary">Cancel</a>
                                                    </div>
                                                </form>
                                            </div>
                                        </div>
                                    </c:if>

                                    <%-- SERVICE LIST --%>
                                    <c:if test="${empty requestScope.service && param.action != 'add'}">
                                        <div class="card">
                                            <div class="card-header">
                                                <h5>All Services</h5>
                                            </div>
                                            <div class="card-body p-0">
                                                <div class="table-responsive">
                                                    <table class="table table-hover table-bordered mb-0">
                                                        <thead class="thead-dark">
                                                        <tr>
                                                            <th>ID</th>
                                                            <th>Service Name</th>
                                                            <th>Description</th>
                                                            <th>Category</th>
                                                            <th>Approval</th>
                                                            <th>Est. Days</th>
                                                            <th>Status</th>
                                                            <th class="text-center">Actions</th>
                                                        </tr>
                                                        </thead>
                                                        <tbody>
                                                        <c:forEach var="svc" items="${requestScope.services}">
                                                            <tr>
                                                                <td>${svc.id}</td>
                                                                <td>${svc.name}</td>
                                                                <td>${svc.description}</td>
                                                                <td>${svc.categoryId}</td>
                                                                <td>
                                                                    <span class="badge ${svc.requiresApproval ? 'badge-warning' : 'badge-secondary'}">
                                                                        ${svc.requiresApproval ? 'Yes' : 'No'}
                                                                    </span>
                                                                </td>
                                                                <td>${svc.estimatedDeliveryDays}</td>
                                                                <td>
                                                                    <span class="badge ${svc.isActive ? 'badge-success' : 'badge-danger'}">
                                                                        ${svc.isActive ? 'Active' : 'Inactive'}
                                                                    </span>
                                                                </td>
                                                                <td class="text-center">
                                                                    <a href="ServiceCatalog?action=edit&id=${svc.id}" class="btn btn-sm btn-outline-primary action-btn">Edit</a>

                                                                    <c:choose>
                                                                        <c:when test="${svc.isActive}">
                                                                            <a href="ServiceCatalog?action=toggle&id=${svc.id}&isActive=true"
                                                                               class="btn btn-sm btn-outline-warning action-btn"
                                                                               onclick="return confirm('Hide this service?')">Hide</a>
                                                                        </c:when>
                                                                        <c:otherwise>
                                                                            <a href="ServiceCatalog?action=toggle&id=${svc.id}&isActive=false"
                                                                               class="btn btn-sm btn-outline-success action-btn"
                                                                               onclick="return confirm('Show this service?')">Show</a>
                                                                        </c:otherwise>
                                                                    </c:choose>

                                                                    <a href="ServiceCatalog?action=delete&id=${svc.id}"
                                                                       class="btn btn-sm btn-outline-danger action-btn"
                                                                       onclick="return confirm('DELETE this service? This cannot be undone!')">Delete</a>
                                                                </td>
                                                            </tr>
                                                        </c:forEach>

                                                        <c:if test="${empty requestScope.services}">
                                                            <tr>
                                                                <td colspan="8" class="text-center text-muted py-4">
                                                                    No services found. Please add a new service.
                                                                </td>
                                                            </tr>
                                                        </c:if>
                                                        </tbody>
                                                    </table>
                                                </div>
                                            </div>
                                        </div>
                                    </c:if>

                                </div>
                            </div>
                            <!-- [ Main Content - ServiceCatalog ] end -->

                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
    <!-- [ Main Content ] end -->

    <!-- Required Js -->
    <script src="assets/plugins/jquery/js/jquery.min.js"></script>
    <script src="assets/js/vendor-all.min.js"></script>
    <script src="assets/plugins/bootstrap/js/bootstrap.min.js"></script>
    <script src="assets/js/pcoded.min.js"></script>

    <!-- Bootstrap 5 JS (for alerts, etc.) -->
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>

    <script>
        $(document).ready(function () {
            $('.fixed-button').remove();
            // Optional: activate tooltips if needed
            $('[data-toggle="tooltip"]').tooltip();
        });
    </script>
</body>
</html>