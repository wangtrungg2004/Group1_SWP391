<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<!DOCTYPE html>
<html lang="vi">

    <head>
        <meta charset="utf-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0, user-scalable=0, minimal-ui">
        <title>Ticket Resolution Review</title>
        <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/fonts/fontawesome/css/fontawesome-all.min.css">
        <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/plugins/animation/css/animate.min.css">
        <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/plugins/bootstrap/css/bootstrap.min.css">
        <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/style.css">
        <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/fonts/feather/css/feather.css">
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
        <div class="loader-bg"><div class="loader-track"><div class="loader-fill"></div></div></div>
        <jsp:include page="includes/sidebar.jsp" />
        <jsp:include page="includes/header.jsp" />

        <div class="pcoded-main-container">
            <div class="pcoded-content">
                <div class="page-header">
                    <div class="page-block">
                        <div class="row align-items-center">
                            <div class="col-md-12">
                                <div class="page-header-title">
                                    <h5 class="m-b-10">Ticket Resolution</h5>
                                </div>
                                <ul class="breadcrumb">
                                    <li class="breadcrumb-item"><a href="ITDashboard.jsp"><i
                                                class="feather icon-home"></i></a></li>
                                    <li class="breadcrumb-item active">Resolution </li>
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
                                                    <i class="feather icon-list mr-1"></i> List
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
                                                                <th>Type</th>
                                                                <td>${ticket.ticketType}</td>
                                                            </tr>
                                                            <tr>
                                                                <th>Title</th>
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
                                                <h6>Problem description:</h6>
                                                <p class="text-muted" style="white-space:pre-wrap;">
                                                    ${ticket.description}</p>
                                            </div>
                                        </div>

                                        <%-- Resolution Form --%>
                                        <div class="card">
                                            <div class="card-header">
                                                <h6 class="mb-0"><i
                                                        class="feather icon-edit-2 mr-1"></i> Edit
                                                    Resolution</h6>
                                            </div>
                                            <div class="card-body">
                                                <form action="TicketResolutionReview" method="POST">
                                                    <input type="hidden" name="ticketId"
                                                           value="${ticket.id}">
                                                    <div class="form-group">
                                                        <label><strong>Title
                                                                Resolution</strong></label>
                                                        <input type="text" class="form-control"
                                                               name="title" value="${ticket.title}"
                                                               placeholder="Enter title resolution..."
                                                               required>
                                                    </div>
                                                    <div class="form-group">
                                                        <label><strong>Description solution</strong></label>
                                                        <textarea class="form-control"
                                                                  name="description" rows="4"
                                                                  placeholder="Provide a detailed description of the implemented solution....">${ticket.description}</textarea>
                                                    </div>
                                                    <div class="form-group">
                                                        <label><strong>Resolution
                                                                Steps</strong></label>
                                                        <textarea class="form-control"
                                                                  name="resolutionSteps" rows="6"
                                                                  placeholder="Step 1: ...&#10;Step 2: ...&#10;Step 3: ..."></textarea>
                                                    </div>
                                                    <div class="d-flex justify-content-between">
                                                        <a href="TicketResolutionReview"
                                                           class="btn btn-secondary">
                                                            <i class="feather icon-arrow-left mr-1"></i>
                                                            Return
                                                        </a>
                                                        <button type="submit" class="btn btn-primary">
                                                            <i class="feather icon-save mr-1"></i> Save
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
                                                    List Resolved Tickets</h6>
                                            </div>
                                            <div class="card-body">
                                                <form action="TicketResolutionReview" method="GET"
                                                      class="mb-3">
                                                    <div class="input-group" style="max-width:420px;">
                                                        <input type="text" class="form-control"
                                                               name="keyword" value="${keyword}"
                                                               placeholder="Search across TicketNumber (VD: INC-...)">
                                                        <div class="input-group-append">
                                                            <button class="btn btn-primary"
                                                                    type="submit">
                                                                <i class="feather icon-search"></i>Search
                                                            </button>
                                                            <c:if test="${not empty keyword}">
                                                                <a href="TicketResolutionReview"
                                                                   class="btn btn-outline-secondary">
                                                                    <i class="feather icon-x"></i>
                                                                </a>
                                                            </c:if>
                                                        </div>
                                                    </div>
                                                </form>

                                                <c:choose>
                                                    <c:when test="${empty resolvedTickets}">
                                                        <div class="text-center py-5 text-muted">
                                                            <i class="feather icon-inbox"
                                                               style="font-size:3rem;display:block;"></i>
                                                            <p class="mt-2">
                                                                No Resolved tickets
                                                                <c:if test="${not empty keyword}">
                                                                    match
                                                                    "<strong>${keyword}</strong>"
                                                                </c:if>
                                                            </p>
                                                            <c:if test="${not empty keyword}">
                                                                <a href="TicketResolutionReview"
                                                                   class="btn btn-sm btn-outline-primary">View all</a>
                                                                </c:if>
                                                        </div>
                                                    </c:when>
                                                    <c:otherwise>
                                                        <div class="table-responsive">
                                                            <table class="table table-hover">
                                                                <thead class="thead-light">
                                                                    <tr>
                                                                        <th>Ticket Number</th>
                                                                        <th>Type</th>
                                                                        <th>Title</th>
                                                                        <th>Impact</th>
                                                                        <th>Resolved At</th>
                                                                        <th class="text-center">Action
                                                                        </th>
                                                                    </tr>
                                                                </thead>
                                                                <tbody>
                                                                    <c:forEach var="t"
                                                                               items="${resolvedTickets}">
                                                                        <tr class="ticket-card"
                                                                            onclick="location.href = 'TicketResolutionReview?ticketNumber=<c:out value="
                                                                                   ${t.ticketNumber}" />'">
                                                                            <td><strong>${t.ticketNumber}</strong>
                                                                            </td>
                                                                            <td>${t.ticketType}</td>
                                                                            <td>${t.title}</td>
                                                                            <td>
                                                                                <c:choose>
                                                                                    <c:when
                                                                                        test="${t.impact == 1}">
                                                                                        <span
                                                                                            class="badge badge-success">Low</span>
                                                                                    </c:when>
                                                                                    <c:when
                                                                                        test="${t.impact == 2}">
                                                                                        <span
                                                                                            class="badge badge-warning">Medium</span>
                                                                                    </c:when>
                                                                                    <c:when
                                                                                        test="${t.impact == 3}">
                                                                                        <span
                                                                                            class="badge badge-danger">High</span>
                                                                                    </c:when>
                                                                                    <c:otherwise><span
                                                                                            class="badge badge-secondary">N/A</span>
                                                                                    </c:otherwise>
                                                                                </c:choose>
                                                                            </td>
                                                                            <td>${t.resolvedAt}</td>
                                                                            <td class="text-center">
                                                                                <a href="TicketResolutionReview?ticketNumber=<c:out value="
                                                                                       ${t.ticketNumber}" />"
                                                                                   class="btn btn-sm
                                                                                   btn-primary"
                                                                                   onclick="event.stopPropagation()">
                                                                                    <i
                                                                                        class="feather icon-edit-2"></i>
                                                                                    Review
                                                                                </a>
                                                                            </td>
                                                                        </tr>
                                                                    </c:forEach>
                                                                </tbody>
                                                            </table>
                                                        </div>
                                                       
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

        <script src="${pageContext.request.contextPath}/assets/plugins/jquery/js/jquery.min.js"></script>
        <script src="${pageContext.request.contextPath}/assets/js/vendor-all.min.js"></script>
        <script src="${pageContext.request.contextPath}/assets/plugins/bootstrap/js/bootstrap.min.js"></script>
        <script src="${pageContext.request.contextPath}/assets/js/pcoded.min.js"></script>
    </body>

</html>