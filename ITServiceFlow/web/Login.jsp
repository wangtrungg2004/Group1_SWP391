<%-- 
    Document   : Login
    Created on : Jan 14, 2026, 1:17:18 PM
    Author     : DELL
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<%@ page import="Utils.GoogleOAuthConfig" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Đăng nhập - ITServiceFlow</title>
    <link rel="stylesheet" href="assets/fonts/fontawesome/css/fontawesome-all.min.css">
    <link rel="stylesheet" href="assets/plugins/bootstrap/css/bootstrap.min.css">
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }
        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background: #f5f7fa;
            min-height: 100vh;
        }
        .login-wrapper {
            min-height: 100vh;
            display: flex;
        }
        .login-left {
            flex: 1;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            display: flex;
            flex-direction: column;
            justify-content: center;
            align-items: center;
            padding: 60px;
            color: white;
            position: relative;
            overflow: hidden;
        }
        .login-left::before {
            content: '';
            position: absolute;
            width: 200%;
            height: 200%;
            background: url('data:image/svg+xml,<svg width="60" height="60" viewBox="0 0 60 60" xmlns="http://www.w3.org/2000/svg"><g fill="none" fill-rule="evenodd"><g fill="%23ffffff" fill-opacity="0.05"><circle cx="30" cy="30" r="4"/></g></svg>');
            animation: move 20s linear infinite;
        }
        @keyframes move {
            0% { transform: translate(0, 0); }
            100% { transform: translate(50px, 50px); }
        }
        .login-left-content {
            position: relative;
            z-index: 1;
            text-align: center;
            max-width: 500px;
        }
        .login-left h1 {
            font-size: 3rem;
            font-weight: 700;
            margin-bottom: 20px;
            text-shadow: 0 2px 10px rgba(0,0,0,0.2);
        }
        .login-left p {
            font-size: 1.2rem;
            line-height: 1.8;
            opacity: 0.95;
        }
        .login-right {
            flex: 1;
            display: flex;
            align-items: center;
            justify-content: center;
            padding: 40px;
            background: #ffffff;
        }
        .login-form-container {
            width: 100%;
            max-width: 420px;
        }
        .login-logo {
            text-align: center;
            margin-bottom: 40px;
        }
        .login-logo img {
            height: 60px;
            margin-bottom: 15px;
        }
        .login-logo h2 {
            color: #2d3748;
            font-size: 1.8rem;
            font-weight: 600;
            margin-bottom: 8px;
        }
        .login-logo p {
            color: #718096;
            font-size: 0.95rem;
        }
        .form-group {
            margin-bottom: 24px;
        }
        .form-label {
            display: block;
            color: #2d3748;
            font-weight: 500;
            margin-bottom: 8px;
            font-size: 0.9rem;
        }
        .form-control {
            width: 100%;
            padding: 12px 16px;
            border: 1px solid #e2e8f0;
            border-radius: 6px;
            font-size: 0.95rem;
            transition: all 0.2s ease;
            background: #ffffff;
        }
        .form-control:focus {
            outline: none;
            border-color: #667eea;
            box-shadow: 0 0 0 3px rgba(102, 126, 234, 0.1);
        }
        .form-control::placeholder {
            color: #a0aec0;
        }
        .password-wrapper {
            position: relative;
        }
        .password-toggle {
            position: absolute;
            right: 12px;
            top: 50%;
            transform: translateY(-50%);
            background: none;
            border: none;
            color: #718096;
            cursor: pointer;
            padding: 8px;
            font-size: 0.9rem;
        }
        .password-toggle:hover {
            color: #667eea;
        }
        .form-options {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 24px;
            font-size: 0.9rem;
        }
        .remember-me {
            display: flex;
            align-items: center;
            cursor: pointer;
        }
        .remember-me input[type="checkbox"] {
            margin-right: 8px;
            cursor: pointer;
        }
        .remember-me label {
            color: #4a5568;
            cursor: pointer;
            margin: 0;
        }
        .forgot-password {
            color: #667eea;
            text-decoration: none;
            font-weight: 500;
            transition: color 0.2s ease;
        }
        .forgot-password:hover {
            color: #764ba2;
            text-decoration: none;
        }
        .btn-login {
            width: 100%;
            padding: 14px;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            border: none;
            border-radius: 6px;
            font-size: 1rem;
            font-weight: 600;
            cursor: pointer;
            transition: all 0.3s ease;
            box-shadow: 0 4px 12px rgba(102, 126, 234, 0.3);
        }
        .btn-login:hover {
            transform: translateY(-2px);
            box-shadow: 0 6px 20px rgba(102, 126, 234, 0.4);
        }
        .btn-login:active {
            transform: translateY(0);
        }
        .btn-google {
            display: inline-block;
            width: 100%;
            padding: 12px 16px;
            background: white;
            color: #4a5568;
            border: 1px solid #e2e8f0;
            border-radius: 6px;
            font-size: 0.95rem;
            font-weight: 500;
            cursor: pointer;
            transition: all 0.3s ease;
            text-decoration: none;
            text-align: center;
            box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
        }
        .btn-google:hover {
            background: #f7fafc;
            border-color: #cbd5e0;
            box-shadow: 0 4px 12px rgba(0, 0, 0, 0.12);
            text-decoration: none;
            color: #4a5568;
        }
        .btn-google i {
            margin-right: 8px;
            color: #db4437;
        }
        .social-login {
            margin-top: 24px;
            padding-top: 24px;
            border-top: 1px solid #e2e8f0;
        }
        .alert {
            padding: 12px 16px;
            border-radius: 6px;
            margin-bottom: 24px;
            font-size: 0.9rem;
        }
        .alert-danger {
            background-color: #fed7d7;
            color: #c53030;
            border-left: 4px solid #e53e3e;
        }
        @media (max-width: 768px) {
            .login-wrapper {
                flex-direction: column;
            }
            .login-left {
                min-height: 200px;
                padding: 40px 20px;
            }
            .login-left h1 {
                font-size: 2rem;
            }
            .login-left p {
                font-size: 1rem;
            }
            .login-right {
                padding: 30px 20px;
            }
        }
    </style>
</head>
<body>
    <div class="login-wrapper">
        <div class="login-left">
            <div class="login-left-content">
                <h1>ITServiceFlow</h1>
                <p>Hệ thống quản lý dịch vụ IT chuyên nghiệp. Đăng nhập để truy cập vào hệ thống và quản lý các yêu cầu hỗ trợ của bạn.</p>
            </div>
        </div>
        <div class="login-right">
            <div class="login-form-container">
                <div class="login-logo">
                    <img src="assets/images/logo.svg" alt="ITServiceFlow Logo" onerror="this.style.display='none'">
                    <h2>Đăng nhập</h2>
                    <p>Nhập thông tin đăng nhập của bạn</p>
                </div>
                
                <form method="post" action="Login" id="loginForm">
                    <c:if test="${not empty error}">
                        <div class="alert alert-danger">
                            <i class="fas fa-exclamation-circle"></i> ${error}
                        </div>
                    </c:if>
                    
                    <div class="form-group">
                        <label class="form-label" for="username">
                            <i class="fas fa-user"></i> Tên đăng nhập
                        </label>
                        <input type="text" 
                               class="form-control" 
                               id="username" 
                               name="username" 
                               placeholder="Nhập tên đăng nhập" 
                               required 
                               autocomplete="username">
                    </div>

                    <div class="form-group">
                        <label class="form-label" for="password">
                            <i class="fas fa-lock"></i> Mật khẩu
                        </label>
                        <div class="password-wrapper">
                            <input type="password" 
                                   class="form-control" 
                                   id="password" 
                                   name="password" 
                                   placeholder="Nhập mật khẩu" 
                                   required 
                                   autocomplete="current-password">
                            <button type="button" class="password-toggle" id="passwordToggle">
                                <i class="fas fa-eye"></i>
                            </button>
                        </div>
                    </div>

                    <div class="form-options">
                        <div class="remember-me">
                            <input type="checkbox" id="remember" name="remember">
                            <label for="remember">Ghi nhớ đăng nhập</label>
                        </div>
                        <a href="ForgotPassword" class="forgot-password">Quên mật khẩu?</a>
                    </div>

                    <button type="submit" class="btn-login">
                        <i class="fas fa-sign-in-alt"></i> Đăng nhập
                    </button>

                    <!-- Google Sign-In Button -->
                    <div class="social-login" style="margin-top: 24px; text-align: center;">
                        <p style="color: #718096; font-size: 0.9rem; margin-bottom: 16px;">Hoặc đăng nhập bằng</p>
                        <% if (GoogleOAuthConfig.isConfigured()) { %>
                        <a href="<%= GoogleOAuthConfig.GOOGLE_AUTH_URL + "?" +
                            "client_id=" + java.net.URLEncoder.encode(GoogleOAuthConfig.GOOGLE_CLIENT_ID, "UTF-8") +
                            "&redirect_uri=" + java.net.URLEncoder.encode(GoogleOAuthConfig.GOOGLE_REDIRECT_URI, "UTF-8") +
                            "&response_type=code" +
                            "&scope=" + GoogleOAuthConfig.GOOGLE_SCOPE %>"
                           class="btn-google">
                            <i class="fab fa-google"></i> Google
                        </a>
                        <% } else { %>
                        <p class="text-muted small mb-0">Google chưa được cấu hình. Mở <code>Utils/GoogleOAuthConfig.java</code> và thêm Client ID từ <a href="https://console.cloud.google.com/apis/credentials" target="_blank">Google Cloud Console</a>.</p>
                        <% } %>
                    </div>
                </form>
            </div>
        </div>
    </div>

    <script src="assets/js/vendor-all.min.js"></script>
    <script>
        // Toggle password visibility
        const passwordToggle = document.getElementById('passwordToggle');
        const passwordInput = document.getElementById('password');
        
        if (passwordToggle && passwordInput) {
            passwordToggle.addEventListener('click', function() {
                const type = passwordInput.getAttribute('type') === 'password' ? 'text' : 'password';
                passwordInput.setAttribute('type', type);
                
                const icon = passwordToggle.querySelector('i');
                if (type === 'password') {
                    icon.classList.remove('fa-eye-slash');
                    icon.classList.add('fa-eye');
                } else {
                    icon.classList.remove('fa-eye');
                    icon.classList.add('fa-eye-slash');
                }
            });
        }
    </script>
</body>

    <script src="assets/js/vendor-all.min.js"></script>
    <script>
        // Toggle password visibility
        const passwordInput = document.getElementById('password');
        if (passwordInput) {
            const toggleBtn = document.createElement('button');
            toggleBtn.type = 'button';
            toggleBtn.className = 'password-toggle';
            toggleBtn.innerHTML = '<i class="fas fa-eye"></i>';
            toggleBtn.style.cssText = 'position: absolute; right: 15px; top: 50%; transform: translateY(-50%); background: none; border: none; cursor: pointer; color: #999;';
            toggleBtn.onclick = function() {
                if (passwordInput.type === 'password') {
                    passwordInput.type = 'text';
                    toggleBtn.innerHTML = '<i class="fas fa-eye-slash"></i>';
                } else {
                    passwordInput.type = 'password';
                    toggleBtn.innerHTML = '<i class="fas fa-eye"></i>';
                }
            };
            passwordInput.parentElement.style.position = 'relative';
            passwordInput.parentElement.appendChild(toggleBtn);
        }
    </script>
</body>
</html>
