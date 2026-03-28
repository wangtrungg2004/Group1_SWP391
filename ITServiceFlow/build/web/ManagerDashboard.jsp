<%-- 
    Document   : ManagerDashboard
    Created on : Feb 9, 2026, 4:21:38 PM
    Author     : DELL
--%>
<%-- 
    Document   : AdminDashboard
    Created on : Jan 17, 2026, 12:58:54 AM
    Author     : DELL
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ page import="dao.NotificationDao" %>
<%@ page import="model.Notifications" %>
<%@ page import="java.util.List" %>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<%@ taglib uri="jakarta.tags.fmt" prefix="fmt" %>
<%
    if (session.getAttribute("user") == null) {
        response.sendRedirect("Login.jsp");
        return;
    }
    
    String role = (String) session.getAttribute("role");
    model.Users user = (model.Users) session.getAttribute("user");
%>
<!DOCTYPE html>
<html lang="en">

<head>

	<!--<title>Flash Able - Most Trusted Admin Template</title>-->
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
	<!--<link rel="icon" href="assets/images/favicon.ico" type="image/x-icon">-->
	<!-- fontawesome icon -->
	<link rel="stylesheet" href="assets/fonts/fontawesome/css/fontawesome-all.min.css">
	<!-- animation css -->
	<link rel="stylesheet" href="assets/plugins/animation/css/animate.min.css">
	
	<!-- Bootstrap CSS -->
	<link rel="stylesheet" href="assets/plugins/bootstrap/css/bootstrap.min.css">

	<!-- vendor css -->
	<link rel="stylesheet" href="assets/css/style.css">
	<!-- Manager Dashboard custom -->
	<style>
		.manager-dash .page-wrapper { background: #f4f5f7; padding-bottom: 2rem; }
		.metric-card { background: #fff; border-radius: 12px; box-shadow: 0 1px 3px rgba(0,0,0,.08); padding: 1.25rem; height: 100%; }
		.metric-card .icon-wrap { width: 48px; height: 48px; border-radius: 12px; display: flex; align-items: center; justify-content: center; font-size: 1.25rem; flex-shrink: 0; }
		.metric-card .icon-wrap.blue { background: #e3f2fd; color: #1976d2; }
		.metric-card .icon-wrap.yellow { background: #fff8e1; color: #f9a825; }
		.metric-card .icon-wrap.purple { background: #f3e5f5; color: #7b1fa2; }
		.metric-card .icon-wrap.green { background: #e8f5e9; color: #388e3c; }
		.metric-card .value { font-size: 1.75rem; font-weight: 700; color: #1a1a1a; }
		.metric-card .label { font-size: 0.875rem; color: #666; margin-bottom: 0.25rem; }
		.metric-card .trend { font-size: 0.8rem; }
		.metric-card .trend.up { color: #2e7d32; }
		.metric-card .trend.down { color: #c62828; }
		.metric-card .trend.same { color: #f9a825; }
		.chart-card { background: #fff; border-radius: 12px; box-shadow: 0 1px 3px rgba(0,0,0,.08); padding: 1.25rem; height: 100%; }
		.chart-card h6 { font-weight: 600; margin-bottom: 1rem; }
		.purple-hero-card { background: linear-gradient(135deg, #7b1fa2 0%, #512da8 100%); border-radius: 12px; padding: 1.5rem; color: #fff; margin-bottom: 1rem; }
		.purple-hero-card .big-num { font-size: 2rem; font-weight: 700; }
		.purple-hero-card .sub { font-size: 0.85rem; opacity: .9; }
		.top-list-card { background: #fff; border-radius: 12px; box-shadow: 0 1px 3px rgba(0,0,0,.08); padding: 1.25rem; }
		.top-list-card h6 { font-weight: 600; margin-bottom: 0.5rem; }
		.top-list-card .list-item { display: flex; justify-content: space-between; align-items: center; padding: 0.5rem 0; border-bottom: 1px solid #eee; font-size: 0.9rem; }
		.top-list-card .list-item:last-child { border-bottom: none; }
		.table-card-dash { background: #fff; border-radius: 12px; box-shadow: 0 1px 3px rgba(0,0,0,.08); overflow: hidden; }
		.table-card-dash .card-header { padding: 1rem 1.25rem; border-bottom: 1px solid #eee; font-weight: 600; }
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
	<!-- [ navigation menu ] end -->

	<!-- [ Header ] start -->

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
												<h5>Manager Dashboard</h5>
											</div>
											<ul class="breadcrumb">
												<li class="breadcrumb-item"><a href="ManagerDashboard.jsp"><i class="feather icon-home"></i></a></li>
												<li class="breadcrumb-item">Analytics Dashboard</li>
											</ul>
										</div>
									</div>
								</div>
							</div>
							<!-- [ breadcrumb ] end -->
							<!-- [ Main Content ] start -->
							<div class="row manager-dash">

								<!-- 4 metric cards -->
								<div class="col-xl-3 col-md-6 mb-3">
									<div class="card metric-card">
										<div class="card-body d-flex align-items-center">
											<div class="icon-wrap blue mr-3">
												<i class="feather icon-activity"></i>
											</div>
											<div class="flex-grow-1">
												<div class="value">${totalPendingProblem}</div>
												<div class="label" style="font-weight: bold;" >Pending Problem</div>
												<!--<div class="trend up"><i class="feather icon-trending-up"></i> 4.07% Tháng trước</div>-->
											</div>
										</div>
									</div>
								</div>
								<div class="col-xl-3 col-md-6 mb-3">
									<div class="card metric-card">
										<div class="card-body d-flex align-items-center">
											<div class="icon-wrap yellow mr-3">
												<i class="feather icon-file-text"></i>
											</div>
											<div class="flex-grow-1">
												<div class="value">${totalTicket}</div>
                                                                                                <div class="label" style="font-weight: bold;">Total Ticket</div>
												<!--<div class="trend up"><i class="feather icon-trending-up"></i> 0.24% Tháng trước</div>-->
											</div>
										</div>
									</div>
								</div>
								<div class="col-xl-3 col-md-6 mb-3">
									<div class="card metric-card">
										<div class="card-body d-flex align-items-center">
											<div class="icon-wrap purple mr-3">
												<i class="feather icon-check-circle"></i>
											</div>
											<div class="flex-grow-1">
												<div class="value">${totalProblem}</div>
												<div class="label" style="font-weight: bold;">Total Problem</div>
												<!--<div class="trend down"><i class="feather icon-trending-down"></i> 1.64% Tháng trước</div>-->
											</div>
										</div>
									</div>
								</div>
								<div class="col-xl-3 col-md-6 mb-3">
									<div class="card metric-card">
										<div class="card-body d-flex align-items-center">
											<div class="icon-wrap green mr-3">
												<i class="feather icon-smile"></i>
											</div>
											<div class="flex-grow-1">
												<div class="value">${totalUsers}</div>
												<div class="label" style="font-weight: bold;" >Total User</div>
												<!--<div class="trend same">0.00% Tháng trước</div>-->
											</div>
										</div>
									</div>
								</div>
								<!-- Chart + Right column -->
								<div class="col-lg-8 mb-3">
									<div class="card chart-card">
										<h6>Ticket statistics by month</h6>
										<div style="height: 280px;">
											<canvas id="managerTicketChart"></canvas>
										</div>
									</div>
								</div>
								<div class="col-lg-4 mb-3">
									<div class="purple-hero-card">
										<div class="d-flex justify-content-between align-items-start">
											<div>
												<div class="sub">Total Ticket This month</div>
												<div class="big-num">${totalTicketThisMonth}</div>
												<!--<small>Daily Avg.</small>-->
											</div>
											<!--<div class="big-num">+3</div>-->
										</div>
									</div>
									<div class="card top-list-card">
                                                                            <h6>Top agents</h6>
                                                                            <small class="text-muted">Based on tickets resolved this month</small>

                                                                            <c:forEach var="agent" items="${topAgents}">
                                                                                <div class="list-item">
                                                                                    <span>${agent.fullName}</span>
                                                                                    <strong>${agent.ticketCount}</strong>
                                                                                </div>
                                                                            </c:forEach>
                                                                        </div>
								</div>
								<!-- Table section start -->
								<div class="col-12">
									<div class="card table-card-dash">
                                                                            <div class="card-header">Unassigned Tickets (Top 10)</div>
                                                                            <div class="table-responsive">
                                                                              <table class="table table-hover m-b-0">
                                                                                <thead>
                                                                                  <tr>
                                                                                    <th>Ticket #</th>
                                                                                    <th>Title</th>
                                                                                    <th>Status</th>
                                                                                    <th>CreatedAt</th>
                                                                                    <th>Action</th>
                                                                                  </tr>
                                                                                </thead>
                                                                                <tbody>
                                                                                  <c:forEach var="t" items="${UnAssignedTicket}">
                                                                                    <tr>
                                                                                      <td>${t.ticketNumber}</td>
                                                                                      <td>${t.title}</td>
                                                                                      <td><span class="badge badge-light">${t.status}</span></td>
                                                                                      <td>${t.createdAt}</td>
                                                                                      <td><a class="btn btn-sm btn-outline-primary" href="${pageContext.request.contextPath}/TicketAgentDetail?id=${t.id}">View</a></td>
                                                                                    </tr>
                                                                                  </c:forEach>

                                                                                  <c:if test="${empty unAssignedTicket}">
                                                                                    <tr><td colspan="5" class="text-center text-muted">No unassigned tickets</td></tr>
                                                                                  </c:if>
                                                                                </tbody>
                                                                              </table>
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
                            <img src="assets/images/browser/chrome.png" alt="Chrome">
                            <div>Chrome</div>
                        </a>
                    </li>
                    <li>
                        <a href="https://www.mozilla.org/en-US/firefox/new/">
                            <img src="assets/images/browser/firefox.png" alt="Firefox">
                            <div>Firefox</div>
                        </a>
                    </li>
                    <li>
                        <a href="http://www.opera.com">
                            <img src="assets/images/browser/opera.png" alt="Opera">
                            <div>Opera</div>
                        </a>
                    </li>
                    <li>
                        <a href="https://www.apple.com/safari/">
                            <img src="assets/images/browser/safari.png" alt="Safari">
                            <div>Safari</div>
                        </a>
                    </li>
                    <li>
                        <a href="http://windows.microsoft.com/en-us/internet-explorer/download-ie">
                            <img src="assets/images/browser/ie.png" alt="">
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
	<script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
	<script src="https://cdn.jsdelivr.net/npm/chart.js"></script>

        <c:set var="lbs" value="${empty chartLabels ? [] : chartLabels}" />
        <c:set var="done" value="${empty chartDaXuLy ? [] : chartDaXuLy}" />
        <c:set var="open" value="${empty chartChuaXuLy ? [] : chartChuaXuLy}" />

        <script>
        var chartLabels = [
        <c:forEach var="lb" items="${lbs}" varStatus="st">'${lb}'<c:if test="${!st.last}">, </c:if></c:forEach>
        ];

        var chartDaXuLy = [
        <c:forEach var="n" items="${done}" varStatus="st">${n}<c:if test="${!st.last}">, </c:if></c:forEach>
        ];

        var chartChuaXuLy = [
        <c:forEach var="n" items="${open}" varStatus="st">${n}<c:if test="${!st.last}">, </c:if></c:forEach>
        ];
        </script>
        
        
        <script>

            (function() {
                var ctx = document.getElementById('managerTicketChart');
                if (!ctx) return;

                // Fallback nếu chưa có dữ liệu (vào thẳng JSP chưa qua servlet)
                if (typeof chartLabels === 'undefined' || chartLabels.length === 0) {
                    chartLabels = ['T1','T2','T3','T4','T5','T6'];
                    chartDaXuLy = [0,0,0,0,0,0];
                    chartChuaXuLy = [0,0,0,0,0,0];
                }

                new Chart(ctx.getContext('2d'), {
                    type: 'line',
                    data: {
                        labels: chartLabels,
                        datasets: [
                            { label: 'SOLVED',   data: chartDaXuLy,   borderColor: '#7b1fa2', fill: false, tension: 0.3 },
                            { label: 'UNSOLVED', data: chartChuaXuLy, borderColor: '#388e3c', fill: false, tension: 0.3 }
                        ]
                    },
                    options: {
                        responsive: true,
                        maintainAspectRatio: false,
                        plugins: { legend: { position: 'top' } },
                        scales: { y: { beginAtZero: true } }
                    }
                });
            })();
        </script>
</body>

</html>

<script>
    $(document).ready(function () {
        $('.fixed-button').remove();
    });
</script>


