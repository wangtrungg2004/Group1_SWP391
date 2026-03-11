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
        <title>My Requests - ITServiceFlow</title>

        <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/fonts/fontawesome/css/fontawesome-all.min.css">
        <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/plugins/bootstrap/css/bootstrap.min.css">
        <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/style.css">

        <style>
            .kpi-card {
                background: #fff;
                border-radius: 6px;
                padding: 15px 20px;
                border: 1px solid #dfe1e6;
                border-left: 4px solid #0052cc;
                display: flex;
                align-items: center;
                justify-content: space-between;
                margin-bottom: 20px;
                box-shadow: 0 1px 3px rgba(0,0,0,0.02);
            }
            .kpi-card.kpi-warning {
                border-left-color: #ff8b00;
            }
            .kpi-card.kpi-danger {
                border-left-color: #ff5630;
            }
            .kpi-card.kpi-success {
                border-left-color: #00875a;
            }
            .kpi-info h6 {
                color: #5e6c84;
                font-size: 0.8rem;
                text-transform: uppercase;
                font-weight: 700;
                margin-bottom: 5px;
                letter-spacing: 0.5px;
            }
            .kpi-info h3 {
                color: #172b4d;
                font-size: 1.5rem;
                font-weight: 700;
                margin: 0;
            }
            .kpi-icon {
                font-size: 2rem;
                color: #dfe1e6;
                opacity: 0.8;
            }

            .filter-toolbar {
                background: #f4f5f7;
                padding: 15px;
                border-radius: 6px;
                margin-bottom: 20px;
                display: flex;
                gap: 15px;
                align-items: center;
                flex-wrap: wrap;
                border: 1px solid #dfe1e6;
            }
            .filter-toolbar .form-control {
                border: 1px solid #c1c7d0;
                height: 38px;
            }

            .jira-table {
                border-collapse: separate;
                border-spacing: 0;
                width: 100%;
                border: 1px solid #dfe1e6;
                border-radius: 6px;
                overflow: hidden;
            }
            .jira-table thead {
                background-color: #f4f5f7;
            }
            .jira-table th {
                color: #5e6c84;
                font-size: 0.8rem;
                font-weight: 600;
                text-transform: uppercase;
                padding: 12px 16px;
                border-bottom: 1px solid #dfe1e6;
            }
            .jira-table td {
                padding: 12px 16px;
                vertical-align: middle;
                border-bottom: 1px solid #dfe1e6;
                color: #172b4d;
                background: #fff;
            }
            .jira-table tr:last-child td {
                border-bottom: none;
            }
            .jira-table tr:hover td {
                background-color: #fafbfc;
                cursor: pointer;
            }

            .ticket-key {
                font-weight: 600;
                color: #0052cc;
                font-size: 0.9rem;
                text-decoration: none;
            }
            .ticket-key:hover {
                text-decoration: underline;
            }
            .ticket-summary {
                font-weight: 600;
                font-size: 0.95rem;
                display: block;
                margin-bottom: 4px;
                color: #172b4d;
            }
            .ticket-category {
                font-size: 0.75rem;
                color: #6b778c;
                background: #ebecf0;
                padding: 2px 6px;
                border-radius: 3px;
            }

            .type-icon {
                font-size: 1.1rem;
                vertical-align: text-bottom;
            }
            .icon-incident {
                color: #ff5630;
            }
            .icon-request {
                color: #0052cc;
            }

            .prio-medium {
                color: #ff8b00;
            }

            .avatar-group {
                display: flex;
                align-items: center;
            }
            .avatar-sm {
                width: 26px;
                height: 26px;
                border-radius: 50%;
                background-color: #0052cc;
                color: white;
                display: inline-flex;
                align-items: center;
                justify-content: center;
                font-size: 0.7rem;
                font-weight: bold;
                margin-right: 8px;
                flex-shrink: 0;
            }
            .avatar-unassigned {
                background-color: #fff;
                color: #7a869a;
                border: 1px dashed #7a869a;
            }

            .jira-badge {
                display: inline-block;
                padding: 3px 8px;
                border-radius: 3px;
                font-size: 0.75rem;
                font-weight: 700;
                text-transform: uppercase;
                letter-spacing: 0.3px;
            }
            .badge-new {
                background-color: #e9f2ff;
                color: #0052cc;
            }
            .badge-progress {
                background-color: #fff0b3;
                color: #ff8b00;
            }
            .badge-resolved {
                background-color: #e3fcef;
                color: #00875a;
            }
            .badge-closed {
                background-color: #dfe1e6;
                color: #42526e;
            }

            .btn-action {
                width: 32px;
                height: 32px;
                padding: 0;
                display: inline-flex;
                align-items: center;
                justify-content: center;
                border-radius: 4px;
                color: #5e6c84;
                background: transparent;
                border: 1px solid transparent;
                transition: all 0.2s;
            }
            .btn-action:hover {
                background: #ebecf0;
                color: #172b4d;
                border-color: #dfe1e6;
            }

            /* Styling cho phân trang */
            .pagination {
                display: flex;
                justify-content: flex-end;
                margin-top: 20px;
            }
            .page-item .page-link {
                color: #5e6c84;
                border: 1px solid #dfe1e6;
                margin: 0 3px;
                border-radius: 4px;
                padding: 6px 12px;
            }
            .page-item.active .page-link {
                background-color: #0052cc;
                border-color: #0052cc;
                color: white;
            }
            .page-item.disabled .page-link {
                color: #c1c7d0;
                pointer-events: none;
                background-color: #fafbfc;
            }
            .page-link:hover {
                background-color: #ebecf0;
                color: #172b4d;
            }

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
                                            <h5 class="m-b-10">Service Desk Portal</h5>
                                        </div>
                                        <ul class="breadcrumb">
                                            <li class="breadcrumb-item"><a href="${pageContext.request.contextPath}/UserDashboard"><i class="feather icon-home"></i> Dashboard</a></li>
                                            <li class="breadcrumb-item"><a href="#!">My Requests</a></li>
                                        </ul>
                                    </div>
                                </div>
                            </div>
                        </div>

                        <div class="main-body">
                            <div class="page-wrapper">

                                <div class="row mb-2">
                                    <div class="col-md-3 col-sm-6">
                                        <div class="kpi-card">
                                            <div class="kpi-info">
                                                <h6>Open Requests</h6>
                                                <h3>${not empty kpis.open ? kpis.open : 0}</h3>
                                            </div>
                                            <i class="feather icon-folder kpi-icon"></i>
                                        </div>
                                    </div>
                                    <div class="col-md-3 col-sm-6">
                                        <div class="kpi-card kpi-warning">
                                            <div class="kpi-info">
                                                <h6>In Progress</h6>
                                                <h3>${not empty kpis.inProgress ? kpis.inProgress : 0}</h3>
                                            </div>
                                            <i class="feather icon-loader kpi-icon text-warning"></i>
                                        </div>
                                    </div>
                                    <div class="col-md-3 col-sm-6">
                                        <div class="kpi-card kpi-danger">
                                            <div class="kpi-info">
                                                <h6>Pending User</h6>
                                                <h3>${not empty kpis.awaiting ? kpis.awaiting : 0}</h3>
                                            </div>
                                            <i class="feather icon-alert-circle kpi-icon text-danger"></i>
                                        </div>
                                    </div>
                                    <div class="col-md-3 col-sm-6">
                                        <div class="kpi-card kpi-success">
                                            <div class="kpi-info">
                                                <h6>Resolved (Last 7d)</h6>
                                                <h3>${not empty kpis.resolved7d ? kpis.resolved7d : 0}</h3>
                                            </div>
                                            <i class="feather icon-check-circle kpi-icon text-success"></i>
                                        </div>
                                    </div>
                                </div>

                                <div class="row">
                                    <div class="col-12"> 
                                        <div class="card shadow-sm border-0">
                                            <div class="card-body p-4">

                                                <div class="d-flex justify-content-between align-items-center mb-3">
                                                    <h4 class="m-0 font-weight-bold text-dark">Ticket Directory</h4>
                                                    <a href="${pageContext.request.contextPath}/CreateTicket" class="btn btn-primary shadow-sm font-weight-bold">
                                                        <i class="feather icon-plus mr-1"></i> Create Request
                                                    </a>
                                                </div>

                                                <div class="filter-toolbar">
                                                    <form action="${pageContext.request.contextPath}/Tickets" method="GET" class="filter-toolbar">
                                                        <div class="input-group" style="max-width: 350px; flex: 1;">
                                                            <div class="input-group-prepend">
                                                                <span class="input-group-text bg-white border-right-0"><i class="feather icon-search"></i></span>
                                                            </div>
                                                            <input type="text" name="search" value="${search}" class="form-control border-left-0" placeholder="Search key, summary...">
                                                            <div class="input-group-append">
                                                                <button type="submit" class="btn btn-primary px-3" title="Click to search">
                                                                    <i class="feather icon-search mr-1"></i> Search
                                                                </button>
                                                            </div>
                                                        </div>

                                                        <div class="d-flex align-items-center gap-2">
                                                            <select name="status" class="form-control" style="width: 160px;">
                                                                <option value="all" ${selectedStatus == 'all' ? 'selected' : ''}>All Statuses</option>
                                                                <option value="New" ${selectedStatus == 'New' ? 'selected' : ''}>Pending / New</option>
                                                                <option value="In Progress" ${selectedStatus == 'In Progress' ? 'selected' : ''}>In Progress</option>
                                                                <option value="Resolved" ${selectedStatus == 'Resolved' ? 'selected' : ''}>Resolved</option>
                                                                <option value="Closed" ${selectedStatus == 'Closed' ? 'selected' : ''}>Closed</option>
                                                            </select>

                                                            <select name="type" class="form-control" style="width: 160px;">
                                                                <option value="all" ${selectedType == 'all' ? 'selected' : ''}>All Types</option>
                                                                <option value="Incident" ${selectedType == 'Incident' ? 'selected' : ''}>Incidents</option>
                                                                <option value="ServiceRequest" ${selectedType == 'ServiceRequest' ? 'selected' : ''}>Service Requests</option>
                                                            </select>

                                                            <button type="submit" class="btn btn-secondary shadow-sm">
                                                                <i class="feather icon-filter mr-1"></i> Apply Filter
                                                            </button>
                                                        </div>

                                                        <c:if test="${not empty search or selectedStatus != 'all' or selectedType != 'all'}">
                                                            <a href="${pageContext.request.contextPath}/Tickets" class="btn btn-link text-muted font-weight-bold" style="text-decoration: none;">
                                                                <i class="feather icon-rotate-ccw mr-1"></i> Reset
                                                            </a>
                                                        </c:if>
                                                    </form>

                                                    <div class="table-responsive">
                                                        <table class="jira-table" id="ticketTable">
                                                            <thead>
                                                                <tr>
                                                                    <th width="5%" class="text-center">T</th>
                                                                    <th width="12%">Key</th>
                                                                    <th width="33%">Summary</th>
                                                                    <th width="10%">Priority</th>
                                                                    <th width="15%">Assignee</th>
                                                                    <th width="10%">Status</th>
                                                                    <th width="10%">Created</th>
                                                                    <th width="5%" class="text-center">Action</th>
                                                                </tr>
                                                            </thead>
                                                            <tbody>
                                                                <c:if test="${empty myTicketList}">
                                                                    <tr>
                                                                        <td colspan="8" class="text-center text-muted py-5">
                                                                            <div class="mb-3"><i class="feather icon-inbox d-block" style="font-size: 3rem; color: #dfe1e6;"></i></div>
                                                                            <h6 class="font-weight-bold text-dark">No tickets found</h6>
                                                                            <p class="mb-0">You don't have any IT requests yet.</p>
                                                                        </td>
                                                                    </tr>
                                                                </c:if>

                                                                <c:forEach items="${myTicketList}" var="ticket">
                                                                    <tr class="ticket-row" data-status="${ticket.status}" data-type="${ticket.ticketType}">
                                                                        <td class="text-center">
                                                                            <c:choose>
                                                                                <c:when test="${ticket.ticketType == 'Incident'}"><i class="feather icon-alert-octagon type-icon icon-incident" title="Incident"></i></c:when>
                                                                                <c:otherwise><i class="feather icon-monitor type-icon icon-request" title="Service Request"></i></c:otherwise>
                                                                            </c:choose>
                                                                        </td>

                                                                        <td><a href="${pageContext.request.contextPath}/TicketDetailUser?id=${ticket.id}" class="ticket-key">${ticket.ticketNumber}</a></td>

                                                                        <td>
                                                                            <span class="ticket-summary">${ticket.title}</span>
                                                                            <span class="ticket-category"><i class="feather icon-tag mr-1"></i> ${ticket.ticketType == 'Incident' ? 'Hardware / Software Issue' : 'Access / Provisioning'}</span>
                                                                        </td>

                                                                        <td>
                                                                            <c:choose>
                                                                                <c:when test="${ticket.priorityLevel == 'Critical' || ticket.priorityLevel == 'High'}"><i class="feather icon-arrow-up prio-high"></i> ${ticket.priorityLevel}</c:when>
                                                                                <c:when test="${ticket.priorityLevel == 'Low'}"><i class="feather icon-arrow-down prio-low"></i> ${ticket.priorityLevel}</c:when>
                                                                                <c:when test="${ticket.priorityLevel == 'Medium'}"><i class="feather icon-minus prio-medium"></i> ${ticket.priorityLevel}</c:when>
                                                                                <c:otherwise><span class="text-muted">Not to be rated</span></c:otherwise>
                                                                            </c:choose>
                                                                        </td>

                                                                        <td>
                                                                            <div class="avatar-group">
                                                                                <c:choose>
                                                                                    <c:when test="${not empty ticket.assigneeName}">
                                                                                        <div class="avatar-sm">${ticket.assigneeName.substring(0, 2).toUpperCase()}</div> 
                                                                                        <span style="font-size: 0.85rem;">${ticket.assigneeName}</span>
                                                                                    </c:when>
                                                                                    <c:otherwise>
                                                                                        <div class="avatar-sm avatar-unassigned"><i class="feather icon-user-x"></i></div> 
                                                                                        <span class="text-muted" style="font-size: 0.85rem;">Unassigned</span>
                                                                                    </c:otherwise>
                                                                                </c:choose>
                                                                            </div>
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

                                                                        <td><span class="text-dark" style="font-size: 0.9rem;"><fmt:formatDate value="${ticket.createdAt}" pattern="dd/MM/yyyy"/></span></td>

                                                                        <td class="text-center">
                                                                            <a href="${pageContext.request.contextPath}/TicketDetailUser?id=${ticket.id}" class="btn-action" title="View Details">
                                                                                <i class="feather icon-external-link"></i>
                                                                            </a>
                                                                        </td>
                                                                    </tr>
                                                                </c:forEach>
                                                            </tbody>
                                                        </table>
                                                        <nav aria-label="Page navigation" class="mt-4">
                                                            <ul class="pagination justify-content-center">
                                                                <li class="page-item ${currentPage == 1 ? 'disabled' : ''}">
                                                                    <a class="page-link" href="?page=${currentPage - 1}&search=${search}">Previous</a>
                                                                </li>

                                                                <c:forEach begin="1" end="${totalPages}" var="i">
                                                                    <li class="page-item ${currentPage == i ? 'active' : ''}">
                                                                        <a class="page-link" href="?page=${i}&search=${search}">${i}</a>
                                                                    </li>
                                                                </c:forEach>

                                                                <li class="page-item ${currentPage == totalPages ? 'disabled' : ''}">
                                                                    <a class="page-link" href="?page=${currentPage + 1}&search=${search}">Next</a>
                                                                </li>
                                                            </ul>
                                                        </nav>

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