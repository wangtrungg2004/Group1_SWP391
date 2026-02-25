<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html lang="en">

<head>
    <title>CI Detail - ${ci.assetTag} | ITServiceFlow</title>
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
                                            <h4>Configuration Item Detail</h4>
                                            <span>Asset Tag: <strong>${ci.assetTag}</strong> | ${ci.name}</span>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>

                        <div class="page-body">

                            <div class="card">
                                <div class="card-header">
                                    <h5>Basic Information</h5>
                                    <c:if test="${not empty ticketId}">
                                        <div class="card-header-right">
                                            <a href="LinkCIServlet?ciId=${ci.id}&ticketId=${ticketId}" class="btn btn-success btn-sm">
                                                <i class="feather icon-link"></i> Link to Ticket #${ticket.ticketNumber}
                                            </a>
                                        </div>
                                    </c:if>
                                </div>
                                <div class="card-block">
                                    <div class="row">
                                        <div class="col-md-6">
                                            <table class="table table-borderless table-striped">
                                                <tr>
                                                    <th width="160">Asset Tag</th>
                                                    <td><strong>${ci.assetTag}</strong></td>
                                                </tr>
                                                <tr>
                                                    <th>Name</th>
                                                    <td>${ci.name}</td>
                                                </tr>
                                                <tr>
                                                    <th>Type</th>
                                                    <td><c:out value="${not empty ci.assetType ? ci.assetType : 'N/A'}"/></td>
                                                </tr>
                                                <tr>
                                                    <th>Status</th>
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
                                                </tr>
                                            </table>
                                        </div>
                                        <div class="col-md-6">
                                            <table class="table table-borderless table-striped">
                                                <tr>
                                                    <th width="160">Location</th>
                                                    <td><c:out value="${not empty ci.locationName ? ci.locationName : 'N/A'}"/></td>
                                                </tr>
                                                <tr>
                                                    <th>Owner</th>
                                                    <td><c:out value="${not empty ci.ownerName ? ci.ownerName : 'N/A'}"/></td>
                                                </tr>
                                                <tr>
                                                    <th>Created At</th>
                                                    <td><fmt:formatDate value="${ci.createdAt}" pattern="dd/MM/yyyy HH:mm"/></td>
                                                </tr>
                                                <tr>
                                                    <th>Related Tickets</th>
                                                    <td>${relatedTicketCount} linked ticket(s)</td>
                                                </tr>
                                            </table>
                                        </div>
                                    </div>
                                </div>
                            </div>

                            <div class="card">
                                <div class="card-header">
                                    <h5>Related Configuration Items</h5>
                                </div>
                                <div class="card-block">
                                    <c:choose>
                                        <c:when test="${not empty relationships}">
                                            <div class="table-responsive">
                                                <table class="table table-hover table-bordered">
                                                    <thead class="thead-light">
                                                        <tr>
                                                            <th>Relationship Type</th>
                                                            <th>Related CI</th>
                                                            <th>Asset Tag</th>
                                                            <th>Description</th>
                                                        </tr>
                                                    </thead>
                                                    <tbody>
                                                        <c:forEach var="rel" items="${relationships}">
                                                            <tr>
                                                                <td><span class="badge badge-info">${rel.relationshipType}</span></td>
                                                                <td><c:out value="${not empty rel.targetName ? rel.targetName : '-'}"/></td>
                                                                <td><c:out value="${not empty rel.targetAssetTag ? rel.targetAssetTag : '-'}"/></td>
                                                                <td><c:out value="${not empty rel.description ? rel.description : '-'}"/></td>
                                                            </tr>
                                                        </c:forEach>
                                                    </tbody>
                                                </table>
                                            </div>
                                        </c:when>
                                        <c:otherwise>
                                            <div class="alert alert-info text-center mb-0">
                                                No related configuration items found.
                                            </div>
                                        </c:otherwise>
                                    </c:choose>
                                </div>
                            </div>

                            <div class="text-right mt-4">
                                <a href="CIListServlet" class="btn btn-secondary">
                                    <i class="feather icon-arrow-left"></i> Back to CI List
                                </a>
                                <c:if test="${not empty ticketId}">
                                    <a href="TicketLinkCIServlet?ticketId=${ticketId}" class="btn btn-primary ml-2">
                                        <i class="feather icon-file-text"></i> Back to Ticket
                                    </a>
                                </c:if>
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

</body>
</html>
