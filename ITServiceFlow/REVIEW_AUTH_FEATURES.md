# PHÂN TÍCH CHI TIẾT CÁC CHỨC NĂNG AUTHENTICATION & AUTHORIZATION

## 📋 MỤC LỤC
1. Tổng quan hệ thống
2. Chi tiết chức năng Login
3. Chi tiết chức năng Forgot Password
4. Chi tiết chức năng Google Login
5. Phân quyền (Authorization)
6. Luồng dữ liệu
7. Sơ đồ kiến trúc

---

## 1️⃣ TỔNG QUAN HỆ THỐNG

### Kiến trúc MVC
```
Controllers (Servlet)
    ↓
Services (Business Logic)
    ↓
DAOs (Database Access)
    ↓
Database (SQL Server)
```

### Các thành phần chính:
- **Controllers**: Login, GoogleLogin, ForgotPassword, ResetPassword
- **Services**: UserService
- **DAOs**: UserDao
- **Filters**: AuthorizationFilter
- **Utils**: PasswordUtil, GoogleAuthUtil, EmailUtil

---

## 2️⃣ CHỨC NĂNG LOGIN (Đăng nhập)

### A. Luồng hoạt động
```
User nhập username + password
    ↓
Login Controller (doPost)
    ↓
Trim input & gọi UserService.login()
    ↓
PasswordUtil.sha256() - mã hóa password
    ↓
UserDao.login() - kiểm tra DB
    ↓
Nếu thành công: Tạo session + redirect theo role
Nếu thất bại: Hiển thị error message
```

### B. Các methods liên quan

#### **Controller: Login.java**
```java
// Xử lý đăng nhập
doPost(HttpServletRequest, HttpServletResponse)
    - Lấy username & password từ form
    - Trim whitespace
    - Gọi UserService.login()
    - Tạo HttpSession với user, role, userId
    - Redirect theo role (Admin/Manager/User/IT Support)
    - Nếu lỗi: forward tới Login.jsp với error message

doGet(HttpServletRequest, HttpServletResponse)
    - Forward tới Login.jsp để hiển thị form
```

#### **Service: UserService.login()**
```java
public Users login(String Username, String RawPassword)
    - Kiểm tra null/empty
    - Mã hóa password: passwordHash = PasswordUtil.sha256(RawPassword.trim())
    - Gọi UserDao.login(Username, passwordHash)
    - Trả về Users object hoặc null
```

#### **DAO: UserDao.login()**
```java
public Users login(String username, String passwordHash)
    - Kiểm tra null/empty & connection
    - SQL: SELECT Id, Username, FullName, Role, IsActive
           FROM Users
           WHERE Username = ? AND PasswordHash = ? AND IsActive = 1
    - Trả về Users object nếu tìm thấy
```

#### **Model: Users.java**
```
Trường quan trọng:
- int Id: ID người dùng
- String Username: Tên đăng nhập
- String FullName: Họ tên đầy đủ
- String Role: Vai trò (Admin, Manager, User, IT Support)
- String Email: Email
- boolean IsActive: Trạng thái hoạt động
- int DepartmentId: ID phòng ban
- int LocationId: ID vị trí
```

#### **Utils: PasswordUtil.sha256()**
```java
- Sử dụng MessageDigest với thuật toán SHA-256
- Chuyển đổi bytes thành hex string
- Mã hóa single-pass (không reversible)
```

### C. Điểm quan trọng
✅ Kiểm tra user IsActive = 1 (chỉ active users mới login được)
✅ Kiểm tra connection database
✅ Trim whitespace từ input
✅ Sử dụng SHA-256 để mã hóa password
❌ Không có rate limiting (có thể bị brute force)
❌ Không có 2FA (Two-Factor Authentication)

---

## 3️⃣ CHỨC NĂNG FORGOT PASSWORD (Quên mật khẩu)

### A. Luồng hoạt động
```
User nhập email
    ↓
ForgotPassword Controller (doPost)
    ↓
Kiểm tra email tồn tại
    ↓
UserService.createPasswordResetToken()
    - Tạo UUID token
    - Lưu token với thời gian hết hạn (15 phút)
    ↓
EmailUtil.sendForgotPasswordEmail()
    - Gửi email với link reset
    ↓
Hiển thị success message
```

### B. Các methods liên quan

#### **Controller: ForgotPassword.java**
```java
doPost(HttpServletRequest, HttpServletResponse)
    1. Lấy email từ form & trim
    2. Kiểm tra email blank → error
    3. Gọi UserService.getUserByEmail(email)
    4. Nếu user không tồn tại → error
    5. Gọi UserService.createPasswordResetToken(email)
    6. Nếu token = null → error
    7. Gọi EmailUtil.sendForgotPasswordEmail()
    8. Nếu gửi thất bại → error
    9. Hiển thị success message
```

#### **Service: UserService.createPasswordResetToken()**
```java
public String createPasswordResetToken(String email)
    1. Lấy user từ email
    2. Nếu user = null → return null
    3. Tạo token: UUID.randomUUID().toString()
    4. Tính thời gian hết hạn: 15 phút từ giờ hiện tại
    5. Gọi UserDao.savePasswordResetToken()
    6. Trả về token hoặc null
```

#### **DAO: UserDao.savePasswordResetToken()**
```java
public boolean savePasswordResetToken(int userId, String token, Timestamp expiresAt)
    - SQL: INSERT INTO PasswordResetTokens 
           (UserId, Token, ExpiresAt, IsUsed)
           VALUES (?, ?, ?, 0)
    - Lưu token với IsUsed = 0 (chưa dùng)
    - Trả về true/false
```

#### **Utils: EmailUtil.sendForgotPasswordEmail()**
```
- Gửi email với tiêu đề: "Quên mật khẩu"
- Body có link: http://domain/ResetPassword?token=TOKEN
- Sử dụng cấu hình email từ mail.properties
```

### C. Điểm quan trọng
✅ Token có thời gian hết hạn (15 phút)
✅ Token chỉ dùng 1 lần (IsUsed flag)
✅ Gửi link qua email an toàn
❌ Email config cần được setup đúng
❌ Không có xác thực email trước khi gửi

---

## 4️⃣ CHỨC NĂNG GOOGLE LOGIN (Đăng nhập qua Google)

### A. Luồng hoạt động
```
User click "Login with Google"
    ↓
Google One Tap / Google Sign-In Modal hiện lên
    ↓
User chọn tài khoản Google
    ↓
Google trả về ID Token
    ↓
GoogleLogin Controller (doPost)
    ↓
GoogleAuthUtil.verifyIdToken()
    - Xác minh token với Google oauth2.googleapis.com
    - Kiểm tra email_verified = true
    ↓
UserService.loginWithGoogleEmail()
    - Tìm user theo email
    ↓
Nếu user tồn tại: Tạo session + redirect theo role
Nếu user không tồn tại: Hiển thị error
```

### B. Các methods liên quan

#### **Controller: GoogleLogin.java**
```java
doPost(HttpServletRequest, HttpServletResponse)
    1. Lấy credential (ID Token) từ form
    2. Lấy GOOGLE_CLIENT_ID từ config
    3. Kiểm tra CLIENT_ID → error nếu không có
    4. Gọi GoogleAuthUtil.verifyIdToken()
    5. Nếu xác minh thất bại → error
    6. Gọi UserService.loginWithGoogleEmail(email)
    7. Nếu user không tồn tại → error
    8. Tạo session (user, role, userId)
    9. Gọi redirectByRole() để redirect
```

#### **Service: UserService.loginWithGoogleEmail()**
```java
public Users loginWithGoogleEmail(String email)
    1. Kiểm tra email null/empty
    2. Gọi UserDao.getUserByEmail(email.trim())
    3. Trả về Users object
```

#### **DAO: UserDao.getUserByEmail()**
```java
public Users getUserByEmail(String email)
    - SQL: SELECT Id, Username, Email, FullName, Role, IsActive
           FROM Users
           WHERE Email = ? AND IsActive = 1
    - Trả về Users object hoặc null
```

#### **Utils: GoogleAuthUtil.verifyIdToken()**
```java
public static GoogleUserInfo verifyIdToken(String idToken, String expectedClientId)
    1. URLEncode ID Token
    2. Gọi: https://oauth2.googleapis.com/tokeninfo?id_token=TOKEN
    3. Parse JSON response
    4. Kiểm tra:
       - aud (audience) == expectedClientId
       - email_verified == true
       - email không null/empty
    5. Trả về GoogleUserInfo object hoặc null
```

#### **GoogleUserInfo class**
```java
public class GoogleUserInfo {
    String email;      // Email từ Google
    String aud;        // Client ID
    boolean emailVerified;
}
```

#### **GoogleAuthUtil.getGoogleClientId()**
```
Tìm GOOGLE_CLIENT_ID từ (theo thứ tự):
1. System environment variable: GOOGLE_CLIENT_ID
2. System property: GOOGLE_CLIENT_ID
3. mail.properties file
```

### C. Điểm quan trọng
✅ Xác minh token trực tiếp với Google (không thể giả mạo)
✅ Kiểm tra email verified
✅ Không cần lưu password Google
✅ An toàn hơn login thường (có 2FA từ Google)
❌ Cần config GOOGLE_CLIENT_ID đúng
❌ Cần kết nối internet đến Google API
❌ Email phải tồn tại trong database (không auto-create account)

---

## 5️⃣ PHÂN QUYỀN (AUTHORIZATION)

### A. Các Roles trong hệ thống
1. **Admin** - Quản trị viên (Full access)
2. **Manager** - Quản lý (Quản lý problems, users)
3. **User** - Người dùng bình thường (Xem problems của mình)
4. **IT Support** - Nhân viên IT (Xử lý problems)

### B. Luồng kiểm tra quyền
```
User request tới protected URL
    ↓
AuthorizationFilter intercept request
    ↓
Kiểm tra public paths (Login, ForgotPassword, etc.)
    ↓
Nếu public: Cho phép
    ↓
Kiểm tra session & user
    ↓
Nếu không login: Redirect tới /Login.jsp
    ↓
Lấy role từ session
    ↓
Nếu Admin: Cho phép toàn quyền
    ↓
Nếu role khác: Kiểm tra quyền theo role
    ↓
Nếu được phép: Continue
Nếu không được phép: Trả về 403 Forbidden
```

### C. Chi tiết quyền từng role

#### **Filter: AuthorizationFilter.java**
```java
Protected URLs:
- /AdminDashboard.jsp
- /ManagerDashboard.jsp
- /UserDashboard.jsp
- /ITDashboard.jsp
- /ProblemList, /ProblemAdd, /ProblemUpdate, /ProblemDetail
- /ITProblemListController
- /UserCreate
- /admin/*, /user/*, /it/*

Public URLs (không cần xác thực):
- /Login, /Login.jsp, /Logout
- /ForgotPassword, /ForgotPassword.jsp
- /ResetPassword, /ResetPassword.jsp
- /GoogleLogin

hasAccessByRole(String role, String path):
    
🔷 ADMIN:
   → Toàn quyền (ngoài filter logic)

🔷 MANAGER:
   ✓ /ManagerDashboard.jsp
   ✓ /UserDashboard.jsp
   ✓ /ProblemList, /ProblemAdd, /ProblemUpdate, /ProblemDetail
   ✓ /ProblemList.jsp, /ProblemAdd.jsp, /ProblemUpdate.jsp, /ProblemDetail.jsp
   ✓ /user/*

🔷 USER:
   ✓ /UserDashboard.jsp
   ✓ /ProblemList, /ProblemDetail
   ✓ /ProblemList.jsp, /ProblemDetail.jsp
   ✓ /user/*

🔷 IT SUPPORT:
   ✓ /ITDashboard.jsp
   ✓ /ITProblemListController
   ✓ /ProblemDetail, /ProblemUpdate
   ✓ /ITSupportProblemList.jsp, /ProblemDetail.jsp, /ProblemUpdate.jsp
   ✓ /it/*
```

### D. Session Attributes sau login
```java
session.setAttribute("user", user);        // Users object
session.setAttribute("role", user.getRole());  // "Admin", "Manager", etc.
session.setAttribute("userId", user.getId());  // ID người dùng
```

### E. Redirect theo role sau login
```
Admin      → /AdminDashboard.jsp
Manager    → /ManagerDashboard.jsp
User       → /UserDashboard.jsp
IT Support → /ITDashboard.jsp
```

### F. Điểm quan trọng
✅ Role-based access control (RBAC)
✅ Filter kiểm tra tất cả requests
✅ Admin có full access
✅ Logout clear session
❌ Không có fine-grained permissions (chỉ có role level)
❌ Không có resource-level authorization (có thể xem problems của người khác)

---

## 6️⃣ LUỒNG DỮ LIỆU (DATA FLOW)

### A. Database Schema (Cơ sở dữ liệu)

#### **Table: Users**
```sql
CREATE TABLE Users (
    Id INT PRIMARY KEY IDENTITY(1,1),
    Username NVARCHAR(50) UNIQUE NOT NULL,
    Email NVARCHAR(100) UNIQUE NOT NULL,
    PasswordHash NVARCHAR(255) NOT NULL,  -- SHA-256 hash
    FullName NVARCHAR(100),
    Role NVARCHAR(50),  -- 'Admin', 'Manager', 'User', 'IT Support'
    DepartmentId INT,
    LocationId INT,
    IsActive BIT DEFAULT 1,
    CreatedAt DATETIME DEFAULT GETDATE()
);
```

#### **Table: PasswordResetTokens**
```sql
CREATE TABLE PasswordResetTokens (
    Id INT PRIMARY KEY IDENTITY(1,1),
    UserId INT NOT NULL FOREIGN KEY REFERENCES Users(Id),
    Token NVARCHAR(MAX) NOT NULL,
    ExpiresAt DATETIME NOT NULL,
    IsUsed BIT DEFAULT 0,
    CreatedAt DATETIME DEFAULT GETDATE()
);
```

### B. Quy trình lưu trữ mật khẩu
```
Raw Password: "123456"
    ↓
PasswordUtil.sha256()
    ↓
SHA-256 Hash: "8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6472"
    ↓
Lưu vào DB: PasswordHash
    ↓
Khi login: sha256(input) == PasswordHash → Đúng
```

### C. Flow chi tiết Login
```
1. USER INPUT
   Username: "john"
   Password: "123456"

2. CONTROLLER PROCESSING
   Login.doPost()
   - trim: username = "john", password = "123456"
   - call UserService.login("john", "123456")

3. SERVICE PROCESSING
   UserService.login()
   - hash = PasswordUtil.sha256("123456")
   - hash = "8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6472"
   - call UserDao.login("john", hash)

4. DAO PROCESSING
   UserDao.login()
   - SQL: SELECT * FROM Users 
           WHERE Username = "john" 
           AND PasswordHash = "8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6472"
           AND IsActive = 1
   - DB returns: Users{Id=1, Username="john", FullName="John Doe", Role="Manager"}

5. SESSION CREATION
   HttpSession session = request.getSession();
   session.setAttribute("user", userObject);
   session.setAttribute("role", "Manager");
   session.setAttribute("userId", 1);

6. REDIRECT
   response.sendRedirect("ManagerDashboard.jsp");
```

### D. Flow chi tiết Forgot Password
```
1. USER INPUT
   Email: "john@example.com"

2. CONTROLLER PROCESSING
   ForgotPassword.doPost()
   - validate email
   - call UserService.getUserByEmail("john@example.com")

3. SERVICE PROCESSING
   UserService.createPasswordResetToken()
   - token = UUID.randomUUID().toString()
   - token = "550e8400-e29b-41d4-a716-446655440000"
   - expiresAt = System.currentTimeMillis() + 15*60*1000
   - call UserDao.savePasswordResetToken(userId, token, expiresAt)

4. DAO PROCESSING
   UserDao.savePasswordResetToken()
   - SQL: INSERT INTO PasswordResetTokens 
           (UserId, Token, ExpiresAt, IsUsed)
           VALUES (1, "550e8400-e29b-41d4-a716-446655440000", 2025-03-02 10:30:00, 0)

5. EMAIL SENDING
   EmailUtil.sendForgotPasswordEmail()
   - To: john@example.com
   - Link: http://domain/ResetPassword?token=550e8400-e29b-41d4-a716-446655440000

6. USER RECEIVES EMAIL
   - Click link: /ResetPassword?token=550e8400-e29b-41d4-a716-446655440000

7. RESET PAGE VALIDATION
   ResetPassword.doGet()
   - token = "550e8400-e29b-41d4-a716-446655440000"
   - call UserService.isValidResetToken(token)
   - check: EXISTS token AND IsUsed = 0 AND ExpiresAt > NOW()

8. PASSWORD UPDATE
   ResetPassword.doPost()
   - newPassword: "newpass123"
   - confirmPassword: "newpass123"
   - validate match: newPassword == confirmPassword
   - call UserService.resetPasswordByToken(token, newPassword)
   
9. SERVICE PROCESSING
   UserService.resetPasswordByToken()
   - newHash = PasswordUtil.sha256("newpass123")
   - call UserDao.updatePasswordByUserId(userId, newHash)
   - call UserDao.markTokenUsed(token)

10. DAO PROCESSING - UPDATE PASSWORD
    UserDao.updatePasswordByUserId()
    - SQL: UPDATE Users SET PasswordHash = ? WHERE Id = ? AND IsActive = 1
    - Update: Id=1, PasswordHash=newHash

11. DAO PROCESSING - MARK TOKEN USED
    UserDao.markTokenUsed()
    - SQL: UPDATE PasswordResetTokens SET IsUsed = 1 WHERE Token = ?
    - Prevent reuse: Token cannot be used again

12. SUCCESS MESSAGE
    - Redirect to Login.jsp with success message
    - User can login with new password
```

### E. Flow chi tiết Google Login
```
1. FRONTEND - GOOGLE SIGN-IN
   - User clicks "Sign in with Google"
   - Google One Tap shows dialog
   - User selects account
   - Google returns: credential (ID Token)

2. TOKEN TO BACKEND
   GoogleLogin.doPost()
   - idToken = request.getParameter("credential")
   - clientId = "abc123.apps.googleusercontent.com"

3. VERIFY TOKEN WITH GOOGLE
   GoogleAuthUtil.verifyIdToken(idToken, clientId)
   - URL: https://oauth2.googleapis.com/tokeninfo?id_token={idToken}
   - Google API returns JSON:
     {
       "aud": "abc123.apps.googleusercontent.com",
       "email": "john@example.com",
       "email_verified": true,
       ...
     }
   - Validate:
     * aud == clientId ✓
     * email_verified == true ✓
     * email = "john@example.com" ✓

4. FIND USER BY EMAIL
   UserService.loginWithGoogleEmail("john@example.com")
   - call UserDao.getUserByEmail("john@example.com")
   - SQL: SELECT * FROM Users 
           WHERE Email = "john@example.com" AND IsActive = 1
   - Returns: Users{Id=1, Role="Manager"}

5. SESSION & REDIRECT
   - session.setAttribute("user", user)
   - session.setAttribute("role", "Manager")
   - redirectByRole("Manager") → /ManagerDashboard.jsp
```

---

## 7️⃣ SƠ ĐỒ KIẾN TRÚC

### Architecture Diagram
```
┌─────────────────────────────────────────────────────────────┐
│                      FRONTEND (JSP)                         │
│  Login.jsp  ForgotPassword.jsp  ResetPassword.jsp           │
└────────────────────────────────────────────────────────────┐
                          │
                    HTTP Request/Response
                          │
         ┌────────────────┴────────────────┐
         │                                  │
    ┌────▼───────┐                  ┌──────▼─────┐
    │ Filters    │                  │ Servlets   │
    ├────────────┤                  ├────────────┤
    │ Authorization│                │ Login      │
    │ Filter     │                  │ GoogleLogin│
    │           │                  │ ForgotPass │
    │ Checks:   │                  │ ResetPass  │
    │ - Session │                  │ Logout     │
    │ - Role    │                  │ UserCreate │
    └────┬───────┘                  └──────┬─────┘
         │                                  │
         └────────────────┬─────────────────┘
                         │
                 ┌────────▼────────┐
                 │  Services       │
                 ├─────────────────┤
                 │ UserService     │
                 │  - login()      │
                 │  - resetPass()  │
                 │  - tokenMgmt()  │
                 │  - googleLogin()│
                 └────────┬────────┘
                         │
                 ┌────────▼────────┐
                 │  DAOs           │
                 ├─────────────────┤
                 │ UserDao         │
                 │  - login()      │
                 │  - getUserBy..()│
                 │  - resetPass()  │
                 │  - token ops    │
                 └────────┬────────┘
                         │
         ┌───────────────┴───────────────┐
         │                               │
    ┌────▼──────┐              ┌────────▼──┐
    │  Database │              │ External  │
    │   (SQL)   │              │ Services  │
    ├───────────┤              ├───────────┤
    │ Users     │              │ Google    │
    │ Password  │              │ OAuth API │
    │ ResetTokens│             │           │
    │ Depts, Loc│             │ Email Svc │
    └───────────┘              └───────────┘
```

### Request Flow: Login → Authentication → Authorization
```
┌──────────────────────────────────────────────────────────┐
│ 1. USER submits Login Form (username=john, pass=123456) │
└──────────────────┬───────────────────────────────────────┘
                   │
                   ▼
        ┌──────────────────────┐
        │ Login Servlet        │
        │ ├─ doPost()          │
        │ ├─ Get input         │
        │ └─ Call UserService  │
        └──────────┬───────────┘
                   │
                   ▼
        ┌──────────────────────┐
        │ UserService          │
        │ ├─ login()           │
        │ ├─ Hash password     │
        │ └─ Call UserDao      │
        └──────────┬───────────┘
                   │
                   ▼
        ┌──────────────────────┐
        │ UserDao              │
        │ ├─ login()           │
        │ ├─ Query DB          │
        │ └─ Validate          │
        └──────────┬───────────┘
                   │
       ┌───────────┴───────────┐
       │                       │
   SUCCESS              FAILURE (NULL)
       │                       │
       ▼                       ▼
   ┌─────────┐         ┌─────────┐
   │ Create  │         │ Forward │
   │ Session │         │ with    │
   │ role    │         │ ERROR   │
   │ userId  │         │         │
   └────┬────┘         └────┬────┘
        │                   │
        ▼                   ▼
   Redirect            Login.jsp
   to Dashboard        (error msg)
   (by role)
        │
        ▼
   ┌──────────────────────────────────────┐
   │ Request to Protected URL             │
   │ (e.g. /ManagerDashboard.jsp)         │
   └──────────┬───────────────────────────┘
              │
              ▼
   ┌──────────────────────────────────────┐
   │ AuthorizationFilter                  │
   │ ├─ Check session exists              │
   │ ├─ Get role from session             │
   │ ├─ Check if public path              │
   │ ├─ Call hasAccessByRole()            │
   │ └─ Allow or Forbid (403)             │
   └──────────┬───────────────────────────┘
              │
         ALLOWED (continue filter chain)
              │
              ▼
        ┌───────────────┐
        │ Servlet/JSP   │
        │ Process       │
        │ Request       │
        └───────────────┘
```

---

## 8️⃣ BẢNG TÓMLÝ CHỨC NĂNG

| Chức Năng | Controller | Service | DAO | Method Chính | Bảo Mật |
|-----------|-----------|---------|-----|-------------|--------|
| **Login** | Login | UserService | UserDao | login() | SHA-256 hash, IsActive check |
| **Forgot Pass** | ForgotPassword | UserService | UserDao | createPasswordResetToken() | Email verification, Token expire |
| **Reset Pass** | ResetPassword | UserService | UserDao | resetPasswordByToken() | Token validation, Confirm password |
| **Google Login** | GoogleLogin | UserService | UserDao | loginWithGoogleEmail() | Google token verify, Email verify |
| **Authorization** | - | - | - | AuthorizationFilter | Role-based access, Session check |
| **Logout** | Logout | - | - | invalidateSession() | Session cleared |

---

## 9️⃣ KIỂM SOÁT LỖIDƯƠNG HÀNH

### Login Errors:
```
1. Invalid username or password
   → Check connection, user exists, password hash match
2. User not active (IsActive = 0)
   → User account was deactivated
3. Database connection error
   → Check SQL Server, DbContext
```

### Forgot Password Errors:
```
1. Email does not exist
   → No user with this email
2. Cannot create reset link
   → DB error or token creation failed
3. Cannot send reset email
   → Email service not configured, mail.properties issue
```

### Reset Password Errors:
```
1. Invalid or expired reset link
   → Token doesn't exist, IsUsed=1, or ExpiresAt < NOW()
2. Passwords don't match
   → newPassword != confirmPassword
3. Password too short (< 6 chars)
   → Validation error
```

### Google Login Errors:
```
1. Google login not configured
   → GOOGLE_CLIENT_ID not set
2. Google authentication failed
   → Invalid token or network error
3. No active account linked to Google email
   → Email not in Users table
```

---

## 🔟 CÁCH CẢI THIỆN

### Security:
```
1. ✓ Thêm rate limiting (prevent brute force)
2. ✓ Thêm 2FA (Two-Factor Authentication)
3. ✓ Thêm CSRF token checks
4. ✓ Thêm password complexity validation
5. ✓ Sử dụng bcrypt thay vì SHA-256
6. ✓ Thêm login attempt logging
7. ✓ Thêm email confirmation cho new accounts
```

### Features:
```
1. ✓ Auto-create account for Google login
2. ✓ Account recovery via security questions
3. ✓ Password history (không dùng lại password cũ)
4. ✓ Session timeout + auto logout
5. ✓ Fine-grained permissions (resource level)
6. ✓ Audit logging (who logged in when)
7. ✓ Support for multiple login methods linking
```

### Code Quality:
```
1. ✓ Thêm unit tests cho authentication
2. ✓ Thêm integration tests
3. ✓ Thêm logging (SLF4J, Log4j)
4. ✓ Thêm error handling improvements
5. ✓ Thêm input validation/sanitization
6. ✓ Database connection pooling
```

---

## 📝 TÓMLÝ

### Login Flow:
```
User Input → Controller → Service (hash) → DAO (query) → DB → Session → Redirect
```

### Forgot Password Flow:
```
Email Input → Service (token) → DAO (save) → Email Util → Email → Token validation → Reset → Update
```

### Google Login Flow:
```
Google Token → Controller → Verify with Google API → Find User → Session → Redirect
```

### Authorization Flow:
```
Protected URL → Filter (session check) → hasAccessByRole() → Allow/Deny → Response
```

### Database:
```
Users table: Username, Email, PasswordHash (SHA-256), Role, IsActive
PasswordResetTokens table: Token, ExpiresAt, IsUsed (for one-time use)
```

---

## 🔗 FILE LIÊN QUAN

**Controllers:**
- [Login.java](src/java/controller/Login.java)
- [GoogleLogin.java](src/java/controller/GoogleLogin.java)
- [ForgotPassword.java](src/java/controller/ForgotPassword.java)
- [ResetPassword.java](src/java/controller/ResetPassword.java)

**Services:**
- [UserService.java](src/java/service/UserService.java)

**DAOs:**
- [UserDao.java](src/java/dao/UserDao.java)

**Filters:**
- [AuthorizationFilter.java](src/java/filter/AuthorizationFilter.java)

**Utils:**
- [PasswordUtil.java](src/java/Utils/PasswordUtil.java)
- [GoogleAuthUtil.java](src/java/Utils/GoogleAuthUtil.java)
- [EmailUtil.java](src/java/Utils/EmailUtil.java)

**Models:**
- [Users.java](src/java/model/Users.java)

**Views:**
- [Login.jsp](web/Login.jsp)
- [ForgotPassword.jsp](web/ForgotPassword.jsp)
- [ResetPassword.jsp](web/ResetPassword.jsp)
- [AdminDashboard.jsp](web/AdminDashboard.jsp)
- [ManagerDashboard.jsp](web/ManagerDashboard.jsp)
- [UserDashboard.jsp](web/UserDashboard.jsp)
- [ITDashboard.jsp](web/ITDashboard.jsp)
