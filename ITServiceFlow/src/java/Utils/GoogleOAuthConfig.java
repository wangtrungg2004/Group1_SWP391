/*
 * Google OAuth 2.0 Configuration
 *
 * CẤU HÌNH ĐĂNG NHẬP GOOGLE (tránh lỗi 401 invalid_client):
 * 1. Vào https://console.cloud.google.com/ → chọn hoặc tạo project
 * 2. APIs & Services → Credentials → Create Credentials → OAuth client ID
 * 3. Nếu chưa có: cấu hình OAuth consent screen (User type: External, thêm app name, email)
 * 4. Application type: Web application
 * 5. Authorized redirect URIs: thêm đúng 1 dòng:
 *    http://localhost:8080/ITServiceFlow/GoogleAuthCallback
 * 6. Copy Client ID và Client Secret → dán vào dưới đây (thay YOUR_...)
 */
package Utils;

/**
 * Configuration for Google OAuth 2.0 Login
 * Values can be set via environment variables or replace placeholders below.
 * Env: GOOGLE_CLIENT_ID, GOOGLE_CLIENT_SECRET, GOOGLE_REDIRECT_URI
 */
public class GoogleOAuthConfig {

    private static String getEnvOr(String key, String fallback) {
        String v = System.getenv(key);
        return (v != null && !v.isEmpty()) ? v : fallback;
    }

    /**
     * Một số máy hay set nhầm GOOGLE_CLIENT_SECRET = Client ID (đuôi .apps.googleusercontent.com).
     * Khi phát hiện kiểu giá trị sai này, fallback về secret trong file để tránh 401 invalid_client.
     */
    private static String getEnvOrSecret(String key, String fallback) {
        String v = System.getenv(key);
        if (v == null || v.isEmpty()) return fallback;
        if (v.contains(".apps.googleusercontent.com")) return fallback;
        return v;
    }

    /** Client ID từ Google Cloud Console (dạng 123456-xxx.apps.googleusercontent.com) */
    public static final String GOOGLE_CLIENT_ID = getEnvOr("GOOGLE_CLIENT_ID");
    /** Client Secret từ Google Cloud Console (dạng GOCSPX-xxxx) */
    public static final String GOOGLE_CLIENT_SECRET = getEnvOrSecret("GOOGLE_CLIENT_SECRET");

    /** Redirect URI phải trùng chính xác với URI đã thêm trong Google Cloud Console */
    public static final String GOOGLE_REDIRECT_URI = getEnvOr("GOOGLE_REDIRECT_URI", "http://localhost:8080/ITServiceFlow/GoogleAuthCallback");

    /** True nếu đã thay YOUR_... bằng Client ID thật */
    public static boolean isConfigured() {
        return GOOGLE_CLIENT_ID != null && !GOOGLE_CLIENT_ID.startsWith("YOUR_")
                && GOOGLE_CLIENT_SECRET != null && !GOOGLE_CLIENT_SECRET.startsWith("YOUR_");
    }
    
    // Google OAuth endpoints
    public static final String GOOGLE_AUTH_URL = "https://accounts.google.com/o/oauth2/v2/auth";
    public static final String GOOGLE_TOKEN_URL = "https://oauth2.googleapis.com/token";
    public static final String GOOGLE_USERINFO_URL = "https://www.googleapis.com/oauth2/v1/userinfo";
    
    // OAuth scope
    public static final String GOOGLE_SCOPE = "openid%20email%20profile";
}
