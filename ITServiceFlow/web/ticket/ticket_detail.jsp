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
            body {
                background-color: #f4f5f7;
            }
            .card {
                border-radius: 8px;
                box-shadow: 0 1px 3px rgba(9,30,66,0.05);
                border: 1px solid #dfe1e6;
            }

            /* Header */
            .ticket-header {
                border-bottom: 1px solid #dfe1e6;
                padding-bottom: 20px;
                margin-bottom: 25px;
            }
            .ticket-key {
                font-size: 0.95rem;
                color: #5e6c84;
                font-weight: 500;
                margin-bottom: 8px;
                display: flex;
                align-items: center;
            }
            .ticket-title {
                font-size: 1.6rem;
                color: #172b4d;
                font-weight: 600;
                line-height: 1.3;
                margin: 0;
            }

            /* Content Sections */
            .section-title {
                font-size: 1rem;
                font-weight: 600;
                color: #172b4d;
                margin-bottom: 15px;
                display: flex;
                align-items: center;
                border-bottom: 1px solid #f4f5f7;
                padding-bottom: 8px;
            }
            .section-title i {
                margin-right: 8px;
                color: #6b778c;
                font-size: 1.1rem;
            }

            /* Description Box - Lighter, cleaner */
            .desc-box {
                background-color: #fafbfc;
                padding: 16px 20px;
                border-radius: 6px;
                color: #172b4d;
                white-space: pre-wrap;
                border: 1px solid #ebecf0;
                margin-bottom: 35px;
                font-size: 0.95rem;
                line-height: 1.6;
            }

            /* Sidebar Meta Info */
            .sidebar-section-title {
                font-size: 0.75rem;
                font-weight: 700;
                color: #5e6c84;
                text-transform: uppercase;
                letter-spacing: 0.8px;
                border-bottom: 1px solid #dfe1e6;
                padding-bottom: 10px;
                margin-bottom: 20px;
            }
            .meta-group {
                margin-bottom: 20px;
            }
            .meta-label {
                color: #6b778c;
                font-size: 0.75rem;
                font-weight: 600;
                text-transform: uppercase;
                margin-bottom: 6px;
                display: block;
                letter-spacing: 0.3px;
            }
            .meta-value {
                color: #172b4d;
                font-size: 0.9rem;
                font-weight: 500;
                display: flex;
                align-items: center;
            }
            .meta-value i {
                margin-right: 6px;
                font-size: 1rem;
            }

            /* Avatars */
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
                margin-right: 10px;
                flex-shrink: 0;
            }
            .avatar-unassigned {
                background-color: #fafbfc;
                color: #7a869a;
                border: 1px dashed #a5adba;
            }

            /* Badges & Icons */
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
            .badge-reopened {
                background-color: #fff4e5;
                color: #b26b00;
            }

            .prio-high {
                color: #ff5630;
            }
            .prio-medium {
                color: #ff8b00;
            }
            .prio-low {
                color: #00875a;
            }

            /* Activity Log Styling */
            .empty-activity {
                background: #fafbfc;
                border: 1px dashed #dfe1e6;
                border-radius: 6px;
                padding: 25px;
                text-align: center;
                margin-bottom: 20px;
            }
            .empty-activity i {
                font-size: 2rem;
                color: #b3bac5;
                margin-bottom: 10px;
                display: block;
            }
            .empty-activity p {
                color: #6b778c;
                font-size: 0.9rem;
                margin: 0;
            }
            
            .editor-area { border-radius: 6px; border: 1px solid #dfe1e6; font-size: 0.95rem; background-color: #fafbfc;}
            .editor-area:focus { background-color: #fff; box-shadow: 0 0 0 2px rgba(0,82,204,0.2); border-color: #0052cc;}
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

                        <c:if test="${not empty ticketDetailFlashMessage}">
                            <div class="alert alert-${ticketDetailFlashType == 'success' ? 'success' : 'danger'} alert-dismissible fade show" role="alert">
                                ${ticketDetailFlashMessage}
                                <button type="button" class="close" data-dismiss="alert" aria-label="Close">
                                    <span aria-hidden="true">&times;</span>
                                </button>
                            </div>
                        </c:if>

                        <div class="main-body">
                            <div class="page-wrapper p-0">
                                <div class="row">
                                    <div class="col-lg-8">
                                        <div class="card border-0">
                                            <div class="card-body p-4 p-md-5">

                                                <div class="ticket-header d-flex justify-content-between align-items-start flex-wrap">
                                                    <div>
                                                        <span class="ticket-key">
                                                            <c:choose>
                                                                <c:when test="${ticket.ticketType == 'Incident'}"><i class="feather icon-alert-octagon text-danger mr-2"></i> IT Incident</c:when>
                                                                <c:otherwise><i class="feather icon-monitor text-primary mr-2"></i> Service Request</c:otherwise>
                                                            </c:choose>
                                                            <span class="mx-2 text-muted">|</span> ${ticket.ticketNumber}
                                                        </span>
                                                        <h1 class="ticket-title">${ticket.title}</h1>
                                                    </div>
                                                    <c:if test="${ticket.status == 'Resolved' || ticket.status == 'Closed'}">
                                                        <button type="button" class="btn btn-warning shadow-sm font-weight-bold mt-2 mt-md-0" data-toggle="modal" data-target="#reopenModal">
                                                            <i class="feather icon-rotate-ccw mr-1"></i> Reopen Ticket
                                                        </button>
                                                    </c:if>
                                                </div>

                                                <h6 class="section-title"><i class="feather icon-align-left"></i> Description</h6>
                                                <div class="desc-box"><c:out value="${ticket.description}" default="No description provided."/></div>

                                                

                                                <div class="comment-thread mt-2 pt-2 border-top">
                                                    <h6 class="section-title mt-4"><i class="feather icon-message-square"></i> Activity Log</h6>

                                                    <div class="text-center my-4">
                                                        <span class="badge badge-light text-muted border px-3 py-1" style="font-weight: 500;">
                                                            Ticket created on <fmt:formatDate value="${ticket.createdAt}" pattern="MMM dd, yyyy HH:mm"/>
                                                        </span>
                                                    </div>

                                                    <c:choose>
                                                        <c:when test="${not empty comments}">
                                                            <c:forEach items="${comments}" var="cmt">
                                                                <div class="p-3 p-md-4 mb-3 border rounded" style="background-color: #fafbfc;">
                                                                    <div class="d-flex justify-content-between align-items-center mb-3 border-bottom pb-2">
                                                                        <span class="font-weight-bold ${cmt.userRole == 'User' ? 'text-primary' : 'text-dark'} d-flex align-items-center">
                                                                            <div class="avatar-sm d-inline-flex align-items-center justify-content-center text-white rounded-circle mr-2" style="background:${cmt.userRole == 'User' ? '#00875a' : '#0052cc'}; width:28px; height:28px; font-size:11px;">
                                                                                ${cmt.userFullName.substring(0, 2).toUpperCase()}
                                                                            </div>
                                                                            ${cmt.userFullName} <span class="badge badge-light text-muted ml-2 border">${cmt.userRole}</span>
                                                                        </span>
                                                                        <span class="text-muted font-weight-bold" style="font-size: 0.8rem;">
                                                                            <fmt:formatDate value="${cmt.createdAt}" pattern="dd/MM/yyyy HH:mm" />
                                                                        </span>
                                                                    </div>
                                                                    <div style="white-space: pre-wrap; font-size: 0.95rem; line-height: 1.6; color: #172b4d;">${cmt.content}</div>
                                                                </div>
                                                            </c:forEach>
                                                        </c:when>
                                                        <c:otherwise>
                                                            <div class="empty-activity">
                                                                <i class="feather icon-message-circle"></i>
                                                                <p>No activity or comments yet.</p>
                                                            </div>
                                                        </c:otherwise>
                                                    </c:choose>

                                                    <div class="mt-4">
                                                        <form action="${pageContext.request.contextPath}/AddComment" method="POST">
                                                            <input type="hidden" name="ticketId" value="${ticket.id}">
                                                            <input type="hidden" name="isInternal" value="false"> <textarea name="content" class="form-control editor-area p-3" rows="4" placeholder="Add a comment or reply to IT Support..." required></textarea>
                                                            <div class="text-right mt-3">
                                                                <button type="submit" class="btn btn-primary px-4 py-2 font-weight-bold">Post Comment</button>
                                                            </div>
                                                        </form>
                                                    </div>
                                                </div>
                                                
                                                <%-- CSAT Banner (only shown when ticket status is Closed) --%>
                                                <c:if test="${ticket.status == 'Closed'}">
                                                    <div class="mt-5 border-top pt-4" id="csatSection">
                                                        <c:choose>
                                                            <%-- Survey exists --%>
                                                            <c:when test="${not empty csatSurvey}">
                                                                <div style="background:#f3faf6; border:1px solid #b7e4c7; border-radius:8px; padding:14px 18px;">
                                                                    <div class="d-flex align-items-center">
                                                                        <div style="width:34px;height:34px;background:#e3fcef;border-radius:50%; display:flex;align-items:center;justify-content:center; margin-right:12px;flex-shrink:0;">
                                                                            <i class="feather icon-check" style="color:#00875a;font-size:1rem;"></i>
                                                                        </div>
                                                                        <div class="flex-grow-1">
                                                                            <p class="mb-0 font-weight-bold" style="color:#00875a;font-size:.875rem;">Feedback Submitted</p>
                                                                            <p class="mb-0 text-muted" style="font-size:.78rem;">
                                                                                <fmt:formatDate value="${csatSurvey.submittedAt}" pattern="dd/MM/yyyy HH:mm"/>
                                                                            </p>
                                                                        </div>
                                                                        <div class="ml-2">
                                                                            <c:forEach begin="1" end="5" var="i">
                                                                                <span style="font-size:1.15rem; color:${i <= csatSurvey.rating ? '#f6c90e' : '#dfe1e6'};">&#9733;</span>
                                                                            </c:forEach>
                                                                            <span class="text-muted ml-1" style="font-size:.8rem;">(${csatSurvey.rating}/5)</span>
                                                                        </div>
                                                                    </div>
                                                                    <c:if test="${not empty csatSurvey.comment}">
                                                                        <p class="mb-0 mt-2 text-muted" style="font-size:.82rem;font-style:italic;padding-left:46px;">
                                                                            "<c:out value='${csatSurvey.comment}' />"
                                                                        </p>
                                                                    </c:if>
                                                                </div>
                                                            </c:when>

                                                            <%-- Survey not submitted yet --%>
                                                            <c:otherwise>
                                                                <div style="background:#e9f2ff; border:1px solid #b3d4ff; border-radius:8px; padding:14px 18px;">
                                                                    <div class="d-flex align-items-center">
                                                                        <div style="width:36px;height:36px;background:#cce0ff;border-radius:50%; display:flex;align-items:center;justify-content:center; margin-right:12px;flex-shrink:0;">
                                                                            <i class="feather icon-star" style="color:#0052cc;font-size:1rem;"></i>
                                                                        </div>
                                                                        <div class="flex-grow-1">
                                                                            <p class="mb-0 font-weight-bold" style="color:#0052cc;font-size:.875rem;">How was your experience?</p>
                                                                            <p class="mb-0 text-muted" style="font-size:.8rem;">This ticket is closed. Share your feedback to help us improve.</p>
                                                                        </div>
                                                                        <a href="${pageContext.request.contextPath}/CsatSurvey?ticketId=${ticket.id}" class="btn btn-sm ml-3 font-weight-bold flex-shrink-0" style="background:#0052cc;color:#fff;border-radius:5px;padding:7px 16px;">
                                                                            <i class="feather icon-edit-2 mr-1"></i>Give Feedback
                                                                        </a>
                                                                    </div>
                                                                </div>
                                                            </c:otherwise>
                                                        </c:choose>
                                                    </div>
                                                </c:if>

                                                <c:if test="${ticket.status == 'Resolved' || ticket.status == 'Closed'}">
                                                    <div class="modal fade" id="reopenModal" tabindex="-1" role="dialog" aria-labelledby="reopenModalLabel" aria-hidden="true">
                                                        <div class="modal-dialog" role="document">
                                                            <div class="modal-content">
                                                                <form action="${pageContext.request.contextPath}/TicketReopen" method="POST">
                                                                    <input type="hidden" name="ticketId" value="${ticket.id}">
                                                                    <div class="modal-header">
                                                                        <h5 class="modal-title" id="reopenModalLabel">Reopen Ticket ${ticket.ticketNumber}</h5>
                                                                        <button type="button" class="close" data-dismiss="modal" aria-label="Close">
                                                                            <span aria-hidden="true">&times;</span>
                                                                        </button>
                                                                    </div>
                                                                    <div class="modal-body">
                                                                        <label class="font-weight-bold">Reason for reopen <span class="text-danger">*</span></label>
                                                                        <textarea class="form-control" name="reopenReason" rows="4" maxlength="500" required placeholder="Describe what issue is still not resolved..."></textarea>
                                                                        <small class="text-muted d-block mt-2">The ticket will move to <strong>Reopened</strong> and notify the assigned queue/agent.</small>
                                                                    </div>
                                                                    <div class="modal-footer">
                                                                        <button type="button" class="btn btn-light border" data-dismiss="modal">Cancel</button>
                                                                        <button type="submit" class="btn btn-warning font-weight-bold">Submit Reopen Request</button>
                                                                    </div>
                                                                </form>
                                                            </div>
                                                        </div>
                                                    </div>
                                                </c:if>

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
                                                            <c:when test="${ticket.status == 'Reopened'}"><span class="jira-badge badge-reopened">Reopened</span></c:when>
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
                                                            <c:otherwise><span class="text-muted">Unclassified</span></c:otherwise>
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

