# DATABASE SCHEMA & CONFIGURATION

## 1. DATABASE TABLES

### Table: Users

#### Purpose:
Stores user account information, credentials, roles, and organizational structure.

#### Schema:
```sql
CREATE TABLE Users (
    Id INT PRIMARY KEY IDENTITY(1,1),
    Username NVARCHAR(50) UNIQUE NOT NULL,
    Email NVARCHAR(100) UNIQUE NOT NULL,
    PasswordHash NVARCHAR(255) NOT NULL,
    FullName NVARCHAR(100),
    Role NVARCHAR(50),
    DepartmentId INT FOREIGN KEY REFERENCES Departments(Id),
    LocationId INT FOREIGN KEY REFERENCES Locations(Id),
    IsActive BIT DEFAULT 1,
    CreatedAt DATETIME DEFAULT GETDATE()
);
```

#### Columns Explained:

| Column | Type | Purpose | Example | Requirements |
|--------|------|---------|---------|--------------|
| Id | INT | Primary Key | 1 | Auto-increment |
| Username | NVARCHAR(50) | Login identifier | "john" | UNIQUE, NOT NULL |
| Email | NVARCHAR(100) | Email address | "john@example.com" | UNIQUE, NOT NULL |
| PasswordHash | NVARCHAR(255) | SHA-256 hashed password | "8d969eef6ecad3c29a..." | NOT NULL (never store raw) |
| FullName | NVARCHAR(100) | Display name | "John Doe" | Optional |
| Role | NVARCHAR(50) | User role | "Manager", "Admin", "User", "IT Support" | Optional |
| DepartmentId | INT | Department association | 1, 2, 3 | Foreign Key (optional) |
| LocationId | INT | Location association | 1, 2, 3 | Foreign Key, Required |
| IsActive | BIT | Account active status | 1 (active) / 0 (inactive) | Default: 1 |
| CreatedAt | DATETIME | Account creation date | '2025-03-02 10:00:00' | Default: Current Timestamp |

#### Sample Data:
```sql
INSERT INTO Users VALUES
(1, 'admin', 'admin@example.com', '8d969eef6ecad...', 'Admin User', 'Admin', NULL, 1, 1, '2025-01-01'),
(2, 'john', 'john@example.com', '8d969eef6ecad...', 'John Doe', 'Manager', 1, 1, 1, '2025-01-15'),
(3, 'jane', 'jane@example.com', '8d969eef6ecad...', 'Jane Smith', 'User', 1, 1, 1, '2025-02-01'),
(4, 'bob', 'bob@example.com', '8d969eef6ecad...', 'Bob IT', 'IT Support', 2, 1, 1, '2025-02-10');
```

#### Indexes:
```sql
-- For login performance
CREATE UNIQUE INDEX idx_username ON Users(Username);
CREATE UNIQUE INDEX idx_email ON Users(Email);
CREATE INDEX idx_role ON Users(Role);
CREATE INDEX idx_isactive ON Users(IsActive);
```

#### Password Hash Format:
```
Raw Password: "123456"
Algorithm: SHA-256
Output: "8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6472"
Length: 64 characters (hex string of 32 bytes)
Database field size: NVARCHAR(255) - sufficient for SHA-256
```

---

### Table: PasswordResetTokens

#### Purpose:
Stores one-time tokens for password reset via email. Automatically expires after 15 minutes.

#### Schema:
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

#### Columns Explained:

| Column | Type | Purpose | Example | Requirements |
|--------|------|---------|---------|--------------|
| Id | INT | Primary Key | 1, 2, 3 | Auto-increment |
| UserId | INT | Reference to user | 2 | Foreign Key to Users(Id) |
| Token | NVARCHAR(MAX) | Reset token | "550e8400-e29b-41d4-a716-446655440000" | NOT NULL, UUID format |
| ExpiresAt | DATETIME | Token expiration time | '2025-03-02 10:15:00' | NOT NULL, 15 min from creation |
| IsUsed | BIT | Token used status | 0 (not used) / 1 (used) | Default: 0 |
| CreatedAt | DATETIME | Token creation time | '2025-03-02 10:00:00' | Default: Current Timestamp |

#### Sample Data:
```sql
INSERT INTO PasswordResetTokens VALUES
(1, 2, '550e8400-e29b-41d4-a716-446655440000', '2025-03-02 10:15:00', 0, '2025-03-02 10:00:00'),
(2, 3, '9f9c9c1d-87e2-4f5c-8c8d-5b5b5b5b5b5b', '2025-03-02 10:30:00', 1, '2025-03-02 10:15:00');
```

#### Cleanup Query:
```sql
-- Delete expired tokens older than 1 day
DELETE FROM PasswordResetTokens
WHERE CreatedAt < DATEADD(DAY, -1, GETDATE());
```

#### Query Examples:

##### Get valid token by token value:
```sql
SELECT TOP 1 UserId
FROM PasswordResetTokens
WHERE Token = '550e8400-e29b-41d4-a716-446655440000'
  AND IsUsed = 0
  AND ExpiresAt > GETDATE();
```

##### Mark token as used:
```sql
UPDATE PasswordResetTokens
SET IsUsed = 1
WHERE Token = '550e8400-e29b-41d4-a716-446655440000';
```

---

## 2. RELATED TABLES

### Table: Departments
```sql
CREATE TABLE Departments (
    Id INT PRIMARY KEY IDENTITY(1,1),
    DepartmentName NVARCHAR(100),
    Description NVARCHAR(255)
);
```

### Table: Locations
```sql
CREATE TABLE Locations (
    Id INT PRIMARY KEY IDENTITY(1,1),
    LocationName NVARCHAR(100),
    Address NVARCHAR(255)
);
```

---

## 3. CONFIGURATION FILES

### web.xml (Deployment Descriptor)

```xml
<?xml version="1.0" encoding="UTF-8"?>
<web-app xmlns="http://xmlns.jcp.org/xml/ns/javaee"
         xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xsi:schemaLocation="http://xmlns.jcp.org/xml/ns/javaee
         http://xmlns.jcp.org/xml/ns/javaee/web-app_4_0.xsd"
         version="4.0">

    <!-- Session Configuration -->
    <session-config>
        <!-- Timeout in minutes -->
        <cookie-config>
            <secure>true</secure>
            <http-only>true</http-only>
        </cookie-config>
        <tracking-mode>COOKIE</tracking-mode>
    </session-config>

    <!-- Error Pages -->
    <error-page>
        <error-code>403</error-code>
        <location>/error403.jsp</location>
    </error-page>

    <error-page>
        <error-code>404</error-code>
        <location>/error404.jsp</location>
    </error-page>

</web-app>
```

### mail.properties (Email & Google Configuration)

```properties
# Gmail SMTP Configuration
mail.smtp.host=smtp.gmail.com
mail.smtp.port=587
mail.smtp.auth=true
mail.smtp.starttls.enable=true
mail.smtp.starttls.required=true
mail.smtp.ttls.protocols=TLSv1.2

# Email credentials (use App Password for Gmail)
mail.from=noreply@itserviceflow.com
mail.username=your-email@gmail.com
mail.password=your-app-password

# Google OAuth Configuration
GOOGLE_CLIENT_ID=1234567890-abcdefghijklmnop.apps.googleusercontent.com
GOOGLE_CLIENT_SECRET=your-client-secret-key

# Application
app.url=http://localhost:8080/ITServiceFlow
app.name=IT Service Flow
```

### DbContext Configuration

#### Java Code:
```java
public class DbContext {
    protected Connection connection;

    public DbContext() {
        try {
            // SQL Server JDBC Connection
            Class.forName("com.microsoft.sqlserver.jdbc.SQLServerDriver");
            String url = "jdbc:sqlserver://localhost:1433;databaseName=ITServiceDB;encrypt=true;trustServerCertificate=true";
            String user = "sa";
            String password = "your-password";
            
            connection = DriverManager.getConnection(url, user, password);
        } catch (ClassNotFoundException | SQLException e) {
            e.printStackTrace();
        }
    }
}
```

#### Connection String Components:
```
Protocol:    jdbc:sqlserver://
Server:      localhost:1433  (host:port)
Database:    ITServiceDB
Encrypt:     true
Trust Cert:  true (for self-signed certificates)
User:        sa
Password:    (see web.xml or environment variables)
```

---

## 4. ROLE PERMISSIONS MATRIX

### Access Control by Role

```
┌─────────────┬──────────────┬─────────┬────────┬────────────┐
│ Feature     │ Admin        │ Manager │ User   │ IT Support │
├─────────────┼──────────────┼─────────┼────────┼────────────┤
│ Login       │ ✓            │ ✓       │ ✓      │ ✓          │
│ Dashboard   │ Admin        │ Manager │ User   │ IT         │
├─────────────┼──────────────┼─────────┼────────┼────────────┤
│ Problems    │              │         │        │            │
│ - View All  │ ✓            │ ✓       │ ✗      │ ✓          │
│ - View Own  │ ✓            │ ✓       │ ✓      │ ✓          │
│ - Create    │ ✓            │ ✓       │ ✗      │ ✗          │
│ - Update    │ ✓            │ ✓       │ ✗      │ ✓          │
│ - Delete    │ ✓            │ ✗       │ ✗      │ ✗          │
├─────────────┼──────────────┼─────────┼────────┼────────────┤
│ Users       │              │         │        │            │
│ - View All  │ ✓            │ ✓       │ ✗      │ ✗          │
│ - Create    │ ✓            │ ✗       │ ✗      │ ✗          │
│ - Edit      │ ✓            │ ✗       │ ✓(self)│ ✗          │
│ - Deactivate│ ✓            │ ✗       │ ✗      │ ✗          │
├─────────────┼──────────────┼─────────┼────────┼────────────┤
│ Reports     │ ✓            │ ✓       │ ✗      │ ✓          │
│ Settings    │ ✓            │ ✗       │ ✗      │ ✗          │
└─────────────┴──────────────┴─────────┴────────┴────────────┘
```

### Role Definitions

#### Admin
- Full system access
- Can manage all areas
- Can create/delete users
- Can view all reports
- Can change system settings

#### Manager
- Can create and manage problems
- Can view user dashboard
- Can create new users
- Can view reports
- Cannot delete data
- Cannot change settings

#### User
- Can view own problems
- Can view own dashboard
- Can update own profile
- Cannot create problems (not in this config)
- Limited read access

#### IT Support
- Can view all problems
- Can update problem status
- Can see IT dashboard
- Can add solutions/notes
- Cannot create new problems
- Cannot manage users

---

## 5. AUTHENTICATION FLOW SUMMARY

### Login Sequence:
```
1. User submits username + password
2. Controller gets input
3. Service hashes password with SHA-256
4. DAO queries database:
   SELECT * FROM Users 
   WHERE Username=? AND PasswordHash=? AND IsActive=1
5. If found:
   - Create HttpSession
   - Store user, role, userId
   - Redirect to role-specific dashboard
6. If not found:
   - Show error message
   - Re-display login form
```

### Session Management:
```
Login → Session Created with:
  - user: Users object (Id, Username, FullName, Role)
  - role: String ("Admin", "Manager", "User", "IT Support")
  - userId: Integer (primary key)

Protected Page Request → Filter Checks:
  1. Is public page? → Allow
  2. Session exists? → If no, redirect to login
  3. User in session? → If no, redirect to login
  4. Role in session? → If no, redirect to login
  5. Is admin? → Allow all
  6. Has role access? → Check permissions by role
  7. If allowed → Process request
  8. If denied → Return 403 Forbidden

Logout → Session Destroyed:
  - session.invalidate()
  - JSESSIONID cookie removed
  - User must login again
```

---

## 6. PASSWORD RESET FLOW SUMMARY

### Forgot Password Process:
```
1. User clicks "Forgot Password"
2. User enters email
3. System checks if email exists
4. If exists:
   a. Generate UUID token
   b. Calculate expiration (NOW + 15 minutes)
   c. Save to PasswordResetTokens table
   d. Send email with link: /ResetPassword?token=UUID
5. User receives email
6. User clicks link
7. System validates token:
   - Token exists
   - IsUsed = 0
   - ExpiresAt > NOW
8. If valid:
   - Show password reset form
9. User enters new password
10. System validates:
    - Passwords filled
    - Passwords match
    - Length >= 6
11. If valid:
    - Hash new password
    - Update Users table
    - Mark token as used
    - Redirect to login with success message
12. User can login with new password
```

### Token Validation:
```sql
SELECT TOP 1 UserId
FROM PasswordResetTokens
WHERE Token = 'VALUE'
  AND IsUsed = 0
  AND ExpiresAt > GETDATE()
```

- If returns UserId: Token is valid
- If returns nothing: Token is invalid, expired, or already used

---

## 7. GOOGLE OAUTH FLOW SUMMARY

### Google Sign-In Process:
```
1. Frontend: Google One Tap loads
2. User selects Google account
3. Google returns credential (JWT)
4. Frontend: POSTs credential to /GoogleLogin
5. Backend: Gets GOOGLE_CLIENT_ID from config
6. Backend: Calls GoogleAuthUtil.verifyIdToken()
7. Verification:
   a. URL encodes token
   b. Calls https://oauth2.googleapis.com/tokeninfo
   c. Google verifies token
   d. Google returns JSON with: aud, email, email_verified
8. Backend validates:
   - aud (Client ID) matches expected value
   - email_verified = true
   - email is not blank
9. If valid:
   - Get GoogleUserInfo (email, aud, emailVerified)
10. Backend: Lookup user by email
11. Query: SELECT * FROM Users WHERE Email=? AND IsActive=1
12. If found:
    - Create session
    - Redirect to dashboard
13. If not found:
    - Show error: "No account for this Google email"
    - Cannot auto-create (manual setup required)
```

### Important Notes:
- Google account email MUST exist in Users table
- Email MUST be verified with Google
- IsActive MUST be 1
- GOOGLE_CLIENT_ID MUST be configured
- No password stored for Google accounts
- Token is verified with Google API (verified only)

---

## 8. ERROR SCENARIOS

### Login Errors:

#### "Invalid username or password"
- Cause: Username not found OR password hash doesn't match
- SQL result: 0 rows
- UserDao.login() returns: null

#### "User not active"
- Cause: IsActive = 0
- SQL includes: AND IsActive = 1
- UserDao.login() returns: null

#### "Database connection error"
- Cause: Connection is null or exception thrown
- Check: DbContext initialization
- Check: SQL Server running
- Check: Connection string correct

### Forgot Password Errors:

#### "Email does not exist"
- Cause: No user with this email
- SQL: SELECT FROM Users WHERE Email=?
- Result: 0 rows

#### "Cannot create reset link"
- Cause: savePasswordResetToken() failed
- Check: Database insert permission
- Check: Insert statement syntax

#### "Cannot send reset email"
- Cause: Email service not configured
- Check: mail.properties exists
- Check: SMTP credentials correct
- Check: Gmail app password generated

### Reset Password Errors:

#### "Invalid or expired reset link"
- Cause: Token not found, IsUsed=1, or ExpiresAt passed
- SQL: SELECT FROM PasswordResetTokens 
       WHERE Token=? AND IsUsed=0 AND ExpiresAt>NOW
- Result: 0 rows

#### "Passwords don't match"
- User entered different values in password fields
- Validation on controller

#### "Password too short"
- Length < 6 characters
- Validation on controller

### Google Login Errors:

#### "Google login not configured"
- Cause: GOOGLE_CLIENT_ID not set
- Check: Environment variable
- Check: System property
- Check: mail.properties

#### "Google authentication failed"
- Cause: Invalid token OR Google API unreachable
- Check: Token validity
- Check: Internet connection
- Check: Google API status

#### "No active account for this Google email"
- Cause: Email not in Users table
- Action: Admin must create user with Google email first
- No auto-account creation

### Authorization Errors:

#### "403 Forbidden"
- Cause: Role doesn't have access to resource
- Check: User role
- Check: Filter permissions for role
- Action: Admin must grant access

---

## 9. DATABASE QUERIES REFERENCE

### Query: Login
```sql
SELECT Id, Username, FullName, Role, IsActive
FROM Users
WHERE Username = @username
  AND PasswordHash = @passwordHash
  AND IsActive = 1;
```

### Query: Get user by email
```sql
SELECT Id, Username, Email, FullName, Role, IsActive
FROM Users
WHERE Email = @email
  AND IsActive = 1;
```

### Query: Create password reset token
```sql
INSERT INTO PasswordResetTokens (UserId, Token, ExpiresAt, IsUsed)
VALUES (@userId, @token, @expiresAt, 0);
```

### Query: Validate reset token
```sql
SELECT TOP 1 UserId
FROM PasswordResetTokens
WHERE Token = @token
  AND IsUsed = 0
  AND ExpiresAt > GETDATE();
```

### Query: Update password
```sql
UPDATE Users
SET PasswordHash = @newPasswordHash
WHERE Id = @userId
  AND IsActive = 1;
```

### Query: Mark token used
```sql
UPDATE PasswordResetTokens
SET IsUsed = 1
WHERE Token = @token;
```

### Query: Get all active users
```sql
SELECT *
FROM Users
WHERE IsActive = 1
ORDER BY CreatedAt DESC;
```

### Query: Deactivate user
```sql
UPDATE Users
SET IsActive = 0
WHERE Id = @userId;
```

---

## 10. SECURITY BEST PRACTICES CHECKLIST

### Password Security:
- [ ] Use SHA-256 (minimum) or bcrypt (recommended)
- [ ] Never store plain text passwords
- [ ] Don't log passwords
- [ ] Validate password length (minimum 6 chars)
- [ ] Hash before storing in database
- [ ] Use bind parameters in SQL (prevent SQL injection)

### Session Security:
- [ ] Use HTTPS only
- [ ] Set HttpOnly flag on session cookie
- [ ] Set Secure flag on session cookie
- [ ] Implement session timeout
- [ ] Invalidate session on logout
- [ ] Regenerate session ID after login

### Reset Password Security:
- [ ] Use strong random tokens (UUID recommended)
- [ ] Set short expiration time (15 minutes)
- [ ] One-time use only (IsUsed flag)
- [ ] Validate token on every step
- [ ] Send link via email only
- [ ] Require email verification

### Google OAuth Security:
- [ ] Verify token with Google API
- [ ] Check email_verified flag
- [ ] Check Client ID matches
- [ ] Use HTTPS only
- [ ] Don't trust client-provided tokens
- [ ] Require email to exist in system first

### Authorization Security:
- [ ] Filter protects all sensitive URLs
- [ ] Check role for every request
- [ ] Don't rely on frontend validation
- [ ] Implement principle of least privilege
- [ ] Log access attempts
- [ ] Return 403 for unauthorized access

### Input Validation:
- [ ] Trim all string inputs
- [ ] Validate non-null inputs
- [ ] Validate string length
- [ ] Validate email format
- [ ] Use bind parameters in SQL
- [ ] Don't echo user input without escaping

---
