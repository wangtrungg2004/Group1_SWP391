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
        
        /* 🚀 SLA BREACHED ANIMATION & STYLES */
        .sla-breached { background-color: #ffebe6; color: #bf2600; border: 1px solid #ff5630; animation: pulse-red 2s infinite; display: inline-block; text-align: center; }
        @keyframes pulse-red { 0% { box-shadow: 0 0 0 0 rgba(255, 86, 48, 0.4); } 70% { box-shadow: 0 0 0 6px rgba(255, 86, 48, 0); } 100% { box-shadow: 0 0 0 0 rgba(255, 86, 48, 0); } }
        .row-breached td { background-color: #fffdfd !important; }
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

                    <c:if test="${not empty param.successMessage}">
                        <div id="successAlert" class="alert alert-success alert-dismissible fade show" role="alert">
                            <i class="feather icon-check-circle mr-2"></i>
                            <strong>Success!</strong> ${param.successMessage}
                            <button type="button" class="close" data-dismiss="alert" aria-label="Close">
                                <span aria-hidden="true">&times;</span>
                            </button>
                        </div>
                    </c:if>

                    <c:if test="${not empty param.errorMessage}">
                        <div id="errorAlert" class="alert alert-danger alert-dismissible fade show" role="alert">
                            <i class="feather icon-alert-circle mr-2"></i>
                            <strong>Error!</strong> ${param.errorMessage}
                            <button type="button" class="close" data-dismiss="alert" aria-label="Close">
                                <span aria-hidden="true">&times;</span>
                             </button>
                        </div>
                    </c:if>

                    <div class="main-body">
                        <div class="page-wrapper p-0">
                            <div class="row">
                                <div class="col-12">
                                    
                                   <div class="queue-nav">
                                        <a href="${pageContext.request.contextPath}/Queues?queue=unassigned" class="queue-pill ${currentQueue == 'unassigned' ? 'active' : ''}"><i class="feather icon-inbox"></i> Unassigned (Triage)</a>
                                        <a href="${pageContext.request.contextPath}/Queues?queue=mine" class="queue-pill ${currentQueue == 'mine' ? 'active' : ''}"><i class="feather icon-user"></i> Assigned to me</a>
                                        <a href="${pageContext.request.contextPath}/Queues?queue=all_active" class="queue-pill ${currentQueue == 'all_active' ? 'active' : ''}"><i class="feather icon-list"></i> All Open</a>
                                        <a href="${pageContext.request.contextPath}/Queues?queue=resolved" class="queue-pill ${currentQueue == 'resolved' ? 'active' : ''}"><i class="feather icon-check-circle"></i> Resolved</a>
                                    </div>

                                    <div class="card mb-4">
                                        <div class="card-block">
                                            <form id="searchForm" action="${pageContext.request.contextPath}/Queues" method="GET">
                                                <input type="hidden" name="queue" value="${currentQueue}">

                                              <div class="row">
                                                    <%-- Keyword --%>
                                                     <div class="col-md-6">
                                                        <label class="col-form-label font-weight-bold">
                                                             <i class="feather icon-search mr-1"></i>Search Ticket
                                                        </label>
                                                        <div class="input-group">
                                                             <input type="text"
                                                                   name="search"
                                                                   class="form-control"
                                                                   placeholder="Search by Ticket Number, Title..."
                                                                    value="${search}">
                                                            <div class="input-group-append">
                                                                 <button type="submit" class="btn btn-primary">
                                                                    <i class="feather icon-search"></i> Search
                                                                </button>
                                                                 <c:if test="${not empty search 
                                                                               or (selectedTicketType ne 'all' and not empty selectedTicketType)
                                                                               or (selectedStatus ne 'all' and not empty selectedStatus)
                                                                               or (selectedPriority ne 'all' and not empty selectedPriority)}">
                                                                       <a href="${pageContext.request.contextPath}/Queues?queue=${currentQueue}"
                                                                          class="btn btn-outline-secondary" title="Clear filters">
                                                                           <i class="feather icon-x"></i>
                                                                      </a>
                                                                 </c:if>
                                                             </div>
                                                        </div>
                                                   </div>

                                                    <div class="col-md-2">
                                                        <label class="col-form-label font-weight-bold">
                                                            <i class="feather icon-filter mr-1"></i>Filter by Type
                                                         </label>
                                                         <select name="ticketType"
                                                                class="form-control"
                                                                  onchange="document.getElementById('searchForm').submit()">
                                                            <option value="all"             ${selectedTicketType eq 'all' ? 'selected' : ''}>All</option>
                                                            <option value="Incident"        ${selectedTicketType eq 'Incident' ? 'selected' : ''}>Incident</option>
                                                            <option value="ServiceRequest"  ${selectedTicketType eq 'ServiceRequest' ? 'selected' : ''}>Service Request</option>
                                                        </select>
                                                     </div>

                                                    <div class="col-md-2">
                                                         <label class="col-form-label font-weight-bold">
                                                            <i class="feather icon-filter mr-1"></i>Filter by Status
                                                         </label>
                                                        <select name="status"
                                                                class="form-control"
                                                                 onchange="document.getElementById('searchForm').submit()">
                                                            <option value="all"         ${selectedStatus eq 'all' ? 'selected' : ''}>All Statuses</option>
                                                            <option value="New"         ${selectedStatus eq 'New' ? 'selected' : ''}>New</option>
                                                            <option value="In Progress" ${selectedStatus eq 'In Progress' ? 'selected' : ''}>In Progress</option>
                                                            <option value="Reopened"    ${selectedStatus eq 'Reopened' ? 'selected' : ''}>Reopened</option>
                                                            <option value="Resolved"    ${selectedStatus eq 'Resolved' ? 'selected' : ''}>Resolved</option>
                                                            <option value="Closed"      ${selectedStatus eq 'Closed' ? 'selected' : ''}>Closed</option>
                                                        </select>
                                                    </div>
                                                    
                                                    <div class="col-md-2">
                                                         <label class="col-form-label font-weight-bold">
                                                            <i class="feather icon-filter mr-1"></i>Filter by Priority
                                                          </label>
                                                        <select name="priority"
                                                                class="form-control"
                                                                 onchange="document.getElementById('searchForm').submit()">
                                                            <option value="all"      ${selectedPriority eq 'all' ? 'selected' : ''}>All</option>
                                                            <option value="Critical" ${selectedPriority eq 'Critical' ? 'selected' : ''}>Critical</option>
                                                            <option value="High"     ${selectedPriority eq 'High' ? 'selected' : ''}>High</option>
                                                            <option value="Medium"   ${selectedPriority eq 'Medium' ? 'selected' : ''}>Medium</option>
                                                            <option value="Low"      ${selectedPriority eq 'Low' ? 'selected' : ''}>Low</option>
                                                        </select>
                                                    </div>
                                                </div>
                                                <small class="text-muted mt-2 d-block">
                                                    Searches across: Ticket Number, Title
                                                 </small>
                                            </form>
                                        </div>
                                   </div>

                                    <div class="card border-0 shadow-sm">
                                         <div class="table-responsive">
                                            <table class="table jira-table mb-0">
                                                <thead>
                                                    <tr>
                                                         <th width="5%">No</th>
                                                        <th width="10%">Key</th>
                                                        <th width="10%">Type</th>
                                                        <th width="10%">Priority</th>
                                                         <th width="15%">Assets</th>
                                                        <th width="13%">SLA Deadline</th>
                                                        <th width="12%">Assignee</th>
                                                         <th width="10%">Status</th>
                                                        <th width="15%">Action</th>
                                                     </tr>
                                                </thead>
                                                <tbody>
                                                    <c:if test="${empty queueList}">
                                                        <tr><td colspan="9" class="text-center py-5 text-muted"><i class="feather icon-check-circle d-block mb-2" style="font-size: 2rem;"></i> Queue is empty. Great job!</td></tr>
                                                    </c:if>                                                  
                                                    <jsp:useBean id="now" class="java.util.Date" />
                                                    <c:forEach items="${queueList}" var="ticket" varStatus="status">                                                       
                                                        <c:set var="isActiveBreached" value="${not empty ticket.resolutionDeadline and ticket.resolutionDeadline.time < now.time and ticket.status != 'Resolved' and ticket.status != 'Closed'}" />                                                        
                                                        <tr class="${isActiveBreached ? 'row-breached' : ''}">
                                                            <td>${(currentPage - 1) * 10 + status.count}</td>
                                                            <td><a href="${pageContext.request.contextPath}/TicketAgentDetail?id=${ticket.id}" class="ticket-key">${ticket.ticketNumber}</a></td>
                                                            <td>${ticket.ticketType}</td>
                                                            
                                                            <%-- 🚀 PRIORITY COLOR CODING --%>
                                                            <td>
                                                                <c:choose>
                                                                    <c:when test="${ticket.priorityLevel == 'Critical'}"><span class="badge badge-danger"><i class="feather icon-alert-circle mr-1"></i>Critical</span></c:when>
                                                                    <c:when test="${ticket.priorityLevel == 'High'}"><span class="badge badge-warning text-dark"><i class="feather icon-arrow-up mr-1"></i>High</span></c:when>
                                                                    <c:when test="${ticket.priorityLevel == 'Medium'}"><span class="badge badge-info"><i class="feather icon-minus mr-1"></i>Medium</span></c:when>
                                                                    <c:when test="${ticket.priorityLevel == 'Low'}"><span class="badge badge-secondary"><i class="feather icon-arrow-down mr-1"></i>Low</span></c:when>
                                                                    <c:otherwise><span class="badge badge-light border text-muted">${ticket.priorityLevel}</span></c:otherwise>
                                                                </c:choose>
                                                            </td>
                                                            
                                                            <td>
                                                                <c:choose>
                                                                    <c:when test="${not empty ticket.linkedAssets}">
                                                                        <c:forEach var="ci" items="${ticket.linkedAssets}">
                                                                           <span class="badge badge-info mr-1">
                                                                                <a href="${pageContext.request.contextPath}/CIDetailServlet?id=${ci.id}&ticketId=${ticket.id}"
                                                                                   class="text-white"
                                                                                   style="text-decoration: underline;">
                                                                                    ${ci.assetTag}
                                                                                </a>
                                                                                <form action="${pageContext.request.contextPath}/TicketUnlinkCIServlet"
                                                                                      method="POST"
                                                                                      style="display:inline;">
                                                                                    <input type="hidden" name="ticketId" value="${ticket.id}" />
                                                                                    <input type="hidden" name="assetId" value="${ci.id}" />
                                                                                    <input type="hidden" name="redirect" value="/Queues?queue=${currentQueue}&search=${search}&status=${selectedStatus}&ticketType=${selectedTicketType}&priority=${selectedPriority}"/>
                                                                                    <button type="submit"
                                                                                            class="btn btn-sm btn-link text-white p-0 ml-1"
                                                                                            title="Remove asset link"
                                                                                            onclick="return confirm('Remove this asset from ticket?');">
                                                                                        ×
                                                                                    </button>
                                                                                </form>
                                                                            </span>
                                                                        </c:forEach>
                                                                    </c:when>
                                                                    <c:otherwise>
                                                                       <span class="text-muted">—</span>
                                                                    </c:otherwise>
                                                                </c:choose>
                                                            </td>

                                                            <%-- 🚀 SLA DEADLINE COLOR CODING --%>
                                                            <td>
                                                                <c:choose>
                                                                    <c:when test="${not empty ticket.resolutionDeadline}">
                                                                        <c:choose>
                                                                            <%-- If ticket is Resolved/Closed, neutralize the SLA badge --%>
                                                                            <c:when test="${ticket.status == 'Resolved' || ticket.status == 'Closed'}">
                                                                                <span class="badge badge-light border text-muted p-2" title="SLA Stopped"><i class="feather icon-check-circle mr-1"></i> <fmt:formatDate value="${ticket.resolutionDeadline}" pattern="dd/MM HH:mm"/></span>
                                                                            </c:when>
                                                                            
                                                                            <%-- If actively Breached --%>
                                                                            <c:when test="${ticket.resolutionDeadline.time < now.time}">
                                                                                <div class="badge p-2 sla-breached" title="SLA Target Missed!">
                                                                                    <i class="feather icon-alert-octagon mr-1"></i> <strong>BREACHED</strong><br>
                                                                                    <span style="font-size: 0.75rem; opacity: 0.9;"><fmt:formatDate value="${ticket.resolutionDeadline}" pattern="dd/MM HH:mm"/></span>
                                                                                </div>
                                                                            </c:when>
                                                                            
                                                                            <%-- If Due within 2 Hours (Warning) --%>
                                                                            <c:when test="${(ticket.resolutionDeadline.time - now.time) < 7200000}">
                                                                                <span class="badge badge-warning text-dark p-2" title="Due Soon!"><i class="feather icon-alert-triangle mr-1"></i> <fmt:formatDate value="${ticket.resolutionDeadline}" pattern="dd/MM HH:mm"/></span>
                                                                            </c:when>
                                                                            
                                                                            <%-- Safe (Green) --%>
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
                                                            
                                                            <td>
                                                                <a href="${pageContext.request.contextPath}/TicketAgentDetail?id=${ticket.id}" class="btn btn-sm btn-info mb-1" title="View Ticket Detail">
                                                                    <i class="feather icon-eye"></i> View
                                                                </a>
                                                                <button type="button"
                                                                        class="btn btn-sm btn-warning mb-1"
                                                                        data-toggle="modal"
                                                                        data-target="#assetPickerModal"
                                                                        data-ticket-id="${ticket.id}">
                                                                    <i class="feather icon-link"></i> Link Asset
                                                                </button>
                                                                <c:if test="${empty ticket.assigneeName && ticket.status != 'Awaiting Approval'}">
                                                                    <c:choose>
                                                                        <c:when test="${sessionScope.role == 'Manager' || sessionScope.role == 'Admin'}">
                                                                            <button type="button" class="btn btn-sm btn-outline-primary font-weight-bold px-3 mb-1" data-toggle="modal" data-target="#assignModal" onclick="document.getElementById('assignModalTicketId').value = '${ticket.id}'">Assign</button>
                                                                        </c:when>
                                                                        <c:otherwise>
                                                                            <a href="${pageContext.request.contextPath}/AssignTicket?id=${ticket.id}" class="btn btn-sm btn-outline-primary font-weight-bold px-3 mb-1">Assign to me</a>
                                                                        </c:otherwise>
                                                                    </c:choose>
                                                                </c:if>
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
                                                <a class="page-link" href="${pageContext.request.contextPath}/Queues?queue=${currentQueue}&page=${currentPage - 1}&search=${search}&status=${selectedStatus}&ticketType=${selectedTicketType}&priority=${selectedPriority}">Previous</a>
                                            </li>
                                            <c:forEach begin="1" end="${totalPages > 0 ? totalPages : 1}" var="i">
                                                <li class="page-item ${currentPage == i ? 'active' : ''}">
                                                    <a class="page-link" href="${pageContext.request.contextPath}/Queues?queue=${currentQueue}&page=${i}&search=${search}&status=${selectedStatus}&ticketType=${selectedTicketType}&priority=${selectedPriority}">${i}</a>
                                                </li>
                                            </c:forEach>
                                            <li class="page-item ${currentPage == totalPages || totalPages == 0 ? 'disabled' : ''}">
                                                <a class="page-link" href="${pageContext.request.contextPath}/Queues?queue=${currentQueue}&page=${currentPage + 1}&search=${search}&status=${selectedStatus}&ticketType=${selectedTicketType}&priority=${selectedPriority}">Next</a>
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

    <%-- Asset Picker Modal --%>
    <div class="modal fade" id="assetPickerModal" tabindex="-1" role="dialog" aria-labelledby="assetPickerModalLabel" aria-hidden="true">
        <div class="modal-dialog modal-lg" role="document">
            <div class="modal-content">
                <div class="modal-header">
                    <h5 class="modal-title" id="assetPickerModalLabel">Select the Asset to link</h5>
                    <button type="button" class="close" data-dismiss="modal" aria-label="Close">
                        <span aria-hidden="true">&times;</span>
                    </button>
                </div>
                <div class="modal-body">
                    <input type="hidden" id="apTicketId" value="" />

                    <div class="row">
                        <div class="col-md-8">
                            <label class="col-form-label">
                                <i class="feather icon-search mr-1"></i>Search
                            </label>
                            <div class="input-group">
                                <input type="text"
                                       id="apAssetSearch"
                                       class="form-control"
                                       placeholder="Search across: asset tag, asset name, owner" />
                                <div class="input-group-append">
                                    <button type="button"
                                            id="apAssetSearchBtn"
                                            class="btn btn-primary">
                                        <i class="feather icon-search"></i> Search
                                    </button>
                                    <button type="button"
                                            id="apAssetSearchClearBtn"
                                            class="btn btn-outline-secondary"
                                            title="Clear filters"
                                            style="display:none;">
                                        <i class="feather icon-x"></i>
                                    </button>
                                </div>
                            </div>
                        </div>
                        <div class="col-md-4">
                            <label class="col-form-label">
                                <i class="feather icon-filter mr-1"></i>Filter by Asset Type
                            </label>
                            <select id="apAssetType" class="form-control">
                                <option value="all">All</option>
                                <option value="Laptop">Laptop</option>
                                <option value="Server">Server</option>
                                <option value="Network">Network</option>
                                <option value="Printer">Printer</option>
                            </select>
                        </div>
                    </div>

                    <div class="table-responsive mt-3">
                        <table class="table table-hover table-bordered mb-0">
                            <thead class="thead-light">
                                <tr>
                                    <th style="width: 120px;">Asset Tag</th>
                                    <th>Name</th>
                                    <th style="width: 140px;">Type</th>
                                    <th style="width: 200px;">Owner</th>
                                    <th style="width: 90px;">Action</th>
                                </tr>
                            </thead>
                            <tbody id="apTableBody">
                                <tr>
                                    <td colspan="5" class="text-center text-muted py-4">Select ticket to load the configuration item list...</td>
                                </tr>
                            </tbody>
                        </table>
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
        // Auto-hide alerts after 2 seconds
        (function() {
            var successAlert = document.getElementById('successAlert');
            var errorAlert = document.getElementById('errorAlert');
            
            if (successAlert) {
                setTimeout(function() {
                    $(successAlert).fadeOut(500, function() {
                        $(this).remove();
                    });
                }, 2000);
            }
            if (errorAlert) {
                setTimeout(function() {
                    $(errorAlert).fadeOut(500, function() {
                        $(this).remove();
                    });
                }, 2000);
            }
        })();

        (function () {
            function escapeHtml(str) {
                if (str === null || str === undefined)
                    return '';
                return String(str)
                        .replace(/&/g, '&amp;')
                        .replace(/</g, '&lt;')
                        .replace(/>/g, '&gt;')
                        .replace(/"/g, '&quot;')
                        .replace(/'/g, '&#39;');
            }

            function renderRows(items, ticketId) {
                var tbody = document.getElementById('apTableBody');
                if (!items || items.length === 0) {
                    tbody.innerHTML = '<tr><td colspan="5" class="text-center text-muted py-4">No suitable assets were found.</td></tr>';
                    return;
                }

                var html = '';
                for (var i = 0; i < items.length; i++) {
                    var a = items[i];
                    html += '<tr>'
                            + '<td><strong class="text-primary">' + escapeHtml(a.assetTag) + '</strong></td>'
                            + '<td>' + escapeHtml(a.name) + '</td>'
                            + '<td>' + escapeHtml(a.assetType) + '</td>'
                            + '<td>' + escapeHtml(a.ownerName) + '</td>'
                            + '<td>'
                            + '<form action="${pageContext.request.contextPath}/TicketLinkCIServlet" method="POST" style="margin:0;">'
                            + '<input type="hidden" name="ticketId" value="' + escapeHtml(ticketId) + '"/>'
                            + '<input type="hidden" name="assetTag" value="' + escapeHtml(a.assetTag) + '"/>'
                            + '<input type="hidden" name="redirect" value="/Queues?queue=${currentQueue}&search=${search}&status=${selectedStatus}&ticketType=${selectedTicketType}&priority=${selectedPriority}"/>'
                            + '<button type="submit" class="btn btn-sm btn-primary">Link</button>'
                            + '</form>'
                            + '</td>'
                            + '</tr>';
                }
                tbody.innerHTML = html;
            }

            var apAllAssets = [];
            function updateApAssetSearchClearVisibility() {
                var searchVal = (document.getElementById('apAssetSearch').value || '').trim();
                var assetTypeVal = document.getElementById('apAssetType').value || 'all';
                var shouldShow = searchVal.length > 0 || assetTypeVal !== 'all';
                var clearBtn = document.getElementById('apAssetSearchClearBtn');
                if (clearBtn)
                    clearBtn.style.display = shouldShow ? '' : 'none';
            }

            async function loadAssetsBase() {
                var ticketId = document.getElementById('apTicketId').value;
                var assetType = document.getElementById('apAssetType').value || 'all';

                var tbody = document.getElementById('apTableBody');
                tbody.innerHTML = '<tr><td colspan="5" class="text-center text-muted py-4">Loading...</td></tr>';
                try {
                    var url = '${pageContext.request.contextPath}/TicketAssetsPickerServlet?ticketId=' + encodeURIComponent(ticketId)
                            + '&keyword=' + encodeURIComponent('') 
                            + '&assetType=' + encodeURIComponent(assetType);
                    var res = await fetch(url, {headers: {'Accept': 'application/json'}});
                    var data = await res.json();
                    apAllAssets = data.assets || [];
                    applyClientFilters();
                } catch (e) {
                    tbody.innerHTML = '<tr><td colspan="5" class="text-center text-danger py-4">Cannot load assets.</td></tr>';
                }
            }

            function applyClientFilters() {
                var ticketId = document.getElementById('apTicketId').value;
                var searchTerm = (document.getElementById('apAssetSearch').value || '').trim().toLowerCase();

                var filtered = (apAllAssets || []).filter(function (a) {
                    var ok = true;
                    if (searchTerm) {
                        ok = ok && (
                                (a.assetTag || '').toLowerCase().includes(searchTerm) ||
                                (a.name || '').toLowerCase().includes(searchTerm) ||
                                (a.ownerName || '').toLowerCase().includes(searchTerm)
                        );
                    }
                    return ok;
                });
                renderRows(filtered, ticketId);
            }

            $('#assetPickerModal').on('show.bs.modal', function (event) {
                var button = $(event.relatedTarget);
                var ticketId = button.data('ticket-id');
                document.getElementById('apTicketId').value = ticketId;
                document.getElementById('apAssetSearch').value = '';
                document.getElementById('apAssetType').value = 'all';
                apAllAssets = [];
                loadAssetsBase();
                updateApAssetSearchClearVisibility();
            });
            document.getElementById('apAssetSearch').addEventListener('input', function () {
                updateApAssetSearchClearVisibility();
            });
            document.getElementById('apAssetSearch').addEventListener('keydown', function (e) {
                if (e.key === 'Enter') {
                    e.preventDefault();
                    applyClientFilters();
                }
            });
            document.getElementById('apAssetSearchBtn').addEventListener('click', function () {
                applyClientFilters();
            });
            document.getElementById('apAssetType').addEventListener('change', function () {
                apAllAssets = [];
                loadAssetsBase();
                updateApAssetSearchClearVisibility();
            });
            document.getElementById('apAssetSearchClearBtn').addEventListener('click', function () {
                document.getElementById('apAssetSearch').value = '';
                document.getElementById('apAssetType').value = 'all';
                apAllAssets = [];
                loadAssetsBase();
                updateApAssetSearchClearVisibility();
            });
        })();
    </script>
</body>
</html>