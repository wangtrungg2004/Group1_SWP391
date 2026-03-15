<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<%
    if (session.getAttribute("user") == null) {
        response.sendRedirect(request.getContextPath() + "/Login.jsp");
        return;
    }
%>

<!DOCTYPE html>
<html lang="vi">
    <head>
        <title>Ticket List | ITServiceFlow</title>
        <meta charset="utf-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0, user-scalable=0, minimal-ui">
        <meta http-equiv="X-UA-Compatible" content="IE=edge"/>
        <link rel="icon" href="assets/images/favicon.ico" type="image/x-icon">
        <link rel="stylesheet" href="assets/fonts/fontawesome/css/fontawesome-all.min.css">
        <link rel="stylesheet" href="assets/plugins/animation/css/animate.min.css">
        <link rel="stylesheet" href="assets/plugins/bootstrap/css/bootstrap.min.css">
        <link rel="stylesheet" href="assets/css/style.css">
    </head>

    <body>
        <div class="loader-bg">
            <div class="loader-track">
                <div class="loader-fill"></div>
            </div>
        </div>

        <nav class="pcoded-navbar menupos-fixed menu-light brand-blue">
            <div class="navbar-wrapper">
                <div class="navbar-brand header-logo">
                    <a href="index.jsp" class="b-brand">
                        <img src="assets/images/logo.svg" alt="ITServiceFlow Logo" class="logo images">
                        <span class="b-title">ITServiceFlow</span>
                    </a>
                </div>
                <div class="navbar-content scroll-div">
                    <ul class="nav pcoded-inner-navbar">
                        <li class="nav-item">
                            <a href="AdminDashboard.jsp" class="nav-link">
                                <span class="pcoded-micon"><i class="feather icon-home"></i></span>
                                <span class="pcoded-mtext">Dashboard</span>
                            </a>
                        </li>
                        <li class="nav-item"> 
                            <a href="TicketLinkCIListServlet" class="nav-link"> 
                                <span class="pcoded-micon"><i class="feather icon-link"></i></span> 
                                <span class="pcoded-mtext">Ticket - CI Links</span> 
                            </a> 
                        </li> 
                        <li class="nav-item active">
                            <a href="Long_TicketListServlet" class="nav-link">
                                <span class="pcoded-micon"><i class="feather icon-file-text"></i></span>
                                <span class="pcoded-mtext">Tickets</span>
                            </a>
                        </li>
                        <li class="nav-item">
                            <a href="CIListServlet" class="nav-link">
                                <span class="pcoded-micon"><i class="feather icon-file-text"></i></span>
                                <span class="pcoded-mtext">Assets</span>
                            </a>
                        </li>
                    </ul>
                </div>
            </div>
        </nav>

        <div class="pcoded-main-container">
            <div class="pcoded-wrapper">
                <div class="pcoded-content">
                    <div class="pcoded-inner-content">
                        <div class="main-body">
                            <div class="page-wrapper">

                                <div class="page-header">
                                    <div class="row align-items-end">
                                        <div class="col-lg-12">
                                            <div class="page-header-title">
                                                <div class="d-inline">
                                                    <h4>Tickets</h4>
                                                    <span>View all tickets in the system.</span>
                                                </div>
                                            </div>
                                        </div>
                                    </div>
                                </div>

                                <c:if test="${not empty errorMessage}">
                                    <div class="alert alert-danger alert-dismissible fade show" role="alert">
                                        <i class="feather icon-alert-circle"></i>
                                        <strong>Error:</strong> ${errorMessage}
                                        <button type="button" class="close" data-dismiss="alert" aria-label="Close">
                                            <span aria-hidden="true">&times;</span>
                                        </button>
                                    </div>
                                </c:if>

                                <c:if test="${not empty param.successMessage}">
                                    <div id="linkSuccessAlert" class="alert alert-success alert-dismissible fade show" role="alert">
                                        <i class="feather icon-check-circle"></i>
                                        <strong>Link successfull</strong>
                                    </div>
                                </c:if>

                                <div class="page-body">
                                    <div class="row">
                                        <div class="col-sm-12">

                                            <%-- SEARCH CARD --%>
                                            <div class="card">
                                                <div class="card-block">

                                                    <form id="searchForm" action="Long_TicketListServlet" method="GET">
                                                        <c:if test="${not empty ticketId}">
                                                            <input type="hidden" name="ticketId" value="${ticketId}">
                                                        </c:if>

                                                        <div class="row">
                                                            <%-- Keyword --%>
                                                            <div class="col-md-6">
                                                                <label class="col-form-label">
                                                                    <i class="feather icon-search mr-1"></i>Search Ticket
                                                                </label>
                                                                <div class="input-group">
                                                                    <input type="text"
                                                                           name="keyword"
                                                                           class="form-control"
                                                                           placeholder="Search by Ticket Number, Title, Status, Priority, Created At(dd/MM/yyyy)"
                                                                           value="${keyword}">
                                                                    <div class="input-group-append">
                                                                        <button type="submit" class="btn btn-primary">
                                                                            <i class="feather icon-search"></i> Search
                                                                        </button>
                                                                        <c:if test="${not empty keyword 
                                                                                      or (type ne 'all' and not empty type)
                                                                                      or (status ne 'all' and not empty status)
                                                                                      or (priority ne 'all' and not empty priority)}">
                                                                            <a href="Long_TicketListServlet"
                                                                               class="btn btn-outline-secondary" title="Clear filters">
                                                                                <i class="feather icon-x"></i>
                                                                            </a>
                                                                        </c:if>
                                                                    </div>
                                                                </div>
                                                            </div>

                                                            <div class="col-md-2">
                                                                <label class="col-form-label">
                                                                    <i class="feather icon-filter mr-1"></i>Filter by Type
                                                                </label>
                                                                <select name="type"
                                                                        class="form-control"
                                                                        onchange="document.getElementById('searchForm').submit()">
                                                                    <option value="all"             ${type eq 'all' ? 'selected' : ''}>All</option>
                                                                    <option value="Incident"        ${type eq 'Incident' ? 'selected' : ''}>Incident</option>
                                                                    <option value="ServiceRequest"  ${type eq 'ServiceRequest' ? 'selected' : ''}>Service Request</option>
                                                                </select>
                                                            </div>

                                                            <div class="col-md-2">
                                                                <label class="col-form-label">
                                                                    <i class="feather icon-filter mr-1"></i>Filter by Status
                                                                </label>
                                                                <select name="status"
                                                                        class="form-control"
                                                                        onchange="document.getElementById('searchForm').submit()">
                                                                    <option value="all"        ${status eq 'all' ? 'selected' : ''}>All</option>
                                                                    <option value="New"        ${status eq 'New' ? 'selected' : ''}>New</option>
                                                                    <option value="Inprogress" ${status eq 'Inprogress' ? 'selected' : ''}>In Progress</option>
                                                                    <option value="Completed"  ${status eq 'Completed' ? 'selected' : ''}>Completed</option>
                                                                </select>
                                                            </div>
                                                            <div class="col-md-2">
                                                                <label class="col-form-label">
                                                                    <i class="feather icon-filter mr-1"></i>Filter by Priority
                                                                </label>
                                                                <select name="priority"
                                                                        class="form-control"
                                                                        onchange="document.getElementById('searchForm').submit()">
                                                                    <option value="all"      ${priority eq 'all' ? 'selected' : ''}>All</option>
                                                                    <option value="Critical" ${priority eq 'Critical' ? 'selected' : ''}>Critical</option>
                                                                    <option value="High"     ${priority eq 'High' ? 'selected' : ''}>High</option>
                                                                    <option value="Medium"   ${priority eq 'Medium' ? 'selected' : ''}>Medium</option>
                                                                    <option value="Low"      ${priority eq 'Low' ? 'selected' : ''}>Low</option>
                                                                </select>
                                                            </div>
                                                        </div>
                                                        <small class="text-muted mt-1 d-block">
                                                            Searches across: Ticket Number, Title, Status, Priority, Created At(dd/MM/yyyy)
                                                        </small>
                                                    </form>

                                                </div>
                                            </div>

                                            <%-- Tickets LIST TABLE CARD --%>
                                            <div class="card">
                                                <div class="card-header d-flex justify-content-between align-items-center">
                                                    <h5 class="mb-0">Ticket List</h5>
                                                    <span class="badge badge-primary">${empty ticketList ? 0 : ticketList.size()}</span>
                                                </div>

                                                <div class="card-block table-border-style">
                                                    <div class="table-responsive">
                                                        <table class="table table-hover table-bordered">
                                                            <thead class="thead-light">
                                                                <tr>
                                                                    <th style="width: 60px">#</th>
                                                                    <th>Ticket Number</th>
                                                                    <th>Type</th>
                                                                    <th>Title</th>
                                                                    <th>Status</th>
                                                                    <th>Priority</th>
                                                                    <th>Assets</th>
                                                                    <th>Created At</th>
                                                                    <th style="width: 120px">Action</th>
                                                                </tr>
                                                            </thead>
                                                            <tbody>
                                                                <c:choose>
                                                                    <c:when test="${not empty ticketList}">
                                                                        <c:forEach var="t" items="${ticketList}" varStatus="loop">
                                                                            <tr>
                                                                                <td class="text-muted">${loop.count}</td>
                                                                                <td><strong class="text-primary">${t.ticketNumber}</strong></td>
                                                                                <td>${t.ticketType}</td>
                                                                                <td>${t.title}</td>
                                                                                <td>${t.status}</td>
                                                                                <td>
                                                                                    <c:choose>
                                                                                        <c:when test="${not empty t.priorityLevel}">${t.priorityLevel}</c:when>
                                                                                        <c:otherwise><span class="text-muted">—</span></c:otherwise>
                                                                                    </c:choose>
                                                                                </td>
                                                                                <td>
                                                                                    <c:choose>
                                                                                        <c:when test="${not empty t.linkedAssets}">
                                                                                            <c:forEach var="ci" items="${t.linkedAssets}">
                                                                                                <span class="badge badge-info mr-1">
                                                                                                    <a href="CIDetailServlet?id=${ci.id}&ticketId=${t.id}"
                                                                                                       class="text-white"
                                                                                                       style="text-decoration: underline;">
                                                                                                        ${ci.assetTag}
                                                                                                    </a>
                                                                                                    <form action="TicketUnlinkCIServlet"
                                                                                                          method="POST"
                                                                                                          style="display:inline;">
                                                                                                        <input type="hidden" name="ticketId" value="${t.id}" />
                                                                                                        <input type="hidden" name="assetId" value="${ci.id}" />
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
                                                                                <td>
                                                                                    <c:choose>
                                                                                        <c:when test="${not empty t.createdAt}">
                                                                                            <fmt:formatDate value="${t.createdAt}" pattern="dd/MM/yyyy"/>
                                                                                        </c:when>
                                                                                        <c:otherwise><span class="text-muted">—</span></c:otherwise>
                                                                                    </c:choose>
                                                                                </td>
                                                                                <td>
                                                                                    <a href="TicketDetailServlet?id=${t.id}" class="btn btn-sm btn-info mb-1" title="View Ticket Detail">
                                                                                        <i class="feather icon-eye"></i> View
                                                                                    </a>
                                                                                    <button type="button"
                                                                                            class="btn btn-sm btn-warning mb-1"
                                                                                            data-toggle="collapse"
                                                                                            data-target="#linkAssetForm${t.id}"
                                                                                            aria-expanded="false"
                                                                                            aria-controls="linkAssetForm${t.id}">
                                                                                        <i class="feather icon-link"></i> Link to Asset
                                                                                    </button>

                                                                                    <div class="collapse mt-2" id="linkAssetForm${t.id}">
                                                                                        <form action="TicketLinkCIServlet" method="POST" class="form-inline">
                                                                                            <input type="hidden" name="ticketId" value="${t.id}">
                                                                                            <input type="text"
                                                                                                   name="assetTag"
                                                                                                   class="form-control form-control-sm mr-1"
                                                                                                   placeholder="Enter asset-tag"
                                                                                                   required>
                                                                                            <button type="submit" class="btn btn-sm btn-primary">
                                                                                                <i class="feather icon-check"></i> Link
                                                                                            </button>
                                                                                        </form>
                                                                                    </div>
                                                                                </td>
                                                                            </tr>
                                                                        </c:forEach>
                                                                    </c:when>
                                                                    <c:otherwise>
                                                                        <tr>
                                                                            <td colspan="9" class="text-center py-5">
                                                                                <i class="feather icon-file-text" style="font-size:2rem; color:#ccc;"></i>
                                                                                <p class="mt-2 mb-1 font-weight-bold text-muted">No tickets found</p>
                                                                                <small class="text-muted">There is no ticket data to display.</small>
                                                                            </td>
                                                                        </tr>
                                                                    </c:otherwise>
                                                                </c:choose>
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
        </div>

        <script src="assets/js/vendor-all.min.js"></script>
        <script src="assets/plugins/bootstrap/js/bootstrap.min.js"></script>
        <script src="assets/js/pcoded.min.js"></script>
        <script>
            (function () {
                var successAlert = document.getElementById('linkSuccessAlert');
                if (successAlert) {
                    setTimeout(function () {
                        successAlert.style.transition = 'opacity 0.3s ease';
                        successAlert.style.opacity = '0';
                        setTimeout(function () {
                            if (successAlert && successAlert.parentNode) {
                                successAlert.parentNode.removeChild(successAlert);
                            }
                        }, 300);
                    }, 2000);
                }
            })();
        </script>
    </body>
</html>
