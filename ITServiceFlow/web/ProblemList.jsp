<%-- 
    Document   : ProblemList
    Created on : Jan 18, 2026, 8:16:37 PM
    Author     : DELL
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ taglib uri="jakarta.tags.functions" prefix="fn" %>
<%@ page import="dao.NotificationDao" %>
<%@ page import="model.Notifications" %>
<%@ page import="java.util.List" %>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<%@ taglib uri="jakarta.tags.fmt" prefix="fmt" %>
<!DOCTYPE html>
<html lang="en">

<head>

    <title>Flash Able - Most Trusted Admin Template</title>
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
    <meta name="description" content="Flash Able Bootstrap admin template made using Bootstrap 4 and it has huge amount of ready made feature, UI components, pages which completely fulfills any dashboard needs." />
    <meta name="keywords"
        content="admin templates, bootstrap admin templates, bootstrap 4, dashboard, dashboard templets, sass admin templets, html admin templates, responsive, bootstrap admin templates free download,premium bootstrap admin templates, Flash Able, Flash Able bootstrap admin template">
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
                                                <h5 class="m-b-10">Form Elements</h5>
                                            </div>
                                            <ul class="breadcrumb">
                                                <li class="breadcrumb-item"><a href="ProblemList"><i class="feather icon-home"></i></a></li>
                                                <li class="breadcrumb-item"><a href="#!">Problem Pending List</a></li>
                                                <li class="breadcrumb-item"><a href="#!">Problem Pending List</a></li>
                                            </ul>
                                        </div>
                                    </div>
                                </div>
                            </div>
                            <!-- [ breadcrumb ] end -->
                            <!-- [ Main Content ] start -->
                            <div class="row">
                                <!-- [ form-element ] start -->
                                <div class="col-sm-12">
                                    <div class="card">
                                        <div class="card-body table-border-style">
                                        <c:if test="${empty problem}">
                                            <div class="alert alert-warning">
                                             Problem list is empty
                                            </div>
                                        </c:if>
                                        <form action="ProblemList" method="get" class="mb-3">
                                            <div class="row mb-2">
                                                <div class="col-md-8">
                                                    <div class="input-group">
                                                        <input type="text" name="keyword" class="form-control"
                                                               placeholder="Search by Title or Ticket Number..."
                                                               value="${filterKeyword != null ? filterKeyword : ''}">
                                                        <div class="input-group-append">
                                                            <button type="submit" class="btn btn-primary">Search</button>
                                                        </div>
                                                    </div>
                                                </div>
                                            </div>
                                            <div class="row align-items-end">
                                                <div class="col-md-2">
                                                    <label class="mb-1 small text-muted">Status</label>
                                                    <select name="filterStatus" class="form-control">
                                                        <option value="">-- All --</option>
                                                        <option value="APPROVED" ${filterStatus == 'NEW' ? 'selected' : ''}>NEW</option>
                                                        <option value="REJECTED" ${filterStatus == 'UNDER_INVESTIGATION' ? 'selected' : ''}>UNDER_INVESTIGATION</option>
                                                        <!--<option value="RESOLVED" ${filterStatus == 'RESOLVED' ? 'selected' : ''}>RESOLVED</option>-->
                                                    </select>
                                                </div>
                                                <div class="col-md-2">
                                                    <label class="mb-1 small text-muted">From Date</label>
                                                    <input type="date" name="fromDate" class="form-control"
                                                           value="${filterFromDate != null ? filterFromDate : ''}">
                                                </div>
                                                <div class="col-md-2">
                                                    <label class="mb-1 small text-muted">To Date</label>
                                                    <input type="date" name="toDate" class="form-control"
                                                           value="${filterToDate != null ? filterToDate : ''}">
                                                </div>
                                                <div class="col-md-2">
                                                    <button type="submit" class="btn btn-secondary">Filter</button>
                                                </div>
                                            </div>
                                        </form>
                                        <div class="table-responsive">
                                            <table class="table table-hover">
                                                <thead class="thead-dark">
                                                    <tr>
                                                        <th>ID</th>
                                                        <th>Ticket Number</th>
                                                        <th>Title</th>
                                                        <th>Status</th>
                                                        <th>Created By</th>
                                                        <th>Assign To</th>
                                                        <th>Created At</th>
                                                        <th>Action</th>
                                                    </tr>
                                                </thead>
                                                <tbody>
                                                    <c:choose>
                                                        <c:when test="${empty problem}">
                                                            <tr>
                                                                <td colspan="6" class="text-center text-muted">
                                                                    <i>No problems found</i>
                                                                </td>
                                                            </tr>
                                                        </c:when>
                                                        <c:otherwise>
                                                            <c:forEach items="${problem}" var="p">
                                                                <tr>
                                                                    <td>${p.id}</td>
                                                                    <td>${p.ticketNumber}</td>
                                                                    <td>${p.title}</td>
                                                                    <td>
                                                                        <span class="badge badge-status" data-status="${p.status}">
                                                                            ${p.status}
                                                                        </span>
                                                                    </td>
                                                                    <td>${p.createdByName != null ? p.createdByName : p.createdBy}</td>
                                                                    <td>${p.assignedToName != null && p.assignedToName != '' ? p.assignedToName : '-'}</td>
                                                                    <td>${p.createdAt}</td>
                                                                    <td class="d-flex gap-1">
                                                                        <a class="btn btn-sm btn-primary"
                                                                           href="ProblemDetail?Id=${p.id}">
                                                                            Detail
                                                                        </a>
                                                                        <a class="btn btn-sm btn-primary"
                                                                           href="ProblemUpdate?Id=${p.id}">
                                                                            Update
                                                                        </a>
                                                                        <form action="ProblemList" method="post"
                                                                                onsubmit="return confirm('Delete this Problem?');"
                                                                                style="display:inline;">
                                                                              <input type="hidden" name="Id" value="${p.id}">
                                                                              <button type="submit" class="btn btn-sm btn-danger">
                                                                                  Delete
                                                                              </button>
                                                                          </form>
                                                                    </td>
                                                                </tr>
                                                            </c:forEach>
                                                        </c:otherwise>
                                                    </c:choose>
                                                </tbody>
                                            </table>
                                            <%-- Pagination --%>
                                                <c:if test="${totalPages != null && totalPages > 1}">
                                                    <nav aria-label="Page navigation" class="mt-3">
                                                        <ul class="pagination justify-content-center flex-wrap">
                                                            <li class="page-item ${currentPage == 1 ? 'disabled' : ''}">
                                                                <a class="page-link" href="ProblemList?page=${currentPage - 1}<c:if test='${not empty filterKeyword}'>&keyword=${filterKeyword}</c:if>">Previous</a>
                                                            </li>
                                                            <c:forEach begin="1" end="${totalPages}" var="i">
                                                                <li class="page-item ${i == currentPage ? 'active' : ''}">
                                                                    <a class="page-link" href="ProblemList?page=${i}<c:if test='${not empty filterKeyword}'>&keyword=${filterKeyword}</c:if>">${i}</a>
                                                                </li>
                                                            </c:forEach>
                                                            <li class="page-item ${currentPage == totalPages ? 'disabled' : ''}">
                                                                <a class="page-link" href="ProblemList?page=${currentPage + 1}<c:if test='${not empty filterKeyword}'>&keyword=${filterKeyword}</c:if>">Next</a>
                                                            </li>
                                                        </ul>
                                                    </nav>
                                                </c:if>
                                        </div>
                                    </div>

                                    </div>
                                    <!-- Input group -->
                                </div>
                                <!-- [ form-element ] end -->
                                <!-- [ Main Content ] end -->
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
    <!-- [ Main Content ] end -->

    <!-- Warning Section start -->
    <!-- Older IE warning message -->
    <!--[if lt IE 11]>
            <div class="ie-warning">
                <h1>Warning!!</h1>
                <p>You are using an outdated version of Internet Explorer, please upgrade
                   <br/>to any of the following web browsers to access this website.
                </p>
                <div class="iew-container">
                    <ul class="iew-download">
                        <li>
                            <a href="http://www.google.com/chrome/">
                                <img src="../assets/images/browser/chrome.png" alt="Chrome">
                                <div>Chrome</div>
                            </a>
                        </li>
                        <li>
                            <a href="https://www.mozilla.org/en-US/firefox/new/">
                                <img src="../assets/images/browser/firefox.png" alt="Firefox">
                                <div>Firefox</div>
                            </a>
                        </li>
                        <li>
                            <a href="http://www.opera.com">
                                <img src="../assets/images/browser/opera.png" alt="Opera">
                                <div>Opera</div>
                            </a>
                        </li>
                        <li>
                            <a href="https://www.apple.com/safari/">
                                <img src="../assets/images/browser/safari.png" alt="Safari">
                                <div>Safari</div>
                            </a>
                        </li>
                        <li>
                            <a href="http://windows.microsoft.com/en-us/internet-explorer/download-ie">
                                <img src="../assets/images/browser/ie.png" alt="">
                                <div>IE (11 & above)</div>
                            </a>
                        </li>
                    </ul>
                </div>
                <p>Sorry for the inconvenience!</p>
            </div>
        <![endif]-->
    <!-- Warning Section Ends -->

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
    });
</script>