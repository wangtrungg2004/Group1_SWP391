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
    <title>Ticket Detail | ITServiceFlow</title>
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
                <li class="nav-item">
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
                                            <h4>Ticket Detail</h4>
                                            <span>View detailed information of selected ticket.</span>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>

                        <div class="mb-3">
                            <a href="Long_TicketListServlet" class="btn btn-secondary btn-sm">
                                <i class="feather icon-arrow-left"></i> Back to Ticket List
                            </a>
                        </div>

                        <c:if test="${not empty errorMessage}">
                            <div class="alert alert-danger" role="alert">
                                <i class="feather icon-alert-circle"></i>
                                ${errorMessage}
                            </div>
                        </c:if>

                        <c:if test="${not empty ticket}">
                            <div class="row">
                                <div class="col-md-12">
                                    <div class="card">
                                        <div class="card-header">
                                            <h5 class="mb-0">${ticket.ticketNumber} - ${ticket.title}</h5>
                                        </div>
                                        <div class="card-body">
                                            <div class="row">
                                                <div class="col-md-6">
                                                    <table class="table table-bordered">
                                                        <tr>
                                                            <th style="width: 35%">Ticket ID</th>
                                                            <td>${ticket.id}</td>
                                                        </tr>
                                                        <tr>
                                                            <th>Ticket Number</th>
                                                            <td>${ticket.ticketNumber}</td>
                                                        </tr>
                                                        <tr>
                                                            <th>Type</th>
                                                            <td>${ticket.ticketType}</td>
                                                        </tr>
                                                        <tr>
                                                            <th>Status</th>
                                                            <td>
                                                                <c:choose>
                                                                    <c:when test="${ticket.status eq 'New'}">
                                                                        <span class="badge badge-info">New</span>
                                                                    </c:when>
                                                                    <c:when test="${ticket.status eq 'Resolved'}">
                                                                        <span class="badge badge-success">Resolved</span>
                                                                    </c:when>
                                                                    <c:when test="${ticket.status eq 'Closed'}">
                                                                        <span class="badge badge-secondary">Closed</span>
                                                                    </c:when>
                                                                    <c:otherwise>
                                                                        <span class="badge badge-light">${ticket.status}</span>
                                                                    </c:otherwise>
                                                                </c:choose>
                                                            </td>
                                                        </tr>
                                                        <tr>
                                                            <th>Category</th>
                                                            <td>${empty ticket.categoryName ? '—' : ticket.categoryName}</td>
                                                        </tr>
                                                        <tr>
                                                            <th>Location</th>
                                                            <td>${empty ticket.locationName ? '—' : ticket.locationName}</td>
                                                        </tr>
                                                    </table>
                                                </div>

                                                <div class="col-md-6">
                                                    <table class="table table-bordered">
                                                        <tr>
                                                            <th style="width: 35%">Priority Level</th>
                                                            <td>${empty ticket.priorityLevel ? '—' : ticket.priorityLevel}</td>
                                                        </tr>
                                                        <tr>
                                                            <th>Impact</th>
                                                            <td>${empty ticket.impact ? '—' : ticket.impact}</td>
                                                        </tr>
                                                        <tr>
                                                            <th>Urgency</th>
                                                            <td>${empty ticket.urgency ? '—' : ticket.urgency}</td>
                                                        </tr>
                                                        <tr>
                                                            <th>Created By</th>
                                                            <td>${ticket.createdBy}</td>
                                                        </tr>
                                                        <tr>
                                                            <th>Assigned To</th>
                                                            <td>${empty ticket.assignedTo ? '—' : ticket.assignedTo}</td>
                                                        </tr>
                                                        <tr>
                                                            <th>Current Level</th>
                                                            <td>${empty ticket.currentLevel ? '—' : ticket.currentLevel}</td>
                                                        </tr>
                                                    </table>
                                                </div>
                                            </div>

                                            <div class="row mt-3">
                                                <div class="col-md-12">
                                                    <div class="card mb-0 border">
                                                        <div class="card-header bg-light">
                                                            <strong>Description</strong>
                                                        </div>
                                                        <div class="card-body">
                                                            <c:choose>
                                                                <c:when test="${not empty ticket.description}">
                                                                    <p class="mb-0" style="white-space: pre-line;">${ticket.description}</p>
                                                                </c:when>
                                                                <c:otherwise>
                                                                    <p class="text-muted mb-0">No description.</p>
                                                                </c:otherwise>
                                                            </c:choose>
                                                        </div>
                                                    </div>
                                                </div>
                                            </div>

                                            <div class="row mt-3">
                                                <div class="col-md-12">
                                                    <table class="table table-bordered">
                                                        <tr>
                                                            <th style="width: 20%">Created At</th>
                                                            <td>
                                                                <c:choose>
                                                                    <c:when test="${not empty ticket.createdAt}">
                                                                        <fmt:formatDate value="${ticket.createdAt}" pattern="dd/MM/yyyy HH:mm:ss"/>
                                                                    </c:when>
                                                                    <c:otherwise>—</c:otherwise>
                                                                </c:choose>
                                                            </td>
                                                        </tr>
                                                        <tr>
                                                            <th>Updated At</th>
                                                            <td>
                                                                <c:choose>
                                                                    <c:when test="${not empty ticket.updatedAt}">
                                                                        <fmt:formatDate value="${ticket.updatedAt}" pattern="dd/MM/yyyy HH:mm:ss"/>
                                                                    </c:when>
                                                                    <c:otherwise>—</c:otherwise>
                                                                </c:choose>
                                                            </td>
                                                        </tr>
                                                        <tr>
                                                            <th>Resolved At</th>
                                                            <td>
                                                                <c:choose>
                                                                    <c:when test="${not empty ticket.resolvedAt}">
                                                                        <fmt:formatDate value="${ticket.resolvedAt}" pattern="dd/MM/yyyy HH:mm:ss"/>
                                                                    </c:when>
                                                                    <c:otherwise>—</c:otherwise>
                                                                </c:choose>
                                                            </td>
                                                        </tr>
                                                        <tr>
                                                            <th>Closed At</th>
                                                            <td>
                                                                <c:choose>
                                                                    <c:when test="${not empty ticket.closedAt}">
                                                                        <fmt:formatDate value="${ticket.closedAt}" pattern="dd/MM/yyyy HH:mm:ss"/>
                                                                    </c:when>
                                                                    <c:otherwise>—</c:otherwise>
                                                                </c:choose>
                                                            </td>
                                                        </tr>
                                                    </table>
                                                </div>
                                            </div>

                                        </div>
                                    </div>
                                </div>
                            </div>
                        </c:if>

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
