<%-- 
    Document   : ProblemUpdate
    Created on : Jan 18, 2026, 8:16:37 PM
    Author     : DELL
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ page import="dao.NotificationDao" %>
<%@ page import="model.Notifications" %>
<%@ page import="java.util.List" %>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<%@ taglib uri="jakarta.tags.fmt" prefix="fmt" %>
<%
    List<Notifications> notifications = new java.util.ArrayList<>();
    Integer userId = (Integer) session.getAttribute("userId");
    if (userId != null) {
        NotificationDao notificationDao = new NotificationDao();
        notifications = notificationDao.getAllNotifications();
    }
    request.setAttribute("notifications", notifications);
%>
<!DOCTYPE html>
<html lang="en">

<head>

    <title>Update Problem - IT Service Flow</title>
    <!-- HTML5 Shim and Respond.js IE11 support of HTML5 elements and media queries -->
    <!-- WARNING: Respond.js doesn't work if you view the page via file:// -->
    <!--[if lt IE 11]>
    	<script src="https://oss.maxcdn.com/libs/html5shiv/3.7.0/html5shiv.js"></script>
    	<script src="https://oss.maxcdn.com/libs/respond.js/1.4.2/respond.min.js"></script>
    	<![endif]-->
    <!-- Meta -->
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0, user-scalable=0, minimal-ui">
    <meta http-equiv="X-UA-Compatible" content="IE=edge" />
    <meta name="description" content="Update Problem - IT Service Flow" />
    <meta name="keywords" content="problem, update, IT service" />
    <meta name="author" content="Codedthemes" />

    <!-- Favicon icon -->
    <!--<link rel="icon" href="../assets/images/favicon.ico" type="image/x-icon">-->
    <!-- fontawesome icon -->
	<link rel="stylesheet" href="assets/fonts/fontawesome/css/fontawesome-all.min.css">
	<!-- animation css -->
	<link rel="stylesheet" href="assets/plugins/animation/css/animate.min.css">
	
	<!-- Bootstrap CSS -->
	<link rel="stylesheet" href="assets/plugins/bootstrap/css/bootstrap.min.css">

	<!-- vendor css -->
	<link rel="stylesheet" href="assets/css/style.css">
            <style>
    /* === FORCE FULL WIDTH – KILL BOXED LAYOUT === */

    /* ông nội */
    .pcoded-wrapper {
        max-width: 100% !important;
        width: 100% !important;
        margin: 0 !important;
    }

    /* cha */
    .pcoded-main-container {
        width: 100% !important;
        margin-left: 264px !important;
    }

    /* khi sidebar collapse */
    .pcoded-navbar.navbar-collapsed ~ .pcoded-main-container {
        margin-left: 80px !important;
    }

    /* con cháu */
    .pcoded-content,
    .pcoded-inner-content,
    .main-body,
    .page-wrapper {
        max-width: 100% !important;
        width: 100% !important;
    }

    /* tránh scroll ngang ảo */
    body {
        overflow-x: hidden;
    }
    </style>
</head>

<body class="">
    <!-- [ Pre-loader ] start -->
    <div class="loader-bg">
        <div class="loader-track">
            <div class="loader-fill"></div>
        </div>
    </div>
    <!-- [ Pre-loader ] End -->
    <jsp:include page="includes/sidebar.jsp"/>
    <jsp:include page="includes/header.jsp"/>
    <!-- [ Main Content ] start -->
    <div class="pcoded-main-container">
        <div class="pcoded-wrapper">
            <div class="pcoded-content">
                <div class="pcoded-inner-content">
                    <div class="main-body">
                        <div class="page-wrapper">
                            <!-- [ breadcrumb ] start -->
                            <div class="page-header">
                                <div class="page-block">
                                    <div class="row align-items-center">
                                        <div class="col-md-12">
                                            <div class="page-header-title">
                                                <h5 class="m-b-10">Update Problem</h5>
                                            </div>
                                            <ul class="breadcrumb">
                                                <li class="breadcrumb-item"><a href="index.html"><i class="feather icon-home"></i></a></li>
                                                <li class="breadcrumb-item"><a href="ProblemList">Problem List</a></li>
                                                <li class="breadcrumb-item"><a href="ProblemUpdate?Id=${problem.id}">Problem Update</a></li>
                                                <li class="breadcrumb-item"><a href="#!">Update Problem</a></li>
                                            </ul>
                                        </div>
                                    </div>
                                </div>
                            </div>
                            <!-- [ breadcrumb ] end -->
                            <!-- [ Main Content ] start -->
                            <div class="row">
                                <div class="col-sm-12">
                                    <div class="card">
                                        <div class="card-header">
                                            <h5><i class="feather icon-edit"></i> Update Problem</h5>
                                            <div class="card-header-right">
                                                <a href="ProblemDetail?Id=${problem.id}" class="btn btn-sm btn-secondary">
                                                    <i class="feather icon-eye"></i> View Detail
                                                </a>
                                                <a href="ProblemList" class="btn btn-sm btn-secondary">
                                                    <i class="feather icon-arrow-left"></i> Back to List
                                                </a>
                                            </div>
                                        </div>
                                        <div class="card-body">
                                            <c:if test="${not empty error}">
                                                <div class="alert alert-danger alert-dismissible fade show" role="alert">
                                                    <strong><i class="feather icon-alert-circle"></i> Error!</strong> ${error}
                                                    <button type="button" class="close" data-dismiss="alert" aria-label="Close">
                                                        <span aria-hidden="true">&times;</span>
                                                    </button>
                                                </div>
                                            </c:if>
                                            <c:if test="${not empty success}">
                                                <div class="alert alert-success alert-dismissible fade show" role="alert">
                                                    <strong><i class="feather icon-check-circle"></i> Success!</strong> ${success}
                                                    <button type="button" class="close" data-dismiss="alert" aria-label="Close">
                                                        <span aria-hidden="true">&times;</span>
                                                    </button>
                                                </div>
                                            </c:if>
                                            <c:choose>
                                                <c:when test="${empty problem && empty error}">
                                                    <div class="alert alert-warning">
                                                        <h4><i class="feather icon-alert-triangle"></i> Problem not found</h4>
                                                        <p>The problem you are looking for does not exist or has been deleted.</p>
                                                        <a href="ProblemList" class="btn btn-primary">Back to Problem List</a>
                                                    </div>
                                                </c:when>
                                                <c:otherwise>
                                                    <div class="row">
                                                        <!-- Cột trái: Form update -->
                                                        <div class="col-md-6 col-lg-6 pr-lg-3" style="min-width: 0;">
                                                    <form method="post" action="ProblemUpdate" id="updateProblemForm">
                                                        <!-- ID bắt buộc -->
                                                        <input type="hidden" name="Id" value="${problem.id}">

                                                        <div class="row">
                                                            <div class="col-md-12">
                                                                <div class="form-group">
                                                                    <label for="TicketNumber"><strong>Ticket Number</strong></label>
                                                                    <input type="text" class="form-control" id="TicketNumber" 
                                                                           value="${problem.ticketNumber}" readonly 
                                                                           style="background-color: #f8f9fa;">
                                                                    <small class="form-text text-muted">Ticket number cannot be changed</small>
                                                                </div>
                                                            </div>
                                                        </div>

                                                        <div class="row">
                                                            <div class="col-md-12">
                                                                <div class="form-group">
                                                                    <c:if test="${role eq 'IT Support'}">
                                                                        <input type="hidden" name="Title" value="${problem.title}">
                                                                    </c:if>
                                                                    <c:if test="${role ne 'IT Support'}">
                                                                        <label for="Title"><strong>Title <span class="text-danger">*</span></strong></label>
                                                                        <input type="text" class="form-control" id="Title" name="Title" value="${problem.title}"
                                                                               required placeholder="Enter problem title">
                                                                    </c:if>
                                                                </div>
                                                            </div>
                                                        </div>
                                                        <c:if test="${role eq 'IT Support'}">
                                                            <input type="hidden" id="Status" name="Status" value="${problem.status}">
                                                        </c:if>
                                                        <c:if test="${role ne 'IT Support'}">
                                                            <div class="row">
                                                                <div class="col-md-6">
                                                                    <div class="form-group">
                                                                        <label><strong>Status</strong></label>
                                                                        <input type="text" class="form-control" value="${problem.status}" readonly disabled>
                                                                        <input type="hidden" id="Status" name="Status" value="${problem.status}">
                                                                    </div>
                                                                </div>
                                                            </div>
                                                        </c:if>
                                                        
                                                        <div class="row">
                                                            <div class="col-md-12">
                                                                <div class="form-group">
                                                                    <c:if test="${role eq 'IT Support'}">
                                                                        <input type="hidden" name="AssignedTo" value="${problem.assignedTo}">
                                                                    </c:if>
                                                                    <c:if test="${role ne 'IT Support'}">
                                                                        <label for="AssignedTo"><strong>Assigned To</strong></label>
                                                                        <select id="AssignedTo" name="AssignedTo" class="form-control">
                                                                            <option value="">-- Select assignee --</option>
                                                                            <c:forEach items="${assignees}" var="u">
                                                                                <option value="${u.id}" ${u.id == problem.assignedTo ? 'selected' : ''}>
                                                                                    ${u.fullName} (${u.username})
                                                                                </option>
                                                                            </c:forEach>
                                                                        </select>
                                                                        <small class="form-text text-muted">
                                                                            Select the user who will handle this problem
                                                                        </small>
                                                                    </c:if>
                                                                </div>  
                                                            </div>
                                                        </div>
                                                                           
                                                        <c:if test="${role ne 'IT Support'}">
                                                            <div class="row">
                                                                <div class="col-md-12">
                                                                    <div class="form-group">
                                                                        <label for="Description"><strong>Description</strong></label>
                                                                        <textarea name="Description" id="Description" class="form-control" rows="4"
                                                                                  placeholder="Enter problem description">${problem.description}</textarea>
                                                                    </div>
                                                                </div>
                                                            </div>
                                                        </c:if>

                                                        <div class="row">
                                                            <div class="col-md-12">
                                                                <div class="form-group">
                                                                    <label for="RootCause"><strong>Root Cause</strong></label>
                                                                    <c:if test="${role eq 'IT Support'}">
                                                                        <textarea name="RootCause" id="RootCause" 
                                                                                  class="form-control" rows="3" 
                                                                                  placeholder="Enter root cause analysis">${problem.rootCause}</textarea>
                                                                    </c:if>
                                                                    <c:if test="${role ne 'IT Support'}">
                                                                        <textarea id="RootCause" class="form-control" rows="3" readonly
                                                                                  style="background-color: #f8f9fa;">${problem.rootCause != null ? problem.rootCause : ''}</textarea>
                                                                    </c:if>
                                                                </div>
                                                            </div>
                                                        </div>
                                                        <div class="row">
                                                            <div class="col-md-12">
                                                                <div class="form-group">
                                                                    <label for="Workaround"><strong>Workaround</strong></label>
                                                                    <c:if test="${role eq 'IT Support'}">
                                                                        <textarea name="Workaround" id="Workaround" 
                                                                                  class="form-control" rows="3" 
                                                                                  placeholder="Enter workaround solution">${problem.workaround}</textarea>
                                                                    </c:if>
                                                                    <c:if test="${role ne 'IT Support'}">
                                                                        <textarea id="Workaround" class="form-control" rows="3" readonly
                                                                                  style="background-color: #f8f9fa;">${problem.workaround != null ? problem.workaround : ''}</textarea>
                                                                    </c:if>
                                                                </div>
                                                            </div>
                                                        </div>
                                                        <hr>                                                     
                                                        <hr>

                                                        <div class="row">
                                                            <div class="col-md-6">
                                                                <div class="form-group">
                                                                    <label><strong>Created By</strong></label>
                                                                    <input type="text" class="form-control" 
                                                                           value="${problem.createdByName}" readonly 
                                                                           style="background-color: #f8f9fa;">
                                                                </div>
                                                            </div>
                                                            <div class="col-md-6">
                                                                <div class="form-group">
                                                                    <label><strong>Created At</strong></label>
                                                                    <input type="text" class="form-control" 
                                                                           value="${problem.createdAt}" readonly 
                                                                           style="background-color: #f8f9fa;">
                                                                </div>
                                                            </div>
                                                        </div>

                                                        <div class="form-group mt-4">
                                                            <button type="submit" class="btn btn-primary">
                                                                <i class="feather icon-save"></i> Update Problem
                                                            </button>
                                                            <a href="ProblemList" class="btn btn-secondary">
                                                                <i class="feather icon-x"></i> Cancel
                                                            </a>
                                                            <a href="ProblemList" class="btn btn-outline-secondary">
                                                                <i class="feather icon-list"></i> Back to List
                                                            </a>
                                                        </div>
                                                    </form>
                                                        </div>
                                                        <!-- Cột phải: Related Tickets -->
                                                        <div class="col-md-6 col-lg-6 pl-lg-0" style="min-width:0;">
                                                            <div class="card h-100">
                                                                <div class="card-header">
                                                                    <h5 class="m-0">
                                                                        <i class="feather icon-link"></i> Related Tickets
                                                                    </h5>
                                                                </div>
                                                                <div class="card-body p-2">
                                                            <c:choose>
                                                                <c:when test="${empty relatedTickets}">
                                                                    <div class="alert alert-info mb-0">
                                                                        <i class="feather icon-info"></i>
                                                                        No related tickets found for this problem.
                                                                    </div>
                                                                </c:when>
                                                                <c:otherwise>
                                                                    <div class="table-responsive">
                                                                        <table class="table table-hover table-sm mb-0">
                                                                            <thead class="thead-light">
                                                                                <tr>
                                                                                    <th>Ticket</th>
                                                                                    <th>Type</th>
                                                                                    <!--<th>Status</th>-->
                                                                                    <th class="text-center">Action</th>
                                                                                </tr>
                                                                            </thead>
                                                                            <tbody>
                                                                                <c:forEach items="${relatedTickets}" var="ticket">
                                                                                    <tr>
                                                                                        <td style="max-width:120px; white-space:nowrap; overflow:hidden; text-overflow:ellipsis;">
                                                                                            <strong>${ticket.ticketNumber}</strong><br/>
                                                                                            <small class="text-muted">${ticket.title}</small>
                                                                                        </td>
                                                                                        <td>
                                                                                            <span class="badge badge-secondary">${ticket.ticketType}</span>
                                                                                        </td>
<!--                                                                                        <td>
                                                                                            <span class="badge badge-info">${ticket.status}</span>
                                                                                        </td>-->
                                                                                        <td class="text-center">
                                                                                            <a href="TicketDetail?Id=${ticket.id}" class="btn btn-sm btn-primary">
                                                                                                <i class="feather icon-eye"></i>
                                                                                            </a>
                                                                                        </td>
                                                                                    </tr>
                                                                                </c:forEach>
                                                                            </tbody>
                                                                        </table>
                                                                    </div>
                                                                </c:otherwise>
                                                            </c:choose>
                                                                </div>
                                                            </div>
                                                        </div>
                                                    </div>
                                                </c:otherwise>
                                            </c:choose>
                                        </div>
                                    </div>
                                </div>
                            </div>
                            <!-- [ Main Content ] end -->
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
    <!-- [ Main Content ] end -->

    <!-- Required Js -->
    <script src="assets/plugins/jquery/js/jquery.min.js"></script>
	<script src="assets/js/vendor-all.min.js"></script>
	<script src="assets/plugins/bootstrap/js/bootstrap.min.js"></script>
	<script src="assets/js/pcoded.min.js"></script>
</body>

</html>

<script>
    $(document).ready(function () {
        $('.fixed-button').remove();
        
        // Form validation
        $('#updateProblemForm').on('submit', function(e) {
            var title = $('#Title').val().trim();
            var status = $('#Status').val();
            
            if (!title) {
                e.preventDefault();
                alert('Please enter a title for the problem.');
                $('#Title').focus();
                return false;
            }
            
            if (!status) {
                e.preventDefault();
                alert('Please select a status.');
                $('#Status').focus();
                return false;
            }
        });
    });
</script>