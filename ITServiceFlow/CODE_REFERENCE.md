# CODE REFERENCE & IMPLEMENTATION GUIDE

## 1. LOGIN IMPLEMENTATION

### Controller Side: Login.java

```java
@WebServlet(name = "Login", urlPatterns = {"/Login"})
public class Login extends HttpServlet {
    UserService userService = new UserService();

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        try {
            // Step 1: Get input from form
            String username = request.getParameter("username");  // e.g., "john"
            String password = request.getParameter("password");  // e.g., "123456"
            
            // Step 2: Trim whitespace
            if (username != null) {
                username = username.trim();  // "john" (no spaces)
            }
            if (password != null) {
                password = password.trim();  // "123456"
            }

            // Step 3: Call UserService.login()
            // This hashes password and queries database
            Users user = userService.login(username, password);

            // Step 4: Check if user found
            if (user == null) {
                request.setAttribute("error", "Invalid username or password");
                forwardLogin(request, response);  // Go back to login page with error
                return;
            }

            // Step 5: Create session
            HttpSession session = request.getSession();
            session.setAttribute("user", user);          // Users object
            session.setAttribute("role", user.getRole()); // "Manager", "Admin", etc
            session.setAttribute("userId", user.getId());  // 1, 2, 3, etc

            // Step 6: Redirect based on role
            String role = user.getRole();
            switch (role) {
                case "Admin":
                    response.sendRedirect("AdminDashboard.jsp");
                    break;
                case "Manager":
                    response.sendRedirect("ManagerDashboard.jsp");
                    break;
                case "User":
                    response.sendRedirect("UserDashboard.jsp");
                    break;
                case "IT Support":
                    response.sendRedirect("ITDashboard.jsp");
                    break;
                default:
                    request.setAttribute("error", "Invalid role");
                    forwardLogin(request, response);
                    return;
            }
        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("error", "Database connection error");
            forwardLogin(request, response);
        }
    }

    private void forwardLogin(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setAttribute("googleClientId", GoogleAuthUtil.getGoogleClientId());
        request.getRequestDispatcher("Login.jsp").forward(request, response);
    }
}
```

### Service Side: UserService.login()

```java
public Users login(String Username, String RawPassword) {
    // Step 1: Validate input
    if (Username == null || RawPassword == null) {
        return null;  // Invalid input
    }
    
    // Step 2: Hash the password
    //   Input:  "123456"
    //   SHA256: "8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6472"
    String passwordHash = PasswordUtil.sha256(RawPassword.trim());
    
    // Step 3: Call DAO to query database
    //   Will query: SELECT * FROM Users
    //   WHERE Username='john' AND PasswordHash='8d969eef...' AND IsActive=1
    return dao.login(Username, passwordHash);
}
```

### DAO Side: UserDao.login()

```java
public Users login(String username, String passwordHash) {
    // Validation
    if (username == null || passwordHash == null) {
        return null;
    }
    if (connection == null) {
        System.err.println("Database connection is null");
        return null;
    }

    // SQL Query
    String sql = """
        SELECT Id, Username, FullName, Role, IsActive
        FROM Users
        WHERE Username = ?
          AND PasswordHash = ?
          AND IsActive = 1
    """;

    try (PreparedStatement ps = connection.prepareStatement(sql)) {
        // Set parameters safely (prevents SQL injection)
        ps.setString(1, username.trim());      // Parameter 1: username
        ps.setString(2, passwordHash.trim());  // Parameter 2: hashed password
        
        // Execute query
        ResultSet rs = ps.executeQuery();
        
        // Get result
        if (rs.next()) {
            // Found matching user
            Users u = new Users();
            u.setId(rs.getInt("Id"));
            u.setUsername(rs.getString("Username"));
            u.setFullName(rs.getString("FullName"));
            u.setRole(rs.getString("Role"));
            return u;  // Login success
        }
    } catch (Exception e) {
        e.printStackTrace();
    }
    
    return null;  // No matching user
}
```

### Password Hashing: PasswordUtil.sha256()

```java
public class PasswordUtil {
    public static String sha256(String rawPassword) {
        if (rawPassword == null) {
            return null;
        }
        try {
            // Use SHA-256 algorithm
            MessageDigest digest = MessageDigest.getInstance("SHA-256");
            
            // Convert password string to bytes and hash
            byte[] hash = digest.digest(rawPassword.getBytes(StandardCharsets.UTF_8));
            
            // Convert bytes to hex string
            StringBuilder hex = new StringBuilder(hash.length * 2);
            for (byte b : hash) {
                String part = Integer.toHexString(0xff & b);
                if (part.length() == 1) {
                    hex.append('0');  // Pad with 0 if needed
                }
                hex.append(part);
            }
            
            // Return hex string
            // "123456" → "8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6472"
            return hex.toString();
        } catch (Exception ex) {
            throw new RuntimeException("Cannot hash password.", ex);
        }
    }
}

// Example:
// Input:  "123456"
// Output: "8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6472"
```

### Frontend: Login.jsp

```jsp
<!-- Login Form -->
<form method="POST" action="Login">
    <!-- Username field -->
    <input type="text" name="username" required 
           placeholder="Enter your username">
    
    <!-- Password field -->
    <input type="password" name="password" required 
           placeholder="Enter your password">
    
    <!-- Submit button -->
    <button type="submit">Login</button>
</form>

<!-- Display error if exists -->
<% 
    String error = (String) request.getAttribute("error");
    if (error != null) {
        out.println("<div class='error'>" + error + "</div>");
    }
%>
```

---

## 2. FORGOT PASSWORD IMPLEMENTATION

### Flow: Email → Token → Link → Verify → Reset

### Controller: ForgotPassword.java

```java
@WebServlet(name = "ForgotPassword", urlPatterns = {"/ForgotPassword"})
public class ForgotPassword extends HttpServlet {
    private final UserService userService = new UserService();

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        // Step 1: Get email from form
        String email = safeTrim(request.getParameter("email"));  // "john@example.com"

        // Step 2: Validate email not blank
        if (isBlank(email)) {
            request.setAttribute("error", "Please enter your email.");
            request.getRequestDispatcher("ForgotPassword.jsp").forward(request, response);
            return;
        }

        // Step 3: Check if user with this email exists
        var user = userService.getUserByEmail(email);
        if (user == null) {
            // Security: Don't reveal if email exists or not
            request.setAttribute("error", "If email exists, reset link will be sent.");
            request.getRequestDispatcher("ForgotPassword.jsp").forward(request, response);
            return;
        }

        // Step 4: Generate reset token (15 min expiry)
        String token = userService.createPasswordResetToken(email);
        if (token == null) {
            request.setAttribute("error", "Cannot create reset link. Please try again.");
            request.getRequestDispatcher("ForgotPassword.jsp").forward(request, response);
            return;
        }
        // token = "550e8400-e29b-41d4-a716-446655440000"

        // Step 5: Build reset link
        String resetLink = buildResetLink(request, token);
        // Link: "http://localhost:8080/ITServiceFlow/ResetPassword?token=550e8400-e29b-..."

        // Step 6: Send email with link
        boolean sent = EmailUtil.sendForgotPasswordEmail(email, user.getUsername(), resetLink);
        if (!sent) {
            request.setAttribute("error", "Cannot send reset email. Please check mail config.");
            request.getRequestDispatcher("ForgotPassword.jsp").forward(request, response);
            return;
        }

        // Step 7: Show success message
        request.setAttribute("message", "Reset link has been sent to your email.");
        request.getRequestDispatcher("ForgotPassword.jsp").forward(request, response);
    }

    private String buildResetLink(HttpServletRequest request, String token) {
        return request.getScheme() + "://"              // http
                + request.getServerName() + ":"        // localhost
                + request.getServerPort()              // 8080
                + request.getContextPath()             // /ITServiceFlow
                + "/ResetPassword?token=" + token;     // /ResetPassword?token=UUID
    }

    private String safeTrim(String value) {
        return value == null ? null : value.trim();
    }

    private boolean isBlank(String value) {
        return value == null || value.isEmpty();
    }
}
```

### Service: UserService.createPasswordResetToken()

```java
public String createPasswordResetToken(String email) {
    // Step 1: Get user by email
    Users user = dao.getUserByEmail(email);
    if (user == null) {
        return null;  // User doesn't exist
    }

    // Step 2: Generate unique token
    String token = UUID.randomUUID().toString();
    // token = "550e8400-e29b-41d4-a716-446655440000"

    // Step 3: Calculate expiration time (15 minutes from now)
    Timestamp expiresAt = new Timestamp(System.currentTimeMillis() + 15 * 60 * 1000L);
    // Current: 2025-03-02 10:00:00
    // Expires: 2025-03-02 10:15:00

    // Step 4: Save token to database
    boolean saved = dao.savePasswordResetToken(user.getId(), token, expiresAt);
    
    return saved ? token : null;
}
```

### DAO: UserDao.savePasswordResetToken()

```java
public boolean savePasswordResetToken(int userId, String token, Timestamp expiresAt) {
    if (connection == null || token == null || expiresAt == null) {
        return false;
    }
    
    String sql = """
        INSERT INTO PasswordResetTokens (UserId, Token, ExpiresAt, IsUsed)
        VALUES (?, ?, ?, 0)
    """;
    
    try (PreparedStatement ps = connection.prepareStatement(sql)) {
        // Parameter 1: UserId (e.g., 1)
        ps.setInt(1, userId);
        
        // Parameter 2: Token (UUID)
        ps.setString(2, token);
        
        // Parameter 3: Expiration time
        ps.setTimestamp(3, expiresAt);
        
        // Execute insert
        return ps.executeUpdate() > 0;  // true if 1+ rows inserted
    } catch (SQLException e) {
        e.printStackTrace();
    }
    return false;
}

// Database record created:
// Id=1, UserId=1, Token='550e8400-...', ExpiresAt='2025-03-02 10:15:00', IsUsed=0
```

### Controller: ResetPassword.java (GET - Validate Token)

```java
@Override
protected void doGet(HttpServletRequest request, HttpServletResponse response)
        throws ServletException, IOException {
    
    // Step 1: Get token from URL
    String token = trim(request.getParameter("token"));
    // token = "550e8400-e29b-41d4-a716-446655440000"
    
    // Step 2: Validate token
    if (isBlank(token) || !userService.isValidResetToken(token)) {
        request.setAttribute("error", "Invalid or expired reset link.");
        request.getRequestDispatcher("ForgotPassword.jsp").forward(request, response);
        return;
    }
    
    // Step 3: Token is valid, show reset password form
    request.setAttribute("token", token);
    request.getRequestDispatcher("ResetPassword.jsp").forward(request, response);
}
```

### Service: UserService.isValidResetToken()

```java
public boolean isValidResetToken(String token) {
    // Query: Check if token exists AND not used AND not expired
    // SELECT UserId FROM PasswordResetTokens
    // WHERE Token = ? AND IsUsed = 0 AND ExpiresAt > NOW()
    Integer userId = dao.getValidUserIdByToken(token);
    return userId != null;  // true if valid, false otherwise
}
```

### DAO: UserDao.getValidUserIdByToken()

```java
public Integer getValidUserIdByToken(String token) {
    if (connection == null || token == null || token.trim().isEmpty()) {
        return null;
    }
    
    String sql = """
        SELECT TOP 1 UserId
        FROM PasswordResetTokens
        WHERE Token = ?
          AND IsUsed = 0
          AND ExpiresAt > GETDATE()
    """;
    
    try (PreparedStatement ps = connection.prepareStatement(sql)) {
        ps.setString(1, token.trim());
        ResultSet rs = ps.executeQuery();
        
        if (rs.next()) {
            return rs.getInt("UserId");  // Return valid UserId
        }
    } catch (Exception e) {
        e.printStackTrace();
    }
    return null;  // Token invalid/expired/used
}

// Query explanation:
// - Token = ? : Exact token match
// - IsUsed = 0 : Token not used yet  
// - ExpiresAt > GETDATE() : Not expired
```

### Controller: ResetPassword.java (POST - Update Password)

```java
@Override
protected void doPost(HttpServletRequest request, HttpServletResponse response)
        throws ServletException, IOException {
    
    // Step 1: Get inputs
    String token = trim(request.getParameter("token"));
    String newPassword = trim(request.getParameter("newPassword"));
    String confirmPassword = trim(request.getParameter("confirmPassword"));

    // Step 2: Validate token
    if (isBlank(token) || !userService.isValidResetToken(token)) {
        request.setAttribute("error", "Invalid or expired reset link.");
        request.getRequestDispatcher("ForgotPassword.jsp").forward(request, response);
        return;
    }

    // Step 3: Validate passwords not blank
    if (isBlank(newPassword) || isBlank(confirmPassword)) {
        request.setAttribute("error", "Please fill all fields.");
        request.setAttribute("token", token);
        request.getRequestDispatcher("ResetPassword.jsp").forward(request, response);
        return;
    }

    // Step 4: Validate password length
    if (newPassword.length() < 6) {
        request.setAttribute("error", "Password must be at least 6 characters.");
        request.setAttribute("token", token);
        request.getRequestDispatcher("ResetPassword.jsp").forward(request, response);
        return;
    }

    // Step 5: Validate passwords match
    if (!newPassword.equals(confirmPassword)) {
        request.setAttribute("error", "Passwords don't match.");
        request.setAttribute("token", token);
        request.getRequestDispatcher("ResetPassword.jsp").forward(request, response);
        return;
    }

    // Step 6: Update password
    boolean updated = userService.resetPasswordByToken(token, newPassword);
    if (!updated) {
        request.setAttribute("error", "Cannot reset password. Link may be expired.");
        request.getRequestDispatcher("ForgotPassword.jsp").forward(request, response);
        return;
    }

    // Step 7: Success - redirect to login
    request.setAttribute("message", "Password reset successful. Please login.");
    request.getRequestDispatcher("Login.jsp").forward(request, response);
}
```

### Service: UserService.resetPasswordByToken()

```java
public boolean resetPasswordByToken(String token, String rawNewPassword) {
    // Step 1: Validate inputs
    if (token == null || rawNewPassword == null || rawNewPassword.trim().isEmpty()) {
        return false;
    }

    // Step 2: Get userId from token (validates token too)
    Integer userId = dao.getValidUserIdByToken(token);
    if (userId == null) {
        return false;  // Token invalid
    }

    // Step 3: Hash new password
    String newPasswordHash = PasswordUtil.sha256(rawNewPassword.trim());
    // "newpass123" → "a1b2c3d4e5f6..."

    // Step 4: Update user password
    boolean updated = dao.updatePasswordByUserId(userId, newPasswordHash);
    if (!updated) {
        return false;
    }

    // Step 5: Mark token as used (prevent reuse)
    return dao.markTokenUsed(token);
}
```

### DAO: UserDao.updatePasswordByUserId()

```java
public boolean updatePasswordByUserId(int userId, String newPasswordHash) {
    if (connection == null || newPasswordHash == null || newPasswordHash.trim().isEmpty()) {
        return false;
    }
    
    String sql = """
        UPDATE Users
        SET PasswordHash = ?
        WHERE Id = ?
          AND IsActive = 1
    """;
    
    try (PreparedStatement ps = connection.prepareStatement(sql)) {
        ps.setString(1, newPasswordHash.trim());
        ps.setInt(2, userId);
        
        int rowsAffected = ps.executeUpdate();
        return rowsAffected > 0;  // true if password updated
    } catch (Exception e) {
        e.printStackTrace();
    }
    return false;
}
```

### DAO: UserDao.markTokenUsed()

```java
public boolean markTokenUsed(String token) {
    if (connection == null || token == null || token.trim().isEmpty()) {
        return false;
    }
    
    String sql = """
        UPDATE PasswordResetTokens
        SET IsUsed = 1
        WHERE Token = ?
    """;
    
    try (PreparedStatement ps = connection.prepareStatement(sql)) {
        ps.setString(1, token.trim());
        
        int rowsAffected = ps.executeUpdate();
        return rowsAffected > 0;  // true if marked as used
    } catch (Exception e) {
        e.printStackTrace();
    }
    return false;
}

// Update in DB:
// IsUsed: 0 → 1 (token can't be used again)
```

---

## 3. GOOGLE LOGIN IMPLEMENTATION

### Controller: GoogleLogin.java

```java
@WebServlet(name = "GoogleLogin", urlPatterns = {"/GoogleLogin"})
public class GoogleLogin extends HttpServlet {
    private final UserService userService = new UserService();

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        try {
            // Step 1: Get ID token from Google Sign-In
            String idToken = request.getParameter("credential");
            // idToken = "eyJhbGciOiJSUzI1NiIsImtpZCI6IjEyMzQ1In0.eyJhdWQiOiJhYmMxMjMuYXBwcy5nb29nbGV1c2VyY29udGVudC5jb20iLCJlbWFpbCI6ImpvaG5AZXhhbXBsZS5jb20iLCJlbWFpbF92ZXJpZmllZCI6dHJ1ZSwibmFtZSI6IkpvaG4gRG9lIn0.signature"

            // Step 2: Get Google Client ID from config
            String clientId = GoogleAuthUtil.getGoogleClientId();
            // clientId = "abc123.apps.googleusercontent.com"

            // Step 3: Check if client ID configured
            if (clientId == null || clientId.isBlank()) {
                request.setAttribute("error", "Google login is not configured");
                request.setAttribute("googleClientId", "");
                request.getRequestDispatcher("Login.jsp").forward(request, response);
                return;
            }

            // Step 4: Verify token with Google
            GoogleUserInfo info = GoogleAuthUtil.verifyIdToken(idToken, clientId);
            if (info == null) {
                request.setAttribute("error", "Google authentication failed");
                request.setAttribute("googleClientId", clientId);
                request.getRequestDispatcher("Login.jsp").forward(request, response);
                return;
            }
            // info = GoogleUserInfo{email="john@example.com", aud="abc123...", emailVerified=true}

            // Step 5: Find user by Google email
            Users user = userService.loginWithGoogleEmail(info.getEmail());
            // Query: SELECT * FROM Users WHERE Email='john@example.com' AND IsActive=1
            
            if (user == null) {
                request.setAttribute("error", "No active account linked to this Google email");
                request.setAttribute("googleClientId", clientId);
                request.getRequestDispatcher("Login.jsp").forward(request, response);
                return;
            }

            // Step 6: Create session
            HttpSession session = request.getSession();
            session.setAttribute("user", user);
            session.setAttribute("role", user.getRole());
            session.setAttribute("userId", user.getId());

            // Step 7: Redirect based on role
            redirectByRole(user.getRole(), request, response);
        } catch (Exception ex) {
            ex.printStackTrace();
            request.setAttribute("error", "Google login error");
            request.setAttribute("googleClientId", GoogleAuthUtil.getGoogleClientId());
            request.getRequestDispatcher("Login.jsp").forward(request, response);
        }
    }

    private void redirectByRole(String role, HttpServletRequest request, HttpServletResponse response)
            throws IOException, ServletException {
        switch (role) {
            case "Admin":
                response.sendRedirect("AdminDashboard.jsp");
                break;
            case "Manager":
                response.sendRedirect("ManagerDashboard.jsp");
                break;
            case "User":
                response.sendRedirect("UserDashboard.jsp");
                break;
            case "IT Support":
                response.sendRedirect("ITDashboard.jsp");
                break;
            default:
                request.setAttribute("error", "Invalid role");
                request.setAttribute("googleClientId", GoogleAuthUtil.getGoogleClientId());
                request.getRequestDispatcher("Login.jsp").forward(request, response);
                break;
        }
    }
}
```

### Utils: GoogleAuthUtil.verifyIdToken()

```java
public static GoogleUserInfo verifyIdToken(String idToken, String expectedClientId) {
    if (idToken == null || idToken.isBlank()) {
        return null;
    }

    try {
        // Step 1: URL encode token
        String encodedToken = URLEncoder.encode(idToken, StandardCharsets.UTF_8);
        
        // Step 2: Call Google API to verify token
        URL url = new URL("https://oauth2.googleapis.com/tokeninfo?id_token=" + encodedToken);
        HttpURLConnection connection = (HttpURLConnection) url.openConnection();
        connection.setRequestMethod("GET");
        connection.setConnectTimeout(8000);
        connection.setReadTimeout(8000);

        // Step 3: Check response code
        int code = connection.getResponseCode();
        if (code != HttpURLConnection.HTTP_OK) {  // 200
            return null;  // Token verification failed
        }

        // Step 4: Read response JSON
        StringBuilder response = new StringBuilder();
        try (BufferedReader reader = new BufferedReader(
                new InputStreamReader(connection.getInputStream(), StandardCharsets.UTF_8))) {
            String line;
            while ((line = reader.readLine()) != null) {
                response.append(line);
            }
        }

        String json = response.toString();
        // json = {"aud":"abc123...","email":"john@example.com","email_verified":true,...}

        // Step 5: Extract values from JSON
        String aud = extractString(json, "aud");
        String email = extractString(json, "email");
        boolean emailVerified = extractBoolean(json, "email_verified");

        // Step 6: Validate values
        if (expectedClientId != null && !expectedClientId.isBlank() && !expectedClientId.equals(aud)) {
            return null;  // Client ID mismatch
        }
        if (email == null || email.isBlank() || !emailVerified) {
            return null;  // Email not verified or missing
        }

        // Step 7: Return user info if valid
        return new GoogleUserInfo(email.trim(), aud, emailVerified);
    } catch (Exception ex) {
        ex.printStackTrace();
        return null;
    }
}
```

### Utils: GoogleAuthUtil.getGoogleClientId()

```java
public static String getGoogleClientId() {
    // Try environment variable first
    String fromEnv = System.getenv("GOOGLE_CLIENT_ID");
    if (fromEnv != null && !fromEnv.isBlank()) {
        return fromEnv.trim();
    }
    
    // Try system property
    String fromProp = System.getProperty("GOOGLE_CLIENT_ID");
    if (fromProp != null && !fromProp.isBlank()) {
        return fromProp.trim();
    }
    
    // Try mail.properties file
    return readFromMailProperties("GOOGLE_CLIENT_ID");
}

// Priority:
// 1. Environment variable: GOOGLE_CLIENT_ID
// 2. System property: GOOGLE_CLIENT_ID
// 3. mail.properties: GOOGLE_CLIENT_ID=abc123...
```

---

## 4. AUTHORIZATION FILTER IMPLEMENTATION

### Filter: AuthorizationFilter.java

```java
@WebFilter(
    filterName = "AuthorizationFilter",
    urlPatterns = {
        "/AdminDashboard.jsp", "/ManagerDashboard.jsp", "/UserDashboard.jsp", "/ITDashboard.jsp",
        "/ProblemList", "/ProblemAdd", "/ProblemUpdate", "/ProblemDetail",
        // ... more patterns
    }
)
public class AuthorizationFilter implements Filter {
    
    private static final Set<String> PUBLIC_PATHS = Set.of(
        "/Login", "/Login.jsp", "/Logout",
        "/ForgotPassword", "/ForgotPassword.jsp",
        "/ResetPassword", "/ResetPassword.jsp",
        "/GoogleLogin"
    );

    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {
        
        HttpServletRequest httpRequest = (HttpServletRequest) request;
        HttpServletResponse httpResponse = (HttpServletResponse) response;
        HttpSession session = httpRequest.getSession(false);
        
        // Get path from URI
        String requestURI = httpRequest.getRequestURI();
        String contextPath = httpRequest.getContextPath();
        String path = requestURI.substring(contextPath.length());

        // Step 1: Check if public path (no auth required)
        if (PUBLIC_PATHS.contains(path)) {
            chain.doFilter(request, response);  // Allow
            return;
        }

        // Step 2: Check if session exists
        if (session == null || session.getAttribute("user") == null) {
            httpResponse.sendRedirect(contextPath + "/Login.jsp");
            return;
        }

        // Step 3: Get role from session
        String role = (String) session.getAttribute("role");
        
        if (role == null) {
            httpResponse.sendRedirect(contextPath + "/Login.jsp");
            return;
        }

        // Step 4: Check permissions
        // Admin has full access
        if ("Admin".equals(role)) {
            chain.doFilter(request, response);  // Allow all
            return;
        }

        // Check role-specific permissions
        boolean hasAccess = hasAccessByRole(role, path);
        
        if (!hasAccess) {
            // Access denied
            httpResponse.sendError(HttpServletResponse.SC_FORBIDDEN);
            return;
        }

        // Allow request to proceed
        chain.doFilter(request, response);
    }

    private boolean hasAccessByRole(String role, String path) {
        switch (role) {
            case "Manager":
                // Manager can access: Dashboard, Problems, User dashboard
                return path.equals("/ManagerDashboard.jsp")
                    || path.equals("/UserDashboard.jsp")
                    || path.equals("/ProblemList")
                    || path.equals("/ProblemAdd")
                    || path.equals("/ProblemUpdate")
                    || path.equals("/ProblemDetail")
                    || path.startsWith("/user/");

            case "User":
                // User can only view: User dashboard, View problems
                return path.equals("/UserDashboard.jsp")
                    || path.equals("/ProblemList")
                    || path.equals("/ProblemDetail")
                    || path.startsWith("/user/");

            case "IT Support":
                // IT Support can: View dashboard, Update/View problems
                return path.equals("/ITDashboard.jsp")
                    || path.equals("/ITProblemListController")
                    || path.equals("/ProblemDetail")
                    || path.equals("/ProblemUpdate")
                    || path.startsWith("/it/");

            default:
                return false;
        }
    }
}
```

### How Authorization Works:

```
Request: GET /ManagerDashboard.jsp
    ↓
isPublic? ("Login.jsp", etc.) → NO
    ↓
sessionExists? → YES
    ↓
getUserFromSession() → "Manager"
    ↓
getRole() → "Manager"
    ↓
isAdmin? → NO
    ↓
hasAccessByRole("Manager", "/ManagerDashboard.jsp") → YES
    ↓
Allow (chain.doFilter)
```

### Example: Manager tries to access Admin page

```
Request: GET /AdminDashboard.jsp
    ↓
isPublic? → NO
    ↓
sessionExists? → YES
    ↓
getRole() → "Manager"
    ↓
isAdmin? → NO
    ↓
hasAccessByRole("Manager", "/AdminDashboard.jsp") → NO
    ↓
Return 403 Forbidden
```

---

## 5. COMPLETE LOGIN EXAMPLE (STEP BY STEP)

### User: John (Password: "123456", Role: Manager, Email: john@example.com)

```java
// Database record:
// Id=1, Username="john", Email="john@example.com"
// PasswordHash="8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6472"
// Role="Manager", IsActive=1

// ============= STEP 1: User submits form =============
// Form data:
// username: "john"
// password: "123456"

// ============= STEP 2: Login Controller =============
String username = "john";  // trim
String password = "123456";  // trim
Users user = userService.login("john", "123456");

// ============= STEP 3: UserService.login() =============
String passwordHash = PasswordUtil.sha256("123456");
// passwordHash = "8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6472"

Users user = dao.login("john", "8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6472");

// ============= STEP 4: UserDao.login() =============
// SQL executed:
// SELECT Id, Username, FullName, Role, IsActive
// FROM Users
// WHERE Username = "john"
//   AND PasswordHash = "8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6472"
//   AND IsActive = 1

// Result found in DB → Create Users object:
Users u = new Users();
u.setId(1);
u.setUsername("john");
u.setFullName("John Doe");
u.setRole("Manager");
return u;

// ============= STEP 5: Back to Controller =============
// user is not null, login success

HttpSession session = request.getSession();
session.setAttribute("user", user);          // Users{Id=1, Username=john, Role=Manager}
session.setAttribute("role", "Manager");      // "Manager"
session.setAttribute("userId", 1);            // 1

// ============= STEP 6: Redirect =============
String role = user.getRole();  // "Manager"
switch(role) {
    case "Manager":
        response.sendRedirect("ManagerDashboard.jsp");  // ✓ Redirect
        break;
}

// ============= STEP 7: User now on Dashboard =============
// Next request: GET /ManagerDashboard.jsp
// Filter intercepts:
//   - Is public? NO
//   - Session exists? YES
//   - Role? "Manager"
//   - Has access to /ManagerDashboard.jsp? YES (Manager can access own dashboard)
//   → Allow (chain.doFilter)
```

---

## 6. COMMON ERRORS & SOLUTIONS

### Error 1: "Invalid username or password"
```
Cause: 
- Username doesn't exist in DB
- Password hash doesn't match
- User IsActive = 0

Solution:
- Check username spelling
- Check password spelling
- Ask admin to activate account
```

### Error 2: "Database connection error"
```
Cause:
- DbContext.connection is null
- SQL Server not running
- Connection string incorrect

Solution:
- Check DbContext initialization
- Restart SQL Server
- Verify connection string in web.xml
```

### Error 3: "Email does not exist" (Forgot Password)
```
Cause:
- Email not in Users table
- Email not exact match

Solution:
- Use correct email
- Create account first
```

### Error 4: "Invalid or expired reset link"
```
Cause:
- Token not found
- IsUsed = 1 (already used)
- ExpiresAt < NOW (15 min passed)

Solution:
- Request new reset link
- Don't wait > 15 minutes
```

### Error 5: "Google authentication failed"
```
Cause:
- Invalid token
- Network error
- Token expired

Solution:
- Try again
- Check internet connection
```

### Error 6: "403 Forbidden"
```
Cause:
- User doesn't have access to page
- Role not authorized

Solution:
- Check your role
- Ask admin to grant access
```

---

## 7. BEST PRACTICES

### Security:
✓ Always hash passwords with salt (use bcrypt instead of SHA-256)
✓ Use HTTPS for all authentication
✓ Never log passwords
✓ Validate all inputs on server side
✓ Use prepared statements (prevent SQL injection)
✓ Check IsActive flag before login
✓ Set reasonable token expiration times
✓ Use secure random for token generation (UUID.randomUUID)

### Code Quality:
✓ Always trim input to avoid whitespace issues
✓ Check null before using strings
✓ Close database connections (try-with-resources)
✓ Log exceptions for debugging
✓ Don't reveal if email exists (for reset password)

### Performance:
✓ Use connection pooling
✓ Index Username and Email columns
✓ Clean up expired tokens regularly

---
