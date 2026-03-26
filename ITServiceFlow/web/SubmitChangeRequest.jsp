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
    <meta name="viewport" content="width=device-width, initial-scale=1.0, user-scalable=0, minimal-ui">
    <title>Tạo RFC - ITServiceFlow</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/fonts/fontawesome/css/fontawesome-all.min.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/plugins/bootstrap/css/bootstrap.min.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/style.css">
    <style>
        body { background-color: #f4f5f7; }
        .rfc-layout { max-width: 860px; margin: 0 auto; }

        /* Section headers */
        .section-divider {
            font-size: .72rem; font-weight: 700; color: #6b778c;
            text-transform: uppercase; letter-spacing: .6px;
            border-bottom: 1px solid #dfe1e6; padding-bottom: 8px;
            margin: 28px 0 18px;
        }
        .section-divider:first-of-type { margin-top: 0; }

        /* Labels */
        .field-label {
            font-size: .8rem; font-weight: 600; color: #172b4d;
            margin-bottom: 5px; display: block;
        }
        .field-label .req { color: #de350b; margin-left: 2px; }

        /* Input focus */
        .form-control:focus {
            border-color: #0052cc;
            box-shadow: 0 0 0 2px rgba(0,82,204,.15);
        }

        /* Risk badges — hiển thị ngay khi chọn */
        .risk-preview {
            display: inline-block; padding: 4px 12px;
            border-radius: 4px; font-size: .8rem; font-weight: 700;
            margin-top: 6px; transition: all .15s;
        }
        .risk-Low      { background:#e3fcef; color:#00875a; }
        .risk-Medium   { background:#fff0b3; color:#ff8b00; }
        .risk-High     { background:#ffebe6; color:#bf2600; }
        .risk-Critical { background:#de350b; color:#fff; }

        /* Linked ticket box */
        .linked-ticket-box {
            background: #e9f2ff; border: 1px solid #b3d4ff;
            border-radius: 6px; padding: 10px 14px;
            font-size: .875rem; display: none; margin-top: 8px;
        }
        .linked-ticket-box .t-num  { font-weight: 700; color: #0052cc; }
        .linked-ticket-box .t-type { font-size: .75rem; background: #dce9ff; color: #0052cc; border-radius: 3px; padding: 1px 6px; }
        .linked-ticket-box .t-status { font-size: .75rem; color: #6b778c; }

        /* Action buttons */
        .btn-draft  { background: #f4f5f7; color: #42526e; border: 1px solid #c1c7d0; }
        .btn-draft:hover  { background: #ebecf0; color: #172b4d; }
        .btn-submit { background: #0052cc; color: #fff; border: none; }
        .btn-submit:hover { background: #003d99; color: #fff; }
        .btn-rfc    { padding: 10px 26px; font-weight: 600; font-size: .9rem; border-radius: 5px; cursor: pointer; }

        /* Info callout */
        .info-callout {
            background: #fffae6; border-left: 3px solid #f6c90e;
            border-radius: 0 5px 5px 0; padding: 10px 14px;
            font-size: .82rem; color: #5e6c84; margin-bottom: 20px;
        }
        .info-callout i { color: #f6c90e; margin-right: 6px; }
    </style>
</head>
<body>
    <jsp:include page="includes/header.jsp"/>
    <jsp:include page="includes/sidebar.jsp"/>

    <div class="pcoded-main-container">
        <div class="pcoded-wrapper">
            <div class="pcoded-content">
                <div class="pcoded-inner-content">

                    <!-- Breadcrumb -->
                    <div class="page-header mb-3">
                        <div class="page-block">
                            <ul class="breadcrumb bg-transparent p-0 m-0">
                                <li class="breadcrumb-item">
                                    <a href="${pageContext.request.contextPath}/ITDashboard" class="text-primary">
                                        <i class="feather icon-home"></i>
                                    </a>
                                </li>
                                <li class="breadcrumb-item">
                                    <a href="${pageContext.request.contextPath}/MyChangeRequests" class="text-primary">Change Requests</a>
                                </li>
                                <li class="breadcrumb-item text-muted">Tạo RFC mới</li>
                            </ul>
                        </div>
                    </div>

                    <div class="rfc-layout">

                        <!-- Alert messages -->
                        <c:if test="${not empty error}">
                            <div class="alert alert-danger rounded d-flex align-items-center mb-3">
                                <i class="feather icon-alert-circle mr-2"></i> ${error}
                            </div>
                        </c:if>

                        <div class="card border-0" style="box-shadow: 0 1px 3px rgba(9,30,66,.08);">
                            <div class="card-body p-4 p-md-5">

                                <!-- Page title -->
                                <div class="d-flex align-items-center mb-4">
                                    <div style="width:40px;height:40px;background:#e9f2ff;border-radius:8px;display:flex;align-items:center;justify-content:center;margin-right:14px;flex-shrink:0;">
                                        <i class="feather icon-file-plus" style="color:#0052cc;font-size:1.2rem;"></i>
                                    </div>
                                    <div>
                                        <h4 class="mb-0" style="color:#172b4d;font-weight:700;">Tạo Request for Change (RFC)</h4>
                                        <p class="mb-0 text-muted" style="font-size:.85rem;">RFC sẽ được gửi tới Manager để phê duyệt trước khi triển khai</p>
                                    </div>
                                </div>

                                <form action="${pageContext.request.contextPath}/SubmitChangeRequest" method="post" id="rfcForm">

                                    <%-- ═══════════ PHẦN 1: THÔNG TIN CƠ BẢN ═══════════ --%>
                                    <p class="section-divider"><i class="feather icon-info mr-1"></i>Thông tin cơ bản</p>

                                    <%-- Liên kết với ticket (optional, giảm nhập tay) --%>
                                    <div class="form-group mb-4">
                                        <label class="field-label">
                                            <i class="feather icon-link-2 mr-1 text-muted"></i>
                                            Liên kết với Ticket (tùy chọn)
                                        </label>
                                        <select name="linkedTicketId" id="linkedTicketId" class="form-control">
                                            <option value="">— Không liên kết —</option>
                                            <c:forEach var="t" items="${assignedTickets}">
                                                <option value="${t.id}"
                                                    data-num="${t.ticketNumber}"
                                                    data-title="${t.title}"
                                                    data-type="${t.ticketType}"
                                                    data-status="${t.status}"
                                                    ${preSelectedTicketId == t.id ? 'selected' : ''}>
                                                    [${t.ticketNumber}] ${t.title}
                                                </option>
                                            </c:forEach>
                                        </select>
                                        <div class="linked-ticket-box" id="linkedTicketPreview">
                                            <i class="feather icon-link-2 mr-1"></i>
                                            <span class="t-num" id="ltNum"></span>
                                            <span class="t-type ml-2" id="ltType"></span>
                                            <span class="t-status ml-2" id="ltStatus"></span>
                                            <br><small class="text-muted" id="ltTitle"></small>
                                        </div>
                                        <c:if test="${empty assignedTickets}">
                                            <small class="text-muted">Bạn chưa có ticket nào được assign.</small>
                                        </c:if>
                                    </div>

                                    <%-- Tiêu đề --%>
                                    <div class="form-group mb-3">
                                        <label class="field-label">Tiêu đề RFC <span class="req">*</span></label>
                                        <input type="text" name="title" id="rfcTitle" class="form-control"
                                               placeholder="Mô tả ngắn gọn thay đổi cần thực hiện..."
                                               value="${param.title}" required maxlength="255">
                                    </div>

                                    <%-- Loại thay đổi — dropdown thay vì tự gõ --%>
                                    <div class="row">
                                        <div class="col-md-6 mb-3">
                                            <label class="field-label">Loại thay đổi <span class="req">*</span></label>
                                            <select name="changeType" id="changeType" class="form-control" required>
                                                <option value="">— Chọn loại —</option>
                                                <option value="Hardware Upgrade"      ${param.changeType == 'Hardware Upgrade'      ? 'selected':''}>Hardware Upgrade</option>
                                                <option value="Hardware Replacement"  ${param.changeType == 'Hardware Replacement'  ? 'selected':''}>Hardware Replacement</option>
                                                <option value="Software Installation" ${param.changeType == 'Software Installation' ? 'selected':''}>Software Installation</option>
                                                <option value="Software Update"       ${param.changeType == 'Software Update'       ? 'selected':''}>Software Update</option>
                                                <option value="Network Change"        ${param.changeType == 'Network Change'        ? 'selected':''}>Network Change</option>
                                                <option value="Security Patch"        ${param.changeType == 'Security Patch'        ? 'selected':''}>Security Patch</option>
                                                <option value="Configuration Change"  ${param.changeType == 'Configuration Change'  ? 'selected':''}>Configuration Change</option>
                                                <option value="Access Management"     ${param.changeType == 'Access Management'     ? 'selected':''}>Access Management</option>
                                                <option value="Other"                 ${param.changeType == 'Other'                 ? 'selected':''}>Other</option>
                                            </select>
                                        </div>
                                        <div class="col-md-6 mb-3">
                                            <label class="field-label">Mức độ rủi ro <span class="req">*</span></label>
                                            <select name="riskLevel" id="riskLevel" class="form-control" required>
                                                <option value="">— Chọn mức —</option>
                                                <option value="Low"      ${param.riskLevel == 'Low'      ? 'selected':''}>Low — Ít ảnh hưởng</option>
                                                <option value="Medium"   ${param.riskLevel == 'Medium'   ? 'selected':''}>Medium — Ảnh hưởng một phần</option>
                                                <option value="High"     ${param.riskLevel == 'High'     ? 'selected':''}>High — Ảnh hưởng lớn</option>
                                                <option value="Critical" ${param.riskLevel == 'Critical' ? 'selected':''}>Critical — Ảnh hưởng toàn hệ thống</option>
                                            </select>
                                            <span class="risk-preview" id="riskPreview" style="display:none;"></span>
                                        </div>
                                    </div>

                                    <%-- Mô tả chi tiết --%>
                                    <div class="form-group mb-3">
                                        <label class="field-label">Mô tả chi tiết</label>
                                        <textarea name="description" class="form-control" rows="4"
                                                  placeholder="Mô tả lý do thay đổi, phạm vi ảnh hưởng, các bước thực hiện..."
                                                  maxlength="2000">${param.description}</textarea>
                                        <small class="text-muted float-right" id="descCount">0 / 2000</small>
                                    </div>

                                    <%-- ═══════════ PHẦN 2: KẾ HOẠCH ═══════════ --%>
                                    <p class="section-divider"><i class="feather icon-calendar mr-1"></i>Kế hoạch triển khai</p>

                                    <div class="row mb-3">
                                        <div class="col-md-6">
                                            <label class="field-label">Ngày bắt đầu dự kiến</label>
                                            <input type="date" name="plannedStart" class="form-control"
                                                   id="plannedStart" value="${param.plannedStart}">
                                        </div>
                                        <div class="col-md-6">
                                            <label class="field-label">Ngày kết thúc dự kiến</label>
                                            <input type="date" name="plannedEnd" class="form-control"
                                                   id="plannedEnd" value="${param.plannedEnd}">
                                            <small class="text-danger" id="dateError" style="display:none;">
                                                Ngày kết thúc phải sau ngày bắt đầu.
                                            </small>
                                        </div>
                                    </div>

                                    <%-- Rollback Plan --%>
                                    <div class="form-group mb-4">
                                        <label class="field-label">Kế hoạch rollback <span class="req">*</span></label>
                                        <div class="info-callout">
                                            <i class="feather icon-alert-triangle"></i>
                                            Bắt buộc mô tả cách hoàn tác thay đổi nếu phát sinh sự cố. Manager sẽ đánh giá kỹ mục này.
                                        </div>
                                        <textarea name="rollbackPlan" class="form-control" rows="3" required
                                                  placeholder="Ví dụ: Restore từ backup tại T-1 ngày, quay lại config cũ trong 30 phút..."
                                                  maxlength="1000">${param.rollbackPlan}</textarea>
                                    </div>

                                    <%-- ═══════════ ACTION BUTTONS ═══════════ --%>
                                    <div class="d-flex align-items-center justify-content-between mt-4 pt-3 border-top">
                                        <a href="${pageContext.request.contextPath}/MyChangeRequests"
                                           class="btn btn-outline-secondary">
                                            <i class="feather icon-x mr-1"></i>Hủy
                                        </a>
                                        <div class="d-flex gap-2" style="gap:10px;">
                                            <%-- Nút Lưu nháp --%>
                                            <button type="submit" name="action" value="draft"
                                                    class="btn btn-rfc btn-draft">
                                                <i class="feather icon-save mr-1"></i>Lưu nháp
                                            </button>
                                            <%-- Nút Gửi Manager --%>
                                            <button type="submit" name="action" value="submit"
                                                    class="btn btn-rfc btn-submit" id="submitBtn">
                                                <i class="feather icon-send mr-1"></i>Gửi Manager duyệt
                                            </button>
                                        </div>
                                    </div>

                                </form>
                            </div>
                        </div>
                    </div><%-- /.rfc-layout --%>

                </div>
            </div>
        </div>
    </div>

    <script src="${pageContext.request.contextPath}/assets/plugins/jquery/js/jquery.min.js"></script>
<script src="${pageContext.request.contextPath}/assets/js/vendor-all.min.js"></script>
<script src="${pageContext.request.contextPath}/assets/plugins/bootstrap/js/bootstrap.min.js"></script>
<script src="${pageContext.request.contextPath}/assets/js/pcoded.min.js"></script>
    <script>
    (function(){
        // ── Linked ticket preview ──────────────────────────────────────
        var sel = document.getElementById('linkedTicketId');
        var box = document.getElementById('linkedTicketPreview');

        function updateTicketPreview() {
            var opt = sel.options[sel.selectedIndex];
            if (!opt || !opt.value) {
                box.style.display = 'none';
                return;
            }
            document.getElementById('ltNum').textContent    = opt.dataset.num    || '';
            document.getElementById('ltTitle').textContent  = opt.dataset.title  || '';
            document.getElementById('ltType').textContent   = opt.dataset.type   || '';
            document.getElementById('ltStatus').textContent = opt.dataset.status || '';
            box.style.display = 'block';
        }
        if (sel) {
            sel.addEventListener('change', updateTicketPreview);
            updateTicketPreview(); // xử lý preSelectedTicketId
        }

        // ── Risk level badge ───────────────────────────────────────────
        var riskSel     = document.getElementById('riskLevel');
        var riskPreview = document.getElementById('riskPreview');
        var RISK_LABELS = {
            Low: 'Low — Ít ảnh hưởng',
            Medium: 'Medium — Ảnh hưởng một phần',
            High: 'High — Ảnh hưởng lớn',
            Critical: 'Critical — Ảnh hưởng toàn hệ thống'
        };
        function updateRisk() {
            var v = riskSel.value;
            if (!v) { riskPreview.style.display = 'none'; return; }
            riskPreview.className = 'risk-preview risk-' + v;
            riskPreview.textContent = RISK_LABELS[v] || v;
            riskPreview.style.display = 'inline-block';
        }
        if (riskSel) { riskSel.addEventListener('change', updateRisk); updateRisk(); }

        // ── Char counter ───────────────────────────────────────────────
        var descArea  = document.querySelector('textarea[name="description"]');
        var descCount = document.getElementById('descCount');
        if (descArea && descCount) {
            descArea.addEventListener('input', function(){
                descCount.textContent = descArea.value.length + ' / 2000';
            });
        }

        // ── Date validation ────────────────────────────────────────────
        var startIn   = document.getElementById('plannedStart');
        var endIn     = document.getElementById('plannedEnd');
        var dateErr   = document.getElementById('dateError');
        var submitBtn = document.getElementById('submitBtn');

        function checkDates() {
            if (!startIn.value || !endIn.value) {
                dateErr.style.display = 'none'; return true;
            }
            var ok = endIn.value >= startIn.value;
            dateErr.style.display = ok ? 'none' : 'block';
            return ok;
        }
        if (startIn) startIn.addEventListener('change', checkDates);
        if (endIn)   endIn.addEventListener('change', checkDates);

        // ── Prevent double-submit ──────────────────────────────────────
        var form = document.getElementById('rfcForm');
        if (form) {
            form.addEventListener('submit', function(e){
                if (!checkDates()) { e.preventDefault(); return; }
                submitBtn.disabled = true;
                submitBtn.innerHTML = '<i class="feather icon-loader mr-1"></i>Đang gửi...';
            });
        }

        // ── Set min date = today ───────────────────────────────────────
        var today = new Date().toISOString().split('T')[0];
        if (startIn) startIn.min = today;
        if (endIn)   endIn.min   = today;
    })();
    </script>
</body>
</html>
