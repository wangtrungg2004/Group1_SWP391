<%--
    Quên mật khẩu - Nhập email để nhận link đặt lại mật khẩu
--%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Quên mật khẩu - ITServiceFlow</title>
    <link rel="stylesheet" href="assets/fonts/fontawesome/css/fontawesome-all.min.css">
    <link rel="stylesheet" href="assets/plugins/bootstrap/css/bootstrap.min.css">
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body { font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; background: #f5f7fa; min-height: 100vh; }
        .login-wrapper { min-height: 100vh; display: flex; }
        .login-left { flex: 1; background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); display: flex; flex-direction: column; justify-content: center; align-items: center; padding: 60px; color: white; }
        .login-left h1 { font-size: 2.5rem; font-weight: 700; margin-bottom: 16px; }
        .login-left p { font-size: 1.1rem; opacity: 0.95; }
        .login-right { flex: 1; display: flex; align-items: center; justify-content: center; padding: 40px; background: #ffffff; }
        .login-form-container { width: 100%; max-width: 420px; }
        .login-logo { text-align: center; margin-bottom: 32px; }
        .login-logo h2 { color: #2d3748; font-size: 1.6rem; font-weight: 600; margin-bottom: 8px; }
        .login-logo p { color: #718096; font-size: 0.95rem; }
        .form-group { margin-bottom: 24px; }
        .form-label { display: block; color: #2d3748; font-weight: 500; margin-bottom: 8px; font-size: 0.9rem; }
        .form-control { width: 100%; padding: 12px 16px; border: 1px solid #e2e8f0; border-radius: 6px; font-size: 0.95rem; }
        .form-control:focus { outline: none; border-color: #667eea; box-shadow: 0 0 0 3px rgba(102, 126, 234, 0.1); }
        .btn-submit { width: 100%; padding: 14px; background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); color: white; border: none; border-radius: 6px; font-size: 1rem; font-weight: 600; cursor: pointer; }
        .btn-submit:hover { opacity: 0.95; }
        .alert { padding: 12px 16px; border-radius: 6px; margin-bottom: 24px; font-size: 0.9rem; }
        .alert-danger { background-color: #fed7d7; color: #c53030; border-left: 4px solid #e53e3e; }
        .alert-success { background-color: #c6f6d5; color: #276749; border-left: 4px solid #38a169; }
        .reset-link-box { background: #f7fafc; border: 1px solid #e2e8f0; border-radius: 6px; padding: 12px; margin-top: 16px; word-break: break-all; font-size: 0.85rem; }
        .reset-link-box a { color: #667eea; font-weight: 500; }
        .back-login { display: inline-block; margin-top: 20px; color: #667eea; text-decoration: none; font-weight: 500; }
        .back-login:hover { color: #764ba2; text-decoration: none; }
        @media (max-width: 768px) { .login-wrapper { flex-direction: column; } .login-left { min-height: 180px; padding: 32px 20px; } }
    </style>
</head>
<body>
    <div class="login-wrapper">
        <div class="login-left">
            <h1>ITServiceFlow</h1>
            <p>Nhập email đăng ký tài khoản để nhận link đặt lại mật khẩu. Link có hiệu lực 1 giờ.</p>
        </div>
        <div class="login-right">
            <div class="login-form-container">
                <div class="login-logo">
                    <h2><i class="fas fa-key"></i> Quên mật khẩu</h2>
                    <p>Nhập email của bạn</p>
                </div>

                <c:if test="${not empty success && success}">
                    <div class="alert alert-success">
                        <i class="fas fa-check-circle"></i> ${message}
                    </div>
                    <c:if test="${empty emailSent || !emailSent}">
                        <div class="reset-link-box">
                            <strong>Link đặt lại mật khẩu (dự phòng):</strong><br>
                            <a href="${resetLink}" id="resetLink">${resetLink}</a>
                        </div>
                        <p class="small text-muted mt-2">Sao chép link trên vào trình duyệt hoặc nhấn vào link để đặt mật khẩu mới.</p>
                    </c:if>
                    <a href="Login" class="back-login"><i class="fas fa-arrow-left"></i> Quay lại đăng nhập</a>
                </c:if>

                <c:if test="${empty success || !success}">
                    <form method="post" action="ForgotPassword">
                        <c:if test="${not empty error}">
                            <div class="alert alert-danger">
                                <i class="fas fa-exclamation-circle"></i> ${error}
                            </div>
                        </c:if>
                        <div class="form-group">
                            <label class="form-label" for="email"><i class="fas fa-envelope"></i> Email</label>
                            <input type="email" class="form-control" id="email" name="email" placeholder="Nhập email đăng ký" required value="${param.email}">
                        </div>
                        <button type="submit" class="btn-submit"><i class="fas fa-paper-plane"></i> Gửi link đặt lại mật khẩu</button>
                    </form>
                    <a href="Login" class="back-login"><i class="fas fa-arrow-left"></i> Quay lại đăng nhập</a>
                </c:if>
            </div>
        </div>
    </div>
</body>
</html>
