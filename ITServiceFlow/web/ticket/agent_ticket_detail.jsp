<%-- 
    Document   : agent_ticket_detail
    Created on : Mar 14, 2026
    Author     : Dumb Trung
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<%@ taglib uri="jakarta.tags.fmt" prefix="fmt" %>
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
        /* Typography & Layout Polish (From User View) */
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

        /* Description Box */
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

        /* Agent Specific: Comment Area */
        .comment-tabs { display: flex; gap: 10px; margin-bottom: 15px; border-bottom: 2px solid #ebecf0; padding-bottom: 10px;}
        .comment-tab { padding: 6px 16px; border-radius: 20px; font-size: 0.85rem; font-weight: 600; color: #5e6c84; background: transparent; cursor: pointer; transition: 0.2s;}
        .comment-tab:hover { background: #f4f5f7; }
        .comment-tab.active-reply { background: #e9f2ff; color: #0052cc; }
        .comment-tab.active-note { background: #fff0b3; color: #ff8b00; }
        .editor-area { border-radius: 6px; border: 1px solid #dfe1e6; font-size: 0.95rem; background-color: #fafbfc;}
        .editor-area:focus { background-color: #fff; box-shadow: 0 0 0 2px rgba(0,82,204,0.2); border-color: #0052cc;}
        .editor-area.note-mode { background-color: #fffdf5; border-color: #ffc400; }
        .editor-area.note-mode:focus { box-shadow: 0 0 0 2px rgba(255,196,0,0.2); }

        /* Priority Colors */
        .prio-high { color: #ff5630; margin-right: 6px; }
        .prio-medium { color: #ff8b00; margin-right: 6px; }
        .prio-low { color: #00875a; margin-right: 6px; }
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
                                        <li class="breadcrumb-item"><a href="${pageContext.request.contextPath}/Agent/Queues" class="text-primary"><i class="feather icon-arrow-left mr-1"></i>Back to Queues</a></li>
                                        <li class="breadcrumb-item text-muted">${ticket.ticketType}</li>
                                        <li class="breadcrumb-item text-muted">${ticket.ticketNumber}</li>
                                    </ul>
                                </div>
                            </div>
                        </div>
                    </div>

                    <div class="main-body">
                        <div class="page-wrapper p-0">
                            
                            <c:choose>
                                <c:when test="${not empty slaTracking}">
                                    <div class="alert ${isSlaBreached ? 'alert-danger' : 'alert-warning'} p-3 mb-4 border-0 d-flex justify-content-between align-items-center" style="border-radius: 6px;">
                                        <div>
                                            <i class="feather icon-clock font-weight-bold mr-2" style="font-size: 1.1rem;"></i> 
                                            <span style="font-size: 0.9rem;"><strong>Resolution SLA:</strong> Deadline is <fmt:formatDate value="${slaTracking.resolutionDeadline}" pattern="dd/MM/yyyy HH:mm" /></span>
                                        </div>
                                        <c:if test="${isSlaBreached}"><span class="badge badge-danger px-2 py-1" style="font-size: 0.8rem; letter-spacing: 0.5px;">BREACHED</span></c:if>
                                    </div>
                                </c:when>
                            </c:choose>

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
                                                    <div class="dropdown mr-2">
                                                        <button class="btn btn-sm btn-primary dropdown-toggle shadow-sm font-weight-bold" type="button" data-toggle="dropdown">
                                                            ${ticket.status == 'New' ? 'Start Progress' : ticket.status}
                                                        </button>
                                                        <div class="dropdown-menu dropdown-menu-right mt-1 shadow-sm">
                                                            <a class="dropdown-item py-2" href="UpdateStatus?id=${ticket.id}&status=In Progress">In Progress</a>
                                                            <div class="dropdown-divider"></div>
                                                            <a class="dropdown-item text-success font-weight-bold py-2" href="UpdateStatus?id=${ticket.id}&status=Resolved"><i class="feather icon-check-circle mr-2"></i> Resolve Ticket</a>
                                                            <a class="dropdown-item text-secondary py-2" href="UpdateStatus?id=${ticket.id}&status=Closed"><i class="feather icon-archive mr-2"></i> Close</a>
                                                        </div>
                                                    </div>
                                                    <a href="${pageContext.request.contextPath}/CreateProblem?sourceTicketId=${ticket.id}" class="btn btn-sm btn-outline-danger bg-white font-weight-bold">
                                                        <i class="feather icon-alert-triangle mr-1"></i> Escalate
                                                    </a>
                                                </div>
                                            </div>

                                            <h6 class="section-title"><i class="feather icon-align-left"></i> Description</h6>
                                            <div class="desc-box"><c:out value="${ticket.description}" default="No description provided."/></div>

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
                                                        <span class="text-muted" style="font-size: 0.85rem; font-style: italic;">No files attached to this request.</span>
                                                    </c:otherwise>
                                                </c:choose>
                                            </div>

                                            <div class="mt-2">
                                                <h6 class="section-title"><i class="feather icon-message-square"></i> Communication</h6>
                                                
                                                <div class="comment-tabs">
                                                    <div class="comment-tab active-reply" onclick="toggleComment('reply', this)"><i class="feather icon-corner-up-left mr-1"></i> Reply to User</div>
                                                    <div class="comment-tab" onclick="toggleComment('note', this)"><i class="feather icon-lock mr-1"></i> Internal Note</div>
                                                </div>
                                                
                                                <form action="AddComment" method="POST">
                                                    <input type="hidden" name="ticketId" value="${ticket.id}">
                                                    <input type="hidden" name="isInternal" id="isInternalInput" value="false">
                                                    
                                                    <textarea class="form-control editor-area p-3" id="commentArea" rows="4" placeholder="Type your response to the user here..."></textarea>
                                                    <div class="text-right mt-3">
                                                        <button type="submit" class="btn btn-primary px-4 py-2 font-weight-bold" id="btnSubmitComment">Save Reply</button>
                                                    </div>
                                                </form>
                                            </div>

                                        </div>
                                    </div>
                                </div>

                                <div class="col-lg-4">
                                    <div class="card border-0">
                                        <div class="card-body p-4">

                                            <h6 class="sidebar-section-title">Details</h6>

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

                                            <div class="meta-group mb-0">
                                                <span class="meta-label">Category</span>
                                                <div class="meta-value">
                                                    ${not empty ticket.categoryName ? ticket.categoryName : 'Uncategorized'}
                                                </div>
                                            </div>

                                            <h6 class="sidebar-section-title mt-4 pt-3">People</h6>

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
                                                            <span class="text-muted mr-2">Unassigned</span>
                                                            <a href="AssignTicket?id=${ticket.id}" class="text-primary font-weight-bold" style="font-size: 0.8rem;">(Assign to me)</a>
                                                        </c:otherwise>
                                                    </c:choose>
                                                </div>
                                            </div>

                                            <div class="meta-group mb-0">
                                                <span class="meta-label">Reporter</span>
                                                <div class="meta-value">
                                                    <div class="avatar-sm" style="background-color: #6b778c;"><i class="feather icon-user"></i></div>
                                                    User ID: ${ticket.createdBy}
                                                </div>
                                            </div>

                                            <div class="d-flex justify-content-between align-items-center mt-4 pt-3 border-bottom pb-2 mb-3">
                                                <h6 class="sidebar-section-title border-0 pb-0 mb-0 m-0">Configuration Items</h6>
                                                <a href="#!" class="text-primary" title="Link Asset"><i class="feather icon-plus-circle" style="font-size: 1.1rem;"></i></a>
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