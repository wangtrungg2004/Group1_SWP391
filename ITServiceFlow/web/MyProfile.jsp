<%-- MyProfile.jsp --%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<%@ taglib uri="jakarta.tags.fmt" prefix="fmt" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0, user-scalable=0, minimal-ui">
    <title>My Profile - ITServiceFlow</title>
    <link rel="stylesheet" href="assets/fonts/fontawesome/css/fontawesome-all.min.css">
    <link rel="stylesheet" href="assets/css/style.css">
    <style>
        /* ── Layout ────────────────────────────────── */
        .profile-wrapper {
            max-width: 860px;
            margin: 0 auto;
        }

        /* ── Avatar card ───────────────────────────── */
        .avatar-card {
            background: linear-gradient(135deg, #1a73e8 0%, #0d47a1 100%);
            border-radius: 12px;
            padding: 32px 28px;
            color: #fff;
            text-align: center;
            position: relative;
            overflow: hidden;
        }
        .avatar-card::before {
            content: '';
            position: absolute;
            top: -40px; right: -40px;
            width: 160px; height: 160px;
            border-radius: 50%;
            background: rgba(255,255,255,0.07);
        }
        .avatar-circle {
            width: 80px; height: 80px;
            border-radius: 50%;
            background: rgba(255,255,255,0.25);
            border: 3px solid rgba(255,255,255,0.5);
            display: flex; align-items: center; justify-content: center;
            font-size: 2rem; font-weight: 700;
            margin: 0 auto 16px;
            letter-spacing: 1px;
        }
        .avatar-card .user-name {
            font-size: 1.3rem; font-weight: 600; margin-bottom: 4px;
        }
        .avatar-card .user-role {
            font-size: 0.82rem; opacity: 0.8;
            background: rgba(255,255,255,0.15);
            display: inline-block; padding: 2px 12px; border-radius: 20px;
            margin-bottom: 12px;
        }
        .avatar-card .user-meta {
            font-size: 0.82rem; opacity: 0.75; margin-top: 4px;
        }
        .avatar-card .user-meta i { margin-right: 5px; }

        /* ── Stat chips ────────────────────────────── */
        .stat-row {
            display: flex; gap: 8px; margin-top: 20px;
            justify-content: center; flex-wrap: wrap;
        }
        .stat-chip {
            background: rgba(255,255,255,0.15);
            border-radius: 8px; padding: 10px 18px;
            text-align: center; min-width: 72px;
        }
        .stat-chip .num {
            font-size: 1.4rem; font-weight: 700; display: block; line-height: 1;
        }
        .stat-chip .lbl {
            font-size: 0.68rem; opacity: 0.75; text-transform: uppercase;
            letter-spacing: 0.5px; margin-top: 3px; display: block;
        }

        /* ── Section cards ─────────────────────────── */
        .section-card {
            background: #fff;
            border: 1px solid #e8eaed;
            border-radius: 10px;
            margin-bottom: 20px;
            overflow: hidden;
        }
        .section-header {
            padding: 16px 24px;
            border-bottom: 1px solid #f1f3f4;
            display: flex; align-items: center; gap: 10px;
        }
        .section-header h6 {
            font-size: 0.9rem; font-weight: 600;
            color: #202124; margin: 0;
        }
        .section-header i { color: #1a73e8; font-size: 1rem; }
        .section-body { padding: 24px; }

        /* ── Form fields ───────────────────────────── */
        .field-label {
            font-size: 0.75rem; font-weight: 600;
            color: #5f6368; text-transform: uppercase;
            letter-spacing: 0.4px; margin-bottom: 6px; display: block;
        }
        .form-control-profile {
            border: 1px solid #dadce0;
            border-radius: 6px;
            padding: 9px 14px;
            font-size: 0.9rem;
            color: #202124;
            width: 100%;
            transition: border-color 0.15s;
        }
        .form-control-profile:focus {
            outline: none;
            border-color: #1a73e8;
            box-shadow: 0 0 0 3px rgba(26,115,232,0.12);
        }
        .form-control-profile[readonly] {
            background: #f8f9fa;
            color: #80868b;
            cursor: default;
        }
        select.form-control-profile {
            appearance: none;
            background-image: url("data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' width='12' height='12' viewBox='0 0 24 24' fill='none' stroke='%2380868b' stroke-width='2'%3E%3Cpolyline points='6 9 12 15 18 9'/%3E%3C/svg%3E");
            background-repeat: no-repeat;
            background-position: right 12px center;
            padding-right: 36px;
            cursor: pointer;
        }

        /* ── Readonly info rows ────────────────────── */
        .info-row {
            display: flex; align-items: center;
            padding: 11px 0;
            border-bottom: 1px solid #f1f3f4;
        }
        .info-row:last-child { border-bottom: none; }
        .info-row .info-label {
            width: 140px; flex-shrink: 0;
            font-size: 0.78rem; font-weight: 600;
            color: #80868b; text-transform: uppercase; letter-spacing: 0.4px;
        }
        .info-row .info-value {
            font-size: 0.9rem; color: #202124; font-weight: 500;
        }
        .badge-role {
            display: inline-flex; align-items: center; gap: 5px;
            padding: 3px 10px; border-radius: 20px;
            font-size: 0.75rem; font-weight: 600;
        }
        .badge-role.user     { background:#e8f5e9; color:#2e7d32; }
        .badge-role.support  { background:#e3f2fd; color:#1565c0; }
        .badge-role.manager  { background:#fff3e0; color:#e65100; }
        .badge-role.admin    { background:#fce4ec; color:#880e4f; }

        /* ── Buttons ───────────────────────────────── */
        .btn-save {
            background: #1a73e8; color: #fff;
            border: none; border-radius: 6px;
            padding: 9px 24px; font-size: 0.88rem; font-weight: 600;
            cursor: pointer; transition: background 0.15s;
        }
        .btn-save:hover { background: #1557b0; }
        .btn-change-pw {
            background: #fff; color: #1a73e8;
            border: 1.5px solid #1a73e8;
            border-radius: 6px;
            padding: 8px 22px; font-size: 0.88rem; font-weight: 600;
            cursor: pointer; transition: all 0.15s;
        }
        .btn-change-pw:hover { background: #e8f0fe; }

        /* ── Alert ─────────────────────────────────── */
        .alert-profile {
            padding: 11px 16px; border-radius: 7px; margin-bottom: 20px;
            font-size: 0.88rem; font-weight: 500;
            display: flex; align-items: center; gap: 9px;
        }
        .alert-profile.success { background:#e8f5e9; color:#2e7d32; border-left: 3px solid #43a047; }
        .alert-profile.error   { background:#fce4ec; color:#c62828; border-left: 3px solid #e53935; }

        /* ── Password modal ────────────────────────── */
        .pw-modal-backdrop {
            display: none; position: fixed; inset: 0;
            background: rgba(0,0,0,0.45); z-index: 1050;
            align-items: center; justify-content: center;
        }
        .pw-modal-backdrop.open { display: flex; }
        .pw-modal {
            background: #fff; border-radius: 12px;
            width: 100%; max-width: 420px;
            padding: 28px 32px;
            box-shadow: 0 8px 40px rgba(0,0,0,0.18);
        }
        .pw-modal h5 {
            font-size: 1rem; font-weight: 700;
            color: #202124; margin-bottom: 20px;
        }
        .pw-modal .form-group { margin-bottom: 16px; }
        .pw-modal .close-btn {
            background: none; border: none;
            font-size: 1.3rem; cursor: pointer; color: #80868b;
            position: absolute; right: 20px; top: 16px;
        }
        .pw-field-wrap { position: relative; }
        .pw-toggle {
            position: absolute; right: 11px; top: 50%;
            transform: translateY(-50%);
            background: none; border: none; cursor: pointer;
            color: #80868b; font-size: 0.9rem; padding: 0;
        }

        /* ── Password strength ─────────────────────── */
        .pw-strength-bar {
            height: 4px; border-radius: 2px;
            background: #e8eaed; margin-top: 6px; overflow: hidden;
        }
        .pw-strength-fill {
            height: 100%; border-radius: 2px;
            width: 0; transition: width 0.3s, background 0.3s;
        }
        .pw-strength-text {
            font-size: 0.72rem; margin-top: 3px; font-weight: 600;
        }
    </style>
</head>
<body>
    <jsp:include page="includes/sidebar.jsp"/>
    <jsp:include page="includes/header.jsp"/>

    <div class="pcoded-main-container">
        <div class="pcoded-wrapper">
            <div class="pcoded-content">
                <div class="pcoded-inner-content">

                    <%-- Breadcrumb --%>
                    <div class="page-header mb-3">
                        <div class="page-block">
                            <div class="row align-items-center">
                                <div class="col-md-12">
                                    <div class="page-header-title">
                                        <h5 class="m-b-5">My Profile</h5>
                                        <span class="text-muted" style="font-size:0.83rem;">
                                            Manage your personal information and account security
                                        </span>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>

                    <div class="main-body">
                        <div class="page-wrapper">
                            <div class="profile-wrapper">

                                <%-- Flash alert --%>
                                <c:if test="${not empty flashMsg}">
                                    <div class="alert-profile ${flashType}">
                                        <i class="feather ${flashType eq 'success' ? 'icon-check-circle' : 'icon-alert-circle'}"></i>
                                        ${flashMsg}
                                    </div>
                                </c:if>

                                <div class="row">

                                    <%-- ── LEFT COL: Avatar card ── --%>
                                    <div class="col-md-4">
                                        <div class="avatar-card mb-4">
                                            <div class="avatar-circle">
                                                <c:choose>
                                                    <c:when test="${not empty profileUser.fullName and profileUser.fullName.length() >= 2}">
                                                        ${profileUser.fullName.substring(0,2).toUpperCase()}
                                                    </c:when>
                                                    <c:otherwise>US</c:otherwise>
                                                </c:choose>
                                            </div>
                                            <div class="user-name">${profileUser.fullName}</div>
                                            <div class="user-role">${profileUser.role}</div>
                                            <div class="user-meta"><i class="feather icon-mail"></i>${profileUser.email}</div>
                                            <c:if test="${not empty currentLocation}">
                                                <div class="user-meta"><i class="feather icon-map-pin"></i>${currentLocation.name}</div>
                                            </c:if>
                                            <div class="user-meta">
                                                <i class="feather icon-calendar"></i>
                                                Member since
                                                <fmt:formatDate value="${profileUser.createdAt}" pattern="MMM yyyy"/>
                                            </div>

                                            <%-- Ticket stats --%>
                                            <div class="stat-row">
                                                <div class="stat-chip">
                                                    <span class="num">${totalTickets}</span>
                                                    <span class="lbl">Total</span>
                                                </div>
                                                <div class="stat-chip">
                                                    <span class="num">${kpis.open + kpis.inProgress}</span>
                                                    <span class="lbl">Open</span>
                                                </div>
                                                <div class="stat-chip">
                                                    <span class="num">${kpis.resolved7d}</span>
                                                    <span class="lbl">Resolved 7d</span>
                                                </div>
                                            </div>
                                        </div>

                                        <%-- Account info (readonly) --%>
                                        <div class="section-card">
                                            <div class="section-header">
                                                <i class="feather icon-shield"></i>
                                                <h6>Account Info</h6>
                                            </div>
                                            <div class="section-body" style="padding: 16px 20px;">
                                                <div class="info-row">
                                                    <span class="info-label">Username</span>
                                                    <span class="info-value">
                                                        <i class="feather icon-user mr-1 text-muted" style="font-size:0.85rem;"></i>
                                                        ${profileUser.username}
                                                    </span>
                                                </div>
                                                <div class="info-row">
                                                    <span class="info-label">Role</span>
                                                    <span class="info-value">
                                                        <c:choose>
                                                            <c:when test="${profileUser.role eq 'EndUser'}">
                                                                <span class="badge-role user"><i class="feather icon-user"></i> End User</span>
                                                            </c:when>
                                                            <c:when test="${profileUser.role eq 'IT Support'}">
                                                                <span class="badge-role support"><i class="feather icon-tool"></i> IT Support</span>
                                                            </c:when>
                                                            <c:when test="${profileUser.role eq 'Manager'}">
                                                                <span class="badge-role manager"><i class="feather icon-briefcase"></i> Manager</span>
                                                            </c:when>
                                                            <c:otherwise>
                                                                <span class="badge-role admin"><i class="feather icon-settings"></i> ${profileUser.role}</span>
                                                            </c:otherwise>
                                                        </c:choose>
                                                    </span>
                                                </div>
                                                <div class="info-row">
                                                    <span class="info-label">Status</span>
                                                    <span class="info-value">
                                                        <c:choose>
                                                            <c:when test="${profileUser.active}">
                                                                <span style="color:#2e7d32; font-weight:600;">
                                                                    <i class="feather icon-check-circle mr-1"></i>Active
                                                                </span>
                                                            </c:when>
                                                            <c:otherwise>
                                                                <span style="color:#c62828; font-weight:600;">
                                                                    <i class="feather icon-x-circle mr-1"></i>Inactive
                                                                </span>
                                                            </c:otherwise>
                                                        </c:choose>
                                                    </span>
                                                </div>
                                            </div>
                                        </div>
                                    </div>

                                    <%-- ── RIGHT COL: Edit forms ── --%>
                                    <div class="col-md-8">

                                        <%-- Update personal info --%>
                                        <div class="section-card">
                                            <div class="section-header">
                                                <i class="feather icon-edit-2"></i>
                                                <h6>Personal Information</h6>
                                            </div>
                                            <div class="section-body">
                                                <form action="${pageContext.request.contextPath}/MyProfile"
                                                      method="post" id="infoForm">
                                                    <input type="hidden" name="action" value="updateInfo">

                                                    <div class="row">
                                                        <div class="col-md-6 mb-3">
                                                            <label class="field-label">Full Name <span class="text-danger">*</span></label>
                                                            <input type="text" name="fullName"
                                                                   class="form-control-profile"
                                                                   value="${profileUser.fullName}"
                                                                   maxlength="100" required>
                                                        </div>
                                                        <div class="col-md-6 mb-3">
                                                            <label class="field-label">Email <span class="text-danger">*</span></label>
                                                            <input type="email" name="email"
                                                                   class="form-control-profile"
                                                                   value="${profileUser.email}"
                                                                   maxlength="100" required>
                                                        </div>
                                                    </div>

                                                    <%-- Read-only fields --%>
                                                    <div class="row">
                                                        <div class="col-md-6 mb-3">
                                                            <label class="field-label">Username</label>
                                                            <input type="text" class="form-control-profile"
                                                                   value="${profileUser.username}" readonly>
                                                            <small class="text-muted" style="font-size:0.72rem;">
                                                                Username cannot be changed
                                                            </small>
                                                        </div>
                                                        <div class="col-md-6 mb-3">
                                                            <label class="field-label">Location <span class="text-danger">*</span></label>
                                                            <select name="locationId" class="form-control-profile" required>
                                                                <c:forEach var="loc" items="${locations}">
                                                                    <option value="${loc.id}"
                                                                        ${loc.id == profileUser.locationId ? 'selected' : ''}>
                                                                        ${loc.name}
                                                                    </option>
                                                                </c:forEach>
                                                            </select>
                                                        </div>
                                                    </div>

                                                    <div class="d-flex justify-content-end mt-2">
                                                        <button type="submit" class="btn-save">
                                                            <i class="feather icon-save mr-1"></i> Save Changes
                                                        </button>
                                                    </div>
                                                </form>
                                            </div>
                                        </div>

                                        <%-- Security section --%>
                                        <div class="section-card">
                                            <div class="section-header">
                                                <i class="feather icon-lock"></i>
                                                <h6>Security</h6>
                                            </div>
                                            <div class="section-body">
                                                <div class="d-flex justify-content-between align-items-center">
                                                    <div>
                                                        <div style="font-size:0.88rem; font-weight:600; color:#202124;">
                                                            Password
                                                        </div>
                                                        <div style="font-size:0.8rem; color:#80868b; margin-top:2px;">
                                                            Use a strong password with at least 6 characters
                                                        </div>
                                                    </div>
                                                    <button type="button" class="btn-change-pw"
                                                            onclick="openPasswordModal()">
                                                        <i class="feather icon-key mr-1"></i> Change Password
                                                    </button>
                                                </div>
                                            </div>
                                        </div>

                                        <%-- Ticket activity --%>
                                        <div class="section-card">
                                            <div class="section-header">
                                                <i class="feather icon-activity"></i>
                                                <h6>My Ticket Activity</h6>
                                            </div>
                                            <div class="section-body">
                                                <div class="row text-center">
                                                    <div class="col-3">
                                                        <div style="font-size:1.8rem; font-weight:700; color:#1a73e8;">${totalTickets}</div>
                                                        <div style="font-size:0.75rem; color:#80868b; text-transform:uppercase; letter-spacing:0.4px;">Total Submitted</div>
                                                    </div>
                                                    <div class="col-3">
                                                        <div style="font-size:1.8rem; font-weight:700; color:#f4a300;">${kpis.open}</div>
                                                        <div style="font-size:0.75rem; color:#80868b; text-transform:uppercase; letter-spacing:0.4px;">New / Open</div>
                                                    </div>
                                                    <div class="col-3">
                                                        <div style="font-size:1.8rem; font-weight:700; color:#0f9d58;">${kpis.inProgress}</div>
                                                        <div style="font-size:0.75rem; color:#80868b; text-transform:uppercase; letter-spacing:0.4px;">In Progress</div>
                                                    </div>
                                                    <div class="col-3">
                                                        <div style="font-size:1.8rem; font-weight:700; color:#9e9e9e;">${kpis.awaiting}</div>
                                                        <div style="font-size:0.75rem; color:#80868b; text-transform:uppercase; letter-spacing:0.4px;">Awaiting Approval</div>
                                                    </div>
                                                </div>
                                                <div class="mt-3 pt-3 border-top text-right">
                                                    <a href="${pageContext.request.contextPath}/MyTickets"
                                                       style="font-size:0.82rem; color:#1a73e8; font-weight:600; text-decoration:none;">
                                                        View all my tickets <i class="feather icon-arrow-right"></i>
                                                    </a>
                                                </div>
                                            </div>
                                        </div>

                                    </div><%-- end right col --%>
                                </div><%-- end row --%>
                            </div><%-- end profile-wrapper --%>
                        </div>
                    </div>

                </div>
            </div>
        </div>
    </div>

    <%-- ══ Password Modal ══════════════════════════════════════════════════════ --%>
    <div class="pw-modal-backdrop" id="pwModalBackdrop" onclick="closePwOnBackdrop(event)">
        <div class="pw-modal" style="position:relative;">
            <button class="close-btn" onclick="closePasswordModal()">
                <i class="feather icon-x"></i>
            </button>
            <h5><i class="feather icon-lock mr-2" style="color:#1a73e8;"></i>Change Password</h5>

            <form action="${pageContext.request.contextPath}/MyProfile"
                  method="post" id="pwForm" onsubmit="return validatePasswordForm()">
                <input type="hidden" name="action" value="changePassword">

                <div class="form-group">
                    <label class="field-label">Current Password <span class="text-danger">*</span></label>
                    <div class="pw-field-wrap">
                        <input type="password" name="currentPassword" id="currentPw"
                               class="form-control-profile" placeholder="Enter current password" required>
                        <button type="button" class="pw-toggle" onclick="togglePw('currentPw', this)">
                            <i class="feather icon-eye"></i>
                        </button>
                    </div>
                </div>

                <div class="form-group">
                    <label class="field-label">New Password <span class="text-danger">*</span></label>
                    <div class="pw-field-wrap">
                        <input type="password" name="newPassword" id="newPw"
                               class="form-control-profile" placeholder="At least 6 characters"
                               required oninput="checkStrength(this.value)">
                        <button type="button" class="pw-toggle" onclick="togglePw('newPw', this)">
                            <i class="feather icon-eye"></i>
                        </button>
                    </div>
                    <div class="pw-strength-bar"><div class="pw-strength-fill" id="strengthFill"></div></div>
                    <div class="pw-strength-text" id="strengthText" style="color:#80868b;"></div>
                </div>

                <div class="form-group">
                    <label class="field-label">Confirm New Password <span class="text-danger">*</span></label>
                    <div class="pw-field-wrap">
                        <input type="password" name="confirmPassword" id="confirmPw"
                               class="form-control-profile" placeholder="Repeat new password" required>
                        <button type="button" class="pw-toggle" onclick="togglePw('confirmPw', this)">
                            <i class="feather icon-eye"></i>
                        </button>
                    </div>
                    <div id="matchMsg" style="font-size:0.72rem; margin-top:3px;"></div>
                </div>

                <div class="d-flex justify-content-end gap-2 mt-2" style="gap:10px;">
                    <button type="button" class="btn-change-pw" onclick="closePasswordModal()">Cancel</button>
                    <button type="submit" class="btn-save">
                        <i class="feather icon-check mr-1"></i> Update Password
                    </button>
                </div>
            </form>
        </div>
    </div>

    <script src="assets/plugins/jquery/js/jquery.min.js"></script>
    <script src="assets/js/vendor-all.min.js"></script>
    <script src="assets/plugins/bootstrap/js/bootstrap.min.js"></script>
    <script src="assets/js/pcoded.min.js"></script>
    <script>
        // ── Modal controls ────────────────────────────────────────
        function openPasswordModal() {
            document.getElementById('pwModalBackdrop').classList.add('open');
            document.getElementById('currentPw').focus();
        }
        function closePasswordModal() {
            document.getElementById('pwModalBackdrop').classList.remove('open');
            document.getElementById('pwForm').reset();
            document.getElementById('strengthFill').style.width = '0';
            document.getElementById('strengthText').textContent = '';
            document.getElementById('matchMsg').textContent = '';
        }
        function closePwOnBackdrop(e) {
            if (e.target === document.getElementById('pwModalBackdrop')) closePasswordModal();
        }

        // ── Toggle show/hide password ─────────────────────────────
        function togglePw(fieldId, btn) {
            var f = document.getElementById(fieldId);
            var isText = f.type === 'text';
            f.type = isText ? 'password' : 'text';
            btn.querySelector('i').className = isText ? 'feather icon-eye' : 'feather icon-eye-off';
        }

        // ── Password strength indicator ───────────────────────────
        function checkStrength(val) {
            var fill = document.getElementById('strengthFill');
            var txt  = document.getElementById('strengthText');
            var score = 0;
            if (val.length >= 6)  score++;
            if (val.length >= 10) score++;
            if (/[A-Z]/.test(val)) score++;
            if (/[0-9]/.test(val)) score++;
            if (/[^A-Za-z0-9]/.test(val)) score++;

            var levels = [
                { w:'0%',   c:'#e53935', t:'' },
                { w:'25%',  c:'#e53935', t:'Weak' },
                { w:'50%',  c:'#f4a300', t:'Fair' },
                { w:'75%',  c:'#1e88e5', t:'Good' },
                { w:'100%', c:'#0f9d58', t:'Strong' },
            ];
            var l = levels[Math.min(score, 4)];
            fill.style.width = l.w;
            fill.style.background = l.c;
            txt.textContent = l.t;
            txt.style.color = l.c;
        }

        // ── Real-time confirm match ───────────────────────────────
        document.getElementById('confirmPw').addEventListener('input', function() {
            var msg = document.getElementById('matchMsg');
            if (!this.value) { msg.textContent = ''; return; }
            var match = this.value === document.getElementById('newPw').value;
            msg.textContent = match ? '✓ Passwords match' : '✗ Passwords do not match';
            msg.style.color = match ? '#0f9d58' : '#e53935';
        });

        // ── Form validation before submit ─────────────────────────
        function validatePasswordForm() {
            var np = document.getElementById('newPw').value;
            var cp = document.getElementById('confirmPw').value;
            if (np.length < 6) {
                alert('New password must be at least 6 characters.');
                return false;
            }
            if (np !== cp) {
                alert('Passwords do not match.');
                return false;
            }
            return true;
        }

        // ── Auto-open modal if changePassword flash is shown ──────
        <c:if test="${flashType eq 'error' and not empty flashMsg}">
        // Keep modal open on password error (heuristic)
        var msg = '${flashMsg}';
        if (msg.indexOf('mật khẩu') !== -1 || msg.indexOf('password') !== -1 ||
            msg.indexOf('Password') !== -1) {
            openPasswordModal();
        }
        </c:if>
    </script>
</body>
</html>
