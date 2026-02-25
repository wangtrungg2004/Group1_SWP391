<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html lang="en">

<head>
    <title>Link CI to Ticket #${ticket.ticketNumber} | ITServiceFlow</title>
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
                <img src="assets/images/logo.svg" alt="ITServiceFlow" class="logo images">
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
                <li class="nav-item active">
                    <a href="ticket-list.jsp" class="nav-link">
                        <span class="pcoded-micon"><i class="feather icon-file-text"></i></span>
                        <span class="pcoded-mtext">Tickets</span>
                    </a>
                </li>
                <li class="nav-item">
                    <a href="CIListServlet" class="nav-link">
                        <span class="pcoded-micon"><i class="feather icon-database"></i></span>
                        <span class="pcoded-mtext">CMDB / Assets</span>
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
                                            <h4>Link Configuration Item to Ticket #${ticket.ticketNumber}</h4>
                                            <span>Attach IT assets (CI/Asset) to this ticket for tracking and SLA.</span>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>

                        <div class="page-body">

                            <div class="card">
                                <div class="card-header">
                                    <h5>Ticket Information</h5>
                                </div>
                                <div class="card-block">
                                    <div class="row">
                                        <div class="col-md-6">
                                            <table class="table table-borderless table-sm">
                                                <tr><th width="140">Ticket Number</th><td><strong>${ticket.ticketNumber}</strong></td></tr>
                                                <tr><th>Title</th><td><c:out value="${ticket.title}"/></td></tr>
                                                <tr><th>Type</th><td>
                                                    <span class="badge ${ticket.ticketType eq 'Incident' ? 'badge-danger' : 'badge-info'}">
                                                        ${ticket.ticketType}
                                                    </span>
                                                </td></tr>
                                                <tr><th>Status</th><td><span class="badge badge-warning">${ticket.status}</span></td></tr>
                                            </table>
                                        </div>
                                        <div class="col-md-6">
                                            <table class="table table-borderless table-sm">
                                                <tr><th width="140">Category</th><td><c:out value="${not empty ticket.categoryName ? ticket.categoryName : 'N/A'}"/></td></tr>
                                                <tr><th>Location</th><td><c:out value="${not empty ticket.locationName ? ticket.locationName : 'N/A'}"/></td></tr>
                                                <tr><th>Priority</th><td>
                                                    <c:if test="${ticket.priorityLevel != null}">
                                                        <span class="badge badge-pill ${ticket.priorityLevel <= 3 ? 'badge-danger' : ticket.priorityLevel <= 5 ? 'badge-warning' : 'badge-success'}">
                                                            P${ticket.priorityLevel}
                                                        </span>
                                                    </c:if>
                                                </td></tr>
                                                <tr><th>Created At</th><td><fmt:formatDate value="${ticket.createdAt}" pattern="dd/MM/yyyy HH:mm"/></td></tr>
                                            </table>
                                        </div>
                                    </div>
                                </div>
                            </div>

                            <div class="card">
                                <div class="card-header">
                                    <h5>Linked Configuration Items</h5>
                                    <div class="card-header-right">
                                        <a href="CIListServlet?ticketId=${ticket.id}" class="btn btn-primary btn-sm">
                                            <i class="feather icon-plus"></i> Link New CI
                                        </a>
                                    </div>
                                </div>
                                <div class="card-block">
                                    <c:choose>
                                        <c:when test="${not empty linkedCIs}">
                                            <div class="table-responsive">
                                                <table class="table table-hover table-bordered">
                                                    <thead class="thead-light">
                                                        <tr>
                                                            <th style="width:40px">#</th>
                                                            <th>Asset Tag</th>
                                                            <th>Name</th>
                                                            <th>Type</th>
                                                            <th>Status</th>
                                                            <th>Owner</th>
                                                            <th>Linked At</th>
                                                            <th style="width:180px">Actions</th>
                                                        </tr>
                                                    </thead>
                                                    <tbody>
                                                        <c:forEach var="ci" items="${linkedCIs}" varStatus="loop">
                                                            <tr>
                                                                <td>${loop.count}</td>
                                                                <td><strong>${ci.assetTag}</strong></td>
                                                                <td><c:out value="${ci.name}"/></td>
                                                                <td><c:out value="${not empty ci.assetType ? ci.assetType : '—'}"/></td>
                                                                <td>
                                                                    <c:choose>
                                                                        <c:when test="${ci.status eq 'Active'}"><span class="badge badge-success">Active</span></c:when>
                                                                        <c:when test="${ci.status eq 'Inactive'}"><span class="badge badge-secondary">Inactive</span></c:when>
                                                                        <c:when test="${ci.status eq 'Maintenance'}"><span class="badge badge-warning">Maintenance</span></c:when>
                                                                        <c:otherwise><span class="badge badge-light">${ci.status}</span></c:otherwise>
                                                                    </c:choose>
                                                                </td>
                                                                <td><c:out value="${not empty ci.ownerName ? ci.ownerName : '—'}"/></td>
                                                                <td>
                                                                    <c:choose>
                                                                        <c:when test="${not empty ci.linkedAt}"><fmt:formatDate value="${ci.linkedAt}" pattern="dd/MM/yyyy HH:mm"/></c:when>
                                                                        <c:otherwise>—</c:otherwise>
                                                                    </c:choose>
                                                                </td>
                                                                <td>
                                                                    <a href="CIDetailServlet?id=${ci.id}&ticketId=${ticket.id}" class="btn btn-sm btn-info mb-1" title="View CI">
                                                                        <i class="feather icon-eye"></i> View
                                                                    </a>
                                                                    <a href="RemoveLinkedCIServlet?ticketId=${ticket.id}&ciId=${ci.id}" class="btn btn-sm btn-danger mb-1 confirm-remove" title="Remove link">
                                                                        <i class="feather icon-trash-2"></i> Remove
                                                                    </a>
                                                                </td>
                                                            </tr>
                                                        </c:forEach>
                                                    </tbody>
                                                </table>
                                            </div>
                                        </c:when>
                                        <c:otherwise>
                                            <div class="alert alert-info text-center py-4">
                                                <i class="feather icon-info icon-3x mb-3"></i><br>
                                                <h5>No Configuration Items linked yet</h5>
                                                <p>Click "Link New CI" to attach an IT asset to this ticket.</p>
                                            </div>
                                        </c:otherwise>
                                    </c:choose>
                                </div>
                            </div>

                            <div class="text-right mt-4">
                                <a href="ticket-detail.jsp?id=${ticket.id}" class="btn btn-secondary">
                                    <i class="feather icon-arrow-left"></i> Back to Ticket Detail
                                </a>
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
document.querySelectorAll('.confirm-remove').forEach(function(el) {
    el.addEventListener('click', function(e) {
        if (!confirm('Remove this CI link from the ticket?')) {
            e.preventDefault();
        }
    });
});
</script>

</body>
</html>
