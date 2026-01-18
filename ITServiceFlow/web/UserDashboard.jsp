<%-- 
    Document   : UserDashboard
    Created on : Jan 17, 2026
    Author     : DELL
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<%
    // Kiểm tra đăng nhập
    if (session.getAttribute("user") == null) {
        response.sendRedirect("Login.jsp");
        return;
    }
    
    // Kiểm tra quyền truy cập
    String role = (String) session.getAttribute("role");
    if (role == null || (!role.equals("Manager") && !role.equals("User"))) {
        response.sendRedirect("Login.jsp");
        return;
    }
    
    model.Users user = (model.Users) session.getAttribute("user");
%>
<!DOCTYPE html>
<html lang="en">

<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0, user-scalable=0, minimal-ui">
    <meta http-equiv="X-UA-Compatible" content="IE=edge" />
    <meta name="description" content="User Dashboard" />
    <meta name="author" content="ITServiceFlow" />

    <!-- fontawesome icon -->
    <link rel="stylesheet" href="assets/fonts/fontawesome/css/fontawesome-all.min.css">
    <!-- animation css -->
    <link rel="stylesheet" href="assets/plugins/animation/css/animate.min.css">
    
    <!-- Bootstrap CSS -->
    <link rel="stylesheet" href="assets/plugins/bootstrap/css/bootstrap.min.css">

    <!-- vendor css -->
    <link rel="stylesheet" href="assets/css/style.css">
    
    <title>User Dashboard - ITServiceFlow</title>
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
    <nav class="pcoded-navbar menupos-fixed menu-light brand-blue ">
        <div class="navbar-wrapper ">
            <div class="navbar-brand header-logo">
                <a href="UserDashboard.jsp" class="b-brand">
                    <img src="assets/images/logo.svg" alt="" class="logo images">
                    <img src="assets/images/logo-icon.svg" alt="" class="logo-thumb images">
                </a>
                <a class="mobile-menu" id="mobile-collapse" href="#!"><span></span></a>
            </div>
            <div class="navbar-content scroll-div">
                <ul class="nav pcoded-inner-navbar">
                    <li class="nav-item pcoded-menu-caption">
                        <label>Navigation</label>
                    </li>
                    <li class="nav-item">
                        <a href="UserDashboard.jsp" class="nav-link"><span class="pcoded-micon"><i class="feather icon-home"></i></span><span class="pcoded-mtext">Dashboard</span></a>
                    </li>
                    <li class="nav-item">
                        <a href="Tickets" class="nav-link"><span class="pcoded-micon"><i class="feather icon-help-circle"></i></span><span class="pcoded-mtext">Tickets của tôi</span></a>
                    </li>
                    <li class="nav-item">
                        <a href="CreateTicket" class="nav-link"><span class="pcoded-micon"><i class="feather icon-plus-circle"></i></span><span class="pcoded-mtext">Tạo Ticket mới</span></a>
                    </li>
                    <c:if test="${role == 'Manager'}">
                        <li class="nav-item pcoded-menu-caption">
                            <label>Quản lý</label>
                        </li>
                        <li class="nav-item">
                            <a href="Reports" class="nav-link"><span class="pcoded-micon"><i class="feather icon-file-text"></i></span><span class="pcoded-mtext">Báo cáo</span></a>
                        </li>
                    </c:if>
                </ul>
            </div>
        </div>
    </nav>
    <!-- [ navigation menu ] end -->

    <!-- [ Header ] start -->
    <header class="navbar pcoded-header navbar-expand-lg navbar-light header-blue">
        <div class="m-header">
            <a class="mobile-menu" id="mobile-collapse1" href="#!"><span></span></a>
            <a href="#!" class="b-brand">
                <div class="b-bg">
                    <i class="feather icon-trending-up"></i>
                </div>
                <span class="b-title">ITServiceFlow</span>
            </a>
        </div>
        <a class="mobile-menu" id="mobile-header" href="#!">
            <i class="feather icon-more-horizontal"></i>
        </a>
        <div class="collapse navbar-collapse">
            <ul class="navbar-nav mr-auto">
                <li><a href="#!" class="full-screen" onclick="javascript:toggleFullScreen()"><i class="feather icon-maximize"></i></a></li>
            </ul>
            <ul class="navbar-nav ml-auto">
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
                                <li><a href="UserProfile" class="dropdown-item"><i class="feather icon-user"></i> Profile</a></li>
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
                    <!-- [ breadcrumb ] start -->
                    <div class="page-header">
                        <div class="page-block">
                            <div class="row align-items-center">
                                <div class="col-md-12">
                                    <div class="page-header-title">
                                        <h5 class="m-b-10">User Dashboard</h5>
                                    </div>
                                    <ul class="breadcrumb">
                                        <li class="breadcrumb-item"><a href="UserDashboard.jsp"><i class="feather icon-home"></i></a></li>
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
                                            <h6 class="mb-4">Tickets đang mở</h6>
                                            <div class="row d-flex align-items-center">
                                                <div class="col-9">
                                                    <h3 class="f-w-300 d-flex align-items-center m-b-0"><i class="feather icon-file-text text-c-green f-30 m-r-10"></i>0</h3>
                                                </div>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                                <div class="col-md-6 col-xl-3">
                                    <div class="card">
                                        <div class="card-body">
                                            <h6 class="mb-4">Tickets đã đóng</h6>
                                            <div class="row d-flex align-items-center">
                                                <div class="col-9">
                                                    <h3 class="f-w-300 d-flex align-items-center m-b-0"><i class="feather icon-check-circle text-c-blue f-30 m-r-10"></i>0</h3>
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
                                                    <h3 class="f-w-300 d-flex align-items-center m-b-0"><i class="feather icon-clock text-c-yellow f-30 m-r-10"></i>0</h3>
                                                </div>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                                <div class="col-md-6 col-xl-3">
                                    <div class="card">
                                        <div class="card-body">
                                            <h6 class="mb-4">Tổng Tickets</h6>
                                            <div class="row d-flex align-items-center">
                                                <div class="col-9">
                                                    <h3 class="f-w-300 d-flex align-items-center m-b-0"><i class="feather icon-list text-c-purple f-30 m-r-10"></i>0</h3>
                                                </div>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                                <!-- [ Statistics ] end -->
                            </div>

                            <div class="row">
                                <div class="col-xl-12">
                                    <div class="card">
                                        <div class="card-header">
                                            <h5>Chào mừng, <%= user != null ? user.getFullName() : "User" %>!</h5>
                                        </div>
                                        <div class="card-body">
                                            <p>Đây là trang dashboard dành cho User. Bạn có thể:</p>
                                            <ul>
                                                <li>Xem và quản lý tickets của bạn</li>
                                                <li>Tạo ticket mới khi cần hỗ trợ</li>
                                                <li>Xem lịch sử tickets</li>
                                                <c:if test="${role == 'Manager'}">
                                                    <li>Xem báo cáo và thống kê</li>
                                                </c:if>
                                            </ul>
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
    <script src="assets/js/vendor-all.min.js"></script>
    <script src="assets/plugins/bootstrap/js/bootstrap.min.js"></script>
    <script src="assets/js/pcoded.min.js"></script>
</body>

</html>
