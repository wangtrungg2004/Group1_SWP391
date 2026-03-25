<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ page import="java.util.List, java.util.Map" %>
<%@ page import="model.Users, model.Tickets, model.AuditLog, model.ChangeRequests" %>
<%@ taglib uri="jakarta.tags.core"   prefix="c" %>
<%@ taglib uri="jakarta.tags.fmt"    prefix="fmt" %>
<%@ taglib uri="jakarta.tags.functions" prefix="fn" %>
<%
    if (session.getAttribute("user") == null) {
        response.sendRedirect("Login.jsp");
        return;
    }
    String role = (String) session.getAttribute("role");
    if (!"Admin".equals(role)) {
        response.sendRedirect("Login.jsp");
        return;
    }
    model.Users currentUser = (model.Users) session.getAttribute("user");
%>
<!DOCTYPE html>
<html lang="en">
    <head>
        <meta charset="utf-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0, user-scalable=0, minimal-ui">
        <meta http-equiv="X-UA-Compatible" content="IE=edge"/>
        <title>Admin Dashboard — IT ServiceFlow</title>

        <link rel="stylesheet" href="assets/fonts/fontawesome/css/fontawesome-all.min.css">
        <link rel="stylesheet" href="assets/plugins/animation/css/animate.min.css">
        <link rel="stylesheet" href="assets/plugins/bootstrap/css/bootstrap.min.css">
        <link rel="stylesheet" href="assets/css/style.css">

        <style>
            /* Fallback: prevent stuck gray preloader overlay */
            .loader-bg { display: none !important; }
            /* ── Page background ───────────────────────────────────────── */
            .admin-dash .pcoded-content {
                background: #f4f5f7;
            }

            /* ── KPI cards ─────────────────────────────────────────────── */
            .kpi-card {
                background: #fff;
                border-radius: 12px;
                box-shadow: 0 1px 4px rgba(0,0,0,.07);
                padding: 1.1rem 1.25rem;
                display: flex;
                align-items: center;
                gap: 14px;
                height: 100%;
            }
            .kpi-icon {
                width: 46px;
                height: 46px;
                border-radius: 12px;
                display: flex;
                align-items: center;
                justify-content: center;
                font-size: 1.2rem;
                flex-shrink: 0;
            }
            .kpi-icon.blue   {
                background: #e3f2fd;
                color: #1565c0;
            }
            .kpi-icon.green  {
                background: #e8f5e9;
                color: #2e7d32;
            }
            .kpi-icon.purple {
                background: #f3e5f5;
                color: #6a1b9a;
            }
            .kpi-icon.yellow {
                background: #fff8e1;
                color: #f57f17;
            }
            .kpi-icon.red    {
                background: #fce4ec;
                color: #b71c1c;
            }
            .kpi-icon.orange {
                background: #fff3e0;
                color: #e65100;
            }
            .kpi-icon.teal   {
                background: #e0f2f1;
                color: #00695c;
            }
            .kpi-icon.indigo {
                background: #e8eaf6;
                color: #283593;
            }
            .kpi-val {
                font-size: 1.7rem;
                font-weight: 700;
                color: #1a1a1a;
                line-height: 1.1;
            }
            .kpi-val.danger  {
                color: #c62828;
            }
            .kpi-val.warning {
                color: #e65100;
            }
            .kpi-val.success {
                color: #2e7d32;
            }
            .kpi-lbl {
                font-size: .8rem;
                color: #555;
                margin-bottom: 2px;
            }
            .kpi-sub {
                font-size: .75rem;
                color: #888;
                margin-top: 3px;
            }

            /* ── Section headers ───────────────────────────────────────── */
            .dash-section {
                border-left: 4px solid #5e35b1;
                padding-left: .75rem;
                margin-bottom: 1rem;
                margin-top: 1.75rem;
            }
            .dash-section h6 {
                font-weight: 700;
                color: #1a1a1a;
                margin: 0;
                font-size: .95rem;
                letter-spacing: .01em;
            }
            .dash-section small {
                color: #888;
                font-size: .8rem;
            }

            /* ── Content cards ─────────────────────────────────────────── */
            .panel {
                background: #fff;
                border-radius: 12px;
                box-shadow: 0 1px 4px rgba(0,0,0,.07);
                padding: 1.15rem 1.25rem;
                height: 100%;
            }
            .panel-title {
                font-size: .88rem;
                font-weight: 600;
                color: #1a1a1a;
                margin-bottom: .9rem;
                display: flex;
                align-items: center;
                justify-content: space-between;
            }
            .panel-title a {
                font-size: .75rem;
                font-weight: 400;
                color: #5e35b1;
            }

            /* ── Status badges ─────────────────────────────────────────── */
            .sbadge {
                display: inline-block;
                font-size: .7rem;
                font-weight: 600;
                padding: 2px 8px;
                border-radius: 20px;
            }
            .sbadge-new       {
                background: #e3f2fd;
                color: #1565c0;
            }
            .sbadge-open      {
                background: #e8f5e9;
                color: #2e7d32;
            }
            .sbadge-pending   {
                background: #fff8e1;
                color: #f57f17;
            }
            .sbadge-progress  {
                background: #f3e5f5;
                color: #6a1b9a;
            }
            .sbadge-resolved  {
                background: #e8f5e9;
                color: #2e7d32;
            }
            .sbadge-closed    {
                background: #f5f5f5;
                color: #555;
            }
            .sbadge-danger    {
                background: #fce4ec;
                color: #b71c1c;
            }
            .sbadge-warning   {
                background: #fff3e0;
                color: #e65100;
            }
            .sbadge-success   {
                background: #e8f5e9;
                color: #2e7d32;
            }

            /* ── List rows ─────────────────────────────────────────────── */
            .list-row {
                display: flex;
                justify-content: space-between;
                align-items: center;
                padding: .5rem 0;
                border-bottom: 1px solid #f0f0f0;
                font-size: .85rem;
            }
            .list-row:last-child {
                border-bottom: none;
            }
            .list-row .r-label {
                color: #1a1a1a;
            }
            .list-row .r-val   {
                color: #555;
                font-size: .8rem;
            }

            /* ── Progress bars ─────────────────────────────────────────── */
            .prow {
                display: flex;
                align-items: center;
                gap: 8px;
                font-size: .82rem;
                margin-bottom: 6px;
            }
            .prow .plabel {
                width: 110px;
                flex-shrink: 0;
                color: #444;
            }
            .prow .pbar   {
                flex: 1;
                height: 7px;
                background: #eee;
                border-radius: 4px;
                overflow: hidden;
            }
            .prow .pfill  {
                height: 100%;
                border-radius: 4px;
            }
            .prow .pnum   {
                width: 36px;
                text-align: right;
                color: #666;
            }

            /* ── SLA compliance ring ───────────────────────────────────── */
            .sla-ring-wrap {
                display: flex;
                align-items: center;
                gap: 1.5rem;
                padding: .5rem 0 .75rem;
            }
            .sla-ring {
                position: relative;
                width: 80px;
                height: 80px;
                flex-shrink: 0;
            }
            .sla-ring svg {
                width: 80px;
                height: 80px;
            }
            .sla-ring .ring-pct {
                position: absolute;
                top: 50%;
                left: 50%;
                transform: translate(-50%,-50%);
                font-size: .95rem;
                font-weight: 700;
                color: #1a1a1a;
            }
            .sla-legend-item {
                display: flex;
                align-items: center;
                gap: 6px;
                font-size: .82rem;
                color: #555;
            }
            .sla-dot {
                width: 10px;
                height: 10px;
                border-radius: 50%;
                flex-shrink: 0;
            }

            /* ── Agent avatar ──────────────────────────────────────────── */
            .agent-avatar {
                width: 28px;
                height: 28px;
                border-radius: 50%;
                display: inline-flex;
                align-items: center;
                justify-content: center;
                font-size: .7rem;
                font-weight: 600;
                background: #e8eaf6;
                color: #283593;
                flex-shrink: 0;
            }

            /* ── CSAT stars ────────────────────────────────────────────── */
            .star-filled {
                color: #f9a825;
            }
            .star-empty  {
                color: #ccc;
            }

            /* ── Audit log ─────────────────────────────────────────────── */
            .audit-row {
                display: flex;
                gap: 10px;
                padding: .5rem 0;
                border-bottom: 1px solid #f0f0f0;
                font-size: .82rem;
            }
            .audit-row:last-child {
                border-bottom: none;
            }
            .audit-action {
                font-weight: 600;
                color: #5e35b1;
            }
            .audit-entity {
                color: #1565c0;
            }
            .audit-time   {
                color: #aaa;
                font-size: .75rem;
                white-space: nowrap;
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
	<!-- [ navigation menu ] start -->
	<nav class="pcoded-navbar menupos-fixed menu-light brand-blue ">
		<div class="navbar-wrapper ">
			<div class="navbar-brand header-logo">
				<a href="${pageContext.request.contextPath}/AdminDashboard" class="b-brand">
<!--					<img src="assets/images/logo.svg" alt="" class="logo images">
					<img src="assets/images/logo-icon.svg" alt="" class="logo-thumb images">-->
				</a>
				<a class="mobile-menu" id="mobile-collapse" href="#!"><span></span></a>
			</div>
			<div class="navbar-content scroll-div">
				<ul class="nav pcoded-inner-navbar">
					<li class="nav-item pcoded-menu-caption">
						<label>Navigation</label>
					</li>
					<li class="nav-item">
						<a href="${pageContext.request.contextPath}/AdminDashboard" class="nav-link"><span class="pcoded-micon"><i class="feather icon-home"></i></span><span class="pcoded-mtext">Dashboard</span></a>
					</li>
					<li class="nav-item pcoded-menu-caption">
						<label>UI Element</label>
					</li>
					<li class="nav-item pcoded-hasmenu">
						<a href="#!" class="nav-link"><span class="pcoded-micon"><i class="feather icon-box"></i></span><span class="pcoded-mtext">Componant</span></a>
						<ul class="pcoded-submenu">
							<li class=""><a href="bc_button.html" class="">Button</a></li>
							<li class=""><a href="bc_badges.html" class="">Badges</a></li>
							<li class=""><a href="bc_breadcrumb-pagination.html" class="">Breadcrumb & paggination</a></li>
							<li class=""><a href="bc_collapse.html" class="">Collapse</a></li>
							<li class=""><a href="bc_progress.html" class="">Progress</a></li>
							<li class=""><a href="bc_tabs.html" class="">Tabs & pills</a></li>
							<li class=""><a href="bc_typography.html" class="">Typography</a></li>
						</ul>
					</li>
					<li class="nav-item pcoded-menu-caption">
						<label>Forms &amp; table</label>
					</li>
					<li class="nav-item">
						<a href="ProblemList" class="nav-link"><span class="pcoded-micon"><i class="feather icon-file-text"></i></span><span class="pcoded-mtext">Problem List</span></a>
					</li>
					<li class="nav-item">
						<a href="tbl_bootstrap.html" class="nav-link"><span class="pcoded-micon"><i class="feather icon-align-justify"></i></span><span class="pcoded-mtext">Bootstrap table</span></a>
					</li>
					<li class="nav-item pcoded-menu-caption">
						<label>Chart & Maps</label>
					</li>
					<li class="nav-item">
						<a href="chart-morris.html" class="nav-link"><span class="pcoded-micon"><i class="feather icon-pie-chart"></i></span><span class="pcoded-mtext">Chart</span></a>
					</li>
					<li class="nav-item">
						<a href="map-google.html" class="nav-link"><span class="pcoded-micon"><i class="feather icon-map"></i></span><span class="pcoded-mtext">Maps</span></a>
					</li>
					<c:if test="${role == 'Admin'}">
						<li class="nav-item pcoded-menu-caption">
							<label>Quan tri he thong</label>
						</li>
						<li class="nav-item">
							<a href="UserManagement" class="nav-link"><span class="pcoded-micon"><i class="feather icon-users"></i></span><span class="pcoded-mtext">User Management</span></a>
						</li>
                                            <li class="nav-item">
                                                    <a href="CIListServlet" class="nav-link"><span class="pcoded-micon"><i class="feather icon-server"></i></span><span class="pcoded-mtext">List Configuration Items</span></a>
                                            </li>
                                            <li class="nav-item">
                                                    <a href="Long_TicketListServlet" class="nav-link"><span class="pcoded-micon"><i class="feather icon-server"></i></span><span class="pcoded-mtext">List Tickets</span></a>
                                            </li>
					</c:if>
					<c:if test="${role == 'Admin' || role == 'Manager'}">
						<li class="nav-item pcoded-menu-caption">
							<label>Bao cao</label>
						</li>
						<li class="nav-item">
							<a href="Reports" class="nav-link"><span class="pcoded-micon"><i class="feather icon-file-text"></i></span><span class="pcoded-mtext">Xem bao cao</span></a>
						</li>
					</c:if>
					<c:if test="${role == 'IT Support' || role == 'Admin'}">
						<li class="nav-item pcoded-menu-caption">
							<label>Ho tro</label>
						</li>
						<li class="nav-item">
							<a href="Tickets" class="nav-link"><span class="pcoded-micon"><i class="feather icon-help-circle"></i></span><span class="pcoded-mtext">Quan ly Ticket</span></a>
						</li>
					</c:if>
					<li class="nav-item pcoded-menu-caption">
						<label>Pages</label>
					</li>
					<li class="nav-item pcoded-hasmenu">
						<a href="#!" class="nav-link"><span class="pcoded-micon"><i class="feather icon-lock"></i></span><span class="pcoded-mtext">Authentication</span></a>
						<ul class="pcoded-submenu">
							<li class=""><a href="auth-signup.html" class="" target="_blank">Sign up</a></li>
							<li class=""><a href="auth-signin.html" class="" target="_blank">Sign in</a></li>
						</ul>
					</li>
					<li class="nav-item"><a href="sample-page.html" class="nav-link"><span class="pcoded-micon"><i class="feather icon-sidebar"></i></span><span class="pcoded-mtext">Sample page</span></a></li>
					<li class="nav-item disabled"><a href="#!" class="nav-link"><span class="pcoded-micon"><i class="feather icon-power"></i></span><span class="pcoded-mtext">Disabled menu</span></a></li>
				</ul>
			</div>
		</div>
	</nav>
	<!-- [ navigation menu ] end -->

        <!-- [ navigation menu ] start -->
        <nav class="pcoded-navbar menupos-fixed menu-light brand-blue ">
            <div class="navbar-wrapper ">
                <div class="navbar-brand header-logo">
                    <a href="${pageContext.request.contextPath}/AdminDashboard" class="b-brand">
                        <!--					<img src="assets/images/logo.svg" alt="" class="logo images">
                                                                <img src="assets/images/logo-icon.svg" alt="" class="logo-thumb images">-->
                    </a>
                    <a class="mobile-menu" id="mobile-collapse" href="#!"><span></span></a>
                </div>
                <div class="navbar-content scroll-div">
                    <ul class="nav pcoded-inner-navbar">
                        <li class="nav-item pcoded-menu-caption">
                            <label>Navigation</label>
                        </li>
                        <li class="nav-item">
                            <a href="${pageContext.request.contextPath}/AdminDashboard" class="nav-link"><span class="pcoded-micon"><i class="feather icon-home"></i></span><span class="pcoded-mtext">Dashboard</span></a>
                        </li>
                        <li class="nav-item pcoded-menu-caption">
                            <label>UI Element</label>
                        </li>
                        <li class="nav-item pcoded-hasmenu">
                            <a href="#!" class="nav-link"><span class="pcoded-micon"><i class="feather icon-box"></i></span><span class="pcoded-mtext">Componant</span></a>
                            <ul class="pcoded-submenu">
                                <li class=""><a href="bc_button.html" class="">Button</a></li>
                                <li class=""><a href="bc_badges.html" class="">Badges</a></li>
                                <li class=""><a href="bc_breadcrumb-pagination.html" class="">Breadcrumb & paggination</a></li>
                                <li class=""><a href="bc_collapse.html" class="">Collapse</a></li>
                                <li class=""><a href="bc_progress.html" class="">Progress</a></li>
                                <li class=""><a href="bc_tabs.html" class="">Tabs & pills</a></li>
                                <li class=""><a href="bc_typography.html" class="">Typography</a></li>
                            </ul>
                        </li>
                        <li class="nav-item pcoded-menu-caption">
                            <label>Forms &amp; table</label>
                        </li>
                        <li class="nav-item">
                            <a href="ProblemList" class="nav-link"><span class="pcoded-micon"><i class="feather icon-file-text"></i></span><span class="pcoded-mtext">Problem List</span></a>
                        </li>
                        <c:if test="${role eq 'Manager'}">
                            <li class="nav-item">
                                <a class="nav-link" href="ManagerChangeApprovals">
                                    <span class="pcoded-micon"><i class="feather icon-check-square"></i></span>
                                    <span class="pcoded-mtext">Approve Change Request</span>
                                </a>
                            </li>
                        </c:if>
                        <li class="nav-item">
                            <a href="tbl_bootstrap.html" class="nav-link"><span class="pcoded-micon"><i class="feather icon-align-justify"></i></span><span class="pcoded-mtext">Bootstrap table</span></a>
                        </li>
                        <li class="nav-item pcoded-menu-caption">
                            <label>Chart & Maps</label>
                        </li>
                        <li class="nav-item">
                            <a href="chart-morris.html" class="nav-link"><span class="pcoded-micon"><i class="feather icon-pie-chart"></i></span><span class="pcoded-mtext">Chart</span></a>
                        </li>
                        <li class="nav-item">
                            <a href="map-google.html" class="nav-link"><span class="pcoded-micon"><i class="feather icon-map"></i></span><span class="pcoded-mtext">Maps</span></a>
                        </li>
                        <c:if test="${role == 'Admin'}">
                            <li class="nav-item pcoded-menu-caption">
                                <label>Quan tri he thong</label>
                            </li>
                            <li class="nav-item">
                                <a href="UserManagement" class="nav-link"><span class="pcoded-micon"><i class="feather icon-users"></i></span><span class="pcoded-mtext">User Management</span></a>
                            </li>
                        </c:if>
                        <c:if test="${role == 'Admin' || role == 'Manager'}">
                            <li class="nav-item pcoded-menu-caption">
                                <label>Bao cao</label>
                            </li>
                            <li class="nav-item">
                                <a href="Reports" class="nav-link"><span class="pcoded-micon"><i class="feather icon-file-text"></i></span><span class="pcoded-mtext">Xem bao cao</span></a>
                            </li>
                        </c:if>
                        <c:if test="${role == 'IT Support' || role == 'Admin'}">
                            <li class="nav-item pcoded-menu-caption">
                                <label>Ho tro</label>
                            </li>
                            <li class="nav-item">
                                <a href="Tickets" class="nav-link"><span class="pcoded-micon"><i class="feather icon-help-circle"></i></span><span class="pcoded-mtext">Quan ly Ticket</span></a>
                            </li>
                        </c:if>
                        <li class="nav-item pcoded-menu-caption">
                            <label>Pages</label>
                        </li>
                        <li class="nav-item pcoded-hasmenu">
                            <a href="#!" class="nav-link"><span class="pcoded-micon"><i class="feather icon-lock"></i></span><span class="pcoded-mtext">Authentication</span></a>
                            <ul class="pcoded-submenu">
                                <li class=""><a href="auth-signup.html" class="" target="_blank">Sign up</a></li>
                                <li class=""><a href="auth-signin.html" class="" target="_blank">Sign in</a></li>
                            </ul>
                        </li>
                        <li class="nav-item"><a href="sample-page.html" class="nav-link"><span class="pcoded-micon"><i class="feather icon-sidebar"></i></span><span class="pcoded-mtext">Sample page</span></a></li>
                        <li class="nav-item disabled"><a href="#!" class="nav-link"><span class="pcoded-micon"><i class="feather icon-power"></i></span><span class="pcoded-mtext">Disabled menu</span></a></li>
                    </ul>
                </div>
            </div>
        </nav>
        <!-- [ navigation menu ] end -->

        <!-- ════════════════════════════════════════════════════════════════════
             MAIN CONTENT
        ════════════════════════════════════════════════════════════════════ -->
        <div class="pcoded-main-container">
            <div class="pcoded-wrapper">
                <div class="pcoded-content">
                    <div class="pcoded-inner-content">
                        <div class="main-body">
                            <div class="page-wrapper">

                                <!-- breadcrumb -->
                                <div class="page-header">
                                    <div class="page-block">
                                        <div class="row align-items-center">
                                            <div class="col-md-12">
                                                <div class="page-header-title">
                                                    <h5 class="m-b-10">Admin Dashboard</h5>
                                                </div>
                                                <ul class="breadcrumb">
                                                    <li class="breadcrumb-item"><a href="AdminDashboard"><i class="feather icon-home"></i></a></li>
                                                    <li class="breadcrumb-item">System Overview</li>
                                                </ul>
                                            </div>
                                        </div>
                                    </div>
                                </div>

                                <!-- ════════════════════════════════════════
                                     ZONE 1 — SYSTEM HEALTH KPIs
                                ════════════════════════════════════════ -->
                                <div class="dash-section">
                                    <h6><i class="feather icon-activity mr-1"></i> System Health</h6>
                                    <small>Real-time overview of all ITSM processes</small>
                                </div>
                                <div class="row mb-0">
                                    <!-- Total Tickets -->
                                    <div class="col-xl-3 col-md-6 mb-3">
                                        <div class="kpi-card">
                                            <div class="kpi-icon blue"><i class="feather icon-file-text"></i></div>
                                            <div>
                                                <div class="kpi-lbl">Total Tickets</div>
                                                <div class="kpi-val">${totalTickets}</div>
                                                <div class="kpi-sub">This month: <strong>${ticketsThisMonth}</strong></div>
                                            </div>
                                        </div>
                                    </div>
                                    <!-- Active Users -->
                                    <div class="col-xl-3 col-md-6 mb-3">
                                        <div class="kpi-card">
                                            <div class="kpi-icon green"><i class="feather icon-users"></i></div>
                                            <div>
                                                <div class="kpi-lbl">Active Users</div>
                                                <div class="kpi-val">${totalActiveUsers}</div>
                                                <div class="kpi-sub">IsActive = true</div>
                                            </div>
                                        </div>
                                    </div>
                                    <!-- Total Problems -->
                                    <div class="col-xl-3 col-md-6 mb-3">
                                        <div class="kpi-card">
                                            <div class="kpi-icon purple"><i class="feather icon-alert-circle"></i></div>
                                            <div>
                                                <div class="kpi-lbl">Total Problems</div>
                                                <div class="kpi-val">${totalProblems}</div>
                                                <div class="kpi-sub">All statuses</div>
                                            </div>
                                        </div>
                                    </div>
                                    <!-- RFC Pending -->
                                    <div class="col-xl-3 col-md-6 mb-3">
                                        <div class="kpi-card">
                                            <div class="kpi-icon yellow"><i class="feather icon-git-pull-request"></i></div>
                                            <div>
                                                <div class="kpi-lbl">RFC Pending Approval</div>
                                                <div class="kpi-val <c:if test="${rfcPendingCount > 0}">warning</c:if>">${rfcPendingCount}</div>
                                                    <div class="kpi-sub">Awaiting Manager</div>
                                                </div>
                                            </div>
                                        </div>
                                        <!-- SLA Breached -->
                                        <div class="col-xl-3 col-md-6 mb-3">
                                            <div class="kpi-card">
                                                <div class="kpi-icon red"><i class="feather icon-alert-triangle"></i></div>
                                                <div>
                                                    <div class="kpi-lbl">SLA Breached</div>
                                                    <div class="kpi-val <c:if test="${slaBreached > 0}">danger</c:if>">${slaBreached}</div>
                                                <div class="kpi-sub">Near breach: ${slaNearBreach}</div>
                                            </div>
                                        </div>
                                    </div>
                                    <!-- Unassigned -->
                                    <div class="col-xl-3 col-md-6 mb-3">
                                        <div class="kpi-card">
                                            <div class="kpi-icon orange"><i class="feather icon-user-x"></i></div>
                                            <div>
                                                <div class="kpi-lbl">Unassigned Tickets</div>
                                                <div class="kpi-val <c:if test="${unassignedCount > 0}">warning</c:if>">${unassignedCount}</div>
                                                    <div class="kpi-sub">Needs assignment</div>
                                                </div>
                                            </div>
                                        </div>
                                        <!-- Avg CSAT -->
                                        <div class="col-xl-3 col-md-6 mb-3">
                                            <div class="kpi-card">
                                                <div class="kpi-icon teal"><i class="feather icon-star"></i></div>
                                                <div>
                                                    <div class="kpi-lbl">Avg CSAT Rating</div>
                                                    <div class="kpi-val success">${csatAvg}</div>
                                                <div class="kpi-sub">Out of 5.0</div>
                                            </div>
                                        </div>
                                    </div>
                                    <!-- Total Surveys -->
                                    <div class="col-xl-3 col-md-6 mb-3">
                                        <div class="kpi-card">
                                            <div class="kpi-icon indigo"><i class="feather icon-message-square"></i></div>
                                            <div>
                                                <div class="kpi-lbl">CSAT Surveys</div>
                                                <div class="kpi-val">${csatTotal}</div>
                                                <div class="kpi-sub">Response rate: ${csatResponseRate}%</div>
                                            </div>
                                        </div>
                                    </div>
                                </div>

                                <!-- ════════════════════════════════════════
                                     ZONE 2 — TICKET MANAGEMENT
                                ════════════════════════════════════════ -->
                                <div class="dash-section mt-4">
                                    <h6><i class="feather icon-layers mr-1"></i> Ticket Management</h6>
                                </div>
                                <div class="row">
                                    <!-- Volume chart -->
                                    <div class="col-lg-7 mb-3">
                                        <div class="panel">
                                            <div class="panel-title">
                                                Ticket volume — last 6 months
                                                <a href="Long_TicketListServlet">View all</a>
                                            </div>
                                            <div style="height:230px">
                                                <canvas id="ticketVolumeChart"></canvas>
                                            </div>
                                        </div>
                                    </div>
                                    <!-- Status breakdown -->
                                    <div class="col-lg-5 mb-3">
                                        <div class="panel">
                                            <div class="panel-title">Status breakdown</div>
                                            <c:forEach var="entry" items="${ticketsByStatus}">
                                                <c:if test="${entry.value > 0}">
                                                    <div class="prow">
                                                        <span class="plabel">${entry.key}</span>
                                                        <div class="pbar">
                                                            <div class="pfill"
                                                                 style="width:${entry.value * 100 / (totalTickets > 0 ? totalTickets : 1)}%;
                                                                 background:
                                                                 <c:choose>
                                                                     <c:when test="${entry.key == 'New'}">           #1976d2</c:when>
                                                                     <c:when test="${entry.key == 'Open'}">          #388e3c</c:when>
                                                                     <c:when test="${entry.key == 'In Progress'}">   #7b1fa2</c:when>
                                                                     <c:when test="${entry.key == 'Pending'}">       #f57f17</c:when>
                                                                     <c:when test="${entry.key == 'Resolved'}">      #0097a7</c:when>
                                                                     <c:otherwise>                                  #9e9e9e</c:otherwise>
                                                                 </c:choose>">
                                                            </div>
                                                        </div>
                                                        <span class="pnum">${entry.value}</span>
                                                    </div>
                                                </c:if>
                                            </c:forEach>
                                        </div>
                                    </div>
                                    <!-- Type breakdown -->
                                    <div class="col-lg-5 mb-3">
                                        <div class="panel">
                                            <div class="panel-title">Type distribution</div>
                                            <c:set var="typeTotal" value="${totalTickets > 0 ? totalTickets : 1}" />
                                            <c:forEach var="entry" items="${ticketsByType}">
                                                <div class="prow">
                                                    <span class="plabel">${entry.key}</span>
                                                    <div class="pbar">
                                                        <div class="pfill"
                                                             style="width:${entry.value * 100 / typeTotal}%;
                                                             background:#5e35b1">
                                                        </div>
                                                    </div>
                                                    <span class="pnum">${entry.value}</span>
                                                </div>
                                            </c:forEach>
                                        </div>
                                    </div>
                                    <!-- Unassigned queue -->
                                    <div class="col-lg-7 mb-3">
                                        <div class="panel">
                                            <div class="panel-title">
                                                <span><i class="feather icon-alert-circle mr-1 text-danger"></i> Unassigned tickets</span>
                                                <a href="Long_TicketListServlet">Assign all</a>
                                            </div>
                                            <c:choose>
                                                <c:when test="${empty unassignedTickets}">
                                                    <p class="text-muted" style="font-size:.85rem">No unassigned tickets. Great!</p>
                                                </c:when>
                                                <c:otherwise>
                                                    <c:forEach var="t" items="${unassignedTickets}">
                                                        <div class="list-row">
                                                            <div class="r-label">
                                                                <span class="font-weight-600">${t.ticketNumber}</span>
                                                                <span class="text-muted ml-2" style="font-size:.8rem">${t.title}</span>
                                                            </div>
                                                            <div class="r-val">
                                                                <span class="sbadge
                                                                      <c:choose>
                                                                          <c:when test="${t.status == 'New'}">sbadge-new</c:when>
                                                                          <c:when test="${t.status == 'Open'}">sbadge-open</c:when>
                                                                          <c:otherwise>sbadge-pending</c:otherwise>
                                                                      </c:choose>">${t.status}</span>
                                                                &nbsp;
                                                                <fmt:formatDate value="${t.createdAt}" pattern="dd/MM/yyyy"/>
                                                            </div>
                                                        </div>
                                                    </c:forEach>
                                                </c:otherwise>
                                            </c:choose>
                                        </div>
                                    </div>
                                </div>

                                <!-- ════════════════════════════════════════
                                     ZONE 3 — SLA COMPLIANCE
                                ════════════════════════════════════════ -->
                                <div class="dash-section">
                                    <h6><i class="feather icon-clock mr-1"></i> SLA Compliance</h6>
                                </div>
                                <div class="row">
                                    <!-- Overall compliance ring -->
                                    <div class="col-lg-4 mb-3">
                                        <div class="panel">
                                            <div class="panel-title">Overall compliance</div>
                                            <div class="sla-ring-wrap">
                                                <div class="sla-ring">
                                                    <%-- SVG donut ring: circumference = 2π×28 ≈ 176 --%>
                                                    <svg viewBox="0 0 80 80">
                                                    <circle cx="40" cy="40" r="28" fill="none" stroke="#eee" stroke-width="10"/>
                                                    <circle cx="40" cy="40" r="28" fill="none"
                                                            stroke="#2e7d32" stroke-width="10"
                                                            stroke-dasharray="${slaCompliancePct * 1.76} 176"
                                                            stroke-dashoffset="44"
                                                            stroke-linecap="round"
                                                            transform="rotate(-90 40 40)"/>
                                                    </svg>
                                                    <div class="ring-pct">${slaCompliancePct}%</div>
                                                </div>
                                                <div>
                                                    <div class="sla-legend-item mb-2">
                                                        <div class="sla-dot" style="background:#2e7d32"></div>
                                                        Within SLA: <strong>${slaWithin}</strong>
                                                    </div>
                                                    <div class="sla-legend-item mb-2">
                                                        <div class="sla-dot" style="background:#c62828"></div>
                                                        Breached: <strong class="text-danger">${slaBreached}</strong>
                                                    </div>
                                                    <div class="sla-legend-item">
                                                        <div class="sla-dot" style="background:#e65100"></div>
                                                        Near breach: <strong class="text-warning">${slaNearBreach}</strong>
                                                    </div>
                                                </div>
                                            </div>
                                        </div>
                                    </div>
                                    <!-- Compliance by priority -->
                                    <div class="col-lg-4 mb-3">
                                        <div class="panel">
                                            <div class="panel-title">Compliance by priority</div>
                                            <c:forEach var="prio" items="${fn:split('P1,P2,P3,P4', ',')}">
                                                <c:set var="pctKey"  value="${prio}_pct" />
                                                <c:set var="totKey"  value="${prio}_total" />
                                                <c:set var="pct"     value="${slaByPriority[pctKey]}" />
                                                <c:set var="tot"     value="${slaByPriority[totKey]}" />
                                                <c:if test="${tot != null && tot > 0}">
                                                    <div class="prow">
                                                        <span class="plabel">${prio}</span>
                                                        <div class="pbar">
                                                            <div class="pfill"
                                                                 style="width:${pct}%;
                                                                 background:
                                                                 <c:choose>
                                                                     <c:when test="${pct >= 90}">#2e7d32</c:when>
                                                                     <c:when test="${pct >= 70}">#f57f17</c:when>
                                                                     <c:otherwise>              #c62828</c:otherwise>
                                                                 </c:choose>">
                                                            </div>
                                                        </div>
                                                        <span class="pnum">${pct}%</span>
                                                    </div>
                                                </c:if>
                                            </c:forEach>
                                        </div>
                                    </div>
                                    <!-- Near-breach ticket list -->
                                    <div class="col-lg-4 mb-3">
                                        <div class="panel">
                                            <div class="panel-title">
                                                <span><i class="feather icon-alert-triangle mr-1 text-warning"></i> Near breach (&lt;2h)</span>
                                            </div>
                                            <c:choose>
                                                <c:when test="${empty nearBreachList}">
                                                    <p class="text-muted" style="font-size:.85rem">No tickets near SLA breach.</p>
                                                </c:when>
                                                <c:otherwise>
                                                    <c:forEach var="nb" items="${nearBreachList}">
                                                        <div class="list-row">
                                                            <div class="r-label">
                                                                <span class="font-weight-600">${nb.TicketNumber}</span><br>
                                                                <span class="text-muted" style="font-size:.78rem">${nb.Title}</span>
                                                            </div>
                                                            <div class="r-val text-right">
                                                                <span class="sbadge sbadge-warning">${nb.Priority}</span><br>
                                                                <span style="font-size:.75rem;color:#c62828">
                                                                    <fmt:formatDate value="${nb.ResolutionDeadline}" pattern="HH:mm dd/MM"/>
                                                                </span>
                                                            </div>
                                                        </div>
                                                    </c:forEach>
                                                </c:otherwise>
                                            </c:choose>
                                        </div>
                                    </div>
                                </div>

                                <!-- ════════════════════════════════════════
                                     ZONE 4 — PROBLEM & CHANGE MANAGEMENT
                                ════════════════════════════════════════ -->
                                <div class="dash-section">
                                    <h6><i class="feather icon-tool mr-1"></i> Problem &amp; Change Management</h6>
                                </div>
                                <div class="row">
                                    <!-- Problem status -->
                                    <div class="col-lg-4 mb-3">
                                        <div class="panel">
                                            <div class="panel-title">
                                                Problem status
                                                <a href="ProblemList">View all</a>
                                            </div>
                                            <c:forEach var="entry" items="${problemsByStatus}">
                                                <c:if test="${entry.value > 0}">
                                                    <div class="list-row">
                                                        <span class="r-label">${entry.key}</span>
                                                        <span class="sbadge
                                                              <c:choose>
                                                                  <c:when test="${entry.key == 'Pending'}">          sbadge-warning</c:when>
                                                                  <c:when test="${entry.key == 'Under Investigation'}">sbadge-progress</c:when>
                                                                  <c:when test="${entry.key == 'Resolved'}">          sbadge-resolved</c:when>
                                                                  <c:when test="${entry.key == 'Closed'}">            sbadge-closed</c:when>
                                                                  <c:when test="${entry.key == 'Rejected'}">          sbadge-danger</c:when>
                                                                  <c:otherwise>                                       sbadge-new</c:otherwise>
                                                              </c:choose>">${entry.value}</span>
                                                    </div>
                                                </c:if>
                                            </c:forEach>
                                        </div>
                                    </div>
                                    <!-- RFC status -->
                                    <div class="col-lg-4 mb-3">
                                        <div class="panel">
                                            <div class="panel-title">
                                                RFC (Change Request) status
                                                <a href="ManagerChangeApprovals">View all</a>
                                            </div>
                                            <c:forEach var="entry" items="${rfcByStatus}">
                                                <c:if test="${entry.value > 0}">
                                                    <div class="list-row">
                                                        <span class="r-label">${entry.key}</span>
                                                        <span class="sbadge
                                                              <c:choose>
                                                                  <c:when test="${entry.key == 'Pending Approval'}">sbadge-warning</c:when>
                                                                  <c:when test="${entry.key == 'Approved'}">        sbadge-success</c:when>
                                                                  <c:when test="${entry.key == 'In Progress'}">     sbadge-progress</c:when>
                                                                  <c:when test="${entry.key == 'Completed'}">       sbadge-resolved</c:when>
                                                                  <c:when test="${entry.key == 'Rejected'}">        sbadge-danger</c:when>
                                                                  <c:when test="${entry.key == 'RolledBack'}">      sbadge-danger</c:when>
                                                                  <c:otherwise>                                     sbadge-closed</c:otherwise>
                                                              </c:choose>">${entry.value}</span>
                                                    </div>
                                                </c:if>
                                            </c:forEach>
                                        </div>
                                    </div>
                                    <!-- RFC pending needs action -->
                                    <div class="col-lg-4 mb-3">
                                        <div class="panel">
                                            <div class="panel-title">
                                                <span><i class="feather icon-clock mr-1 text-warning"></i> RFC awaiting approval</span>
                                                <a href="ManagerChangeApprovals">Approve</a>
                                            </div>
                                            <c:choose>
                                                <c:when test="${empty top5PendingRFCs}">
                                                    <p class="text-muted" style="font-size:.85rem">No pending RFCs.</p>
                                                </c:when>
                                                <c:otherwise>
                                                    <c:forEach var="rfc" items="${top5PendingRFCs}">
                                                        <div class="list-row">
                                                            <div class="r-label">
                                                                <span class="font-weight-600">${rfc.rfcNumber}</span><br>
                                                                <span class="text-muted" style="font-size:.78rem">${rfc.title}</span>
                                                            </div>
                                                            <span class="sbadge
                                                                  <c:choose>
                                                                      <c:when test="${rfc.riskLevel == 'High'}">   sbadge-danger</c:when>
                                                                      <c:when test="${rfc.riskLevel == 'Medium'}"> sbadge-warning</c:when>
                                                                      <c:otherwise>                               sbadge-success</c:otherwise>
                                                                  </c:choose>">${rfc.riskLevel}</span>
                                                        </div>
                                                    </c:forEach>
                                                </c:otherwise>
                                            </c:choose>
                                        </div>
                                    </div>
                                </div>

                                <!-- ════════════════════════════════════════
                                     ZONE 5 — USER & AGENT MANAGEMENT
                                ════════════════════════════════════════ -->
                                <div class="dash-section">
                                    <h6><i class="feather icon-users mr-1"></i> User &amp; Agent Management</h6>
                                </div>
                                <div class="row">
                                    <!-- User role breakdown -->
                                    <div class="col-lg-4 mb-3">
                                        <div class="panel">
                                            <div class="panel-title">
                                                Users by role
                                                <a href="UserCreate">Manage</a>
                                            </div>
                                            <c:forEach var="entry" items="${usersByRole}">
                                                <div class="prow">
                                                    <span class="plabel">${entry.key}</span>
                                                    <div class="pbar">
                                                        <div class="pfill"
                                                             style="width:${entry.value * 100 / (totalActiveUsers > 0 ? totalActiveUsers : 1)}%;
                                                             background:#5e35b1"></div>
                                                    </div>
                                                    <span class="pnum">${entry.value}</span>
                                                </div>
                                            </c:forEach>
                                        </div>
                                    </div>
                                    <!-- Top agents -->
                                    <div class="col-lg-4 mb-3">
                                        <div class="panel">
                                            <div class="panel-title">Top agents this month</div>
                                            <c:set var="agentRank" value="0"/>
                                            <c:forEach var="agent" items="${topAgents}" varStatus="loop">
                                                <div class="list-row">
                                                    <div class="r-label" style="display:flex;align-items:center;gap:8px">
                                                        <div class="agent-avatar"
                                                             style="<c:if test="${loop.index == 0}">background:#e8f5e9;color:#2e7d32;</c:if>
                                                             <c:if test="${loop.index == 1}">background:#e3f2fd;color:#1565c0;</c:if>">
                                                            ${loop.index + 1}
                                                        </div>
                                                        ${agent.fullName}
                                                    </div>
                                                    <span class="r-val">${agent.ticketCount != null ? agent.ticketCount : '—'} resolved</span>
                                                </div>
                                            </c:forEach>
                                        </div>
                                    </div>
                                    <!-- Agent CSAT leaderboard -->
                                    <div class="col-lg-4 mb-3">
                                        <div class="panel">
                                            <div class="panel-title">Agent CSAT leaderboard</div>
                                            <c:forEach var="row" items="${agentCsat}" varStatus="loop">
                                                <c:if test="${loop.index < 5}">
                                                    <div class="list-row">
                                                        <div class="r-label" style="display:flex;align-items:center;gap:8px">
                                                            <div class="agent-avatar">${loop.index + 1}</div>
                                                            ${row[0]}
                                                        </div>
                                                        <div class="r-val">
                                                            <span class="star-filled">&#9733;</span>
                                                            <fmt:formatNumber value="${row[1]}" pattern="0.0"/>
                                                            <span class="text-muted ml-1">(${row[2]})</span>
                                                        </div>
                                                    </div>
                                                </c:if>
                                            </c:forEach>
                                        </div>
                                    </div>
                                </div>

                                <!-- ════════════════════════════════════════
                                     ZONE 6 — CSAT & SERVICE QUALITY
                                ════════════════════════════════════════ -->
                                <div class="dash-section">
                                    <h6><i class="feather icon-smile mr-1"></i> Customer Satisfaction (CSAT)</h6>
                                </div>
                                <div class="row">
                                    <!-- CSAT summary + distribution -->
                                    <div class="col-lg-6 mb-3">
                                        <div class="panel">
                                            <div class="panel-title">
                                                CSAT overview
                                                <a href="CsatReport">Full report</a>
                                            </div>
                                            <div class="d-flex gap-4 mb-3">
                                                <div style="text-align:center;min-width:80px">
                                                    <div style="font-size:2rem;font-weight:700;color:#2e7d32">${csatAvg}</div>
                                                    <div style="font-size:.75rem;color:#888">Avg Rating</div>
                                                </div>
                                                <div style="text-align:center;min-width:80px">
                                                    <div style="font-size:2rem;font-weight:700">${csatTotal}</div>
                                                    <div style="font-size:.75rem;color:#888">Surveys</div>
                                                </div>
                                                <div style="text-align:center;min-width:80px">
                                                    <div style="font-size:2rem;font-weight:700;color:#1565c0">${csatResponseRate}%</div>
                                                    <div style="font-size:.75rem;color:#888">Response Rate</div>
                                                </div>
                                            </div>
                                            <!-- Rating distribution bars -->
                                            <c:forEach begin="1" end="5" var="i">
                                                <c:set var="star" value="${6 - i}" />
                                                <c:set var="distIdx" value="${star - 1}" />

                                                <div class="prow">
                                                    <span class="plabel">★${star}</span>
                                                    <div class="pbar">
                                                        <div class="pfill"
                                                             style="width:${csatTotal > 0 ? csatDist[distIdx] * 100 / csatTotal : 0}%;
                                                             background:
                                                             <c:choose>
                                                                 <c:when test="${star == 5}">#2e7d32</c:when>
                                                                 <c:when test="${star == 4}">#558b2f</c:when>
                                                                 <c:when test="${star == 3}">#f9a825</c:when>
                                                                 <c:when test="${star == 2}">#e65100</c:when>
                                                                 <c:otherwise>#c62828</c:otherwise>
                                                             </c:choose>">
                                                        </div>
                                                    </div>
                                                    <span class="pnum">${csatDist[distIdx]}</span>
                                                </div>
                                            </c:forEach>
                                            <c:forEach begin="1" end="5" var="i">
                                                <c:set var="star" value="${6 - i}" />
                                                <c:set var="distIdx" value="${star - 1}" />
                                                <div class="prow">
                                                    <span class="plabel" style="width:30px">★${star}</span>
                                                    <div class="pbar">
                                                        <div class="pfill"
                                                             style="width:${csatTotal > 0 ? csatDist[distIdx] * 100 / csatTotal : 0}%;
                                                             background:${starColors[star]}">
                                                        </div>
                                                    </div>
                                                    <span class="pnum">${csatDist[distIdx]}</span>
                                                </div>
                                            </c:forEach>
                                        </div>
                                    </div>
                                    <!-- Donut chart for CSAT distribution -->
                                    <div class="col-lg-6 mb-3">
                                        <div class="panel">
                                            <div class="panel-title">Rating distribution chart</div>
                                            <div style="height:220px; position:relative">
                                                <canvas id="csatDonutChart"></canvas>
                                            </div>
                                        </div>
                                    </div>
                                </div>

                                <!-- ════════════════════════════════════════
                                     ZONE 7 — AUDIT LOG & SYSTEM ACTIVITY
                                ════════════════════════════════════════ -->
                                <div class="dash-section">
                                    <h6><i class="feather icon-shield mr-1"></i> Audit Log &amp; System Activity</h6>
                                    <small>Admin-only — last 10 system actions</small>
                                </div>
                                <div class="row">
                                    <div class="col-12 mb-4">
                                        <div class="panel">
                                            <div class="panel-title">
                                                Recent system activity
                                                <a href="#">View full log</a>
                                            </div>
                                            <c:choose>
                                                <c:when test="${empty recentAuditLogs}">
                                                    <p class="text-muted" style="font-size:.85rem">No audit log entries found.</p>
                                                </c:when>
                                                <c:otherwise>
                                                    <c:forEach var="log" items="${recentAuditLogs}">
                                                        <div class="audit-row">
                                                            <div class="flex-grow-1">
                                                                <span class="audit-action">${log.action}</span>
                                                                on
                                                                <span class="audit-entity">${log.entity} #${log.entityId}</span>
                                                                by
                                                                <strong>${log.userName != null ? log.userName : 'User #'.concat(log.userId)}</strong>
                                                            </div>
                                                            <div class="audit-time">
                                                                <fmt:formatDate value="${log.createdAt}" pattern="HH:mm dd/MM/yyyy"/>
                                                            </div>
                                                        </div>
                                                    </c:forEach>
                                                </c:otherwise>
                                            </c:choose>
                                        </div>
                                    </div>
                                </div>

                            </div><!-- page-wrapper -->
                        </div><!-- main-body -->
                    </div>
                </div><!-- pcoded-content -->
            </div>
        </div><!-- pcoded-main-container -->

        <!-- ════════════════════════════════════════════════════════════════════
             SCRIPTS
        ════════════════════════════════════════════════════════════════════ -->
        <script src="assets/plugins/jquery/js/jquery.min.js"></script>
        <script src="assets/js/vendor-all.min.js"></script>
        <script src="assets/plugins/bootstrap/js/bootstrap.min.js"></script>
        <script src="assets/js/pcoded.min.js"></script>
        <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>

        <%-- Pass server-side data into JS --%>
        <c:set var="lbs"      value="${empty chartLabels   ? '' : chartLabels}" />
        <c:set var="resolved" value="${empty chartResolved ? '' : chartResolved}" />
        <c:set var="open"     value="${empty chartOpen     ? '' : chartOpen}" />

        <script>
            /* ── Ticket Volume Chart ───────────────────────────────────── */
            var chartLabels = [
            <c:forEach var="lb" items="${lbs}" varStatus="st">'${lb}'<c:if test="${!st.last}">,</c:if></c:forEach>
            ];
            var chartResolved = [
            <c:forEach var="n" items="${resolved}" varStatus="st">${n}<c:if test="${!st.last}">,</c:if></c:forEach>
            ];
            var chartOpen = [
            <c:forEach var="n" items="${open}" varStatus="st">${n}<c:if test="${!st.last}">,</c:if></c:forEach>
            ];

            (function () {
                var ctx = document.getElementById('ticketVolumeChart');
                if (!ctx)
                    return;
                if (!chartLabels.length) {
                    chartLabels = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun'];
                    chartResolved = [0, 0, 0, 0, 0, 0];
                    chartOpen = [0, 0, 0, 0, 0, 0];
                }
                new Chart(ctx.getContext('2d'), {
                    type: 'bar',
                    data: {
                        labels: chartLabels,
                        datasets: [
                            {
                                label: 'Resolved',
                                data: chartResolved,
                                backgroundColor: 'rgba(46,125,50,.7)',
                                borderRadius: 4
                            },
                            {
                                label: 'Open / Pending',
                                data: chartOpen,
                                backgroundColor: 'rgba(94,53,177,.6)',
                                borderRadius: 4
                            }
                        ]
                    },
                    options: {
                        responsive: true,
                        maintainAspectRatio: false,
                        plugins: {legend: {position: 'top'}},
                        scales: {y: {beginAtZero: true, ticks: {stepSize: 1}}}
                    }
                });
            })();

            /* ── CSAT Donut Chart ──────────────────────────────────────── */
            (function () {
                var ctx2 = document.getElementById('csatDonutChart');
                if (!ctx2)
                    return;
                var dist = [
            ${csatDist[0]},
            ${csatDist[1]},
            ${csatDist[2]},
            ${csatDist[3]},
            ${csatDist[4]}
                ];
                new Chart(ctx2.getContext('2d'), {
                    type: 'doughnut',
                    data: {
                        labels: ['★1', '★2', '★3', '★4', '★5'],
                        datasets: [{
                                data: dist,
                                backgroundColor: ['#c62828', '#e65100', '#f9a825', '#558b2f', '#2e7d32'],
                                borderWidth: 2
                            }]
                    },
                    options: {
                        responsive: true,
                        maintainAspectRatio: false,
                        plugins: {
                            legend: {position: 'right', labels: {font: {size: 12}}}
                        },
                        cutout: '60%'
                    }
                });
            })();
        </script>

        <script>
            $(document).ready(function () {
                $('.fixed-button').remove();
            });
        </script>
    </body>
</html>
