<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Set New Password</title>
    <link rel="stylesheet" href="assets/css/style.css">
</head>
<body>
    <div class="login-container">
        <div class="login-card">
            <div class="login-header">
                <h2>Set New Password</h2>
                <p>Enter your new password</p>
            </div>

            <form method="post" action="ResetPassword" class="login-form" novalidate>
                <input type="hidden" name="token" value="${token}">

                <c:if test="${not empty error}">
                    <div class="login-error">
                        <strong>Error:</strong> ${error}
                    </div>
                </c:if>

                <div class="form-group">
                    <div class="input-wrapper">
                        <input type="password" id="newPassword" name="newPassword" required>
                        <label for="newPassword">New Password</label>
                        <span class="input-border"></span>
                    </div>
                </div>

                <div class="form-group">
                    <div class="input-wrapper">
                        <input type="password" id="confirmPassword" name="confirmPassword" required>
                        <label for="confirmPassword">Confirm Password</label>
                        <span class="input-border"></span>
                    </div>
                </div>

                <button type="submit" class="login-btn">
                    <span class="btn-text">Update Password</span>
                </button>

                <div class="form-options" style="margin-top:16px;justify-content:center;">
                    <a href="Login" class="forgot-password">Back to Login</a>
                </div>
            </form>
        </div>
    </div>
</body>
</html>
