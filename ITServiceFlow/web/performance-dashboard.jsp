<%-- Document : performance-dashboard Created on : Feb 15, 2026 Author : DELL --%>
    <%@page contentType="text/html" pageEncoding="UTF-8" %>
        <%@ taglib uri="jakarta.tags.core" prefix="c" %>
            <%@ taglib uri="jakarta.tags.fmt" prefix="fmt" %>
                <!DOCTYPE html>
                <html lang="en">

                <head>
                    <title>IT Service Flow - Performance Dashboard</title>
                    <meta charset="utf-8">
                    <meta name="viewport" content="width=device-width, initial-scale=1.0, user-scalable=0, minimal-ui">
                    <meta http-equiv="X-UA-Compatible" content="IE=edge" />

                    <!-- fontawesome icon -->
                    <link rel="stylesheet" href="assets/fonts/fontawesome/css/fontawesome-all.min.css">
                    <!-- animation css -->
                    <link rel="stylesheet" href="assets/plugins/animation/css/animate.min.css">
                    <!-- Bootstrap CSS -->
                    <link rel="stylesheet" href="assets/plugins/bootstrap/css/bootstrap.min.css">
                    <!-- morris css -->
                    <link rel="stylesheet" href="assets/plugins/chart-morris/css/morris.css">
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
                                                                <h5 class="m-b-10">Performance Dashboard</h5>
                                                            </div>
                                                            <ul class="breadcrumb">
                                                                <li class="breadcrumb-item"><a
                                                                        href="AdminDashboard.jsp"><i
                                                                            class="feather icon-home"></i></a></li>
                                                                <li class="breadcrumb-item"><a href="#!">Reporting</a>
                                                                </li>
                                                                <li class="breadcrumb-item"><a href="#!">Performance</a>
                                                                </li>
                                                            </ul>
                                                        </div>
                                                    </div>
                                                </div>
                                            </div>
                                            <!-- [ breadcrumb ] end -->

                                            <!-- [ Main Content ] start -->
                                            <div class="row">
                                                <!-- Filter -->
                                                <div class="col-sm-12">
                                                    <div class="card">
                                                        <div class="card-body">
                                                            <form action="PerformanceDashboard" method="get"
                                                                class="form-inline">
                                                                <div class="form-group mb-2">
                                                                    <label for="from" class="mr-2">From:</label>
                                                                    <input type="date" class="form-control mr-3"
                                                                        name="from" value="${fromDate}">
                                                                </div>
                                                                <div class="form-group mb-2">
                                                                    <label for="to" class="mr-2">To:</label>
                                                                    <input type="date" class="form-control mr-3"
                                                                        name="to" value="${toDate}">
                                                                </div>
                                                                <div class="form-group mb-2">
                                                                    <label for="categoryId" class="mr-2">Category:</label>
                                                                    <select name="categoryId" class="form-control mr-3">
                                                                        <option value="">All Categories</option>
                                                                        <c:forEach items="${categories}" var="cat">
                                                                            <option value="${cat.Id}" ${categoryId == cat.Id ? 'selected' : ''}>${cat.Name}</option>
                                                                        </c:forEach>
                                                                    </select>
                                                                </div>
                                                                <div class="form-group mb-2">
                                                                    <label for="locationId" class="mr-2">Location:</label>
                                                                    <select name="locationId" class="form-control mr-3">
                                                                        <option value="">All Locations</option>
                                                                        <c:forEach items="${locations}" var="loc">
                                                                            <option value="${loc.Id}" ${locationId == loc.Id ? 'selected' : ''}>${loc.Name}</option>
                                                                        </c:forEach>
                                                                    </select>
                                                                </div>
                                                                <button type="submit"
                                                                    class="btn btn-primary mb-2">Filter</button>
                                                            </form>
                                                        </div>
                                                    </div>
                                                </div>

                                                <!-- KPI Cards -->
                                                <div class="col-md-6 col-xl-3">
                                                    <div class="card bg-c-blue order-card">
                                                        <div class="card-body">
                                                            <h6 class="text-white">Total Tickets</h6>
                                                            <h2 class="text-right text-white"><i
                                                                    class="feather icon-shopping-cart float-left"></i><span>${performanceStats.Total}</span>
                                                            </h2>
                                                            <p class="m-b-0">Period Volume<span
                                                                    class="float-right"></span></p>
                                                        </div>
                                                    </div>
                                                </div>
                                                <div class="col-md-6 col-xl-3">
                                                    <div class="card bg-c-green order-card">
                                                        <div class="card-body">
                                                            <h6 class="text-white">Resolution Rate</h6>
                                                            <h2 class="text-right text-white"><i
                                                                    class="feather icon-check-circle float-left"></i><span>${performanceStats.ResolutionRate}%</span>
                                                            </h2>
                                                            <p class="m-b-0">Resolved:
                                                                ${performanceStats.ResolvedTickets}</p>
                                                        </div>
                                                    </div>
                                                </div>
                                                <div class="col-md-6 col-xl-3">
                                                    <div class="card bg-c-yellow order-card">
                                                        <div class="card-body">
                                                            <h6 class="text-white">SLA Compliance</h6>
                                                            <h2 class="text-right text-white"><i
                                                                    class="feather icon-award float-left"></i><span>${complianceStats.ComplianceRate}%</span>
                                                            </h2>
                                                            <p class="m-b-0">Breached: ${complianceStats.Breached}</p>
                                                        </div>
                                                    </div>
                                                </div>
                                                <div class="col-md-6 col-xl-3">
                                                    <div class="card bg-c-red order-card">
                                                        <div class="card-body">
                                                            <h6 class="text-white">Avg Resolution Time</h6>
                                                            <h2 class="text-right text-white"><i
                                                                    class="feather icon-clock float-left"></i><span>
                                                                    <fmt:formatNumber
                                                                        value="${performanceStats.AvgResolutionTime}"
                                                                        maxFractionDigits="1" /> h
                                                                </span></h2>
                                                            <p class="m-b-0">Hours per Ticket</p>
                                                        </div>
                                                    </div>
                                                </div>

                                                <!-- Charts -->
                                                <div class="col-xl-8 col-md-12">
                                                    <div class="card">
                                                        <div class="card-header">
                                                            <h5>Ticket Volume Trend (Created vs Resolved)</h5>
                                                        </div>
                                                        <div class="card-body">
                                                            <div id="morris-line-chart" style="height:300px"></div>
                                                        </div>
                                                    </div>
                                                </div>
                                                <div class="col-xl-4 col-md-12">
                                                    <div class="card">
                                                        <div class="card-header">
                                                            <h5>SLA Compliance Overview</h5>
                                                        </div>
                                                        <div class="card-body">
                                                            <div id="morris-donut-chart" style="height:300px"></div>
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

                    <!-- Morris Chart js -->
                    <script src="assets/plugins/chart-morris/js/raphael.min.js"></script>
                    <script src="assets/plugins/chart-morris/js/morris.min.js"></script>

                    <script>
                        $(document).ready(function () {
                            // Line Chart
                            var trendData = [
                                <c:forEach items="${trendData}" var="d" varStatus="loop">
                                    {
                                        y: '${d.Date}',
                                        a: ${d.Created != null ? d.Created : 0},
                                        b: ${d.Resolved != null ? d.Resolved : 0}
                                    }${!loop.last ? ',' : ''}
                                </c:forEach>
                            ];

                            if (trendData.length > 0) {
                                Morris.Line({
                                    element: 'morris-line-chart',
                                    data: trendData,
                                    xkey: 'y',
                                    ykeys: ['a', 'b'],
                                    labels: ['Created', 'Resolved'],
                                    lineColors: ['#04a9f5', '#1de9b6'],
                                    resize: true
                                });
                            } else {
                                $('#morris-line-chart').html('<p class="text-center mt-5">No data available for this period.</p>');
                            }

                            // Donut Chart
                            Morris.Donut({
                                element: 'morris-donut-chart',
                                data: [
                                    { label: "Met SLA", value: ${complianceStats.Met != null ? complianceStats.Met : 0} },
                                    { label: "Breached SLA", value: ${complianceStats.Breached != null ? complianceStats.Breached : 0} }
                                ],
                                colors: ['#1de9b6', '#f44236'],
                                resize: true,
                                formatter: function (x) { return x + " Tickets" }
                            });
        });
                    </script>

                </body>

                </html>