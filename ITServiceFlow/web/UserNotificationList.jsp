<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<%@ taglib uri="jakarta.tags.fmt" prefix="fmt" %>
<%@ page import="java.util.List" %>
<%@ page import="model.Notifications" %>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0, user-scalable=0, minimal-ui">
    <meta http-equiv="X-UA-Compatible" content="IE=edge" />
    <meta name="description" content="My Notifications" />
    <meta name="author" content="ITServiceFlow" />
    <link rel="stylesheet" href="assets/fonts/fontawesome/css/fontawesome-all.min.css">
    <link rel="stylesheet" href="assets/plugins/animation/css/animate.min.css">
    <link rel="stylesheet" href="assets/plugins/bootstrap/css/bootstrap.min.css">
    <link rel="stylesheet" href="assets/css/style.css">
    <title>My Notifications - ITServiceFlow</title>
    <style>
        .pcoded-wrapper { max-width: 100% !important; width: 100% !important; margin: 0 !important; }
        .pcoded-main-container { width: 100% !important; margin-left: 264px !important; }
        .pcoded-navbar.navbar-collapsed ~ .pcoded-main-container { margin-left: 80px !important; }
        .pcoded-content, .pcoded-inner-content, .main-body, .page-wrapper { max-width: 100% !important; width: 100% !important; }
        body { overflow-x: hidden; }
    </style>
</head>
<body class="">
    <div class="loader-bg"><div class="loader-track"><div class="loader-fill"></div></div></div>
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
                                            <h5 class="m-b-10">My Notifications</h5>
                                            <ul class="breadcrumb">
                                                <li class="breadcrumb-item"><a href="index.html"><i class="feather icon-home"></i></a></li>
                                                <li class="breadcrumb-item"><a href="UserNotificationList">Notification List</a></li>
                                                <li class="breadcrumb-item"><a href="#!">Notification List</a></li>
                                            </ul>
                                        </div>
                                    </div>
                                </div>
                            </div>

                            <div class="row">
                                <div class="col-sm-12">
                                    <div class="card">
                                        <div class="card-header">
                                            <h5 class="m-0">Notification List</h5>
                                        </div>
                                        <div class="card-body table-border-style">
                                            <c:if test="${empty notifications}">
                                                <div class="alert alert-warning">Notification list is empty</div>
                                            </c:if>
                                            <div class="table-responsive">
                                                <table class="table table-hover">
                                                    <thead class="thead-dark">
                                                        <tr>
                                                            <th>ID</th>
                                                            <th>Title</th>
                                                            <th>Type</th>
                                                            <th>Send to</th>
                                                            <th>Message</th>
                                                            <th>Created At</th>
                                                            <th>Status</th>
                                                            <th>Action</th>
                                                        </tr>
                                                    </thead>
                                                    <tbody>
                                                        <c:choose>
                                                            <c:when test="${empty notifications}">
                                                                <tr>
                                                                    <td colspan="8" class="text-center text-muted">No notifications found</td>
                                                                </tr>
                                                            </c:when>
                                                            <c:otherwise>
                                                                <c:forEach items="${notifications}" var="n">
                                                                    <tr>
                                                                        <td>${n.id}</td>
                                                                        <td>${n.title}</td>
                                                                        <td>${n.type}</td>
                                                                        <td>
                                                                            <c:choose>
                                                                                <c:when test="${n.isBroadcast}">
                                                                                    <span class="badge badge-success">All (Broadcast)</span>
                                                                                </c:when>
                                                                                <c:otherwise>
                                                                                    User #${n.userId}
                                                                                </c:otherwise>
                                                                            </c:choose>
                                                                        </td>
                                                                        <td>${n.message}</td>
                                                                        <td><fmt:formatDate value="${n.createdAt}" pattern="dd/MM/yyyy HH:mm"/></td>
                                                                        <td>${n.isRead ? 'Read' : 'Unread'}</td>
                                                                        <td>
                                                                            <a class="btn btn-sm btn-primary" href="NotificationDetail?Id=${n.id}">Detail</a>
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

    <script src="assets/js/vendor-all.min.js"></script>
    <script src="assets/plugins/bootstrap/js/bootstrap.min.js"></script>
    <script src="assets/js/pcoded.min.js"></script>
</body>
</html>