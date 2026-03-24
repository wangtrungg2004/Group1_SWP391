<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<%@ taglib uri="jakarta.tags.fmt" prefix="fmt" %>
<%
    if (session.getAttribute("user") == null) {
        response.sendRedirect(request.getContextPath() + "/Login.jsp");
        return;
    }
%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>RFC của tôi - ITServiceFlow</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/fonts/fontawesome/css/fontawesome-all.min.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/plugins/bootstrap/css/bootstrap.min.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/style.css">
    <style>
        body { background-color: #f4f5f7; }

        /* KPI cards */
        .kpi-row { display: flex; gap: 16px; margin-bottom: 24px; flex-wrap: wrap; }
        .kpi-box {
            flex: 1; min-width: 130px;
            background: #fff; border: 1px solid #dfe1e6;
            border-radius: 7px; padding: 14px 18px;
            border-left: 4px solid #dfe1e6;
        }
        .kpi-box.kpi-pending  { border-left-color: #ff8b00; }
        .kpi-box.kpi-approved { border-left-color: #00875a; }
        .kpi-box.kpi-rejected { border-left-color: #de350b; }
        .kpi-box.kpi-draft    { border-left-color: #6b778c; }
        .kpi-box p { margin: 0; font-size: .75rem; font-weight: 700; color: #6b778c; text-transform: uppercase; letter-spacing: .4px; }
        .kpi-box h3 { margin: 4px 0 0; font-size: 1.6rem; font-weight: 700; color: #172b4d; }

        /* Tabs */
        .rfc-tabs { border-bottom: 2px solid #dfe1e6; margin-bottom: 20px; display: flex; gap: 4px; flex-wrap: wrap; }
        .rfc-tab {
            padding: 9px 18px; font-size: .85rem; font-weight: 600;
            color: #6b778c; border: none; background: none; cursor: pointer;
            border-bottom: 2px solid transparent; margin-bottom: -2px;
            text-decoration: none; transition: color .15s;
        }
        .rfc-tab:hover { color: #172b4d; }
        .rfc-tab.active { color: #0052cc; border-bottom-color: #0052cc; }

        /* Table */
        .rfc-table { width: 100%; border-collapse: separate; border-spacing: 0; border: 1px solid #dfe1e6; border-radius: 6px; overflow: hidden; }
        .rfc-table thead { background: #f4f5f7; }
        .rfc-table th { padding: 11px 14px; font-size: .75rem; font-weight: 700; color: #5e6c84; text-transform: uppercase; letter-spacing: .4px; border-bottom: 1px solid #dfe1e6; }
        .rfc-table td { padding: 13px 14px; vertical-align: middle; border-bottom: 1px solid #dfe1e6; color: #172b4d; background: #fff; }
        .rfc-table tr:last-child td { border-bottom: none; }
        .rfc-table tr:hover td { background: #fafbfc; }

        /* RFC number link */
        .rfc-num { font-weight: 700; color: #0052cc; font-size: .875rem; text-decoration: none; }
        .rfc-num:hover { text-decoration: underline; }

        /* Badges */
        .badge-rfc { display: inline-block; padding: 3px 9px; border-radius: 3px; font-size: .72rem; font-weight: 700; text-transform: uppercase; letter-spacing: .3px; }
        .b-draft    { background: #ebecf0; color: #42526e; }
        .b-pending  { background: #fff0b3; color: #ff8b00; }
        .b-approved { background: #e3fcef; color: #00875a; }
        .b-rejected { background: #ffebe6; color: #bf2600; }
        .b-progress { background: #e9f2ff; color: #0052cc; }
        .b-complete { background: #dfe1e6; color: #172b4d; }

        .badge-risk { display: inline-block; padding: 2px 7px; border-radius: 3px; font-size: .72rem; font-weight: 700; }
        .r-Low      { background:#e3fcef; color:#00875a; }
        .r-Medium   { background:#fff0b3; color:#ff8b00; }
        .r-High     { background:#ffebe6; color:#bf2600; }
        .r-Critical { background:#de350b; color:#fff; }

        /* Empty state */
        .empty-state { text-align: center; padding: 50px 20px; color: #6b778c; }
        .empty-state i { font-size: 3rem; color: #b3bac5; display: block; margin-bottom: 12px; }

        /* ── Search bar ── */
        .search-bar { display:flex; gap:10px; align-items:center; margin-bottom:16px; flex-wrap:wrap; }
        .search-bar input[type=text] {
            flex:1; min-width:200px; height:36px; border:1px solid #dfe1e6;
            border-radius:5px; padding:0 12px; font-size:.875rem; color:#172b4d; outline:none;
        }
        .search-bar input[type=text]:focus { border-color:#4c9aff; box-shadow:0 0 0 2px rgba(76,154,255,.2); }
        .btn-search {
            height:36px; padding:0 16px; border:none; border-radius:5px;
            background:#0052cc; color:#fff; font-size:.875rem; font-weight:600;
            cursor:pointer; display:inline-flex; align-items:center; gap:5px;
        }
        .btn-search:hover { background:#003d99; }
        .btn-reset {
            height:36px; padding:0 12px; border:1px solid #dfe1e6; border-radius:5px;
            background:#fff; color:#42526e; font-size:.875rem; font-weight:600;
            cursor:pointer; text-decoration:none; display:inline-flex; align-items:center; gap:5px;
        }
        .btn-reset:hover { background:#f4f5f7; text-decoration:none; }
        .search-result-info { font-size:.78rem; color:#6b778c; align-self:center; }
    </style>
</head>
<body>
    <jsp:include page="includes/header.jsp"/>
    <jsp:include page="includes/sidebar.jsp"/>

    <div class="pcoded-main-container">
        <div class="pcoded-wrapper">
            <div class="pcoded-content">
                <div class="pcoded-inner-content">

                    <!-- Breadcrumb + action button -->
                    <div class="page-header mb-3">
                        <div class="page-block">
                            <div class="row align-items-center">
                                <div class="col">
                                    <ul class="breadcrumb bg-transparent p-0 m-0">
                                        <li class="breadcrumb-item">
                                            <a href="${pageContext.request.contextPath}/ITDashboard" class="text-primary">
                                                <i class="feather icon-home"></i>
                                            </a>
                                        </li>
                                        <li class="breadcrumb-item text-muted">Change Requests của tôi</li>
                                    </ul>
                                </div>
                                <div class="col-auto">
                                    <a href="${pageContext.request.contextPath}/SubmitChangeRequest"
                                       class="btn btn-primary btn-sm font-weight-bold">
                                        <i class="feather icon-plus mr-1"></i>Tạo RFC mới
                                    </a>
                                </div>
                            </div>
                        </div>
                    </div>

                    <!-- Flash messages -->
                    <c:if test="${not empty success}">
                        <div class="alert alert-success alert-dismissible fade show rounded d-flex align-items-center mb-3">
                            <i class="feather icon-check-circle mr-2"></i>${success}
                            <button type="button" class="close ml-auto" data-dismiss="alert"><span>&times;</span></button>
                        </div>
                    </c:if>
                    <c:if test="${not empty error}">
                        <div class="alert alert-danger alert-dismissible fade show rounded d-flex align-items-center mb-3">
                            <i class="feather icon-alert-circle mr-2"></i>${error}
                            <button type="button" class="close ml-auto" data-dismiss="alert"><span>&times;</span></button>
                        </div>
                    </c:if>

                    <!-- KPI Row -->
                    <div class="kpi-row">
                        <div class="kpi-box kpi-draft">
                            <p>Nháp</p>
                            <h3><c:set var="draftCount" value="0"/>
                                <c:forEach var="r" items="${requests}"><c:if test="${r.status=='Draft'}"><c:set var="draftCount" value="${draftCount+1}"/></c:if></c:forEach>
                                ${draftCount}</h3>
                        </div>
                        <div class="kpi-box kpi-pending">
                            <p>Chờ duyệt</p>
                            <h3><c:set var="pendCount" value="0"/>
                                <c:forEach var="r" items="${requests}"><c:if test="${r.status=='Pending Approval'}"><c:set var="pendCount" value="${pendCount+1}"/></c:if></c:forEach>
                                ${pendCount}</h3>
                        </div>
                        <div class="kpi-box kpi-approved">
                            <p>Đã duyệt</p>
                            <h3><c:set var="appCount" value="0"/>
                                <c:forEach var="r" items="${requests}"><c:if test="${r.status=='Approved'}"><c:set var="appCount" value="${appCount+1}"/></c:if></c:forEach>
                                ${appCount}</h3>
                        </div>
                        <div class="kpi-box kpi-rejected">
                            <p>Từ chối</p>
                            <h3><c:set var="rejCount" value="0"/>
                                <c:forEach var="r" items="${requests}"><c:if test="${r.status=='Rejected'}"><c:set var="rejCount" value="${rejCount+1}"/></c:if></c:forEach>
                                ${rejCount}</h3>
                        </div>
                    </div>

                    <!-- Tabs -->
                    <div class="rfc-tabs">
                        <a href="${pageContext.request.contextPath}/MyChangeRequests?tab=all&keyword=${keyword}"              class="rfc-tab ${tab=='all'              ? 'active':''}">Tất cả</a>
                        <a href="${pageContext.request.contextPath}/MyChangeRequests?tab=Draft&keyword=${keyword}"            class="rfc-tab ${tab=='Draft'            ? 'active':''}">Nháp</a>
                        <a href="${pageContext.request.contextPath}/MyChangeRequests?tab=Pending Approval&keyword=${keyword}" class="rfc-tab ${tab=='Pending Approval' ? 'active':''}">Chờ duyệt</a>
                        <a href="${pageContext.request.contextPath}/MyChangeRequests?tab=Approved&keyword=${keyword}"         class="rfc-tab ${tab=='Approved'         ? 'active':''}">Đã duyệt</a>
                        <a href="${pageContext.request.contextPath}/MyChangeRequests?tab=Rejected&keyword=${keyword}"         class="rfc-tab ${tab=='Rejected'         ? 'active':''}">Từ chối</a>
                        <a href="${pageContext.request.contextPath}/MyChangeRequests?tab=In Progress&keyword=${keyword}"      class="rfc-tab ${tab=='In Progress'      ? 'active':''}">Đang thực hiện</a>
                    </div>

                    <!-- Table card -->
                    <div class="card border-0" style="box-shadow:0 1px 3px rgba(9,30,66,.06);">
                        <div class="card-body p-0">
                            <c:choose>
                                <c:when test="${empty requests}">
                                    <div class="empty-state">
                                        <i class="feather icon-file-text"></i>
                                        <p class="font-weight-bold">Không có RFC nào</p>
                                        <a href="${pageContext.request.contextPath}/SubmitChangeRequest"
                                           class="btn btn-primary btn-sm mt-2">
                                            <i class="feather icon-plus mr-1"></i>Tạo RFC đầu tiên
                                        </a>
                                    </div>
                                </c:when>
                                <c:otherwise>
                                    <div class="table-responsive">
                                        <table class="rfc-table">
                                            <thead>
                                                <tr>
                                                    <th>RFC #</th>
                                                    <th>Tiêu đề</th>
                                                    <th>Loại</th>
                                                    <th>Rủi ro</th>
                                                    <th>Liên kết ticket</th>
                                                    <th>Ngày tạo</th>
                                                    <th>Trạng thái</th>
                                                    <th>Hành động</th>
                                                </tr>
                                            </thead>
                                            <tbody>
                                                <c:forEach var="req" items="${requests}">
                                                    <tr>
                                                        <td>
                                                            <a href="#" class="rfc-num"
                                                               data-toggle="modal"
                                                               data-target="#modal${req.id}">
                                                                ${req.ticketNumber}
                                                            </a>
                                                        </td>
                                                        <td style="max-width:240px;">
                                                            <span style="font-weight:600;color:#172b4d;">
                                                                <c:out value="${req.title}"/>
                                                            </span>
                                                            <br>
                                                            <small class="text-muted">${req.changeType}</small>
                                                        </td>
                                                        <td>
                                                            <span style="font-size:.8rem;background:#ebecf0;color:#42526e;padding:2px 7px;border-radius:3px;">
                                                                ${req.changeType}
                                                            </span>
                                                        </td>
                                                        <td>
                                                            <span class="badge-risk r-${req.riskLevel}">${req.riskLevel}</span>
                                                        </td>
                                                        <td>
                                                            <c:choose>
                                                                <c:when test="${not empty req.linkedTicketNumber}">
                                                                    <span style="font-size:.8rem;color:#0052cc;font-weight:600;">
                                                                        ${req.linkedTicketNumber}
                                                                    </span>
                                                                </c:when>
                                                                <c:otherwise>
                                                                    <span class="text-muted" style="font-size:.8rem;">—</span>
                                                                </c:otherwise>
                                                            </c:choose>
                                                        </td>
                                                        <td style="font-size:.82rem;color:#5e6c84;white-space:nowrap;">
                                                            <fmt:formatDate value="${req.createdAt}" pattern="dd/MM/yyyy"/>
                                                        </td>
                                                        <td>
                                                            <c:choose>
                                                                <c:when test="${req.status=='Draft'}">           <span class="badge-rfc b-draft">Draft</span></c:when>
                                                                <c:when test="${req.status=='Pending Approval'}"><span class="badge-rfc b-pending">Chờ duyệt</span></c:when>
                                                                <c:when test="${req.status=='Approved'}">        <span class="badge-rfc b-approved">Đã duyệt</span></c:when>
                                                                <c:when test="${req.status=='Rejected'}">        <span class="badge-rfc b-rejected">Từ chối</span></c:when>
                                                                <c:when test="${req.status=='In Progress'}">     <span class="badge-rfc b-progress">Đang thực hiện</span></c:when>
                                                                <c:otherwise>                                    <span class="badge-rfc b-complete">${req.status}</span></c:otherwise>
                                                            </c:choose>
                                                        </td>
                                                        <td>
                                                            <!-- Nút Submit nháp nếu là Draft -->
                                                            <c:if test="${req.status=='Draft'}">
                                                                <form action="${pageContext.request.contextPath}/MyChangeRequests"
                                                                      method="post" class="d-inline"
                                                                      onsubmit="return confirm('Gửi RFC này tới Manager để duyệt?')">
                                                                    <input type="hidden" name="action" value="submitDraft">
                                                                    <input type="hidden" name="id" value="${req.id}">
                                                                    <button type="submit" class="btn btn-sm btn-primary font-weight-bold"
                                                                            style="font-size:.78rem;padding:4px 10px;">
                                                                        <i class="feather icon-send mr-1"></i>Gửi duyệt
                                                                    </button>
                                                                </form>
                                                            </c:if>
                                                            <!-- Xem chi tiết (tất cả trạng thái) -->
                                                            <button class="btn btn-sm btn-outline-secondary ml-1"
                                                                    style="font-size:.78rem;padding:4px 10px;"
                                                                    data-toggle="modal" data-target="#modal${req.id}">
                                                                <i class="feather icon-eye"></i>
                                                            </button>
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

                    <%-- ═══ MODALS CHI TIẾT ═══ --%>
                    <c:forEach var="req" items="${requests}">
                        <div class="modal fade" id="modal${req.id}" tabindex="-1" role="dialog">
                            <div class="modal-dialog modal-lg" role="document">
                                <div class="modal-content">
                                    <div class="modal-header" style="background:#f4f5f7;border-bottom:1px solid #dfe1e6;">
                                        <div>
                                            <h5 class="modal-title mb-0" style="color:#172b4d;font-weight:700;">
                                                ${req.ticketNumber}
                                            </h5>
                                            <small class="text-muted"><c:out value="${req.title}"/></small>
                                        </div>
                                        <button type="button" class="close" data-dismiss="modal"><span>&times;</span></button>
                                    </div>
                                    <div class="modal-body p-4">
                                        <div class="row mb-3">
                                            <div class="col-sm-6">
                                                <p class="mb-1" style="font-size:.75rem;font-weight:700;color:#6b778c;text-transform:uppercase;">Loại thay đổi</p>
                                                <p class="mb-0">${req.changeType}</p>
                                            </div>
                                            <div class="col-sm-3">
                                                <p class="mb-1" style="font-size:.75rem;font-weight:700;color:#6b778c;text-transform:uppercase;">Rủi ro</p>
                                                <span class="badge-risk r-${req.riskLevel}">${req.riskLevel}</span>
                                            </div>
                                            <div class="col-sm-3">
                                                <p class="mb-1" style="font-size:.75rem;font-weight:700;color:#6b778c;text-transform:uppercase;">Trạng thái</p>
                                                <c:choose>
                                                    <c:when test="${req.status=='Draft'}">           <span class="badge-rfc b-draft">Draft</span></c:when>
                                                    <c:when test="${req.status=='Pending Approval'}"><span class="badge-rfc b-pending">Chờ duyệt</span></c:when>
                                                    <c:when test="${req.status=='Approved'}">        <span class="badge-rfc b-approved">Đã duyệt ✓</span></c:when>
                                                    <c:when test="${req.status=='Rejected'}">        <span class="badge-rfc b-rejected">Từ chối ✗</span></c:when>
                                                    <c:otherwise>                                    <span class="badge-rfc b-progress">${req.status}</span></c:otherwise>
                                                </c:choose>
                                            </div>
                                        </div>

                                        <c:if test="${not empty req.linkedTicketNumber}">
                                            <div class="mb-3 p-2" style="background:#e9f2ff;border-radius:5px;font-size:.85rem;">
                                                <i class="feather icon-link-2 mr-1 text-primary"></i>
                                                Liên kết ticket: <strong class="text-primary">${req.linkedTicketNumber}</strong>
                                                — <c:out value="${req.linkedTicketTitle}"/>
                                            </div>
                                        </c:if>

                                        <c:if test="${not empty req.description}">
                                            <p style="font-size:.75rem;font-weight:700;color:#6b778c;text-transform:uppercase;margin-bottom:5px;">Mô tả</p>
                                            <div style="background:#fafbfc;border:1px solid #ebecf0;border-radius:5px;padding:12px;font-size:.875rem;margin-bottom:14px;white-space:pre-wrap;">
                                                <c:out value="${req.description}"/>
                                            </div>
                                        </c:if>

                                        <p style="font-size:.75rem;font-weight:700;color:#6b778c;text-transform:uppercase;margin-bottom:5px;">Kế hoạch rollback</p>
                                        <div style="background:#fffae6;border:1px solid #f6c90e;border-radius:5px;padding:12px;font-size:.875rem;margin-bottom:14px;white-space:pre-wrap;">
                                            <c:out value="${req.rollbackPlan}"/>
                                        </div>

                                        <c:if test="${req.plannedStart != null || req.plannedEnd != null}">
                                            <div class="row mb-3">
                                                <div class="col-sm-6">
                                                    <p style="font-size:.75rem;font-weight:700;color:#6b778c;text-transform:uppercase;margin-bottom:3px;">Ngày bắt đầu</p>
                                                    <fmt:formatDate value="${req.plannedStart}" pattern="dd/MM/yyyy"/>
                                                </div>
                                                <div class="col-sm-6">
                                                    <p style="font-size:.75rem;font-weight:700;color:#6b778c;text-transform:uppercase;margin-bottom:3px;">Ngày kết thúc</p>
                                                    <fmt:formatDate value="${req.plannedEnd}" pattern="dd/MM/yyyy"/>
                                                </div>
                                            </div>
                                        </c:if>

                                        <!-- Kết quả duyệt nếu đã có -->
                                        <c:if test="${req.status=='Approved' || req.status=='Rejected'}">
                                            <div style="background:${req.status=='Approved' ? '#e3fcef' : '#ffebe6'};border-radius:6px;padding:12px 14px;margin-top:8px;">
                                                <p class="mb-1 font-weight-bold" style="color:${req.status=='Approved' ? '#00875a' : '#bf2600'};font-size:.875rem;">
                                                    <i class="feather icon-${req.status=='Approved' ? 'check-circle' : 'x-circle'} mr-1"></i>
                                                    ${req.status=='Approved' ? 'Đã được duyệt' : 'Bị từ chối'}
                                                </p>
                                                <c:if test="${not empty req.approverComment}">
                                                    <p class="mb-0 text-muted" style="font-size:.82rem;">
                                                        Nhận xét: <c:out value="${req.approverComment}"/>
                                                    </p>
                                                </c:if>
                                            </div>
                                        </c:if>
                                    </div>
                                    <div class="modal-footer" style="background:#f4f5f7;">
                                        <button type="button" class="btn btn-secondary btn-sm" data-dismiss="modal">Đóng</button>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </c:forEach>

                </div>
            </div>
        </div>
    </div>

    <script src="${pageContext.request.contextPath}/assets/plugins/jquery/js/jquery.min.js"></script>
    <script src="${pageContext.request.contextPath}/assets/plugins/bootstrap/js/bootstrap.min.js"></script>
    <script src="${pageContext.request.contextPath}/assets/js/vendor-all.min.js"></script>
    <script src="${pageContext.request.contextPath}/assets/js/pcoded.min.js"></script>
</body>
</html>
