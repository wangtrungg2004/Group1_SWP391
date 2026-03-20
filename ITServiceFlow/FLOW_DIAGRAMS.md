# DIAGRAM & FLOW VISUALIZATION

## 1. Login Flow Diagram

```mermaid
graph TD
    A[User: Nhập username & password] -->|Submit Login Form| B[Login Servlet - doPost]
    B --> C{Input validation}
    C -->|Null/Empty| D["Forward Login.jsp<br/>Error: empty fields"]
    C -->|Valid| E[UserService.login<br/>Hash password with SHA-256]
    E --> F[UserDao.login<br/>Query WHERE Username=? AND PasswordHash=? AND IsActive=1]
    F --> G{User found?}
    G -->|No match| H["Return null<br/>Invalid username/password"]
    G -->|Found| I["Return Users object<br/>Id, Username, FullName, Role"]
    H --> J["Request.setAttribute error<br/>Forward Login.jsp"]
    I --> K[Create HttpSession<br/>setAttribute user, role, userId]
    K --> L{Get User.getRole}
    L -->|Admin| M["Redirect<br/>/AdminDashboard.jsp"]
    L -->|Manager| N["Redirect<br/>/ManagerDashboard.jsp"]
    L -->|User| O["Redirect<br/>/UserDashboard.jsp"]
    L -->|IT Support| P["Redirect<br/>/ITDashboard.jsp"]
    L -->|Invalid| Q["Error: Role invalid<br/>Forward Login.jsp"]
    D --> J
    J --> R[User sees error message]
    M --> S[User Dashboard loaded]
    N --> S
    O --> S
    P --> S
    Q --> R
```

## 2. Password Reset Flow (Forgot Password)

```mermaid
graph TD
    A[User: Nhập email] -->|Submit Forgot Password| B[ForgotPassword - doPost]
    B --> C{Email validation}
    C -->|Blank| D["Error: Blank email<br/>Forward ForgotPassword.jsp"]
    C -->|Valid| E[UserService.getUserByEmail]
    E --> F[UserDao.getUserByEmail<br/>Query WHERE Email=? AND IsActive=1]
    F --> G{User exists?}
    G -->|No| H["Error: Email not exists<br/>Forward ForgotPassword.jsp"]
    G -->|Yes| I[UserService.createPasswordResetToken]
    I --> J["Generate UUID token<br/>Calculate ExpiresAt=NOW+15minutes"]
    J --> K[UserDao.savePasswordResetToken<br/>INSERT INTO PasswordResetTokens]
    K --> L{Token saved?}
    L -->|Failed| M["Error: Cannot create link<br/>Forward ForgotPassword.jsp"]
    L -->|Success| N[Build reset link<br/>http://domain/ResetPassword?token=TOKEN]
    N --> O[EmailUtil.sendForgotPasswordEmail<br/>Send link to email]
    O --> P{Email sent?}
    P -->|Failed| Q["Error: Mail config<br/>Forward ForgotPassword.jsp"]
    P -->|Success| R["Success: Link sent to email<br/>Forward ForgotPassword.jsp"]
    D --> S[User sees error]
    H --> S
    M --> S
    Q --> S
    R --> T[User receives email]
    T --> U[User clicks link<br/>GET /ResetPassword?token=TOKEN]
    U --> V[ResetPassword - doGet]
    V --> W[Extract token parameter]
    W --> X[UserService.isValidResetToken]
    X --> Y[UserDao.getValidUserIdByToken<br/>Query WHERE Token=? AND IsUsed=0 AND ExpiresAt>NOW]
    Y --> Z{Token valid?}
    Z -->|Expired/Used| AA["Error: Invalid link<br/>Forward ForgotPassword.jsp"]
    Z -->|Valid| AB["setAttribute token<br/>Forward ResetPassword.jsp"]
    AA --> AC[User sees error]
    AB --> AD[User sees password reset form]
    AD --> AE[User submits new password]
    AE --> AF[ResetPassword - doPost]
    AF --> AG{Validate inputs}
    AG -->|Token invalid| AH["Forward with error"]
    AG -->|Passwords blank| AI["Forward with error"]
    AG -->|Password < 6 chars| AJ["Forward with error"]
    AG -->|newPassword != confirm| AK["Forward with error"]
    AG -->|All valid| AL[UserService.resetPasswordByToken]
    AL --> AM[Get userId from token]
    AM --> AN["Hash new password<br/>PasswordUtil.sha256"]
    AN --> AO[UserDao.updatePasswordByUserId<br/>UPDATE Users SET PasswordHash WHERE Id=?]
    AO --> AP[UserDao.markTokenUsed<br/>UPDATE PasswordResetTokens SET IsUsed=1]
    AP --> AQ["Success message<br/>Forward Login.jsp"]
    AQ --> AR[User can login with new password]
    AH --> AS[User sees error]
    AI --> AS
    AJ --> AS
    AK --> AS
```

## 3. Google Login Flow

```mermaid
graph TD
    A[User clicks Google Sign-In] -->|Google One Tap| B[Google Login Dialog]
    B --> C[User selects account]
    C --> D["Google returns<br/>credential ID Token"]
    D --> E[Frontend posts token<br/>POST /GoogleLogin]
    E --> F[GoogleLogin - doPost]
    F --> G["Get GOOGLE_CLIENT_ID<br/>from env/config"]
    G --> H{CLIENT_ID exists?}
    H -->|No| I["Error: Not configured<br/>Forward Login.jsp"]
    H -->|Yes| J[GoogleAuthUtil.verifyIdToken<br/>token, clientId]
    J --> K["URL encode token<br/>Call https://oauth2.googleapis.com/tokeninfo"]
    K --> L{API Response valid?}
    L -->|HTTP != 200| M["Return null"]
    L -->|HTTP 200| N["Parse JSON response<br/>aud, email, email_verified"]
    M --> O["Error: Auth failed<br/>Forward Login.jsp"]
    N --> P{Validate response}
    P -->|aud != clientId| Q["Return null"]
    P -->|email_verified != true| Q
    P -->|email blank| Q
    P -->|All valid| R["Return GoogleUserInfo<br/>email, aud, emailVerified"]
    Q --> O
    R --> S[UserService.loginWithGoogleEmail<br/>email]
    S --> T[UserDao.getUserByEmail<br/>Query WHERE Email=? AND IsActive=1]
    T --> U{User found?}
    U -->|No| V["Error: No account for email<br/>Forward Login.jsp"]
    U -->|Yes| W["Return Users object"]
    V --> X[User sees error]
    W --> Y[Create HttpSession<br/>setAttribute user, role, userId]
    Y --> Z[redirectByRole<br/>based on user.getRole]
    Z --> AA[Redirect to Dashboard]
    AA --> AB[User logged in]
```

## 4. Authorization Filter Flow

```mermaid
graph TD
    A["User requests<br/>Protected URL"] -->|HTTP Request| B[AuthorizationFilter.doFilter]
    B --> C["Get RequestURI<br/>Get Session"]
    C --> D["Extract path from URI"]
    D --> E{Is PUBLIC path?<br/>Login/ForgotPassword/etc}
    E -->|Yes| F["chain.doFilter<br/>Allow request"]
    E -->|No| G{Session exists?}
    G -->|No| H["Response.sendRedirect<br/>/Login.jsp"]
    G -->|Yes| I{session.getAttribute<br/>user exists?}
    I -->|No| H
    I -->|Yes| J["Get role from session<br/>role = session.getAttribute role"]
    J --> K{Role exists?}
    K -->|No| H
    K -->|Yes| L{Role == Admin?}
    L -->|Yes| F
    L -->|No| M["Call hasAccessByRole<br/>role, path"]
    M --> N{User has access?}
    N -->|Yes| F
    N -->|No| O["Response.sendError<br/>403 Forbidden"]
    F --> P[Proceed to<br/>Servlet/JSP]
    H --> Q[Redirect to Login]
    O --> R[Show 403 Error Page]
    P --> S[Process request]
```

## 5. Role-Based Access Control (RBAC)

```mermaid
graph TD
    A["User with Role<br/>from session"] --> B{Role Type}
    
    B -->|Admin| C["✓ Full Access<br/>All URLs allowed<br/>No restrictions"]
    
    B -->|Manager| D["✓ Limited Access<br/>ManagerDashboard<br/>UserDashboard<br/>ProblemList/Add/Update/Detail<br/>/user/*"]
    
    B -->|User| E["✓ Limited Access<br/>UserDashboard<br/>ProblemList/Detail only<br/>/user/*<br/>Cannot Add/Update"]
    
    B -->|IT Support| F["✓ Limited Access<br/>ITDashboard<br/>ProblemDetail/Update<br/>ITSupportProblemList<br/>/it/*<br/>Cannot Add"]
    
    B -->|Other/Invalid| G["✗ No Access<br/>403 Forbidden<br/>Redirect to Login"]
    
    C --> H["Access Granted"]
    D --> H
    E --> H
    F --> H
    G --> I["Access Denied"]
```

## 6. Password Hash & Verification Flow

```mermaid
graph TD
    A["Raw Password<br/>'123456'"] --> B["PasswordUtil.sha256"]
    B --> C["MessageDigest<br/>SHA-256 algorithm"]
    C --> D["Convert bytes<br/>to HEX string"]
    D --> E["Hash<br/>'8d969eef...'"]
    
    E --> F["Save to DB<br/>Users.PasswordHash"]
    
    G["User Login<br/>Input: '123456'"] -->|During Login| H["PasswordUtil.sha256<br/>input password"]
    H --> I["Same hash<br/>'8d969eef...'"]
    I --> J{hash == DB hash?}
    J -->|Yes| K["✓ Password Match<br/>Login Success"]
    J -->|No| L["✗ Password Mismatch<br/>Login Failed"]
    
    E -.->|Stored in DB| F
    I -.->|Compare with| F
```

## 7. Session Management

```mermaid
graph TD
    A[Login Success] --> B[Create HttpSession<br/>request.getSession]
    B --> C["session.setAttribute<br/>user, Users object"]
    C --> D["session.setAttribute<br/>role, String"]
    D --> E["session.setAttribute<br/>userId, Integer"]
    E --> F[Session Created & Stored<br/>in Server Memory]
    
    F --> G["User makes request<br/>with JSESSIONID cookie"]
    G --> H[Filter validates<br/>session still exists]
    H --> I["Retrieve role from<br/>session attributes"]
    I --> J["Check authorization<br/>hasAccessByRole"]
    J --> K{Allowed?}
    K -->|Yes| L["Continue to JSP/Servlet"]
    K -->|No| M["403 Forbidden"]
    
    N[User clicks Logout] --> O["Logout Servlet<br/>session.invalidate"]
    O --> P[Session Destroyed]
    P --> Q["JSESSIONID cookie<br/>no longer valid"]
    Q --> R["Redirect to Login"]
    R --> S["User must login again"]
```

## 8. Database Transaction: Login

```mermaid
graph LR
    A["SELECT Id, Username,<br/>FullName, Role, IsActive<br/>FROM Users<br/>WHERE Username=?<br/>AND PasswordHash=?<br/>AND IsActive=1"] -->|DB Query| B["SQL Server<br/>Execute Query"]
    B -->|Result Set| C{Row exists?}
    C -->|No| D["ResultSet.next<br/>returns false"]
    C -->|Yes| E["Extract columns<br/>from ResultSet"]
    D --> F["Return null<br/>Login Failed"]
    E --> G["Create Users object<br/>Set Id, Username,<br/>FullName, Role"]
    G --> H["Return Users object<br/>Login Success"]
```

## 9. Email Token Generation & Validation

```mermaid
graph TD
    A["User requests<br/>password reset"] --> B["UUID.randomUUID<br/>Generate unique token"]
    B --> C["token_value<br/>550e8400-e29b-41d4..."]
    C --> D["Calculate ExpiresAt<br/>NOW + 15 minutes"]
    D --> E["INSERT INTO<br/>PasswordResetTokens<br/>UserId, Token,<br/>ExpiresAt, IsUsed=0"]
    E --> F["Token Row Created<br/>in Database"]
    
    F --> G["Email with link<br/>sent to user"]
    
    G -->|User clicks link| H["Token value<br/>from URL parameter"]
    H --> I["SELECT UserId<br/>FROM PasswordResetTokens<br/>WHERE Token=?<br/>AND IsUsed=0<br/>AND ExpiresAt > NOW"]
    I --> J{Token found &<br/>Valid?}
    J -->|Token not found| K["Return null<br/>Invalid link"]
    J -->|IsUsed=1| K
    J -->|ExpiresAt passed| K
    J -->|Token valid| L["Return UserId<br/>Link valid"]
    
    K --> M["Show error message<br/>Request new link"]
    L --> N["Show reset form<br/>Allow password change"]
    N --> O["UPDATE Users<br/>SET PasswordHash=new"]
    O --> P["UPDATE<br/>PasswordResetTokens<br/>SET IsUsed=1"]
    P --> Q["Token marked used<br/>Cannot be reused"]
```

## 10. Google OAuth 2.0 Token Verification

```mermaid
graph TD
    A["Google Frontend<br/>Google One Tap"] -->|User selects account| B["GoogleUserInfo<br/>credential JWT Token"]
    B --> C["POST /GoogleLogin<br/>credential param"]
    C --> D[GoogleLogin Controller]
    D --> E["GoogleAuthUtil<br/>.verifyIdToken"]
    E --> F["URLEncode token"]
    F --> G["HTTP GET Request<br/>oauth2.googleapis.com<br/>/tokeninfo?id_token="]
    G --> H["Google API Server"]
    H --> I{"Verify token<br/>validity"}
    I -->|Invalid| J["Return 400<br/>Bad Request"]
    I -->|Expired| J
    I -->|Valid| K["Return 200 OK<br/>JSON Response"]
    
    J --> L["GoogleAuthUtil<br/>returns null"]
    K --> M["Parse JSON:<br/>aud, email,<br/>email_verified, etc"]
    M --> N{"Validate<br/>aud == clientId?<br/>email_verified<br/>==true?"}
    N -->|Invalid| O["Return null"]
    N -->|Valid| P["Return GoogleUserInfo"]
    
    L --> Q["Error: Auth Failed<br/>Forward Login.jsp"]
    O --> Q
    P --> R["Find user by email<br/>getUserByEmail<br/>email"]
    R --> S["Query DB<br/>SELECT * FROM Users<br/>WHERE Email=? AND IsActive=1"]
    S --> T{User exists?}
    T -->|No| U["Return null<br/>No account"]
    T -->|Yes| V["Return Users object"]
    U --> W["Error: No account<br/>Must create account first"]
    V --> X["Create session"]
```
