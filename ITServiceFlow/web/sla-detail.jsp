<%-- Document : sla-detail Created on : Feb 14, 2026 Author : DELL --%>
    <%@page contentType="text/html" pageEncoding="UTF-8" %>
        <%@ taglib uri="jakarta.tags.core" prefix="c" %>
            <%@ taglib uri="jakarta.tags.fmt" prefix="fmt" %>
                <!DOCTYPE html>
                <html lang="en">

                <head>
                    <title>IT Service Flow - SLA Detail</title>
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
                                                                <h5 class="m-b-10">SLA Rule Detail</h5>
                                                            </div>
                                                            <ul class="breadcrumb">
                                                                <li class="breadcrumb-item"><a
                                                                        href="AdminDashboard.jsp"><i
                                                                            class="feather icon-home"></i></a></li>
                                                                <li class="breadcrumb-item"><a href="SLAConfig">SLA
                                                                        Configuration</a>
                                                                </li>
                                                                <li class="breadcrumb-item"><a href="#!">SLA Detail</a>
                                                                </li>
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
                                                            <h5>Rule Information: ${rule.slaName}</h5>
                                                            <div class="card-header-right">
                                                                <span
                                                                    class="badge badge-${rule.status == 'Active' ? 'success' : 'secondary'}">
                                                                    ${rule.status}
                                                                </span>
                                                            </div>
                                                        </div>
                                                        <div class="card-body">
                                                            <div class="row">
                                                                <div class="col-md-6">
                                                                    <h6 class="text-muted">General Information</h6>
                                                                    <hr>
                                                                    <dl class="row">
                                                                        <dt class="col-sm-4">SLA Name</dt>
                                                                        <dd class="col-sm-8">${rule.slaName}</dd>

                                                                        <dt class="col-sm-4">Ticket Type</dt>
                                                                        <dd class="col-sm-8">${rule.ticketType}</dd>

                                                                        <dt class="col-sm-4">Priority</dt>
                                                                        <dd class="col-sm-8">${rule.priorityName}
                                                                            (Level)</dd>
                                                                    </dl>
                                                                </div>
                                                                <div class="col-md-6">
                                                                    <h6 class="text-muted">Time Thresholds</h6>
                                                                    <hr>
                                                                    <dl class="row">
                                                                        <dt class="col-sm-5">Response Time</dt>
                                                                        <dd class="col-sm-7">${rule.responseTime} Hours
                                                                        </dd>

                                                                        <dt class="col-sm-5">Resolution Time</dt>
                                                                        <dd class="col-sm-7">${rule.resolutionTime}
                                                                            Hours</dd>
                                                                    </dl>
                                                                </div>
                                                            </div>

                                                            <div class="row mt-4">
                                                                <div class="col-md-12">
                                                                    <h6 class="text-muted">Audit Information</h6>
                                                                    <hr>
                                                                    <dl class="row">
                                                                        <dt class="col-sm-2">Created By</dt>
                                                                        <dd class="col-sm-4">${rule.createdByName}</dd>

                                                                        <dt class="col-sm-2">Created At</dt>
                                                                        <dd class="col-sm-4">
                                                                            <fmt:formatDate value="${rule.createdAt}"
                                                                                pattern="yyyy-MM-dd HH:mm:ss" />
                                                                        </dd>

                                                                        <dt class="col-sm-2">Last Updated</dt>
                                                                        <dd class="col-sm-4">
                                                                            <fmt:formatDate value="${rule.updatedAt}"
                                                                                pattern="yyyy-MM-dd HH:mm:ss" />
                                                                        </dd>
                                                                    </dl>
                                                                </div>
                                                            </div>

                                                            <div class="row mt-4">
                                                                <div class="col-md-12 text-right">
                                                                    <a href="SLAConfig" class="btn btn-secondary">Back
                                                                        to List</a>

                                                                    <a href="SLAConfig?action=edit&id=${rule.id}"
                                                                        class="btn btn-info">
                                                                        <i class="feather icon-edit"></i> Edit Rule
                                                                    </a>

                                                                    <form action="SLAConfig" method="post"
                                                                        style="display:inline;"
                                                                        onsubmit="return confirm('Are you sure you want to change the status of this rule?');">
                                                                        <input type="hidden" name="action"
                                                                            value="toggleStatus">
                                                                        <input type="hidden" name="id"
                                                                            value="${rule.id}">
                                                                        <input type="hidden" name="currentStatus"
                                                                            value="${rule.status}">
                                                                        <c:if test="${rule.status == 'Active'}">
                                                                            <button type="submit"
                                                                                class="btn btn-warning">
                                                                                <i class="feather icon-slash"></i>
                                                                                Disable Rule
                                                                            </button>
                                                                        </c:if>
                                                                        <c:if test="${rule.status != 'Active'}">
                                                                            <button type="submit"
                                                                                class="btn btn-success">
                                                                                <i
                                                                                    class="feather icon-check-circle"></i>
                                                                                Enable Rule
                                                                            </button>
                                                                        </c:if>
                                                                    </form>

                                                                    <form action="SLAConfig" method="post"
                                                                        style="display:inline;"
                                                                        onsubmit="return confirm('Delete this SLA Rule? This action cannot be undone.');">
                                                                        <input type="hidden" name="action"
                                                                            value="delete">
                                                                        <input type="hidden" name="id"
                                                                            value="${rule.id}">
                                                                        <button type="submit" class="btn btn-danger">
                                                                            <i class="feather icon-trash-2"></i> Delete
                                                                            Rule
                                                                        </button>
                                                                    </form>
                                                                </div>
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