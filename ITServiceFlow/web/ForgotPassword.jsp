<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Forgot Password</title>
    <link rel="stylesheet" href="assets/css/style.css">
</head>
<body>
    <div class="login-container">
        <div class="login-card">
            <div class="login-header">
                <h2>Reset Password</h2>
                <p>Enter your email to receive reset link</p>
            </div>

            <form method="post" action="ForgotPassword" class="login-form" novalidate>
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

                <div class="form-group">
                    <div class="input-wrapper">
                        <input type="email" id="email" name="email" required>
                        <label for="email">Email</label>
                        <span class="input-border"></span>
                    </div>
                </div>

                <button type="submit" class="login-btn">
                    <span class="btn-text">Send Reset Link</span>
                </button>

                <div class="form-options" style="margin-top:16px;justify-content:center;">
                    <a href="Login" class="forgot-password">Back to Login</a>
                </div>
            </form>
        </div>
    </div>
</body>
</html>
