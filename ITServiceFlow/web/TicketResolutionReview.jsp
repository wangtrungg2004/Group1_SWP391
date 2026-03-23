<%@ page contentType="text/html;charset=UTF-8" language="java" %>
    <%@ taglib uri="jakarta.tags.core" prefix="c" %>
        <!DOCTYPE html>
        <html lang="vi">

        <head>
            <meta charset="UTF-8">
            <title>Ticket Resolution Review</title>
            <meta name="viewport" content="width=device-width, initial-scale=1.0">
            <link rel="stylesheet" href="assets/css/style.css">
            <link rel="stylesheet" href="assets/css/pcoded.min.css">
            <link rel="stylesheet" href="assets/fonts/feather.css">
            <style>
                .badge-resolved {
                    background: #28a745;
                    color: #fff;
                    padding: 3px 10px;
                    border-radius: 12px;
                    font-size: .8rem;
                }

                .badge-other {
                    background: #6c757d;
                    color: #fff;
                    padding: 3px 10px;
                    border-radius: 12px;
                    font-size: .8rem;
                }

                .ticket-card {
                    transition: .2s;
                    cursor: pointer;
                }

                .ticket-card:hover {
                    box-shadow: 0 4px 15px rgba(0, 0, 0, .12);
                    transform: translateY(-2px);
                }
            </style>
        </head>

        <body>
            <div class="loader-bg">
                <div class="loader-track">
                    <div class="loader-fill"></div>
                </div>
            </div>
            <jsp:include page="/includes/sidebar.jsp" />

            <div class="pcoded-main-container">
                <div class="pcoded-content">
                    <div class="page-header">
                        <div class="page-block">
                            <div class="row align-items-center">
                                <div class="col-md-12">
                                    <div class="page-header-title">
                                        <h5 class="m-b-10">Ticket Resolution Review</h5>
                                    </div>
                                    <ul class="breadcrumb">
                                        <li class="breadcrumb-item"><a href="${pageContext.request.contextPath}/ITDashboard"><i
                                                    class="feather icon-home"></i></a></li>
                                        <li class="breadcrumb-item active">Resolution Review</li>
                                    </ul>
                                </div>
                            </div>
                        </div>
                    </div>

                    <div class="pcoded-inner-content">
                        <div class="main-body">
                            <div class="page-wrapper">
                                <div class="row">
                                    <div class="col-sm-12">

                                        <%-- MESSAGES --%>
                                            <c:if test="${not empty errorMessage}">
                                                <div class="alert alert-danger alert-dismissible fade show"
                                                    role="alert">
                                                    <i class="feather icon-alert-circle mr-1"></i> ${errorMessage}
                                                    <button type="button" class="close"
                                                        data-dismiss="alert"><span>&times;</span></button>
                                                </div>
                                            </c:if>
                                            <c:if test="${not empty successMessage}">
                                                <div class="alert alert-success alert-dismissible fade show"
                                                    role="alert">
                                                    <i class="feather icon-check-circle mr-1"></i> ${successMessage}
                                                    <button type="button" class="close"
                                                        data-dismiss="alert"><span>&times;</span></button>
                                                </div>
                                            </c:if>
                                            <c:if test="${not empty warningMessage}">
                                                <div class="alert alert-warning alert-dismissible fade show"
                                                    role="alert">
                                                    <i class="feather icon-alert-triangle mr-1"></i> ${warningMessage}
                                                    <button type="button" class="close"
                                                        data-dismiss="alert"><span>&times;</span></button>
                                                </div>
                                            </c:if>

                                            <%-- TICKET DETAIL VIEW --%>
                                                <c:if test="${not empty ticket}">
                                                    <div class="card mb-3">
                                                        <div
                                                            class="card-header d-flex justify-content-between align-items-center">
                                                            <h6 class="mb-0">
                                                                <i class="feather icon-info mr-1"></i>
                                                                Ticket: <strong>${ticket.ticketNumber}</strong>
                                                            </h6>
                                                            <a href="TicketResolutionReview"
                                                                class="btn btn-sm btn-outline-secondary">
                                                                <i class="feather icon-list mr-1"></i> Xem danh sách
                                                            </a>
                                                        </div>
                                                        <div class="card-body">
                                                            <div class="row">
                                                                <div class="col-md-6">
                                                                    <table class="table table-sm table-borderless">
                                                                        <tr>
                                                                            <th width="130">Ticket #</th>
                                                                            <td><strong>${ticket.ticketNumber}</strong>
                                                                            </td>
                                                                        </tr>
                                                                        <tr>
                                                                            <th>Loại</th>
                                                                            <td>${ticket.ticketType}</td>
                                                                        </tr>
                                                                        <tr>
                                                                            <th>Tiêu đề</th>
                                                                            <td>${ticket.title}</td>
                                                                        </tr>
                                                                        <tr>
                                                                            <th>Status</th>
                                                                            <td><span
                                                                                    class="${ticket.status == 'Resolved' ? 'badge-resolved' : 'badge-other'}">${ticket.status}</span>
                                                                            </td>
                                                                        </tr>
                                                                        <tr>
                                                                            <th>Impact</th>
                                                                            <td>
                                                                                <c:choose>
                                                                                    <c:when
                                                                                        test="${ticket.impact == 1}">Low
                                                                                    </c:when>
                                                                                    <c:when
                                                                                        test="${ticket.impact == 2}">
                                                                                        Medium</c:when>
                                                                                    <c:when
                                                                                        test="${ticket.impact == 3}">
                                                                                        High</c:when>
                                                                                    <c:otherwise>N/A</c:otherwise>
                                                                                </c:choose>
                                                                            </td>
                                                                        </tr>
                                                                        <tr>
                                                                            <th>Urgency</th>
                                                                            <td>
                                                                                <c:choose>
                                                                                    <c:when
                                                                                        test="${ticket.urgency == 1}">
                                                                                        Low</c:when>
                                                                                    <c:when
                                                                                        test="${ticket.urgency == 2}">
                                                                                        Medium</c:when>
                                                                                    <c:when
                                                                                        test="${ticket.urgency == 3}">
                                                                                        High</c:when>
                                                                                    <c:otherwise>N/A</c:otherwise>
                                                                                </c:choose>
                                                                            </td>
                                                                        </tr>
                                                                    </table>
                                                                </div>
                                                                <div class="col-md-6">
                                                                    <table class="table table-sm table-borderless">
                                                                        <tr>
                                                                            <th width="130">Category</th>
                                                                            <td>${ticket.categoryName}</td>
                                                                        </tr>
                                                                        <tr>
                                                                            <th>Location</th>
                                                                            <td>${ticket.locationName}</td>
                                                                        </tr>
                                                                        <tr>
                                                                            <th>Resolved At</th>
                                                                            <td>${ticket.resolvedAt}</td>
                                                                        </tr>
                                                                        <tr>
                                                                            <th>Created At</th>
                                                                            <td>${ticket.createdAt}</td>
                                                                        </tr>
                                                                    </table>
                                                                </div>
                                                            </div>
                                                            <hr>
                                                            <h6>Mô tả vấn đề:</h6>
                                                            <p class="text-muted" style="white-space:pre-wrap;">
                                                                ${ticket.description}</p>
                                                        </div>
                                                    </div>

                                                    <%-- Resolution Form --%>
                                                        <div class="card">
                                                            <div class="card-header">
                                                                <h6 class="mb-0"><i
                                                                        class="feather icon-edit-2 mr-1"></i> Chỉnh sửa
                                                                    Resolution</h6>
                                                            </div>
                                                            <div class="card-body">
                                                                <form action="TicketResolutionReview" method="POST">
                                                                    <input type="hidden" name="ticketId"
                                                                        value="${ticket.id}">
                                                                    <div class="form-group">
                                                                        <label><strong>Tiêu đề
                                                                                Resolution</strong></label>
                                                                        <input type="text" class="form-control"
                                                                            name="title" value="${ticket.title}"
                                                                            placeholder="Nhập tiêu đề resolution..."
                                                                            required>
                                                                    </div>
                                                                    <div class="form-group">
                                                                        <label><strong>Mô tả giải pháp</strong></label>
                                                                        <textarea class="form-control"
                                                                            name="description" rows="4"
                                                                            placeholder="Mô tả chi tiết giải pháp đã thực hiện...">${ticket.description}</textarea>
                                                                    </div>
                                                                    <div class="form-group">
                                                                        <label><strong>Các bước xử lý (Resolution
                                                                                Steps)</strong></label>
                                                                        <textarea class="form-control"
                                                                            name="resolutionSteps" rows="6"
                                                                            placeholder="Bước 1: ...&#10;Bước 2: ...&#10;Bước 3: ..."></textarea>
                                                                    </div>
                                                                    <div class="d-flex justify-content-between">
                                                                        <a href="TicketResolutionReview"
                                                                            class="btn btn-secondary">
                                                                            <i class="feather icon-arrow-left mr-1"></i>
                                                                            Quay lại
                                                                        </a>
                                                                        <button type="submit" class="btn btn-primary">
                                                                            <i class="feather icon-save mr-1"></i> Lưu
                                                                            Resolution
                                                                        </button>
                                                                    </div>
                                                                </form>
                                                            </div>
                                                        </div>
                                                </c:if>

                                                <%-- LIST VIEW --%>
                                                    <c:if test="${empty ticket}">
                                                        <div class="card">
                                                            <div class="card-header">
                                                                <h6 class="mb-0"><i class="feather icon-list mr-1"></i>
                                                                    Danh sách Resolved Tickets</h6>
                                                            </div>
                                                            <div class="card-body">
                                                                 <form action="TicketResolutionReview" method="GET" class="mb-4">
                                                                    <div class="row align-items-end">
                                                                        <div class="col-md-5">
                                                                            <div class="form-group mb-0">
                                                                                <label class="floating-label">Tìm kiếm</label>
                                                                                <input type="text" class="form-control" name="keyword" value="${keyword}" placeholder="TicketNumber hoặc Tiêu đề...">
                                                                            </div>
                                                                        </div>
                                                                        <div class="col-md-3">
                                                                            <div class="form-group mb-0">
                                                                                <label class="floating-label">Loại ticket</label>
                                                                                <select class="form-control" name="type">
                                                                                    <option value="All" ${type == 'All' || empty type ? 'selected' : ''}>Tất cả loại</option>
                                                                                    <option value="Incident" ${type == 'Incident' ? 'selected' : ''}>Incident</option>
                                                                                    <option value="Service Request" ${type == 'Service Request' ? 'selected' : ''}>Service Request</option>
                                                                                </select>
                                                                            </div>
                                                                        </div>
                                                                        <div class="col-md-4">
                                                                            <button type="submit" class="btn btn-primary">
                                                                                <i class="feather icon-search mr-1"></i> Lọc
                                                                            </button>
                                                                            <a href="TicketResolutionReview" class="btn btn-outline-secondary">
                                                                                <i class="feather icon-refresh-cw mr-1"></i> Reset
                                                                            </a>
                                                                        </div>
                                                                    </div>
                                                                </form>

                                                                <c:choose>
                                                                    <c:when test="${empty resolvedTickets}">
                                                                        <div class="text-center py-5 text-muted">
                                                                            <i class="feather icon-inbox"
                                                                                style="font-size:3rem;display:block;"></i>
                                                                            <p class="mt-2">
                                                                                Không có Resolved ticket nào
                                                                                <c:if test="${not empty keyword}">
                                                                                    khớp với
                                                                                    "<strong>${keyword}</strong>"
                                                                                </c:if>
                                                                            </p>
                                                                            <c:if test="${not empty keyword}">
                                                                                <a href="TicketResolutionReview"
                                                                                    class="btn btn-sm btn-outline-primary">Xem
                                                                                    tất cả</a>
                                                                            </c:if>
                                                                        </div>
                                                                    </c:when>
                                                                    <c:otherwise>
                                                                        <div class="table-responsive">
                                                                            <table class="table table-hover">
                                                                                <thead class="thead-light">
                                                                                    <tr>
                                                                                        <th>Ticket #</th>
                                                                                        <th>Loại</th>
                                                                                        <th>Category</th>
                                                                                        <th>Tiêu đề</th>
                                                                                        <th>Impact</th>
                                                                                        <th>Resolved At</th>
                                                                                        <th class="text-center">Thao tác</th>
                                                                                    </tr>
                                                                                </thead>
                                                                                <tbody>
                                                                                    <c:forEach var="t" items="${resolvedTickets}">
                                                                                        <tr class="ticket-card" onclick="window.location.href='TicketResolutionReview?ticketNumber=${t.ticketNumber}'">
                                                                                            <td><strong>${t.ticketNumber}</strong></td>
                                                                                            <td>${t.ticketType}</td>
                                                                                            <td>${t.categoryName}</td>
                                                                                            <td>${t.title}</td>
                                                                                            <td>
                                                                                                <c:choose>
                                                                                                    <c:when test="${t.impact == 1}"><span class="badge badge-success">Low</span></c:when>
                                                                                                    <c:when test="${t.impact == 2}"><span class="badge badge-warning">Medium</span></c:when>
                                                                                                    <c:when test="${t.impact == 3}"><span class="badge badge-danger">High</span></c:when>
                                                                                                    <c:otherwise><span class="badge badge-secondary">N/A</span></c:otherwise>
                                                                                                </c:choose>
                                                                                            </td>
                                                                                            <td>${t.resolvedAt}</td>
                                                                                            <td class="text-center">
                                                                                                <a href="TicketResolutionReview?ticketNumber=${t.ticketNumber}" class="btn btn-sm btn-primary" onclick="event.stopPropagation()">
                                                                                                    <i class="feather icon-edit-2"></i> Review
                                                                                                </a>
                                                                                            </td>
                                                                                        </tr>
                                                                                    </c:forEach>
                                                                                </tbody>
                                                                            </table>
                                                                        </div>
                                                                        <small class="text-muted">Tổng:
                                                                            ${resolvedTickets.size()} ticket(s)</small>
                                                                    </c:otherwise>
                                                                </c:choose>
                                                            </div>
                                                        </div>
                                                    </c:if>

                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>

            <script src="assets/js/vendor-all.min.js"></script>
            <script src="assets/js/plugins/bootstrap.min.js"></script>
            <script src="assets/js/pcoded.min.js"></script>
        </body>

        </html>