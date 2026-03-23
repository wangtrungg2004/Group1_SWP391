<%-- 
    Document   : agent_ticket_detail
    Created on : Mar 14, 2026
    Author     : Dumb Trung
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<%@ taglib uri="jakarta.tags.fmt" prefix="fmt" %>

<%-- 🚀 KHAI BÁO BIẾN PHÂN QUYỀN TOÀN CỤC NGAY ĐẦU TRANG --%>
<c:set var="isOwner" value="${not empty ticket.assignedTo && ticket.assignedTo == sessionScope.user.id}" />
<c:set var="isManager" value="${sessionScope.role == 'Manager' || sessionScope.role == 'Admin'}" />

<%-- ĐÃ FIX LỖI: Chỉ người đang sở hữu vé (Owner) mới được hiện nút Edit / Đổi Status --%>
<c:set var="canEdit" value="${isOwner}" />

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0, user-scalable=0, minimal-ui">
    <title>${ticket.ticketNumber} - Agent Workspace</title>

    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/fonts/fontawesome/css/fontawesome-all.min.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/plugins/bootstrap/css/bootstrap.min.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/style.css">

    <style>
        /* Typography & Layout Polish */
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
        .comment-tabs { display: flex; gap: 10px; margin-bottom: 15px; border-bottom: 2px solid #ebecf0; padding-bottom: 10px; }
        .comment-tab { padding: 6px 16px; border-radius: 20px; font-size: 0.85rem; font-weight: 600; color: #5e6c84; background: transparent; cursor: pointer; transition: 0.2s; }
        .comment-tab:hover { background: #f4f5f7; }
        .comment-tab.active-reply { background: #e9f2ff; color: #0052cc; }
        .comment-tab.active-note { background: #fff0b3; color: #ff8b00; }
        .editor-area { border-radius: 6px; border: 1px solid #dfe1e6; font-size: 0.95rem; background-color: #fafbfc; }
        .editor-area:focus { background-color: #fff; box-shadow: 0 0 0 2px rgba(0,82,204,0.2); border-color: #0052cc; }
        .editor-area.note-mode { background-color: #fffdf5; border-color: #ffc400; }
        .editor-area.note-mode:focus { box-shadow: 0 0 0 2px rgba(255,196,0,0.2); }
        .prio-high { color: #ff5630; margin-right: 6px; }
        .prio-medium { color: #ff8b00; margin-right: 6px; }
        .prio-low { color: #00875a; margin-right: 6px; }
    </style>
</head>

<body>
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
                                        <li class="breadcrumb-item text-muted">${ticket.ticketType}</li>
                                        <li class="breadcrumb-item text-muted">${ticket.ticketNumber}</li>
                                    </ul>
                                </div>
                            </div>
                        </div>
                    </div>

                    <div class="main-body">
                        <div class="page-wrapper p-0">

                            <c:if test="${not empty slaTracking}">
                                <div class="alert ${isSlaBreached ? 'alert-danger' : 'alert-warning'} p-3 mb-4 border-0 d-flex justify-content-between align-items-center" style="border-radius: 6px;">
                                    <div>
                                        <i class="feather icon-clock font-weight-bold mr-2" style="font-size: 1.1rem;"></i> 
                                        <span style="font-size: 0.9rem;"><strong>Resolution SLA:</strong> Deadline is <fmt:formatDate value="${slaTracking.resolutionDeadline}" pattern="dd/MM/yyyy HH:mm" /></span>
                                    </div>
                                    <c:if test="${isSlaBreached}">
                                        <span class="badge badge-danger px-2 py-1" style="font-size: 0.8rem; letter-spacing: 0.5px;">BREACHED</span>
                                    </c:if>
                                </div>
                            </c:if>

                            <div class="row">
                                <div class="col-lg-8">
                                    <div class="card border-0">
                                        <div class="card-body p-4 p-md-5">

                                            <div class="ticket-header d-flex justify-content-between align-items-start">
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

                                                <div class="d-flex align-items-center">
                                                    <c:choose>
                                                        <%-- KỊCH BẢN 1: VÉ ĐANG CHỜ DUYỆT --%>
                                                        <c:when test="${ticket.status == 'Awaiting Approval'}">
                                                            <c:choose>
                                                                <c:when test="${isManager}">
                                                                    <a href="${pageContext.request.contextPath}/ProcessApproval?id=${ticket.id}&action=approve" class="btn btn-sm btn-success font-weight-bold shadow-sm mr-2">
                                                                        <i class="feather icon-check-circle mr-1"></i> Approve
                                                                    </a>
                                                                    <a href="${pageContext.request.contextPath}/ProcessApproval?id=${ticket.id}&action=reject" class="btn btn-sm btn-danger font-weight-bold shadow-sm mr-2">
                                                                        <i class="feather icon-x-circle mr-1"></i> Reject
                                                                    </a>
                                                                </c:when>
                                                                <c:otherwise>
                                                                    <span class="badge badge-warning p-2 mr-2" style="font-size:0.85rem;"><i class="feather icon-lock mr-1"></i> Locked: Pending Approval</span>
                                                                </c:otherwise>
                                                            </c:choose>
                                                        </c:when>

                                                        <%-- KỊCH BẢN 2: VÉ BÌNH THƯỜNG --%>
                                                        <c:otherwise>
                                                            <c:choose>
                                                                <%-- CÓ QUYỀN -> Cho phép Đổi Status --%>
                                                                <c:when test="${canEdit}">
                                                                    <div class="dropdown mr-2">
                                                                        <button class="btn btn-sm btn-primary dropdown-toggle shadow-sm font-weight-bold" type="button" data-toggle="dropdown">
                                                                            ${ticket.status == 'New' ? 'Start Progress' : ticket.status}
                                                                        </button>
                                                                        <div class="dropdown-menu dropdown-menu-right mt-1 shadow-sm">
                                                                            <a class="dropdown-item py-2" href="${pageContext.request.contextPath}/UpdateStatus?id=${ticket.id}&status=In Progress">In Progress</a>
                                                                            <div class="dropdown-divider"></div>
                                                                            <a class="dropdown-item text-success font-weight-bold py-2" href="${pageContext.request.contextPath}/UpdateStatus?id=${ticket.id}&status=Resolved"><i class="feather icon-check-circle mr-2"></i> Resolve Ticket</a>
                                                                            <a class="dropdown-item text-secondary py-2" href="${pageContext.request.contextPath}/UpdateStatus?id=${ticket.id}&status=Closed"><i class="feather icon-archive mr-2"></i> Close</a>
                                                                        </div>
                                                                    </div>
                                                                </c:when>
                                                                <%-- KHÔNG CÓ QUYỀN -> Khóa lại --%>
                                                                <c:otherwise>
                                                                    <div class="alert alert-secondary py-2 px-3 mb-0 mr-2 border d-flex align-items-center shadow-sm" style="font-size: 0.85rem; background: #fff;">
                                                                        <i class="feather icon-lock mr-2 text-muted"></i> 
                                                                        <span>Read Only. <a href="${pageContext.request.contextPath}/AssignTicket?id=${ticket.id}" class="font-weight-bold text-primary ml-1">Assign to me</a> to take action.</span>
                                                                    </div>
                                                                </c:otherwise>
                                                            </c:choose>
                                                        </c:otherwise>
                                                    </c:choose>

                                                    <c:if test="${ticket.ticketType == 'Incident' and (empty ticket.parentTicketId or ticket.parentTicketId == 0)}">
                                                        <button type="button" data-toggle="modal" data-target="#linkChildModal" class="btn btn-sm btn-outline-secondary bg-white font-weight-bold mr-2" title="Gom nhóm các vé con">
                                                            <i class="feather icon-layers mr-1"></i> Link Incidents
                                                        </button>
                                                    </c:if>

                                                    <c:if test="${sessionScope.role == 'IT Support'}">
                                                        <a href="${pageContext.request.contextPath}/ProblemAdd?sourceTicketId=${ticket.id}" class="btn btn-sm btn-outline-danger bg-white font-weight-bold">
                                                            <i class="feather icon-alert-triangle mr-1"></i> Escalate
                                                        </a>
                                                    </c:if>
                                                </div>
                                            </div>

                                            <h6 class="section-title"><i class="feather icon-align-left"></i> Description</h6>
                                            <div class="desc-box">
                                                <c:out value="${ticket.description}" default="No description provided."/>
                                            </div>

                                            <h6 class="section-title"><i class="feather icon-paperclip"></i> Attachments</h6>
                                            <div class="mb-5">
                                                <c:choose>
                                                    <c:when test="${not empty attachments}">
                                                        <div class="d-flex flex-wrap" style="gap: 10px;">
                                                            <c:forEach items="${attachments}" var="file">
                                                                <a href="${pageContext.request.contextPath}/DownloadFile?id=${file.fileId}" target="_blank" class="btn btn-sm btn-light border text-dark font-weight-bold">
                                                                    <i class="feather icon-file text-primary mr-1"></i> ${file.fileName}
                                                                </a>
                                                            </c:forEach>
                                                        </div>
                                                    </c:when>
                                                    <c:otherwise>
                                                        <span class="text-muted" style="font-size: 0.85rem; font-style: italic;">No files attached.</span>
                                                    </c:otherwise>
                                                </c:choose>
                                            </div>

                                            <div class="card-neat p-4 p-lg-5">
                                                <div class="section-title mb-4">
                                                    <i class="feather icon-message-square text-primary mr-3" style="font-size: 1.2rem;"></i> Communication
                                                </div>

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
                                        <div class="card-body p-4 position-relative">

                                            <div class="d-flex justify-content-between align-items-center mb-3">
                                                <h6 class="sidebar-section-title border-0 pb-0 mb-0 m-0 text-dark">Categorization</h6>
                                                <c:if test="${canEdit}">
                                                    <a href="javascript:void(0)" class="btn btn-sm btn-light text-primary border shadow-sm" data-toggle="modal" data-target="#editTicketModal" title="Update Category">
                                                        <i class="feather icon-edit-2 mr-1"></i> Edit
                                                    </a>
                                                </c:if>
                                            </div>
                                            
                                            <c:set var="parentCatName" value="Uncategorized" />
                                            <c:forEach items="${mainCategories}" var="mc">
                                                <c:if test="${mc.id == ticketParentCatId}">
                                                    <c:set var="parentCatName" value="${mc.name}" />
                                                </c:if>
                                            </c:forEach>

                                            <div class="meta-group">
                                                <span class="meta-label">Main Category (L1)</span>
                                                <div class="meta-value">
                                                    <c:choose>
                                                        <c:when test="${ticketParentCatId > 0}">
                                                            <div class="avatar-sm d-inline-flex align-items-center justify-content-center text-white rounded-circle mr-2" style="background-color: #f4f5f7; border: 1px solid #dfe1e6; color: #6b778c;">
                                                                ${parentCatName.substring(0, 1).toUpperCase()}
                                                            </div>
                                                            <span class="font-weight-bold text-dark">${parentCatName}</span>
                                                        </c:when>
                                                        <c:otherwise><span class="text-muted">Uncategorized</span></c:otherwise>
                                                    </c:choose>
                                                </div>
                                            </div>

                                            <div class="meta-group">
                                                <span class="meta-label">Sub-Category (L2)</span>
                                                <div class="meta-value">
                                                    <c:choose>
                                                        <c:when test="${not empty ticket.categoryName}">
                                                            <div class="avatar-sm d-inline-flex align-items-center justify-content-center text-white rounded-circle mr-2" style="background-color: #e9f2ff; color: #0052cc;">
                                                                ${ticket.categoryName.substring(0, 1).toUpperCase()}
                                                            </div>
                                                            <span class="font-weight-bold text-primary">${ticket.categoryName}</span>
                                                        </c:when>
                                                        <c:otherwise><span class="text-muted">Uncategorized</span></c:otherwise>
                                                    </c:choose>
                                                </div>
                                            </div>

                                            <h6 class="sidebar-section-title mt-4 pt-3">Details</h6>

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

                                            <h6 class="sidebar-section-title mt-4 pt-3">People</h6>
                                            
                                            <c:if test="${ticket.requiresApproval}">
                                                <div class="meta-group">
                                                    <span class="meta-label">Approval Status</span>
                                                    <div class="meta-value">
                                                        <c:choose>
                                                            <c:when test="${empty ticket.approvedBy && ticket.status == 'Awaiting Approval'}">
                                                                <span class="text-warning font-weight-bold"><i class="feather icon-clock"></i> Pending Manager</span>
                                                            </c:when>
                                                            <c:when test="${not empty ticket.approvedBy}">
                                                                <span class="text-success font-weight-bold"><i class="feather icon-check-circle"></i> Approved (User ID: ${ticket.approvedBy})</span>
                                                            </c:when>
                                                        </c:choose>
                                                    </div>
                                                </div>
                                            </c:if>

                                            <div class="meta-group">
                                                <span class="meta-label">Assignee</span>
                                                <div class="meta-value">
                                                    <c:choose>
                                                        <c:when test="${not empty ticket.assigneeName}">
                                                            <div class="avatar-sm d-inline-flex align-items-center justify-content-center text-white rounded-circle mr-2" style="background-color: #0052cc;">
                                                                ${ticket.assigneeName.substring(0, 2).toUpperCase()}
                                                            </div> 
                                                            <span class="font-weight-bold text-dark">${ticket.assigneeName}</span>
                                                            
                                                            
                                                            <c:if test="${isManager && !isOwner && ticket.status != 'Closed' && ticket.status != 'Resolved'}">
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
                                                                            <a href="${pageContext.request.contextPath}/AssignTicket?id=${ticket.id}" class="text-primary font-weight-bold mr-2" style="font-size: 0.8rem;" title="Nhận xử lý vé này">(Assign to me)</a>
                                                                            <a href="javascript:void(0)" data-toggle="modal" data-target="#assignModal" class="text-secondary font-weight-bold" style="font-size: 0.8rem;" title="Gán cho người khác">(Assign to...)</a>
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
                                                <span class="meta-label">Reporter</span>
                                                <div class="meta-value">
                                                    <div class="avatar-sm" style="background-color: #6b778c;"><i class="feather icon-user"></i></div> User ID: ${ticket.createdBy}
                                                </div>
                                            </div>

                                            <div class="d-flex justify-content-between align-items-center mt-4 pt-3 border-bottom pb-2 mb-3">
                                                <h6 class="sidebar-section-title border-0 pb-0 mb-0 m-0">Configuration Items</h6>
                                                <a href="${pageContext.request.contextPath}/TicketLinkCIListServlet" class="btn btn-sm btn-light text-primary border" title="Go to Asset Management page"><i class="feather icon-settings"></i> Manage CIs</a>
                                            </div>
                                            <div class="meta-group mb-0">
                                                <c:choose>
                                                    <c:when test="${not empty linkedAssets}">
                                                        <c:forEach items="${linkedAssets}" var="asset">
                                                            <div class="p-2 border rounded mb-2 bg-light d-flex align-items-center">
                                                                <i class="feather icon-monitor text-primary mx-2"></i>
                                                                <div>
                                                                    <div class="font-weight-bold text-dark" style="font-size: 0.85rem;">${asset.name}</div>
                                                                    <div class="text-muted" style="font-size: 0.75rem;">Tag: ${asset.assetTag}</div>
                                                                </div>
                                                            </div>
                                                        </c:forEach>
                                                    </c:when>
                                                    <c:otherwise>
                                                        <span class="text-muted font-italic" style="font-size: 0.85rem;">No linked assets</span>
                                                    </c:otherwise>
                                                </c:choose>
                                            </div>

                                            <div class="d-flex justify-content-between align-items-center mt-4 pt-3 border-bottom pb-2 mb-3">
                                                <h6 class="sidebar-section-title border-0 pb-0 mb-0 m-0">Incident Hierarchy</h6>
                                            </div>
                                            <div class="meta-group mb-0">
                                                <c:choose>
                                                    <c:when test="${not empty parentTicket}">
                                                        <div class="alert alert-info border-0 p-3" style="background-color: #e9f2ff; border-radius: 6px;">
                                                            <div class="font-weight-bold text-primary mb-1" style="font-size: 0.85rem;"><i class="feather icon-arrow-up-right mr-1"></i> Part of a Major Incident:</div>
                                                            <a href="TicketAgentDetail?id=${parentTicket.id}" class="text-dark font-weight-bold text-decoration-none">${parentTicket.ticketNumber}</a>
                                                            <div class="text-muted text-truncate mt-1" style="font-size: 0.8rem;">${parentTicket.title}</div>
                                                            <span class="badge badge-light border mt-2">${parentTicket.status}</span>
                                                        </div>
                                                    </c:when>
                                                    <c:when test="${not empty childTickets}">
                                                        <div class="text-muted mb-2 font-weight-bold" style="font-size: 0.75rem; text-transform: uppercase;">Child Tickets (${childTickets.size()})</div>
                                                        <div style="max-height: 250px; overflow-y: auto;">
                                                            <c:forEach items="${childTickets}" var="child">
                                                                <div class="p-2 border rounded mb-2 bg-light">
                                                                    <div class="d-flex justify-content-between align-items-center">
                                                                        <a href="TicketAgentDetail?id=${child.id}" class="font-weight-bold text-primary" style="font-size: 0.85rem;">${child.ticketNumber}</a>
                                                                        <span class="badge ${child.status == 'Resolved' ? 'badge-success' : 'badge-secondary'}" style="font-size: 0.7rem;">${child.status}</span>
                                                                    </div>
                                                                    <div class="text-dark text-truncate mt-1" style="font-size: 0.8rem;">${child.title}</div>
                                                                </div>
                                                            </c:forEach>
                                                        </div>
                                                    </c:when>
                                                    <c:otherwise>
                                                        <span class="text-muted font-italic" style="font-size: 0.85rem;">No linked incidents</span>
                                                    </c:otherwise>
                                                </c:choose>
                                            </div>

                                            <h6 class="sidebar-section-title mt-4 pt-3">Related Problem</h6>
                                            <div class="meta-group mb-0">
                                                <c:choose>
                                                    <c:when test="${not empty relatedProblem}">
                                                        <a href="${pageContext.request.contextPath}/ProblemDetail?id=${relatedProblem.id}" class="d-block p-2 border border-danger rounded bg-white text-decoration-none shadow-sm">
                                                            <div class="text-danger font-weight-bold" style="font-size: 0.85rem;"><i class="feather icon-alert-triangle mr-1"></i> ${relatedProblem.ticketNumber}</div>
                                                            <div class="text-dark text-truncate mt-1" style="font-size: 0.8rem;">${relatedProblem.title}</div>
                                                        </a>
                                                    </c:when>
                                                    <c:otherwise>
                                                        <span class="text-muted font-italic" style="font-size: 0.85rem;">No problem escalated</span>
                                                    </c:otherwise>
                                                </c:choose>
                                            </div>

                                            <c:if test="${sessionScope.role eq 'IT Support'}">
                                                <div class="mt-4 pt-3 border-top">
                                                    <div class="d-flex justify-content-between align-items-center mb-3">
                                                        <h6 class="sidebar-section-title border-0 pb-0 mb-0"><i class="feather icon-clock mr-1 text-primary"></i> Time Tracking</h6>
                                                        <c:if test="${totalHours > 0}">
                                                            <span class="badge badge-primary" style="font-size:0.8rem;"><fmt:formatNumber value="${totalHours}" pattern="#.##"/>h total</span>
                                                        </c:if>
                                                    </div>
                                                    <c:if test="${not empty timeLogFlashMsg}">
                                                        <div class="alert alert-${timeLogFlashType eq 'success' ? 'success' : 'danger'} alert-dismissible p-2 mb-3" style="font-size:0.82rem;" role="alert">
                                                            ${timeLogFlashMsg}
                                                            <button type="button" class="close py-1 px-2" data-dismiss="alert"><span>&times;</span></button>
                                                        </div>
                                                    </c:if>
                                                    <c:choose>
                                                        <c:when test="${ticket.status eq 'Resolved' or ticket.status eq 'Closed'}">
                                                            <button type="button" class="btn btn-sm btn-outline-primary btn-block mb-3" onclick="openTimeLogModal()"><i class="feather icon-plus mr-1"></i> Log Time</button>
                                                        </c:when>
                                                        <c:otherwise>
                                                            <div class="p-2 mb-3 rounded text-center" style="background:#f4f5f7; border:1px dashed #dfe1e6; font-size:0.78rem; color:#a5adba;">
                                                                <i class="feather icon-lock mr-1"></i> Available after ticket is resolved
                                                            </div>
                                                        </c:otherwise>
                                                    </c:choose>
                                                    <c:choose>
                                                        <c:when test="${not empty timeLogs}">
                                                            <div style="max-height:280px; overflow-y:auto;">
                                                                <c:forEach var="log" items="${timeLogs}">
                                                                    <div class="p-2 border rounded mb-2 bg-light" style="font-size:0.78rem;">
                                                                        <div class="d-flex justify-content-between align-items-start">
                                                                            <span class="font-weight-bold text-dark">${log.fullName}</span>
                                                                            <span class="text-primary font-weight-bold ml-2" style="white-space:nowrap;"><fmt:formatNumber value="${log.hours}" pattern="#.##"/>h</span>
                                                                        </div>
                                                                        <c:if test="${not empty log.note}"><div class="text-dark mt-1">${log.note}</div></c:if>
                                                                        <div class="text-muted mt-1"><fmt:formatDate value="${log.logDate}" pattern="dd/MM/yyyy"/></div>
                                                                    </div>
                                                                </c:forEach>
                                                            </div>
                                                        </c:when>
                                                        <c:otherwise><p class="text-muted font-italic" style="font-size:0.82rem;">No time logged yet.</p></c:otherwise>
                                                    </c:choose>
                                                </div>
                                            </c:if>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <%-- ════════════════════════════════════════════════════════════════════════ --%>
        <%-- MODALS --%>
        <%-- ════════════════════════════════════════════════════════════════════════ --%>

        <div class="modal fade" id="editTicketModal" tabindex="-1" role="dialog" aria-hidden="true">
            <div class="modal-dialog modal-dialog-centered" role="document">
                <div class="modal-content border-0 shadow-lg" style="border-radius: 8px;">
                    <div class="modal-header bg-light border-bottom-0 p-4">
                        <h5 class="modal-title font-weight-bold text-dark"><i class="feather icon-edit-2 text-primary mr-2"></i>Update Categorization</h5>
                        <button type="button" class="close" data-dismiss="modal" aria-label="Close"><span aria-hidden="true">&times;</span></button>
                    </div>
                    <form action="${pageContext.request.contextPath}/EditTicket" method="POST">
                        <div class="modal-body p-4">
                            <input type="hidden" name="ticketId" value="${ticket.id}">
                            
                            <div class="form-group mb-3">
                                <label class="font-weight-bold text-dark mb-2">Main Category (L1) <span class="text-danger">*</span></label>
                                <select id="editMainCategory" class="form-control select2-main" required style="width: 100%;">
                                    <option value="" disabled>-- Chọn danh mục chính --</option>
                                    <c:forEach items="${mainCategories}" var="cat">
                                        <option value="${cat.id}" ${ticketParentCatId == cat.id ? 'selected' : ''}>${cat.name}</option>
                                    </c:forEach>
                                </select>
                            </div>

                            <div class="form-group mb-4">
                                <label class="font-weight-bold text-dark mb-2">Sub-Category (L2) <span class="text-danger">*</span></label>
                                <select name="categoryId" id="editSubCategory" class="form-control select2-sub" required style="width: 100%;">
                                    <option value="" disabled>-- Chọn danh mục con --</option>
                                </select>
                            </div>

                            <c:if test="${ticket.ticketType == 'Incident'}">
                                <div class="row">
                                    <div class="col-md-6 form-group">
                                        <label class="font-weight-bold text-dark mb-2">Impact <span class="text-danger">*</span></label>
                                        <select name="impact" class="form-control" required style="border-radius: 6px; height: 42px;">
                                            <option value="1" ${ticket.impact == 1 ? 'selected' : ''}>1 - Extensive (Widespread)</option>
                                            <option value="2" ${ticket.impact == 2 ? 'selected' : ''}>2 - Significant (Large)</option>
                                            <option value="3" ${ticket.impact == 3 ? 'selected' : ''}>3 - Moderate (Small)</option>
                                        </select>
                                    </div>
                                    <div class="col-md-6 form-group">
                                        <label class="font-weight-bold text-dark mb-2">Urgency <span class="text-danger">*</span></label>
                                        <select name="urgency" class="form-control" required style="border-radius: 6px; height: 42px;">
                                            <option value="1" ${ticket.urgency == 1 ? 'selected' : ''}>1 - Critical (Business down)</option>
                                            <option value="2" ${ticket.urgency == 2 ? 'selected' : ''}>2 - High (Work impaired)</option>
                                            <option value="3" ${ticket.urgency == 3 ? 'selected' : ''}>3 - Low (Workaround available)</option>
                                        </select>
                                    </div>
                                </div>
                                <small class="text-muted"><i class="feather icon-info mr-1"></i>Priority and SLA will be automatically recalculated upon saving.</small>
                            </c:if>
                        </div>
                        <div class="modal-footer border-top-0 p-4 pt-0">
                            <button type="button" class="btn btn-light font-weight-bold px-4" data-dismiss="modal">Cancel</button>
                            <button type="submit" class="btn btn-primary font-weight-bold px-4 shadow-sm">Save Changes</button>
                        </div>
                    </form>
                </div>
            </div>
        </div>

        <div class="modal fade" id="assignModal" tabindex="-1" role="dialog" aria-hidden="true">
            <div class="modal-dialog modal-dialog-centered" role="document">
                <div class="modal-content border-0 shadow-lg" style="border-radius: 8px;">
                    <div class="modal-header bg-light border-bottom-0 p-4">
                        <h5 class="modal-title font-weight-bold text-dark"><i class="feather icon-user-check text-primary mr-2"></i>Assign Ticket to Agent</h5>
                        <button type="button" class="close" data-dismiss="modal" aria-label="Close"><span aria-hidden="true">&times;</span></button>
                    </div>
                    <form action="${pageContext.request.contextPath}/AssignTicket" method="POST">
                        <div class="modal-body p-4">
                            <input type="hidden" name="ticketId" id="assignModalTicketId" value="${ticket.id}">
                            <div class="form-group">
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

        <div class="modal fade" id="linkChildModal" tabindex="-1" role="dialog" aria-hidden="true">
            <div class="modal-dialog modal-dialog-centered modal-lg" role="document">
                <div class="modal-content border-0 shadow-lg" style="border-radius: 8px;">
                    <div class="modal-header bg-light border-bottom-0 p-4">
                        <h5 class="modal-title font-weight-bold text-dark"><i class="feather icon-layers text-primary mr-2"></i>Link Child Incidents</h5>
                        <button type="button" class="close" data-dismiss="modal"><span aria-hidden="true">&times;</span></button>
                    </div>
                    <form action="${pageContext.request.contextPath}/LinkChildTicket" method="POST">
                        <div class="modal-body p-4">
                            <input type="hidden" name="ticketId" value="${ticket.id}">
                            <p class="text-muted mb-3">Select the tickets that are caused by this major incident. Resolving this ticket will automatically resolve all linked child tickets.</p>
                            <div class="table-responsive" style="max-height: 300px; overflow-y: auto; border: 1px solid #dfe1e6; border-radius: 6px;">
                                <table class="table table-hover mb-0">
                                    <thead style="background-color: #f4f5f7; position: sticky; top: 0; z-index: 1;">
                                        <tr>
                                            <th width="5%" class="text-center">✔</th>
                                            <th width="20%">Ticket Key</th>
                                            <th width="55%">Summary</th>
                                            <th width="20%">Status</th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        <c:choose>
                                            <c:when test="${not empty availableTicketsForLinking}">
                                                <c:forEach items="${availableTicketsForLinking}" var="avlTicket">
                                                    <tr>
                                                        <td class="text-center"><input type="checkbox" name="childTicketIds" value="${avlTicket.id}" style="transform: scale(1.2);"></td>
                                                        <td class="font-weight-bold text-primary">${avlTicket.ticketNumber}</td>
                                                        <td class="text-dark text-truncate" style="max-width: 250px;">${avlTicket.title}</td>
                                                        <td><span class="badge badge-light border">${avlTicket.status}</span></td>
                                                    </tr>
                                                </c:forEach>
                                            </c:when>
                                            <c:otherwise><tr><td colspan="4" class="text-center text-muted py-4">No active tickets available for linking.</td></tr></c:otherwise>
                                        </c:choose>
                                    </tbody>
                                </table>
                            </div>
                        </div>
                        <div class="modal-footer border-top-0 p-4 pt-0">
                            <button type="button" class="btn btn-light font-weight-bold px-4" data-dismiss="modal">Cancel</button>
                            <button type="submit" class="btn btn-primary font-weight-bold px-4 shadow-sm">Link Selected Tickets</button>
                        </div>
                    </form>
                </div>
            </div>
        </div>

        <div id="timeLogModalBackdrop" onclick="closeTimeLogOnBackdrop(event)" style="display:none; position:fixed; inset:0; background:rgba(0,0,0,0.45); z-index:1050; align-items:center; justify-content:center;">
            <div style="background:#fff; border-radius:12px; width:100%; max-width:440px; padding:28px 32px; box-shadow:0 8px 40px rgba(0,0,0,0.18); position:relative;" onclick="event.stopPropagation()">
                <div class="d-flex justify-content-between align-items-center mb-4">
                    <h5 style="margin:0; font-size:1rem; font-weight:700; color:#172b4d;"><i class="feather icon-clock mr-2" style="color:#0052cc;"></i>Log Time</h5>
                    <button onclick="closeTimeLogModal()" style="background:none;border:none;cursor:pointer;color:#6b778c;font-size:1.2rem;padding:0;"><i class="feather icon-x"></i></button>
                </div>
                <div class="form-group mb-3">
                    <label style="font-size:0.75rem;font-weight:600;color:#5e6c84;text-transform:uppercase;letter-spacing:0.4px;">Performed by</label>
                    <input type="text" value="${sessionScope.user.fullName}" class="form-control form-control-sm" readonly style="background:#f4f5f7; color:#172b4d; font-weight:600; border:1px solid #dfe1e6;">
                </div>
                <form action="${pageContext.request.contextPath}/TicketTimeLog" method="post" id="timeLogForm" onsubmit="return validateTimeLogForm()">
                    <input type="hidden" name="action" value="logManual">
                    <input type="hidden" name="ticketId" value="${ticket.id}">
                    <div class="form-group mb-3">
                        <label style="font-size:0.75rem;font-weight:600;color:#5e6c84;text-transform:uppercase;letter-spacing:0.4px;">Time Spent <span class="text-danger">*</span></label>
                        <div class="d-flex align-items-center" style="gap:8px;">
                            <input type="number" name="hours" id="tlHours" class="form-control form-control-sm" min="0" step="1" placeholder="0" style="width:80px; text-align:center;" oninput="updateTimeDisplay()">
                            <span style="color:#6b778c; font-size:0.85rem;">h</span>
                            <input type="number" name="minutes" id="tlMinutes" class="form-control form-control-sm" min="0" max="59" step="1" placeholder="0" style="width:80px; text-align:center;" oninput="updateTimeDisplay()">
                            <span style="color:#6b778c; font-size:0.85rem;">min</span>
                        </div>
                        <div id="tlTimePreview" style="font-size:0.75rem; color:#0052cc; margin-top:5px; font-weight:600;"></div>
                    </div>
                    <div class="form-group mb-4">
                        <label style="font-size:0.75rem;font-weight:600;color:#5e6c84;text-transform:uppercase;letter-spacing:0.4px;">Work Description <span class="text-danger">*</span></label>
                        <textarea name="note" id="tlNote" rows="3" class="form-control form-control-sm" placeholder="Describe what you worked on..." maxlength="500" required style="resize:vertical; border:1px solid #dfe1e6; border-radius:6px; font-size:0.9rem; padding:8px 12px;"></textarea>
                        <div style="text-align:right; font-size:0.7rem; color:#a5adba; margin-top:2px;"><span id="tlNoteCount">0</span>/500</div>
                    </div>
                    <div class="d-flex justify-content-end" style="gap:10px;">
                        <button type="button" onclick="closeTimeLogModal()" class="btn btn-sm" style="border:1.5px solid #dfe1e6; color:#6b778c; background:#fff; padding:7px 20px; border-radius:6px; font-weight:600;">Cancel</button>
                        <button type="submit" class="btn btn-sm btn-primary" style="padding:7px 24px; border-radius:6px; font-weight:600;"><i class="feather icon-check mr-1"></i> Save Log</button>
                    </div>
                </form>
            </div>
        </div>

        <script src="${pageContext.request.contextPath}/assets/plugins/jquery/js/jquery.min.js"></script>
        <script src="${pageContext.request.contextPath}/assets/js/vendor-all.min.js"></script>
        <script src="${pageContext.request.contextPath}/assets/plugins/bootstrap/js/bootstrap.min.js"></script>
        <script src="${pageContext.request.contextPath}/assets/js/pcoded.min.js"></script>
        
        <link href="https://cdn.jsdelivr.net/npm/select2@4.1.0-rc.0/dist/css/select2.min.css" rel="stylesheet" />
        <script src="https://cdn.jsdelivr.net/npm/select2@4.1.0-rc.0/dist/js/select2.min.js"></script>

        <script>
            // PRE-LOAD TOÀN BỘ SUB-CATEGORY VÀO MỘT BIẾN JS (JSON-like array)
            const allSubCategories = [
                <c:forEach items="${subCategories}" var="cat" varStatus="loop">
                    { id: ${cat.id}, parentId: ${cat.parentId}, name: "${cat.name.replace('"', '\\"')}" }${!loop.last ? ',' : ''}
                </c:forEach>
            ];

            $(document).ready(function() {
                // Khởi tạo select2 cho 2 ô chọn (Kích hoạt Search)
                $('.select2-main, .select2-sub').select2({
                    dropdownParent: $('#editTicketModal'),
                    width: '100%',
                    theme: "classic" 
                });
                
                // === LOGIC PHÂN CẤP BẬC THANG (CASCADING) ===
                function filterSubCategories(parentId, preSelectId) {
                    const $subSelect = $('#editSubCategory');
                    
                    // Xóa hết options cũ và reset
                    $subSelect.empty().trigger('change');
                    $subSelect.append('<option value="" disabled>-- Chọn danh mục con --</option>');
                    
                    // Lọc lấy danh mục con tương ứng
                    const filteredCats = allSubCategories.filter(cat => cat.parentId === parseInt(parentId));
                    
                    if (filteredCats.length > 0) {
                        // Nạp động Options mới
                        filteredCats.forEach(cat => {
                            const isSelected = (cat.id === parseInt(preSelectId));
                            const newOption = new Option(cat.name, cat.id, isSelected, isSelected);
                            $subSelect.append(newOption);
                        });
                        $subSelect.prop('disabled', false); // Mở khóa
                    } else {
                        // Nếu không có con, nạp option mặc định và khóa
                        $subSelect.append('<option value="" disabled>-- Không có danh mục con --</option>');
                        $subSelect.prop('disabled', true);
                    }
                    
                    // Cập nhật lại giao diện Select2
                    $subSelect.trigger('change');
                }

                // LẮNG NGHE SỰ KIỆN: Khi thay đổi Ô Category chính
                $('#editMainCategory').on('change', function() {
                    const newParentId = $(this).val();
                    if(newParentId) {
                        filterSubCategories(newParentId, 0); // Nạp lại con, không pre-select
                    }
                });
                
                // === CHẠY LẦN ĐẦU (INITIAL LOAD) ===
                const currentParentId = '${ticketParentCatId}';
                const currentSubId = '${ticket.categoryId}';
                
                if (currentParentId && currentParentId !== '0') {
                    // Nếu vé đã có cate chính, nạp con và pre-select con
                    filterSubCategories(currentParentId, currentSubId);
                } else if ($('#editMainCategory').val()) {
                    // Nếu vé chưa có cate chính (bản cũ), nhưng DB có sẵn cha
                    filterSubCategories($('#editMainCategory').val(), currentSubId);
                } else {
                    // Mặc định khóa ô Sub cho đến khi chọn cha
                    $('#editSubCategory').prop('disabled', true).trigger('change');
                }

                // Ghi đè một chút CSS để khung Select2 cao bằng khung input của Bootstrap (42px)
                $('.select2-container--classic .select2-selection--single').css({
                    'height': '42px',
                    'border-radius': '6px',
                    'border': '1px solid #dfe1e6',
                    'display': 'flex',
                    'align-items': 'center'
                });
                $('.select2-container--classic .select2-selection--single .select2-selection__arrow').css('height', '40px');
            });
            
            function toggleComment(mode, element) {
                $('.comment-tab').removeClass('active-reply active-note');
                var area = $('#commentArea');
                var btn = $('#btnSubmitComment');
                var input = $('#isInternalInput');
                if (mode === 'reply') {
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

            function openTimeLogModal() {
                document.getElementById('timeLogModalBackdrop').style.display = 'flex';
                document.getElementById('tlHours').focus();
            }

            function closeTimeLogModal() {
                document.getElementById('timeLogModalBackdrop').style.display = 'none';
                document.getElementById('timeLogForm').reset();
                document.getElementById('tlTimePreview').textContent = '';
                document.getElementById('tlNoteCount').textContent = '0';
            }

            function closeTimeLogOnBackdrop(e) {
                if (e.target === document.getElementById('timeLogModalBackdrop')) {
                    closeTimeLogModal();
                }
            }

            function updateTimeDisplay() {
                var h = parseInt(document.getElementById('tlHours').value) || 0;
                var m = parseInt(document.getElementById('tlMinutes').value) || 0;
                var preview = document.getElementById('tlTimePreview');
                if (h === 0 && m === 0) { 
                    preview.textContent = ''; 
                    return;
                }
                
                var parts = [];
                if (h > 0) parts.push(h + ' hour' + (h > 1 ? 's' : ''));
                if (m > 0) parts.push(m + ' minute' + (m > 1 ? 's' : ''));
                preview.textContent = '= ' + parts.join(' ');
            }

            document.getElementById('tlNote').addEventListener('input', function () {
                document.getElementById('tlNoteCount').textContent = this.value.length;
            });

            function validateTimeLogForm() {
                var h = parseInt(document.getElementById('tlHours').value) || 0;
                var m = parseInt(document.getElementById('tlMinutes').value) || 0;
                var note = document.getElementById('tlNote').value.trim();
                
                if (h === 0 && m === 0) { 
                    alert('Please enter time spent (hours and/or minutes).'); 
                    return false;
                }
                if (note === '') { 
                    alert('Please enter a work description.');
                    return false; 
                }
                
                var totalHours = h + (m / 60);
                document.getElementById('tlHours').value = totalHours.toFixed(4);
                document.getElementById('tlMinutes').disabled = true;
                return true;
            }
        </script>
</body>
</html>