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
    <title>Add New Problem - IT Service Flow</title>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">

    <link rel="stylesheet" href="assets/fonts/fontawesome/css/fontawesome-all.min.css">
    <link rel="stylesheet" href="assets/plugins/animation/css/animate.min.css">
    <link rel="stylesheet" href="assets/plugins/bootstrap/css/bootstrap.min.css">
    <link rel="stylesheet" href="assets/css/style.css">

    <!-- Make content stretch full width on this page -->
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

                        <!-- Header -->
                        <div class="page-header">
                            <h5>Add New Problem</h5>
                        </div>

                        <div class="row no-gutters">
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
                                        <form method="post" action="ProblemAdd" id="addProblemForm">
                                        <div class="row no-gutters">
                                            <!-- Left: Add Problem form -->
                                            <div class="col-md-4 col-lg-4 pr-lg-3">

                                                <!-- Error / Success -->
                                                <c:if test="${not empty error}">
                                                    <div class="alert alert-danger">${error}</div>
                                                </c:if>

                                                <c:if test="${not empty success}">
                                                    <div class="alert alert-success">${success}</div>
                                                </c:if>

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
                                                        <input type="text" class="form-control" value="NEW" readonly disabled>
                                                        <input type="hidden" name="Status" value="NEW">
                                                    </div>

                                                    <!-- Assigned To -->
                                                    <div class="form-group">
                                                        <label><strong>Assigned To</strong></label>
                                                        <select name="AssignedTo" class="form-control">
                                                            <option value="">-- Select assignee --</option>
                                                            <c:forEach items="${assignees}" var="u">
                                                                <%-- Nếu muốn lọc theo role, ví dụ chỉ IT Support: --%>
                                                                 <c:if test="${u.role == 'IT Support'}"> 
                                                                    <option value="${u.id}">
                                                                        ${u.fullName} (${u.username})
                                                                    </option>
                                                                 </c:if> 
                                                            </c:forEach>
                                                        </select>
                                                    </div>

                                                    <!-- Description -->
                                                    <div class="form-group">
                                                        <label><strong>Description</strong></label>
                                                        <textarea name="Description" class="form-control"
                                                                  rows="4" placeholder="Problem description"></textarea>
                                                    </div>

    <!--                                             Root Cause 
                                                    <div class="form-group">
                                                        <label><strong>Root Cause</strong></label>
                                                        <textarea name="RootCause" class="form-control"
                                                                  rows="3"></textarea>
                                                    </div>

                                                     Workaround 
                                                    <div class="form-group">
                                                        <label><strong>Workaround</strong></label>
                                                        <textarea name="Workaround" class="form-control"
                                                                  rows="3"></textarea>
                                                    </div>-->

                                                    <!-- Buttons -->
                                                    <div class="mt-4">
                                                        <button type="submit" class="btn btn-primary">
                                                            <i class="feather icon-save"></i> Add Problem
                                                        </button>
                                                        <a href="ProblemList" class="btn btn-secondary">
                                                            Cancel
                                                        </a>
                                                    </div>

                                            </div>

                                            <!-- Right: Related Tickets list -->
                                            <div class="col-md-8 col-lg-8 pl-0 pr-0">
                                                <div class="card h-100 border-0 rounded-0" style="margin-bottom:0">
                                                    <div class="card-header">
                                                        <h5 class="m-0">Related Tickets</h5>
                                                    </div>
                                                    <div class="card-body" style="max-height: 500px; overflow-y: auto;">
                                                        <c:if test="${empty Ticket}">
                                                            <div class="text-muted"><i>No tickets found</i></div>
                                                        </c:if>
                                                        <c:if test="${not empty Ticket}">
                                                            <div class="table-responsive w-100">
                                                                <table class="table table-sm table-hover mb-0 w-100">
                                                                    <thead>
                                                                        <tr>
                                                                            <th>No.</th>
                                                                            <th>Title</th>
                                                                            <th>Status</th>
                                                                            <th>Link Ticket</th>
                                                                        </tr>
                                                                    </thead>
                                                                    <tbody>
                                                                        <c:forEach items="${Ticket}" var="t">
                                                                            <tr>
                                                                                <td>${t.ticketNumber}</td>
                                                                                <td>${t.title}</td>
                                                                                <td>
                                                                                    <span class="badge badge-info">${t.status}</span>
                                                                                </td>
                                                                                <td>
                                                                                    <input type="checkbox" name="ticketIds" value="${t.id}" id="ticket_${t.id}">
                                                                                </td>
                                                                            </tr>
                                                                        </c:forEach>
                                                                    </tbody>
                                                                </table>
                                                            </div>
                                                        </c:if>
                                                    </div>
                                                </div>
                                            </div>

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
