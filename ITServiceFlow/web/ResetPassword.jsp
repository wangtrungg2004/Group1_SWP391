<%--
    Đặt lại mật khẩu - Nhập mật khẩu mới (truy cập qua link có token)
--%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Đặt lại mật khẩu - ITServiceFlow</title>
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
        .password-wrapper { position: relative; }
        .password-toggle { position: absolute; right: 12px; top: 50%; transform: translateY(-50%); background: none; border: none; color: #718096; cursor: pointer; padding: 8px; }
        .btn-submit { width: 100%; padding: 14px; background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); color: white; border: none; border-radius: 6px; font-size: 1rem; font-weight: 600; cursor: pointer; }
        .btn-submit:hover { opacity: 0.95; }
        .alert { padding: 12px 16px; border-radius: 6px; margin-bottom: 24px; font-size: 0.9rem; }
        .alert-danger { background-color: #fed7d7; color: #c53030; border-left: 4px solid #e53e3e; }
        .alert-success { background-color: #c6f6d5; color: #276749; border-left: 4px solid #38a169; }
        .back-login { display: inline-block; margin-top: 20px; color: #667eea; text-decoration: none; font-weight: 500; }
        .back-login:hover { color: #764ba2; text-decoration: none; }
        @media (max-width: 768px) { .login-wrapper { flex-direction: column; } .login-left { min-height: 180px; padding: 32px 20px; } }
    </style>
</head>
<body>
    <div class="login-wrapper">
        <div class="login-left">
            <h1>ITServiceFlow</h1>
            <p>Đặt lại mật khẩu mới cho tài khoản của bạn. Mật khẩu cần ít nhất 6 ký tự.</p>
        </div>
        <div class="login-right">
            <div class="login-form-container">
                <div class="login-logo">
                    <h2><i class="fas fa-lock"></i> Đặt lại mật khẩu</h2>
                    <p>Nhập mật khẩu mới</p>
                </div>

                <c:if test="${not empty success && success}">
                    <div class="alert alert-success">
                        <i class="fas fa-check-circle"></i> Đặt mật khẩu thành công. Bạn có thể đăng nhập bằng mật khẩu mới.
                    </div>
                    <a href="Login" class="btn-submit" style="text-align: center; text-decoration: none; display: block;"><i class="fas fa-sign-in-alt"></i> Đăng nhập</a>
                </c:if>

                <c:if test="${empty success || !success}">
                    <form method="post" action="ResetPassword" id="resetForm">
                        <input type="hidden" name="token" value="${token}">
                        <c:if test="${not empty error}">
                            <div class="alert alert-danger">
                                <i class="fas fa-exclamation-circle"></i> ${error}
                            </div>
                        </c:if>
                        <div class="form-group">
                            <label class="form-label" for="password"><i class="fas fa-lock"></i> Mật khẩu mới</label>
                            <div class="password-wrapper">
                                <input type="password" class="form-control" id="password" name="password" placeholder="Ít nhất 6 ký tự" required minlength="6" autocomplete="new-password">
                                <button type="button" class="password-toggle" id="togglePass"><i class="fas fa-eye"></i></button>
                            </div>
                        </div>
                        <div class="form-group">
                            <label class="form-label" for="confirmPassword"><i class="fas fa-lock"></i> Xác nhận mật khẩu</label>
                            <div class="password-wrapper">
                                <input type="password" class="form-control" id="confirmPassword" name="confirmPassword" placeholder="Nhập lại mật khẩu" required minlength="6" autocomplete="new-password">
                                <button type="button" class="password-toggle" id="toggleConfirm"><i class="fas fa-eye"></i></button>
                            </div>
                        </div>
                        <button type="submit" class="btn-submit"><i class="fas fa-check"></i> Đặt mật khẩu</button>
                    </form>
                    <a href="Login" class="back-login"><i class="fas fa-arrow-left"></i> Quay lại đăng nhập</a>
                </c:if>
            </div>
        </div>
    </div>
    <script>
        (function() {
            var p = document.getElementById('password'), c = document.getElementById('confirmPassword');
            var t1 = document.getElementById('togglePass'), t2 = document.getElementById('toggleConfirm');
            if (t1 && p) t1.onclick = function() { p.type = p.type === 'password' ? 'text' : 'password'; t1.querySelector('i').className = p.type === 'password' ? 'fas fa-eye' : 'fas fa-eye-slash'; };
            if (t2 && c) t2.onclick = function() { c.type = c.type === 'password' ? 'text' : 'password'; t2.querySelector('i').className = c.type === 'password' ? 'fas fa-eye' : 'fas fa-eye-slash'; };
        })();
    </script>
</body>
</html>
