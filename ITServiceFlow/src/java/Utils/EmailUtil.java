package Utils;

import jakarta.mail.Authenticator;
import jakarta.mail.Message;
import jakarta.mail.PasswordAuthentication;
import jakarta.mail.Session;
import jakarta.mail.Transport;
import jakarta.mail.internet.InternetAddress;
import jakarta.mail.internet.MimeMessage;
import java.util.Properties;
import java.io.InputStream;

public class EmailUtil {

    private EmailUtil() {
    }

    public static boolean sendForgotPasswordEmail(String toEmail, String username, String resetLink) {
        String smtpUser = firstNonBlank(
                System.getenv("MAIL_USERNAME"),
                System.getProperty("MAIL_USERNAME"),
                readFromProperties("MAIL_USERNAME")
        );
        String smtpPass = firstNonBlank(
                System.getenv("MAIL_APP_PASSWORD"),
                System.getProperty("MAIL_APP_PASSWORD"),
                readFromProperties("MAIL_APP_PASSWORD")
        );
        if (smtpUser == null || smtpPass == null || smtpUser.isBlank() || smtpPass.isBlank()) {
            System.err.println("MAIL_USERNAME or MAIL_APP_PASSWORD is missing.");
            return false;
        }

        Properties props = new Properties();
        props.put("mail.smtp.host", "smtp.gmail.com");
        props.put("mail.smtp.port", "587");
        props.put("mail.smtp.auth", "true");
        props.put("mail.smtp.starttls.enable", "true");

        Session session = Session.getInstance(props, new Authenticator() {
            @Override
            protected PasswordAuthentication getPasswordAuthentication() {
                return new PasswordAuthentication(smtpUser, smtpPass);
            }
        });

        String from = firstNonBlank(
                System.getenv("MAIL_FROM"),
                System.getProperty("MAIL_FROM"),
                readFromProperties("MAIL_FROM")
        );
        if (from == null || from.isBlank()) {
            from = smtpUser;
        }

        String subject = "IT ServiceFlow - Password Reset";
        String body = """
                Hello,

                We received a request to reset your password.
                Account username: %s

                Click the link below to reset your password:
                %s

                This link will expire in 15 minutes.

                If you did not request this, please ignore this email.
                """.formatted(username, resetLink);

        try {
            MimeMessage message = new MimeMessage(session);
            message.setFrom(new InternetAddress(from));
            message.setRecipients(Message.RecipientType.TO, InternetAddress.parse(toEmail));
            message.setSubject(subject, "UTF-8");
            message.setText(body, "UTF-8");
            Transport.send(message);
            return true;
        } catch (Exception ex) {
            ex.printStackTrace();
            return false;
        }
    }

    private static String firstNonBlank(String... values) {
        if (values == null) {
            return null;
        }
        for (String value : values) {
            if (value != null && !value.isBlank()) {
                return value.trim();
            }
        }
        return null;
    }

    private static String readFromProperties(String key) {
        try (InputStream in = EmailUtil.class.getClassLoader().getResourceAsStream("mail.properties")) {
            if (in == null) {
                return null;
            }
            Properties p = new Properties();
            p.load(in);
            return p.getProperty(key);
        } catch (Exception ex) {
            return null;
        }
    }
}
