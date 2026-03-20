# 📖 HƯỚNG DẪN SỬ DỤNG TÀI LIỆU

Dưới đây là 5 tài liệu chi tiết về các chức năng Authentication & Authorization:

---

## 📄 1. REVIEW_AUTH_FEATURES.md
**Phạm vi:** Phân tích toàn diện các chức năng

**Nội dung:**
- ✓ Tổng quan hệ thống MVC
- ✓ Chi tiết chức năng Login (username/password)
- ✓ Chi tiết chức năng Forgot Password
- ✓ Chi tiết chức năng Google Login (OAuth)
- ✓ Phân quyền chi tiết (Authorization)
- ✓ Luồng dữ liệu từng chức năng
- ✓ Sơ đồ kiến trúc
- ✓ Bảng tómlý chức năng
- ✓ Xử lý lỗi
- ✓ Cách cải thiện

**Dùng khi nào:**
- Muốn hiểu tổng quan toàn bộ hệ thống
- Cần giải thích cho người khác
- Muốn xem chi tiết từng chức năng

---

## 🔄 2. FLOW_DIAGRAMS.md
**Phạm vi:** Sơ đồ luồng dữ liệu

**Nội dung:**
- ✓ Login Flow (luồng đăng nhập)
- ✓ Password Reset Flow (quên mật khẩu)
- ✓ Google Login Flow (OAuth)
- ✓ Authorization Filter Flow
- ✓ Role-Based Access Control (RBAC)
- ✓ Password Hash & Verification
- ✓ Session Management
- ✓ Database Transaction
- ✓ Email Token Generation
- ✓ Google OAuth Token Verification

**Dùng khi nào:**
- Muốn hình dung luồng xử lý
- Đang debug và cần trace flow
- Muốn trình bày cho team

---

## 💻 3. CODE_REFERENCE.md
**Phạm vi:** Mã nguồn chi tiết

**Nội dung:**
- ✓ Mã Login hoàn chỉnh (Controller → Service → DAO)
- ✓ Mã Forgot Password hoàn chỉnh
- ✓ Mã Reset Password hoàn chỉnh
- ✓ Mã Google Login hoàn chỉnh
- ✓ Filter Authorization hoàn chỉnh
- ✓ Toàn bộ ví dụ Login (step by step)
- ✓ Xử lý lỗi phổ biến
- ✓ Best practices

**Dùng khi nào:**
- Cần xem mã code thực tế
- Muốn hiểu cách implement
- Cần copy-paste code pattern
- Đang debug code

---

## 📊 4. DATABASE_CONFIG.md
**Phạm vi:** Cơ sở dữ liệu và cấu hình

**Nội dung:**
- ✓ Schema Users table
- ✓ Schema PasswordResetTokens table
- ✓ Cấu hình web.xml
- ✓ Cấu hình mail.properties
- ✓ Cấu hình DbContext
- ✓ Matrix quyền theo role
- ✓ Query SQL tham chiếu
- ✓ Checklist bảo mật

**Dùng khi nào:**
- Cần setup database
- Cần cấu hình email/Google
- Muốn xem permission matrix
- Cần SQL queries

---

## 🧪 5. TESTING_GUIDE.md
**Phạm vi:** Hướng dẫn test và debug

**Nội dung:**
- ✓ Cheat sheet nhanh
- ✓ 8 test scenarios chi tiết
- ✓ Debugging tips cho lỗi thường gặp
- ✓ Testing checklist
- ✓ Step-by-step test cases
- ✓ Database expect vs actual

**Dùng khi nào:**
- Cần test chức năng
- Đang gặp lỗi
- Muốn verify hệ thống hoạt động
- Cần QA testing

---

## 🎯 HƯỚNG DẪN NHANH

### Nếu bạn muốn...

#### 1. Hiểu hoàn toàn hệ thống
Đọc theo thứ tự:
1. REVIEW_AUTH_FEATURES.md (phần 1-2)
2. FLOW_DIAGRAMS.md (phần 1-3)
3. CODE_REFERENCE.md (phần 1-3)

#### 2. Setup/Cấu hình hệ thống
Đọc:
- DATABASE_CONFIG.md (phần 3-5)
- CODE_REFERENCE.md (phần 7)

#### 3. Debug một vấn đề
Đọc:
1. TESTING_GUIDE.md (phần "Debugging Tips")
2. TESTING_GUIDE.md (phần "Error Scenarios")
3. FLOW_DIAGRAMS.md (flow liên quan)

#### 4. Test một chức năng
Đọc:
- TESTING_GUIDE.md (phần 2 - Testing Scenarios)
- TESTING_GUIDE.md (phần 3 - Checklist)

#### 5. Thêm một tính năng mới
Đọc:
1. CODE_REFERENCE.md (phần tương tự)
2. FLOW_DIAGRAMS.md (phần tương tự)
3. DATABASE_CONFIG.md (phần Schema/Query)
4. TESTING_GUIDE.md (phần Testing Checklist)

#### 6. Tìm một cái gì đó cụ thể
Dùng Ctrl+F để tìm từ khóa:
- "Login" → tìm chi tiết đăng nhập
- "Token" → tìm chi tiết reset password
- "Google" → tìm OAuth
- "authorize" → tìm phân quyền
- "error" → tìm xử lý lỗi
- "query" → tìm SQL

---

## 📋 DANH SÁCH CÁC ROLES & QUYỀN

### Admin
```
✓ Toàn quyền hệ thống
✓ Quản lý users
✓ Quản lý settings
✓ Xem tất cả reports
```

### Manager
```
✓ Quản lý problems (CRUD)
✓ Xem user dashboard
✓ Tạo users mới
✓ Xem reports
```

### User
```
✓ Xem dashboard
✓ Xem problems của mình
✓ Update profile
```

### IT Support
```
✓ Xem IT dashboard
✓ Update problems
✓ Xem all problems
✓ Thêm solutions
```

---

## 🔐 MẬT KHẨU & BẢO MẬT

### Mã hóa:
```
Password: "123456"
   ↓ SHA-256
Hash: "8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6472"
   ↓
Lưu vào DB
```

### Reset Token:
```
UUID: "550e8400-e29b-41d4-a716-446655440000"
Hết hạn: 15 phút sau khi tạo
Dùng 1 lần: IsUsed = 0 → 1
```

### Google OAuth:
```
Token từ Google → Xác minh với Google API
Email phải verified
Email phải tồn tại trong DB
```

---

## 🚀 QUICK START

### 1. Login
```
Form: username + password
Flow: Trim → Hash SHA-256 → Query DB → Create Session → Redirect
```

### 2. Forgot Password
```
Email → Generate Token (UUID) → Save to DB → Send Email with Link
User clicks link → Validate Token → Enter new password
→ Update password → Mark token as used
```

### 3. Google Login
```
One Tap → Verify Token with Google API → Find User
→ Create Session → Redirect
```

### 4. Authorization
```
Protect URLs with Filter
Check: Is public? → Has session? → Has role? → Check permissions
```

---

## 📞 THẮC MẮC THƯỜNG GẶP

### Q: Làm sao reset password nếu quên?
**A:** Dùng chức năng "Forgot Password" - gửi link qua email

### Q: Làm sao tạo user mới?
**A:** Admin hoặc Manager tạo via UserCreate page, hoặc trực tiếp insert DB

### Q: Làm sao setup Google Login?
**A:** Set GOOGLE_CLIENT_ID trong mail.properties + cấu hình Google Console

### Q: Mất bao lâu để reset token hết hạn?
**A:** 15 phút từ lúc tạo

### Q: Có thể dùng token reset lần 2 không?
**A:** Không, mark as IsUsed = 1 após lần đầu

### Q: Admin có quyền gì?
**A:** Toàn quyền, bypass tất cả filter

### Q: Làm sao check ai đang login?
**A:** Check session getAttribute("user")

### Q: Bind sao khi 403?
**A:** Check role có access → nếu không grant quyền admin hoặc trong DB

---

## ✅ CHECKLIST IMPLEMENTATION

### Authentication:
- [ ] Login page created
- [ ] Login controller implemented
- [ ] UserService.login() works
- [ ] UserDao.login() queries correctly
- [ ] Password hashing works (SHA-256)
- [ ] Session created after login
- [ ] Redirect based on role works

### Forgot Password:
- [ ] Forgot password page created
- [ ] Token generation works (UUID)
- [ ] Token saves to DB
- [ ] Email sending works
- [ ] Token validation works (not expired, not used)
- [ ] Password update works
- [ ] Token marked as used

### Google Login:
- [ ] GOOGLE_CLIENT_ID configured
- [ ] Google One Tap loaded on page
- [ ] Token verification with Google API works
- [ ] User lookup by email works
- [ ] Session created after Google login

### Authorization:
- [ ] Filter protects all sensitive URLs
- [ ] Public paths allow access
- [ ] Session check works
- [ ] Role-based permissions work
- [ ] Admin has full access
- [ ] 403 error for unauthorized
- [ ] Redirect to login for non-authenticated

---

## 📐 ARCHITECTURE SUMMARY

```
┌─────────────────────────┐
│ Frontend (JSP/HTML)     │
│ Login.jsp, etc.         │
└──────────┬──────────────┘
           │ HTTP Request
           ▼
┌──────────────────────────────┐
│ Filter (AuthorizationFilter) │
│ - Session check              │
│ - Role check                 │
│ - Permission validation      │
└──────────┬───────────────────┘
           │
           ▼
┌──────────────────────────────┐
│ Servlet (Controller)         │
│ - Login, GoogleLogin, etc.   │
│ - Get input, call service    │
└──────────┬───────────────────┘
           │
           ▼
┌──────────────────────────────┐
│ Service (UserService)        │
│ - Password hashing           │
│ - Token generation           │
│ - Business logic             │
└──────────┬───────────────────┘
           │
           ▼
┌──────────────────────────────┐
│ DAO (UserDao)                │
│ - Database queries           │
│ - SQL execution              │
└──────────┬───────────────────┘
           │
           ▼
┌──────────────────────────────┐
│ Database (SQL Server)        │
│ - Users table                │
│ - PasswordResetTokens table  │
└──────────────────────────────┘
```

---

## 🎓 LEARNING PATH

### Level 1: Basics (1-2 giờ)
1. Đọc REVIEW_AUTH_FEATURES.md (phần 1, 2)
2. Xem FLOW_DIAGRAMS.md (Login Flow)
3. Chạy test Login thành công

### Level 2: Intermediate (2-3 giờ)
1. Đọc CODE_REFERENCE.md (phần 1, 2, 3)
2. Xem tất cả FLOW_DIAGRAMS.md
3. Chạy test tất cả scenarios
4. Debug một vấn đề gặp phải

### Level 3: Advanced (3-4 giờ)
1. Đọc cả 4 files còn lại
2. Modify code (thêm feature mới)
3. Tạo unit tests
4. Optimize bảo mật

### Level 4: Expert (1 tuần)
1. Master tất cả files
2. Implement security enhancements
3. Add features (2FA, rate limiting, etc.)
4. Create documentation cho team

---

## 📚 FILE MAP

```
ITServiceFlow/
├── REVIEW_AUTH_FEATURES.md ← Tổng quan toàn diện
├── FLOW_DIAGRAMS.md ← Lưu đồ và diagram
├── CODE_REFERENCE.md ← Code examples
├── DATABASE_CONFIG.md ← Database & cấu hình
├── TESTING_GUIDE.md ← Test & debug
├── QUICK_START.md ← File này
├── src/java/
│   ├── controller/
│   │   ├── Login.java
│   │   ├── GoogleLogin.java
│   │   ├── ForgotPassword.java
│   │   └── ResetPassword.java
│   ├── service/
│   │   └── UserService.java
│   ├── dao/
│   │   └── UserDao.java
│   ├── filter/
│   │   └── AuthorizationFilter.java
│   ├── Utils/
│   │   ├── PasswordUtil.java
│   │   ├── GoogleAuthUtil.java
│   │   └── EmailUtil.java
│   └── model/
│       └── Users.java
└── web/
    ├── Login.jsp
    ├── ForgotPassword.jsp
    ├── ResetPassword.jsp
    └── *Dashboard.jsp
```

---

## 📞 CẦN GIÚP?

1. **Tìm lỗi?** → TESTING_GUIDE.md → "Debugging Tips"
2. **Cần code?** → CODE_REFERENCE.md
3. **Cần flow?** → FLOW_DIAGRAMS.md
4. **Cần schema?** → DATABASE_CONFIG.md
5. **Cần tổng quan?** → REVIEW_AUTH_FEATURES.md

---

## ✨ TÓMLÝ

Hệ thống authentication & authorization gồm:

1. **Login**: Username/Password → SHA-256 hash → DB query → Session
2. **Forgot Password**: Email → UUID token → Email link → Reset → Mark used
3. **Google Login**: OAuth token → Verify with Google → DB lookup → Session
4. **Authorization**: AuthorizationFilter → Session check → Role check → Allow/Deny

Tất cả được được ghi chép chi tiết trong 5 files trên. Bạn có thể:
- Hiểu hệ thống
- Debug lỗi
- Test chức năng
- Thêm tính năng mới
- Cải thiện bảo mật

**Chúc bạn học tốt! 🎉**
