<%-- 
    Document   : ProblemDetail
    Created on : Jan 18, 2026, 8:16:37 PM
    Author     : DELL
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ page import="dao.NotificationDao" %>
<%@ page import="model.Notifications" %>
<%@ page import="java.util.List" %>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<%@ taglib uri="jakarta.tags.fmt" prefix="fmt" %>
<%
   List<Notifications> notifications = new java.util.ArrayList<>();
    Integer userId = (Integer) session.getAttribute("userId");
    if (userId != null) {
        NotificationDao notificationDao = new NotificationDao();
        notifications = notificationDao.getAllNotifications();
    }
    request.setAttribute("notifications", notifications);
////    String role = (String) session.getAttribute("role");
////    String problemListUrl = "IT Support".equals(role) ? "ITProblemListController" : "ProblemList";
////    request.setAttribute("problemListUrl", problemListUrl);
////    request.setAttribute("role", role != null ? role : "");
//%>
<!DOCTYPE html>
<html lang="en">

    <head>

        <title>Flash Able - Most Trusted Admin Template</title>
        <!-- HTML5 Shim and Respond.js IE11 support of HTML5 elements and media queries -->
        <!-- WARNING: Respond.js doesn't work if you view the page via file:// -->
        <!--[if lt IE 11]>
            <script src="https://oss.maxcdn.com/libs/html5shiv/3.7.0/html5shiv.js"></script>
            <script src="https://oss.maxcdn.com/libs/respond.js/1.4.2/respond.min.js"></script>
            <![endif]-->
        <!-- Meta -->
        <meta charset="utf-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0, user-scalable=0, minimal-ui">
        <meta http-equiv="X-UA-Compatible" content="IE=edge" />
        <meta name="description" content="Flash Able Bootstrap admin template made using Bootstrap 4 and it has huge amount of ready made feature, UI components, pages which completely fulfills any dashboard needs." />
        <meta name="keywords"
              content="admin templates, bootstrap admin templates, bootstrap 4, dashboard, dashboard templets, sass admin templets, html admin templates, responsive, bootstrap admin templates free download,premium bootstrap admin templates, Flash Able, Flash Able bootstrap admin template">
        <meta name="author" content="Codedthemes" />

        <!-- Favicon icon -->
        <!--<link rel="icon" href="../assets/images/favicon.ico" type="image/x-icon">-->
        <!-- fontawesome icon -->
        <link rel="stylesheet" href="assets/fonts/fontawesome/css/fontawesome-all.min.css">
        <!-- animation css -->
        <link rel="stylesheet" href="assets/plugins/animation/css/animate.min.css">

	<!-- vendor css -->
	<link rel="stylesheet" href="assets/css/style.css">
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
    .noti-message-detail {
        white-space: pre-wrap;
        word-break: break-word;
        overflow-wrap: anywhere;
    }
    </style>
</head>

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
                                                    <h5 class="m-b-10">Notification Detail</h5>
                                                </div>
                                                <ul class="breadcrumb">
                                                    <li class="breadcrumb-item"><a href="index.html"><i class="feather icon-home"></i></a></li>
                                                    <li class="breadcrumb-item">
                                                        <c:choose>
                                                            <c:when test="${role eq 'IT Support'}">
                                                                <a href="ITSupportNotificationList">Notification List</a>
                                                            </c:when>
                                                            <c:when test="${role eq 'Manager'}">
                                                                <a href="NotificationList">Notification List</a>
                                                            </c:when>
                                                            <c:otherwise>
                                                                <a href="${notificationListUrl}">Notification List</a>
                                                            </c:otherwise>
                                                        </c:choose>
                                                    </li>
                                                    <li class="breadcrumb-item"><a href="#!">Notification Detail</a></li>
                                                </ul>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                            </div>
                            <!-- [ breadcrumb ] end -->
                            <!-- [ Main Content ] start -->
                            <div class="row">
                                <div class="col-sm-12">
                                    <div class="card">
                                        <div class="card-header">
                                            <h5>Notification Details</h5>
                                            <div class="card-header-right d-flex align-items-center gap-2">
                                                <a href="${notificationListUrl}" class="btn btn-sm btn-secondary">
                                                    <i class="feather icon-arrow-left"></i> Back to List
                                                </a>
                                            </div>
                                        </div>
                                        <div class="card-body">
                                            <c:if test="${not empty error}">
                                                <div class="alert alert-danger">
                                                    <h4>Error</h4>
                                                    <p>${error}</p>
                                                    <a href="${notificationListUrl}" class="btn btn-primary">Back to Notification List</a>
                                                </div>
                                            </c:if>
                                            <c:if test="${empty error}">
                                                <c:choose>
                                                    <c:when test="${empty notification}">
                                                        <div class="alert alert-warning">
                                                            <h4>Notification not found</h4>
                                                            <p>The notification you are looking for does not exist or has been deleted.</p>
                                                            <a href="${notificationListUrl}" class="btn btn-primary">Back to Notification List</a>
                                                        </div>
                                                    </c:when>
                                                    <c:otherwise>
                                                        <div class="row">
                                                            <div class="col-md-6 col-lg-6 pr-lg-3" style="min-width: 0;">
                                                                <div class="table-responsive">
                                                                    <table class="table table-bordered">
                                                                        <tbody>
                                                                            <tr>
                                                                                <th width="200">ID</th>
                                                                                <td>${notification.id}</td>
                                                                            </tr>
                                                                            <tr>
                                                                                <th>Title</th>
                                                                                <td><strong>${notification.title}</strong></td>
                                                                            </tr>
                                                                            <tr>
                                                                                <th>Message</th>
                                                                                <td><strong class="noti-message-detail"><c:out value="${notification.message}"/></strong></td>
                                                                            </tr>
                                                                            <tr>
                                                                                <th>Created At</th>
                                                                                <td>${notification.createdAt}</td>
                                                                            </tr>
                                                                            <tr>
                                                                                <th>Type</th>
                                                                                <td><span class="badge badge-info">${notification.type}</span></td>
                                                                            </tr>
                                                                            <tr>
                                                                                <th>Send to</th>
                                                                                <td>
                                                                                    <c:choose>
                                                                                        <c:when test="${notification.isBroadcast}">
                                                                                            <span class="badge badge-success">All users (Broadcast)</span>
                                                                                        </c:when>
                                                                                        <c:otherwise>
                                                                                            User #${notification.userId}
                                                                                        </c:otherwise>
                                                                                    </c:choose>
                                                                                </td>
                                                                            </tr>
                                                                        </tbody>
                                                                    </table>
                                                                </div>
                                                            </div>
                                                        </div>
                                                    </c:otherwise>
                                                </c:choose>
                                            </c:if>
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

            <!-- Warning Section start -->
            <!-- Older IE warning message -->
            <!--[if lt IE 11]>
                    <div class="ie-warning">
                        <h1>Warning!!</h1>
                        <p>You are using an outdated version of Internet Explorer, please upgrade
                           <br/>to any of the following web browsers to access this website.
                        </p>
                        <div class="iew-container">
                            <ul class="iew-download">
                                <li>
                                    <a href="http://www.google.com/chrome/">
                                        <img src="../assets/images/browser/chrome.png" alt="Chrome">
                                        <div>Chrome</div>
                                    </a>
                                </li>
                                <li>
                                    <a href="https://www.mozilla.org/en-US/firefox/new/">
                                        <img src="../assets/images/browser/firefox.png" alt="Firefox">
                                        <div>Firefox</div>
                                    </a>
                                </li>
                                <li>
                                    <a href="http://www.opera.com">
                                        <img src="../assets/images/browser/opera.png" alt="Opera">
                                        <div>Opera</div>
                                    </a>
                                </li>
                                <li>
                                    <a href="https://www.apple.com/safari/">
                                        <img src="../assets/images/browser/safari.png" alt="Safari">
                                        <div>Safari</div>
                                    </a>
                                </li>
                                <li>
                                    <a href="http://windows.microsoft.com/en-us/internet-explorer/download-ie">
                                        <img src="../assets/images/browser/ie.png" alt="">
                                        <div>IE (11 & above)</div>
                                    </a>
                                </li>
                            </ul>
                        </div>
                        <p>Sorry for the inconvenience!</p>
                    </div>
                <![endif]-->
            <!-- Warning Section Ends -->

            <!-- Required Js -->
            <script src="assets/plugins/jquery/js/jquery.min.js"></script>
            <script src="assets/js/vendor-all.min.js"></script>
            <script src="assets/plugins/bootstrap/js/bootstrap.min.js"></script>
            <script src="assets/js/pcoded.min.js"></script>
    </body>

</html>

<script>
                                                                                    $(document).ready(function () {
                                                                                        $('.fixed-button').remove();
                                                                                    });
</script>
