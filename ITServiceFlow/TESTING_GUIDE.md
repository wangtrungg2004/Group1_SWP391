# QUICK SUMMARY & TESTING GUIDE

## 📌 CHEAT SHEET - AUTHENTICATION & AUTHORIZATION

### 1. QUICK REFERENCE TABLE

| Feature | Entry Point | Key Method | DB Query | Output |
|---------|------------|------------|----------|--------|
| **Login** | POST /Login | UserService.login() | WHERE Username=? AND PasswordHash=? | Users object + Session |
| **Forgot** | POST /ForgotPassword | UserService.createPasswordResetToken() | INSERT PasswordResetTokens | Token + Email |
| **Reset** | POST /ResetPassword | UserService.resetPasswordByToken() | UPDATE Users password | Redirect to Login |
| **Google** | POST /GoogleLogin | GoogleAuthUtil.verifyIdToken() | OAuth API + Users table | Users object + Session |
| **Auth** | Any protected URL | AuthorizationFilter | Session + Role check | Allow/Deny (403) |

---

## 🧪 TESTING SCENARIOS

### Test 1: Successful Login

#### Test Data:
```
Username: john
Password: 123456
Expected Role: Manager
Expected Redirect: /ManagerDashboard.jsp
```

#### Steps:
1. Open http://localhost:8080/ITServiceFlow/Login.jsp
2. Enter:
   - Username: john
   - Password: 123456
3. Click Login
4. Verify: Should redirect to ManagerDashboard.jsp

#### What happens:
```
Login.doPost()
  → UserService.login("john", "123456")
    → PasswordUtil.sha256("123456") = "8d969eef..."
    → UserDao.login("john", "8d969eef...")
      → SQL: SELECT FROM Users WHERE Username='john' AND PasswordHash='8d969eef...' AND IsActive=1
      → Result: Returns Users{Id=1, Role="Manager"}
    → Returns Users object
  → Create session: user=Users, role="Manager", userId=1
  → switch("Manager") → sendRedirect("ManagerDashboard.jsp")
  → Browser redirects to ManagerDashboard.jsp
  → AuthorizationFilter intercepts:
    - Is /ManagerDashboard.jsp public? NO
    - Session exists? YES
    - User exists? YES
    - Role? "Manager"
    - Has access? YES (Manager can access own dashboard)
    → Allow request to proceed
  → ManagerDashboard.jsp loads
  → Success!
```

#### Verification:
```
✓ Redirect to correct dashboard
✓ Session has user object
✓ Session has role "Manager"
✓ URL shows ManagerDashboard.jsp
```

---

### Test 2: Login with Wrong Password

#### Test Data:
```
Username: john
Password: wrongpassword
Expected: Error message
Expected Redirect: Login.jsp with error
```

#### Steps:
1. Open Login.jsp
2. Enter:
   - Username: john
   - Password: wrongpassword
3. Click Login
4. Verify: Should see error "Invalid username or password"

#### What happens:
```
Login.doPost()
  → UserService.login("john", "wrongpassword")
    → Hash: PasswordUtil.sha256("wrongpassword") = "a1b2c3d4..."
    → UserDao.login("john", "a1b2c3d4...")
      → SQL: SELECT FROM Users WHERE Username='john' AND PasswordHash='a1b2c3d4...' AND IsActive=1
      → Result: No match (correct hash is "8d969eef...", not "a1b2c3d4...")
      → Returns NULL
  → user == null
  → setAttribute("error", "Invalid username or password")
  → forwardLogin() → forward to Login.jsp
  → ELF displays error message
  → User stays on Login page
```

#### Verification:
```
✓ No redirect (stays on Login.jsp)
✓ Error message visible
✓ No session created
```

---

### Test 3: Forgot Password Flow

#### Test Data:
```
Email: john@example.com
New Password: newpass123
Expected: Success message → Password changed
```

#### Steps:
1. Open ForgotPassword.jsp
2. Enter email: john@example.com
3. Click Submit
4. Check email inbox
5. Click reset link from email
6. Enter new password: newpass123
7. Confirm: newpass123
8. Click Reset
9. Verify: Success message
10. Go to Login.jsp
11. Login with username: john, password: newpass123
12. Verify: Should login successfully

#### Database Changes:
```
BEFORE:
Users: Id=1, Username=john, PasswordHash=8d969eef...
PasswordResetTokens: (empty)

DURING:
1. User submits email
2. System checks: Email exists? YES
3. System creates token: UUID.randomUUID() = "550e8400-e29b-41d4-a716-446655440000"
4. System saves to DB:
   INSERT INTO PasswordResetTokens (UserId, Token, ExpiresAt, IsUsed)
   VALUES (1, '550e8400-e29b-41d4-a716-446655440000', '2025-03-02 10:15:00', 0)
5. System sends email with link

6. User clicks link with token
7. System validates: Token exists AND IsUsed=0 AND ExpiresAt>NOW → YES
8. User enters new password: "newpass123"
9. System validates: Passwords match? YES, Length>=6? YES
10. System hashes: PasswordUtil.sha256("newpass123") = "a1b2c3d4e5f6..."
11. System updates:
    UPDATE Users SET PasswordHash='a1b2c3d4e5f6...' WHERE Id=1
    UPDATE PasswordResetTokens SET IsUsed=1 WHERE Token='550e8400-e29b-41d4-a716-446655440000'

AFTER:
Users: Id=1, Username=john, PasswordHash=a1b2c3d4e5f6...  ← CHANGED
PasswordResetTokens: Token=550e8400-..., IsUsed=1          ← MARKED USED
```

#### Verification:
```
✓ Email received with reset link
✓ Link expires in 15 minutes
✓ Can reset password
✓ Token can't be reused (IsUsed=1)
✓ Can login with new password
✓ Old password no longer works
```

---

### Test 4: Forgot Password - Expired Token

#### Test Data:
```
Email: john@example.com
Wait: > 15 minutes
Expected: Error "Invalid or expired reset link"
```

#### Steps:
1. Submit forgot password request
2. Get reset link from email
3. Wait 15+ minutes
4. Click reset link
5. Verify: Should see error

#### What happens:
```
ResetPassword.doGet()
  → Extract token from URL
  → Call UserService.isValidResetToken(token)
    → UserDao.getValidUserIdByToken(token)
      → SQL: SELECT UserId FROM PasswordResetTokens
             WHERE Token=? AND IsUsed=0 AND ExpiresAt>GETDATE()
      → Current time: 2025-03-02 10:20:00
      → ExpiresAt: 2025-03-02 10:15:00
      → ExpiresAt > GETDATE()? 10:15:00 > 10:20:00? NO ← EXPIRED
      → Result: 0 rows
      → Returns NULL
    → userId == null → Returns false
  → isValidResetToken() returns false
  → setAttribute("error", "Invalid or expired reset link")
  → Forward to ForgotPassword.jsp
  → User sees error
```

#### Verification:
```
✓ Can't reset with expired token
✓ Error message shown
✓ User redirected to forgot password page
✓ User must request new reset link
```

---

### Test 5: Google Login

#### Test Data:
```
Google Account: john@gmail.com
Email in DB: john@gmail.com
Expected: Login successful, redirect based on role
```

#### Prerequisites:
1. GOOGLE_CLIENT_ID configured in mail.properties
2. John@gmail.com account exists in Users table with IsActive=1
3. Google One Tap enabled on Login.jsp

#### Steps:
1. Open Login.jsp
2. Look for Google One Tap
3. Click on Google account email
4. Verify: Redirected to dashboard

#### What happens:
```
Frontend:
  → Google One Tap loads
  → User selects account
  → Google returns JWT credential

Backend (GoogleLogin.doPost):
  → Get credential (ID Token) from form
  → Get GOOGLE_CLIENT_ID from config
  → Call GoogleAuthUtil.verifyIdToken(credential, clientId)
    → URL encode token
    → Call: https://oauth2.googleapis.com/tokeninfo?id_token=...
    → Google API returns: {"aud":"...", "email":"john@gmail.com", "email_verified":true, ...}
    → Validate: aud==clientId? email_verified==true? email not blank?
    → All valid → Return GoogleUserInfo{email:"john@gmail.com", ...}
  → Call UserService.loginWithGoogleEmail("john@gmail.com")
    → UserDao.getUserByEmail("john@gmail.com")
      → SQL: SELECT FROM Users WHERE Email='john@gmail.com' AND IsActive=1
      → Result: Returns Users{Id=2, Role="Manager"}
  → user != null → Login successful
  → Create session: user=Users, role="Manager"
  → redirectByRole("Manager") → sendRedirect("ManagerDashboard.jsp")
  → Browser redirects
  → AuthorizationFilter allows
  → Dashboard loads
```

#### Verification:
```
✓ Google One Tap appears
✓ Can select account
✓ Redirects to correct dashboard
✓ Session created with correct role
✓ Can access protected pages
```

---

### Test 6: Google Login - Account Not Found

#### Test Data:
```
Google Account: unknown@gmail.com
Email NOT in DB: unknown@gmail.com doesn't exist
Expected: Error message
```

#### Steps:
1. Open Login.jsp
2. Try to login with unknown Google account
3. Verify: Error message "No active account linked to this Google email"

#### What happens:
```
GoogleLogin.doPost()
  → Verify token with Google → Success
  → Extract email: "unknown@gmail.com"
  → UserService.loginWithGoogleEmail("unknown@gmail.com")
    → UserDao.getUserByEmail("unknown@gmail.com")
      → SQL: SELECT FROM Users WHERE Email='unknown@gmail.com' AND IsActive=1
      → Result: 0 rows (email not in database)
      → Returns NULL
  → user == null
  → setAttribute("error", "No active account linked to this Google email")
  → Forward to Login.jsp
  → User sees error
```

#### Verification:
```
✓ Error message shown
✓ No account created automatically
✓ User must have account created by admin first
✓ Email must exist in Users table
```

---

### Test 7: Authorization - Role-Based Access

#### Test Data:
```
User: Manager (john)
Trying to access: /AdminDashboard.jsp
Expected: 403 Forbidden
```

#### Steps:
1. Login as john (Manager)
2. Try to access: http://localhost:8080/ITServiceFlow/AdminDashboard.jsp
3. Verify: Should see 403 Forbidden error

#### What happens:
```
Request: GET /AdminDashboard.jsp
  ↓
AuthorizationFilter.doFilter()
  → Get requestURI: "/ITServiceFlow/AdminDashboard.jsp"
  → Extract path: "/AdminDashboard.jsp"
  → Is public path? ("/Login.jsp", "/ForgotPassword.jsp", etc.) → NO
  → Get session: session exists with user
  → Get user from session: "john"
  → Get role from session: "Manager"
  → Is "Admin"? → NO
  → Call hasAccessByRole("Manager", "/AdminDashboard.jsp")
    → Switch on "Manager":
      → Does path match Manager permissions?
      → "/AdminDashboard.jsp" in list? NO
      → Return false
  → hasAccess = false
  → httpResponse.sendError(403, "Bạn không có quyền truy cập")
  → Return 403 Forbidden
```

#### Verification:
```
✓ 403 Forbidden error shown
✓ Can't access admin pages
✓ Manager access to manager pages still works
✓ User can only access their own pages
```

---

### Test 8: Authorization - NOT Logged In

#### Test Data:
```
No session
Trying to access: /ManagerDashboard.jsp
Expected: Redirect to Login.jsp
```

#### Steps:
1. Clear cookies (or use incognito mode)
2. Try to access: http://localhost:8080/ITServiceFlow/ManagerDashboard.jsp
3. Verify: Should redirect to Login.jsp

#### What happens:
```
Request: GET /ManagerDashboard.jsp
  ↓
AuthorizationFilter.doFilter()
  → Get session(false): Returns NULL (no current session)
  → session == null → true
  → httpResponse.sendRedirect("/Login.jsp")
  → Redirect to login page
```

#### Verification:
```
✓ Redirects to Login.jsp
✓ Can't access protected content without login
✓ Session timeout also triggers this
```

---

## 📊 TESTING CHECKLIST

### Login Tests:
- [ ] Login with correct username & password
- [ ] Login with incorrect password
- [ ] Login with non-existent username
- [ ] Login with deactivated account (IsActive=0)
- [ ] Login with empty username
- [ ] Login with empty password
- [ ] Session created correctly after login
- [ ] Correct redirect based on role
- [ ] Database connection error handling

### Forgot Password Tests:
- [ ] Request reset with existing email
- [ ] Request reset with non-existent email
- [ ] Email received with reset link
- [ ] Reset link valid (within 15 mins)
- [ ] Reset link expired after 15 mins
- [ ] Reset link can't be reused
- [ ] Password update with matching passwords
- [ ] Password update with non-matching passwords
- [ ] Password too short (< 6 chars)
- [ ] Login after password reset works
- [ ] Old password no longer works

### Google Login Tests:
- [ ] GOOGLE_CLIENT_ID configured
- [ ] Google One Tap displays
- [ ] Token verification succeeds
- [ ] Token verification fails with invalid token
- [ ] User account found in database
- [ ] User account not found (error)
- [ ] IsActive check (can't login if inactive)
- [ ] Session created correctly
- [ ] Redirect to correct dashboard

### Authorization Tests:
- [ ] Admin access to all pages
- [ ] Manager access to manager pages
- [ ] Manager can't access admin pages
- [ ] User access to user pages
- [ ] User can't access manager pages
- [ ] IT Support access to support pages
- [ ] Public pages (login, forgot) don't require auth
- [ ] Protected pages redirect if not logged in
- [ ] 403 error for unauthorized access
- [ ] Session timeout redirect to login

---

## 🔍 DEBUGGING TIPS

### Common Issues:

#### Issue 1: "Invalid username or password" but credentials look correct
```
Debug:
1. Check if username exists in database
2. Check if password hash matches
   - Raw password: "123456"
   - Expected hash: "8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6472"
3. Verify user IsActive = 1
4. Check for whitespace in input (trim issue)

SQL to check:
SELECT * FROM Users WHERE Username='john';
SELECT * FROM Users WHERE Email='john@example.com';
```

#### Issue 2: Email not received from forgot password
```
Debug:
1. Check mail.properties configuration
2. Verify email credentials are correct
3. Check if Gmail app password is set (not regular password)
4. Verify SMTP host and port:
   - Host: smtp.gmail.com
   - Port: 587
5. Check firewall/internet connection
6. Check email "from" address is configured

Log statements:
System.out.println("Sending email to: " + email);
System.out.println("Reset link: " + resetLink);
```

#### Issue 3: Google login showing "not configured"
```
Debug:
1. Check GOOGLE_CLIENT_ID environment variable
   - Windows: set GOOGLE_CLIENT_ID=...
   - Linux: export GOOGLE_CLIENT_ID=...
2. Check mail.properties file
3. Verify client ID format (should be like: 123456789-abcdefgh.apps.googleusercontent.com)
4. Restart application after setting env var

Verify:
String clientId = GoogleAuthUtil.getGoogleClientId();
System.out.println("Client ID: " + clientId);
```

#### Issue 4: 403 Forbidden on dashboard
```
Debug:
1. Check if logged in (check session)
2. Check user role:
   SELECT Role FROM Users WHERE Username='john';
3. Check filter permissions for role:
   - Manager should have access to /ManagerDashboard.jsp
   - Admin can access anything
4. Check if path matches filter pattern

Test:
String role = (String) session.getAttribute("role");
System.out.println("User role: " + role);
```

#### Issue 5: Database connection fails
```
Debug:
1. Check SQL Server is running
2. Verify connection string:
   - Server: localhost:1433
   - Database: ITServiceDB
   - User: sa
   - Password: correct
3. Check firewall allows SQL Server port (1433)

Test connection:
String url = "jdbc:sqlserver://localhost:1433;databaseName=ITServiceDB;";
Connection conn = DriverManager.getConnection(url, "sa", "password");
System.out.println(conn != null ? "Connected" : "Failed");
```

---

## 📚 ADDITIONAL RESOURCES

### Files to Study:
1. [REVIEW_AUTH_FEATURES.md](REVIEW_AUTH_FEATURES.md) - Detailed feature overview
2. [FLOW_DIAGRAMS.md](FLOW_DIAGRAMS.md) - Visual flow diagrams
3. [CODE_REFERENCE.md](CODE_REFERENCE.md) - Code implementation examples
4. [DATABASE_CONFIG.md](DATABASE_CONFIG.md) - Database schema and config

### Key Files in Project:
```
src/java/controller/
  - Login.java
  - GoogleLogin.java
  - ForgotPassword.java
  - ResetPassword.java

src/java/service/
  - UserService.java

src/java/dao/
  - UserDao.java

src/java/filter/
  - AuthorizationFilter.java

src/java/Utils/
  - PasswordUtil.java
  - GoogleAuthUtil.java
  - EmailUtil.java
  - DbContext.java

src/java/model/
  - Users.java

web/
  - Login.jsp
  - ForgotPassword.jsp
  - ResetPassword.jsp
  - AdminDashboard.jsp
  - ManagerDashboard.jsp
  - UserDashboard.jsp
  - ITDashboard.jsp
```

---

## 📝 NOTES FOR IMPROVEMENT

### Security Enhancements:
- [ ] Implement rate limiting on login attempts
- [ ] Add 2FA (Two-Factor Authentication)
- [ ] Use bcrypt instead of SHA-256
- [ ] Add CSRF token validation
- [ ] Implement password hashing with salt
- [ ] Add login attempt logging
- [ ] Implement account lockout after failed attempts

### Feature Enhancements:
- [ ] Auto-create account for Google login
- [ ] Password complexity requirements
- [ ] Password history (can't reuse old passwords)
- [ ] Session timeout with warning
- [ ] "Remember me" functionality
- [ ] Multi-device login
- [ ] Login history and audit logs

### Code Quality:
- [ ] Add unit tests for each service
- [ ] Add integration tests
- [ ] Add logging framework (SLF4J)
- [ ] Refactor duplicated code
- [ ] Add input validation utility class
- [ ] Implement connection pooling
- [ ] Add caching for performance

---
