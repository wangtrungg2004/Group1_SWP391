<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<%
    if (session.getAttribute("user") == null) {
        response.sendRedirect("Login.jsp");
        return;
    }
    String role = (String) session.getAttribute("role");
    if (!"Admin".equals(role)) {
        response.sendError(HttpServletResponse.SC_FORBIDDEN, "Bạn không có quyền truy cập.");
        return;
    }
%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Quản lý Địa điểm - ITServiceFlow</title>
    <link rel="icon" type="image/x-icon" href="assets/images/favicon.ico">
    <link rel="stylesheet" href="assets/plugins/bootstrap/css/bootstrap.min.css">
    <link rel="stylesheet" href="assets/fonts/feather/css/feather.css">
    <style>
        body { font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; background: #f1f5f9; padding: 24px; }
        .card { border: none; box-shadow: 0 1px 3px rgba(0,0,0,0.1); border-radius: 8px; }
        .card-header { background: #fff; border-bottom: 1px solid #e2e8f0; font-weight: 600; }
        .table th { border-top: none; color: #64748b; font-weight: 600; }
        .badge-active { background: #10b981; }
        .badge-inactive { background: #94a3b8; }
    </style>
</head>
<body>
    <div class="container-fluid">
        <div class="d-flex justify-content-between align-items-center mb-4">
            <h5 class="mb-0"><i class="feather icon-map-pin"></i> Quản lý Địa điểm</h5>
            <a href="AdminDashboard.jsp" class="btn btn-outline-primary"><i class="feather icon-arrow-left"></i> Về Dashboard</a>
        </div>
        <div class="card">
            <div class="card-header">
                Danh sách địa điểm
            </div>
            <div class="card-body p-0">
                <c:choose>
                    <c:when test="${empty locations}">
                        <div class="p-4 text-center text-muted">
                            Chưa có địa điểm nào. Chạy script <code>database/sample_locations.sql</code> để tạo dữ liệu mẫu.
                        </div>
                    </c:when>
                    <c:otherwise>
                        <table class="table table-hover mb-0">
                            <thead>
                                <tr>
                                    <th>ID</th>
                                    <th>Tên địa điểm</th>
                                    <th>Trạng thái</th>
                                </tr>
                            </thead>
                            <tbody>
                                <c:forEach var="loc" items="${locations}">
                                    <tr>
                                        <td>${loc.id}</td>
                                        <td>${loc.name}</td>
                                        <td>
                                            <span class="badge ${loc.active ? 'badge-active' : 'badge-inactive'}">${loc.active ? 'Hoạt động' : 'Tắt'}</span>
                                        </td>
                                    </tr>
                                </c:forEach>
                            </tbody>
                        </table>
                    </c:otherwise>
                </c:choose>
            </div>
        </div>
    </div>
</body>
</html>
