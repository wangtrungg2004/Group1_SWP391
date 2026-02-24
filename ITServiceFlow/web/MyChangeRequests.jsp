<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<%@ taglib uri="jakarta.tags.fmt" prefix="fmt" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <title>Yêu cầu Thay đổi của tôi - ITServiceFlow</title>
    <link rel="stylesheet" href="assets/plugins/bootstrap/css/bootstrap.min.css">
    <link rel="stylesheet" href="assets/css/style.css">
    <style>
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
                                <h5 class="m-b-10">Yêu cầu Thay đổi của tôi</h5>
                            </div>
                            <ul class="breadcrumb">
                                <li class="breadcrumb-item"><a href="ITDashboard.jsp"><i class="feather icon-home"></i></a></li>
                                <li class="breadcrumb-item active">Yêu cầu Thay đổi của tôi</li>
                            </ul>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Tabs -->
            <ul class="nav nav-tabs mb-4">
                <li class="nav-item">
                    <a class="nav-link ${tab == 'all' ? 'active' : ''}" href="?tab=all">Tất cả</a>
                </li>
                <li class="nav-item">
                    <a class="nav-link ${tab == 'Pending Approval' ? 'active' : ''}" href="?tab=Pending Approval">Chờ duyệt</a>
                </li>
                <li class="nav-item">
                    <a class="nav-link ${tab == 'Approved' ? 'active' : ''}" href="?tab=Approved">Đã duyệt</a>
                </li>
                <li class="nav-item">
                    <a class="nav-link ${tab == 'Rejected' ? 'active' : ''}" href="?tab=Rejected">Bị từ chối</a>
                </li>
                <li class="nav-item">
                    <a class="nav-link ${tab == 'Escalated' ? 'active' : ''}" href="?tab=Escalated">Đã escalate</a>
                </li>
            </ul>

            <!-- Bảng danh sách -->
            <div class="card">
                <div class="card-header">
                    <h5 class="mb-0">Danh sách yêu cầu thay đổi tôi đã gửi</h5>
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
                                    <th>Ngày tạo</th>
                                    <th>Chi tiết</th>
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
                                        <td><fmt:formatDate value="${req.createdAt}" pattern="dd/MM/yyyy HH:mm"/></td>
                                        <td>
                                            <a href="#" class="btn btn-sm btn-info" data-toggle="modal" data-target="#detailModal${req.id}">
                                                Xem chi tiết
                                            </a>
                                        </td>
                                    </tr>
                                </c:forEach>
                                <c:if test="${empty requests}">
                                    <tr>
                                        <td colspan="7" class="text-center text-muted py-4">
                                            Bạn chưa gửi yêu cầu thay đổi nào
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

    <!-- Modal chi tiết (tùy chọn, hiển thị mô tả + lịch sử duyệt) -->
    <c:forEach var="req" items="${requests}">
        <div class="modal fade" id="detailModal${req.id}" tabindex="-1" role="dialog">
            <div class="modal-dialog modal-lg" role="document">
                <div class="modal-content">
                    <div class="modal-header">
                        <h5 class="modal-title">Chi tiết yêu cầu #${req.ticketNumber}</h5>
                        <button type="button" class="close" data-dismiss="modal" aria-label="Close">
                            <span aria-hidden="true">×</span>
                        </button>
                    </div>
                    <div class="modal-body">
                        <p><strong>Tiêu đề:</strong> ${req.title}</p>
                        <p><strong>Mô tả:</strong> ${req.description}</p>
                        <p><strong>Loại thay đổi:</strong> ${req.changeType}</p>
                        <p><strong>Mức rủi ro:</strong> ${req.riskLevel}</p>
                        <p><strong>Kế hoạch rollback:</strong> ${req.rollbackPlan}</p>
                        <p><strong>Trạng thái:</strong> <span class="badge badge-${req.status == 'Approved' ? 'success' : req.status == 'Rejected' ? 'danger' : req.status == 'Escalated' ? 'warning' : 'secondary'}">${req.status}</span></p>
                        
                        <!-- Lịch sử duyệt (nếu có) -->
                        <h6>Lịch sử duyệt:</h6>
                        <c:set var="history" value="${service.getHistory(req.id)}" />
                        <c:if test="${not empty history}">
                            <ul class="list-group">
                                <c:forEach var="approval" items="${history}">
                                    <li class="list-group-item">
                                        <strong>${approval.approverName}</strong> - 
                                        <span class="badge badge-${approval.decision == 'Approved' ? 'success' : approval.decision == 'Rejected' ? 'danger' : 'warning'}">${approval.decision}</span>
                                        <br>
                                        <small><fmt:formatDate value="${approval.decidedAt}" pattern="dd/MM/yyyy HH:mm"/></small>
                                        <p class="mb-0"><strong>Ghi chú:</strong> ${approval.comment != null && !approval.comment.isEmpty() ? approval.comment : 'Không có'}</p>
                                    </li>
                                </c:forEach>
                            </ul>
                        </c:if>
                        <c:if test="${empty history}">
                            <p class="text-muted">Chưa có lịch sử duyệt</p>
                        </c:if>
                    </div>
                    <div class="modal-footer">
                        <button type="button" class="btn btn-secondary" data-dismiss="modal">Đóng</button>
                    </div>
                </div>
            </div>
        </div>
    </c:forEach>

    <script src="assets/plugins/jquery/js/jquery.min.js"></script>
    <script src="assets/plugins/bootstrap/js/bootstrap.min.js"></script>
</body>
</html>