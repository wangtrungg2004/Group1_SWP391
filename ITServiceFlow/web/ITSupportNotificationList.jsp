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
    
    <title>IT Support Dashboard - ITServiceFlow</title>
    
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
                                                <li class="breadcrumb-item"><a href="ITSupportNotificationList">Notification List</a></li>
                                                <li class="breadcrumb-item"><a href="#!">Notification List</a></li>
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
                                            <h5 class="m-0">Notification List</h5>
                                        </div>
                                        <div class="card-body table-border-style">
                                        <c:if test="${empty notifications}">
                                            <div class="alert alert-warning">
                                             Notification list is empty
                                            </div>
                                        </c:if>
                                            <form action="ITProblemListController" method="get" class="mb-3">
                                                <div class="input-group">
                                                    <input type="text" name="keyword" class="form-control" placeholder="Search by Title or Ticket Number..."
                                                           value="${keyword != null ? keyword : ''}">
                                                    <div class="input-group-append">
                                                        <button type="submit" class="btn btn-primary">Search</button>
                                                    </div>
                                                </div>
                                            </form>
                                        <div class="table-responsive">
                                            <table class="table table-hover">
                                                <thead class="thead-dark">
                                                    <tr>
                                                        <th>ID</th>
                                                        <th>Title</th>
                                                        <th>Type</th>
                                                        <th>Message</th>
                                                        <th>Created At</th>
                                                        <th>Is Read</th>
                                                        <th>Action</th>
                                                    </tr>
                                                </thead>
                                                <tbody>
                                                    <c:choose>
                                                        <c:when test="${empty notifications}">
                                                            <tr>
                                                                <td colspan="6" class="text-center text-muted">
                                                                    <i>No notifications found</i>
                                                                </td>
                                                            </tr>
                                                        </c:when>
                                                        <c:otherwise>
                                                            <c:forEach items="${notifications}" var="n">
                                                                <tr>
                                                                    <td>${n.id}</td>
                                                                    <td>${n.title}</td>
                                                                    <td>${n.type}</td>
                                                                    <td>${n.message}</td>
                                                                    <td>${n.createdAt}</td>
                                                                    <td>${n.isRead  ? 'Read' : 'UnRead'}</td>
                                                                    <td class="d-flex gap-1">
                                                                        <a class="btn btn-sm btn-primary"
                                                                           href="NotificationDetail?Id=${n.id}">
                                                                            Detail
                                                                        </a>
                                                                    </td>
                                                                    
                                                                </tr>
                                                            </c:forEach>
                                                        </c:otherwise>
                                                    </c:choose>
                                                </tbody>
                                            </table>
                                            <%-- Pagination --%>
                                                <c:if test="${totalPages != null && totalPages > 1}">
                                                    <nav aria-label="Page navigation" class="mt-3">
                                                        <ul class="pagination justify-content-center flex-wrap">
                                                            <li class="page-item ${currentPage == 1 ? 'disabled' : ''}">
                                                                <a class="page-link" href="ITProblemListController?page=${currentPage - 1}">Previous</a>
                                                            </li>
                                                            <c:forEach begin="1" end="${totalPages}" var="i">
                                                                <li class="page-item ${i == currentPage ? 'active' : ''}">
                                                                    <a class="page-link" href="ITProblemListController?page=${i}">${i}</a>
                                                                </li>
                                                            </c:forEach>
                                                            <li class="page-item ${currentPage == totalPages ? 'disabled' : ''}">
                                                                <a class="page-link" href="ITProblemListController?page=${currentPage + 1}">Next</a>
                                                            </li>
                                                        </ul>
                                                    </nav>
                                                </c:if>
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

