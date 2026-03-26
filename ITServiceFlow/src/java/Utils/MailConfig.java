/*
 * Cấu hình SMTP để gửi email (Quên mật khẩu).
 * Có thể set biến môi trường: SMTP_HOST, SMTP_PORT, SMTP_USER, SMTP_PASSWORD, MAIL_FROM
 * Hoặc sửa giá trị mặc định bên dưới (không commit mật khẩu lên git).
 *
 * Ví dụ Gmail: SMTP_HOST=smtp.gmail.com, SMTP_PORT=587,
 * SMTP_USER=your@gmail.com, SMTP_PASSWORD=App Password (tạo tại Google Account > Security).
 */
package Utils;

public class MailConfig {

    private static String getEnvOr(String key, String fallback) {
        String v = System.getenv(key);
        return (v != null && !v.isEmpty()) ? v : fallback;
    }

    public static final String SMTP_HOST = getEnvOr("SMTP_HOST", "");
    public static final String SMTP_PORT = getEnvOr("SMTP_PORT", "587");
    public static final String SMTP_USER = getEnvOr("SMTP_USER", "");
    public static final String SMTP_PASSWORD = getEnvOr("SMTP_PASSWORD", "");
    /** Email người gửi (From) */
    public static final String MAIL_FROM = getEnvOr("MAIL_FROM", "noreply@itserviceflow.com");

    /** True nếu đã cấu hình đủ để gửi mail (có host và thường có user/pass cho TLS) */
    public static boolean isConfigured() {
        return SMTP_HOST != null && !SMTP_HOST.trim().isEmpty();
    }
}
