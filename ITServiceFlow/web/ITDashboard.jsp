<%-- 
    Document   : ITDashboard
    Created on : Jan 17, 2026
    Author     : DELL
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<%@ page import="java.util.List" %>
<%@ page import="model.Notifications" %>
<%@ page import="dao.NotificationDao" %>
<%
    // 1. Kiểm tra đăng nhập
    if (session.getAttribute("user") == null) {
        response.sendRedirect("Login.jsp");
        return;
    }

    // 2. Lấy thông tin từ session
    model.Users user = (model.Users) session.getAttribute("user");
    Integer userId = (Integer) session.getAttribute("userId");
    String role = (String) session.getAttribute("role");

    // 3. Kiểm tra quyền truy cập (chỉ IT Support được vào)
    if (role == null || !role.equals("IT Support")) {
        response.sendRedirect("Login.jsp");
        return;
    }
%>

<!DOCTYPE html>
<html lang="en">

<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0, user-scalable=0, minimal-ui">
    <meta http-equiv="X-UA-Compatible" content="IE=edge" />
    <meta name="description" content="IT Support Dashboard" />
    <meta name="author" content="ITServiceFlow" />

    <!-- fontawesome icon -->
    <link rel="stylesheet" href="assets/fonts/fontawesome/css/fontawesome-all.min.css">
    <!-- animation css -->
    <link rel="stylesheet" href="assets/plugins/animation/css/animate.min.css">
    
    <!-- Bootstrap CSS -->
    <link rel="stylesheet" href="assets/plugins/bootstrap/css/bootstrap.min.css">

    <!-- vendor css -->
    <link rel="stylesheet" href="assets/css/style.css">
    
    <title>IT Support Dashboard - ITServiceFlow</title>
</head>

<body class="">
    <!-- [ Pre-loader ] start -->
    <div class="loader-bg">
        <div class="loader-track">
            <div class="loader-fill"></div>
        </div>
    </div>
    <!-- [ Pre-loader ] End -->
    <jsp:include page="includes/sidebar.jsp"/>
    <jsp:include page="includes/header.jsp"/>
    <!-- [ navigation menu ] start -->
    <!-- [ Main Content ] start -->
    <div class="pcoded-main-container">
        <div class="pcoded-wrapper">
            <div class="pcoded-content">
                <div class="pcoded-inner-content">
                    <!-- [ breadcrumb ] start -->
                    <div class="page-header">
                        <div class="page-block">
                            <div class="row align-items-center">
                                <div class="col-md-12">
                                    <div class="page-header-title">
                                        <h5 class="m-b-10">IT Support Dashboard</h5>
                                    </div>
                                    <ul class="breadcrumb">
                                        <li class="breadcrumb-item"><a href="${pageContext.request.contextPath}/ITDashboard"><i class="feather icon-home"></i></a></li>
                                        <li class="breadcrumb-item"><a href="#!">Dashboard</a></li>
                                    </ul>
                                </div>
                            </div>
                        </div>
                    </div>
                    <!-- [ breadcrumb ] end -->

                    <div class="main-body">
                        <div class="page-wrapper">
                            <!-- [ Main Content ] start -->
                            <div class="row">
                                <!-- [ Statistics ] start -->
                                <div class="col-md-6 col-xl-3">
                                    <div class="card">
                                        <div class="card-body">
                                            <h6 class="mb-4">Tickets mới</h6>
                                            <div class="row d-flex align-items-center">
                                                <div class="col-9">
                                                    <h3 class="f-w-300 d-flex align-items-center m-b-0">
                                                        <i class="feather icon-file-plus text-c-green f-30 m-r-10"></i>
                                                        ${agentKPIs.myNew}
                                                    </h3>
                                                </div>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                                <div class="col-md-6 col-xl-3">
                                    <div class="card">
                                        <div class="card-body">
                                            <h6 class="mb-4">Tickets đang xử lý</h6>
                                            <div class="row d-flex align-items-center">
                                                <div class="col-9">
                                                    <h3 class="f-w-300 d-flex align-items-center m-b-0">
                                                        <i class="feather icon-clock text-c-yellow f-30 m-r-10"></i>
                                                        ${agentKPIs.myInProgress}
                                                    </h3>
                                                </div>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                                <div class="col-md-6 col-xl-3">
                                    <div class="card">
                                        <div class="card-body">
                                            <h6 class="mb-4">Đã giải quyết (7 ngày)</h6>
                                            <div class="row d-flex align-items-center">
                                                <div class="col-9">
                                                    <h3 class="f-w-300 d-flex align-items-center m-b-0">
                                                        <i class="feather icon-check-circle text-c-blue f-30 m-r-10"></i>
                                                        ${agentKPIs.myResolved}
                                                    </h3>
                                                </div>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                                <div class="col-md-6 col-xl-3">
                                    <div class="card ${agentKPIs.slaBreaching > 0 ? 'border-danger' : ''}">
                                        <div class="card-body">
                                            <h6 class="mb-4">Sắp breach SLA</h6>
                                            <div class="row d-flex align-items-center">
                                                <div class="col-9">
                                                    <h3 class="f-w-300 d-flex align-items-center m-b-0">
                                                        <i class="feather icon-alert-triangle ${agentKPIs.slaBreaching > 0 ? 'text-danger' : 'text-c-purple'} f-30 m-r-10"></i>
                                                        <span class="${agentKPIs.slaBreaching > 0 ? 'text-danger' : ''}">${agentKPIs.slaBreaching}</span>
                                                    </h3>
                                                </div>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                                <!-- [ Statistics ] end -->
                            </div>

                            <div class="row mt-3">
                                <%-- Tickets gần nhất --%>
                                <div class="col-xl-8">
                                    <div class="card">
                                        <div class="card-header d-flex justify-content-between align-items-center">
                                            <h5 class="mb-0">Tickets đang xử lý</h5>
                                            <a href="${pageContext.request.contextPath}/Queues"
                                               class="btn btn-sm btn-outline-primary">Xem tất cả</a>
                                        </div>
                                        <div class="card-body p-0">
                                            <c:choose>
                                                <c:when test="${not empty recentTickets}">
                                                    <div class="table-responsive">
                                                        <table class="table table-sm table-hover mb-0">
                                                            <thead class="thead-light">
                                                                <tr>
                                                                    <th class="pl-3">Ticket</th>
                                                                    <th>Tiêu đề</th>
                                                                    <th>Loại</th>
                                                                    <th>Trạng thái</th>
                                                                </tr>
                                                            </thead>
                                                            <tbody>
                                                                <c:forEach var="t" items="${recentTickets}">
                                                                    <tr>
                                                                        <td class="pl-3">
                                                                            <a href="${pageContext.request.contextPath}/TicketAgentDetail?id=${t.id}"
                                                                               style="font-weight:600; color:#0052cc; font-size:0.83rem;">
                                                                                ${t.ticketNumber}
                                                                            </a>
                                                                        </td>
                                                                        <td style="font-size:0.85rem; max-width:200px;
                                                                                   overflow:hidden; text-overflow:ellipsis; white-space:nowrap;">
                                                                            ${t.title}
                                                                        </td>
                                                                        <td>
                                                                            <span class="badge ${t.ticketType eq 'Incident' ? 'badge-danger' : 'badge-primary'}"
                                                                                  style="font-size:0.72rem;">
                                                                                ${t.ticketType}
                                                                            </span>
                                                                        </td>
                                                                        <td>
                                                                            <span class="badge ${t.status eq 'New' ? 'badge-warning' : 'badge-info'}"
                                                                                  style="font-size:0.72rem;">
                                                                                ${t.status}
                                                                            </span>
                                                                        </td>
                                                                    </tr>
                                                                </c:forEach>
                                                            </tbody>
                                                        </table>
                                                    </div>
                                                </c:when>
                                                <c:otherwise>
                                                    <div class="text-center py-4 text-muted">
                                                        <i class="feather icon-check-circle" style="font-size:2rem; opacity:0.3;"></i>
                                                        <p class="mt-2 mb-0" style="font-size:0.85rem;">Không có ticket nào đang xử lý</p>
                                                    </div>
                                                </c:otherwise>
                                            </c:choose>
                                        </div>
                                    </div>
                                </div>

                                <%-- Quick links --%>
                                <div class="col-xl-4">
                                    <div class="card">
                                        <div class="card-header">
                                            <h5 class="mb-0">Chào mừng, <%= user != null ? user.getFullName() : "IT Support" %>!</h5>
                                        </div>
                                        <div class="card-body">
                                            <a href="${pageContext.request.contextPath}/Queues"
                                               class="btn btn-primary btn-block mb-2">
                                                <i class="feather icon-list mr-2"></i>
                                                Ticket Queue (${agentKPIs.myTotal} đang mở)
                                            </a>
                                            <a href="${pageContext.request.contextPath}/ITProblemListController"
                                               class="btn btn-outline-danger btn-block mb-2">
                                                <i class="feather icon-alert-circle mr-2"></i>
                                                My Problems (${myProblems})
                                            </a>
                                            <a href="${pageContext.request.contextPath}/SubmitChangeRequest"
                                               class="btn btn-outline-secondary btn-block">
                                                <i class="feather icon-edit mr-2"></i>
                                                Submit Change Request
                                            </a>
                                        </div>
                                    </div>
                                </div>
                            </div>
                            <!-- [ Main Content ] end -->
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
    <script>
        $(document).ready(function () {
            $('.fixed-button').remove();
        });
    </script>
</body>

</html>
