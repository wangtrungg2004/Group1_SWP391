<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<%@ taglib uri="jakarta.tags.fmt" prefix="fmt" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <title>Duyệt Yêu cầu Thay đổi - ITServiceFlow</title>
    <link rel="stylesheet" href="assets/plugins/bootstrap/css/bootstrap.min.css">
    <link rel="stylesheet" href="assets/css/style.css">
    <style>
        .action-form { display: inline-flex; align-items: center; gap: 8px; flex-wrap: wrap; }
        .action-form textarea { width: 180px; height: 60px; resize: vertical; font-size: 0.875rem; }
        .action-form button { white-space: nowrap; }
        .status-badge { font-size: 0.9rem; padding: 0.4em 0.8em; }
        .table th, .table td { vertical-align: middle; }
    </style>
</head>
<body>
    <jsp:include page="includes/sidebar.jsp"/>
    <jsp:include page="includes/header.jsp"/>

    <div class="pcoded-main-container">
        <div class="pcoded-content">
            <!-- Breadcrumb -->
            <div class="page-header">
                <div class="page-block">
                    <div class="row align-items-center">
                        <div class="col-md-12">
                            <div class="page-header-title">
                                <h5 class="m-b-10">Duyệt Yêu cầu Thay đổi</h5>
                            </div>
                            <ul class="breadcrumb">
                                <li class="breadcrumb-item"><a href="ManagerDashboard.jsp"><i class="feather icon-home"></i></a></li>
                                <li class="breadcrumb-item"><a href="#!">Quản lý Thay đổi</a></li>
                                <li class="breadcrumb-item active">Duyệt Yêu cầu</li>
                            </ul>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Tabs -->
            <ul class="nav nav-tabs mb-4">
                <li class="nav-item">
                    <a class="nav-link ${tab == 'pending' || tab == null ? 'active' : ''}" href="?tab=pending">Chờ duyệt</a>
                </li>
                <li class="nav-item">
                    <a class="nav-link ${tab == 'all' ? 'active' : ''}" href="?tab=all">Tất cả yêu cầu</a>
                </li>
            </ul>

            <!-- Thông báo -->
            <c:if test="${not empty success}">
                <div class="alert alert-success alert-dismissible fade show" role="alert">
                    ${success}
                    <button type="button" class="close" data-dismiss="alert" aria-label="Close">
                        <span aria-hidden="true">&times;</span>
                    </button>
                </div>
            </c:if>
            <c:if test="${not empty error}">
                <div class="alert alert-danger alert-dismissible fade show" role="alert">
                    ${error}
                    <button type="button" class="close" data-dismiss="alert" aria-label="Close">
                        <span aria-hidden="true">&times;</span>
                    </button>
                </div>
            </c:if>

            <!-- Bảng danh sách -->
            <div class="card">
                <div class="card-header">
                    <h5 class="mb-0">Danh sách yêu cầu thay đổi</h5>
                </div>
                <div class="card-body">
                    <div class="table-responsive">
                        <table class="table table-hover table-bordered">
                            <thead class="thead-light">
                                <tr>
                                    <th>Ticket #</th>
                                    <th>Tiêu đề</th>
                                    <th>Loại thay đổi</th>
                                    <th>Rủi ro</th>
                                    <th>Trạng thái</th>
                                    <th>Người tạo</th>
                                    <th>Ngày tạo</th>
                                    <th>Hành động</th>
                                </tr>
                            </thead>
                            <tbody>
                                <c:forEach var="req" items="${requests}">
                                    <tr>
                                        <td>${req.ticketNumber}</td>
                                        <td>${req.title}</td>
                                        <td>${req.changeType}</td>
                                        <td>
                                            <span class="badge badge-${req.riskLevel == 'Critical' ? 'danger' : req.riskLevel == 'High' ? 'warning' : req.riskLevel == 'Medium' ? 'info' : 'success'}">
                                                ${req.riskLevel}
                                            </span>
                                        </td>
                                        <td>
                                            <span class="badge status-badge badge-${req.status == 'Approved' ? 'success' : req.status == 'Rejected' ? 'danger' : req.status == 'Escalated' ? 'warning' : 'secondary'}">
                                                ${req.status}
                                            </span>
                                        </td>
                                        <td>${req.createdByName != null ? req.createdByName : 'Unknown'}</td>
                                        <td><fmt:formatDate value="${req.createdAt}" pattern="dd/MM/yyyy HH:mm"/></td>
                                        <td class="action-col">
                                            <c:if test="${req.status == 'Pending Approval'}">
                                                <div class="action-form">
                                                    <!-- Approve -->
                                                    <form action="ManagerChangeApprovals" method="post">
                                                        <input type="hidden" name="action" value="approve">
                                                        <input type="hidden" name="changeId" value="${req.id}">
                                                        <textarea name="comment" class="form-control form-control-sm" rows="2" placeholder="Ghi chú (tùy chọn)"></textarea>
                                                        <button type="submit" class="btn btn-sm btn-success" title="Chấp nhận yêu cầu">
                                                            Approve
                                                        </button>
                                                    </form>

                                                    <!-- Reject -->
                                                    <form action="ManagerChangeApprovals" method="post">
                                                        <input type="hidden" name="action" value="reject">
                                                        <input type="hidden" name="changeId" value="${req.id}">
                                                        <textarea name="comment" class="form-control form-control-sm" rows="2" placeholder="Lý do từ chối" required></textarea>
                                                        <button type="submit" class="btn btn-sm btn-danger" title="Từ chối yêu cầu">
                                                            Reject
                                                        </button>
                                                    </form>

                                                    <!-- Escalate -->
<!--                                                    <form action="ManagerChangeApprovals" method="post">
                                                        <input type="hidden" name="action" value="escalate">
                                                        <input type="hidden" name="changeId" value="${req.id}">
                                                        <textarea name="comment" class="form-control form-control-sm" rows="2" placeholder="Lý do escalate"></textarea>
                                                        <button type="submit" class="btn btn-sm btn-warning" title="Chuyển lên cấp cao hơn">
                                                            Escalate
                                                        </button>
                                                    </form>-->
                                                </div>
                                            </c:if>

                                            <!-- Nếu đã duyệt, hiển thị lịch sử ngắn gọn -->
                                            <c:if test="${req.status != 'Pending Approval'}">
                                                <small class="text-muted">Đã xử lý</small>
                                            </c:if>
                                        </td>
                                    </tr>
                                </c:forEach>
                                <c:if test="${empty requests}">
                                    <tr>
                                        <td colspan="8" class="text-center text-muted py-4">
                                            Không có yêu cầu thay đổi nào
                                        </td>
                                    </tr>
                                </c:if>
                            </tbody>
                        </table>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <!-- Script Bootstrap (nếu chưa có trong header) -->
    <script src="assets/plugins/jquery/js/jquery.min.js"></script>
    <script src="assets/plugins/bootstrap/js/bootstrap.min.js"></script>
</body>
</html>