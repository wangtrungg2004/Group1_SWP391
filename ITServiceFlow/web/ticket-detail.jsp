<%-- Document : ticket-detail Created on : Feb 15, 2026 Author : DELL --%>
    <%@page contentType="text/html" pageEncoding="UTF-8" %>
        <%@ taglib uri="jakarta.tags.core" prefix="c" %>
            <%@ taglib uri="jakarta.tags.fmt" prefix="fmt" %>
                <!DOCTYPE html>
                <html lang="en">

                <head>
                    <title>IT Service Flow - Ticket Detail</title>
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
                                                                <h5 class="m-b-10">Ticket Detail</h5>
                                                            </div>
                                                            <ul class="breadcrumb">
                                                                <li class="breadcrumb-item"><a
                                                                        href="AdminDashboard.jsp"><i
                                                                            class="feather icon-home"></i></a></li>
                                                                <li class="breadcrumb-item"><a href="#!">Tickets</a>
                                                                </li>
                                                                <li class="breadcrumb-item"><a
                                                                        href="#!">${ticket.ticketNumber}</a></li>
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
                                                            <h5>${ticket.title}</h5>
                                                            <div class="card-header-right">
                                                                <span
                                                                    class="badge badge-${ticket.status == 'Resolved' || ticket.status == 'Closed' ? 'success' : (ticket.status == 'Open' ? 'primary' : 'warning')}">${ticket.status}</span>
                                                            </div>
                                                        </div>
                                                        <div class="card-body">
                                                            <div class="row">
                                                                <div class="col-md-6">
                                                                    <p><strong>Ticket Number:</strong>
                                                                        ${ticket.ticketNumber}</p>
                                                                    <p><strong>Type:</strong> ${ticket.ticketType}</p>
                                                                    <p><strong>Priority ID:</strong>
                                                                        ${ticket.priorityId}</p>
                                                                    <p><strong>Category ID:</strong>
                                                                        ${ticket.categoryId}</p>
                                                                </div>
                                                                <div class="col-md-6">
                                                                    <p><strong>Created At:</strong>
                                                                        <fmt:formatDate value="${ticket.createdAt}"
                                                                            pattern="yyyy-MM-dd HH:mm:ss" />
                                                                    </p>
                                                                    <p><strong>Assigned To ID:</strong>
                                                                        ${ticket.assignedTo != null ? ticket.assignedTo
                                                                        : 'Unassigned'}</p>
                                                                    <p><strong>Created By ID:</strong>
                                                                        ${ticket.createdBy}</p>
                                                                </div>
                                                            </div>
                                                            <hr>
                                                            <h5>Description</h5>
                                                            <p>${ticket.description}</p>

                                                            <div class="mt-4">
                                                                <a href="SLABreachList" class="btn btn-secondary">Back
                                                                    to Breach List</a>
                                                                <a href="AdminDashboard.jsp"
                                                                    class="btn btn-outline-secondary">Back to
                                                                    Dashboard</a>
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