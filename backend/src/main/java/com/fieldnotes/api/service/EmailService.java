package com.fieldnotes.api.service;

import jakarta.mail.internet.MimeMessage;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.ObjectProvider;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.mail.javamail.JavaMailSender;
import org.springframework.mail.javamail.MimeMessageHelper;
import org.springframework.stereotype.Service;

@Service
public class EmailService {

    private static final Logger log = LoggerFactory.getLogger(EmailService.class);

    private final JavaMailSender mailSender;

    @Value("${spring.mail.username:}")
    private String mailUsername;

    @Value("${spring.mail.password:}")
    private String mailPassword;

    public EmailService(ObjectProvider<JavaMailSender> mailSenderProvider) {
        this.mailSender = mailSenderProvider.getIfAvailable();
    }

    public boolean sendPasswordResetOtp(String toEmail, String otp) {
        if (mailSender == null) {
            log.info("JavaMailSender bean is not available. Skipping external email send for {}. OTP: {}", toEmail, otp);
            return false;
        }

        if (mailUsername == null || mailUsername.trim().isEmpty() || mailPassword == null || mailPassword.trim().isEmpty()) {
            log.info("No SMTP credentials configured. Skipping external email send for {}. OTP: {}", toEmail, otp);
            return false;
        }

        try {
            MimeMessage message = mailSender.createMimeMessage();
            MimeMessageHelper helper = new MimeMessageHelper(message, true, "UTF-8");
            helper.setFrom(mailUsername, "Field Notes Security");
            helper.setTo(toEmail);
            helper.setSubject("Field Notes - Password Reset Verification Code");

            String html = """
                <div style="font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; max-width: 520px; margin: 0 auto; padding: 24px; border: 1px solid #e2e8f0; border-radius: 12px; background-color: #ffffff;">
                    <div style="text-align: center; margin-bottom: 24px;">
                        <h2 style="color: #0f172a; margin: 0; font-size: 22px;">Field Notes Verification</h2>
                        <p style="color: #64748b; font-size: 14px; margin-top: 6px;">Secure Password Reset</p>
                    </div>
                    <p style="color: #334155; font-size: 15px; line-height: 1.5;">Hello,</p>
                    <p style="color: #334155; font-size: 15px; line-height: 1.5;">You requested a password reset for your Field Notes account. Please use the following 6-digit verification code:</p>
                    <div style="text-align: center; margin: 28px 0;">
                        <div style="display: inline-block; background-color: #f1f5f9; border: 2px dashed #3b82f6; border-radius: 8px; padding: 14px 28px; font-size: 28px; font-weight: 700; letter-spacing: 6px; color: #1e3a8a;">
                            %s
                        </div>
                    </div>
                    <p style="color: #64748b; font-size: 13px; line-height: 1.5;">This code will expire in <strong>15 minutes</strong>. If you did not request this, please ignore this email.</p>
                    <hr style="border: none; border-top: 1px solid #e2e8f0; margin: 24px 0;" />
                    <p style="color: #94a3b8; font-size: 12px; text-align: center; margin: 0;">&copy; Field Notes • Offline-First Field Inspection Management</p>
                </div>
            """.formatted(otp);

            helper.setText(html, true);
            mailSender.send(message);
            log.info("Password reset OTP email sent successfully to {}", toEmail);
            return true;
        } catch (Exception e) {
            log.warn("Failed to send password reset email to {}: {}", toEmail, e.getMessage());
            return false;
        }
    }
}
