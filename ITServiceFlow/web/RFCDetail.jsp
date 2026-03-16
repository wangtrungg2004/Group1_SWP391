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
    <title>${rfc.rfcNumber} - Chi tiết RFC</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/fonts/fontawesome/css/fontawesome-all.min.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/plugins/bootstrap/css/bootstrap.min.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/style.css">
    <style>
        body { background:#f4f5f7; }

        /* ── Layout ── */
        .detail-layout { display:grid; grid-template-columns:1fr 340px; gap:20px; align-items:start; }
        @media(max-width:900px){ .detail-layout { grid-template-columns:1fr; } }

        /* ── Card base ── */
        .panel { background:#fff; border:1px solid #dfe1e6; border-radius:8px;
                 box-shadow:0 1px 3px rgba(9,30,66,.05); }

        /* ── RFC Header ── */
        .rfc-header { padding:24px 28px 20px; border-bottom:1px solid #f0f0f0; }
        .rfc-header .rfc-id { font-size:.8rem; font-weight:700; color:#6b778c;
                               text-transform:uppercase; letter-spacing:.5px; margin-bottom:6px; }
        .rfc-header h2 { font-size:1.35rem; font-weight:700; color:#172b4d; margin:0 0 12px; line-height:1.35; }
        .rfc-header-meta { display:flex; gap:10px; flex-wrap:wrap; align-items:center; }

        /* ── Section ── */
        .section { padding:22px 28px; border-bottom:1px solid #f4f5f7; }
        .section:last-child { border-bottom:none; }
        .section-title { font-size:.72rem; font-weight:700; color:#6b778c; text-transform:uppercase;
                          letter-spacing:.5px; margin-bottom:12px; display:flex; align-items:center; gap:6px; }
        .section-title i { font-size:.85rem; }

        /* ── Content boxes ── */
        .content-box { background:#fafbfc; border:1px solid #ebecf0; border-radius:6px;
                        padding:14px 16px; font-size:.875rem; color:#172b4d;
                        line-height:1.7; white-space:pre-wrap; }
        .rollback-box { background:#fffae6; border:1px solid #f6c90e; border-radius:6px;
                         padding:14px 16px; font-size:.875rem; color:#172b4d;
                         line-height:1.7; white-space:pre-wrap; }

        /* ── Linked ticket chip ── */
        .ticket-chip { display:inline-flex; align-items:center; gap:6px;
                        background:#e9f2ff; border:1px solid #b3d4ff; border-radius:20px;
                        padding:4px 12px; font-size:.8rem; font-weight:600; color:#0052cc; }

        /* ── Sidebar meta ── */
        .meta-item { padding:14px 20px; border-bottom:1px solid #f4f5f7; }
        .meta-item:last-child { border-bottom:none; }
        .meta-label { font-size:.7rem; font-weight:700; color:#6b778c;
                       text-transform:uppercase; letter-spacing:.4px; margin-bottom:5px; }
        .meta-value { font-size:.875rem; color:#172b4d; font-weight:500; }

        /* ── Badges ── */
        .b { display:inline-flex; align-items:center; gap:4px; padding:4px 11px;
             border-radius:20px; font-size:.75rem; font-weight:700; }
        .b-pending  { background:#fff0b3; color:#ff8b00; }
        .b-approved { background:#e3fcef; color:#00875a; }
        .b-rejected { background:#ffebe6; color:#bf2600; }
        .b-draft    { background:#ebecf0; color:#42526e; }
        .b-progress { background:#e9f2ff; color:#0052cc; }

        .risk { display:inline-flex; align-items:center; gap:5px; padding:4px 11px;
                border-radius:20px; font-size:.75rem; font-weight:700; }
        .r-Low      { background:#e3fcef; color:#00875a; }
        .r-Medium   { background:#fff0b3; color:#ff8b00; }
        .r-High     { background:#ffebe6; color:#bf2600; }
        .r-Critical { background:#de350b; color:#fff; }

        /* ── Avatar ── */
        .av-lg { width:36px; height:36px; border-radius:50%; background:#0052cc; color:#fff;
                  display:inline-flex; align-items:center; justify-content:center;
                  font-size:.75rem; font-weight:700; flex-shrink:0; }

        /* ── Approval panel ── */
        .approval-panel { border:2px solid #0052cc; border-radius:8px; overflow:hidden; }
        .approval-panel-header { background:#0052cc; color:#fff; padding:14px 20px; }
        .approval-panel-header h5 { margin:0; font-size:.95rem; font-weight:700; }
        .approval-panel-header p  { margin:3px 0 0; font-size:.8rem; opacity:.85; }
        .approval-panel-body { padding:20px; }

        .field-label { font-size:.75rem; font-weight:700; color:#6b778c;
                        text-transform:uppercase; letter-spacing:.4px; margin-bottom:6px; }
        .comment-area { width:100%; border:1.5px solid #c1c7d0; border-radius:6px;
                          padding:10px 13px; font-size:.875rem; color:#172b4d;
                          resize:vertical; min-height:80px; transition:border-color .15s; }
        .comment-area:focus { border-color:#0052cc; outline:none;
                               box-shadow:0 0 0 2px rgba(0,82,204,.15); }

        .btn-approve { width:100%; padding:11px; font-size:.9rem; font-weight:700;
                        background:#00875a; color:#fff; border:none; border-radius:6px;
                        cursor:pointer; transition:background .15s; display:flex;
                        align-items:center; justify-content:center; gap:7px; }
        .btn-approve:hover { background:#006644; }
        .btn-reject  { width:100%; padding:11px; font-size:.9rem; font-weight:700;
                         background:#fff; color:#de350b; border:2px solid #de350b;
                         border-radius:6px; cursor:pointer; transition:all .15s;
                         display:flex; align-items:center; justify-content:center; gap:7px; }
        .btn-reject:hover  { background:#de350b; color:#fff; }

        /* ── Result box (đã xử lý) ── */
        .result-approved { background:#e3fcef; border:1px solid #57d9a3; border-radius:7px; padding:16px 18px; }
        .result-rejected { background:#ffebe6; border:1px solid #ff8f73; border-radius:7px; padding:16px 18px; }
        .result-title { font-weight:700; font-size:.9rem; display:flex; align-items:center; gap:7px; margin-bottom:6px; }

        /* ── Approval history timeline ── */
        .tl { list-style:none; padding:0; margin:0; }
        .tl-item { display:flex; gap:12px; padding:12px 0; border-bottom:1px solid #f4f5f7; }
        .tl-item:last-child { border-bottom:none; }
        .tl-dot { width:32px; height:32px; border-radius:50%; display:flex; align-items:center;
                   justify-content:center; flex-shrink:0; font-size:.85rem; }
        .tl-approved { background:#e3fcef; color:#00875a; }
        .tl-rejected { background:#ffebe6; color:#de350b; }
        .tl-body { flex:1; }
        .tl-body .tl-name { font-weight:600; font-size:.875rem; color:#172b4d; }
        .tl-body .tl-time { font-size:.75rem; color:#6b778c; }
        .tl-body .tl-comment { font-size:.82rem; color:#5e6c84; margin-top:4px;
                                 background:#fafbfc; border-radius:4px; padding:6px 10px;
                                 border-left:3px solid #dfe1e6; }

        /* ── Warning callout ── */
        .warn-callout { background:#fffae6; border-left:3px solid #f6c90e;
                         border-radius:0 5px 5px 0; padding:10px 14px;
                         font-size:.8rem; color:#5e6c84; margin-bottom:14px; }
        .warn-callout strong { color:#172b4d; }
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
            <a href="${pageContext.request.contextPath}/ManagerDashboard.jsp" class="text-primary">
              <i class="feather icon-home"></i>
            </a>
          </li>
          <li class="breadcrumb-item">
            <a href="${pageContext.request.contextPath}/ManagerChangeApprovals" class="text-primary">
              Phê duyệt RFC
            </a>
          </li>
          <li class="breadcrumb-item text-muted">${rfc.rfcNumber}</li>
        </ul>
      </div>
    </div>

    <!-- Flash -->
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

    <!-- 2-column layout -->
    <div class="detail-layout">

      <!-- ════ LEFT: RFC Content ════ -->
      <div>
        <div class="panel">

          <!-- Header -->
          <div class="rfc-header">
            <div class="rfc-id">
              <i class="feather icon-file-text mr-1"></i>
              Request for Change &nbsp;·&nbsp; ${rfc.rfcNumber}
            </div>
            <h2><c:out value="${rfc.title}"/></h2>
            <div class="rfc-header-meta">
              <!-- Status -->
              <c:choose>
                <c:when test="${rfc.status=='Pending Approval'}">
                  <span class="b b-pending"><i class="feather icon-clock"></i>Chờ phê duyệt</span>
                </c:when>
                <c:when test="${rfc.status=='Approved'}">
                  <span class="b b-approved"><i class="feather icon-check-circle"></i>Đã phê duyệt</span>
                </c:when>
                <c:when test="${rfc.status=='Rejected'}">
                  <span class="b b-rejected"><i class="feather icon-x-circle"></i>Bị từ chối</span>
                </c:when>
                <c:when test="${rfc.status=='In Progress'}">
                  <span class="b b-progress"><i class="feather icon-loader"></i>Đang triển khai</span>
                </c:when>
                <c:otherwise>
                  <span class="b b-draft">${rfc.status}</span>
                </c:otherwise>
              </c:choose>
              <!-- Risk -->
              <span class="risk r-${rfc.riskLevel}">
                <i class="feather icon-alert-triangle"></i>${rfc.riskLevel} Risk
              </span>
              <!-- Change type -->
              <span style="font-size:.78rem;background:#ebecf0;color:#42526e;padding:4px 10px;border-radius:20px;">
                ${rfc.changeType}
              </span>
              <!-- Linked ticket -->
              <c:if test="${not empty rfc.linkedTicketNumber}">
                <span class="ticket-chip">
                  <i class="feather icon-link-2" style="font-size:.75rem;"></i>
                  ${rfc.linkedTicketNumber}
                </span>
              </c:if>
            </div>
          </div>

          <!-- Description -->
          <c:if test="${not empty rfc.description}">
            <div class="section">
              <div class="section-title">
                <i class="feather icon-align-left"></i>Mô tả chi tiết
              </div>
              <div class="content-box"><c:out value="${rfc.description}"/></div>
            </div>
          </c:if>

          <!-- Rollback Plan — quan trọng nhất với Manager -->
          <div class="section">
            <div class="section-title">
              <i class="feather icon-rotate-ccw" style="color:#f6c90e;"></i>
              Kế hoạch Rollback
              <span style="font-size:.7rem;background:#fffae6;color:#ff8b00;padding:2px 7px;border-radius:10px;font-weight:700;">
                Bắt buộc đánh giá
              </span>
            </div>
            <div class="warn-callout">
              <strong>Lưu ý:</strong> Đây là kế hoạch khôi phục nếu thay đổi gây ra sự cố.
              Manager cần đánh giá tính khả thi trước khi phê duyệt.
            </div>
            <div class="rollback-box"><c:out value="${rfc.rollbackPlan}"/></div>
          </div>

          <!-- Linked ticket detail -->
          <c:if test="${not empty rfc.linkedTicketNumber}">
            <div class="section">
              <div class="section-title">
                <i class="feather icon-link-2"></i>Ticket liên quan
              </div>
              <div style="background:#e9f2ff;border-radius:6px;padding:12px 16px;">
                <div style="font-weight:700;color:#0052cc;">${rfc.linkedTicketNumber}</div>
                <div style="font-size:.875rem;color:#172b4d;margin-top:3px;">
                  <c:out value="${rfc.linkedTicketTitle}"/>
                </div>
              </div>
            </div>
          </c:if>

          <!-- Approval history -->
          <div class="section">
            <div class="section-title">
              <i class="feather icon-clock"></i>Lịch sử phê duyệt
            </div>
            <c:choose>
              <c:when test="${empty history}">
                <p class="text-muted mb-0" style="font-size:.875rem;">
                  <i class="feather icon-info mr-1"></i>Chưa có lịch sử phê duyệt.
                </p>
              </c:when>
              <c:otherwise>
                <ul class="tl">
                  <c:forEach var="ap" items="${history}">
                    <li class="tl-item">
                      <div class="tl-dot ${ap.decision=='Approved' ? 'tl-approved' : 'tl-rejected'}">
                        <i class="feather icon-${ap.decision=='Approved' ? 'check' : 'x'}"></i>
                      </div>
                      <div class="tl-body">
                        <div class="d-flex align-items-center justify-content-between">
                          <span class="tl-name">${ap.approverName}</span>
                          <span class="tl-time">
                            <fmt:formatDate value="${ap.decidedAt}" pattern="dd/MM/yyyy HH:mm"/>
                          </span>
                        </div>
                        <div style="margin-top:3px;">
                          <c:choose>
                            <c:when test="${ap.decision=='Approved'}">
                              <span style="font-size:.75rem;background:#e3fcef;color:#00875a;padding:2px 8px;border-radius:10px;font-weight:700;">
                                Đã phê duyệt
                              </span>
                            </c:when>
                            <c:otherwise>
                              <span style="font-size:.75rem;background:#ffebe6;color:#de350b;padding:2px 8px;border-radius:10px;font-weight:700;">
                                Từ chối
                              </span>
                            </c:otherwise>
                          </c:choose>
                        </div>
                        <c:if test="${not empty ap.comment}">
                          <div class="tl-comment"><c:out value="${ap.comment}"/></div>
                        </c:if>
                      </div>
                    </li>
                  </c:forEach>
                </ul>
              </c:otherwise>
            </c:choose>
          </div>

        </div><%-- /.panel --%>
      </div>

      <!-- ════ RIGHT: Sidebar ════ -->
      <div>

        <!-- Approval action (chỉ với Pending) -->
        <c:if test="${rfc.status=='Pending Approval'}">
          <div class="approval-panel mb-4">
            <div class="approval-panel-header">
              <h5><i class="feather icon-check-square mr-2"></i>Quyết định phê duyệt</h5>
              <p>Xem xét nội dung RFC bên trái trước khi quyết định</p>
            </div>
            <div class="approval-panel-body">
              <div class="field-label">
                <i class="feather icon-message-square mr-1"></i>
                Nhận xét / Ghi chú
              </div>
              <textarea class="comment-area" id="commentInput"
                        placeholder="Nhập nhận xét của bạn... (bắt buộc khi từ chối)"></textarea>
              <small class="text-muted d-block mb-3" style="font-size:.75rem;">
                Khi từ chối, lý do sẽ được gửi tới IT Support qua notification.
              </small>

              <!-- Hidden forms -->
              <form id="approveForm" action="${pageContext.request.contextPath}/ManagerChangeApprovals"
                    method="post" style="display:none;">
                <input type="hidden" name="changeId" value="${rfc.id}">
                <input type="hidden" name="action" value="approve">
                <input type="hidden" name="comment" id="approveComment">
                <input type="hidden" name="returnTo" value="list">
              </form>
              <form id="rejectForm" action="${pageContext.request.contextPath}/ManagerChangeApprovals"
                    method="post" style="display:none;">
                <input type="hidden" name="changeId" value="${rfc.id}">
                <input type="hidden" name="action" value="reject">
                <input type="hidden" name="comment" id="rejectComment">
                <input type="hidden" name="returnTo" value="list">
              </form>

              <button class="btn-approve mb-2" onclick="doApprove()">
                <i class="feather icon-check-circle"></i> Phê duyệt RFC này
              </button>
              <button class="btn-reject" onclick="doReject()">
                <i class="feather icon-x-circle"></i> Từ chối
              </button>
            </div>
          </div>
        </c:if>

        <!-- Kết quả đã xử lý -->
        <c:if test="${rfc.status=='Approved' || rfc.status=='Rejected'}">
          <div class="mb-4">
            <c:choose>
              <c:when test="${rfc.status=='Approved'}">
                <div class="result-approved">
                  <div class="result-title" style="color:#00875a;">
                    <i class="feather icon-check-circle" style="font-size:1.1rem;"></i>
                    RFC đã được phê duyệt
                  </div>
                  <c:if test="${not empty rfc.approvedAt}">
                    <div class="text-muted" style="font-size:.8rem;">
                      <fmt:formatDate value="${rfc.approvedAt}" pattern="dd/MM/yyyy HH:mm"/>
                    </div>
                  </c:if>
                  <c:if test="${not empty rfc.approverComment}">
                    <div style="margin-top:8px;font-size:.82rem;color:#172b4d;">
                      "<c:out value='${rfc.approverComment}'/>"
                    </div>
                  </c:if>
                </div>
              </c:when>
              <c:otherwise>
                <div class="result-rejected">
                  <div class="result-title" style="color:#de350b;">
                    <i class="feather icon-x-circle" style="font-size:1.1rem;"></i>
                    RFC bị từ chối
                  </div>
                  <c:if test="${not empty rfc.approvedAt}">
                    <div class="text-muted" style="font-size:.8rem;">
                      <fmt:formatDate value="${rfc.approvedAt}" pattern="dd/MM/yyyy HH:mm"/>
                    </div>
                  </c:if>
                  <c:if test="${not empty rfc.approverComment}">
                    <div style="margin-top:8px;font-size:.82rem;color:#172b4d;">
                      Lý do: "<c:out value='${rfc.approverComment}'/>"
                    </div>
                  </c:if>
                </div>
              </c:otherwise>
            </c:choose>
          </div>
        </c:if>

        <!-- Meta info card -->
        <div class="panel">
          <div class="meta-item" style="padding-top:16px;">
            <div class="meta-label">Người đề xuất</div>
            <div class="meta-value d-flex align-items-center gap-2" style="gap:8px;">
              <div class="av-lg">
                ${not empty rfc.createdByName ? rfc.createdByName.substring(0, rfc.createdByName.length() >= 2 ? 2 : 1).toUpperCase() : '?'}
              </div>
              <div>
                <div style="font-weight:600;">${rfc.createdByName}</div>
                <div style="font-size:.75rem;color:#6b778c;">IT Support</div>
              </div>
            </div>
          </div>

          <div class="meta-item">
            <div class="meta-label">Ngày tạo</div>
            <div class="meta-value">
              <fmt:formatDate value="${rfc.createdAt}" pattern="dd/MM/yyyy HH:mm"/>
            </div>
          </div>

          <div class="meta-item">
            <div class="meta-label">Loại thay đổi</div>
            <div class="meta-value">${rfc.changeType}</div>
          </div>

          <div class="meta-item">
            <div class="meta-label">Mức độ rủi ro</div>
            <div class="meta-value">
              <span class="risk r-${rfc.riskLevel}">
                <i class="feather icon-alert-triangle"></i>${rfc.riskLevel}
              </span>
            </div>
          </div>

          <c:if test="${rfc.plannedStart != null}">
            <div class="meta-item">
              <div class="meta-label">Ngày triển khai dự kiến</div>
              <div class="meta-value">
                <i class="feather icon-calendar mr-1 text-muted"></i>
                <fmt:formatDate value="${rfc.plannedStart}" pattern="dd/MM/yyyy"/>
                <c:if test="${rfc.plannedEnd != null}">
                  <br>
                  <span class="text-muted" style="font-size:.8rem;">đến </span>
                  <fmt:formatDate value="${rfc.plannedEnd}" pattern="dd/MM/yyyy"/>
                </c:if>
              </div>
            </div>
          </c:if>

          <div class="meta-item" style="padding-bottom:16px;">
            <div class="meta-label">Trạng thái</div>
            <div class="meta-value">
              <c:choose>
                <c:when test="${rfc.status=='Pending Approval'}">
                  <span class="b b-pending"><i class="feather icon-clock"></i>Chờ phê duyệt</span>
                </c:when>
                <c:when test="${rfc.status=='Approved'}">
                  <span class="b b-approved"><i class="feather icon-check-circle"></i>Đã phê duyệt</span>
                </c:when>
                <c:when test="${rfc.status=='Rejected'}">
                  <span class="b b-rejected"><i class="feather icon-x-circle"></i>Từ chối</span>
                </c:when>
                <c:otherwise>
                  <span class="b b-draft">${rfc.status}</span>
                </c:otherwise>
              </c:choose>
            </div>
          </div>
        </div>

        <!-- Back button -->
        <div class="mt-3">
          <a href="${pageContext.request.contextPath}/ManagerChangeApprovals"
             class="btn btn-outline-secondary btn-sm w-100">
            <i class="feather icon-arrow-left mr-1"></i>Quay lại danh sách
          </a>
        </div>

      </div><%-- /.sidebar --%>
    </div><%-- /.detail-layout --%>

  </div></div></div>
</div>

<script src="${pageContext.request.contextPath}/assets/plugins/jquery/js/jquery.min.js"></script>
<script src="${pageContext.request.contextPath}/assets/plugins/bootstrap/js/bootstrap.min.js"></script>
<script src="${pageContext.request.contextPath}/assets/js/vendor-all.min.js"></script>
<script src="${pageContext.request.contextPath}/assets/js/pcoded.min.js"></script>
<script>
function doApprove() {
    var comment = document.getElementById('commentInput').value.trim();
    if (!confirm('Xác nhận PHÊ DUYỆT RFC này?\n\nSau khi phê duyệt, IT Support sẽ nhận thông báo để tiến hành triển khai.')) return;
    document.getElementById('approveComment').value = comment;
    document.getElementById('approveForm').submit();
}

function doReject() {
    var comment = document.getElementById('commentInput').value.trim();
    if (!comment) {
        document.getElementById('commentInput').focus();
        document.getElementById('commentInput').style.borderColor = '#de350b';
        document.getElementById('commentInput').placeholder = '⚠️ Vui lòng nhập lý do từ chối...';
        return;
    }
    if (!confirm('Xác nhận TỪ CHỐI RFC này?\n\nLý do sẽ được gửi tới IT Support.')) return;
    document.getElementById('rejectComment').value = comment;
    document.getElementById('rejectForm').submit();
}

// Reset border khi user bắt đầu nhập
var ci = document.getElementById('commentInput');
if (ci) ci.addEventListener('input', function() {
    this.style.borderColor = '';
});
</script>
</body>
</html>
