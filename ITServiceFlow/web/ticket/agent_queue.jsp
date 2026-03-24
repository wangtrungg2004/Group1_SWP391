<%-- 
    Document   : agent_queue
    Created on : Mar 14, 2026, 11:01:59 PM
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
    <title>Agent Workspace - ITServiceFlow</title>
    <meta name="ctx" content="${pageContext.request.contextPath}">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/fonts/fontawesome/css/fontawesome-all.min.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/plugins/bootstrap/css/bootstrap.min.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/style.css">
    
    <style>
        /* Horizontal Queue Navigation */
        .queue-nav { display: flex; gap: 10px; margin-bottom: 20px; border-bottom: 2px solid #dfe1e6; padding-bottom: 15px;}
        .queue-pill { padding: 8px 16px; border-radius: 20px; font-size: 0.9rem; font-weight: 600; color: #5e6c84; background: #f4f5f7; text-decoration: none; transition: 0.2s;}
        .queue-pill:hover { background: #ebecf0; color: #172b4d; text-decoration: none;}
        .queue-pill.active { background: #0052cc; color: white; box-shadow: 0 4px 8px rgba(0,82,204,0.2);}
        .queue-pill i { margin-right: 6px; }

        /* Filter toolbar styles */
        .filter-toolbar { background: #f4f5f7; padding: 15px; border-radius: 6px; margin-bottom: 20px; display: flex; gap: 15px; align-items: center; flex-wrap: wrap; border: 1px solid #dfe1e6; }
        .filter-toolbar .form-control { border: 1px solid #c1c7d0; height: 38px; }

        /* Table & Typography */
        .jira-table { border-collapse: separate; border-spacing: 0; width: 100%; border: 1px solid #dfe1e6; border-radius: 6px; overflow: hidden; background: white;}
        .jira-table th { background: #f4f5f7; font-size: 0.75rem; text-transform: uppercase; color: #5e6c84; font-weight: 600; padding: 12px 16px; border-bottom: 1px solid #dfe1e6;}
        .jira-table td { padding: 12px 16px; vertical-align: middle; border-bottom: 1px solid #dfe1e6; color: #172b4d; }
        .jira-table tr:last-child td { border-bottom: none; }
        .jira-table tr:hover td { background-color: #fafbfc; }
        .ticket-key { font-weight: 600; color: #0052cc; font-size: 0.95rem;}
        
        .sla-badge-placeholder { border: 1px dashed #ff8b00; color: #ff8b00; font-size: 0.75rem; padding: 4px 8px; border-radius: 4px; font-weight: bold; display: inline-block;}

        /* ── Quick Action Panel ── */
        .tr-wrap { position: relative; }
        .quick-actions {
            display: none;
            position: absolute;
            right: 12px;
            top: 50%; transform: translateY(-50%);
            background: #fff;
            border: 1px solid #dfe1e6;
            border-radius: 8px;
            box-shadow: 0 4px 16px rgba(0,0,0,0.12);
            padding: 6px 8px;
            gap: 4px;
            align-items: center;
            z-index: 10;
            white-space: nowrap;
        }
        .jira-table tbody tr:hover .quick-actions { display: flex; }
        .btn-qa {
            border: none;
            border-radius: 5px;
            padding: 5px 10px;
            font-size: 0.78rem;
            font-weight: 600;
            cursor: pointer;
            transition: background .15s;
            display: inline-flex; align-items: center; gap: 4px;
        }
        .btn-qa-view   { background: #deebff; color: #0052cc; }
        .btn-qa-assign { background: #e3fcef; color: #006644; }
        .btn-qa-status { background: #fff0b3; color: #974f0c; }
        .btn-qa-view:hover   { background: #b3d4ff; }
        .btn-qa-assign:hover { background: #abf5d1; }
        .btn-qa-status:hover { background: #ffe380; }
        .qa-divider { width: 1px; height: 20px; background: #dfe1e6; margin: 0 2px; }

        /* status quick-change dropdown */
        .status-dropdown {
            position: absolute;
            right: 0; top: calc(100% + 4px);
            background: #fff;
            border: 1px solid #dfe1e6;
            border-radius: 6px;
            box-shadow: 0 4px 12px rgba(0,0,0,0.1);
            min-width: 160px;
            z-index: 100;
            display: none;
        }
        .status-dropdown.show { display: block; }
        .status-opt {
            padding: 8px 14px;
            font-size: 0.83rem;
            cursor: pointer;
            color: #172b4d;
        }
        .status-opt:hover { background: #f4f5f7; }
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
                                    <div class="page-header-title"><h5 class="m-b-10">IT Service Desk</h5></div>
                                    <ul class="breadcrumb">
                                        <li class="breadcrumb-item"><a href="#!"><i class="feather icon-briefcase"></i> Agent Workspace</a></li>
                                    </ul>
                                </div>
                            </div>
                        </div>
                    </div>

                    <div class="main-body">
                        <div class="page-wrapper p-0">
                            <div class="row">
                                <div class="col-12">
                                    
                                   <div class="queue-nav">
    <a href="?queue=unassigned" class="queue-pill ${currentQueue == 'unassigned' ? 'active' : ''}"><i class="feather icon-inbox"></i> Unassigned (Triage)</a>
    <a href="?queue=mine" class="queue-pill ${currentQueue == 'mine' ? 'active' : ''}"><i class="feather icon-user"></i> Assigned to me</a>
    <a href="?queue=all_active" class="queue-pill ${currentQueue == 'all_active' ? 'active' : ''}"><i class="feather icon-list"></i> All Open</a>
    <a href="?queue=resolved" class="queue-pill ${currentQueue == 'resolved' ? 'active' : ''}"><i class="feather icon-check-circle"></i> Resolved</a>
</div>

                                    <form action="${pageContext.request.contextPath}/Queues" method="GET" class="filter-toolbar">
    <input type="hidden" name="queue" value="${currentQueue}">
    
    <div class="input-group" style="max-width: 350px; flex: 1;">
        <div class="input-group-prepend"><span class="input-group-text bg-white border-right-0"><i class="feather icon-search"></i></span></div>
        <input type="text" name="search" value="${search}" class="form-control border-left-0" placeholder="Search key, summary...">
        <div class="input-group-append">
            <button type="submit" class="btn btn-primary px-3" title="Click to search"><i class="feather icon-search mr-1"></i> Search</button>
        </div>
    </div>

    <div class="d-flex align-items-center gap-2">
        <select name="status" class="form-control" style="width: 160px;">
            <option value="all" ${selectedStatus == 'all' ? 'selected' : ''}>All Statuses</option>
            <option value="New" ${selectedStatus == 'New' ? 'selected' : ''}>Pending / New</option>
            <option value="In Progress" ${selectedStatus == 'In Progress' ? 'selected' : ''}>In Progress</option>
            <option value="Reopened" ${selectedStatus == 'Reopened' ? 'selected' : ''}>Reopened</option>
        </select>

        <select name="ticketType" class="form-control" style="width: 160px;">
            <option value="all" ${selectedTicketType == 'all' ? 'selected' : ''}>All Types</option>
            <option value="Incident" ${selectedTicketType == 'Incident' ? 'selected' : ''}>Incidents</option>
            <option value="ServiceRequest" ${selectedTicketType == 'ServiceRequest' ? 'selected' : ''}>Requests</option>
        </select>

        <button type="submit" class="btn btn-secondary shadow-sm"><i class="feather icon-filter mr-1"></i> Apply Filter</button>
    </div>

    <c:if test="${not empty search or selectedStatus != 'all' or selectedTicketType != 'all'}">
        <a href="${pageContext.request.contextPath}/Queues?queue=${currentQueue}" class="btn btn-link text-muted font-weight-bold" style="text-decoration: none;"><i class="feather icon-rotate-ccw mr-1"></i> Reset</a>
    </c:if>
</form>

                                    <div class="card border-0 shadow-sm">
                                        <div class="table-responsive">
                                            <table class="table jira-table mb-0">
                                                <thead>
                                                    <tr>
                                                        <th width="10%">Key</th>
                                                        <th width="30%">Summary</th>
                                                        <th width="10%">Priority</th>
                                                        <th width="15%">SLA Deadline</th>
                                                        <th width="15%">Assignee</th>
                                                        <th width="10%">Status</th>
                                                        <th width="10%">Action</th>
                                                    </tr>
                                                </thead>
                                                <tbody>
                                                    <c:if test="${empty queueList}">
                                                        <tr><td colspan="7" class="text-center py-5 text-muted"><i class="feather icon-check-circle d-block mb-2" style="font-size: 2rem;"></i> Queue is empty. Great job!</td></tr>
                                                    </c:if>
                                                    <c:forEach items="${queueList}" var="ticket">
                                                        <tr class="tr-wrap" style="position:relative;">
                                                            <td><a href="${pageContext.request.contextPath}/TicketAgentDetail?id=${ticket.id}" class="ticket-key">${ticket.ticketNumber}</a></td>
                                                            <td>
                                                                <div class="font-weight-bold text-dark">${ticket.title}</div>
                                                                <small class="text-muted"><fmt:formatDate value="${ticket.createdAt}" pattern="dd/MM/yyyy HH:mm"/></small>
                                                            </td>
                                                            <td>
                                                                <span class="badge ${ticket.priorityLevel == 'High' ? 'badge-danger' : 'badge-warning'}">${ticket.priorityLevel}</span>
                                                            </td>
                                                            
                                                            <%-- Khai báo biến thời gian hiện tại --%>
                                                    <jsp:useBean id="now" class="java.util.Date" />
                                                            <td>
                                                                <c:choose>
                                                                    <c:when test="${not empty ticket.resolutionDeadline}">
                                                                        <c:choose>
                                                                            <c:when test="${ticket.resolutionDeadline.time < now.time}">
                                                                                <span class="badge badge-danger p-2" title="SLA Breached!"><i class="feather icon-alert-octagon mr-1"></i> <fmt:formatDate value="${ticket.resolutionDeadline}" pattern="dd/MM HH:mm"/></span>
                                                                            </c:when>
                                                                            <c:when test="${(ticket.resolutionDeadline.time - now.time) < 7200000}">
                                                                                <span class="badge badge-warning text-dark p-2" title="Due Soon!"><i class="feather icon-alert-triangle mr-1"></i> <fmt:formatDate value="${ticket.resolutionDeadline}" pattern="dd/MM HH:mm"/></span>
                                                                            </c:when>
                                                                            <c:otherwise>
                                                                                <span class="badge badge-success p-2"><i class="feather icon-clock mr-1"></i> <fmt:formatDate value="${ticket.resolutionDeadline}" pattern="dd/MM HH:mm"/></span>
                                                                            </c:otherwise>
                                                                        </c:choose>
                                                                    </c:when>
                                                                    <c:otherwise>
                                                                        <span class="text-muted font-italic" style="font-size: 0.8rem;"><i class="feather icon-minus"></i> No SLA</span>
                                                                    </c:otherwise>
                                                                </c:choose>
                                                            </td>

                                                            <td>
                                                                <c:choose>
                                                                    <c:when test="${empty ticket.assigneeName}"><span class="text-muted font-italic">Unassigned</span></c:when>
                                                                    <c:otherwise>${ticket.assigneeName}</c:otherwise>
                                                                </c:choose>
                                                            </td>
                                                            <td><span class="badge badge-light border">${ticket.status}</span></td>
                                                            <td style="overflow:visible; position:relative; min-width:80px;">
                                                                <%-- Quick Action Panel (hiện khi hover row) --%>
                                                                <div class="quick-actions" id="qa-${ticket.id}">
                                                                    <a href="${pageContext.request.contextPath}/TicketAgentDetail?id=${ticket.id}"
                                                                       class="btn-qa btn-qa-view" title="View Details">
                                                                        <i class="feather icon-eye"></i> View
                                                                    </a>
                                                                    <c:if test="${empty ticket.assigneeName && ticket.status != 'Awaiting Approval'}">
                                                                        <div class="qa-divider"></div>
                                                                        <c:choose>
                                                                            <c:when test="${sessionScope.role == 'Manager' || sessionScope.role == 'Admin'}">
                                                                                <button type="button"
                                                                                        class="btn-qa btn-qa-assign"
                                                                                        data-toggle="modal" data-target="#assignModal"
                                                                                        onclick="document.getElementById('assignModalTicketId').value='${ticket.id}'"
                                                                                        title="Assign to agent">
                                                                                    <i class="feather icon-user-check"></i> Assign
                                                                                </button>
                                                                            </c:when>
                                                                            <c:otherwise>
                                                                                <a href="${pageContext.request.contextPath}/AssignTicket?id=${ticket.id}"
                                                                                   class="btn-qa btn-qa-assign" title="Take this ticket">
                                                                                    <i class="feather icon-user-plus"></i> Take
                                                                                </a>
                                                                            </c:otherwise>
                                                                        </c:choose>
                                                                    </c:if>
                                                                    <c:if test="${not empty ticket.assigneeName}">
                                                                        <div class="qa-divider"></div>
                                                                        <div style="position:relative;">
                                                                            <button class="btn-qa btn-qa-status"
                                                                                    onclick="toggleStatusDrop('sd-${ticket.id}', event)"
                                                                                    title="Change Status">
                                                                                <i class="feather icon-refresh-cw"></i> Status
                                                                            </button>
                                                                            <div class="status-dropdown" id="sd-${ticket.id}">
                                                                                <div class="status-opt" onclick="quickStatus(${ticket.id}, 'In Progress')">
                                                                                    <i class="feather icon-play mr-1" style="color:#0052cc"></i> In Progress
                                                                                </div>
                                                                                <div class="status-opt" onclick="quickStatus(${ticket.id}, 'Pending')">
                                                                                    <i class="feather icon-pause mr-1" style="color:#ff8b00"></i> Pending
                                                                                </div>
                                                                                <div class="status-opt" onclick="quickStatus(${ticket.id}, 'Resolved')">
                                                                                    <i class="feather icon-check-circle mr-1" style="color:#00875a"></i> Resolved
                                                                                </div>
                                                                            </div>
                                                                        </div>
                                                                    </c:if>
                                                                </div>
                                                            </td>
                                                        </tr>
                                                    </c:forEach>
                                                </tbody>
                                            </table>
                                        </div>
                                    </div>
                                    
                                    <nav aria-label="Page navigation" class="mt-4">
    <ul class="pagination justify-content-center">
        <li class="page-item ${currentPage == 1 ? 'disabled' : ''}">
            <a class="page-link" href="?queue=${currentQueue}&page=${currentPage - 1}&search=${search}&status=${selectedStatus}&ticketType=${selectedTicketType}">Previous</a>
        </li>
        <c:forEach begin="1" end="${totalPages > 0 ? totalPages : 1}" var="i">
            <li class="page-item ${currentPage == i ? 'active' : ''}">
                <a class="page-link" href="?queue=${currentQueue}&page=${i}&search=${search}&status=${selectedStatus}&ticketType=${selectedTicketType}">${i}</a>
            </li>
        </c:forEach>
        <li class="page-item ${currentPage == totalPages || totalPages == 0 ? 'disabled' : ''}">
            <a class="page-link" href="?queue=${currentQueue}&page=${currentPage + 1}&search=${search}&status=${selectedStatus}&ticketType=${selectedTicketType}">Next</a>
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
        <c:if test="${sessionScope.role == 'Manager' || sessionScope.role == 'Admin'}">
        <div class="modal fade" id="assignModal" tabindex="-1" role="dialog" aria-hidden="true">
            <div class="modal-dialog modal-dialog-centered" role="document">
                <div class="modal-content border-0 shadow-lg" style="border-radius: 8px;">
                    <div class="modal-header bg-light border-bottom-0 p-4">
                        <h5 class="modal-title font-weight-bold text-dark"><i class="feather icon-user-check text-primary mr-2"></i>Assign Ticket</h5>
                        <button type="button" class="close" data-dismiss="modal" aria-label="Close"><span aria-hidden="true">&times;</span></button>
                    </div>
                    <form action="${pageContext.request.contextPath}/AssignTicket" method="POST">
                        <div class="modal-body p-4">
                            <input type="hidden" name="ticketId" id="assignModalTicketId" value="${not empty ticket ? ticket.id : ''}">
                            <div class="form-group">
                                <label class="font-weight-bold text-dark mb-2">Select IT Support Agent</label>
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
    </c:if>
    
    <script src="${pageContext.request.contextPath}/assets/plugins/jquery/js/jquery.min.js"></script>
    <script src="${pageContext.request.contextPath}/assets/js/vendor-all.min.js"></script>
    <script src="${pageContext.request.contextPath}/assets/plugins/bootstrap/js/bootstrap.min.js"></script>
    <script src="${pageContext.request.contextPath}/assets/js/pcoded.min.js"></script>

    <script>
    // ── Quick Status Change ────────────────────────────────────────────────
    function toggleStatusDrop(id, event) {
        event.stopPropagation();
        document.querySelectorAll('.status-dropdown').forEach(d => {
            if (d.id !== id) d.classList.remove('show');
        });
        document.getElementById(id).classList.toggle('show');
    }
    document.addEventListener('click', () => {
        document.querySelectorAll('.status-dropdown').forEach(d => d.classList.remove('show'));
    });

    function quickStatus(ticketId, newStatus) {
        if (!confirm('Change status to "' + newStatus + '"?')) return;
        const form = document.createElement('form');
        form.method = 'POST';
        form.action = document.querySelector('meta[name="ctx"]').content + '/UpdateStatus';
        const fields = { ticketId: ticketId, newStatus: newStatus, redirectUrl: window.location.href };
        Object.entries(fields).forEach(([k, v]) => {
            const i = document.createElement('input');
            i.type = 'hidden'; i.name = k; i.value = v;
            form.appendChild(i);
        });
        document.body.appendChild(form);
        form.submit();
    }
    </script>
</body>
</html>
