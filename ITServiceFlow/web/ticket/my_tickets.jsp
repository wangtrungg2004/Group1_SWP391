<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<%@ taglib uri="jakarta.tags.fmt" prefix="fmt" %>
<%
    if (session.getAttribute("user") == null) {
        response.sendRedirect("Login.jsp");
        return;
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0, user-scalable=0, minimal-ui">
    <title>Tickets Của Tôi - ITServiceFlow</title>

    <link rel="stylesheet" href="assets/fonts/fontawesome/css/fontawesome-all.min.css">
    <link rel="stylesheet" href="assets/plugins/bootstrap/css/bootstrap.min.css">
    <link rel="stylesheet" href="assets/css/style.css">
</head>

<body class="">
    <div class="loader-bg">
        <div class="loader-track"><div class="loader-fill"></div></div>
    </div>

    <jsp:include page="../includes/header.jsp" />
    <jsp:include page="../includes/sidebar.jsp" />

    <div class="pcoded-main-container">
        <div class="pcoded-wrapper">
            <div class="pcoded-content">
                <div class="pcoded-inner-content">
                    
                    <div class="page-header">
                        <div class="page-block">
                            <div class="row align-items-center">
                                <div class="col-md-12">
                                    <div class="page-header-title">
                                        <h5 class="m-b-10">Lịch sử Yêu cầu</h5>
                                    </div>
                                    <ul class="breadcrumb">
                                        <li class="breadcrumb-item"><a href="UserDashboard.jsp"><i class="feather icon-home"></i></a></li>
                                        <li class="breadcrumb-item"><a href="#!">Tickets của tôi</a></li>
                                    </ul>
                                </div>
                            </div>
                        </div>
                    </div>

                    <div class="main-body">
                        <div class="page-wrapper">
                            
                            <div class="row">
                                <div class="col-xl-12">
                                    <div class="card">
                                        <div class="card-header d-flex justify-content-between align-items-center">
                                            <h5>Danh sách Tickets đã gửi</h5>
                                            <a href="${pageContext.request.contextPath}/CreateTicket" class="btn btn-sm btn-primary">
                                                <i class="feather icon-plus"></i> Tạo Mới
                                            </a>
                                        </div>
                                        <div class="card-body table-border-style">
                                            <div class="table-responsive">
                                                <table class="table table-hover">
                                                    <thead>
                                                        <tr>
                                                            <th>Mã vé</th>
                                                            <th>Phân loại</th>
                                                            <th>Tiêu đề</th>
                                                            <th>Ngày tạo</th>
                                                            <th>Trạng thái</th>
                                                            <th>Hành động</th>
                                                        </tr>
                                                    </thead>
                                                    <tbody>
                                                        <c:if test="${empty myTicketList}">
                                                            <tr>
                                                                <td colspan="6" class="text-center text-muted">Bạn chưa tạo yêu cầu nào.</td>
                                                            </tr>
                                                        </c:if>
                                                        
                                                        <c:forEach items="${myTicketList}" var="ticket">
                                                            <tr>
                                                                <td class="font-weight-bold">${ticket.ticketNumber}</td>
                                                                <td>
                                                                    <c:choose>
                                                                        <c:when test="${ticket.ticketType == 'Incident'}">
                                                                            <span class="text-danger"><i class="feather icon-alert-triangle"></i> Báo lỗi</span>
                                                                        </c:when>
                                                                        <c:otherwise>
                                                                            <span class="text-success"><i class="feather icon-shopping-cart"></i> Dịch vụ</span>
                                                                        </c:otherwise>
                                                                    </c:choose>
                                                                </td>
                                                                <td>${ticket.title}</td>
                                                                <td><fmt:formatDate value="${ticket.createdAt}" pattern="dd/MM/yyyy HH:mm"/></td>
                                                                <td>
                                                                    <c:choose>
                                                                        <c:when test="${ticket.status == 'New'}"><span class="badge badge-primary">Mới tạo</span></c:when>
                                                                        <c:when test="${ticket.status == 'In Progress'}"><span class="badge badge-warning">Đang xử lý</span></c:when>
                                                                        <c:when test="${ticket.status == 'Resolved'}"><span class="badge badge-success">Đã khắc phục</span></c:when>
                                                                        <c:when test="${ticket.status == 'Closed'}"><span class="badge badge-secondary">Đã đóng</span></c:when>
                                                                        <c:otherwise><span class="badge badge-dark">${ticket.status}</span></c:otherwise>
                                                                    </c:choose>
                                                                </td>
                                                                <td>
                                                                    <a href="${pageContext.request.contextPath}/TicketDetailUser?id=${ticket.id}" class="btn btn-icon btn-outline-info btn-sm" title="Xem chi tiết">
                                                                        <i class="feather icon-eye"></i>
                                                                    </a>
                                                                </td>
                                                            </tr>
                                                        </c:forEach>
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
    <script src="assets/plugins/jquery/js/jquery.min.js"></script>
    <script src="assets/js/vendor-all.min.js"></script>
    <script src="assets/plugins/bootstrap/js/bootstrap.min.js"></script>
    <script src="assets/js/pcoded.min.js"></script>
</body>
</html>