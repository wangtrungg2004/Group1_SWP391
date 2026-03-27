<%-- Document : sla-breach-list Created on : Feb 15, 2026 Author : DELL --%>
<%@page contentType="text/html" pageEncoding="UTF-8" %>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<%@ taglib uri="jakarta.tags.fmt" prefix="fmt" %>
<!DOCTYPE html>
<html lang="en">

    <head>
        <title>IT Service Flow - SLA Breach List</title>
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
                                                    <h5 class="m-b-10">SLA Breach List</h5>
                                                </div>
                                                <ul class="breadcrumb">
                                                    <li class="breadcrumb-item"><a
                                                            href="AdminDashboard.jsp"><i
                                                                class="feather icon-home"></i></a></li>
                                                    <li class="breadcrumb-item"><a href="#!">SLA
                                                            Management</a></li>
                                                    <li class="breadcrumb-item"><a href="#!">Breach List</a>
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
                                                <h5>Critical Tickets (Breached or Nearing Breach)</h5>
                                            </div>
                                            <div class="card-body">
                                                <!-- Filter Form -->
                                                <form action="SLABreachList" method="get" class="row mb-4">
                                                    <div class="col-md-3">
                                                        <select name="priority" class="form-control">
                                                            <option value="">-- All Priorities --</option>
                                                            <c:forEach items="${priorities}" var="p">
                                                                <option value="${p.id}"
                                                                        ${param.priority==p.id ? 'selected' : ''
                                                                          }>${p.level}</option>
                                                            </c:forEach>
                                                        </select>
                                                    </div>
                                                    <div class="col-md-3">
                                                        <select name="status" class="form-control">
                                                            <option value="">-- All Statuses --</option>
                                                            <c:forEach items="${availableStatuses}" var="s">
                                                                <option value="${s}" ${param.status==s ? 'selected' : ''}>${s}</option>
                                                            </c:forEach>
                                                        </select>
                                                    </div>
                                                    <div class="col-md-5">
                                                        <input type="text" name="agent" class="form-control"
                                                               placeholder="Agent Name" value="${param.agent}">
                                                    </div>
                                                    <div class="col-md-1">
                                                        <button type="submit"
                                                                class="btn btn-primary btn-block"><i
                                                                class="feather icon-filter"></i></button>
                                                    </div>
                                                </form>

                                                <!-- Table -->
                                                <div class="table-responsive">
                                                    <table class="table table-hover">
                                                        <thead>
                                                            <tr>
                                                                <th>Ticket #</th>
                                                                <th>Title</th>
                                                                <th>Priority</th>
                                                                <th>Assigned To</th>
                                                                <th>Status</th>
                                                                <th>Deadline</th>
                                                                <th>Remaining Time</th>
                                                                <th>Action</th>
                                                            </tr>
                                                        </thead>
                                                        <tbody>
                                                            <c:if test="${empty tickets}">
                                                                <tr>
                                                                    <td colspan="8" class="text-center">No
                                                                        breach or near-breach tickets found.
                                                                    </td>
                                                                </tr>
                                                            </c:if>
                                                            <c:forEach items="${tickets}" var="t">
                                                                <tr>
                                                                    <td>${t['TicketNumber']}</td>
                                                                    <td>${t['Title']}</td>
                                                                    <td>
                                                                        <span
                                                                            class="badge badge-${t['Priority'] == 'High' || t['Priority'] == 'Critical' ? 'danger' : (t['Priority'] == 'Medium' ? 'warning' : 'success')}">${t['Priority']}</span>
                                                                    </td>
                                                                    <td>${t['AssignedTo'] != null ?
                                                                          t['AssignedTo'] : '<span
                                                                          class="text-muted">Unassigned</span>'}
                                                                    </td>
                                                                    <td>${t['Status']}</td>
                                                                    <td>
                                                                        <fmt:formatDate
                                                                            value="${t['ResolutionDeadline']}"
                                                                            pattern="MM-dd HH:mm" />
                                                                    </td>
                                                                    <td>
                                                                        <c:set var="rem" value="${t['RemainingMinutes']}" />
                                                                        <c:choose>

                                                                            <c:when test="${rem < 0}">
                                                                                <c:set var="absRem" value="${-rem}" />
                                                                                <span class="text-danger font-weight-bold">
                                                                                    Overdue by <fmt:formatNumber value="${(absRem - (absRem % 60)) / 60}" pattern="#0"/>h ${absRem % 60}m
                                                                                </span>
                                                                            </c:when>


                                                                            <c:when test="${rem < 120}">
                                                                                <span class="text-warning font-weight-bold">
                                                                                    <fmt:formatNumber value="${(rem - (rem % 60)) / 60}" pattern="#0"/>h ${rem % 60}m left
                                                                                </span>
                                                                            </c:when>


                                                                            <c:otherwise>
                                                                                <span class="text-success font-weight-bold">
                                                                                    <fmt:formatNumber value="${(rem - (rem % 60)) / 60}" pattern="#0"/>h ${rem % 60}m left
                                                                                </span>
                                                                            </c:otherwise>
                                                                        </c:choose>
                                                                    </td>
                                                                    <td>
                                                                        <a href="tickets?action=view&id=${t['Id']}"
                                                                           class="btn btn-icon btn-outline-primary"><i
                                                                                class="feather icon-eye"></i></a>
                                                                    </td>
                                                                </tr>
                                                            </c:forEach>
                                                        </tbody>
                                                    </table>
                                                </div>

                                                <!-- Pagination -->
                                                <div class="d-flex justify-content-between align-items-center mt-4">
                                                    <div>
                                                        <c:if test="${totalRecords > 0}">
                                                            Showing ${(currentPage - 1) * 10 + 1} to 
                                                            ${currentPage * 10 > totalRecords ? totalRecords : currentPage * 10} 
                                                            of ${totalRecords} entries
                                                        </c:if>
                                                    </div>
                                                    <c:if test="${totalPages > 1}">
                                                        <nav aria-label="Page navigation">
                                                            <ul class="pagination mb-0">
                                                                <li class="page-item ${currentPage == 1 ? 'disabled' : ''}">
                                                                    <a class="page-link"
                                                                       href="SLABreachList?page=${currentPage - 1}&priority=${paramPriority}&status=${paramStatus}&agent=${paramAgent}">Previous</a>
                                                                </li>
                                                                <c:forEach begin="1" end="${totalPages}" var="i">
                                                                    <li
                                                                        class="page-item ${currentPage == i ? 'active' : ''}">
                                                                        <a class="page-link"
                                                                           href="SLABreachList?page=${i}&priority=${paramPriority}&status=${paramStatus}&agent=${paramAgent}">${i}</a>
                                                                    </li>
                                                                </c:forEach>
                                                                <li class="page-item ${currentPage == totalPages ? 'disabled' : ''}">
                                                                    <a class="page-link"
                                                                       href="SLABreachList?page=${currentPage + 1}&priority=${paramPriority}&status=${paramStatus}&agent=${paramAgent}">Next</a>
                                                                </li>
                                                            </ul>
                                                        </nav>
                                                    </c:if>
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