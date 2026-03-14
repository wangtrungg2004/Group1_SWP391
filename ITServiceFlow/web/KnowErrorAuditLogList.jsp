<%-- 
    Document   : ITDashboard
    Created on : Jan 17, 2026
    Author     : DELL
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<%@ taglib uri="jakarta.tags.fmt" prefix="fmt" %>

<%@ page import="java.util.List" %>
<%@ page import="model.Notifications" %>
<%@ page import="dao.NotificationDao" %>
<%
        if (session != null && session.getAttribute("userId") != null 
                && request.getAttribute("headerNotifications") == null) 
        {
            Integer userId = (Integer) session.getAttribute("userId");
            String role = (String) session.getAttribute("role");
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
    
    <title>Manager Dashboard - ITServiceFlow</title>
    
            <style>
    /* === FORCE FULL WIDTH – KILL BOXED LAYOUT === */

    /* ông nội */
    .pcoded-wrapper {
        max-width: 100% !important;
        width: 100% !important;
        margin: 0 !important;
    }

    /* cha */
    .pcoded-main-container {
        width: 100% !important;
        margin-left: 264px !important;
    }

    /* khi sidebar collapse */
    .pcoded-navbar.navbar-collapsed ~ .pcoded-main-container {
        margin-left: 80px !important;
    }

    /* con cháu */
    .pcoded-content,
    .pcoded-inner-content,
    .main-body,
    .page-wrapper {
        max-width: 100% !important;
        width: 100% !important;
    }

    /* tránh scroll ngang ảo */
    body {
        overflow-x: hidden;
    }
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
    <jsp:include page="includes/sidebar.jsp"/>
    <jsp:include page="includes/header.jsp"/>
    <!-- [ navigation menu ] start -->
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
                                                <h5 class="m-b-10">Form Elements</h5>
                                            </div>
                                            <ul class="breadcrumb">
                                                <li class="breadcrumb-item"><a href="index.html"><i class="feather icon-home"></i></a></li>
                                                <li class="breadcrumb-item"><a href="KnowErrorDetail?Id=${knowerror.id}">Activity List</a></li>
                                                <li class="breadcrumb-item"><a href="#!">Activity List</a></li>
                                            </ul>
                                        </div>
                                    </div>
                                </div>
                            </div>
                            <!-- [ breadcrumb ] end -->
                            <!-- [ Main Content ] start -->
                            <div class="row">
                                <!-- [ form-element ] start -->
                                <div class="col-sm-12">
                                    <div class="card">
                                        <div class="card-header d-flex justify-content-between align-items-center">
                                            <h5 class="m-0">KnowError Activity History</h5>
                                        </div>

                                        <div class="card-body table-border-style">

                                            <c:if test="${empty auditLogs}">
                                                <div class="alert alert-warning">
                                                    No activity history found for this KnowError
                                                </div>
                                            </c:if>

                                            <div class="table-responsive">
                                                <table class="table table-hover">
                                                    <thead class="thead-dark">
                                                        <tr>
                                                            <th>ID</th>
                                                            <th>User</th>
                                                            <th>Action</th>
                                                            <th>Entity</th>
                                                            <th>Entity ID</th>
                                                            <th>Created At</th>
                                                        </tr>
                                                    </thead>

                                                    <tbody>
                                                        <c:choose>

                                                            <c:when test="${empty auditLogs}">
                                                                <tr>
                                                                    <td colspan="6" class="text-center text-muted">
                                                                        <i>No activity logs found</i>
                                                                    </td>
                                                                </tr>
                                                            </c:when>

                                                            <c:otherwise>

                                                                <c:forEach items="${auditLogs}" var="a">
                                                                    <tr>
                                                                        <td>${a.id}</td>

                                                                        <td>
                                                                            <c:choose>
                                                                                <c:when test="${not empty a.userName}">
                                                                                    ${a.userName}
                                                                                </c:when>
                                                                                <c:otherwise>
                                                                                    User #${a.userId}
                                                                                </c:otherwise>
                                                                            </c:choose>
                                                                        </td>

                                                                        <td>
                                                                            <span class="badge badge-info">
                                                                                ${a.action}
                                                                            </span>
                                                                        </td>

                                                                        <td>${a.entity}</td>

                                                                        <td>${a.entityId}</td>

                                                                        <td>
                                                                            <fmt:formatDate value="${a.createdAt}" pattern="yyyy-MM-dd HH:mm"/>
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
                                    <!-- Input group -->
                                </div>
                                <!-- [ form-element ] end -->
                                <!-- [ Main Content ] end -->
                            </div>
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

