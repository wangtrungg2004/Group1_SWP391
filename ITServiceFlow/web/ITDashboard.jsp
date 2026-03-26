<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<%@ taglib uri="jakarta.tags.fmt" prefix="fmt" %>
<%
    if (session.getAttribute("user") == null) {
        response.sendRedirect(request.getContextPath() + "/Login.jsp");
        return;
    }
    model.Users user = (model.Users) session.getAttribute("user");
    String role = (String) session.getAttribute("role");
    if (!"IT Support".equals(role)) {
        response.sendRedirect(request.getContextPath() + "/Login.jsp");
        return;
    }
%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0, user-scalable=0, minimal-ui">
    <title>IT Support Dashboard - ITServiceFlow</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/fonts/fontawesome/css/fontawesome-all.min.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/plugins/animation/css/animate.min.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/plugins/bootstrap/css/bootstrap.min.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/style.css">
    <style>
        /* ── KPI cards ── */
        .kpi-card { border-radius:8px; padding:20px 22px; color:#fff; position:relative; overflow:hidden; }
        .kpi-card::after {
            content:''; position:absolute; right:-14px; top:-14px;
            width:80px; height:80px; border-radius:50%; background:rgba(255,255,255,0.1);
        }
        .kpi-card .kpi-val { font-size:2rem; font-weight:700; line-height:1; }
        .kpi-card .kpi-lbl { font-size:0.78rem; font-weight:600; opacity:0.85; text-transform:uppercase; letter-spacing:0.5px; margin-top:6px; }
        .kpi-card .kpi-ico { font-size:2.2rem; opacity:0.3; position:absolute; right:18px; bottom:14px; }
        .bg-kpi-new      { background:linear-gradient(135deg,#4CAF50,#2E7D32); }
        .bg-kpi-wip      { background:linear-gradient(135deg,#2196F3,#1565C0); }
        .bg-kpi-done     { background:linear-gradient(135deg,#00BCD4,#00838F); }
        .bg-kpi-sla      { background:linear-gradient(135deg,#FF9800,#E65100); }
        .bg-kpi-sla.breach { background:linear-gradient(135deg,#f44336,#b71c1c); }

        /* ── Table ── */
        .dash-table { width:100%; border-collapse:separate; border-spacing:0; }
        .dash-table th {
            background:#f8f9fa; font-size:0.72rem; text-transform:uppercase;
            letter-spacing:0.4px; color:#6b778c; font-weight:700;
            padding:10px 14px; border-bottom:1px solid #e9ecef;
        }
        .dash-table td { padding:10px 14px; vertical-align:middle; border-bottom:1px solid #f4f5f7; font-size:0.85rem; }
        .dash-table tbody tr:last-child td { border-bottom:none; }
        .dash-table tbody tr:hover td { background:#fafbfc; }

        /* ── Quick links ── */
        .quick-link {
            display:flex; align-items:center; gap:12px; padding:12px 16px;
            border:1px solid #e9ecef; border-radius:7px; text-decoration:none;
            color:#172b4d; transition:all .15s; margin-bottom:10px;
        }
        .quick-link:hover { background:#f4f5f7; border-color:#c1c7d0; text-decoration:none; color:#172b4d; }
        .quick-link .ql-icon { width:36px; height:36px; border-radius:7px; display:flex; align-items:center; justify-content:center; font-size:1.1rem; flex-shrink:0; }
        .quick-link .ql-label { font-size:0.88rem; font-weight:600; }
        .quick-link .ql-count { margin-left:auto; font-size:1rem; font-weight:700; }

        /* ── Empty state ── */
        .empty-state { text-align:center; padding:40px 20px; color:#6b778c; }
        .empty-state i { font-size:2.5rem; opacity:0.25; display:block; margin-bottom:10px; }
    </style>
</head>
<body>
    <div class="loader-bg"><div class="loader-track"><div class="loader-fill"></div></div></div>
    <jsp:include page="includes/sidebar.jsp"/>
    <jsp:include page="includes/header.jsp"/>

    <div class="pcoded-main-container">
      <div class="pcoded-wrapper"><div class="pcoded-content"><div class="pcoded-inner-content">

        <!-- Breadcrumb -->
        <div class="page-header mb-3">
          <div class="page-block">
            <ul class="breadcrumb bg-transparent p-0 m-0">
              <li class="breadcrumb-item"><a href="${pageContext.request.contextPath}/ITDashboard"><i class="feather icon-home"></i></a></li>
              <li class="breadcrumb-item text-muted">Dashboard</li>
            </ul>
          </div>
        </div>

        <!-- KPI Row -->
        <div class="row mb-3">
          <div class="col-md-6 col-xl-3 mb-3">
            <div class="kpi-card bg-kpi-new">
              <div class="kpi-val">${agentKPIs.myNew}</div>
              <div class="kpi-lbl">Tickets mới</div>
              <i class="feather icon-file-plus kpi-ico"></i>
            </div>
          </div>
          <div class="col-md-6 col-xl-3 mb-3">
            <div class="kpi-card bg-kpi-wip">
              <div class="kpi-val">${agentKPIs.myInProgress}</div>
              <div class="kpi-lbl">Đang xử lý</div>
              <i class="feather icon-clock kpi-ico"></i>
            </div>
          </div>
          <div class="col-md-6 col-xl-3 mb-3">
            <div class="kpi-card bg-kpi-done">
              <div class="kpi-val">${agentKPIs.myResolved}</div>
              <div class="kpi-lbl">Đã giải quyết (7 ngày)</div>
              <i class="feather icon-check-circle kpi-ico"></i>
            </div>
          </div>
          <div class="col-md-6 col-xl-3 mb-3">
            <div class="kpi-card bg-kpi-sla ${agentKPIs.slaBreaching > 0 ? 'breach' : ''}">
              <div class="kpi-val">${agentKPIs.slaBreaching}</div>
              <div class="kpi-lbl">Sắp breach SLA</div>
              <i class="feather icon-alert-triangle kpi-ico"></i>
            </div>
          </div>
        </div>

        <!-- Main area -->
        <div class="row">
          <!-- Recent tickets table -->
          <div class="col-xl-8 mb-3">
            <div class="card border-0 shadow-sm h-100">
              <div class="card-header d-flex justify-content-between align-items-center py-3">
                <h5 class="mb-0"><i class="feather icon-list mr-2 text-primary"></i>Tickets đang xử lý</h5>
                <a href="${pageContext.request.contextPath}/Queues" class="btn btn-sm btn-outline-primary font-weight-bold">
                  Xem tất cả <i class="feather icon-arrow-right ml-1"></i>
                </a>
              </div>
              <div class="card-body p-0">
                <c:choose>
                  <c:when test="${not empty recentTickets}">
                    <div class="table-responsive">
                      <table class="dash-table">
                        <thead>
                          <tr>
                            <th class="pl-3">Ticket #</th>
                            <th>Tiêu đề</th>
                            <th>Loại</th>
                            <th>Trạng thái</th>
                          </tr>
                        </thead>
                        <tbody>
                          <c:forEach var="t" items="${recentTickets}">
                            <tr>
                              <td class="pl-3">
                                <a href="${pageContext.request.contextPath}/TicketAgentDetail?id=${t.id}"
                                   style="font-weight:700; color:#0052cc; font-size:0.83rem;">${t.ticketNumber}</a>
                              </td>
                              <td style="max-width:220px; overflow:hidden; text-overflow:ellipsis; white-space:nowrap;">
                                ${t.title}
                              </td>
                              <td>
                                <span class="badge ${t.ticketType eq 'Incident' ? 'badge-danger' : 'badge-primary'}"
                                      style="font-size:0.72rem;">${t.ticketType}</span>
                              </td>
                              <td>
                                <span class="badge ${t.status eq 'New' ? 'badge-warning' :
                                                     t.status eq 'In Progress' ? 'badge-info' :
                                                     t.status eq 'Resolved' ? 'badge-success' : 'badge-secondary'}"
                                      style="font-size:0.72rem;">${t.status}</span>
                              </td>
                            </tr>
                          </c:forEach>
                        </tbody>
                      </table>
                    </div>
                  </c:when>
                  <c:otherwise>
                    <div class="empty-state">
                      <i class="feather icon-check-circle"></i>
                      <p class="mb-0" style="font-size:0.88rem;">Không có ticket nào đang xử lý</p>
                    </div>
                  </c:otherwise>
                </c:choose>
              </div>
            </div>
          </div>

          <!-- Quick links sidebar -->
          <div class="col-xl-4 mb-3">
            <div class="card border-0 shadow-sm">
              <div class="card-header py-3">
                <h5 class="mb-0">Xin chào, <%= user != null ? user.getFullName() : "IT Support" %>!</h5>
              </div>
              <div class="card-body">
                <a href="${pageContext.request.contextPath}/Queues" class="quick-link">
                  <div class="ql-icon" style="background:#deebff; color:#0052cc;"><i class="feather icon-inbox"></i></div>
                  <span class="ql-label">Ticket Queue</span>
                  <span class="ql-count text-primary">${agentKPIs.myTotal}</span>
                </a>
                <a href="${pageContext.request.contextPath}/ITProblemListController" class="quick-link">
                  <div class="ql-icon" style="background:#ffebe6; color:#bf2600;"><i class="feather icon-alert-circle"></i></div>
                  <span class="ql-label">My Problems</span>
                  <span class="ql-count text-danger">${myProblems}</span>
                </a>
                <a href="${pageContext.request.contextPath}/MyChangeRequests" class="quick-link">
                  <div class="ql-icon" style="background:#e3fcef; color:#006644;"><i class="feather icon-file-text"></i></div>
                  <span class="ql-label">My Change Requests</span>
                </a>
                <a href="${pageContext.request.contextPath}/SubmitChangeRequest" class="quick-link">
                  <div class="ql-icon" style="background:#f4f5f7; color:#42526e;"><i class="feather icon-edit"></i></div>
                  <span class="ql-label">Submit RFC mới</span>
                </a>
                <a href="${pageContext.request.contextPath}/KnowledgeArticleManage" class="quick-link">
                  <div class="ql-icon" style="background:#fff0b3; color:#974f0c;"><i class="feather icon-book"></i></div>
                  <span class="ql-label">Knowledge Articles</span>
                </a>
              </div>
            </div>
          </div>
        </div>

      </div></div></div>
    </div>

    <script src="${pageContext.request.contextPath}/assets/plugins/jquery/js/jquery.min.js"></script>
    <script src="${pageContext.request.contextPath}/assets/js/vendor-all.min.js"></script>
    <script src="${pageContext.request.contextPath}/assets/plugins/bootstrap/js/bootstrap.min.js"></script>
    <script src="${pageContext.request.contextPath}/assets/js/pcoded.min.js"></script>
    <script>$(document).ready(function(){ $('.fixed-button').remove(); });</script>
</body>
</html>
