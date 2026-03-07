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
        <title>Ticket Details - ITServiceFlow</title>

        <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/fonts/fontawesome/css/fontawesome-all.min.css">
        <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/plugins/bootstrap/css/bootstrap.min.css">
        <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/style.css">

        <style>
            .ticket-header {
                border-bottom: 2px solid #dfe1e6;
                padding-bottom: 15px;
                margin-bottom: 20px;
            }
            .ticket-key {
                font-size: 1.1rem;
                color: #5e6c84;
                font-weight: 600;
                margin-bottom: 5px;
                display: block;
            }
            .ticket-title {
                font-size: 1.5rem;
                color: #172b4d;
                font-weight: 700;
            }

            .meta-group {
                display: flex;
                flex-direction: column;
                margin-bottom: 16px;
            }
            .meta-label {
                color: #5e6c84;
                font-size: 0.85rem;
                font-weight: 600;
                text-transform: uppercase;
                margin-bottom: 4px;
                display: block;
            }
            .meta-value {
                color: #172b4d;
                font-size: 0.95rem;
                font-weight: 500;
                display: flex;
                align-items: center;
            }
            .meta-value i {
                margin-right: 8px;
                font-size: 1.1rem;
            }

            .avatar-sm {
                width: 24px;
                height: 24px;
                border-radius: 50%;
                background-color: #0052cc;
                color: white;
                display: inline-flex;
                align-items: center;
                justify-content: center;
                font-size: 0.7rem;
                font-weight: bold;
                margin-right: 8px;
            }
            .avatar-unassigned {
                background-color: #dfe1e6;
                color: #42526e;
                border: 1px dashed #7a869a;
            }

            .section-title {
                font-size: 1.1rem;
                font-weight: 700;
                color: #172b4d;
                margin-bottom: 15px;
                display: flex;
                align-items: center;
            }
            .section-title i {
                margin-right: 8px;
                color: #5e6c84;
            }
            .desc-box {
                background-color: #f4f5f7;
                padding: 20px;
                border-radius: 5px;
                color: #172b4d;
                white-space: pre-wrap;
                border: 1px solid #dfe1e6;
                margin-bottom: 30px;
                font-size: 0.95rem;
                line-height: 1.6;
            }

            .attachment-card {
                border: 1px solid #dfe1e6;
                border-radius: 4px;
                padding: 10px;
                display: inline-flex;
                align-items: center;
                margin-right: 10px;
                margin-bottom: 10px;
                background: white;
                transition: all 0.2s;
                text-decoration: none !important;
            }
            .attachment-icon {
                font-size: 2rem;
                color: #ff5630;
                margin-right: 10px;
            }
            .attachment-details {
                display: flex;
                flex-direction: column;
            }
            .attachment-name {
                font-size: 0.85rem;
                font-weight: 600;
                color: #172b4d;
            }
            .attachment-size {
                font-size: 0.75rem;
                color: #5e6c84;
            }

            .comment-thread {
                margin-top: 20px;
                border-top: 2px solid #dfe1e6;
                padding-top: 20px;
            }
            .comment-box {
                display: flex;
                margin-bottom: 20px;
            }
            .comment-avatar {
                width: 35px;
                height: 35px;
                border-radius: 50%;
                background-color: #ff8b00;
                color: white;
                display: flex;
                align-items: center;
                justify-content: center;
                font-weight: bold;
                margin-right: 15px;
                flex-shrink: 0;
            }
            .comment-content {
                background: #fff;
                border: 1px solid #dfe1e6;
                border-radius: 4px;
                padding: 15px;
                width: 100%;
                position: relative;
            }
            .comment-author {
                font-weight: 700;
                color: #172b4d;
                font-size: 0.9rem;
                margin-bottom: 5px;
            }
            .comment-time {
                color: #5e6c84;
                font-size: 0.8rem;
                font-weight: normal;
                margin-left: 10px;
            }
            .comment-text {
                font-size: 0.9rem;
                color: #172b4d;
                margin: 0;
            }

            .jira-badge {
                display: inline-block;
                padding: 4px 8px;
                border-radius: 4px;
                font-size: 0.8rem;
                font-weight: 700;
                text-transform: uppercase;
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

            .prio-medium {
                color: #ff8b00;
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
                                            <h5 class="m-b-10">Ticket Information</h5>
                                        </div>
                                        <ul class="breadcrumb">
                                            <li class="breadcrumb-item"><a href="${pageContext.request.contextPath}/Tickets"><i class="feather icon-list"></i> My Requests</a></li>
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
                                            <div class="card-body p-4">

                                                <div class="ticket-header">
                                                    <span class="ticket-key">
                                                        <c:choose>
                                                            <c:when test="${ticket.ticketType == 'Incident'}"><i class="feather icon-alert-octagon text-danger"></i> IT Incident</c:when>
                                                            <c:otherwise><i class="feather icon-monitor text-primary"></i> Service Request</c:otherwise>
                                                        </c:choose>
                                                        &nbsp;|&nbsp; ${ticket.ticketNumber}
                                                    </span>
                                                    <h1 class="ticket-title">${ticket.title}</h1>
                                                </div>

                                                <h6 class="section-title"><i class="feather icon-align-left"></i> Description</h6>
                                                <div class="desc-box"><c:out value="${ticket.description}" default="No description provided by the user."/></div>

                                                <h6 class="section-title"><i class="feather icon-paperclip"></i> Attachments</h6>
                                                <div class="mb-4">
                                                    <span class="text-muted" style="font-size: 0.9rem; font-style: italic;">No files attached to this request.</span>
                                                </div>

                                                <div class="comment-thread">
                                                    <h6 class="section-title"><i class="feather icon-message-square"></i> Activity Log</h6>

                                                    <div class="text-center mb-4">
                                                        <span class="badge badge-light text-muted border px-3 py-1">
                                                            Ticket created on <fmt:formatDate value="${ticket.createdAt}" pattern="MMM dd, yyyy HH:mm"/>
                                                        </span>
                                                    </div>

                                                    <div class="comment-box">
                                                        <div class="comment-avatar"><i class="feather icon-user"></i></div>
                                                        <div class="comment-content shadow-sm">
                                                            <div class="comment-author">System Admin <span class="comment-time">Just now</span></div>
                                                            <p class="comment-text">Hello, we have received your request. An IT agent will be assigned to review this shortly. Thank you!</p>
                                                        </div>
                                                    </div>
                                                </div>

                                                <div class="mt-4 pt-3 border-top">
                                                    <a href="${pageContext.request.contextPath}/Tickets" class="btn btn-outline-secondary font-weight-bold">
                                                        <i class="feather icon-arrow-left"></i> Back to List
                                                    </a>
                                                </div>
                                            </div>
                                        </div>
                                    </div>

                                    <div class="col-lg-4 col-xl-4">
                                        <div class="card shadow-sm border-top-primary">
                                            <div class="card-body p-4">
                                                <h6 class="font-weight-bold border-bottom pb-3 mb-4 text-uppercase" style="letter-spacing: 0.5px; color: #5e6c84;">Details</h6>

                                                <div class="meta-group">
                                                    <span class="meta-label">Status</span>
                                                    <div class="meta-value">
                                                        <c:choose>
                                                            <c:when test="${ticket.status == 'New'}"><span class="jira-badge badge-new">Pending</span></c:when>
                                                            <c:when test="${ticket.status == 'In Progress'}"><span class="jira-badge badge-progress">In Progress</span></c:when>
                                                            <c:when test="${ticket.status == 'Resolved'}"><span class="jira-badge badge-resolved">Resolved</span></c:when>
                                                            <c:when test="${ticket.status == 'Closed'}"><span class="jira-badge badge-closed">Closed</span></c:when>
                                                            <c:otherwise><span class="jira-badge badge-closed">${ticket.status}</span></c:otherwise>
                                                        </c:choose>
                                                    </div>
                                                </div>

                                                <div class="meta-group">
                                                    <span class="meta-label">Priority</span>
                                                    <div class="meta-value">
                                                        <c:choose>
                                                            <c:when test="${ticket.priorityLevel == 'Critical' || ticket.priorityLevel == 'High'}"><i class="feather icon-arrow-up prio-high"></i> ${ticket.priorityLevel}</c:when>
                                                            <c:when test="${ticket.priorityLevel == 'Low'}"><i class="feather icon-arrow-down prio-low"></i> ${ticket.priorityLevel}</c:when>
                                                            <c:when test="${ticket.priorityLevel == 'Medium'}"><i class="feather icon-minus prio-medium"></i> ${ticket.priorityLevel}</c:when>
                                                            <c:otherwise><span class="text-muted">Chưa xếp loại</span></c:otherwise>
                                                        </c:choose>
                                                    </div>
                                                </div>

                                                <div class="meta-group">
                                                    <span class="meta-label">Category</span>
                                                    <div class="meta-value text-dark">
                                                        ${not empty ticket.categoryName ? ticket.categoryName : 'Uncategorized'}
                                                    </div>
                                                </div>

                                                <c:if test="${ticket.ticketType != 'Incident'}">
                                                    <div class="meta-group">
                                                        <span class="meta-label">Requested Service</span>
                                                        <div class="meta-value text-primary font-weight-bold">
                                                            ${not empty ticket.serviceName ? ticket.serviceName : 'N/A'}
                                                        </div>
                                                    </div>
                                                </c:if>

                                                <div class="meta-group">
                                                    <span class="meta-label">Assignee</span>
                                                    <div class="meta-value">
                                                        <c:choose>
                                                            <c:when test="${not empty ticket.assigneeName}">
                                                                <div class="avatar-sm">${ticket.assigneeName.substring(0, 2).toUpperCase()}</div> ${ticket.assigneeName}
                                                            </c:when>
                                                            <c:otherwise>
                                                                <div class="avatar-sm avatar-unassigned"><i class="feather icon-user-x"></i></div> <span class="text-muted">Unassigned</span>
                                                                </c:otherwise>
                                                            </c:choose>
                                                    </div>
                                                </div>

                                                <div class="meta-group">
                                                    <span class="meta-label">Reporter</span>
                                                    <div class="meta-value">
                                                        <div class="avatar-sm" style="background-color: #00875a;">ME</div> 
                                                        You (${sessionScope.user.fullName})
                                                    </div>
                                                </div>

                                                <h6 class="font-weight-bold border-bottom pb-2 mt-4 mb-3 text-uppercase" style="letter-spacing: 0.5px; color: #5e6c84;">Dates</h6>

                                                <div class="meta-group">
                                                    <span class="meta-label">Created</span>
                                                    <div class="meta-value" style="font-size: 0.85rem;">
                                                        <fmt:formatDate value="${ticket.createdAt}" pattern="dd/MM/yyyy hh:mm a"/>
                                                    </div>
                                                </div>

                                                <div class="meta-group">
                                                    <span class="meta-label">Updated</span>
                                                    <div class="meta-value" style="font-size: 0.85rem;">
                                                        <fmt:formatDate value="${ticket.createdAt}" pattern="dd/MM/yyyy hh:mm a"/>
                                                    </div>
                                                </div>

                                                <div class="alert alert-primary mt-4 p-3 text-center border-0 shadow-sm" style="font-size: 0.85rem; background-color: #e9f2ff; color: #0052cc;">
                                                    <i class="feather icon-info d-block mb-1" style="font-size: 1.5rem;"></i> 
                                                    <strong>SLA Note:</strong> IT Support aims to respond to medium priority requests within 24 hours.
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