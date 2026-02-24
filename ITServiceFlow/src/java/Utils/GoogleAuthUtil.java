package Utils;

import java.io.BufferedReader;
import java.io.InputStreamReader;
import java.net.HttpURLConnection;
import java.net.URL;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

public class GoogleAuthUtil {

    private static final Pattern STRING_FIELD = Pattern.compile("\"%s\"\\s*:\\s*\"([^\"]*)\"");
    private static final Pattern BOOLEAN_FIELD = Pattern.compile("\"%s\"\\s*:\\s*\"?(true|false)\"?", Pattern.CASE_INSENSITIVE);

    private GoogleAuthUtil() {
    }

    public static GoogleUserInfo verifyIdToken(String idToken, String expectedClientId) {
        if (idToken == null || idToken.isBlank()) {
            return null;
        }

        try {
            String encodedToken = URLEncoder.encode(idToken, StandardCharsets.UTF_8);
            URL url = new URL("https://oauth2.googleapis.com/tokeninfo?id_token=" + encodedToken);
            HttpURLConnection connection = (HttpURLConnection) url.openConnection();
            connection.setRequestMethod("GET");
            connection.setConnectTimeout(8000);
            connection.setReadTimeout(8000);

            int code = connection.getResponseCode();
            if (code != HttpURLConnection.HTTP_OK) {
                return null;
            }

            StringBuilder response = new StringBuilder();
            try (BufferedReader reader = new BufferedReader(
                    new InputStreamReader(connection.getInputStream(), StandardCharsets.UTF_8))) {
                String line;
                while ((line = reader.readLine()) != null) {
                    response.append(line);
                }
            }

            String json = response.toString();
            String aud = extractString(json, "aud");
            String email = extractString(json, "email");
            boolean emailVerified = extractBoolean(json, "email_verified");

            if (expectedClientId != null && !expectedClientId.isBlank() && !expectedClientId.equals(aud)) {
                return null;
            }
            if (email == null || email.isBlank() || !emailVerified) {
                return null;
            }
            return new GoogleUserInfo(email.trim(), aud, emailVerified);
        } catch (Exception ex) {
            ex.printStackTrace();
            return null;
        }
    }

    private static String extractString(String json, String key) {
        Pattern p = Pattern.compile(String.format(STRING_FIELD.pattern(), Pattern.quote(key)));
        Matcher m = p.matcher(json);
        return m.find() ? m.group(1) : null;
    }

    private static boolean extractBoolean(String json, String key) {
        Pattern p = Pattern.compile(String.format(BOOLEAN_FIELD.pattern(), Pattern.quote(key)));
        Matcher m = p.matcher(json);
        return m.find() && "true".equalsIgnoreCase(m.group(1));
    }

    public static String getGoogleClientId() {
        String fromEnv = System.getenv("GOOGLE_CLIENT_ID");
        if (fromEnv != null && !fromEnv.isBlank()) {
            return fromEnv.trim();
        }
        String fromProp = System.getProperty("GOOGLE_CLIENT_ID");
        if (fromProp != null && !fromProp.isBlank()) {
            return fromProp.trim();
        }
        return readFromMailProperties("GOOGLE_CLIENT_ID");
    }

    private static String readFromMailProperties(String key) {
        try (var in = GoogleAuthUtil.class.getClassLoader().getResourceAsStream("mail.properties")) {
            if (in == null) {
                return null;
            }
            java.util.Properties p = new java.util.Properties();
            p.load(in);
            String value = p.getProperty(key);
            return value == null ? null : value.trim();
        } catch (Exception ex) {
            return null;
        }
    }

    public static class GoogleUserInfo {

        private final String email;
        private final String audience;
        private final boolean emailVerified;

        public GoogleUserInfo(String email, String audience, boolean emailVerified) {
            this.email = email;
            this.audience = audience;
            this.emailVerified = emailVerified;
        }

        public String getEmail() {
            return email;
        }

        public String getAudience() {
            return audience;
        }

        public boolean isEmailVerified() {
            return emailVerified;
        }
    }
}
