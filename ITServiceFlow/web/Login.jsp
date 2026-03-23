<%-- 
    Document   : Login
    Created on : Jan 14, 2026, 1:17:18 PM
    Author     : DELL
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="Utils.GoogleAuthUtil"%>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<%
    String resolvedGoogleClientId = (String) request.getAttribute("googleClientId");
    if (resolvedGoogleClientId == null || resolvedGoogleClientId.isBlank()) {
        resolvedGoogleClientId = GoogleAuthUtil.getGoogleClientId();
    }
    if (resolvedGoogleClientId == null) {
        resolvedGoogleClientId = "";
    }
    request.setAttribute("googleClientId", resolvedGoogleClientId);
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Corporate Login Form</title>
    <link rel="stylesheet" href="assets/css/style.css">
    <script src="https://accounts.google.com/gsi/client" async defer></script>
</head>
<body>
    <div class="login-container">
        <div class="login-card">
            <div class="login-header">
                <h2>Welcome Back</h2>
                <p>Please sign in to your corporate account</p>
            </div>
            
            <form method="post" action="Login" class="login-form" id="loginForm" novalidate>
                <div class="form-group">
                    <c:if test="${not empty error}">
                        <div class="login-error">
                            <strong>Error:</strong> ${error}
                        </div>
                    </c:if>
                    <c:if test="${not empty message}">
                        <div class="login-error" style="background:#e8f5e9;color:#2e7d32;border-left:4px solid #2e7d32;">
                            <strong>Success:</strong> ${message}
                        </div>
                    </c:if>
                    <div class="input-wrapper">
                        <input type="text" id="username" name="username" required >
                        <label for="username">User Name</label>
                        <span class="input-border"></span>
                    </div>
                </div>


                <div class="form-group">
                    <div class="input-wrapper password-wrapper">
                        <input type="password" id="password" name="password" required>
                        <label for="password">Password</label>
                        <button type="button" class="password-toggle" id="passwordToggle" aria-label="Toggle password visibility">
                            <span class="toggle-icon"></span>
                        </button>
                        <span class="input-border"></span>
                    </div>
                    <span class="error-message" id="passwordError"></span>
                </div>

                <div class="form-options">
                    <div class="remember-wrapper">
                        <input type="checkbox" id="remember" name="remember">
                        <label for="remember" class="checkbox-label">
                            <span class="checkbox-custom"></span>
                            Keep me signed in
                        </label>
                    </div>
                    <a href="ForgotPassword" class="forgot-password">Forgot password</a>
                </div>

                <button type="submit" class="login-btn">
                    <span class="btn-text">Sign In</span>
                    <span class="btn-loader"></span>
                </button>
            </form>

            <form id="googleLoginForm" method="post" action="GoogleLogin" style="margin-top: 16px;">
                <input type="hidden" id="googleCredential" name="credential">
                <div id="g_id_onload"
                     data-client_id="${googleClientId}"
                     data-callback="handleGoogleCredential"
                     data-auto_prompt="false"></div>
                <div class="g_id_signin"
                     data-type="standard"
                     data-shape="pill"
                     data-theme="outline"
                     data-text="sign_in_with"
                     data-size="large"
                     data-logo_alignment="left"
                     data-width="100%"></div>
            </form>

            <div class="success-message" id="successMessage">
                <div class="success-icon">✓</div>
                <h3>Authentication Successful</h3>
                <p>Redirecting to your workspace...</p>
            </div>
            <%-- Hiển thị error message từ servlet --%>
        </div>
    </div>

    <script src="assets/js/login.js"></script>
    <script>
        function handleGoogleCredential(response) {
            if (!response || !response.credential) {
                return;
            }
            document.getElementById("googleCredential").value = response.credential;
            document.getElementById("googleLoginForm").submit();
        }
    </script>
</body>
</html>
