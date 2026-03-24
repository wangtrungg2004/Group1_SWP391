<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<%@ taglib uri="jakarta.tags.fmt" prefix="fmt" %>
<%  if (session.getAttribute("user") == null) {
        response.sendRedirect(request.getContextPath() + "/Login.jsp"); return;
    } %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Duyệt RFC - ITServiceFlow</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/fonts/fontawesome/css/fontawesome-all.min.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/plugins/bootstrap/css/bootstrap.min.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/style.css">
    <style>
        body { background: #f4f5f7; }

        /* ── Tabs ── */
        .pg-tabs { display:flex; gap:0; border-bottom:2px solid #dfe1e6; margin-bottom:20px; }
        .pg-tab  { padding:10px 20px; font-size:.875rem; font-weight:600; color:#6b778c;
                   text-decoration:none; border-bottom:2px solid transparent; margin-bottom:-2px; transition:color .15s; }
        .pg-tab:hover  { color:#172b4d; text-decoration:none; }
        .pg-tab.active { color:#0052cc; border-bottom-color:#0052cc; }
        .cnt-badge { display:inline-flex; align-items:center; justify-content:center;
                     background:#de350b; color:#fff; border-radius:10px;
                     font-size:.7rem; font-weight:700; padding:1px 7px; margin-left:6px; }

        /* ── Table ── */
        .rfc-tbl { width:100%; border-collapse:separate; border-spacing:0;
                   border:1px solid #dfe1e6; border-radius:7px; overflow:hidden; }
        .rfc-tbl thead { background:#f8f9fa; }
        .rfc-tbl th { padding:11px 16px; font-size:.72rem; font-weight:700; color:#6b778c;
                      text-transform:uppercase; letter-spacing:.5px; border-bottom:1px solid #dfe1e6; }
        .rfc-tbl td { padding:14px 16px; vertical-align:middle; background:#fff;
                      border-bottom:1px solid #f4f5f7; }
        .rfc-tbl tbody tr:last-child td { border-bottom:none; }
        .rfc-tbl tbody tr:hover td { background:#fafbfc; }

        /* ── RFC number link ── */
        .rfc-link { font-weight:700; color:#0052cc; font-size:.875rem; text-decoration:none; }
        .rfc-link:hover { text-decoration:underline; color:#003d99; }

        /* ── Badges ── */
        .b { display:inline-flex; align-items:center; padding:3px 10px; border-radius:20px;
             font-size:.72rem; font-weight:700; white-space:nowrap; }
        .b-pending  { background:#fff0b3; color:#ff8b00; }
        .b-approved { background:#e3fcef; color:#00875a; }
        .b-rejected { background:#ffebe6; color:#bf2600; }
        .b-draft    { background:#ebecf0; color:#42526e; }
        .b-progress { background:#e9f2ff; color:#0052cc; }

        .risk { display:inline-flex; align-items:center; padding:3px 10px; border-radius:20px;
                font-size:.72rem; font-weight:700; }
        .r-Low      { background:#e3fcef; color:#00875a; }
        .r-Medium   { background:#fff0b3; color:#ff8b00; }
        .r-High     { background:#ffebe6; color:#bf2600; }
        .r-Critical { background:#ffebe6; color:#bf2600; border:1px solid #de350b; }

        /* ── Avatar ── */
        .av { width:30px; height:30px; border-radius:50%; background:#0052cc; color:#fff;
              display:inline-flex; align-items:center; justify-content:center;
              font-size:.7rem; font-weight:700; flex-shrink:0; }

        /* ── Action buttons ── */
        .btn-view { background:#f4f5f7; color:#42526e; border:1px solid #dfe1e6;
                    border-radius:5px; padding:6px 14px; font-size:.8rem; font-weight:600;
                    cursor:pointer; text-decoration:none; display:inline-flex; align-items:center; gap:5px; }
        .btn-view:hover { background:#ebecf0; color:#172b4d; text-decoration:none; }
        .btn-review { background:#0052cc; color:#fff; border:none;
                      border-radius:5px; padding:6px 14px; font-size:.8rem; font-weight:600;
                      cursor:pointer; text-decoration:none; display:inline-flex; align-items:center; gap:5px; }
        .btn-review:hover { background:#003d99; color:#fff; text-decoration:none; }


        /* ── Search bar ── */
        .search-bar { display:flex; gap:10px; align-items:center; margin-bottom:16px; flex-wrap:wrap; }
        .search-bar input[type=text] {
            flex:1; min-width:200px; height:38px; border:1px solid #dfe1e6;
            border-radius:5px; padding:0 12px; font-size:.875rem; color:#172b4d;
            background:#fff; outline:none; transition:border-color .15s;
        }
        .search-bar input[type=text]:focus { border-color:#4c9aff; box-shadow:0 0 0 2px rgba(76,154,255,.2); }
        .btn-search {
            height:38px; padding:0 18px; border:none; border-radius:5px;
            background:#0052cc; color:#fff; font-size:.875rem; font-weight:600;
            cursor:pointer; display:inline-flex; align-items:center; gap:6px; transition:background .15s;
        }
        .btn-search:hover { background:#003d99; }
        .btn-reset {
            height:38px; padding:0 14px; border:1px solid #dfe1e6; border-radius:5px;
            background:#fff; color:#42526e; font-size:.875rem; font-weight:600;
            cursor:pointer; text-decoration:none; display:inline-flex; align-items:center; gap:6px;
        }
        .btn-reset:hover { background:#f4f5f7; text-decoration:none; color:#172b4d; }
        .search-result-info { font-size:.8rem; color:#6b778c; align-self:center; }
        /* ── Empty ── */
        .empty { text-align:center; padding:60px 20px; color:#6b778c; }
        .empty-icon { font-size:3rem; color:#dfe1e6; display:block; margin-bottom:14px; }

        /* ── Risk icon ── */
        .risk-dot { width:8px; height:8px; border-radius:50%; display:inline-block; margin-right:5px; }
        .rd-Low      { background:#00875a; }
        .rd-Medium   { background:#ff8b00; }
        .rd-High     { background:#de350b; }
        .rd-Critical { background:#de350b; }
    </style>
</head>
<body>
<jsp:include page="includes/header.jsp"/>
<jsp:include page="includes/sidebar.jsp"/>

<div class="pcoded-main-container">
  <div class="pcoded-wrapper"><div class="pcoded-content"><div class="pcoded-inner-content">

    <!-- Breadcrumb -->
    <div class="page-header mb-3">
      <div class="page-block">
        <ul class="breadcrumb bg-transparent p-0 m-0">
          <li class="breadcrumb-item">
            <a href="${pageContext.request.contextPath}/ManagerDashboard" class="text-primary">
              <i class="feather icon-home"></i>
            </a>
          </li>
          <li class="breadcrumb-item text-muted">Phê duyệt RFC</li>
        </ul>
      </div>
    </div>

    <!-- Alerts -->
    <c:if test="${not empty success}">
      <div class="alert alert-success alert-dismissible fade show rounded mb-3">
        <i class="feather icon-check-circle mr-2"></i>${success}
        <button type="button" class="close" data-dismiss="alert"><span>&times;</span></button>
      </div>
    </c:if>
    <c:if test="${not empty error}">
      <div class="alert alert-danger alert-dismissible fade show rounded mb-3">
        <i class="feather icon-alert-circle mr-2"></i>${error}
        <button type="button" class="close" data-dismiss="alert"><span>&times;</span></button>
      </div>
    </c:if>


    <!-- Search -->
    <form method="GET" action="${pageContext.request.contextPath}/ManagerChangeApprovals" class="search-bar">
        <input type="hidden" name="tab" value="${tab}"/>
        <input type="text" name="keyword" value="${keyword}"
               placeholder="Tìm theo tiêu đề, tên người đề xuất, số RFC…"/>
        <button type="submit" class="btn-search">
            <i class="feather icon-search"></i> Tìm kiếm
        </button>
        <c:if test="${not empty keyword}">
            <a href="${pageContext.request.contextPath}/ManagerChangeApprovals?tab=${tab}" class="btn-reset">
                <i class="feather icon-x"></i> Xóa
            </a>
            <span class="search-result-info">
                ${requests.size()} kết quả cho "<strong>${keyword}</strong>"
            </span>
        </c:if>
    </form>

    <!-- Tabs -->
    <div class="pg-tabs">
      <a href="${pageContext.request.contextPath}/ManagerChangeApprovals?tab=pending&keyword=${keyword}" class="pg-tab ${tab=='pending' || empty tab ? 'active':''}">
        Chờ phê duyệt
        <c:if test="${tab=='pending' && not empty requests}">
          <span class="cnt-badge">${requests.size()}</span>
        </c:if>
      </a>
      <a href="${pageContext.request.contextPath}/ManagerChangeApprovals?tab=all&keyword=${keyword}" class="pg-tab ${tab=='all' ? 'active':''}">Tất cả RFC</a>
    </div>

    <!-- Card -->
    <div class="card border-0" style="box-shadow:0 1px 4px rgba(9,30,66,.08);">
      <div class="card-body p-0">
        <c:choose>
          <c:when test="${empty requests}">
            <div class="empty">
              <i class="feather icon-inbox empty-icon"></i>
              <p class="font-weight-bold mb-1">
                <c:choose>
                  <c:when test="${tab=='pending'}">Không có RFC nào đang chờ phê duyệt</c:when>
                  <c:otherwise>Chưa có RFC nào trong hệ thống</c:otherwise>
                </c:choose>
              </p>
              <p class="text-muted" style="font-size:.875rem;">
                <c:if test="${tab=='pending'}">IT Support chưa gửi yêu cầu thay đổi nào.</c:if>
              </p>
            </div>
          </c:when>
          <c:otherwise>
            <div class="table-responsive">
              <table class="rfc-tbl">
                <thead>
                  <tr>
                    <th>RFC #</th>
                    <th>Thông tin thay đổi</th>
                    <th>Mức rủi ro</th>
                    <th>Người đề xuất</th>
                    <th>Thời gian triển khai</th>
                    <th>Trạng thái</th>
                    <th style="text-align:center;">Thao tác</th>
                  </tr>
                </thead>
                <tbody>
                  <c:forEach var="req" items="${requests}">
                    <tr>

                      <%-- RFC number --%>
                      <td>
                        <a href="${pageContext.request.contextPath}/ManagerChangeApprovals?action=view&id=${req.id}"
                           class="rfc-link">${req.rfcNumber}</a>
                        <br>
                        <small class="text-muted" style="font-size:.75rem;">
                          <fmt:formatDate value="${req.createdAt}" pattern="dd/MM/yyyy"/>
                        </small>
                      </td>

                      <%-- Title + type + linked ticket --%>
                      <td style="max-width:260px;">
                        <div style="font-weight:600;color:#172b4d;font-size:.9rem;margin-bottom:3px;">
                          <c:out value="${req.title}"/>
                        </div>
                        <span style="font-size:.75rem;background:#ebecf0;color:#42526e;
                                     padding:2px 7px;border-radius:3px;">${req.changeType}</span>
                        <c:if test="${not empty req.linkedTicketNumber}">
                          <span style="font-size:.75rem;color:#0052cc;margin-left:6px;">
                            <i class="feather icon-link-2" style="font-size:.7rem;"></i>
                            ${req.linkedTicketNumber}
                          </span>
                        </c:if>
                      </td>

                      <%-- Risk --%>
                      <td>
                        <span class="risk r-${req.riskLevel}">
                          <span class="risk-dot rd-${req.riskLevel}"></span>
                          ${req.riskLevel}
                        </span>
                      </td>

                      <%-- Creator --%>
                      <td>
                        <div class="d-flex align-items-center gap-2" style="gap:8px;">
                          <div class="av">
                            <c:choose>
                              <c:when test="${not empty req.createdByName}">
                                ${req.createdByName.length() >= 2 ? req.createdByName.substring(0,2).toUpperCase() : req.createdByName.toUpperCase()}
                              </c:when>
                              <c:otherwise>?</c:otherwise>
                            </c:choose>
                          </div>
                          <div>
                            <div style="font-weight:600;font-size:.85rem;color:#172b4d;">
                              ${not empty req.createdByName ? req.createdByName : 'Unknown'}
                            </div>
                            <div style="font-size:.75rem;color:#6b778c;">IT Support</div>
                          </div>
                        </div>
                      </td>

                      <%-- Timeline --%>
                      <td style="font-size:.82rem;color:#5e6c84;white-space:nowrap;">
                        <c:choose>
                          <c:when test="${req.plannedStart != null}">
                            <div><i class="feather icon-calendar mr-1" style="font-size:.75rem;"></i>
                              <fmt:formatDate value="${req.plannedStart}" pattern="dd/MM/yyyy"/>
                            </div>
                            <c:if test="${req.plannedEnd != null}">
                              <div style="color:#b3bac5;">→
                                <fmt:formatDate value="${req.plannedEnd}" pattern="dd/MM/yyyy"/>
                              </div>
                            </c:if>
                          </c:when>
                          <c:otherwise>
                            <span class="text-muted">Chưa xác định</span>
                          </c:otherwise>
                        </c:choose>
                      </td>

                      <%-- Status --%>
                      <td>
                        <c:choose>
                          <c:when test="${req.status=='Pending Approval'}">
                            <span class="b b-pending">
                              <i class="feather icon-clock mr-1" style="font-size:.7rem;"></i>Chờ duyệt
                            </span>
                          </c:when>
                          <c:when test="${req.status=='Approved'}">
                            <span class="b b-approved">
                              <i class="feather icon-check-circle mr-1" style="font-size:.7rem;"></i>Đã duyệt
                            </span>
                          </c:when>
                          <c:when test="${req.status=='Rejected'}">
                            <span class="b b-rejected">
                              <i class="feather icon-x-circle mr-1" style="font-size:.7rem;"></i>Từ chối
                            </span>
                          </c:when>
                          <c:when test="${req.status=='In Progress'}">
                            <span class="b b-progress">
                              <i class="feather icon-loader mr-1" style="font-size:.7rem;"></i>Đang thực hiện
                            </span>
                          </c:when>
                          <c:otherwise>
                            <span class="b b-draft">${req.status}</span>
                          </c:otherwise>
                        </c:choose>
                      </td>

                      <%-- Action --%>
                      <td style="text-align:center;">
                        <c:choose>
                          <c:when test="${req.status=='Pending Approval'}">
                            <a href="${pageContext.request.contextPath}/ManagerChangeApprovals?action=view&id=${req.id}"
                               class="btn-review">
                              <i class="feather icon-edit-2"></i> Xem xét & Duyệt
                            </a>
                          </c:when>
                          <c:otherwise>
                            <a href="${pageContext.request.contextPath}/ManagerChangeApprovals?action=view&id=${req.id}"
                               class="btn-view">
                              <i class="feather icon-eye"></i> Xem chi tiết
                            </a>
                          </c:otherwise>
                        </c:choose>
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

  </div></div></div>
</div>

<script src="${pageContext.request.contextPath}/assets/plugins/jquery/js/jquery.min.js"></script>
<script src="${pageContext.request.contextPath}/assets/js/vendor-all.min.js"></script>
<script src="${pageContext.request.contextPath}/assets/plugins/bootstrap/js/bootstrap.min.js"></script>
<script src="${pageContext.request.contextPath}/assets/js/pcoded.min.js"></script>
</body>
</html>
