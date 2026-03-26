/*
 * Gửi email qua SMTP (dùng cho Quên mật khẩu).
 */
package Utils;

import java.util.Properties;
import javax.mail.Authenticator;
import javax.mail.Message;
import javax.mail.PasswordAuthentication;
import javax.mail.Session;
import javax.mail.Transport;
import javax.mail.internet.InternetAddress;
import javax.mail.internet.MimeMessage;

public class MailUtil {

    /**
     * Gửi email đơn giản (plain text).
     * @return true nếu gửi thành công
     */
    public static boolean send(String toEmail, String subject, String body) {
        if (!MailConfig.isConfigured()) {
            System.err.println("MailUtil: SMTP chưa cấu hình, bỏ qua gửi email.");
            return false;
        }
        if (toEmail == null || toEmail.trim().isEmpty()) return false;

        try {
            Properties props = new Properties();
            props.put("mail.smtp.host", MailConfig.SMTP_HOST);
            props.put("mail.smtp.port", MailConfig.SMTP_PORT);
            props.put("mail.smtp.auth", "true");
            props.put("mail.smtp.starttls.enable", "true");

            Authenticator auth = null;
            if (MailConfig.SMTP_USER != null && !MailConfig.SMTP_USER.isEmpty()) {
                final String user = MailConfig.SMTP_USER;
                final String pass = MailConfig.SMTP_PASSWORD != null ? MailConfig.SMTP_PASSWORD : "";
                auth = new Authenticator() {
                    @Override
                    protected PasswordAuthentication getPasswordAuthentication() {
                        return new PasswordAuthentication(user, pass);
                    }
                };
            }

            Session session = Session.getInstance(props, auth);
            MimeMessage msg = new MimeMessage(session);
            msg.setFrom(new InternetAddress(MailConfig.MAIL_FROM, "ITServiceFlow"));
            msg.setRecipient(Message.RecipientType.TO, new InternetAddress(toEmail.trim()));
            msg.setSubject(subject, "UTF-8");
            msg.setText(body, "UTF-8");

            Transport.send(msg);
            return true;
        } catch (Exception e) {
            System.err.println("MailUtil send error: " + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }
}
