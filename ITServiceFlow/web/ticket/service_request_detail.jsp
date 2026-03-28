<%-- 
    Document   : service_request_detail
    Created on : Mar 22, 2026, 7:45:24 PM
    Author     : Dumb Trung
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<%@ taglib uri="jakarta.tags.fmt" prefix="fmt" %>

<%-- GLOBAL PERMISSION VARIABLES --%>
<c:set var="isOwner" value="${not empty ticket.assignedTo && ticket.assignedTo == sessionScope.user.id}" />
<c:set var="isManager" value="${sessionScope.role == 'Manager' || sessionScope.role == 'Admin'}" />
<c:set var="canEdit" value="${isOwner}" />

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0, user-scalable=0, minimal-ui">
    <title>Request: ${ticket.ticketNumber} - Agent Workspace</title>
    
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/fonts/fontawesome/css/fontawesome-all.min.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/plugins/bootstrap/css/bootstrap.min.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/style.css">

    <style>
        body { background-color: #f4f5f7; }
        .card { border-radius: 8px; box-shadow: 0 1px 3px rgba(9,30,66,0.05); border: 1px solid #dfe1e6; }
        .ticket-header { border-bottom: 1px solid #dfe1e6; padding-bottom: 20px; margin-bottom: 25px; }
        .ticket-key { font-size: 0.95rem; color: #5e6c84; font-weight: 500; margin-bottom: 8px; display: flex; align-items: center; }
        .ticket-title { font-size: 1.6rem; color: #172b4d; font-weight: 600; line-height: 1.3; margin: 0; }
        .section-title { font-size: 1rem; font-weight: 600; color: #172b4d; margin-bottom: 15px; display: flex; align-items: center; border-bottom: 1px solid #f4f5f7; padding-bottom: 8px; }
        .section-title i { margin-right: 8px; color: #6b778c; font-size: 1.1rem; }
        .desc-box { background-color: #fafbfc; padding: 16px 20px; border-radius: 6px; color: #172b4d; white-space: pre-wrap; border: 1px solid #ebecf0; margin-bottom: 35px; font-size: 0.95rem; line-height: 1.6; }
        .sidebar-section-title { font-size: 0.75rem; font-weight: 700; color: #5e6c84; text-transform: uppercase; letter-spacing: 0.8px; border-bottom: 1px solid #dfe1e6; padding-bottom: 10px; margin-bottom: 20px; }
        .meta-group { margin-bottom: 20px; }
        .meta-label { color: #6b778c; font-size: 0.75rem; font-weight: 600; text-transform: uppercase; margin-bottom: 6px; display: block; letter-spacing: 0.3px; }
        .meta-value { color: #172b4d; font-size: 0.9rem; font-weight: 500; display: flex; align-items: center; }
        .avatar-sm { width: 24px; height: 24px; border-radius: 50%; background-color: #0052cc; color: white; display: inline-flex; align-items: center; justify-content: center; font-size: 0.7rem; font-weight: bold; margin-right: 10px; flex-shrink: 0; }
        .avatar-unassigned { background-color: #fafbfc; color: #7a869a; border: 1px dashed #a5adba; }
        
        /* Comment Area */
        .comment-tabs { display: flex; gap: 10px; margin-bottom: 15px; border-bottom: 2px solid #ebecf0; padding-bottom: 10px;}
        .comment-tab { padding: 6px 16px; border-radius: 20px; font-size: 0.85rem; font-weight: 600; color: #5e6c84; background: transparent; cursor: pointer; transition: 0.2s;}
        .comment-tab:hover { background: #f4f5f7; }
        .comment-tab.active-reply { background: #e9f2ff; color: #0052cc; }
        .comment-tab.active-note { background: #fff0b3; color: #ff8b00; }
        .editor-area { border-radius: 6px; border: 1px solid #dfe1e6; font-size: 0.95rem; background-color: #fafbfc;}
        .editor-area:focus { background-color: #fff; box-shadow: 0 0 0 2px rgba(0,82,204,0.2); border-color: #0052cc;}
        .editor-area.note-mode { background-color: #fffdf5; border-color: #ffc400; }
        .editor-area.note-mode:focus { box-shadow: 0 0 0 2px rgba(255,196,0,0.2); }
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
                                <div class="col-md-12 d-flex justify-content-between align-items-center">
                                    <ul class="breadcrumb bg-transparent p-0 m-0">
                                        <li class="breadcrumb-item"><a href="${pageContext.request.contextPath}/Queues" class="text-primary"><i class="feather icon-arrow-left mr-1"></i>Back to Queues</a></li>
                                        <li class="breadcrumb-item text-muted">Service Request</li>
                                        <li class="breadcrumb-item text-muted">${ticket.ticketNumber}</li>
                                    </ul>
                                </div>
                            </div>
                        </div>
                    </div>

                    <div class="main-body">
                        <div class="page-wrapper p-0">
                            
                            <c:if test="${ticket.status == 'Awaiting Approval'}">
                                <div class="alert alert-warning p-3 mb-4 border-0 d-flex justify-content-between align-items-center shadow-sm" style="border-radius: 6px; background-color: #fff0b3; color: #ff8b00;">
                                    <div>
                                        <i class="feather icon-shield font-weight-bold mr-2" style="font-size: 1.2rem;"></i> 
                                        <span style="font-size: 0.95rem; font-weight: 600;">APPROVAL REQUIRED:</span> 
                                        <span class="text-dark">This service request is locked and pending Manager approval.</span>
                                    </div>
                                    <span class="badge badge-warning px-3 py-2 text-dark" style="font-size: 0.85rem; letter-spacing: 0.5px;">PENDING</span>
                                </div>
                            </c:if>

                            <div class="row">
                                <div class="col-lg-8">
                                    <div class="card border-0">
                                        <div class="card-body p-4 p-md-5">

                                            <div class="ticket-header d-flex justify-content-between align-items-start">
                                                <div>
                                                    <span class="ticket-key">
                                                        <i class="feather icon-shopping-cart text-success mr-2"></i> Service Request
                                                        <span class="mx-2 text-muted">|</span> ${ticket.ticketNumber}
                                                    </span>
                                                    <h1 class="ticket-title">${ticket.title}</h1>
                                                </div>
                                                
                                                <div class="d-flex align-items-center">
                                                    <c:choose>
                                                        <c:when test="${ticket.status == 'Awaiting Approval'}">
                                                            <c:choose>
                                                                <c:when test="${isManager}">
                                                                    <button type="button" class="btn btn-sm btn-success font-weight-bold shadow-sm mr-2 px-3" data-toggle="modal" data-target="#approveModal">
                                                                        <i class="feather icon-check-circle mr-1"></i> Approve
                                                                    </button>
                                                                    <button type="button" class="btn btn-sm btn-danger font-weight-bold shadow-sm px-3" data-toggle="modal" data-target="#rejectModal">
                                                                        <i class="feather icon-x-circle mr-1"></i> Reject
                                                                    </button>
                                                                </c:when>
                                                                <c:otherwise>
                                                                    <button class="btn btn-sm btn-light border text-muted font-weight-bold px-3" disabled>
                                                                        <i class="feather icon-lock mr-1"></i> Locked
                                                                    </button>
                                                                </c:otherwise>
                                                            </c:choose>
                                                        </c:when>

                                                        <c:when test="${ticket.status == 'Closed'}">
                                                            <span class="badge badge-secondary p-2 mr-2" style="font-size:0.85rem;">
                                                                <i class="feather icon-archive mr-1"></i> Closed
                                                            </span>
                                                        </c:when>
                                                        
                                                        <c:otherwise>
                                                            <c:choose>
                                                                <c:when test="${canEdit}">
                                                                    <div class="dropdown mr-2">
                                                                        <button class="btn btn-sm btn-primary dropdown-toggle shadow-sm font-weight-bold px-3" type="button" data-toggle="dropdown">
                                                                            ${ticket.status == 'New' ? 'Fulfill Request' : ticket.status}
                                                                        </button>
                                                                        <div class="dropdown-menu dropdown-menu-right mt-1 shadow-sm">
                                                                            <c:if test="${ticket.status == 'New' || ticket.status == 'Reopened'}">
                                                                                <a class="dropdown-item py-2" href="UpdateStatus?id=${ticket.id}&status=In Progress"><i class="feather icon-play mr-2 text-primary"></i> Start Fulfillment</a>
                                                                                <div class="dropdown-divider"></div>
                                                                            </c:if>
                                                                            <c:if test="${ticket.status != 'Resolved'}">
                                                                                <a class="dropdown-item text-success font-weight-bold py-2" href="UpdateStatus?id=${ticket.id}&status=Resolved"><i class="feather icon-check-circle mr-2"></i> Mark as Completed</a>
                                                                            </c:if>
                                                                            <a class="dropdown-item text-secondary py-2" href="UpdateStatus?id=${ticket.id}&status=Closed"><i class="feather icon-archive mr-2"></i> Close Request</a>
                                                                        </div>
                                                                    </div>
                                                                </c:when>
                                                                
                                                                <%-- OTHERS ARE BLOCKED --%>
                                                                <c:otherwise>
                                                                    <div class="alert alert-secondary py-2 px-3 mb-0 mr-2 border d-flex align-items-center shadow-sm" style="font-size: 0.85rem; background: #fff;">
                                                                        <i class="feather icon-lock mr-2 text-muted"></i> 
                                                                        <c:choose>
                                                                            <c:when test="${empty ticket.assigneeName}">
                                                                                <span>Read Only. <a href="${pageContext.request.contextPath}/AssignTicket?id=${ticket.id}" class="font-weight-bold text-primary ml-1">Assign to me</a> to take action.</span>
                                                                            </c:when>
                                                                            <c:otherwise>
                                                                                <span>Read Only. Handled by <strong>${ticket.assigneeName}</strong>.</span>
                                                                            </c:otherwise>
                                                                        </c:choose>
                                                                    </div>
                                                                </c:otherwise>
                                                            </c:choose>
                                                        </c:otherwise>
                                                    </c:choose>
                                                </div>
                                            </div>

                                            <h6 class="section-title"><i class="feather icon-align-left"></i> Request Details</h6>
                                            <div class="desc-box"><c:out value="${ticket.description}" default="No description provided."/></div>

                                            <div class="card-neat p-4 p-lg-5">
                                                <div class="section-title mb-4"><i class="feather icon-message-square text-primary mr-3" style="font-size: 1.2rem;"></i> Communication</div>
                                                <div class="comment-tabs">
                                                    <div class="comment-tab active-reply" onclick="toggleComment('reply', this)"><i class="feather icon-corner-up-left mr-2"></i> Reply to User</div>
                                                    <div class="comment-tab" onclick="toggleComment('note', this)"><i class="feather icon-lock mr-2"></i> Internal Note</div>
                                                </div>
                                                <form action="${pageContext.request.contextPath}/AddComment" method="POST">
                                                    <input type="hidden" name="ticketId" value="${ticket.id}">
                                                    <input type="hidden" name="isInternal" id="isInternalInput" value="false">
                                                    <textarea name="content" class="form-control editor-area mb-3 p-3" id="commentArea" rows="5" placeholder="Type your response to the user here..." required></textarea>
                                                    <div class="text-right mt-3">
                                                        <button type="submit" class="btn btn-primary px-5 py-2 font-weight-bold" id="btnSubmitComment">Save Reply</button>
                                                    </div>
                                                </form>

                                                <c:if test="${not empty comments}">
                                                    <div class="mt-5 pt-4 border-top">
                                                        <h6 class="font-weight-bold text-dark mb-4" style="font-size: 0.95rem; text-transform: uppercase; letter-spacing: 0.5px;">Activity Stream</h6>
                                                        <c:forEach items="${comments}" var="cmt">
                                                            <div class="p-3 p-md-4 mb-3 border rounded ${cmt.internal ? 'border-warning' : ''}" style="background-color: ${cmt.internal ? '#fffdf5' : '#fafbfc'};">
                                                                <div class="d-flex justify-content-between align-items-center mb-3 border-bottom pb-2">
                                                                    <span class="font-weight-bold ${cmt.userRole == 'User' ? 'text-primary' : 'text-dark'} d-flex align-items-center">
                                                                        <div class="avatar-sm d-inline-flex align-items-center justify-content-center text-white rounded-circle mr-2" style="background:${cmt.userRole == 'User' ? '#00875a' : '#0052cc'}; width:28px; height:28px; font-size:11px;">
                                                                            ${cmt.userFullName.substring(0, 2).toUpperCase()}
                                                                        </div>
                                                                        ${cmt.userFullName} <span class="badge badge-light text-muted ml-2 border">${cmt.userRole}</span>
                                                                    </span>
                                                                    <span class="text-muted font-weight-bold" style="font-size: 0.8rem;">
                                                                        <fmt:formatDate value="${cmt.createdAt}" pattern="dd/MM/yyyy HH:mm" />
                                                                        <c:if test="${cmt.internal}"><i class="feather icon-lock text-warning ml-2" title="Internal Note" style="font-size: 1rem;"></i></c:if>
                                                                    </span>
                                                                </div>
                                                                <div style="white-space: pre-wrap; font-size: 0.95rem; line-height: 1.6; color: #172b4d;">${cmt.content}</div>
                                                            </div>
                                                        </c:forEach>
                                                    </div>
                                                </c:if>
                                            </div>

                                        </div>
                                    </div>
                                </div>

                                <div class="col-lg-4">
                                    <div class="card border-0">
                                        <div class="card-body p-4">

                                            <h6 class="sidebar-section-title">Request Info</h6>

                                            <div class="meta-group">
                                                <span class="meta-label">Requested Item</span>
                                                <div class="meta-value text-success font-weight-bold" style="font-size: 1rem;">
                                                    <i class="feather icon-shopping-bag mr-2 text-muted"></i>
                                                    ${not empty ticket.serviceName ? ticket.serviceName : 'N/A'}
                                                </div>
                                            </div>
                                            
                                            <div class="meta-group mb-0">
                                                <span class="meta-label">Category</span>
                                                <div class="meta-value text-muted">
                                                    ${not empty ticket.categoryName ? ticket.categoryName : 'Uncategorized'}
                                                </div>
                                            </div>

                                            <h6 class="sidebar-section-title mt-4 pt-3">People</h6>
                                            
                                            <c:if test="${ticket.requiresApproval}">
                                                <div class="meta-group p-3 border rounded bg-light mb-4">
                                                    <span class="meta-label text-dark">Approval Status</span>
                                                    <div class="meta-value mt-2">
                                                        <c:choose>
                                                            <c:when test="${empty ticket.approvedBy && ticket.status == 'Awaiting Approval'}">
                                                                <span class="text-warning font-weight-bold" style="font-size: 0.95rem;"><i class="feather icon-clock"></i> Pending Manager</span>
                                                            </c:when>
                                                            <c:when test="${not empty ticket.approvedBy}">
                                                                <span class="text-success font-weight-bold" style="font-size: 0.95rem;"><i class="feather icon-check-circle"></i> Approved</span>
                                                                <div class="text-muted mt-1" style="font-size: 0.75rem;">By User ID: ${ticket.approvedBy}</div>
                                                            </c:when>
                                                            <c:when test="${ticket.status == 'Closed' && empty ticket.approvedBy}">
                                                                <span class="text-danger font-weight-bold" style="font-size: 0.95rem;"><i class="feather icon-x-circle"></i> Rejected</span>
                                                            </c:when>
                                                        </c:choose>
                                                    </div>
                                                </div>
                                            </c:if>

                                            <div class="meta-group">
                                                <span class="meta-label">Fulfiller (Assignee)</span>
                                                <div class="meta-value">
                                                    <c:choose>
                                                        <%-- TICKET IS ASSIGNED --%>
                                                        <c:when test="${not empty ticket.assigneeName}">
                                                            <div class="avatar-sm">${ticket.assigneeName.substring(0, 2).toUpperCase()}</div> 
                                                            <span class="font-weight-bold text-dark">${ticket.assigneeName}</span>
                                                            
                                                            <c:if test="${isManager && ticket.status != 'Closed' && ticket.status != 'Resolved'}">
                                                                <a href="javascript:void(0)" data-toggle="modal" data-target="#assignModal" class="text-danger font-weight-bold ml-2" style="font-size: 0.75rem;" title="Re-assign">(Re-assign)</a>
                                                            </c:if>
                                                        </c:when>
                                                        

                                                        <c:otherwise>
                                                            <div class="avatar-sm avatar-unassigned"><i class="feather icon-user-x"></i></div> 
                                                            <span class="text-muted mr-2">Unassigned</span>
                                                            
                                                            <c:if test="${ticket.status != 'Awaiting Approval'}">
                                                                <c:choose>
                                                                    <c:when test="${isManager}">
                                                                        <div class="d-inline-block mt-1">
                                                                            <a href="${pageContext.request.contextPath}/AssignTicket?id=${ticket.id}" class="text-primary font-weight-bold mr-2" style="font-size: 0.8rem;" title="Assign to me">(Assign to me)</a>
                                                                            <a href="javascript:void(0)" data-toggle="modal" data-target="#assignModal" class="text-secondary font-weight-bold" style="font-size: 0.8rem;" title="Assign to another agent">(Assign to...)</a>
                                                                        </div>
                                                                    </c:when>
                                                                    <c:otherwise>
                                                                        <a href="${pageContext.request.contextPath}/AssignTicket?id=${ticket.id}" class="text-primary font-weight-bold" style="font-size: 0.8rem;">(Assign to me)</a>
                                                                    </c:otherwise>
                                                                </c:choose>
                                                            </c:if>
                                                        </c:otherwise>
                                                    </c:choose>
                                                </div>
                                            </div>

                                            <div class="meta-group mb-0">
                                                <span class="meta-label">Requester</span>
                                                <div class="meta-value">
                                                    <div class="avatar-sm" style="background-color: #6b778c;"><i class="feather icon-user"></i></div>
                                                    User ID: ${ticket.createdBy}
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
    </div>

    <div class="modal fade" id="approveModal" tabindex="-1" role="dialog" aria-hidden="true">
        <div class="modal-dialog modal-dialog-centered" role="document">
            <div class="modal-content border-0 shadow-lg" style="border-radius: 8px;">
                <div class="modal-header bg-light border-bottom-0 p-4">
                    <h5 class="modal-title font-weight-bold text-success"><i class="feather icon-check-circle mr-2"></i>Approve Service Request</h5>
                    <button type="button" class="close" data-dismiss="modal" aria-label="Close"><span aria-hidden="true">&times;</span></button>
                </div>
                <form action="${pageContext.request.contextPath}/ProcessApproval" method="POST">
                    <div class="modal-body p-4 text-center">
                        <input type="hidden" name="id" value="${ticket.id}">
                        <input type="hidden" name="action" value="approve">
                        <div class="mb-3"><i class="feather icon-check-circle text-success" style="font-size: 3.5rem;"></i></div>
                        <h6 class="font-weight-bold text-dark">Confirm approval for this request?</h6>
                        <p class="text-muted small mb-0">The system will automatically map the estimated delivery hours from the Service Catalog to establish the SLA and dispatch this ticket to IT Support.</p>
                    </div>
                    <div class="modal-footer border-top-0 p-4 pt-0 justify-content-center">
                        <button type="button" class="btn btn-light font-weight-bold px-4" data-dismiss="modal">Cancel</button>
                        <button type="submit" class="btn btn-success font-weight-bold px-4 shadow-sm">Confirm Approval</button>
                    </div>
                </form>
            </div>
        </div>
    </div>

    <%-- ================= REJECT MODAL ================= --%>
    <div class="modal fade" id="rejectModal" tabindex="-1" role="dialog" aria-hidden="true">
        <div class="modal-dialog modal-dialog-centered" role="document">
            <div class="modal-content border-0 shadow-lg" style="border-radius: 8px;">
                <div class="modal-header bg-light border-bottom-0 p-4">
                    <h5 class="modal-title font-weight-bold text-danger"><i class="feather icon-x-circle mr-2"></i>Reject Service Request</h5>
                    <button type="button" class="close" data-dismiss="modal" aria-label="Close"><span aria-hidden="true">&times;</span></button>
                </div>
                <form action="${pageContext.request.contextPath}/ProcessApproval" method="POST">
                    <div class="modal-body p-4">
                        <input type="hidden" name="id" value="${ticket.id}">
                        <input type="hidden" name="action" value="reject">
                        <div class="form-group mb-0">
                            <label class="font-weight-bold text-dark mb-2">Reason for Rejection <span class="text-danger">*</span></label>
                            <p class="text-muted small mb-3">This reason will be logged and visible to the requester.</p>
                            <textarea name="rejectReason" class="form-control" rows="4" placeholder="e.g., Budget constraints, Invalid request..." required style="border-radius: 6px;"></textarea>
                        </div>
                    </div>
                    <div class="modal-footer border-top-0 p-4 pt-0">
                        <button type="button" class="btn btn-light font-weight-bold px-4" data-dismiss="modal">Cancel</button>
                        <button type="submit" class="btn btn-danger font-weight-bold px-4 shadow-sm">Reject Request</button>
                    </div>
                </form>
            </div>
        </div>
    </div>

    <div class="modal fade" id="assignModal" tabindex="-1" role="dialog" aria-hidden="true">
        <div class="modal-dialog modal-dialog-centered" role="document">
            <div class="modal-content border-0 shadow-lg" style="border-radius: 8px;">
                <div class="modal-header bg-light border-bottom-0 p-4">
                    <h5 class="modal-title font-weight-bold text-dark"><i class="feather icon-user-check text-primary mr-2"></i>Assign Request to Agent</h5>
                    <button type="button" class="close" data-dismiss="modal" aria-label="Close"><span aria-hidden="true">&times;</span></button>
                </div>
                <form action="${pageContext.request.contextPath}/AssignTicket" method="POST">
                    <div class="modal-body p-4">
                        <input type="hidden" name="ticketId" value="${ticket.id}">
                        <div class="form-group mb-0">
                            <label class="font-weight-bold text-dark mb-2">Select Agent</label>
                            <select name="agentId" class="form-control" required style="border: 1px solid #dfe1e6; border-radius: 6px; height: 42px;">
                                <option value="" disabled selected>-- Choose an agent --</option>
                                <c:forEach items="${itSupportList}" var="agent">
                                    <option value="${agent.id}">${agent.fullName}</option>
                                </c:forEach>
                            </select>
                        </div>
                    </div>
                    <div class="modal-footer border-top-0 p-4 pt-0">
                        <button type="button" class="btn btn-light font-weight-bold px-4" data-dismiss="modal">Cancel</button>
                        <button type="submit" class="btn btn-primary font-weight-bold px-4 shadow-sm">Assign Ticket</button>
                    </div>
                </form>
            </div>
        </div>
    </div>

    <script src="${pageContext.request.contextPath}/assets/plugins/jquery/js/jquery.min.js"></script>
    <script src="${pageContext.request.contextPath}/assets/js/vendor-all.min.js"></script>
    <script src="${pageContext.request.contextPath}/assets/plugins/bootstrap/js/bootstrap.min.js"></script>
    <script src="${pageContext.request.contextPath}/assets/js/pcoded.min.js"></script>
    
    <script>
        function toggleComment(mode, element) {
            $('.comment-tab').removeClass('active-reply active-note');
            var area = $('#commentArea');
            var btn = $('#btnSubmitComment');
            var input = $('#isInternalInput');
            if(mode === 'reply') {
                $(element).addClass('active-reply');
                area.removeClass('note-mode').attr('placeholder', 'Type your response to the user here...');
                btn.removeClass('btn-warning text-dark').addClass('btn-primary').text('Save Reply');
                input.val('false');
            } else {
                $(element).addClass('active-note');
                area.addClass('note-mode').attr('placeholder', 'Type internal notes here. The user will NOT see this.');
                btn.removeClass('btn-primary').addClass('btn-warning text-dark').text('Save Internal Note');
                input.val('true');
            }
        }
    </script>
</body>
</html>