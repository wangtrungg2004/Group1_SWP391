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

    // 4. Load notifications (nếu chưa có)
    if (request.getAttribute("notifications") == null && userId != null) {
        dao.NotificationDao notificationDao = new dao.NotificationDao();
        List<Notifications> notifications;

        // Admin & Manager: xem tất cả
        if ("Admin".equals(role) || "Manager".equals(role)) {
            notifications = notificationDao.getAllNotifications();
        } 
        // Các role khác: chỉ xem của mình
        else {
            notifications = notificationDao.getNotificationsByUserId(userId);
        }

        request.setAttribute("notifications", notifications);
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
                                                <li class="breadcrumb-item"><a href="#!">Form Components</a></li>
                                                <li class="breadcrumb-item"><a href="#!">Form Elements</a></li>
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
                                            <h5 class="m-0">Problem List</h5>
                                        </div>
                                        <div class="card-body table-border-style">
                                        <c:if test="${empty problem}">
                                            <div class="alert alert-warning">
                                             Problem list is empty
                                            </div>
                                        </c:if>
                                            <form action="ProblemList" method="get" class="mb-3">
                                                <div class="input-group">
                                                    <input type="text" name="keyword" class="form-control" placeholder="Search by Title or Ticket Number..."
                                                           value="${filterKeyword != null ? filterKeyword : ''}">
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
                                                        <th>Ticket Number</th>
                                                        <th>Title</th>
                                                        <th>Status</th>
                                                        <th>Created By</th>
                                                        <th>Created At</th>
                                                        <th>Action</th>
                                                    </tr>
                                                </thead>
                                                <tbody>
                                                    <c:choose>
                                                        <c:when test="${empty problem}">
                                                            <tr>
                                                                <td colspan="6" class="text-center text-muted">
                                                                    <i>No problems found</i>
                                                                </td>
                                                            </tr>
                                                        </c:when>
                                                        <c:otherwise>
                                                            <c:forEach items="${problem}" var="p">
                                                                <tr>
                                                                    <td>${p.id}</td>
                                                                    <td>${p.ticketNumber}</td>
                                                                    <td>${p.title}</td>
                                                                    <td>
                                                                        <span class="badge badge-info">
                                                                            ${p.status}
                                                                        </span>
                                                                    </td>
                                                                    <td>${p.createdByName != null ? p.createdByName : p.createdBy}</td>
                                                                    <td>${p.createdAt}</td>
                                                                    <td class="d-flex gap-1">
                                                                        <a class="btn btn-sm btn-primary"
                                                                           href="ProblemDetail?Id=${p.id}">
                                                                            Detail
                                                                        </a>
<!--                                                                        <form action="ProblemList" method="post"
                                                                                onsubmit="return confirm('Delete this Problem?');"
                                                                                style="display:inline;">
                                                                              <input type="hidden" name="Id" value="${p.id}">
                                                                              <button type="submit" class="btn btn-sm btn-danger">
                                                                                  Delete
                                                                              </button>
                                                                          </form>-->
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

