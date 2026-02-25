<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html lang="vi">

<head>
    <title>CMDB - CI List | ITServiceFlow</title>
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

<%-- PRE-LOADER --%>
<div class="loader-bg">
    <div class="loader-track">
        <div class="loader-fill"></div>
    </div>
</div>

<%-- NAVIGATION MENU --%>
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
                    <a href="index.jsp" class="nav-link">
                        <span class="pcoded-micon"><i class="feather icon-home"></i></span>
                        <span class="pcoded-mtext">Dashboard</span>
                    </a>
                </li>
                <li class="nav-item">
                    <a href="ticket-list.jsp" class="nav-link">
                        <span class="pcoded-micon"><i class="feather icon-file-text"></i></span>
                        <span class="pcoded-mtext">Tickets</span>
                    </a>
                </li>
                <li class="nav-item active">
                    <a href="CIListServlet" class="nav-link">
                        <span class="pcoded-micon"><i class="feather icon-database"></i></span>
                        <span class="pcoded-mtext">CMDB / Assets</span>
                    </a>
                </li>
            </ul>
        </div>
    </div>
</nav>

<%-- MAIN CONTENT --%>
<div class="pcoded-main-container">
    <div class="pcoded-wrapper">
        <div class="pcoded-content">
            <div class="pcoded-inner-content">
                <div class="main-body">
                    <div class="page-wrapper">

                        <%-- PAGE HEADER --%>
                        <div class="page-header">
                            <div class="row align-items-end">
                                <div class="col-lg-12">
                                    <div class="page-header-title">
                                        <div class="d-inline">
                                            <h4>Configuration Items (CMDB)</h4>
                                            <c:choose>
                                                <c:when test="${not empty ticketId}">
                                                    <span>Select a CI to link with Ticket
                                                        <strong>#${ticketId}</strong>.
                                                    </span>
                                                </c:when>
                                                <c:otherwise>
                                                    <span>Manage all IT assets in the system.</span>
                                                </c:otherwise>
                                            </c:choose>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>

                        <%-- FLASH MESSAGES --%>
                        <c:if test="${not empty sessionScope.message}">
                            <div class="alert alert-${sessionScope.messageType} alert-dismissible fade show" role="alert">
                                <i class="feather ${sessionScope.messageType eq 'success' ? 'icon-check-circle' : 'icon-alert-triangle'}"></i>
                                ${sessionScope.message}
                                <button type="button" class="close" data-dismiss="alert" aria-label="Close">
                                    <span aria-hidden="true">&times;</span>
                                </button>
                            </div>
                            <c:remove var="message" scope="session"/>
                            <c:remove var="messageType" scope="session"/>
                        </c:if>

                        <c:if test="${not empty errorMessage}">
                            <div class="alert alert-danger alert-dismissible fade show" role="alert">
                                <i class="feather icon-alert-circle"></i>
                                <strong>Error:</strong> ${errorMessage}
                                <button type="button" class="close" data-dismiss="alert" aria-label="Close">
                                    <span aria-hidden="true">&times;</span>
                                </button>
                            </div>
                        </c:if>

                        <%-- PAGE BODY --%>
                        <div class="page-body">
                            <div class="row">
                                <div class="col-sm-12">

                                    <%-- SEARCH CARD --%>
                                    <div class="card">
                                        <div class="card-block">

                                            <form id="searchForm" action="CIListServlet" method="GET">
                                                <c:if test="${not empty ticketId}">
                                                    <input type="hidden" name="ticketId" value="${ticketId}">
                                                </c:if>

                                                <div class="row">
                                                    <%-- Keyword --%>
                                                    <div class="col-md-8">
                                                        <label class="col-form-label">
                                                            <i class="feather icon-search mr-1"></i>Search CI
                                                        </label>
                                                        <div class="input-group">
                                                            <input type="text"
                                                                   name="keyword"
                                                                   class="form-control"
                                                                   placeholder="Search by name, type, location, owner, date (dd/MM/yyyy)..."
                                                                   value="${keyword}">
                                                            <div class="input-group-append">
                                                                <button type="submit" class="btn btn-primary">
                                                                    <i class="feather icon-search"></i> Search
                                                                </button>
                                                                <c:if test="${not empty keyword or (status ne 'all')}">
                                                                    <a href="CIListServlet${not empty ticketId ? '?ticketId='.concat(ticketId) : ''}"
                                                                       class="btn btn-outline-secondary" title="Clear filters">
                                                                        <i class="feather icon-x"></i>
                                                                    </a>
                                                                </c:if>
                                                            </div>
                                                        </div>
                                                    </div>

                                                    <%-- Status - chi co 1 field name="status" duy nhat --%>
                                                    <div class="col-md-4">
                                                        <label class="col-form-label">
                                                            <i class="feather icon-filter mr-1"></i>Filter by Status
                                                        </label>
                                                        <select name="status"
                                                                class="form-control"
                                                                onchange="document.getElementById('searchForm').submit()">
                                                            <option value="all"         ${status eq 'all'         ? 'selected' : ''}>All</option>
                                                            <option value="Active"      ${status eq 'Active'      ? 'selected' : ''}>Active</option>
                                                            <option value="Inactive"    ${status eq 'Inactive'    ? 'selected' : ''}>Inactive</option>
                                                            <option value="Maintenance" ${status eq 'Maintenance' ? 'selected' : ''}>Maintenance</option>
                                                        </select>
                                                    </div>
                                                </div>
                                                <small class="text-muted mt-1 d-block">
                                                    Searches across: Name, Type, Location, Owner, Created Date (dd/MM/yyyy)
                                                </small>
                                            </form>

                                        </div>
                                    </div>
                                    <%-- SEARCH CARD END --%>

                                    <%-- CI LIST TABLE CARD --%>
                                    <div class="card">
                                        <div class="card-header d-flex justify-content-between align-items-center">
                                            <h5 class="mb-0">
                                                Configuration Items List
                                                <span class="badge badge-primary ml-2">${totalItems}</span>
                                            </h5>
                                            <small class="text-muted">
                                                Page ${currentPage} of ${totalPages}
                                            </small>
                                        </div>
                                        <div class="card-block table-border-style">
                                            <div class="table-responsive">
                                                <table class="table table-hover table-bordered">
                                                    <thead class="thead-light">
                                                        <tr>
                                                            <th style="width:50px">#</th>
                                                            <th>Asset Tag</th>
                                                            <th>Name</th>
                                                            <th>Type</th>
                                                            <th>Status</th>
                                                            <th>Location</th>
                                                            <th>Owner</th>
                                                            <th>Created At</th>
                                                            <th style="width:150px">Actions</th>
                                                        </tr>
                                                    </thead>
                                                    <tbody>
                                                        <c:choose>
                                                            <c:when test="${not empty ciList}">
                                                                <c:forEach var="ci" items="${ciList}" varStatus="loop">
                                                                    <tr>

                                                                        <td class="text-muted">${(currentPage - 1) * 10 + loop.count}</td>

                                                                        <td>
                                                                            <strong class="text-primary">${ci.assetTag}</strong>
                                                                        </td>

                                                                        <td>${ci.name}</td>

                                                                        <td>
                                                                            <c:choose>
                                                                                <c:when test="${not empty ci.assetType}">${ci.assetType}</c:when>
                                                                                <c:otherwise><span class="text-muted">—</span></c:otherwise>
                                                                            </c:choose>
                                                                        </td>

                                                                        <td>
                                                                            <c:choose>
                                                                                <c:when test="${ci.status eq 'Active'}">
                                                                                    <span class="badge badge-success">Active</span>
                                                                                </c:when>
                                                                                <c:when test="${ci.status eq 'Inactive'}">
                                                                                    <span class="badge badge-secondary">Inactive</span>
                                                                                </c:when>
                                                                                <c:when test="${ci.status eq 'Maintenance'}">
                                                                                    <span class="badge badge-warning">Maintenance</span>
                                                                                </c:when>
                                                                                <c:otherwise>
                                                                                    <span class="badge badge-light">${ci.status}</span>
                                                                                </c:otherwise>
                                                                            </c:choose>
                                                                        </td>

                                                                        <td>
                                                                            <c:choose>
                                                                                <c:when test="${not empty ci.locationName}">
                                                                                    <i class="feather icon-map-pin text-muted mr-1"></i>${ci.locationName}
                                                                                </c:when>
                                                                                <c:otherwise>
                                                                                    <span class="text-muted">—</span>
                                                                                </c:otherwise>
                                                                            </c:choose>
                                                                        </td>

                                                                        <td>
                                                                            <c:choose>
                                                                                <c:when test="${not empty ci.ownerName}">
                                                                                    <i class="feather icon-user text-muted mr-1"></i>${ci.ownerName}
                                                                                </c:when>
                                                                                <c:otherwise>
                                                                                    <span class="text-muted">—</span>
                                                                                </c:otherwise>
                                                                            </c:choose>
                                                                        </td>

                                                                        <td>
                                                                            <fmt:formatDate value="${ci.createdAt}" pattern="dd/MM/yyyy"/>
                                                                        </td>

                                                                        <%-- ACTIONS: View + Map + Link to Ticket --%>
                                                                        <td>
                                                                            <%-- View detail --%>
                                                                            <a href="CIDetailServlet?id=${ci.id}${not empty ticketId ? '&ticketId='.concat(ticketId) : ''}"
                                                                               class="btn btn-sm btn-info mb-1"
                                                                               title="View CI details">
                                                                                <i class="feather icon-eye"></i> View
                                                                            </a>
                                                                            <%-- View Relationship Map --%>
                                                                            <a href="CIRelationshipMapServlet?id=${ci.id}"
                                                                               class="btn btn-sm btn-warning mb-1"
                                                                               title="View Relationship Map">
                                                                                <i class="feather icon-share-2"></i> Map
                                                                            </a>
                                                                            <%-- Link to ticket (only shown when in ticket context) --%>
                                                                            <c:if test="${not empty ticketId}">
                                                                                <a href="LinkCIServlet?ciId=${ci.id}&ticketId=${ticketId}"
                                                                                   class="btn btn-sm btn-success mb-1"
                                                                                   title="Link this CI with Ticket #${ticketId}">
                                                                                    <i class="feather icon-link"></i> Link
                                                                                </a>
                                                                            </c:if>
                                                                        </td>

                                                                    </tr>
                                                                </c:forEach>
                                                            </c:when>

                                                            <c:otherwise>
                                                                <tr>
                                                                    <td colspan="9" class="text-center py-5">
                                                                        <i class="feather icon-database"
                                                                           style="font-size:2rem; color:#ccc;"></i>
                                                                        <p class="mt-2 mb-1 font-weight-bold text-muted">
                                                                            No Configuration Items found
                                                                        </p>
                                                                        <small class="text-muted">
                                                                            Try adjusting your search keyword or status filter.
                                                                        </small>
                                                                    </td>
                                                                </tr>
                                                            </c:otherwise>
                                                        </c:choose>
                                                    </tbody>
                                                </table>
                                            </div>
                                        </div>
                                        <%-- TABLE END --%>

                                        <%-- PAGINATION --%>
                                        <c:if test="${totalPages > 1}">
                                            <div class="text-center mt-3 mb-3">
                                                <nav aria-label="Pagination">
                                                    <ul class="pagination justify-content-center">

                                                        <li class="page-item ${currentPage le 1 ? 'disabled' : ''}">
                                                            <a class="page-link"
                                                               href="CIListServlet?page=${currentPage - 1}&keyword=${keyword}&status=${status}${not empty ticketId ? '&ticketId='.concat(ticketId) : ''}">
                                                                <i class="feather icon-chevron-left"></i>
                                                            </a>
                                                        </li>

                                                        <c:forEach begin="1" end="${totalPages}" var="i">
                                                            <li class="page-item ${currentPage eq i ? 'active' : ''}">
                                                                <a class="page-link"
                                                                   href="CIListServlet?page=${i}&keyword=${keyword}&status=${status}${not empty ticketId ? '&ticketId='.concat(ticketId) : ''}">
                                                                    ${i}
                                                                </a>
                                                            </li>
                                                        </c:forEach>

                                                        <li class="page-item ${currentPage ge totalPages ? 'disabled' : ''}">
                                                            <a class="page-link"
                                                               href="CIListServlet?page=${currentPage + 1}&keyword=${keyword}&status=${status}${not empty ticketId ? '&ticketId='.concat(ticketId) : ''}">
                                                                <i class="feather icon-chevron-right"></i>
                                                            </a>
                                                        </li>

                                                    </ul>
                                                </nav>
                                            </div>
                                        </c:if>
                                        <%-- PAGINATION END --%>

                                    </div>
                                    <%-- CI LIST CARD END --%>

                                </div>
                            </div>
                        </div>
                        <%-- PAGE BODY END --%>

                    </div>
                </div>
            </div>
        </div>
    </div>
</div>
<%-- MAIN CONTENT END --%>

<script src="assets/js/vendor-all.min.js"></script>
<script src="assets/plugins/bootstrap/js/bootstrap.min.js"></script>
<script src="assets/js/pcoded.min.js"></script>



</body>
</html>
