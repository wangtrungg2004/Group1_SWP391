<%-- 
    Document   : ITDashboard
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
    if (role == null || !role.equals("IT Support")) {
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
    
    <style>
        .stat-card {
            background: white;
            border-radius: 10px;
            padding: 25px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.1);
            transition: all 0.3s ease;
            border-left: 4px solid;
            height: 100%;
        }
        .stat-card:hover {
            transform: translateY(-5px);
            box-shadow: 0 5px 20px rgba(0,0,0,0.15);
        }
        .stat-card.blue { border-left-color: #2196F3; }
        .stat-card.green { border-left-color: #4CAF50; }
        .stat-card.yellow { border-left-color: #FFC107; }
        .stat-card.purple { border-left-color: #9C27B0; }
        .stat-card h6 {
            color: #6c757d;
            font-size: 0.9rem;
            font-weight: 600;
            text-transform: uppercase;
            margin-bottom: 15px;
            letter-spacing: 0.5px;
        }
        .stat-card h3 {
            font-size: 2rem;
            font-weight: 700;
            margin: 0;
            color: #333;
        }
        .stat-card .icon {
            font-size: 2.5rem;
            opacity: 0.3;
            float: right;
            margin-top: -10px;
        }
        .welcome-card {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            border-radius: 10px;
            padding: 30px;
            margin-bottom: 30px;
            box-shadow: 0 4px 15px rgba(102, 126, 234, 0.3);
        }
        .welcome-card h5 {
            font-size: 1.5rem;
            margin-bottom: 10px;
        }
        .welcome-card ul {
            margin-top: 15px;
            padding-left: 20px;
        }
        .welcome-card ul li {
            margin-bottom: 8px;
        }
    </style>
    
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

    <!-- [ navigation menu ] start -->
    <nav class="pcoded-navbar menupos-fixed menu-light brand-blue ">
        <div class="navbar-wrapper ">
            <div class="navbar-brand header-logo">
                <a href="ITDashboard.jsp" class="b-brand">
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
                        <a href="ITDashboard.jsp" class="nav-link"><span class="pcoded-micon"><i class="feather icon-home"></i></span><span class="pcoded-mtext">Dashboard</span></a>
                    </li>
                    <li class="nav-item pcoded-menu-caption">
                        <label>Hỗ trợ</label>
                    </li>
                    <li class="nav-item">
                        <a href="Tickets" class="nav-link"><span class="pcoded-micon"><i class="feather icon-help-circle"></i></span><span class="pcoded-mtext">Quản lý Tickets</span></a>
                    </li>
                    <li class="nav-item">
                        <a href="AssignedTickets" class="nav-link"><span class="pcoded-micon"><i class="feather icon-user-check"></i></span><span class="pcoded-mtext">Tickets được giao</span></a>
                    </li>
                    <li class="nav-item">
                        <a href="PendingTickets" class="nav-link"><span class="pcoded-micon"><i class="feather icon-clock"></i></span><span class="pcoded-mtext">Tickets đang chờ</span></a>
                    </li>
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
                                <span><%= user != null ? user.getFullName() : "IT Support" %></span>
                                <span style="display: block; font-size: 11px; color: #999;"><%= role != null ? role : "" %></span>
                                <a href="Logout" class="dud-logout" title="Logout">
                                    <i class="feather icon-log-out"></i>
                                </a>
                            </div>
                            <ul class="pro-body">
                                <li><a href="ITProfile" class="dropdown-item"><i class="feather icon-user"></i> Profile</a></li>
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
                                        <h5 class="m-b-10">IT Support Dashboard</h5>
                                    </div>
                                    <ul class="breadcrumb">
                                        <li class="breadcrumb-item"><a href="ITDashboard.jsp"><i class="feather icon-home"></i></a></li>
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
                                    <div class="stat-card green">
                                        <h6>Tickets mới</h6>
                                        <h3>0</h3>
                                        <i class="feather icon-file-plus icon"></i>
                                    </div>
                                </div>
                                <div class="col-md-6 col-xl-3">
                                    <div class="stat-card yellow">
                                        <h6>Tickets đang xử lý</h6>
                                        <h3>0</h3>
                                        <i class="feather icon-clock icon"></i>
                                    </div>
                                </div>
                                <div class="col-md-6 col-xl-3">
                                    <div class="stat-card blue">
                                        <h6>Tickets đã giải quyết</h6>
                                        <h3>0</h3>
                                        <i class="feather icon-check-circle icon"></i>
                                    </div>
                                </div>
                                <div class="col-md-6 col-xl-3">
                                    <div class="stat-card purple">
                                        <h6>Tổng Tickets</h6>
                                        <h3>0</h3>
                                        <i class="feather icon-list icon"></i>
                                    </div>
                                </div>
                                <!-- [ Statistics ] end -->
                            </div>

                            <div class="row">
                                <div class="col-xl-12">
                                    <div class="welcome-card">
                                        <h5><i class="feather icon-headphones"></i> Chào mừng, <%= user != null ? user.getFullName() : "IT Support" %>!</h5>
                                        <p>Đây là trang dashboard dành cho IT Support. Bạn có thể:</p>
                                        <ul>
                                            <li><i class="feather icon-file-text"></i> Xem và quản lý tất cả tickets</li>
                                            <li><i class="feather icon-user-check"></i> Nhận và xử lý tickets được giao</li>
                                            <li><i class="feather icon-edit"></i> Cập nhật trạng thái tickets</li>
                                            <li><i class="feather icon-clock"></i> Xem tickets đang chờ xử lý</li>
                                        </ul>
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
