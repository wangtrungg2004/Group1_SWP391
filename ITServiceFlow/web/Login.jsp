<%-- 
    Document   : Login
    Created on : Jan 14, 2026, 1:17:18 PM
    Author     : DELL
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Corporate Login Form</title>
    <link rel="stylesheet" href="assets/css/main.css">
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
                    <a href="#" class="forgot-password">Reset password</a>
                </div>

                <button type="submit" class="login-btn">
                    <span class="btn-text">Sign In</span>
                    <span class="btn-loader"></span>
                </button>
            </form>

            <div class="success-message" id="successMessage">
                <div class="success-icon">✓</div>
                <h3>Authentication Successful</h3>
                <p>Redirecting to your workspace...</p>
            </div>
            <%-- Hiển thị error message từ servlet --%>
        </div>
    </div>

    <script src="../../shared/js/form-utils.js"></script>
    <script src="assets/js/main.js"></script>
</body>
</html>
