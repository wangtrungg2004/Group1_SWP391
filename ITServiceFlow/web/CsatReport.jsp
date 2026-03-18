<%@ page contentType="text/html" pageEncoding="UTF-8"%>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<%@ taglib uri="jakarta.tags.fmt" prefix="fmt" %>
<!DOCTYPE html>
<html lang="en">
<head>
	<meta charset="utf-8">
	<meta name="viewport" content="width=device-width, initial-scale=1.0, user-scalable=0, minimal-ui">
	<meta http-equiv="X-UA-Compatible" content="IE=edge" />
	<title>CSAT Report - ITServiceFlow</title>
	<link rel="stylesheet" href="assets/fonts/fontawesome/css/fontawesome-all.min.css">
	<link rel="stylesheet" href="assets/plugins/animation/css/animate.min.css">
	<link rel="stylesheet" href="assets/plugins/bootstrap/css/bootstrap.min.css">
	<link rel="stylesheet" href="assets/css/style.css">
	<style>
		.kpi-card { background:#fff; border-radius:4px; padding:24px 20px; text-align:center; }
		.kpi-value { font-size:2rem; font-weight:700; line-height:1.1; margin-bottom:4px; }
		.kpi-label { font-size:0.78rem; color:#6b778c; text-transform:uppercase; letter-spacing:0.5px; }
		.kpi-icon  { font-size:1.8rem; margin-bottom:10px; }
		.star-filled { color:#f6c90e; }
		.star-empty  { color:#dfe1e6; }
		.rating-bar-wrap  { display:flex; align-items:center; gap:10px; margin-bottom:8px; }
		.rating-bar-label { width:40px; font-size:0.82rem; color:#5e6c84; text-align:right; }
		.rating-bar-bg    { flex:1; background:#f4f5f7; border-radius:4px; height:12px; overflow:hidden; }
		.rating-bar-fill  { height:100%; border-radius:4px; background:#f6c90e; }
		.rating-bar-count { width:28px; font-size:0.78rem; color:#6b778c; }
		.agent-row { display:flex; align-items:center; padding:10px 0; border-bottom:1px solid #f4f5f7; }
		.agent-row:last-child { border-bottom:none; }
		.agent-rank   { width:28px; font-size:0.85rem; font-weight:700; color:#a5adba; }
		.agent-avatar { width:34px; height:34px; border-radius:50%; background:#4099ff; color:#fff;
		                display:flex; align-items:center; justify-content:center; font-size:0.75rem; font-weight:700; flex-shrink:0; }
		.agent-name   { flex:1; font-size:0.88rem; font-weight:600; color:#172b4d; margin-left:10px; }
		.survey-table th { font-size:0.75rem; text-transform:uppercase; letter-spacing:0.4px; color:#6b778c; font-weight:600; }
		.survey-table td { font-size:0.85rem; vertical-align:middle; }
		.comment-cell { max-width:200px; overflow:hidden; text-overflow:ellipsis; white-space:nowrap; color:#5e6c84; font-style:italic; }
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
												<h5 class="m-b-5">CSAT Report</h5>
											</div>
											<ul class="breadcrumb">
												<li class="breadcrumb-item"><a href="#!"><i class="feather icon-home"></i></a></li>
												<li class="breadcrumb-item"><a href="#!">CSAT Report</a></li>
											</ul>
										</div>
									</div>
								</div>
							</div>
							<!-- [ breadcrumb ] end -->

							<!-- [ KPI Cards ] start -->
							<div class="row">
								<!-- Average Rating -->
								<div class="col-xl-3 col-md-6">
									<div class="card kpi-card">
										<div class="card-body">
											<div class="kpi-icon star-filled"><i class="fas fa-star"></i></div>
											<div class="kpi-value" style="color:#f6c90e;">
												<fmt:formatNumber value="${avgRating}" pattern="#.#"/>
												<span style="font-size:1rem; color:#a5adba;">/5</span>
											</div>
											<div class="mt-1 mb-1">
												<c:forEach begin="1" end="5" var="i">
													<i class="${i <= avgRating ? 'fas fa-star star-filled' : 'far fa-star star-empty'}" style="font-size:0.9rem;"></i>
												</c:forEach>
											</div>
											<div class="kpi-label">Average Rating</div>
										</div>
									</div>
								</div>

								<!-- Total Surveys -->
								<div class="col-xl-3 col-md-6">
									<div class="card kpi-card">
										<div class="card-body">
											<div class="kpi-icon" style="color:#4099ff;"><i class="feather icon-message-square"></i></div>
											<div class="kpi-value" style="color:#4099ff;">${totalSurveys}</div>
											<div class="kpi-label">Total Surveys</div>
										</div>
									</div>
								</div>

								<!-- Response Rate -->
								<div class="col-xl-3 col-md-6">
									<div class="card kpi-card">
										<div class="card-body">
											<div class="kpi-icon" style="color:#2ed8b6;"><i class="feather icon-percent"></i></div>
											<div class="kpi-value" style="color:#2ed8b6;">
												<fmt:formatNumber value="${responseRate}" pattern="#.#"/>%
											</div>
											<div class="kpi-label">Response Rate</div>
										</div>
									</div>
								</div>

								<!-- Satisfied -->
								<div class="col-xl-3 col-md-6">
									<div class="card kpi-card">
										<div class="card-body">
											<div class="kpi-icon" style="color:#FFB64D;"><i class="feather icon-thumbs-up"></i></div>
											<div class="kpi-value" style="color:#FFB64D;">
												<c:set var="satisfied" value="${ratingDist[3] + ratingDist[4]}"/>
												<c:choose>
													<c:when test="${totalSurveys > 0}">
														<fmt:formatNumber value="${satisfied * 100.0 / totalSurveys}" pattern="#.#"/>%
													</c:when>
													<c:otherwise>—</c:otherwise>
												</c:choose>
											</div>
											<div class="kpi-label">Satisfied (≥4★)</div>
										</div>
									</div>
								</div>
							</div>
							<!-- [ KPI Cards ] end -->

							<!-- [ Main Charts Row ] start -->
							<div class="row">

								<!-- Rating Distribution + Leaderboard -->
								<div class="col-xl-5 col-md-12">

									<!-- Rating Distribution -->
									<div class="card">
										<div class="card-header">
											<h5><i class="feather icon-bar-chart-2 mr-2"></i>Rating Distribution</h5>
										</div>
										<div class="card-body">
											<c:forEach begin="0" end="4" var="i">
												<c:set var="starNum" value="${5 - i}"/>
												<c:set var="count"   value="${ratingDist[5 - i - 1]}"/>
												<div class="rating-bar-wrap">
													<div class="rating-bar-label">${starNum}★</div>
													<div class="rating-bar-bg">
														<div class="rating-bar-fill"
															 style="width:${totalSurveys > 0 ? count * 100 / totalSurveys : 0}%;"></div>
													</div>
													<div class="rating-bar-count">${count}</div>
												</div>
											</c:forEach>
											<c:if test="${totalSurveys == 0}">
												<p class="text-muted text-center mt-2" style="font-size:0.85rem;">No data yet</p>
											</c:if>
										</div>
									</div>

									<!-- Agent Leaderboard -->
									<div class="card">
										<div class="card-header">
											<h5><i class="feather icon-award mr-2"></i>Agent Rating Leaderboard</h5>
										</div>
										<div class="card-body">
											<c:choose>
												<c:when test="${not empty agentRatings}">
													<c:forEach var="agent" items="${agentRatings}" varStatus="st">
														<div class="agent-row">
															<div class="agent-rank">#${st.index + 1}</div>
															<div class="agent-avatar">
																${agent[0].substring(0, 2).toUpperCase()}
															</div>
															<div class="agent-name">${agent[0]}</div>
															<div>
																<span style="font-size:0.9rem; font-weight:700; color:#4099ff;">
																	<i class="fas fa-star star-filled" style="font-size:0.8rem;"></i>
																	<fmt:formatNumber value="${agent[1]}" pattern="#.##"/>
																</span>
																<span style="font-size:0.75rem; color:#a5adba; margin-left:4px;">(${agent[2]})</span>
															</div>
														</div>
													</c:forEach>
												</c:when>
												<c:otherwise>
													<p class="text-muted text-center" style="font-size:0.85rem;">No agent data yet</p>
												</c:otherwise>
											</c:choose>
										</div>
									</div>
								</div>

								<!-- All Surveys Table -->
								<div class="col-xl-7 col-md-12">
									<div class="card">
										<div class="card-header">
											<h5>
												<i class="feather icon-list mr-2"></i>All Surveys
												<span class="badge badge-secondary ml-2">${totalSurveys}</span>
											</h5>
										</div>
										<div class="card-body p-0">
											<c:choose>
												<c:when test="${not empty surveys}">
													<div style="max-height:560px; overflow-y:auto;">
														<table class="table table-hover survey-table mb-0">
															<thead class="thead-light" style="position:sticky;top:0;z-index:1;">
																<tr>
																	<th class="pl-3">Ticket</th>
																	<th>User</th>
																	<th>Agent</th>
																	<th>Rating</th>
																	<th>Comment</th>
																	<th>Date</th>
																</tr>
															</thead>
															<tbody>
																<c:forEach var="s" items="${surveys}">
																	<tr>
																		<td class="pl-3">
																			<a href="${pageContext.request.contextPath}/TicketDetailUser?id=${s.ticketId}"
																			   style="font-size:0.8rem; font-weight:600; color:#4099ff;">
																				${s.ticketNumber}
																			</a>
																			<div class="text-muted" style="font-size:0.72rem;
																			     max-width:130px; overflow:hidden; text-overflow:ellipsis; white-space:nowrap;">
																				${s.ticketTitle}
																			</div>
																		</td>
																		<td>${s.userFullName}</td>
																		<td>${s.assigneeName}</td>
																		<td>
																			<c:forEach begin="1" end="${s.rating}" var="r">
																				<i class="fas fa-star star-filled" style="font-size:0.75rem;"></i>
																			</c:forEach>
																			<c:forEach begin="${s.rating + 1}" end="5" var="r">
																				<i class="far fa-star star-empty" style="font-size:0.75rem;"></i>
																			</c:forEach>
																		</td>
																		<td>
																			<c:choose>
																				<c:when test="${not empty s.comment}">
																					<span class="comment-cell" title="${s.comment}">"${s.comment}"</span>
																				</c:when>
																				<c:otherwise><span class="text-muted">—</span></c:otherwise>
																			</c:choose>
																		</td>
																		<td style="white-space:nowrap; font-size:0.78rem; color:#6b778c;">
																			<fmt:formatDate value="${s.submittedAt}" pattern="dd/MM/yyyy"/>
																		</td>
																	</tr>
																</c:forEach>
															</tbody>
														</table>
													</div>
												</c:when>
												<c:otherwise>
													<div class="text-center py-5 text-muted">
														<i class="feather icon-message-square" style="font-size:2.5rem; opacity:0.3;"></i>
														<p class="mt-2" style="font-size:0.85rem;">No surveys submitted yet</p>
													</div>
												</c:otherwise>
											</c:choose>
										</div>
									</div>
								</div>

							</div>
							<!-- [ Main Charts Row ] end -->

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
	<script>
		$(document).ready(function () {
			$('.fixed-button').remove();
		});
	</script>
</body>
</html>
