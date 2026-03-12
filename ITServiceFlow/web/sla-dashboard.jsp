<%-- Document : sla-dashboard Created on : Feb 14, 2026 Author : DELL --%>
    <%@page contentType="text/html" pageEncoding="UTF-8" %>
        <%@ taglib uri="jakarta.tags.core" prefix="c" %>
            <%@ taglib uri="jakarta.tags.fmt" prefix="fmt" %>
                <!DOCTYPE html>
                <html lang="en">

                <head>
                    <title>IT Service Flow - SLA Dashboard</title>
                    <meta charset="utf-8">
                    <meta name="viewport" content="width=device-width, initial-scale=1.0, user-scalable=0, minimal-ui">
                    <meta http-equiv="X-UA-Compatible" content="IE=edge" />

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

                    <jsp:include page="includes/sidebar.jsp" />
                    <jsp:include page="includes/header.jsp" />

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
                                                                <h5 class="m-b-10">SLA Dashboard</h5>
                                                            </div>
                                                            <ul class="breadcrumb">
                                                                <li class="breadcrumb-item"><a
                                                                        href="AdminDashboard.jsp"><i
                                                                            class="feather icon-home"></i></a></li>
                                                                <li class="breadcrumb-item"><a href="#!">SLA
                                                                        Management</a></li>
                                                                <li class="breadcrumb-item"><a href="#!">SLA
                                                                        Dashboard</a></li>
                                                            </ul>
                                                        </div>
                                                    </div>
                                                </div>
                                            </div>
                                            <!-- [ breadcrumb ] end -->

                                            <!-- [ Main Content ] start -->
                                            <!-- KPI Cards -->
                                            <div class="row">
                                                <div class="col-xl-3 col-md-6">
                                                    <div class="card bg-c-blue">
                                                        <div class="card-body text-center">
                                                            <i
                                                                class="feather icon-check-square f-30 text-white m-b-10"></i>
                                                            <h3 class="m-b-10 text-white">${stats['TotalTracked']}</h3>
                                                            <h6 class="m-t-10 text-white mb-0">Total Tracked</h6>
                                                        </div>
                                                    </div>
                                                </div>
                                                <div class="col-xl-3 col-md-6">
                                                    <div class="card bg-c-red">
                                                        <div class="card-body text-center">
                                                            <i
                                                                class="feather icon-alert-triangle f-30 text-white m-b-10"></i>
                                                            <h3 class="m-b-10 text-white">${stats['Breached']}</h3>
                                                            <h6 class="m-t-10 text-white mb-0">Breached</h6>
                                                        </div>
                                                    </div>
                                                </div>
                                                <div class="col-xl-3 col-md-6">
                                                    <div class="card bg-c-yellow">
                                                        <div class="card-body text-center">
                                                            <i class="feather icon-clock f-30 text-white m-b-10"></i>
                                                            <h3 class="m-b-10 text-white">${stats['NearBreach']}</h3>
                                                            <h6 class="m-t-10 text-white mb-0">Near Breach (< 2h)</h6>
                                                        </div>
                                                    </div>
                                                </div>
                                                <div class="col-xl-3 col-md-6">
                                                    <div class="card bg-c-green">
                                                        <div class="card-body text-center">
                                                            <i
                                                                class="feather icon-trending-up f-30 text-white m-b-10"></i>
                                                            <h3 class="m-b-10 text-white">${complianceRate}%</h3>
                                                            <h6 class="m-t-10 text-white mb-0">Compliance Rate</h6>
                                                        </div>
                                                    </div>
                                                </div>
                                            </div>

                                            <!-- Alert Tables -->
                                            <div class="row">
                                                <!-- Near Breach Tickets -->
                                                <div class="col-xl-6 col-md-12">
                                                    <div class="card">
                                                        <div class="card-header">
                                                            <h5>⚠️ Tickets Near Breach (Action Required)</h5>
                                                        </div>
                                                        <div class="card-body table-border-style">
                                                            <div class="table-responsive">
                                                                <table class="table table-hover">
                                                                    <thead>
                                                                        <tr>
                                                                            <th>Ticket #</th>
                                                                            <th>Title</th>
                                                                            <th>Deadline</th>
                                                                            <th>Assignee</th>
                                                                        </tr>
                                                                    </thead>
                                                                    <tbody>
                                                                        <c:if test="${empty nearBreachTickets}">
                                                                            <tr>
                                                                                <td colspan="4" class="text-center">No
                                                                                    urgent tickets found.</td>
                                                                            </tr>
                                                                        </c:if>
                                                                        <c:forEach items="${nearBreachTickets}" var="t">
                                                                            <tr>
<<<<<<< HEAD
                                                                                <td><a
                                                                                        href="tickets?action=view&id=${t['Id']}">${t['TicketNumber']}</a>
                                                                                </td>
=======
                                                                                <td>${t['TicketNumber']}</td>
>>>>>>> d2154b86978d31b564b8846d8826925bf10e211d
                                                                                <td>${t['Title']}</td>
                                                                                <td class="text-warning">
                                                                                    <fmt:formatDate
                                                                                        value="${t['ResolutionDeadline']}"
                                                                                        pattern="MM-dd HH:mm" />
                                                                                </td>
                                                                                <td>${t['AssignedTo']}</td>
                                                                            </tr>
                                                                        </c:forEach>
                                                                    </tbody>
                                                                </table>
                                                            </div>
                                                        </div>
                                                    </div>
                                                </div>

                                                <!-- Breached Tickets -->
                                                <div class="col-xl-6 col-md-12">
                                                    <div class="card">
                                                        <div class="card-header">
                                                            <h5>❌ Recently Breached Tickets</h5>
                                                        </div>
                                                        <div class="card-body table-border-style">
                                                            <div class="table-responsive">
                                                                <table class="table table-hover">
                                                                    <thead>
                                                                        <tr>
                                                                            <th>Ticket #</th>
                                                                            <th>Title</th>
                                                                            <th>Priority</th>
                                                                            <th>Breached At</th>
                                                                        </tr>
                                                                    </thead>
                                                                    <tbody>
                                                                        <c:if test="${empty breachedTickets}">
                                                                            <tr>
                                                                                <td colspan="4" class="text-center">No
                                                                                    breached tickets. Great job!</td>
                                                                            </tr>
                                                                        </c:if>
                                                                        <c:forEach items="${breachedTickets}" var="t">
                                                                            <tr>
<<<<<<< HEAD
                                                                                <td><a
                                                                                        href="tickets?action=view&id=${t['Id']}">${t['TicketNumber']}</a>
                                                                                </td>
=======
                                                                                <td>${t['TicketNumber']}</td>
>>>>>>> d2154b86978d31b564b8846d8826925bf10e211d
                                                                                <td>${t['Title']}</td>
                                                                                <td>${t['Priority']}</td>
                                                                                <td class="text-danger">
                                                                                    <fmt:formatDate
                                                                                        value="${t['ResolutionDeadline']}"
                                                                                        pattern="MM-dd HH:mm" />
                                                                                </td>
                                                                            </tr>
                                                                        </c:forEach>
                                                                    </tbody>
                                                                </table>
                                                            </div>
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