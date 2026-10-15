package com.fieldnotes.api.service;

import jakarta.mail.internet.MimeMessage;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.ObjectProvider;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.mail.javamail.JavaMailSender;
import org.springframework.mail.javamail.MimeMessageHelper;
import org.springframework.stereotype.Service;

import java.net.URI;
import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;
import java.nio.charset.StandardCharsets;
import java.time.Duration;

@Service
public class EmailService {

    private static final Logger log = LoggerFactory.getLogger(EmailService.class);

    private final JavaMailSender mailSender;
    private final HttpClient httpClient = HttpClient.newBuilder()
            .connectTimeout(Duration.ofSeconds(5))
            .build();

    @Value("${spring.mail.username:}")
    private String mailUsername;

    @Value("${spring.mail.password:}")
    private String mailPassword;

    @Value("${RESEND_API_KEY:}")
    private String resendApiKey;

    @Value("${BREVO_API_KEY:}")
    private String brevoApiKey;

    public EmailService(ObjectProvider<JavaMailSender> mailSenderProvider) {
        this.mailSender = mailSenderProvider.getIfAvailable();
    }

    public boolean sendPasswordResetOtp(String toEmail, String otp) {
        String html = buildEmailHtml(otp);

        // 1. If Brevo HTTP API Key is set, send via HTTPS Port 443 (bypasses Render SMTP firewall block)
        if (brevoApiKey != null && !brevoApiKey.trim().isEmpty()) {
            if (sendViaBrevo(toEmail, html)) {
                return true;
            }
        }

        // 2. If Resend HTTP API Key is set, send via HTTPS Port 443 (bypasses Render SMTP firewall block)
        if (resendApiKey != null && !resendApiKey.trim().isEmpty()) {
            if (sendViaResend(toEmail, html)) {
                return true;
            }
        }

        // 3. Try standard SMTP if credentials are provided (may be blocked by Render Free Tier firewall)
        if (mailSender != null && mailUsername != null && !mailUsername.trim().isEmpty()
                && mailPassword != null && !mailPassword.trim().isEmpty()) {
            if (sendViaSmtp(toEmail, html)) {
                return true;
            }
        }

        log.info("No active external email provider succeeded. Falling back to in-app verification code for {}", toEmail);
        return false;
    }

    private boolean sendViaBrevo(String toEmail, String html) {
        try {
            String sender = (mailUsername != null && !mailUsername.isBlank()) ? mailUsername.trim() : "nahid018536@gmail.com";
            String payload = "{\"sender\":{\"name\":\"Field Notes Security\",\"email\":\"" + escapeJson(sender)
                    + "\"},\"to\":[{\"email\":\"" + escapeJson(toEmail)
                    + "\"}],\"subject\":\"Field Notes - Password Reset Verification Code\",\"htmlContent\":\""
                    + escapeJson(html) + "\"}";

            HttpRequest request = HttpRequest.newBuilder()
                    .uri(URI.create("https://api.brevo.com/v3/smtp/email"))
                    .header("api-key", brevoApiKey.trim())
                    .header("Content-Type", "application/json")
                    .POST(HttpRequest.BodyPublishers.ofString(payload, StandardCharsets.UTF_8))
                    .timeout(Duration.ofSeconds(8))
                    .build();

            HttpResponse<String> response = httpClient.send(request, HttpResponse.BodyHandlers.ofString());
            if (response.statusCode() >= 200 && response.statusCode() < 300) {
                log.info("Password reset OTP email sent successfully to {} via Brevo HTTPS API", toEmail);
                return true;
            }
            log.warn("Brevo API returned status {}: {}", response.statusCode(), response.body());
        } catch (Exception e) {
            log.warn("Failed to send email via Brevo API: {}", e.getMessage());
        }
        return false;
    }

    private boolean sendViaResend(String toEmail, String html) {
        try {
            String payload = "{\"from\":\"Field Notes Security <onboarding@resend.dev>\",\"to\":[\""
                    + escapeJson(toEmail)
                    + "\"],\"subject\":\"Field Notes - Password Reset Verification Code\",\"html\":\""
                    + escapeJson(html) + "\"}";

            HttpRequest request = HttpRequest.newBuilder()
                    .uri(URI.create("https://api.resend.com/emails"))
                    .header("Authorization", "Bearer " + resendApiKey.trim())
                    .header("Content-Type", "application/json")
                    .POST(HttpRequest.BodyPublishers.ofString(payload, StandardCharsets.UTF_8))
                    .timeout(Duration.ofSeconds(8))
                    .build();

            HttpResponse<String> response = httpClient.send(request, HttpResponse.BodyHandlers.ofString());
            if (response.statusCode() >= 200 && response.statusCode() < 300) {
                log.info("Password reset OTP email sent successfully to {} via Resend HTTPS API", toEmail);
                return true;
            }
            log.warn("Resend API returned status {}: {}", response.statusCode(), response.body());
        } catch (Exception e) {
            log.warn("Failed to send email via Resend API: {}", e.getMessage());
        }
        return false;
    }

    private boolean sendViaSmtp(String toEmail, String html) {
        try {
            MimeMessage message = mailSender.createMimeMessage();
            MimeMessageHelper helper = new MimeMessageHelper(message, true, "UTF-8");
            helper.setFrom(mailUsername.trim(), "Field Notes Security");
            helper.setTo(toEmail);
            helper.setSubject("Field Notes - Password Reset Verification Code");
            helper.setText(html, true);
            mailSender.send(message);
            log.info("Password reset OTP email sent successfully to {} via SMTP", toEmail);
            return true;
        } catch (Exception e) {
            log.warn("SMTP email send failed (Render Free Tier blocks outbound SMTP ports 25, 465, 587): {}", e.getMessage());
            return false;
        }
    }

    private String escapeJson(String raw) {
        if (raw == null) return "";
        StringBuilder sb = new StringBuilder();
        for (int i = 0; i < raw.length(); i++) {
            char c = raw.charAt(i);
            switch (c) {
                case '"' -> sb.append("\\\"");
                case '\\' -> sb.append("\\\\");
                case '\b' -> sb.append("\\b");
                case '\f' -> sb.append("\\f");
                case '\n' -> sb.append("\\n");
                case '\r' -> sb.append("\\r");
                case '\t' -> sb.append("\\t");
                default -> {
                    if (c < ' ') {
                        sb.append(String.format("\\u%04x", (int) c));
                    } else {
                        sb.append(c);
                    }
                }
            }
        }
        return sb.toString();
    }

    private String buildEmailHtml(String otp) {
        return """
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
    }
}
