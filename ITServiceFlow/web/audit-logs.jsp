<%-- Document : audit-logs Created on : Feb 15, 2026 Author : DELL --%>
    <%@page contentType="text/html" pageEncoding="UTF-8" %>
        <%@ taglib uri="jakarta.tags.core" prefix="c" %>
            <%@ taglib uri="jakarta.tags.fmt" prefix="fmt" %>
                <!DOCTYPE html>
                <html lang="en">

                <head>
                    <title>IT Service Flow - System Audit Logs</title>
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
                                                                <h5 class="m-b-10">System Audit Logs</h5>
                                                            </div>
                                                            <ul class="breadcrumb">
                                                                <li class="breadcrumb-item"><a
                                                                        href="AdminDashboard.jsp"><i
                                                                            class="feather icon-home"></i></a></li>
                                                                <li class="breadcrumb-item"><a href="#!">Audit Logs</a>
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
                                                            <form action="AuditLogs" method="get" class="form-inline">
                                                                <div class="form-group mb-2 mr-2">
                                                                    <label for="user" class="mr-2">User:</label>
                                                                    <input type="text" class="form-control" name="user"
                                                                        value="${user}" placeholder="Username">
                                                                </div>
                                                                <div class="form-group mb-2 mr-2">
                                                                    <label for="action" class="mr-2">Action:</label>
                                                                    <select class="form-control" name="action">
                                                                        <option value="">All</option>
                                                                        <option value="LOGIN" ${action=='LOGIN'
                                                                            ? 'selected' : '' }>Login</option>
                                                                        <option value="LOGOUT" ${action=='LOGOUT'
                                                                            ? 'selected' : '' }>Logout</option>
                                                                        <option value="CREATE_TICKET"
                                                                            ${action=='CREATE_TICKET' ? 'selected' : ''
                                                                            }>Create Ticket</option>
                                                                        <option value="UPDATE_TICKET"
                                                                            ${action=='UPDATE_TICKET' ? 'selected' : ''
                                                                            }>Update Ticket</option>
                                                                        <option value="DELETE_USER"
                                                                            ${action=='DELETE_USER' ? 'selected' : '' }>
                                                                            Delete User</option>
                                                                        <!-- Add more actions as needed -->
                                                                    </select>
                                                                </div>
                                                                <div class="form-group mb-2 mr-2">
                                                                    <label for="from" class="mr-2">From:</label>
                                                                    <input type="date" class="form-control" name="from"
                                                                        value="${from}">
                                                                </div>
                                                                <div class="form-group mb-2 mr-2">
                                                                    <label for="to" class="mr-2">To:</label>
                                                                    <input type="date" class="form-control" name="to"
                                                                        value="${to}">
                                                                </div>
                                                                <button type="submit"
                                                                    class="btn btn-primary mb-2">Filter</button>
                                                                <a href="AuditLogs"
                                                                    class="btn btn-secondary mb-2 ml-2">Reset</a>
                                                            </form>
                                                        </div>
                                                    </div>
                                                </div>

                                                <!-- Table -->
                                                <div class="col-md-12">
                                                    <div class="card">
                                                        <div class="card-header">
                                                            <h5>Log Records</h5>
                                                        </div>
                                                        <div class="card-body table-border-style">
                                                            <div class="table-responsive">
                                                                <table class="table table-hover">
                                                                    <thead>
                                                                        <tr>
                                                                            <th>ID</th>
                                                                            <th>Timestamp</th>
                                                                            <th>User</th>
                                                                            <th>Action</th>
                                                                            <th>Screen</th>
                                                                            <th>Details</th>
                                                                        </tr>
                                                                    </thead>
                                                                    <tbody>
                                                                        <c:forEach items="${logs}" var="log">
                                                                            <tr>
                                                                                <td>${log.id}</td>
                                                                                <td>
                                                                                    <fmt:formatDate
                                                                                        value="${log.createdAt}"
                                                                                        pattern="yyyy-MM-dd HH:mm:ss" />
                                                                                </td>
                                                                                <td>${log.userName != null ?
                                                                                    log.userName : 'Unknown'}</td>
                                                                                <td><span
                                                                                        class="badge badge-light-primary">${log.action}</span>
                                                                                </td>
                                                                                <td>${log.screen}</td>
                                                                                <td>
                                                                                    <button type="button"
                                                                                        class="btn btn-icon btn-outline-info"
                                                                                        data-toggle="modal"
                                                                                        data-target="#detailModal${log.id}">
                                                                                        <i
                                                                                            class="feather icon-info"></i>
                                                                                    </button>

                                                                                    <!-- Modal -->
                                                                                    <div class="modal fade"
                                                                                        id="detailModal${log.id}"
                                                                                        tabindex="-1" role="dialog"
                                                                                        aria-labelledby="exampleModalLabel"
                                                                                        aria-hidden="true">
                                                                                        <div class="modal-dialog modal-xl"
                                                                                            role="document">
                                                                                            <div
                                                                                                class="modal-content border-0 shadow-lg">
                                                                                                <div
                                                                                                    class="modal-header bg-primary text-white">
                                                                                                    <h5 class="modal-title font-weight-bold"
                                                                                                        id="exampleModalLabel">
                                                                                                        <i
                                                                                                            class="feather icon-activity mr-2"></i>Audit
                                                                                                        Log Details
                                                                                                        #${log.id}
                                                                                                    </h5>
                                                                                                    <button
                                                                                                        type="button"
                                                                                                        class="close text-white"
                                                                                                        data-dismiss="modal"
                                                                                                        aria-label="Close">
                                                                                                        <span
                                                                                                            aria-hidden="true">&times;</span>
                                                                                                    </button>
                                                                                                </div>
                                                                                                <div
                                                                                                    class="modal-body bg-light">
                                                                                                    <div class="row">
                                                                                                        <!-- Meta Info Card -->
                                                                                                        <div
                                                                                                            class="col-12 mb-3">
                                                                                                            <div
                                                                                                                class="card shadow-sm border-0">
                                                                                                                <div
                                                                                                                    class="card-body p-3 d-flex justify-content-between align-items-center">
                                                                                                                    <div>
                                                                                                                        <strong
                                                                                                                            class="text-muted">User:</strong>
                                                                                                                        <span
                                                                                                                            class="text-dark font-weight-bold ml-1">${log.userName}</span>
                                                                                                                    </div>
                                                                                                                    <div>
                                                                                                                        <strong
                                                                                                                            class="text-muted">Action:</strong>
                                                                                                                        <span
                                                                                                                            class="badge badge-primary ml-1">${log.action}</span>
                                                                                                                    </div>
                                                                                                                    <div>
                                                                                                                        <strong
                                                                                                                            class="text-muted">Screen:</strong>
                                                                                                                        <span
                                                                                                                            class="badge badge-info ml-1">${log.screen}</span>
                                                                                                                    </div>
                                                                                                                    <div>
                                                                                                                        <strong
                                                                                                                            class="text-muted">Time:</strong>
                                                                                                                        <span
                                                                                                                            class="text-dark ml-1">
                                                                                                                            <fmt:formatDate
                                                                                                                                value="${log.createdAt}"
                                                                                                                                pattern="yyyy-MM-dd HH:mm:ss" />
                                                                                                                        </span>
                                                                                                                    </div>
                                                                                                                </div>
                                                                                                            </div>
                                                                                                        </div>

                                                                                                        <!-- Data Before -->
                                                                                                        <div
                                                                                                            class="col-md-6">
                                                                                                            <div
                                                                                                                class="card border-top-0 border-right-0 border-bottom-0 border-left-danger shadow-sm h-100">
                                                                                                                <div
                                                                                                                    class="card-header bg-white border-bottom-0 pb-0">
                                                                                                                    <h6
                                                                                                                        class="text-danger font-weight-bold">
                                                                                                                        <i
                                                                                                                            class="feather icon-minus-circle mr-1"></i>Data
                                                                                                                        Before
                                                                                                                    </h6>
                                                                                                                </div>
                                                                                                                <div
                                                                                                                    class="card-body">
                                                                                                                    <pre class="json-data bg-white p-3 rounded border border-danger text-danger"
                                                                                                                        style="max-height: 400px; overflow: auto; white-space: pre-wrap; word-wrap: break-word; font-family: 'Consolas', 'Monaco', monospace; font-size: 0.9rem;">${log.dataBefore != null ? log.dataBefore : 'N/A'}</pre>
                                                                                                                </div>
                                                                                                            </div>
                                                                                                        </div>

                                                                                                        <!-- Data After -->
                                                                                                        <div
                                                                                                            class="col-md-6">
                                                                                                            <div
                                                                                                                class="card border-top-0 border-right-0 border-bottom-0 border-left-success shadow-sm h-100">
                                                                                                                <div
                                                                                                                    class="card-header bg-white border-bottom-0 pb-0">
                                                                                                                    <h6
                                                                                                                        class="text-success font-weight-bold">
                                                                                                                        <i
                                                                                                                            class="feather icon-plus-circle mr-1"></i>Data
                                                                                                                        After
                                                                                                                    </h6>
                                                                                                                </div>
                                                                                                                <div
                                                                                                                    class="card-body">
                                                                                                                    <pre class="json-data bg-white p-3 rounded border border-success text-success"
                                                                                                                        style="max-height: 400px; overflow: auto; white-space: pre-wrap; word-wrap: break-word; font-family: 'Consolas', 'Monaco', monospace; font-size: 0.9rem;">${log.dataAfter != null ? log.dataAfter : 'N/A'}</pre>
                                                                                                                </div>
                                                                                                            </div>
                                                                                                        </div>
                                                                                                    </div>
                                                                                                </div>
                                                                                                <div
                                                                                                    class="modal-footer bg-white">
                                                                                                    <button
                                                                                                        type="button"
                                                                                                        class="btn btn-outline-secondary"
                                                                                                        data-dismiss="modal">Close</button>
                                                                                                </div>
                                                                                            </div>
                                                                                        </div>
                                                                                    </div>
                                                                                </td>
                                                                            </tr>
                                                                        </c:forEach>
                                                                        <c:if test="${empty logs}">
                                                                            <tr>
                                                                                <td colspan="6" class="text-center">No
                                                                                    logs found.</td>
                                                                            </tr>
                                                                        </c:if>
                                                                    </tbody>
                                                                </table>
                                                            </div>

                                                            <!-- Pagination -->
                                                            <c:if test="${totalPages > 1}">
                                                                <nav aria-label="Page navigation">
                                                                    <ul class="pagination justify-content-end">
                                                                        <c:if test="${currentPage > 1}">
                                                                            <li class="page-item">
                                                                                <a class="page-link"
                                                                                    href="AuditLogs?page=${currentPage - 1}&user=${user}&action=${action}&from=${from}&to=${to}">Previous</a>
                                                                            </li>
                                                                        </c:if>
                                                                        <c:forEach begin="1" end="${totalPages}"
                                                                            var="i">
                                                                            <li
                                                                                class="page-item ${i == currentPage ? 'active' : ''}">
                                                                                <a class="page-link"
                                                                                    href="AuditLogs?page=${i}&user=${user}&action=${action}&from=${from}&to=${to}">${i}</a>
                                                                            </li>
                                                                        </c:forEach>
                                                                        <c:if test="${currentPage < totalPages}">
                                                                            <li class="page-item">
                                                                                <a class="page-link"
                                                                                    href="AuditLogs?page=${currentPage + 1}&user=${user}&action=${action}&from=${from}&to=${to}">Next</a>
                                                                            </li>
                                                                        </c:if>
                                                                    </ul>
                                                                </nav>
                                                            </c:if>
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

                    <script>
                        $(document).ready(function () {
                            // Function to try parsing and formatting JSON
                            function formatJSON() {
                                $('.json-data').each(function () {
                                    var text = $(this).text();
                                    try {
                                        if (text && text !== 'N/A') {
                                            var json = JSON.parse(text);
                                            var formatted = JSON.stringify(json, null, 4);
                                            $(this).text(formatted);
                                        }
                                    } catch (e) {
                                        // Not valid JSON, ignore
                                        console.log('Error parsing JSON for audit log', e);
                                    }
                                });
                            }

                            formatJSON();
                        });
                    </script>

                </body>

                </html>