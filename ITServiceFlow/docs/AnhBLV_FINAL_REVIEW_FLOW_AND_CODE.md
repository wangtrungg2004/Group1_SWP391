# AnhBLV - Final Review Flow + Code Walkthrough

Tai lieu nay tong hop luong hoat dong va map code cho cac chuc nang AnhBLV de demo/cham diem final.

## 1. Scope chuc nang (AnhBLV)

Theo `ProjectTracking.xlsx` (RMS, cot Owner = `AnhBLV`) va code hien tai:

1. Login & Auth
2. Password Hashing (SHA-256)
3. Login with Google
4. Forgot Password - Reset User Password
5. Create User Account
6. User Management - Edit & Status Control
7. Reopen Ticket
8. Temporary Permission Assignment
9. Role & Permission (RBAC)
10. SLA Breach Escalation Rule Engine

Phu luc theo hinh review ban gui:

11. Submit RFC (Request For Change)

## 2. Demo data de review

Dung script:

- `database/20260325_seed_anhblv_project_tracking_demo.sql`

Tai khoan seed (mat khau: `123456`):

- `anhblv.admin` (Admin)
- `anhblv.manager` (Manager)
- `anhblv.itsupport1`, `anhblv.itsupport2` (IT Support)
- `anhblv.user1`, `anhblv.user2` (User)

Ticket demo trong script:

- Reopen: `INC-ANHBLV-REOPEN-001`, `INC-ANHBLV-REOPEN-002`
- SLA: `INC-ANHBLV-SLA-BR-001`, `INC-ANHBLV-SLA-NB-001`, `INC-ANHBLV-SLA-NB-002`

## 3. Flow + code tung chuc nang

## 3.1 Login & Auth

What:

- Dang nhap bang username/password, tao session, redirect theo role.

Why:

- Mo khoa ngu canh nguoi dung cho tat ca module sau.

Flow:

1. User submit form `POST /Login`.
2. `controller.Login#doPost` lay input, trim, kiem tra account active.
3. Goi `UserService.login(username, password)`.
4. Service hash password SHA-256, DAO query `Users`.
5. Neu dung -> set session `user`, `role`, `userId`, `baseRole`, `effectiveRole`.
6. Redirect role:
7. `Admin -> /AdminDashboard`
8. `Manager -> /ManagerDashboard`
9. `User -> /UserDashboard`
10. `IT Support -> /ITDashboard`

Code map:

- `src/java/controller/Login.java`
- `src/java/service/UserService.java`
- `src/java/dao/UserDao.java`

Code snippet:

```java
Users user = userService.login(username, password);
session.setAttribute("user", user);
session.setAttribute("role", user.getRole());
switch (user.getRole()) {
    case "Admin": response.sendRedirect(ctx + "/AdminDashboard"); break;
    case "Manager": response.sendRedirect(ctx + "/ManagerDashboard"); break;
    case "User": response.sendRedirect(ctx + "/UserDashboard"); break;
    case "IT Support": response.sendRedirect(ctx + "/ITDashboard"); break;
}
```

## 3.2 Password Hashing (SHA-256)

What:

- Khong luu plain password, chi luu hash SHA-256.

Why:

- Giam rui ro lo mat khau khi lo DB.

Flow:

1. Create user/reset password/login deu qua `UserService`.
2. `PasswordUtil.sha256(rawPassword)` tao hash hex.
3. DAO compare/luu vao cot `PasswordHash`.

Code map:

- `src/java/Utils/PasswordUtil.java`
- `src/java/service/UserService.java`
- `src/java/dao/UserDao.java`

Code snippet:

```java
String passwordHash = PasswordUtil.sha256(rawPassword.trim());
return dao.login(username, passwordHash);   // so sanh PasswordHash
```

## 3.3 Login with Google

What:

- Dang nhap bang Google ID Token.

Why:

- Tang UX, giam quan ly mat khau.

Flow:

1. Frontend gui `credential` token den `POST /GoogleLogin`.
2. `GoogleAuthUtil.verifyIdToken()` goi Google `tokeninfo`.
3. Validate `aud == GOOGLE_CLIENT_ID`, `email_verified = true`.
4. Tim user active theo email trong DB.
5. Tao session + redirect theo role.

Code map:

- `src/java/controller/GoogleLogin.java`
- `src/java/Utils/GoogleAuthUtil.java`
- `src/java/service/UserService.java`

Code snippet:

```java
GoogleUserInfo info = GoogleAuthUtil.verifyIdToken(idToken, clientId);
Users user = userService.loginWithGoogleEmail(info.getEmail());
session.setAttribute("user", user);
redirectByRole(user.getRole(), request, response);
```

## 3.4 Forgot Password - Reset User Password

What:

- Quen mat khau -> gui link reset qua email.

Why:

- Khoi phuc truy cap an toan ma khong can admin reset tay.

Flow:

1. User nhap email tai `POST /ForgotPassword`.
2. Tao token reset (UUID, han 15 phut) -> luu `PasswordResetTokens`.
3. Gui email co link `/ResetPassword?token=...`.
4. User mo link, server validate token con han + chua dung.
5. User nhap mat khau moi -> hash -> update `Users.PasswordHash`.
6. Danh dau token da dung (`IsUsed = 1`).

Code map:

- `src/java/controller/ForgotPassword.java`
- `src/java/controller/ResetPassword.java`
- `src/java/service/UserService.java`
- `src/java/dao/UserDao.java`
- `src/java/Utils/EmailUtil.java`

Code snippet:

```java
String token = userService.createPasswordResetToken(email);
boolean sent = EmailUtil.sendForgotPasswordEmail(email, user.getUsername(), resetLink);
boolean updated = userService.resetPasswordByToken(token, newPassword);
```

## 3.5 Create User Account

What:

- Admin tao tai khoan noi bo (username, email, role, password, dept/location).

Why:

- Quan ly tai khoan tap trung.

Flow:

1. Admin vao `GET /UserCreate`.
2. Submit form `POST /UserCreate`.
3. Validate required fields, email format, role hop le, password >= 6, confirm match.
4. `UserService.createUser()` hash password.
5. `UserDao.createUser()` insert `Users`.

Code map:

- `src/java/controller/UserCreate.java`
- `src/java/service/UserService.java`
- `src/java/dao/UserDao.java`

Code snippet:

```java
if (!FIXED_ROLES.contains(role)) {
    request.setAttribute("error", "Role is not supported.");
    forward(...); return;
}
boolean success = userService.createUser(username, email, password, fullName, role, departmentId, locationId);
```

## 3.6 User Management - Edit & Status Control

What:

- Admin quan ly user list: sua info, doi role, activate/deactivate, gui email reset password.

Why:

- Van hanh he thong va support tai khoan.

Flow:

1. Admin vao `GET /UserManagement` (filter/search/paging).
2. Action `POST /UserManagement`:
3. `changeRole` -> update role.
4. `activate/deactivate` -> doi `IsActive`.
5. `resetPasswordEmail` -> tao token + gui email reset.
6. Ghi audit log moi action quan trong.

Code map:

- `src/java/controller/UserManagementController.java`
- `src/java/dao/UserDao.java`
- `src/java/service/UserService.java`
- `src/java/service/AuditLogService.java`

Code snippet:

```java
case "changeRole":
    handleChangeRole(request, session, currentUserId);
    break;
case "deactivate":
    handleSetActive(request, session, currentUserId, false);
    break;
```

## 3.7 Reopen Ticket

What:

- End-user reopen ticket da `Resolved/Closed` kem ly do.

Why:

- Xu ly truong hop issue tai phat/sua chua chua triet de.

Flow:

1. Nut `Reopen Ticket` chi hien khi status la `Resolved` hoac `Closed`.
2. User submit `POST /TicketReopen` voi `ticketId`, `reopenReason`.
3. Server validate:
4. owner ticket phai la current user
5. status hop le (`Resolved/Closed`)
6. reason bat buoc, <= 500 ky tu
7. `TicketDAO.reopenTicketForUser()` update status -> `Reopened`.
8. Tao comment `[Ticket Reopen Request] ...`.
9. Gui notification cho requester + IT + manager.
10. Ghi audit log `TICKET_REOPEN_REQUEST`.

Code map:

- `src/java/controller/ticket/user/TicketReopenController.java`
- `src/java/dao/TicketDAO.java` (`reopenTicketForUser`)
- `src/java/dao/TicketCommentsDAO.java`
- `src/java/dao/NotificationDao.java`
- `web/ticket/ticket_detail.jsp`

Code snippet:

```java
boolean reopened = ticketDao.reopenTicketForUser(ticketId, currentUser.getId());
TicketComments c = new TicketComments();
c.setContent("[Ticket Reopen Request] " + normalizedReason);
new TicketCommentsDAO().addComment(c);
sendReopenNotifications(ticket, ticketId, normalizedReason);
```

## 3.8 Temporary Permission Assignment

What:

- User/IT request quyen tam thoi (IT Support/Manager), Admin/Manager approve/reject/revoke, auto-expire.

Why:

- Dap ung nhu cau nang quyen ngan han khong doi role vinh vien.

Flow:

1. User vao `GET /TemporaryAccessRequest`, xem role hien tai + request history.
2. Submit request `POST action=create` (`requestedRole`, `durationMinutes`, `reason`).
3. Service validate role rank, duration, reason, pending/active conflict.
4. Admin/Manager vao `GET /TemporaryAccessApproval` de duyet.
5. Action `approve/reject/revoke` qua `processDecision`.
6. User co request da approved co the `activate`/`deactivate` role tam thoi.
7. Filter + service dong bo role session moi request; request het han se auto `Expired`.

Code map:

- `src/java/controller/Security/TemporaryAccessRequestController.java`
- `src/java/controller/Security/TemporaryAccessApprovalController.java`
- `src/java/service/TemporaryRoleAccessService.java`
- `src/java/dao/TemporaryRoleRequestDao.java`
- `src/java/filter/TemporaryRoleSyncFilter.java`
- `web/TemporaryAccessRequest.jsp`
- `web/TemporaryAccessApproval.jsp`

Code snippet:

```java
ActionResult result = temporaryRoleAccessService.submitRequest(
    userId, currentRole, requestedRole, durationMinutes, reason
);
// approve/reject/revoke
ActionResult decision = temporaryRoleAccessService.processDecision(requestId, approverId, action, comment);
```

## 3.9 Role & Permission (RBAC)

What:

- He thong phan quyen theo role + enforce truy cap URL.

Why:

- Bao dam user chi truy cap dung chuc nang duoc cap.

Flow:

1. Login set role trong session.
2. `AuthorizationFilter` intercept cac URL bao ve.
3. Sync lai effective role (co the bi anh huong temporary role).
4. Kiem tra rule:
5. Admin -> admin pages
6. User/Manager -> user pages
7. IT Support -> IT pages
8. Khong hop le -> `403` hoac redirect login.
9. Admin co the doi role user trong `UserManagement`.

Code map:

- `src/java/filter/AuthorizationFilter.java`
- `src/java/controller/UserManagementController.java` (`changeRole`)
- `src/java/dao/UserDao.java` (`updateUserRoleForAdmin`)
- `web/includes/sidebar.jsp` (menu theo role)

Code snippet:

```java
if (path.contains("AdminDashboard") || path.startsWith("/admin/")) {
    hasAccess = "Admin".equals(role);
} else if (path.contains("ITDashboard") || path.startsWith("/it/")) {
    hasAccess = "IT Support".equals(role);
}
```

## 3.10 SLA Breach Escalation Rule Engine

What:

- Engine giam sat han SLA, canh bao theo stage `2h`, `30m`, `breached`, gui notification va luu escalation history.

Why:

- Giam missed SLA, tang kha nang can thiep som cho IT/Manager.

Flow:

1. `SLAEscalationFilter` chay theo request va trigger sweep moi ~60s.
2. `SLATrackingService.runEscalationSweep()`:
3. dong bo `IsBreached` cho ticket unresolved da qua han
4. lay candidate unresolved co deadline <= 2h
5. tinh `RemainingMinutes` va chon stage:
6. `<0` -> `BREACHED`
7. `<=30` -> `NEAR_BREACH_30M`
8. `<=120` -> `NEAR_BREACH_2H`
9. Gui notification cho reporter + assignee + manager.
10. Deduplicate theo `(TicketId, StageCode, ResolutionDeadline)` truoc khi insert history.

Code map:

- `src/java/filter/SLAEscalationFilter.java`
- `src/java/service/SLATrackingService.java`
- `src/java/dao/SLATrackingDao.java`
- `src/java/controller/SLA/SLADashboard.java`
- `src/java/controller/SLA/SLABreachList.java`

Code snippet:

```java
if (remainingMinutes < 0) {
    triggerEscalation(..., "BREACHED", ...);
} else if (remainingMinutes <= 30) {
    triggerEscalation(..., "NEAR_BREACH_30M", ...);
} else if (remainingMinutes <= 120) {
    triggerEscalation(..., "NEAR_BREACH_2H", ...);
}
```

## 3.11 (Phu luc) Submit RFC - Request For Change

Phan nay them theo hinh review ban gui (US_10).

What:

- IT Support tao RFC (Draft/Pending Approval), Manager duyet/tu choi, thong bao hai chieu.

Flow:

1. IT Support vao `GET /SubmitChangeRequest`.
2. Dien form + submit:
3. `action=draft` -> luu `Draft`
4. `action=submit` -> `Pending Approval` + thong bao Manager
5. IT Support xem danh sach `GET /MyChangeRequests`, co the submit draft.
6. Manager vao `GET /ManagerChangeApprovals`, xem chi tiet `action=view`.
7. Manager `approve/reject` qua `POST /ManagerChangeApprovals`.
8. He thong cap nhat status RFC + luu approval history + thong bao IT Support.

Code map:

- `src/java/controller/Service/SubmitChangeRequest.java`
- `src/java/controller/Service/MyChangeRequests.java`
- `src/java/controller/Service/ManagerChangeApprovals.java`
- `src/java/service/ApprovalService.java`
- `src/java/dao/ChangeRequestDao.java`
- `web/SubmitChangeRequest.jsp`
- `web/MyChangeRequests.jsp`
- `web/ManagerChangeApprovals.jsp`
- `web/RFCDetail.jsp`

Code snippet:

```java
int result = service.submitChangeRequest(..., linkedTicketId, savedAsDraft);
if (!savedAsDraft) {
    for (Users mgr : dao.getAllManagers()) {
        notifDao.addNotification(mgr.getId(), "RFC moi can duyet...", null, false, "Change Request Moi", "ChangeRequest");
    }
}
```

## 4. Diem can nhan manh khi review voi thay

1. Co day du luong tu UI -> Controller -> Service -> DAO -> DB.
2. Co enforce permission ro rang (session role + filter + role-based menu).
3. Co audit/notification cho cac action quan trong (reopen, temp access, RFC, SLA escalation).
4. Co data seed de demo nhanh va lap lai duoc.
5. Co bo sequence/class diagram cho 10 feature AnhBLV:
6. `docs/AnhBLV_PlantUML/01_...` den `docs/AnhBLV_PlantUML/10_...`

## 5. Thu tu demo de an diem (goi y)

1. Chay seed SQL `20260325_seed_anhblv_project_tracking_demo.sql`.
2. Demo Login/Auth + RBAC redirect theo role.
3. Demo Create User + User Management (doi role, deactivate, reset email).
4. Demo Reopen ticket (`INC-ANHBLV-REOPEN-001`) va notifications.
5. Demo Temporary Access request -> approve -> activate -> revoke/expire.
6. Demo SLA dashboard/breach list va escalation notifications (mo app > 60s de sweep).
7. Neu thay hoi US_10, demo Submit RFC -> Manager approve/reject.

