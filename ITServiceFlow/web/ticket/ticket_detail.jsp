<%-- 
    Document   : ticket_detail
    Created on : Mar 2, 2026, 2:54:40 PM
    Author     : Dumb Trung
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<%@ taglib uri="jakarta.tags.fmt" prefix="fmt" %>
<%
    if (session.getAttribute("user") == null) {
        response.sendRedirect(request.getContextPath() + "/Login.jsp");
        return;
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0, user-scalable=0, minimal-ui">
    <title>Chi tiết Yêu cầu - ITServiceFlow</title>

    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/fonts/fontawesome/css/fontawesome-all.min.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/plugins/bootstrap/css/bootstrap.min.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/style.css">

    <style>
        .ticket-header { border-bottom: 2px solid #dfe1e6; padding-bottom: 15px; margin-bottom: 20px; }
        .ticket-key { font-size: 1.1rem; color: #5e6c84; font-weight: 600; margin-bottom: 5px; display: block; }
        .ticket-title { font-size: 1.5rem; color: #172b4d; font-weight: 700; }
        
        .meta-label { color: #5e6c84; font-size: 0.85rem; font-weight: 600; text-transform: uppercase; margin-bottom: 3px; display: block; }
        .meta-value { color: #172b4d; font-size: 0.95rem; font-weight: 500; margin-bottom: 15px; }
        
        .desc-box { background-color: #f4f5f7; padding: 20px; border-radius: 5px; color: #172b4d; white-space: pre-wrap; border: 1px solid #dfe1e6; }
        
        .jira-badge { display: inline-block; padding: 4px 8px; border-radius: 4px; font-size: 0.8rem; font-weight: 700; text-transform: uppercase; }
        .badge-new { background-color: #e9f2ff; color: #0052cc; }
        .badge-progress { background-color: #fff0b3; color: #ff8b00; }
        .badge-resolved { background-color: #e3fcef; color: #00875a; }
        .badge-closed { background-color: #dfe1e6; color: #42526e; }
    </style>
</head>

<body class="">
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
                                        <h5 class="m-b-10">Chi tiết Yêu cầu</h5>
                                    </div>
                                    <ul class="breadcrumb">
                                        <li class="breadcrumb-item"><a href="${pageContext.request.contextPath}/MyTickets"><i class="feather icon-home"></i> Yêu cầu của tôi</a></li>
                                        <li class="breadcrumb-item"><a href="#!">${ticket.ticketNumber}</a></li>
                                    </ul>
                                </div>
                            </div>
                        </div>
                    </div>

                    <div class="main-body">
                        <div class="page-wrapper">
                            
                            <div class="row">
                                <div class="col-lg-8 col-xl-8">
                                    <div class="card shadow-sm">
                                        <div class="card-body">
                                            <div class="ticket-header">
                                                <span class="ticket-key">
                                                    <c:choose>
                                                        <c:when test="${ticket.ticketType == 'Incident'}"><i class="feather icon-alert-octagon text-danger"></i> Báo lỗi sự cố</c:when>
                                                        <c:otherwise><i class="feather icon-monitor text-primary"></i> Yêu cầu dịch vụ</c:otherwise>
                                                    </c:choose>
                                                    &nbsp;|&nbsp; ${ticket.ticketNumber}
                                                </span>
                                                <h1 class="ticket-title">${ticket.title}</h1>
                                            </div>

                                            <h6 class="font-weight-bold mb-3">Mô tả chi tiết:</h6>
                                            <div class="desc-box">${ticket.description}</div>
                                            
                                            <div class="mt-4">
                                                <a href="${pageContext.request.contextPath}/Tickets" class="btn btn-outline-secondary"><i class="feather icon-arrow-left"></i> Quay lại danh sách</a>
                                            </div>
                                        </div>
                                    </div>
                                </div>

                                <div class="col-lg-4 col-xl-4">
                                    <div class="card shadow-sm border-top-primary">
                                        <div class="card-body">
                                            <h6 class="font-weight-bold border-bottom pb-2 mb-3">Thông tin xử lý</h6>
                                            
                                            <span class="meta-label">Trạng thái</span>
                                            <div class="meta-value">
                                                <c:choose>
                                                    <c:when test="${ticket.status == 'New'}"><span class="jira-badge badge-new">Mới tạo (Pending)</span></c:when>
                                                    <c:when test="${ticket.status == 'In Progress'}"><span class="jira-badge badge-progress">Đang xử lý</span></c:when>
                                                    <c:when test="${ticket.status == 'Resolved'}"><span class="jira-badge badge-resolved">Đã khắc phục</span></c:when>
                                                    <c:when test="${ticket.status == 'Closed'}"><span class="jira-badge badge-closed">Đã đóng</span></c:when>
                                                    <c:otherwise><span class="jira-badge badge-closed">${ticket.status}</span></c:otherwise>
                                                </c:choose>
                                            </div>

                                            <span class="meta-label">Phân loại</span>
                                            <div class="meta-value">
                                                <c:forEach items="${categories}" var="cat">
                                                    <c:if test="${cat.id == ticket.categoryId}">${cat.name}</c:if>
                                                </c:forEach>
                                            </div>

                                            <c:if test="${ticket.ticketType == 'ServiceRequest'}">
                                                <span class="meta-label">Dịch vụ yêu cầu</span>
                                                <div class="meta-value text-primary font-weight-bold">
                                                    <c:forEach items="${services}" var="svc">
                                                        <c:if test="${svc.id == ticket.serviceCatalogId}">${svc.name}</c:if>
                                                    </c:forEach>
                                                </div>
                                            </c:if>

                                            <span class="meta-label">Thời gian tạo</span>
                                            <div class="meta-value">
                                                <fmt:formatDate value="${ticket.createdAt}" pattern="dd/MM/yyyy HH:mm"/>
                                            </div>
                                            
                                            <div class="alert alert-info mt-4 p-2 text-center" style="font-size: 0.85rem;">
                                                <i class="feather icon-info"></i> IT Support sẽ phản hồi yêu cầu của bạn trong thời gian sớm nhất.
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

    <script src="${pageContext.request.contextPath}/assets/plugins/jquery/js/jquery.min.js"></script>
    <script src="${pageContext.request.contextPath}/assets/js/vendor-all.min.js"></script>
    <script src="${pageContext.request.contextPath}/assets/plugins/bootstrap/js/bootstrap.min.js"></script>
    <script src="${pageContext.request.contextPath}/assets/js/pcoded.min.js"></script>
</body>
</html>