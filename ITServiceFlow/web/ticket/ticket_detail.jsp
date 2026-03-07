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
        /* Typography & Layout Polish */
        body { background-color: #f4f5f7; }
        .card { border-radius: 8px; box-shadow: 0 1px 3px rgba(9,30,66,0.05); border: 1px solid #dfe1e6; }
        
        /* Header */
        .ticket-header { border-bottom: 1px solid #dfe1e6; padding-bottom: 20px; margin-bottom: 25px; }
        .ticket-key { font-size: 0.95rem; color: #5e6c84; font-weight: 500; margin-bottom: 8px; display: flex; align-items: center; }
        .ticket-title { font-size: 1.6rem; color: #172b4d; font-weight: 600; line-height: 1.3; margin: 0; }
        
        /* Content Sections */
        .section-title { font-size: 1rem; font-weight: 600; color: #172b4d; margin-bottom: 15px; display: flex; align-items: center; border-bottom: 1px solid #f4f5f7; padding-bottom: 8px;}
        .section-title i { margin-right: 8px; color: #6b778c; font-size: 1.1rem; }
        
        /* Description Box - Lighter, cleaner */
        .desc-box { background-color: #fafbfc; padding: 16px 20px; border-radius: 6px; color: #172b4d; white-space: pre-wrap; border: 1px solid #ebecf0; margin-bottom: 35px; font-size: 0.95rem; line-height: 1.6; }
        
        /* Sidebar Meta Info */
        .sidebar-section-title { font-size: 0.75rem; font-weight: 700; color: #5e6c84; text-transform: uppercase; letter-spacing: 0.8px; border-bottom: 1px solid #dfe1e6; padding-bottom: 10px; margin-bottom: 20px; }
        .meta-group { margin-bottom: 20px; }
        .meta-label { color: #6b778c; font-size: 0.75rem; font-weight: 600; text-transform: uppercase; margin-bottom: 6px; display: block; letter-spacing: 0.3px; }
        .meta-value { color: #172b4d; font-size: 0.9rem; font-weight: 500; display: flex; align-items: center; }
        .meta-value i { margin-right: 6px; font-size: 1rem; }
        
        /* Avatars */
        .avatar-sm { width: 24px; height: 24px; border-radius: 50%; background-color: #0052cc; color: white; display: inline-flex; align-items: center; justify-content: center; font-size: 0.7rem; font-weight: bold; margin-right: 10px; flex-shrink: 0;}
        .avatar-unassigned { background-color: #fafbfc; color: #7a869a; border: 1px dashed #a5adba; }

        /* Badges & Icons */
        .jira-badge { display: inline-block; padding: 3px 8px; border-radius: 3px; font-size: 0.75rem; font-weight: 700; text-transform: uppercase; letter-spacing: 0.3px;}
        .badge-new { background-color: #e9f2ff; color: #0052cc; }
        .badge-progress { background-color: #fff0b3; color: #ff8b00; }
        .badge-resolved { background-color: #e3fcef; color: #00875a; }
        .badge-closed { background-color: #dfe1e6; color: #42526e; }
        
        .prio-high { color: #ff5630; }
        .prio-medium { color: #ff8b00; }
        .prio-low { color: #00875a; }

        /* Activity Log Empty State */
        .empty-activity { background: #fafbfc; border: 1px dashed #dfe1e6; border-radius: 6px; padding: 25px; text-align: center; margin-top: 15px; }
        .empty-activity i { font-size: 2rem; color: #b3bac5; margin-bottom: 10px; display: block; }
        .empty-activity p { color: #6b778c; font-size: 0.9rem; margin: 0; }
    </style>
</head>

<body class="">
    <jsp:include page="../includes/header.jsp" />
    <jsp:include page="../includes/sidebar.jsp" />

    <div class="pcoded-main-container">
        <div class="pcoded-wrapper">
            <div class="pcoded-content">
                <div class="pcoded-inner-content">
                    
                    <div class="page-header mb-3">
                        <div class="page-block">
                            <div class="row align-items-center">
                                <div class="col-md-12">
                                    <ul class="breadcrumb bg-transparent p-0 m-0">
                                        <li class="breadcrumb-item"><a href="${pageContext.request.contextPath}/Tickets" class="text-primary"><i class="feather icon-list mr-1"></i>My Requests</a></li>
                                        <li class="breadcrumb-item text-muted">${ticket.ticketNumber}</li>
                                    </ul>
                                </div>
                            </div>
                        </div>
                    </div>

                    <div class="main-body">
                        <div class="page-wrapper p-0">
                            <div class="row">
                                <div class="col-lg-8">
                                    <div class="card border-0">
                                        <div class="card-body p-4 p-md-5">
                                            
                                            <div class="ticket-header">
                                                <span class="ticket-key">
                                                    <c:choose>
                                                        <c:when test="${ticket.ticketType == 'Incident'}"><i class="feather icon-alert-octagon text-danger mr-2"></i> IT Incident</c:when>
                                                        <c:otherwise><i class="feather icon-monitor text-primary mr-2"></i> Service Request</c:otherwise>
                                                    </c:choose>
                                                    <span class="mx-2 text-muted">|</span> ${ticket.ticketNumber}
                                                </span>
                                                <h1 class="ticket-title">${ticket.title}</h1>
                                            </div>

                                            <h6 class="section-title"><i class="feather icon-align-left"></i> Description</h6>
                                            <div class="desc-box"><c:out value="${ticket.description}" default="No description provided."/></div>
                                            
                                            <h6 class="section-title"><i class="feather icon-paperclip"></i> Attachments</h6>
                                            <div class="mb-5">
                                                <span class="text-muted" style="font-size: 0.85rem; font-style: italic;">No files attached to this request.</span>
                                            </div>

                                            <div class="comment-thread mt-2">
                                                <h6 class="section-title"><i class="feather icon-message-square"></i> Activity Log</h6>
                                                
                                                <div class="text-center my-4">
                                                    <span class="badge badge-light text-muted border px-3 py-1" style="font-weight: 500;">
                                                        Ticket created on <fmt:formatDate value="${ticket.createdAt}" pattern="MMM dd, yyyy HH:mm"/>
                                                    </span>
                                                </div>

                                                <div class="empty-activity">
                                                    <i class="feather icon-message-circle"></i>
                                                    <p>No activity or comments yet.</p>
                                                </div>
                                            </div>
                                            
                                            <div class="mt-5 pt-3 border-top">
                                                <a href="${pageContext.request.contextPath}/Tickets" class="btn btn-light border shadow-sm font-weight-bold text-secondary">
                                                    <i class="feather icon-arrow-left mr-1"></i> Back to List
                                                </a>
                                            </div>
                                        </div>
                                    </div>
                                </div>

                                <div class="col-lg-4">
                                    <div class="card border-0">
                                        <div class="card-body p-4">
                                            
                                            <h6 class="sidebar-section-title">Details</h6>
                                            
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
                                                        <c:otherwise><span class="text-muted">Chưa phân loại</span></c:otherwise>
                                                    </c:choose>
                                                </div>
                                            </div>

                                            <div class="meta-group">
                                                <span class="meta-label">Category</span>
                                                <div class="meta-value">
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
                                                            <div class="avatar-sm">${ticket.assigneeName.substring(0, 2).toUpperCase()}</div> 
                                                            ${ticket.assigneeName}
                                                        </c:when>
                                                        <c:otherwise>
                                                            <div class="avatar-sm avatar-unassigned"><i class="feather icon-user-x"></i></div> 
                                                            <span class="text-muted">Unassigned</span>
                                                        </c:otherwise>
                                                    </c:choose>
                                                </div>
                                            </div>

                                            <div class="meta-group mb-0">
                                                <span class="meta-label">Reporter</span>
                                                <div class="meta-value">
                                                    <div class="avatar-sm" style="background-color: #00875a;">ME</div> 
                                                    You (${sessionScope.user.fullName})
                                                </div>
                                            </div>

                                            <h6 class="sidebar-section-title mt-4 pt-3">Dates</h6>

                                            <div class="meta-group">
                                                <span class="meta-label">Created</span>
                                                <div class="meta-value text-dark" style="font-size: 0.85rem;">
                                                    <fmt:formatDate value="${ticket.createdAt}" pattern="dd/MM/yyyy hh:mm a"/>
                                                </div>
                                            </div>

                                            <div class="meta-group">
                                                <span class="meta-label">Updated</span>
                                                <div class="meta-value text-dark" style="font-size: 0.85rem;">
                                                    <c:choose>
                                                        <c:when test="${not empty ticket.updatedAt}">
                                                            <fmt:formatDate value="${ticket.updatedAt}" pattern="dd/MM/yyyy hh:mm a"/>
                                                        </c:when>
                                                        <c:otherwise>
                                                            <fmt:formatDate value="${ticket.createdAt}" pattern="dd/MM/yyyy hh:mm a"/>
                                                        </c:otherwise>
                                                    </c:choose>
                                                </div>
                                            </div>
                                            
                                            <div class="alert mt-4 p-3 text-center border-0" style="font-size: 0.8rem; background-color: #f4f5f7; color: #5e6c84; border-radius: 6px;">
                                                <i class="feather icon-info text-primary mb-1" style="font-size: 1.2rem; display: block;"></i> 
                                                SLA Note: IT Support aims to respond to medium priority requests within 24 hours.
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