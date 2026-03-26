/*
 * Forgot Password: nhập email -> gửi/tạo link đặt lại mật khẩu
 */
package controller;

import java.io.IOException;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import service.UserService;
import Utils.MailConfig;
import Utils.MailUtil;

@WebServlet(name = "ForgotPassword", urlPatterns = {"/ForgotPassword"})
public class ForgotPassword extends HttpServlet {

    private final UserService userService = new UserService();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.getRequestDispatcher("ForgotPassword.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        response.setContentType("text/html; charset=UTF-8");

        String email = request.getParameter("email");
        if (email == null || email.trim().isEmpty()) {
            request.setAttribute("error", "Vui lòng nhập email.");
            request.getRequestDispatcher("ForgotPassword.jsp").forward(request, response);
            return;
        }

        String token = userService.requestPasswordReset(email.trim());
        if (token == null) {
            if (userService.activeEmailExists(email.trim())) {
                request.setAttribute("error", "Email tồn tại nhưng hệ thống chưa tạo được link reset. Vui lòng kiểm tra cột ResetToken/ResetTokenExpiry trong bảng Users và kết nối đúng database.");
            } else {
                request.setAttribute("error", "Không tìm thấy tài khoản với email này hoặc email chưa được đăng ký.");
            }
            request.getRequestDispatcher("ForgotPassword.jsp").forward(request, response);
            return;
        }

        String baseUrl = request.getScheme() + "://" + request.getServerName()
                + (request.getServerPort() == 80 || request.getServerPort() == 443 ? "" : ":" + request.getServerPort())
                + request.getContextPath();
        String resetLink = baseUrl + "/ResetPassword?token=" + token;

        boolean emailSent = false;
        if (MailConfig.isConfigured()) {
            String subject = "ITServiceFlow - Đặt lại mật khẩu";
            String body = "Xin chào,\n\nBạn đã yêu cầu đặt lại mật khẩu. Nhấn vào link sau (hiệu lực 1 giờ):\n\n" + resetLink + "\n\nNếu bạn không yêu cầu, hãy bỏ qua email này.\n\n— ITServiceFlow";
            emailSent = MailUtil.send(email.trim(), subject, body);
        }

        request.setAttribute("success", true);
        request.setAttribute("resetLink", resetLink);
        request.setAttribute("emailSent", emailSent);
        request.setAttribute("message", emailSent
                ? "Đã gửi link đặt lại mật khẩu đến email của bạn. Vui lòng kiểm tra hộp thư (và thư mục spam). Link có hiệu lực 1 giờ."
                : "Link đặt lại mật khẩu đã được tạo. Link có hiệu lực 1 giờ. " + (MailConfig.isConfigured() ? "Gửi email thất bại." : "Chưa cấu hình SMTP nên link hiển thị bên dưới."));
        request.getRequestDispatcher("ForgotPassword.jsp").forward(request, response);
    }
}
