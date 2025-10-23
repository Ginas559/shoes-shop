// tung - filepath: src/main/java/vn/iotstar/services/MailService.java
package vn.iotstar.services;

import jakarta.mail.*;
import jakarta.mail.internet.InternetAddress;
import jakarta.mail.internet.MimeMessage;

import java.util.Properties;

/**
 * Cấu hình lấy từ context-param (web.xml) hoặc System properties:
 * - mail.smtp.host
 * - mail.smtp.port
 * - mail.smtp.user
 * - mail.smtp.pass
 * - mail.smtp.auth=true
 * - mail.smtp.starttls.enable=true
 */
public class MailService {

    private Session buildSession() {
        Properties props = new Properties();
        props.put("mail.smtp.host", System.getProperty("mail.smtp.host", "smtp.example.com"));
        props.put("mail.smtp.port", System.getProperty("mail.smtp.port", "587"));
        props.put("mail.smtp.auth", System.getProperty("mail.smtp.auth", "true"));
        props.put("mail.smtp.starttls.enable", System.getProperty("mail.smtp.starttls.enable", "true"));

        final String user = System.getProperty("mail.smtp.user", "no-reply@example.com");
        final String pass = System.getProperty("mail.smtp.pass", "changeme");

        return Session.getInstance(props, new Authenticator() {
            @Override protected PasswordAuthentication getPasswordAuthentication() {
                return new PasswordAuthentication(user, pass);
            }
        });
    }

    public void sendOtpEmail(String to, String code, String subjectPrefix) {
        try {
            Session session = buildSession();
            Message message = new MimeMessage(session);
            message.setFrom(new InternetAddress(System.getProperty("mail.smtp.user", "no-reply@example.com")));
            message.setRecipients(Message.RecipientType.TO, InternetAddress.parse(to));
            message.setSubject("[" + subjectPrefix + "] Mã OTP của bạn");
            String body = """
                    Xin chào,
                    
                    Mã OTP của bạn là: %s
                    OTP có hiệu lực trong 10 phút. Vui lòng không chia sẻ cho bất kỳ ai.

                    Trân trọng.
                    """.formatted(code);
            message.setText(body);
            Transport.send(message);
        } catch (Exception e) {
            throw new RuntimeException("Gửi email OTP thất bại: " + e.getMessage(), e);
        }
    }
}
