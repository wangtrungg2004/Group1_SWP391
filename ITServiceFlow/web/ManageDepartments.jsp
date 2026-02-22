<%-- 
    Document   : CreateUser
    Created on : Jan 18, 2026
    Author     : DELL
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<%
    // Kiểm tra đăng nhập và quyền Admin
    if (session.getAttribute("user") == null) {
        response.sendRedirect("Login.jsp");
        return;
    }
    
    String role = (String) session.getAttribute("role");
    if (role == null || !role.equals("Admin")) {
        response.sendError(HttpServletResponse.SC_FORBIDDEN, "Bạn không có quyền truy cập trang này.");
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
    <title>Tạo User Mới - ITServiceFlow</title>

    <!-- Favicon -->
    <link rel="icon" type="image/x-icon" href="assets/images/favicon.ico">
    
    <!-- fontawesome icon -->
    <link rel="stylesheet" href="assets/fonts/fontawesome/css/fontawesome-all.min.css">
    <!-- Bootstrap CSS -->
    <link rel="stylesheet" href="assets/plugins/bootstrap/css/bootstrap.min.css">
    <!-- vendor css -->
    <link rel="stylesheet" href="assets/css/style.css">
    
    <style>
        :root {
            --primary-color: #667eea;
            --secondary-color: #764ba2;
            --success-color: #10b981;
            --danger-color: #ef4444;
            --warning-color: #f59e0b;
            --light-color: #f8fafc;
            --dark-color: #1e293b;
            --border-color: #e2e8f0;
        }
        
        body {
            background-color: #f5f7fb;
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
        }
        
        /* Main Layout */
        .pcoded-main-container {
            background: #f5f7fb;
            padding-top: 70px;
        }
        
        /* Header Styles */
        .pcoded-header {
            background: linear-gradient(135deg, var(--primary-color) 0%, var(--secondary-color) 100%);
            box-shadow: 0 2px 10px rgba(0,0,0,0.1);
        }
        
        .pcoded-header .navbar-nav .nav-link {
            color: rgba(255,255,255,0.9);
        }
        
        .pcoded-header .navbar-nav .nav-link:hover {
            color: white;
        }
        
        /* Card Container */
        .form-container {
            max-width: 800px;
            margin: 0 auto;
            padding: 20px;
        }
        
        .card {
            border: none;
            border-radius: 15px;
            box-shadow: 0 4px 20px rgba(0,0,0,0.08);
            overflow: hidden;
            margin-bottom: 30px;
        }
        
        .card-header {
            background: linear-gradient(135deg, var(--primary-color) 0%, var(--secondary-color) 100%);
            padding: 25px 30px;
            border-bottom: none;
            position: relative;
        }
        
        .card-header::after {
            content: '';
            position: absolute;
            bottom: 0;
            left: 0;
            right: 0;
            height: 3px;
            background: rgba(255,255,255,0.3);
        }
        
        .card-header h5 {
            color: white;
            font-weight: 600;
            font-size: 1.5rem;
            margin: 0;
            display: flex;
            align-items: center;
            gap: 12px;
        }
        
        .card-header h5 i {
            font-size: 1.2rem;
            background: rgba(255,255,255,0.2);
            width: 40px;
            height: 40px;
            display: flex;
            align-items: center;
            justify-content: center;
            border-radius: 10px;
        }
        
        .card-body {
            padding: 35px;
            background: white;
        }
        
        /* Section Titles */
        .section-title {
            font-size: 1.1rem;
            font-weight: 600;
            color: var(--dark-color);
            margin: 35px 0 25px 0;
            padding-bottom: 12px;
            border-bottom: 2px solid var(--border-color);
            display: flex;
            align-items: center;
            gap: 10px;
        }
        
        .section-title:first-of-type {
            margin-top: 0;
        }
        
        .section-title i {
            color: var(--primary-color);
            background: rgba(102, 126, 234, 0.1);
            width: 32px;
            height: 32px;
            display: flex;
            align-items: center;
            justify-content: center;
            border-radius: 8px;
            font-size: 1rem;
        }
        
        /* Form Styles */
        .form-group {
            margin-bottom: 25px;
        }
        
        .form-group label {
            font-weight: 600;
            margin-bottom: 10px;
            display: flex;
            align-items: center;
            gap: 8px;
            color: #475569;
            font-size: 0.95rem;
        }
        
        .form-group label i {
            color: var(--primary-color);
            font-size: 0.9rem;
            width: 18px;
            text-align: center;
        }
        
        .required {
            color: var(--danger-color);
            font-weight: bold;
            margin-left: 2px;
        }
        
        .form-control {
            border: 2px solid var(--border-color);
            border-radius: 10px;
            padding: 12px 16px;
            font-size: 0.95rem;
            transition: all 0.3s ease;
            background: white;
            color: var(--dark-color);
        }
        
        .form-control:focus {
            border-color: var(--primary-color);
            box-shadow: 0 0 0 4px rgba(102, 126, 234, 0.15);
            outline: none;
        }
        
        .form-control::placeholder {
            color: #94a3b8;
        }
        
        select.form-control {
            cursor: pointer;
            background-image: url("data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' width='16' height='16' viewBox='0 0 24 24' fill='none' stroke='%23667eea' stroke-width='2' stroke-linecap='round' stroke-linejoin='round'%3E%3Cpath d='M6 9l6 6 6-6'/%3E%3C/svg%3E");
            background-repeat: no-repeat;
            background-position: right 16px center;
            background-size: 16px;
            padding-right: 45px;
            appearance: none;
        }
        
        /* Form Text */
        .form-text {
            font-size: 0.85rem;
            color: #64748b;
            margin-top: 8px;
            padding-left: 26px;
        }
        
        /* Alert Messages */
        .alert {
            border: none;
            border-radius: 10px;
            padding: 18px 22px;
            margin-bottom: 25px;
            display: flex;
            align-items: center;
            gap: 12px;
            animation: slideDown 0.3s ease;
            font-size: 0.95rem;
        }
        
        @keyframes slideDown {
            from {
                opacity: 0;
                transform: translateY(-15px);
            }
            to {
                opacity: 1;
                transform: translateY(0);
            }
        }
        
        .alert-success {
            background-color: #ecfdf5;
            color: #065f46;
            border-left: 4px solid var(--success-color);
        }
        
        .alert-danger {
            background-color: #fef2f2;
            color: #991b1b;
            border-left: 4px solid var(--danger-color);
        }
        
        .alert i {
            font-size: 1.2rem;
        }
        
        /* Buttons */
        .btn {
            padding: 12px 28px;
            border-radius: 10px;
            font-weight: 600;
            font-size: 0.95rem;
            transition: all 0.3s ease;
            border: none;
            display: inline-flex;
            align-items: center;
            gap: 8px;
            text-decoration: none;
        }
        
        .btn-primary {
            background: linear-gradient(135deg, var(--primary-color) 0%, var(--secondary-color) 100%);
            color: white;
            box-shadow: 0 4px 15px rgba(102, 126, 234, 0.3);
        }
        
        .btn-primary:hover {
            transform: translateY(-2px);
            box-shadow: 0 6px 20px rgba(102, 126, 234, 0.4);
            color: white;
        }
        
        .btn-secondary {
            background: #64748b;
            color: white;
            box-shadow: 0 4px 15px rgba(100, 116, 139, 0.2);
        }
        
        .btn-secondary:hover {
            background: #475569;
            transform: translateY(-2px);
            box-shadow: 0 6px 20px rgba(100, 116, 139, 0.3);
            color: white;
        }
        
        .btn i {
            font-size: 1rem;
        }
        
        /* Form Actions */
        .form-actions {
            display: flex;
            gap: 15px;
            margin-top: 40px;
            padding-top: 25px;
            border-top: 2px solid var(--border-color);
        }
        
        /* Responsive Design */
        @media (max-width: 768px) {
            .card-body {
                padding: 25px 20px;
            }
            
            .form-actions {
                flex-direction: column;
            }
            
            .btn {
                width: 100%;
                justify-content: center;
            }
            
            .section-title {
                font-size: 1rem;
            }
            
            .form-container {
                padding: 15px;
            }
        }
        
        /* Row spacing */
        .row {
            margin-left: -8px;
            margin-right: -8px;
        }
        
        .row > [class*="col-"] {
            padding-left: 8px;
            padding-right: 8px;
        }
        
        /* Input group icons */
        .input-group-icon {
            position: relative;
        }
        
        .input-group-icon .form-control {
            padding-left: 45px;
        }
        
        .input-group-icon i {
            position: absolute;
            left: 16px;
            top: 50%;
            transform: translateY(-50%);
            color: #94a3b8;
            z-index: 10;
        }
        
        /* Password strength indicator */
        .password-strength {
            height: 4px;
            background: #e2e8f0;
            border-radius: 2px;
            margin-top: 8px;
            overflow: hidden;
        }
        
        .password-strength-bar {
            height: 100%;
            width: 0%;
            background: var(--danger-color);
            transition: width 0.3s ease;
        }
        
        /* Loading overlay */
        .loading-overlay {
            position: fixed;
            top: 0;
            left: 0;
            right: 0;
            bottom: 0;
            background: rgba(255,255,255,0.9);
            display: flex;
            align-items: center;
            justify-content: center;
            z-index: 9999;
            display: none;
        }
        
        .spinner-border {
            width: 3rem;
            height: 3rem;
            color: var(--primary-color);
        }
        
        /* Breadcrumb fix */
        .breadcrumb {
            background: transparent;
            padding: 0;
            margin-bottom: 0;
        }
        
        .breadcrumb-item a {
            color: #64748b;
            text-decoration: none;
        }
        
        .breadcrumb-item.active {
            color: var(--primary-color);
            font-weight: 500;
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

    <!-- Loading overlay -->
    <div class="loading-overlay">
        <div class="spinner-border" role="status">
            <span class="sr-only">Loading...</span>
        </div>
    </div>

    <!-- [ navigation menu ] start -->
    <nav class="pcoded-navbar menupos-fixed menu-light brand-blue">
        <div class="navbar-wrapper">
            <div class="navbar-brand header-logo">
                <a href="AdminDashboard.jsp" class="b-brand">
                    <img src="assets/images/logo.svg" alt="ITServiceFlow" class="logo images">
                    <img src="assets/images/logo-icon.svg" alt="ITSF" class="logo-thumb images">
                </a>
                <a class="mobile-menu" id="mobile-collapse" href="#!"><span></span></a>
            </div>
            <div class="navbar-content scroll-div">
                <ul class="nav pcoded-inner-navbar">
                    <li class="nav-item">
                        <a href="AdminDashboard.jsp" class="nav-link">
                            <span class="pcoded-micon"><i class="feather icon-home"></i></span>
                            <span class="pcoded-mtext">Dashboard</span>
                        </a>
                    </li>
                    <li class="nav-item pcoded-menu-caption">
                        <label>Quản trị hệ thống</label>
                    </li>
                    <li class="nav-item">
                        <a href="CreateUser" class="nav-link active">
                            <span class="pcoded-micon"><i class="feather icon-user-plus"></i></span>
                            <span class="pcoded-mtext">Tạo User</span>
                        </a>
                    </li>
                    <li class="nav-item">
                        <a href="UserManagement" class="nav-link">
                            <span class="pcoded-micon"><i class="feather icon-users"></i></span>
                            <span class="pcoded-mtext">Quản lý User</span>
                        </a>
                    </li>
                    <li class="nav-item">
                        <a href="DepartmentManagement" class="nav-link">
                            <span class="pcoded-micon"><i class="feather icon-layers"></i></span>
                            <span class="pcoded-mtext">Phòng Ban</span>
                        </a>
                    </li>
                    <li class="nav-item">
                        <a href="LocationManagement" class="nav-link">
                            <span class="pcoded-micon"><i class="feather icon-map-pin"></i></span>
                            <span class="pcoded-mtext">Địa điểm</span>
                        </a>
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
            <a href="AdminDashboard.jsp" class="b-brand">
                <div class="b-bg">
                    <i class="feather icon-settings"></i>
                </div>
                <span class="b-title">ITServiceFlow</span>
            </a>
        </div>
        <a class="mobile-menu" id="mobile-header" href="#!">
            <i class="feather icon-more-horizontal"></i>
        </a>
        <div class="collapse navbar-collapse">
            <ul class="navbar-nav mr-auto">
                <li><a href="#!" class="full-screen" onclick="javascript:toggleFullScreen()" title="Toàn màn hình">
                    <i class="feather icon-maximize"></i>
                </a></li>
                <li class="nav-item">
                    <a href="AdminDashboard.jsp" class="nav-link" title="Dashboard">
                        <i class="feather icon-home"></i>
                    </a>
                </li>
            </ul>
            <ul class="navbar-nav ml-auto">
                <li class="nav-item dropdown">
                    <a href="#" class="dropdown-toggle" data-toggle="dropdown" style="display: flex; align-items: center; gap: 10px; padding: 10px 15px;">
                        <img src="assets/images/user/avatar-1.jpg" class="img-radius" alt="User Avatar" style="width: 36px; height: 36px; border-radius: 50%; border: 2px solid rgba(255,255,255,0.3);">
                        <div style="text-align: left;">
                            <span style="font-weight: 600; color: white; display: block; font-size: 0.95rem;">
                                <%= user != null ? user.getFullName() : "Admin" %>
                            </span>
                            <span style="font-size: 0.85rem; color: rgba(255,255,255,0.8); display: block;">
                                <%= role != null ? role : "" %>
                            </span>
                        </div>
                        <i class="feather icon-chevron-down" style="font-size: 14px; color: white;"></i>
                    </a>
                    <div class="dropdown-menu dropdown-menu-right profile-notification" style="min-width: 220px;">
                        <div class="pro-head" style="padding: 20px; text-align: center; border-bottom: 1px solid var(--border-color);">
                            <img src="assets/images/user/avatar-1.jpg" class="img-radius" alt="User Avatar" style="width: 60px; height: 60px; border-radius: 50%; margin-bottom: 10px;">
                            <h6 style="margin: 0; font-weight: 600;"><%= user != null ? user.getFullName() : "Admin" %></h6>
                            <span style="font-size: 0.85rem; color: #64748b;"><%= role != null ? role : "" %></span>
                        </div>
                        <ul class="pro-body" style="margin: 0; padding: 10px 0;">
                            <li style="list-style: none;">
                                <a href="AdminDashboard.jsp" class="dropdown-item" style="padding: 12px 20px;">
                                    <i class="feather icon-home mr-2"></i> Dashboard
                                </a>
                            </li>
                            <li style="list-style: none;">
                                <a href="Profile.jsp" class="dropdown-item" style="padding: 12px 20px;">
                                    <i class="feather icon-user mr-2"></i> Hồ sơ
                                </a>
                            </li>
                            <li style="list-style: none; border-top: 1px solid var(--border-color); margin-top: 10px;">
                                <a href="Logout" class="dropdown-item" style="padding: 12px 20px; color: var(--danger-color);">
                                    <i class="feather icon-log-out mr-2"></i> Đăng xuất
                                </a>
                            </li>
                        </ul>
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
                                        <h5 class="m-b-10" style="font-weight: 600; color: var(--dark-color);">
                                            <i class="feather icon-user-plus mr-2"></i>Tạo User Mới
                                        </h5>
                                    </div>
                                    <nav aria-label="breadcrumb">
                                        <ol class="breadcrumb">
                                            <li class="breadcrumb-item">
                                                <a href="AdminDashboard.jsp">
                                                    <i class="feather icon-home"></i> Dashboard
                                                </a>
                                            </li>
                                            <li class="breadcrumb-item">
                                                <a href="#!">Quản trị</a>
                                            </li>
                                            <li class="breadcrumb-item active" aria-current="page">Tạo User</li>
                                        </ol>
                                    </nav>
                                </div>
                            </div>
                        </div>
                    </div>
                    <!-- [ breadcrumb ] end -->

                    <div class="main-body">
                        <div class="page-wrapper">
                            <div class="row">
                                <div class="col-md-12">
                                    <div class="form-container">
                                        <div class="card">
                                            <div class="card-header">
                                                <h5>
                                                    <i class="feather icon-user-plus"></i>
                                                    Tạo User Mới
                                                </h5>
                                            </div>
                                            <div class="card-body">
                                                <!-- Hiển thị thông báo -->
                                                <c:if test="${not empty success}">
                                                    <div class="alert alert-success">
                                                        <i class="fas fa-check-circle"></i>
                                                        <strong>Thành công!</strong> ${success}
                                                    </div>
                                                </c:if>
                                                <c:if test="${not empty error}">
                                                    <div class="alert alert-danger">
                                                        <i class="fas fa-exclamation-circle"></i>
                                                        <strong>Lỗi!</strong> ${error}
                                                    </div>
                                                </c:if>

                                                <form method="post" action="CreateUser" id="createUserForm">
                                                    <!-- Thông tin cơ bản -->
                                                    <div class="section-title">
                                                        <i class="feather icon-user"></i>
                                                        Thông tin cơ bản
                                                    </div>
                                                    
                                                    <div class="row">
                                                        <div class="col-md-6">
                                                            <div class="form-group">
                                                                <label for="username">
                                                                    <i class="fas fa-user"></i>
                                                                    Username <span class="required">*</span>
                                                                </label>
                                                                <div class="input-group-icon">
                                                                    <i class="fas fa-user"></i>
                                                                    <input type="text" 
                                                                           id="username" 
                                                                           name="username" 
                                                                           class="form-control" 
                                                                           required 
                                                                           value="${not empty username ? username : param.username}" 
                                                                           placeholder="vd: nguyenvana">
                                                                </div>
                                                            </div>
                                                        </div>
                                                        <div class="col-md-6">
                                                            <div class="form-group">
                                                                <label for="email">
                                                                    <i class="fas fa-envelope"></i>
                                                                    Email <span class="required">*</span>
                                                                </label>
                                                                <div class="input-group-icon">
                                                                    <i class="fas fa-envelope"></i>
                                                                    <input type="email" 
                                                                           id="email" 
                                                                           name="email" 
                                                                           class="form-control" 
                                                                           required 
                                                                           value="${not empty email ? email : param.email}" 
                                                                           placeholder="vd: nguyenvana@company.com">
                                                                </div>
                                                            </div>
                                                        </div>
                                                    </div>

                                                    <div class="row">
                                                        <div class="col-md-6">
                                                            <div class="form-group">
                                                                <label for="password">
                                                                    <i class="fas fa-lock"></i>
                                                                    Mật khẩu <span class="required">*</span>
                                                                </label>
                                                                <div class="input-group-icon">
                                                                    <i class="fas fa-lock"></i>
                                                                    <input type="password" 
                                                                           id="password" 
                                                                           name="password" 
                                                                           class="form-control" 
                                                                           required 
                                                                           placeholder="Nhập mật khẩu"
                                                                           minlength="6">
                                                                </div>
                                                                <div class="password-strength">
                                                                    <div class="password-strength-bar" id="passwordStrength"></div>
                                                                </div>
                                                                <small class="form-text">Mật khẩu phải có ít nhất 6 ký tự</small>
                                                            </div>
                                                        </div>
                                                        <div class="col-md-6">
                                                            <div class="form-group">
                                                                <label for="fullName">
                                                                    <i class="fas fa-id-card"></i>
                                                                    Họ và Tên <span class="required">*</span>
                                                                </label>
                                                                <div class="input-group-icon">
                                                                    <i class="fas fa-id-card"></i>
                                                                    <input type="text" 
                                                                           id="fullName" 
                                                                           name="fullName" 
                                                                           class="form-control" 
                                                                           required 
                                                                           value="${not empty fullName ? fullName : param.fullName}" 
                                                                           placeholder="Nguyễn Văn A">
                                                                </div>
                                                            </div>
                                                        </div>
                                                    </div>

                                                    <!-- Phân quyền -->
                                                    <div class="section-title">
                                                        <i class="feather icon-shield"></i>
                                                        Phân quyền
                                                    </div>

                                                    <div class="row">
                                                        <div class="col-md-6">
                                                            <div class="form-group">
                                                                <label for="role">
                                                                    <i class="fas fa-user-tag"></i>
                                                                    Vai trò <span class="required">*</span>
                                                                </label>
                                                                <select id="role" name="role" class="form-control" required>
                                                                    <option value="">-- Chọn vai trò --</option>
                                                                    <c:set var="selectedRole" value="${not empty role ? role : param.role}" />
                                                                    <option value="Admin" ${selectedRole == 'Admin' ? 'selected' : ''}>Administrator</option>
                                                                    <option value="Manager" ${selectedRole == 'Manager' ? 'selected' : ''}>Quản lý</option>
                                                                    <option value="User" ${selectedRole == 'User' ? 'selected' : ''}>Người dùng</option>
                                                                    <option value="IT Support" ${selectedRole == 'IT Support' ? 'selected' : ''}>Hỗ trợ IT</option>
                                                                </select>
                                                                <small class="form-text">Chọn vai trò phù hợp cho user</small>
                                                            </div>
                                                        </div>
                                                    </div>

                                                    <!-- Thông tin bổ sung -->
                                                    <div class="section-title">
                                                        <i class="feather icon-info"></i>
                                                        Thông tin bổ sung
                                                    </div>

                                                    <div class="row">
                                                        <div class="col-md-6">
                                                            <div class="form-group">
                                                                <label for="departmentId">
                                                                    <i class="fas fa-building"></i>
                                                                    Phòng ban
                                                                </label>
                                                                <select id="departmentId" name="departmentId" class="form-control">
                                                                    <option value="">-- Không chọn --</option>
                                                                    <c:forEach var="d" items="${departments}">
                                                                        <option value="${d.id}" ${param.departmentId == d.id ? 'selected' : ''}>${d.name}</option>
                                                                    </c:forEach>
                                                                </select>
                                                                <small class="form-text">Chọn phòng ban (tùy chọn)</small>
                                                            </div>
                                                        </div>
                                                        <div class="col-md-6">
                                                            <div class="form-group">
                                                                <label for="locationId">
                                                                    <i class="fas fa-map-marker-alt"></i>
                                                                    Địa điểm
                                                                </label>
                                                                <select id="locationId" name="locationId" class="form-control">
                                                                    <option value="">-- Không chọn --</option>
                                                                    <c:forEach var="loc" items="${locations}">
                                                                        <option value="${loc.id}" ${param.locationId == loc.id ? 'selected' : ''}>${loc.name}</option>
                                                                    </c:forEach>
                                                                </select>
                                                                <small class="form-text">Chọn địa điểm (tùy chọn)</small>
                                                            </div>
                                                        </div>
                                                    </div>

                                                    <!-- Form Actions -->
                                                    <div class="form-actions">
                                                        <button type="submit" class="btn btn-primary" id="submitBtn">
                                                            <i class="feather icon-save"></i>
                                                            Tạo User
                                                        </button>
                                                        <a href="UserManagement" class="btn btn-secondary">
                                                            <i class="feather icon-users"></i>
                                                            Xem danh sách
                                                        </a>
                                                        <a href="AdminDashboard.jsp" class="btn btn-secondary">
                                                            <i class="feather icon-x"></i>
                                                            Hủy bỏ
                                                        </a>
                                                    </div>
                                                </form>
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
    <!-- [ Main Content ] end -->

    <!-- Required Js -->
    <script src="assets/js/vendor-all.min.js"></script>
    <script src="assets/plugins/bootstrap/js/bootstrap.min.js"></script>
    <script src="assets/js/pcoded.min.js"></script>
    
    <script>
        // Password strength indicator
        document.getElementById('password').addEventListener('input', function(e) {
            const password = e.target.value;
            const strengthBar = document.getElementById('passwordStrength');
            let strength = 0;
            
            if (password.length >= 6) strength += 25;
            if (/[A-Z]/.test(password)) strength += 25;
            if (/[0-9]/.test(password)) strength += 25;
            if (/[^A-Za-z0-9]/.test(password)) strength += 25;
            
            strengthBar.style.width = strength + '%';
            
            if (strength < 50) {
                strengthBar.style.backgroundColor = '#ef4444'; // Red
            } else if (strength < 75) {
                strengthBar.style.backgroundColor = '#f59e0b'; // Yellow
            } else {
                strengthBar.style.backgroundColor = '#10b981'; // Green
            }
        });
        
        // Form validation and loading overlay
        document.getElementById('createUserForm').addEventListener('submit', function(e) {
            const form = this;
            const submitBtn = document.getElementById('submitBtn');
            const loadingOverlay = document.querySelector('.loading-overlay');
            
            // Basic validation
            const requiredFields = form.querySelectorAll('[required]');
            let isValid = true;
            
            requiredFields.forEach(field => {
                if (!field.value.trim()) {
                    isValid = false;
                    field.style.borderColor = '#ef4444';
                } else {
                    field.style.borderColor = '#e2e8f0';
                }
            });
            
            if (!isValid) {
                e.preventDefault();
                alert('Vui lòng điền đầy đủ các trường bắt buộc!');
                return;
            }
            
            // Email validation
            const emailField = document.getElementById('email');
            const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
            if (!emailRegex.test(emailField.value)) {
                e.preventDefault();
                emailField.style.borderColor = '#ef4444';
                alert('Email không hợp lệ!');
                return;
            }
            
            // Password length validation
            const passwordField = document.getElementById('password');
            if (passwordField.value.length < 6) {
                e.preventDefault();
                passwordField.style.borderColor = '#ef4444';
                alert('Mật khẩu phải có ít nhất 6 ký tự!');
                return;
            }
            
            // Show loading overlay
            loadingOverlay.style.display = 'flex';
            submitBtn.disabled = true;
            submitBtn.innerHTML = '<i class="fas fa-spinner fa-spin"></i> Đang xử lý...';
        });
        
        // Real-time validation
        document.querySelectorAll('input, select').forEach(field => {
            field.addEventListener('blur', function() {
                if (this.hasAttribute('required') && !this.value.trim()) {
                    this.style.borderColor = '#ef4444';
                } else {
                    this.style.borderColor = '#e2e8f0';
                }
            });
        });
        
        // Auto-hide alerts after 5 seconds
        setTimeout(() => {
            document.querySelectorAll('.alert').forEach(alert => {
                alert.style.opacity = '0';
                alert.style.transition = 'opacity 0.5s ease';
                setTimeout(() => alert.remove(), 500);
            });
        }, 5000);
        
        // Remove upgrade buttons
        function removeUpgradeButtons() {
            const elements = document.querySelectorAll('a, button, .btn');
            elements.forEach(el => {
                const text = (el.textContent || el.innerText || '').trim();
                if (text.includes('Upgrade To Pro') || 
                    text.includes('Upgrade') && text.includes('Pro')) {
                    el.remove();
                }
            });
        }
        
        // Initial cleanup
        removeUpgradeButtons();
        
        // Observer for dynamically added elements
        const observer = new MutationObserver(removeUpgradeButtons);
        observer.observe(document.body, { childList: true, subtree: true });
        
        // Periodic cleanup
        setInterval(removeUpgradeButtons, 1000);
        
        // Tooltip initialization
        $(function () {
            $('[data-toggle="tooltip"]').tooltip()
        });
    </script>
</body>

</html>