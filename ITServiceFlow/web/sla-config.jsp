<%-- Document : sla-config Created on : Feb 14, 2026 Author : DELL --%>

    <%@page contentType="text/html" pageEncoding="UTF-8" %>
        <%@ taglib uri="jakarta.tags.core" prefix="c" %>
            <!DOCTYPE html>
            <html lang="en">

            <head>
                <title>IT Service Flow - SLA Configuration</title>
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
                                                            <h5 class="m-b-10">SLA Configuration</h5>
                                                        </div>
                                                        <ul class="breadcrumb">
                                                            <li class="breadcrumb-item"><a href="index.html"><i
                                                                        class="feather icon-home"></i></a></li>
                                                            <li class="breadcrumb-item"><a href="#!">Settings</a></li>
                                                            <li class="breadcrumb-item"><a href="#!">SLA
                                                                    Configuration</a></li>
                                                        </ul>
                                                    </div>
                                                </div>
                                            </div>
                                        </div>
                                        <!-- [ breadcrumb ] end -->

                                        <!-- [ Main Content ] start -->

                                        <c:if test="${not empty sessionScope.successMessage}">
                                            <div class="alert alert-success alert-dismissible fade show" role="alert">
                                                ${sessionScope.successMessage}
                                                <button type="button" class="close" data-dismiss="alert"
                                                    aria-label="Close">
                                                    <span aria-hidden="true">&times;</span>
                                                </button>
                                            </div>
                                            <c:remove var="successMessage" scope="session" />
                                        </c:if>

                                        <c:if test="${not empty sessionScope.errorMessage}">
                                            <div class="alert alert-danger alert-dismissible fade show" role="alert">
                                                ${sessionScope.errorMessage}
                                                <button type="button" class="close" data-dismiss="alert"
                                                    aria-label="Close">
                                                    <span aria-hidden="true">&times;</span>
                                                </button>
                                            </div>
                                            <c:remove var="errorMessage" scope="session" />
                                        </c:if>

                                        <div class="row">
                                            <!-- SLA List -->
                                            <div class="col-xl-8 col-md-12">
                                                <div class="card">
                                                    <div class="card-header">
                                                        <h5>SLA Rules</h5>
                                                    </div>
                                                    <div class="card-body table-border-style">
                                                        <!-- Search Form -->
                                                        <form action="SLAConfig" method="get" class="mb-3">
                                                            <div class="form-row">
                                                                <div class="col">
                                                                    <input type="text" class="form-control" name="name"
                                                                        placeholder="SLA Name" value="${param.name}">
                                                                </div>
                                                                <div class="col">
                                                                     <select class="form-control" name="type">
                                                                         <option value="">-- All Types --</option>
                                                                         <c:forEach items="${availableTypes}" var="t">
                                                                             <option value="${t}" ${param.type==t ? 'selected' : ''}>${t}</option>
                                                                         </c:forEach>
                                                                     </select>
                                                                 </div>
                                                                <div class="col">
                                                                    <select class="form-control" name="priority">
                                                                        <option value="">-- All Priorities --</option>
                                                                        <c:forEach items="${priorities}" var="p">
                                                                            <option value="${p.id}"
                                                                                ${param.priority==p.id ? 'selected' : ''
                                                                                }>${p.level}</option>
                                                                        </c:forEach>
                                                                    </select>
                                                                </div>
                                                                <div class="col">
                                                                     <select class="form-control" name="status">
                                                                         <option value="">-- All Status --</option>
                                                                         <c:forEach items="${availableStatuses}" var="s">
                                                                             <option value="${s}" ${param.status==s ? 'selected' : ''}>${s}</option>
                                                                         </c:forEach>
                                                                     </select>
                                                                 </div>
                                                                <div class="col">
                                                                    <button type="submit"
                                                                        class="btn btn-primary">Search</button>
                                                                    <a href="SLAConfig"
                                                                        class="btn btn-secondary">Reset</a>
                                                                </div>
                                                            </div>
                                                        </form>

                                                        <div class="table-responsive">
                                                            <table class="table table-hover">
                                                                <thead>
                                                                    <tr>
                                                                        <th>Name</th>
                                                                        <th>Type</th>
                                                                        <th>Priority</th>
                                                                        <th>Response (h)</th>
                                                                        <th>Resolution (h)</th>
                                                                        <th>Status</th>
                                                                        <th>Action</th>
                                                                    </tr>
                                                                </thead>
                                                                <tbody>
                                                                    <c:if test="${empty slaRules}">
                                                                        <tr>
                                                                            <td colspan="7" class="text-center">No SLA
                                                                                rules found.</td>
                                                                        </tr>
                                                                    </c:if>
                                                                    <c:forEach items="${slaRules}" var="sla">
                                                                        <tr>
                                                                            <td>
                                                                                <a
                                                                                    href="SLAConfig?action=detail&id=${sla.id}">
                                                                                    ${sla.slaName}
                                                                                </a>
                                                                            </td>
                                                                            <td>${sla.ticketType}</td>
                                                                            <td>${sla.priorityName}</td>
                                                                            <td>${sla.responseTime}</td>
                                                                            <td>${sla.resolutionTime}</td>
                                                                            <td>
                                                                                <span
                                                                                    class="badge badge-${sla.status == 'Active' ? 'success' : 'secondary'}">
                                                                                    ${sla.status}
                                                                                </span>
                                                                            </td>
                                                                            <td>
                                                                                <a href="SLAConfig?action=edit&id=${sla.id}"
                                                                                    class="btn btn-sm btn-info">
                                                                                    <i class="feather icon-edit"></i>
                                                                                </a>
                                                                                <form action="SLAConfig" method="post"
                                                                                    style="display:inline;"
                                                                                    onsubmit="return confirm('Delete this SLA Rule?');">
                                                                                    <input type="hidden" name="action"
                                                                                        value="delete">
                                                                                    <input type="hidden" name="id"
                                                                                        value="${sla.id}">
                                                                                    <button type="submit"
                                                                                        class="btn btn-sm btn-danger">
                                                                                        <i
                                                                                            class="feather icon-trash-2"></i>
                                                                                    </button>
                                                                                </form>
                                                                            </td>
                                                                        </tr>
                                                                    </c:forEach>
                                                                </tbody>
                                                            </table>
                                                        </div>

                                                        <!-- Pagination -->
                                                        <div class="d-flex justify-content-between align-items-center mt-3">
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
                                                                                href="SLAConfig?page=${currentPage - 1}&name=${paramName}&type=${paramType}&priority=${paramPriority}&status=${paramStatus}">Previous</a>
                                                                        </li>
                                                                        <c:forEach begin="1" end="${totalPages}" var="i">
                                                                            <li
                                                                                class="page-item ${currentPage == i ? 'active' : ''}">
                                                                                <a class="page-link"
                                                                                    href="SLAConfig?page=${i}&name=${paramName}&type=${paramType}&priority=${paramPriority}&status=${paramStatus}">${i}</a>
                                                                            </li>
                                                                        </c:forEach>
                                                                        <li class="page-item ${currentPage == totalPages ? 'disabled' : ''}">
                                                                            <a class="page-link"
                                                                                href="SLAConfig?page=${currentPage + 1}&name=${paramName}&type=${paramType}&priority=${paramPriority}&status=${paramStatus}">Next</a>
                                                                        </li>
                                                                    </ul>
                                                                </nav>
                                                            </c:if>
                                                        </div>
                                                    </div>
                                                </div>
                                            </div>

                                            <!-- Add/Edit Form -->
                                            <div class="col-xl-4 col-md-12">
                                                <div class="card">
                                                    <div class="card-header">
                                                        <h5>${ruleToEdit != null ? 'Edit SLA Rule' : 'Add New SLA Rule'}
                                                        </h5>
                                                    </div>
                                                    <div class="card-body">
                                                        <form action="SLAConfig" method="post">
                                                            <input type="hidden" name="id"
                                                                value="${ruleToEdit != null ? ruleToEdit.id : ''}">

                                                            <div class="form-group">
                                                                <label for="slaName">SLA Name</label>
                                                                <input type="text" class="form-control" id="slaName"
                                                                    name="slaName" required
                                                                    value="${ruleToEdit != null ? ruleToEdit.slaName : ''}">
                                                            </div>

                                                            <div class="form-group">
                                                                <label for="ticketType">Ticket Type</label>
                                                                <select class="form-control" id="ticketType"
                                                                    name="ticketType">
                                                                    <option value="Incident" ${ruleToEdit !=null &&
                                                                        ruleToEdit.ticketType=='Incident' ? 'selected'
                                                                        : '' }>Incident</option>
                                                                    <option value="ServiceRequest" ${ruleToEdit !=null
                                                                        && ruleToEdit.ticketType=='ServiceRequest'
                                                                        ? 'selected' : '' }>Service Request</option>
                                                                </select>
                                                            </div>

                                                            <div class="form-group">
                                                                <label for="priorityId">Priority</label>
                                                                <select class="form-control" id="priorityId"
                                                                    name="priorityId">
                                                                    <c:forEach items="${priorities}" var="p">
                                                                        <option value="${p.id}" ${ruleToEdit !=null &&
                                                                            ruleToEdit.priorityId==p.id ? 'selected'
                                                                            : '' }>
                                                                            ${p.level} (Impact: ${p.impact}, Urgency:
                                                                            ${p.urgency})
                                                                        </option>
                                                                    </c:forEach>
                                                                </select>
                                                            </div>

                                                            <div class="form-group">
                                                                <label for="responseTime">Response Time (Hours)</label>
                                                                <input type="number" class="form-control"
                                                                    id="responseTime" name="responseTime" required
                                                                    min="1"
                                                                    value="${ruleToEdit != null ? ruleToEdit.responseTime : ''}">
                                                            </div>

                                                            <div class="form-group">
                                                                <label for="resolutionTime">Resolution Time
                                                                    (Hours)</label>
                                                                <input type="number" class="form-control"
                                                                    id="resolutionTime" name="resolutionTime" required
                                                                    min="1"
                                                                    value="${ruleToEdit != null ? ruleToEdit.resolutionTime : ''}">
                                                            </div>

                                                            <div class="form-group">
                                                                <label for="status">Status</label>
                                                                <select class="form-control" id="status" name="status">
                                                                    <option value="Active" ${ruleToEdit !=null &&
                                                                        ruleToEdit.status=='Active' ? 'selected' : '' }>
                                                                        Active</option>
                                                                    <option value="Inactive" ${ruleToEdit !=null &&
                                                                        ruleToEdit.status=='Inactive' ? 'selected' : ''
                                                                        }>Inactive</option>
                                                                </select>
                                                            </div>

                                                            <button type="submit" class="btn btn-primary">${ruleToEdit
                                                                != null ? 'Update Rule' : 'Add Rule'}</button>
                                                            <c:if test="${ruleToEdit != null}">
                                                                <a href="SLAConfig" class="btn btn-secondary">Cancel</a>
                                                            </c:if>
                                                        </form>
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