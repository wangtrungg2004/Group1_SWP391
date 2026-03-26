<%--
    Document   : CreateUser
    Created on : Jan 19, 2026
    Author     : recreated
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
    if (role == null || !"Admin".equals(role)) {
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
    <title>Tạo User - ITServiceFlow</title>

    <!-- Favicon -->
    <link rel="icon" type="image/x-icon" href="assets/images/favicon.ico">
    <!-- fontawesome icon -->
    <link rel="stylesheet" href="assets/fonts/fontawesome/css/fontawesome-all.min.css">
    <!-- Bootstrap CSS -->
    <link rel="stylesheet" href="assets/plugins/bootstrap/css/bootstrap.min.css">
    <!-- vendor css -->
    <link rel="stylesheet" href="assets/css/style.css">
    <!-- page css -->
    <link rel="stylesheet" href="assets/css/pages/create-user.css">
</head>
<body>
    <!-- Header -->
    <header class="navbar pcoded-header navbar-expand-lg navbar-light">
        <div class="m-r-10">
            <a href="AdminDashboard.jsp" class="b-brand" style="display:flex;align-items:center;gap:8px;">
                <img src="assets/images/logo.svg" alt="Logo" class="logo images" style="height:28px;">
                <span style="font-weight:600;color:#2d3748;">ITServiceFlow</span>
            </a>
        </div>
        <div class="ml-auto">
            <ul class="navbar-nav ml-auto">
                <li class="nav-item">
                    <div class="dropdown drp-user">
                        <a href="#" class="dropdown-toggle" data-toggle="dropdown" style="display:flex;align-items:center;gap:8px;padding:8px 12px;">
                            <img src="assets/images/user/avatar-1.jpg" class="img-radius" alt="User-Profile-Image" style="width:32px;height:32px;border-radius:50%;">
                            <span style="font-weight:500;"><%= user != null ? user.getFullName() : "Admin" %></span>
                            <i class="feather icon-chevron-down" style="font-size:12px;"></i>
                        </a>
                        <div class="dropdown-menu dropdown-menu-right profile-notification">
                            <div class="pro-head">
                                <img src="assets/images/user/avatar-1.jpg" class="img-radius" alt="User-Profile-Image">
                                <span><%= user != null ? user.getFullName() : "Admin" %></span>
                                <span style="display:block;font-size:11px;color:#999;"><%= role != null ? role : "" %></span>
                            </div>
                            <ul class="pro-body">
                                <li><a href="AdminDashboard.jsp" class="dropdown-item"><i class="feather icon-home"></i> Dashboard</a></li>
                                <li><a href="Logout" class="dropdown-item"><i class="feather icon-log-out"></i> Logout</a></li>
                            </ul>
                        </div>
                    </div>
                </li>
                <li class="nav-item">
                    <a href="Logout" class="nav-link" style="padding:8px 12px;color:#dc3545;">
                        <i class="feather icon-log-out"></i>
                    </a>
                </li>
            </ul>
        </div>
    </header>
    <!-- Header end -->

    <!-- Main Content -->
    <div class="pcoded-main-container">
        <div class="pcoded-wrapper">
            <div class="pcoded-content">
                <div class="pcoded-inner-content">
                    <div class="main-body">
                        <div class="page-wrapper">
                            <div class="container-center">
                                <div class="form-container">
                                    <div class="card">
                                        <div class="card-header">
                                            <h5>
                                                <i class="feather icon-user-plus"></i>
                                                Tạo User Mới
                                            </h5>
                                        </div>
                                        <div class="card-body">
                                            <!-- Alerts -->
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
                                                    <i class="feather icon-info"></i>
                                                    Thông tin cơ bản
                                                </div>
                                                <div class="row">
                                                    <div class="col-md-6">
                                                        <div class="form-group">
                                                            <label for="username">
                                                                <i class="fas fa-user"></i>
                                                                Username <span class="required">*</span>
                                                            </label>
                                                            <input type="text" class="form-control" id="username" name="username" placeholder="Nhập username" value="${username}" required>
                                                        </div>
                                                    </div>
                                                    <div class="col-md-6">
                                                        <div class="form-group">
                                                            <label for="email">
                                                                <i class="fas fa-envelope"></i>
                                                                Email <span class="required">*</span>
                                                            </label>
                                                            <input type="email" class="form-control" id="email" name="email" placeholder="name@example.com" value="${email}" required>
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
                                                            <input type="password" class="form-control" id="password" name="password" placeholder="Nhập mật khẩu" required>
                                                        </div>
                                                    </div>
                                                    <div class="col-md-6">
                                                        <div class="form-group">
                                                            <label for="fullName">
                                                                <i class="fas fa-id-card"></i>
                                                                Họ tên đầy đủ <span class="required">*</span>
                                                            </label>
                                                            <input type="text" class="form-control" id="fullName" name="fullName" placeholder="Nhập họ tên" value="${fullName}" required>
                                                        </div>
                                                    </div>
                                                </div>
                                                <div class="row">
                                                    <div class="col-md-6">
                                                        <div class="form-group">
                                                            <label for="role">
                                                                <i class="fas fa-user-shield"></i>
                                                                Vai trò <span class="required">*</span>
                                                            </label>
                                                            <select class="form-control" id="role" name="role" required>
                                                                <option value="">Chọn vai trò</option>
                                                                <option value="Admin" ${role == 'Admin' ? 'selected' : ''}>Admin</option>
                                                                <option value="User" ${role == 'User' ? 'selected' : ''}>User</option>
                                                                <option value="IT Support" ${role == 'IT Support' ? 'selected' : ''}>IT Support</option>
                                                            </select>
                                                        </div>
                                                    </div>
                                                </div>

                                                <!-- Thông tin bổ sung -->
                                                <div class="section-title">
                                                    <i class="feather icon-layers"></i>
                                                    Thông tin bổ sung
                                                </div>
                                                <div class="row">
                                                    <div class="col-md-6">
                                                        <div class="form-group">
                                                            <label for="departmentId">
                                                                <i class="fas fa-building"></i>
                                                                Phòng ban
                                                            </label>
                                                            <select class="form-control" id="departmentId" name="departmentId">
                                                                <option value="">-- Không chọn --</option>
                                                                <c:forEach var="d" items="${departments}">
                                                                    <option value="${d.id}" ${departmentId == d.id || param.departmentId == d.id ? 'selected' : ''}>${d.name}</option>
                                                                </c:forEach>
                                                            </select>
                                                        </div>
                                                    </div>
                                                    <div class="col-md-6">
                                                        <div class="form-group">
                                                            <label for="locationId">
                                                                <i class="fas fa-map-marker-alt"></i>
                                                                Địa điểm
                                                            </label>
                                                            <select class="form-control" id="locationId" name="locationId">
                                                                <option value="">-- Không chọn --</option>
                                                                <c:forEach var="loc" items="${locations}">
                                                                    <option value="${loc.id}" ${locationId == loc.id || param.locationId == loc.id ? 'selected' : ''}>${loc.name}</option>
                                                                </c:forEach>
                                                            </select>
                                                        </div>
                                                    </div>
                                                </div>

                                                <div class="form-actions">
                                                    <button type="submit" class="btn btn-primary">
                                                        <i class="feather icon-save"></i>
                                                        Lưu User
                                                    </button>
                                                    <a href="AdminDashboard.jsp" class="btn btn-light">
                                                        <i class="feather icon-arrow-left"></i>
                                                        Quay lại Dashboard
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
    <!-- Main Content end -->

    <!-- Scripts -->
    <script src="assets/js/vendor-all.min.js"></script>
    <script src="assets/plugins/bootstrap/js/bootstrap.min.js"></script>
    <script src="assets/js/pcoded.min.js"></script>
    <script src="assets/js/main.js"></script>
    <script>
        // Loại bỏ các nút/ảnh Upgrade To Pro (nếu có) được render từ template
        (function removeUpgradeButton() {
            var elementsToRemove = [];
            document.querySelectorAll('a, button, .btn, div, span').forEach(function(el) {
                var text = (el.textContent || el.innerText || '').trim();
                if (text.includes('Upgrade To Pro') || (text.includes('Upgrade') && text.includes('Pro'))) {
                    elementsToRemove.push(el);
                }
            });
            document.querySelectorAll('[href*=\"upgrade\"], [class*=\"upgrade\"], [id*=\"upgrade\"]').forEach(function(el) {
                var text = (el.textContent || el.innerText || '').trim();
                if (text.includes('Upgrade') || text.includes('Pro')) {
                    elementsToRemove.push(el);
                }
            });
            new Set(elementsToRemove).forEach(function(el) {
                if (el && el.parentNode) {
                    el.remove();
                }
            });
        })();
    </script>
</body>
</html>
