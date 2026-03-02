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
    <title>Tickets Của Tôi - ITServiceFlow</title>

    <link rel="stylesheet" href="assets/fonts/fontawesome/css/fontawesome-all.min.css">
    <link rel="stylesheet" href="assets/plugins/bootstrap/css/bootstrap.min.css">
    <link rel="stylesheet" href="assets/css/style.css">

    <style>
        /* Table Styling */
        .jira-table { border-collapse: collapse; width: 100%; }
        .jira-table th { border-bottom: 2px solid #dfe1e6; color: #5e6c84; font-size: 0.85rem; font-weight: 600; text-transform: uppercase; padding: 12px 16px; border-top: none; }
        .jira-table td { padding: 16px; vertical-align: middle; border-bottom: 1px solid #dfe1e6; color: #172b4d; }
        .jira-table tr:hover { background-color: #f4f5f7; cursor: pointer; }
        
        /* Typography */
        .ticket-key { font-weight: 600; color: #0052cc; font-size: 0.9rem; text-decoration: none; }
        .ticket-key:hover { text-decoration: underline; }
        .ticket-summary { font-weight: 500; font-size: 0.95rem; display: block; margin-bottom: 2px; }
        .ticket-meta { font-size: 0.8rem; color: #6b778c; }
        
        /* Icons */
        .type-icon { font-size: 1.1rem; margin-right: 8px; vertical-align: text-bottom; }
        .icon-incident { color: #ff5630; } /* Đỏ cam cho Lỗi */
        .icon-request { color: #0052cc; }  /* Xanh biển cho Dịch vụ */

        /* Status Badges */
        .jira-badge { display: inline-block; padding: 2px 6px; border-radius: 3px; font-size: 0.75rem; font-weight: 700; text-transform: uppercase; letter-spacing: 0.5px; }
        .badge-new { background-color: #e9f2ff; color: #0052cc; }
        .badge-progress { background-color: #fff0b3; color: #ff8b00; }
        .badge-resolved { background-color: #e3fcef; color: #00875a; }
        .badge-closed { background-color: #dfe1e6; color: #42526e; }

        /* Tabs Customize */
        .nav-tabs-jira .nav-link { color: #5e6c84; font-weight: 500; border: none; border-bottom: 2px solid transparent; margin-bottom: -1px; padding: 10px 16px; }
        .nav-tabs-jira .nav-link:hover { color: #172b4d; border-bottom: 2px solid #c1c7d0; }
        .nav-tabs-jira .nav-link.active { color: #0052cc; border-bottom: 2px solid #0052cc; background: transparent; }
        .nav-tabs-jira { border-bottom: 2px solid #dfe1e6; margin-bottom: 20px; }
    </style>
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
                                        <h5 class="m-b-10">Trung tâm Hỗ trợ (Service Desk)</h5>
                                    </div>
                                    <ul class="breadcrumb">
                                        <li class="breadcrumb-item"><a href="UserDashboard.jsp"><i class="feather icon-home"></i></a></li>
                                        <li class="breadcrumb-item"><a href="#!">Yêu cầu của tôi</a></li>
                                    </ul>
                                </div>
                            </div>
                        </div>
                    </div>

                    <div class="main-body">
                        <div class="page-wrapper">
                            
                            <div class="row justify-content-center">
                                <div class="col-xl-11"> <div class="card shadow-sm border-0">
                                        <div class="card-body p-4">
                                            
                                            <div class="d-flex justify-content-between align-items-center mb-4">
                                                <h4 class="m-0 font-weight-bold text-dark">Tất cả yêu cầu</h4>
                                                <div class="d-flex align-items-center">
                                                    <div class="input-group mr-3" style="width: 250px;">
                                                        <div class="input-group-prepend">
                                                            <span class="input-group-text bg-white border-right-0"><i class="feather icon-search"></i></span>
                                                        </div>
                                                        <input type="text" id="searchTicket" class="form-control border-left-0 pl-0" placeholder="Tìm kiếm vé...">
                                                    </div>
                                                    <a href="${pageContext.request.contextPath}/CreateTicket" class="btn btn-primary shadow-sm">
                                                        Create Request
                                                    </a>
                                                </div>
                                            </div>

                                            <ul class="nav nav-tabs nav-tabs-jira" id="ticketTabs">
                                                <li class="nav-item">
                                                    <a class="nav-link active" href="#" data-filter="all">Tất cả</a>
                                                </li>
                                                <li class="nav-item">
                                                    <a class="nav-link" href="#" data-filter="open">Đang mở (Open)</a>
                                                </li>
                                                <li class="nav-item">
                                                    <a class="nav-link" href="#" data-filter="closed">Đã đóng (Closed)</a>
                                                </li>
                                            </ul>

                                            <div class="table-responsive">
                                                <table class="jira-table" id="ticketTable">
                                                    <thead>
                                                        <tr>
                                                            <th width="5%">Loại</th>
                                                            <th width="15%">Mã vé (Key)</th>
                                                            <th width="35%">Tiêu đề (Summary)</th>
                                                            <th width="15%">Trạng thái</th>
                                                            <th width="20%">Thời gian tạo</th>
                                                            <th width="10%">Hành động</th>
                                                        </tr>
                                                    </thead>
                                                    <tbody>
                                                        <c:if test="${empty myTicketList}">
                                                            <tr>
                                                                <td colspan="6" class="text-center text-muted py-5">
                                                                    <i class="feather icon-inbox f-30 d-block mb-2"></i>
                                                                    Chưa có yêu cầu nào được tạo.
                                                                </td>
                                                            </tr>
                                                        </c:if>
                                                        
                                                        <c:forEach items="${myTicketList}" var="ticket">
                                                            <tr class="ticket-row" data-status="${ticket.status}">
                                                                
                                                                <td class="text-center">
                                                                    <c:choose>
                                                                        <c:when test="${ticket.ticketType == 'Incident'}">
                                                                            <i class="feather icon-alert-octagon type-icon icon-incident" title="Báo lỗi"></i>
                                                                        </c:when>
                                                                        <c:otherwise>
                                                                            <i class="feather icon-monitor type-icon icon-request" title="Dịch vụ"></i>
                                                                        </c:otherwise>
                                                                    </c:choose>
                                                                </td>
                                                                
                                                                <td>
                                                                    <a href="${pageContext.request.contextPath}/TicketDetailUser?id=${ticket.id}" class="ticket-key">${ticket.ticketNumber}</a>
                                                                </td>
                                                                
                                                                <td>
                                                                    <span class="ticket-summary">${ticket.title}</span>
                                                                    <c:choose>
                                                                        <c:when test="${ticket.ticketType == 'Incident'}">
                                                                            <span class="ticket-meta">Sự cố CNTT</span>
                                                                        </c:when>
                                                                        <c:otherwise>
                                                                            <span class="ticket-meta">Yêu cầu dịch vụ</span>
                                                                        </c:otherwise>
                                                                    </c:choose>
                                                                </td>
                                                                
                                                                <td>
                                                                    <c:choose>
                                                                        <c:when test="${ticket.status == 'New'}"><span class="jira-badge badge-new">Pending</span></c:when>
                                                                        <c:when test="${ticket.status == 'In Progress'}"><span class="jira-badge badge-progress">In Progress</span></c:when>
                                                                        <c:when test="${ticket.status == 'Resolved'}"><span class="jira-badge badge-resolved">Resolved</span></c:when>
                                                                        <c:when test="${ticket.status == 'Closed'}"><span class="jira-badge badge-closed">Closed</span></c:when>
                                                                        <c:otherwise><span class="jira-badge badge-closed">${ticket.status}</span></c:otherwise>
                                                                    </c:choose>
                                                                </td>
                                                                
                                                                <td>
                                                                    <span class="d-block text-dark"><fmt:formatDate value="${ticket.createdAt}" pattern="dd/MM/yyyy"/></span>
                                                                    <span class="ticket-meta"><fmt:formatDate value="${ticket.createdAt}" pattern="HH:mm"/></span>
                                                                </td>
                                                                
                                                                <td>
                                                                    <a href="${pageContext.request.contextPath}/TicketDetailUser?id=${ticket.id}" class="btn btn-sm btn-light text-primary font-weight-bold">
                                                                        View
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

    <script>
        $(document).ready(function() {
            // 1. Chức năng Lọc theo Tabs (Tất cả / Đang mở / Đã đóng)
            $('#ticketTabs .nav-link').click(function(e) {
                e.preventDefault();
                
                // Đổi active state của tab
                $('#ticketTabs .nav-link').removeClass('active');
                $(this).addClass('active');

                var filterValue = $(this).data('filter');

                $('.ticket-row').each(function() {
                    var status = $(this).data('status');
                    
                    if (filterValue === 'all') {
                        $(this).show();
                    } else if (filterValue === 'open') {
                        // Hiện những vé chưa đóng/giải quyết
                        if (status !== 'Closed' && status !== 'Resolved') {
                            $(this).show();
                        } else {
                            $(this).hide();
                        }
                    } else if (filterValue === 'closed') {
                        // Chỉ hiện vé đã đóng/giải quyết
                        if (status === 'Closed' || status === 'Resolved') {
                            $(this).show();
                        } else {
                            $(this).hide();
                        }
                    }
                });
            });

            // 2. Chức năng Tìm kiếm theo Text
            $('#searchTicket').on('keyup', function() {
                var value = $(this).val().toLowerCase();
                
                $('.ticket-row').filter(function() {
                    // Tìm trong nội dung của dòng (Tìm theo Key hoặc Tiêu đề)
                    $(this).toggle($(this).text().toLowerCase().indexOf(value) > -1);
                });
            });
        });
    </script>
</body>
</html>