<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <title>Add New Problem - IT Service Flow</title>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">

    <link rel="stylesheet" href="assets/fonts/fontawesome/css/fontawesome-all.min.css">
    <link rel="stylesheet" href="assets/plugins/animation/css/animate.min.css">
    <link rel="stylesheet" href="assets/plugins/bootstrap/css/bootstrap.min.css">
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
                <a href="AdminDashboard.jsp" class="b-brand"></a>
                <a class="mobile-menu" id="mobile-collapse" href="#!"><span></span></a>
            </div>
            <div class="navbar-content scroll-div">
                <ul class="nav pcoded-inner-navbar">
                    <li class="nav-item pcoded-menu-caption"><label>Navigation</label></li>
                    <li class="nav-item">
                        <a href="AdminDashboard.jsp" class="nav-link"><span class="pcoded-micon"><i class="feather icon-home"></i></span><span class="pcoded-mtext">Dashboard</span></a>
                    </li>
                    <li class="nav-item pcoded-menu-caption"><label>Forms &amp; table</label></li>
                    <li class="nav-item">
                        <a href="ProblemList" class="nav-link"><span class="pcoded-micon"><i class="feather icon-file-text"></i></span><span class="pcoded-mtext">Problem List</span></a>
                    </li>
                    <li class="nav-item">
                        <a href="ProblemAdd" class="nav-link"><span class="pcoded-micon"><i class="feather icon-plus"></i></span><span class="pcoded-mtext">Add Problem</span></a>
                    </li>
                </ul>
            </div>
        </div>
    </nav>
    <!-- [ navigation menu ] end -->
    <!-- [ Header ] start -->
    <header class="navbar pcoded-header navbar-expand-lg navbar-light headerpos-fixed">
        <div class="m-header">
            <a class="mobile-menu" id="mobile-collapse1" href="#!"><span></span></a>
            <a href="AdminDashboard.jsp" class="b-brand">
                <img src="assets/images/logo.svg" alt="" class="logo images">
                <img src="assets/images/logo-icon.svg" alt="" class="logo-thumb images">
            </a>
        </div>
        <a class="mobile-menu" id="mobile-header" href="#!"><i class="feather icon-more-horizontal"></i></a>
        <div class="collapse navbar-collapse">
            <a href="#!" class="mob-toggler"></a>
            <ul class="navbar-nav mr-auto">
                <li class="nav-item">
                    <div class="main-search open">
                        <div class="input-group">
                            <input type="text" id="m-search" class="form-control" placeholder="Search . . .">
                            <a href="#!" class="input-group-append search-close"><i class="feather icon-x input-group-text"></i></a>
                            <span class="input-group-append search-btn btn btn-primary"><i class="feather icon-search input-group-text"></i></span>
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
                                <div class="float-right"><a href="#!" class="m-r-10">mark as read</a><a href="#!">clear all</a></div>
                            </div>
                            <ul class="noti-body">
                                <li class="n-title"><p class="m-b-0">NEW</p></li>
                                <li class="notification">
                                    <div class="media">
                                        <img class="img-radius" src="assets/images/user/avatar-1.jpg" alt="">
                                        <div class="media-body">
                                            <p><strong>John Doe</strong><span class="n-time text-muted"><i class="icon feather icon-clock m-r-10"></i>5 min</span></p>
                                            <p>New ticket Added</p>
                                        </div>
                                    </div>
                                </li>
                            </ul>
                            <div class="noti-footer"><a href="#!">show all</a></div>
                        </div>
                    </div>
                </li>
                <li>
                    <div class="dropdown drp-user">
                        <a href="#" class="dropdown-toggle" data-toggle="dropdown"><i class="icon feather icon-settings"></i></a>
                        <div class="dropdown-menu dropdown-menu-right profile-notification">
                            <div class="pro-head">
                                <img src="assets/images/user/avatar-1.jpg" class="img-radius" alt="User-Profile-Image">
                                <span>John Doe</span>
                                <a href="auth-signin.html" class="dud-logout" title="Logout"><i class="feather icon-log-out"></i></a>
                            </div>
                            <ul class="pro-body">
                                <li><a href="#!" class="dropdown-item"><i class="feather icon-settings"></i> Settings</a></li>
                                <li><a href="#!" class="dropdown-item"><i class="feather icon-user"></i> Profile</a></li>
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

                        <!-- Header -->
                        <div class="page-header">
                            <h5>Add New Problem</h5>
                        </div>

                        <div class="row">
                            <div class="col-sm-12">
                                <div class="card">

                                    <div class="card-header">
                                        <h5><i class="feather icon-plus"></i> Add Problem</h5>
                                        <div class="card-header-right">
                                            <a href="ProblemList" class="btn btn-sm btn-secondary">
                                                <i class="feather icon-arrow-left"></i> Back to List
                                            </a>
                                        </div>
                                    </div>

                                    <div class="card-body">

                                        <!-- Error / Success -->
                                        <c:if test="${not empty error}">
                                            <div class="alert alert-danger">${error}</div>
                                        </c:if>

                                        <c:if test="${not empty success}">
                                            <div class="alert alert-success">${success}</div>
                                        </c:if>

                                        <!-- FORM ADD -->
                                        <form method="post" action="ProblemAdd" id="addProblemForm">

                                            <!-- Ticket Number -->
                                            <div class="form-group">
                                                <!--<label><strong>Ticket Number <span class="text-danger">*</span></strong></label>-->
                                                <input type="hidden" name="TicketNumber" class="form-control"
                                                        placeholder="Enter ticket number" readonly="true" required>
                                            </div>

                                            <!-- Title -->
                                            <div class="form-group">
                                                <label><strong>Title <span class="text-danger">*</span></strong></label>
                                                <input type="text" name="Title" class="form-control"
                                                       placeholder="Enter problem title" required>
                                            </div>

                                            <!-- Status -->
                                            <div class="form-group">
                                                <label><strong>Status</strong></label>
                                                <select name="Status" class="form-control">
                                                    <option value="NEW" selected>NEW</option>
                                                    <option value="OPEN">OPEN</option>
                                                    <option value="RESOLVED">RESOLVED</option>
                                                    <option value="CLOSED">CLOSED</option>
                                                </select>
                                            </div>

                                            <!-- Assigned To -->
                                            <div class="form-group">
                                                <label><strong>Assigned To</strong></label>
                                                <input type="number" name="AssignedTo" class="form-control"
                                                       placeholder="Enter user ID">
                                            </div>

                                            <!-- Description -->
                                            <div class="form-group">
                                                <label><strong>Description</strong></label>
                                                <textarea name="Description" class="form-control"
                                                          rows="4" placeholder="Problem description"></textarea>
                                            </div>

                                            <!-- Root Cause -->
                                            <div class="form-group">
                                                <label><strong>Root Cause</strong></label>
                                                <textarea name="RootCause" class="form-control"
                                                          rows="3"></textarea>
                                            </div>

                                            <!-- Workaround -->
                                            <div class="form-group">
                                                <label><strong>Workaround</strong></label>
                                                <textarea name="Workaround" class="form-control"
                                                          rows="3"></textarea>
                                            </div>

                                            <!-- Buttons -->
                                            <div class="mt-4">
                                                <button type="submit" class="btn btn-primary">
                                                    <i class="feather icon-save"></i> Add Problem
                                                </button>
                                                <a href="ProblemList" class="btn btn-secondary">
                                                    Cancel
                                                </a>
                                            </div>

                                        </form>
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

    <script src="assets/plugins/jquery/js/jquery.min.js"></script>
	<script src="assets/js/vendor-all.min.js"></script>
	<script src="assets/plugins/bootstrap/js/bootstrap.min.js"></script>
	<script src="assets/js/pcoded.min.js"></script>
<script>
    $('#addProblemForm').submit(function (e) {
        if (!$('input[name="Title"]').val().trim()) {
            alert('Title is required');
            e.preventDefault();
        }
    });
    
        $(document).ready(function () {
        $('.fixed-button').remove();
    });
</script>
</body>
</html>
