<%-- Document : agent-performance-report Created on : Feb 15, 2026 Author : DELL --%>
    <%@page contentType="text/html" pageEncoding="UTF-8" %>
        <%@ taglib uri="jakarta.tags.core" prefix="c" %>
            <%@ taglib uri="jakarta.tags.fmt" prefix="fmt" %>
                <!DOCTYPE html>
                <html lang="en">

                <head>
                    <title>IT Service Flow - Agent Performance Report</title>
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
                                                                <h5 class="m-b-10">Agent Performance Report</h5>
                                                            </div>
                                                            <ul class="breadcrumb">
                                                                <li class="breadcrumb-item"><a
                                                                        href="AdminDashboard.jsp"><i
                                                                            class="feather icon-home"></i></a></li>
                                                                <li class="breadcrumb-item"><a href="#!">Reports</a>
                                                                </li>
                                                                <li class="breadcrumb-item"><a href="#!">Agent
                                                                        Performance</a></li>
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
                                                            <form action="AgentPerformanceReport" method="get"
                                                                class="form-inline">
                                                                <div class="form-group mb-2">
                                                                    <label for="month" class="mr-2">Month:</label>
                                                                    <select class="form-control mr-3" name="month">
                                                                        <c:forEach begin="1" end="12" var="m">
                                                                            <option value="${m}" ${m==month ? 'selected'
                                                                                : '' }>${m}</option>
                                                                        </c:forEach>
                                                                    </select>
                                                                </div>
                                                                <div class="form-group mb-2">
                                                                    <label for="year" class="mr-2">Year:</label>
                                                                    <select class="form-control mr-3" name="year">
                                                                        <c:forEach begin="2023" end="2030" var="y">
                                                                            <option value="${y}" ${y==year ? 'selected'
                                                                                : '' }>${y}</option>
                                                                        </c:forEach>
                                                                    </select>
                                                                </div>
                                                                <button type="submit" class="btn btn-primary mb-2">View
                                                                    Report</button>
                                                            </form>
                                                        </div>
                                                    </div>
                                                </div>

                                                <!-- Chart -->
                                                <div class="col-md-12">
                                                    <div class="card">
                                                        <div class="card-header">
                                                            <h5>Top Agents by Resolution</h5>
                                                        </div>
                                                        <div class="card-body">
                                                            <div id="morris-bar-chart" style="height:300px"></div>
                                                        </div>
                                                    </div>
                                                </div>

                                                <!-- Table -->
                                                <div class="col-md-12">
                                                    <div class="card">
                                                        <div class="card-header">
                                                            <h5>Performance Metrics</h5>
                                                        </div>
                                                        <div class="card-body table-border-style">
                                                            <div class="table-responsive">
                                                                <table class="table table-hover">
                                                                    <thead>
                                                                        <tr>
                                                                            <th>Rank</th>
                                                                            <th>Agent Name</th>
                                                                            <th>Tickets Assigned</th>
                                                                            <th>Resolved</th>
                                                                            <th>Avg Time (h)</th>
                                                                            <th>SLA Breached</th>
                                                                            <th>SLA Compliance</th>
                                                                            <th>Action</th>
                                                                        </tr>
                                                                    </thead>
                                                                    <tbody>
                                                                        <c:forEach items="${agentStats}" var="agent"
                                                                            varStatus="loop">
                                                                            <tr>
                                                                                <td>${loop.index + 1}</td>
                                                                                <td>${agent.FullName}</td>
                                                                                <td>${agent.TotalAssigned}</td>
                                                                                <td>${agent.ResolvedCount}</td>
                                                                                <td>
                                                                                    <fmt:formatNumber
                                                                                        value="${agent.AvgResolutionTime}"
                                                                                        maxFractionDigits="1" />
                                                                                </td>
                                                                                <td
                                                                                    class="${agent.BreachedCount > 0 ? 'text-danger' : ''}">
                                                                                    ${agent.BreachedCount}</td>
                                                                                <td>
                                                                                    <div class="progress"
                                                                                        style="height: 20px;">
                                                                                        <div class="progress-bar ${agent.SLACompliance >= 90 ? 'bg-success' : (agent.SLACompliance >= 70 ? 'bg-warning' : 'bg-danger')}"
                                                                                            role="progressbar"
                                                                                            style="width: ${agent.SLACompliance}%;"
                                                                                            aria-valuenow="${agent.SLACompliance}"
                                                                                            aria-valuemin="0"
                                                                                            aria-valuemax="100">
                                                                                            ${agent.SLACompliance}%
                                                                                        </div>
                                                                                    </div>
                                                                                </td>
                                                                                <td>
                                                                                    <!-- Drill-down to SLABreachList filtered by Agent for now, or just Tickets list if available -->
                                                                                    <!-- Since generic ticket list isn't fully ready, SLABreachList is the closest 'Report' view -->
                                                                                    <a href="SLABreachList?agent=${agent.FullName}"
                                                                                        class="btn btn-icon btn-outline-primary"
                                                                                        title="View Tickets">
                                                                                        <i
                                                                                            class="feather icon-list"></i>
                                                                                    </a>
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

                    <!-- Morris Chart js -->
                    <script src="assets/plugins/chart-morris/js/raphael.min.js"></script>
                    <script src="assets/plugins/chart-morris/js/morris.min.js"></script>

                    <script>
                        $(document).ready(function () {
                            var chartData = [
                                <c:forEach items="${agentStats}" var="a" begin="0" end="4" varStatus="loop">
                                    {y: '${a.FullName}', a: ${a.ResolvedCount}, b: ${a.TotalAssigned} }${!loop.last ? ',' : ''}
                                </c:forEach>
                            ];

                            if (chartData.length > 0) {
                                Morris.Bar({
                                    element: 'morris-bar-chart',
                                    data: chartData,
                                    xkey: 'y',
                                    ykeys: ['a', 'b'],
                                    labels: ['Resolved', 'Assigned'],
                                    barColors: ['#1de9b6', '#04a9f5'],
                                    resize: true
                                });
                            } else {
                                $('#morris-bar-chart').html('<p class="text-center mt-5">No data available.</p>');
                            }
                        });
                    </script>
                </body>

                </html>