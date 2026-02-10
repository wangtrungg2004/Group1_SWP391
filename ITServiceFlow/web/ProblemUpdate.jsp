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

</head>

<body class="">
    <!-- [ Pre-loader ] start -->
    <div class="loader-bg">
        <div class="loader-track">
            <div class="loader-fill"></div>
        </div>
    </div>
    <!-- [ Pre-loader ] End -->
    <!-- [ navigation menu ] start -->
	<nav class="pcoded-navbar menupos-fixed menu-light brand-blue ">
		<div class="navbar-wrapper ">
			<div class="navbar-brand header-logo">
				<a href="AdminDashboard.jsp" class="b-brand">
<!--					<img src="assets/images/logo.svg" alt="" class="logo images">
					<img src="assets/images/logo-icon.svg" alt="" class="logo-thumb images">-->
				</a>
				<a class="mobile-menu" id="mobile-collapse" href="#!"><span></span></a>
			</div>
			<div class="navbar-content scroll-div">
				<ul class="nav pcoded-inner-navbar">
					<li class="nav-item pcoded-menu-caption">
						<label>Navigation</label>
					</li>
					<li class="nav-item">
						<a href="AdminDashboard.jsp" class="nav-link"><span class="pcoded-micon"><i class="feather icon-home"></i></span><span class="pcoded-mtext">Dashboard</span></a>
					</li>
					
					<li class="nav-item pcoded-menu-caption">
						<label>Forms &amp; table</label>
					</li>
					<li class="nav-item">
						<a href="ProblemList" class="nav-link"><span class="pcoded-micon"><i class="feather icon-file-text"></i></span><span class="pcoded-mtext">Problem List</span></a>
					</li>
					<!-- Menu chỉ dành cho Admin -->
					<c:if test="${role == 'Admin'}">
						<li class="nav-item pcoded-menu-caption">
							<label>Quản trị hệ thống</label>
						</li>
						<li class="nav-item">
							<a href="UserManagement" class="nav-link"><span class="pcoded-micon"><i class="feather icon-users"></i></span><span class="pcoded-mtext">Quản lý User</span></a>
						</li>
						<li class="nav-item">
							<a href="SystemSettings" class="nav-link"><span class="pcoded-micon"><i class="feather icon-settings"></i></span><span class="pcoded-mtext">Cài đặt hệ thống</span></a>
						</li>
					</c:if>
					
					<!-- Menu cho Manager và Admin -->
					<c:if test="${role == 'Admin' || role == 'Manager'}">
						<li class="nav-item pcoded-menu-caption">
							<label>Báo cáo</label>
						</li>
						<li class="nav-item">
							<a href="Reports" class="nav-link"><span class="pcoded-micon"><i class="feather icon-file-text"></i></span><span class="pcoded-mtext">Xem báo cáo</span></a>
						</li>
					</c:if>
					
					<!-- Menu cho IT Support và Admin -->
					<c:if test="${role == 'IT Support' || role == 'Admin'}">
						<li class="nav-item pcoded-menu-caption">
							<label>Hỗ trợ</label>
						</li>
						<li class="nav-item">
							<a href="Tickets" class="nav-link"><span class="pcoded-micon"><i class="feather icon-help-circle"></i></span><span class="pcoded-mtext">Quản lý Ticket</span></a>
						</li>
					</c:if>
				</ul>
			</div>
		</div>
	</nav>
	<!-- [ navigation menu ] end -->

    <!-- [ Header ] start -->
    <header class="navbar pcoded-header navbar-expand-lg navbar-light headerpos-fixed">
        <div class="m-header">
            <a class="mobile-menu" id="mobile-collapse1" href="#!"><span></span></a>
            <a href="index.html" class="b-brand">
                <img src="assets/images/logo.svg" alt="" class="logo images">
                <img src="assets/images/logo-icon.svg" alt="" class="logo-thumb images">
            </a>
        </div>
        <a class="mobile-menu" id="mobile-header" href="#!">
            <i class="feather icon-more-horizontal"></i>
        </a>
        <div class="collapse navbar-collapse">
            <a href="#!" class="mob-toggler"></a>
            <ul class="navbar-nav mr-auto">
                <li class="nav-item">
                    <div class="main-search open">
                        <div class="input-group">
                            <input type="text" id="m-search" class="form-control" placeholder="Search . . .">
                            <a href="#!" class="input-group-append search-close">
                                <i class="feather icon-x input-group-text"></i>
                            </a>
                            <span class="input-group-append search-btn btn btn-primary">
                                <i class="feather icon-search input-group-text"></i>
                            </span>
                        </div>
                    </div>
                </li>
            </ul>
            <ul class="navbar-nav ml-auto">
                <li>
                    <div class="dropdown">
                        <a class="dropdown-toggle" href="#" data-toggle="dropdown"><i class="icon feather icon-bell"></i></a>
                        <div class="dropdown-menu dropdown-menu-right notification">
                            <div class="noti-head">
                                <h6 class="d-inline-block m-b-0">Notifications</h6>
                                <div class="float-right">
                                    <a href="#!" class="m-r-10">mark as read</a>
                                    <a href="#!">clear all</a>
                                </div>
                            </div>
                            <ul class="noti-body">
                                <c:choose>
                                    <c:when test="${empty notifications}">
                                        <li class="notification"><p class="text-muted m-2">No notifications</p></li>
                                    </c:when>
                                    <c:otherwise>
                                        <c:forEach items="${notifications}" var="notification">
                                            <c:if test="${notification.userId == sessionScope.userId}">
                                                <li class="notification">
                                                    <div class="media">
                                                        <img class="img-radius" src="assets/images/user/avatar-1.jpg" alt="">
                                                        <div class="media-body">
                                                            <p>
                                                                <span class="n-time text-muted">
                                                                    <i class="icon feather icon-clock m-r-10"></i>
                                                                    <fmt:formatDate value="${notification.createdAt}" pattern="dd/MM/yyyy HH:mm"/>
                                                                </span>
                                                            </p>
                                                            <p><c:out value="${notification.message}"/></p>
                                                        </div>
                                                    </div>
                                                </li>
                                            </c:if>
                                        </c:forEach>
                                    </c:otherwise>
                                </c:choose>
                            </ul>
                            <div class="noti-footer">
                                <a href="#!">show all</a>
                            </div>
                        </div>
                    </div>
                </li>
                <li>
                    <div class="dropdown drp-user">
                        <a href="#" class="dropdown-toggle" data-toggle="dropdown">
                            <i class="icon feather icon-settings"></i>
                        </a>
                        <div class="dropdown-menu dropdown-menu-right profile-notification">
                            <div class="pro-head">
                                <img src="assets/images/user/avatar-1.jpg" class="img-radius" alt="User-Profile-Image">
                                <span>John Doe</span>
                                <a href="auth-signin.html" class="dud-logout" title="Logout">
                                    <i class="feather icon-log-out"></i>
                                </a>
                            </div>
                            <ul class="pro-body">
                                <li><a href="#!" class="dropdown-item"><i class="feather icon-settings"></i> Settings</a></li>
                                <li><a href="#!" class="dropdown-item"><i class="feather icon-user"></i> Profile</a></li>
                                <li><a href="message.html" class="dropdown-item"><i class="feather icon-mail"></i> My Messages</a></li>
                                <li><a href="auth-signin.html" class="dropdown-item"><i class="feather icon-lock"></i> Lock Screen</a></li>
                            </ul>
                        </div>
                    </div>
                </li>
            </ul>
        </div>
    </header>
    <!-- [ Header ] end -->
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
                                                <li class="breadcrumb-item"><a href="ProblemDetail?Id=${problem.id}">Problem Detail</a></li>
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
                                                                    <label for="Title"><strong>Title <span class="text-danger">*</span></strong></label>
                                                                    <input type="text" class="form-control" id="Title"
                                                                           name="Title" value="${problem.title}" required
                                                                           placeholder="Enter problem title">
                                                                </div>
                                                            </div>
                                                        </div>

                                                        <div class="row">
                                                            <div class="col-md-6">
                                                                <div class="form-group">
                                                                    <label for="Status"><strong>Status <span class="text-danger">*</span></strong></label>
                                                                    <select name="Status" id="Status" class="form-control" required>
                                                                        <option value="">-- Select Status --</option>
                                                                        <option value="NEW" ${problem.status == 'NEW' ? 'selected' : ''}>NEW</option>
                                                                        <option value="OPEN" ${problem.status == 'OPEN' ? 'selected' : ''}>OPEN</option>
                                                                        <option value="RESOLVED" ${problem.status == 'RESOLVED' ? 'selected' : ''}>RESOLVED</option>
                                                                        <option value="CLOSED" ${problem.status == 'CLOSED' ? 'selected' : ''}>CLOSED</option>
                                                                    </select>
                                                                </div>
                                                            </div>
                                                            <div class="col-md-6">
                                                                <div class="form-group">
                                                                    <label for="AssignedTo"><strong>Assigned To</strong></label>
                                                                    <input type="number" class="form-control" id="AssignedTo"
                                                                           name="AssignedTo" value="${problem.assignedTo}"
                                                                           placeholder="Enter user ID">
                                                                    <small class="form-text text-muted">Enter the user ID who will handle this problem</small>
                                                                </div>
                                                            </div>
                                                        </div>

                                                        <div class="row">
                                                            <div class="col-md-12">
                                                                <div class="form-group">
                                                                    <label for="Description"><strong>Description</strong></label>
                                                                    <textarea name="Description" id="Description" 
                                                                              class="form-control" rows="4" 
                                                                              placeholder="Enter problem description">${problem.description}</textarea>
                                                                </div>
                                                            </div>
                                                        </div>

                                                        <div class="row">
                                                            <div class="col-md-12">
                                                                <div class="form-group">
                                                                    <label for="RootCause"><strong>Root Cause</strong></label>
                                                                    <textarea name="RootCause" id="RootCause" 
                                                                              class="form-control" rows="3" 
                                                                              placeholder="Enter root cause analysis">${problem.rootCause}</textarea>
                                                                </div>
                                                            </div>
                                                        </div>

                                                        <div class="row">
                                                            <div class="col-md-12">
                                                                <div class="form-group">
                                                                    <label for="Workaround"><strong>Workaround</strong></label>
                                                                    <textarea name="Workaround" id="Workaround" 
                                                                              class="form-control" rows="3" 
                                                                              placeholder="Enter workaround solution">${problem.workaround}</textarea>
                                                                </div>
                                                            </div>
                                                        </div>

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