<%-- 
    Document   : ProblemDetail
    Created on : Jan 18, 2026, 8:16:37 PM
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
    String role = (String) session.getAttribute("role");
    String problemListUrl = "IT Support".equals(role) ? "ITProblemListController" : "ProblemList";
    request.setAttribute("problemListUrl", problemListUrl);
    request.setAttribute("role", role != null ? role : "");
    
    model.Problems currentProblem = (model.Problems) request.getAttribute("problem");
    Integer activeTimeLogId = null;
    if (currentProblem != null) {
        activeTimeLogId = (Integer) session.getAttribute("activeTimeLogId_" + currentProblem.getId());
    }
    request.setAttribute("activeTimeLogId", activeTimeLogId);
%>
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
                                                    <h5 class="m-b-10">Problem Detail</h5>
                                                </div>
                                                <ul class="breadcrumb">
                                                    <li class="breadcrumb-item"><a href="index.html"><i class="feather icon-home"></i></a></li>
                                                    <li class="breadcrumb-item"><a href="${problemListUrl}">Problem List</a></li>
                                                    <li class="breadcrumb-item"><a href="#!">Problem Detail</a></li>
                                                </ul>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                            </div>
                            <!-- [ breadcrumb ] end -->
                            <c:if test="${param.error == 'cannot_edit'}">
                                <div class="alert alert-warning alert-dismissible fade show" role="alert">
                                    <strong>Thông báo:</strong> Không thể chỉnh sửa. Problem đang chờ duyệt hoặc đã được xử lý.
                                    <button type="button" class="close" data-dismiss="alert" aria-label="Close">
                                        <span aria-hidden="true">&times;</span>
                                    </button>
                                </div>
                            </c:if>
                            <c:if test="${not empty success}">
                                <div class="alert alert-success alert-dismissible fade show" role="alert">
                                    <strong>Thành công:</strong> ${success}
                                    <button type="button" class="close" data-dismiss="alert" aria-label="Close">
                                        <span aria-hidden="true">&times;</span>
                                    </button>
                                </div>
                            </c:if>
                            <!-- [ Main Content ] start -->
                            <div class="row">
                                <div class="col-sm-12">
                                    <div class="card">
                                        <div class="card-header">
                                            <h5>Problem Details</h5>
                                            <div class="card-header-right d-flex align-items-center gap-2">
                                                <c:if test="${role eq 'IT Support' and not empty problem and problem.status eq 'UNDER_INVESTIGATION'}">
                                                    <c:set var="hasRca" value="${not empty problem.rootCause and problem.rootCause.trim() ne ''}"/>
                                                    <c:set var="hasWorkaround" value="${not empty problem.workaround and problem.workaround.trim() ne ''}"/>
                                                    <c:if test="${hasRca and hasWorkaround}">
                                                        <form action="SubmitApproval" method="post" style="display:inline;">
                                                            <input type="hidden" name="problemId" value="${problem.id}">
                                                            <input type="hidden" name="status" value="PENDING">
                                                            <button type="submit" class="btn btn-sm btn-success"
                                                                    onclick="return confirm('Gửi problem này cho Manager duyệt?');">
                                                                <i class="feather icon-send"></i> Submit for approval
                                                            </button>
                                                        </form>
                                                    </c:if>
                                                </c:if>

                                                <c:if test="${role eq 'IT Support' 
    and not empty problem 
    and problem.status eq 'REJECTED'
    and not empty problem.rootCause
    and not empty problem.workaround}">
    
    <form action="SubmitApproval" method="post" style="display:inline;">
        <input type="hidden" name="problemId" value="${problem.id}">
        <input type="hidden" name="status" value="PENDING">
        <button type="submit" class="btn btn-sm btn-success"
                onclick="return confirm('RESUBMIT problem???');">
            <i class="feather icon-send"></i> ReSubmit
        </button>
    </form>

</c:if>


<c:if test="${role eq 'IT Support' and not empty problem and problem.status eq 'NEW'}">

    <form action="ProblemDetail" method="post" style="display:inline;">
        <input type="hidden" name="action" value="startInvestigation">
        <input type="hidden" name="problemId" value="${problem.id}">
        <button type="submit" class="btn btn-sm btn-warning"
                onclick="return confirm('Start investigation for this problem?');">
            <i class="feather icon-play-circle"></i> Start Investigation
        </button>
    </form>

</c:if>
                                                
                                                <c:if test="${role eq 'IT Support' 
                                                             and not empty problem 
                                                             and problem.status eq 'UNDER_INVESTIGATION' 
                                                             and activeTimeLogId != null}">
                                                    <form action="ProblemDetail" method="post" style="display:inline;">
                                                        <input type="hidden" name="action" value="markResolved">
                                                        <input type="hidden" name="problemId" value="${problem.id}">
                                                        <input type="hidden" name="timeLogId" value="${activeTimeLogId}">
                                                        <button type="submit" class="btn btn-sm btn-success"
                                                                onclick="return confirm('Mark this problem as RESOLVED and stop timer?');">
                                                            <i class="feather icon-check-circle"></i> Mark Resolved
                                                        </button>
                                                    </form>
                                                </c:if>
                                                
                                                
                                                <c:if test="${role eq 'Manager' and not empty problem and problem.status eq 'PENDING'}">
                                                    <form action="SubmitApproval" method="post" style="display:inline;">
                                                        <input type="hidden" name="problemId" value="${problem.id}">
                                                        <input type="hidden" name="status" value="APPROVED">
                                                        <button type="submit" class="btn btn-sm btn-outline-success"
                                                                onclick="return confirm('APPROVED this Problems?');">
                                                            <i class="feather icon-play-circle"></i> APPROVED
                                                        </button>
                                                    </form>
                                                </c:if>
                                                
                                                <c:if test="${role eq 'Manager' and not empty problem and problem.status eq 'PENDING'}">
                                                    <button type="button" class="btn btn-sm btn-gradient-danger" data-toggle="modal" data-target="#modalReject">
                                                        <i class="feather icon-play-circle"></i> REJECTED
                                                    </button>

                                                    <div class="modal fade" id="modalReject" tabindex="-1">
                                                        <div class="modal-dialog modal-dialog-centered">
                                                            <div class="modal-content">
                                                                <div class="modal-header">
                                                                    <h5 class="modal-title">Rejected Problem</h5>
                                                                    <button type="button" class="close" data-dismiss="modal">&times;</button>
                                                                </div>
                                                                <form action="SubmitApproval" method="post">
                                                                    <div class="modal-body">
                                                                        <input type="hidden" name="problemId" value="${problem.id}">
                                                                        <input type="hidden" name="status" value="REJECTED">
                                                                        <label>Lý do từ chối (tùy chọn)</label>
                                                                        <textarea name="rejectedReason" class="form-control" rows="3" 
                                                                                  placeholder="Nhập lý do từ chối..." maxlength="2000"></textarea>
                                                                    </div>
                                                                    <div class="modal-footer">
                                                                        <button type="button" class="btn btn-secondary" data-dismiss="modal">Hủy</button>
                                                                        <button type="submit" class="btn btn-danger"
                                                                                onclick="return confirm('Xác nhận từ chối?');">
                                                                            Xác nhận từ chối
                                                                        </button>
                                                                    </div>
                                                                </form>
                                                            </div>
                                                        </div>
                                                    </div>
                                                </c:if>
                                                
                                                
                                                <c:if test="${role eq 'IT Support' and not empty problem and problem.status ne 'NEW'}">
                                                    <a href="ProblemUpdate?Id=${problem.id}" class="btn btn-sm btn-primary">
                                                        <i class="feather icon-edit-2"></i> Update
                                                    </a>
                                                </c:if>
                                                <a href="${problemListUrl}" class="btn btn-sm btn-secondary">
                                                    <i class="feather icon-arrow-left"></i> Back to List
                                                </a>
                                            </div>
                                        </div>
                                        <div class="card-body">
                                            <c:if test="${not empty error}">
                                                <div class="alert alert-danger">
                                                    <h4>Error</h4>
                                                    <p>${error}</p>
                                                    <a href="${problemListUrl}" class="btn btn-primary">Back to Problem List</a>
                                                </div>
                                            </c:if>
                                                <div class="card-body">
                                                    <c:if test="${not empty problem and problem.status eq 'REJECTED' and not empty problem.rejectedReason}">
                                                        <div class="card border-danger mt-2">
                                                            <div class="card-header bg-danger text-white">
                                                                <i class="feather icon-alert-triangle"></i> Rejected Reason
                                                            </div>
                                                            <div class="card-body">
                                                                ${problem.rejectedReason}
                                                            </div>
                                                        </div>
                                                    </c:if>
                                                    <c:if test="${not empty error}">
                                                        <div class="alert alert-danger">
                                                            <h4>Error</h4>
                                                            <p>${error}</p>
                                                            <a href="${problemListUrl}" class="btn btn-primary">Back to Problem List</a>
                                                        </div>
                                                    </c:if>
                                                    <c:if test="${empty error}">
                                                        <c:choose>
                                                            <c:when test="${empty problem}">
                                                                <div class="alert alert-warning">
                                                                    <h4>Problem not found</h4>
                                                                    <p>The problem you are looking for does not exist or has been deleted.</p>
                                                                    <a href="${problemListUrl}" class="btn btn-primary">Back to Problem List</a>
                                                                </div>
                                                            </c:when>
                                                            <c:otherwise>
                                                                <div class="row">
                                                                    <!-- Cột trái: Problem Details -->
                                                                    <div class="col-md-6 col-lg-6 pr-lg-3" style="min-width: 0;">
                                                                        <div class="table-responsive">
                                                                            <table class="table table-bordered">
                                                                                <tbody>
                                                                                    <tr>
                                                                                        <th width="200">ID</th>
                                                                                        <td>${problem.id}</td>
                                                                                    </tr>
                                                                                    <tr>
                                                                                        <th>Ticket Number</th>
                                                                                        <td><strong>${problem.ticketNumber}</strong></td>
                                                                                    </tr>
                                                                                    <tr>
                                                                                        <th>Title</th>
                                                                                        <td><strong>${problem.title}</strong></td>
                                                                                    </tr>
                                                                                    <tr>
                                                                                        <th>Status</th>
                                                                                        <td>
                                                                                            <span class="badge badge-status" data-status="${p.status}"">
                                                                                                ${problem.status}
                                                                                            </span>
                                                                                        </td>
                                                                                    </tr>
                                                                                    <tr>
                                                                                        <th>Description</th>
                                                                                        <td>
                                                                                            <div class="p-3 bg-light rounded">
                                                                                                ${problem.description != null ? problem.description : 'N/A'}
                                                                                            </div>
                                                                                        </td>
                                                                                    </tr>
                                                                                    <tr>
                                                                                        <th>Root Cause</th>
                                                                                        <td>
                                                                                            <div class="p-3 bg-light rounded">
                                                                                                ${problem.rootCause != null ? problem.rootCause : 'N/A'}
                                                                                            </div>
                                                                                        </td>
                                                                                    </tr>
                                                                                    <tr>
                                                                                        <th>Workaround</th>
                                                                                        <td>
                                                                                            <div class="p-3 bg-light rounded">
                                                                                                ${problem.workaround != null ? problem.workaround : 'N/A'}
                                                                                            </div>
                                                                                        </td>
                                                                                    </tr>
                                                                                    <tr>
                                                                                        <th>Created By</th>
                                                                                        <td>${problem.createdByName != null ? problem.createdByName : problem.createdBy}</td>
                                                                                    </tr>
                                                                                    <tr>
                                                                                        <th>Assigned To</th>
                                                                                        <td>
                                                                                            ${problem.assignedTo > 0 
                                                                                              ? (problem.assignedToName != null ? problem.assignedToName : problem.assignedTo)
                                                                                              : 'Not Assigned'}
                                                                                        </td>
                                                                                    </tr>
                                                                                    <tr>
                                                                                        <th>Created At</th>
                                                                                        <td>${problem.createdAt}</td>
                                                                                    </tr>
                                                                                    
                                                                                </tbody>
                                                                            </table>
                                                                        </div>
                                                                    </div>
                                                                    <!-- Cột phải: Related Tickets -->
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
                                                                                        <!-- BẮT BUỘC: table-responsive -->
                                                                                        <div class="table-responsive">
                                                                                            <table class="table table-hover table-sm mb-0">
                                                                                                <thead class="thead-light">
                                                                                                    <tr>
                                                                                                        <th>Ticket</th>
                                                                                                        <th>Type</th>
                                                                                                        <th>Status</th>
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
                                                                                                                <span class="badge badge-secondary">
                                                                                                                    ${ticket.ticketType}
                                                                                                                </span>
                                                                                                            </td>

                                                                                                            <td>
                                                                                                                <span class="badge badge-info">
                                                                                                                    ${ticket.status}
                                                                                                                </span>
                                                                                                            </td>

                                                                                                            <td class="text-center">
                                                                                                                <a href="TicketDetail?Id=${ticket.id}"
                                                                                                                   class="btn btn-sm btn-primary">
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
                                                                    <!-- Phần hiển thị lịch sử thời gian xử lý (timer) -->
                                                                    <div class="col-12 mt-4">
                                                                        <div class="card">
                                                                            <div class="card-header">
                                                                                <h5>Lịch sử thời gian xử lý</h5>
                                                                            </div>
                                                                            <div class="card-body">
                                                                                <table class="table table-sm table-hover">
                                                                                    <thead class="thead-light">
                                                                                        <tr>
                                                                                            <th>Agent</th>
                                                                                            <th>Bắt đầu</th>
                                                                                            <th>Kết thúc</th>
                                                                                            <th>Thời gian (giờ)</th>
                                                                                        </tr>
                                                                                    </thead>
                                                                                    <tbody>
                                                                                        <c:forEach var="log" items="${timeLogs}">
                                                                                            <tr>
                                                                                                <td>${log.fullName}</td>
                                                                                                <td><fmt:formatDate value="${log.startTime}" pattern="dd/MM/yyyy HH:mm:ss"/></td>
                                                                                                <td>
                                                                                                    <c:choose>
                                                                                                        <c:when test="${log.endTime != null}">
                                                                                                            <fmt:formatDate value="${log.endTime}" pattern="dd/MM/yyyy HH:mm:ss"/>
                                                                                                        </c:when>
                                                                                                        <c:otherwise>
                                                                                                            <span class="badge badge-warning">Đang chạy</span>
                                                                                                        </c:otherwise>
                                                                                                    </c:choose>
                                                                                                </td>
                                                                                                <td>
                                                                                                    <c:choose>
                                                                                                        <c:when test="${log.hours > 0}">
                                                                                                            <fmt:formatNumber value="${log.hours}" pattern="#.##"/> giờ
                                                                                                        </c:when>
                                                                                                        <c:when test="${log.endTime == null and log.id == activeTimeLogId}">
                                                                                                            <span class="badge badge-info">
                                                                                                                <span id="live-timer"
                                                                                                                      data-start="${log.startTime.time}">0h 00m 00s</span>
                                                                                                            </span>
                                                                                                        </c:when>
                                                                                                        <c:otherwise>-</c:otherwise>
                                                                                                    </c:choose>
                                                                                                </td>
                                                                                            </tr>
                                                                                        </c:forEach>
                                                                                        <c:if test="${empty timeLogs}">
                                                                                            <tr><td colspan="4" class="text-center">Chưa có phiên làm việc nào</td></tr>
                                                                                        </c:if>
                                                                                    </tbody>
                                                                                </table>

                                                                                <strong>Tổng thời gian tất cả phiên: ${totalTime} giờ</strong>
                                                                            </div>
                                                                        </div>
                                                                    </div>

                                                                </div>
                                                            </c:otherwise>
                                                        </c:choose>
                                                    </c:if>
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

        // Live timer cho phiên đang chạy
        const liveTimerEl = document.getElementById('live-timer');
        if (liveTimerEl && liveTimerEl.dataset.start) {
            const startMillis = parseInt(liveTimerEl.dataset.start, 10);

            function formatDuration(ms) {
                const totalSeconds = Math.floor(ms / 1000);
                const hours = Math.floor(totalSeconds / 3600);
                const minutes = Math.floor((totalSeconds % 3600) / 60);
                const seconds = totalSeconds % 60;

                const hh = hours.toString();
                const mm = minutes.toString().padStart(2, '0');
                const ss = seconds.toString().padStart(2, '0');

                return `${hh}h ${mm}m ${ss}s`;
            }

            function updateTimer() {
                const now = Date.now();
                const diff = now - startMillis;
                if (diff >= 0) {
                    liveTimerEl.textContent = formatDuration(diff);
                }
            }

            updateTimer();
            setInterval(updateTimer, 1000);
        }
    });
</script>