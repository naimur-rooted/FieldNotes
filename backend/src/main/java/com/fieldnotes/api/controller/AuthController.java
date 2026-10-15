package com.fieldnotes.api.controller;

import com.fieldnotes.api.dto.*;
import com.fieldnotes.api.entity.PasswordResetOtp;
import com.fieldnotes.api.entity.User;
import com.fieldnotes.api.repository.PasswordResetOtpRepository;
import com.fieldnotes.api.repository.UserRepository;
import com.fieldnotes.api.security.JwtUtil;
import com.fieldnotes.api.service.EmailService;
import jakarta.validation.Valid;
import org.springframework.http.HttpStatus;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.server.ResponseStatusException;

import java.security.SecureRandom;
import java.time.Instant;
import java.time.temporal.ChronoUnit;
import java.util.Map;

@RestController
@RequestMapping("/api/auth")
public class AuthController {

    private final UserRepository users;
    private final PasswordResetOtpRepository otpRepository;
    private final PasswordEncoder encoder;
    private final JwtUtil jwt;
    private final EmailService emailService;
    private final SecureRandom secureRandom = new SecureRandom();

    public AuthController(UserRepository users,
                          PasswordResetOtpRepository otpRepository,
                          PasswordEncoder encoder,
                          JwtUtil jwt,
                          EmailService emailService) {
        this.users = users;
        this.otpRepository = otpRepository;
        this.encoder = encoder;
        this.jwt = jwt;
        this.emailService = emailService;
    }

    @PostMapping("/register")
    public AuthResponse register(@Valid @RequestBody RegisterRequest req) {
        String cleanEmail = req.email().trim().toLowerCase();
        if (users.existsByEmailIgnoreCase(cleanEmail)) {
            throw new ResponseStatusException(HttpStatus.CONFLICT, "Email already registered");
        }
        User u = new User();
        u.setName(req.name().trim());
        u.setEmail(cleanEmail);
        u.setPassword(encoder.encode(req.password()));
        u = users.save(u);
        return new AuthResponse(jwt.generateToken(u.getId(), u.getEmail()), u.getId(), u.getName(), u.getEmail());
    }

    @PostMapping("/login")
    public AuthResponse login(@Valid @RequestBody LoginRequest req) {
        String cleanEmail = req.email().trim();
        User u = users.findByEmailIgnoreCase(cleanEmail)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.UNAUTHORIZED, "Invalid credentials"));
        if (!encoder.matches(req.password(), u.getPassword())) {
            throw new ResponseStatusException(HttpStatus.UNAUTHORIZED, "Invalid credentials");
        }
        return new AuthResponse(jwt.generateToken(u.getId(), u.getEmail()), u.getId(), u.getName(), u.getEmail());
    }

    @PostMapping("/forgot-password")
    public ForgotPasswordResponse forgotPassword(@Valid @RequestBody ForgotPasswordRequest req) {
        String cleanEmail = req.email().trim();
        User u = users.findByEmailIgnoreCase(cleanEmail)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "No account found with this email"));

        // Generate 6-digit numeric OTP code
        String otp = String.format("%06d", secureRandom.nextInt(1_000_000));
        Instant expiryTime = Instant.now().plus(15, ChronoUnit.MINUTES);

        PasswordResetOtp resetOtp = new PasswordResetOtp(u.getEmail(), otp, expiryTime);
        otpRepository.save(resetOtp);

        boolean emailSent = emailService.sendPasswordResetOtp(u.getEmail(), otp);
        String previewOtp = emailSent ? null : otp;
        String message = emailSent
                ? "A 6-digit verification code has been sent to your email inbox."
                : "A 6-digit verification code was generated (Demo Mode: code provided for testing).";

        return new ForgotPasswordResponse(message, emailSent, previewOtp);
    }

    @PostMapping("/verify-otp")
    public Map<String, Object> verifyOtp(@Valid @RequestBody VerifyOtpRequest req) {
        String cleanEmail = req.email().trim();
        User u = users.findByEmailIgnoreCase(cleanEmail)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "No account found with this email"));

        PasswordResetOtp resetOtp = otpRepository.findTopByEmailAndUsedFalseOrderByExpiryTimeDesc(u.getEmail())
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.BAD_REQUEST, "No active password reset request found"));

        if (Instant.now().isAfter(resetOtp.getExpiryTime())) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Verification code has expired. Please request a new one.");
        }

        if (!resetOtp.getOtp().equals(req.otp().trim())) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Invalid verification code. Please check and try again.");
        }

        return Map.of("valid", true, "message", "Verification code verified successfully.");
    }

    @PostMapping("/reset-password")
    public Map<String, Object> resetPassword(@Valid @RequestBody ResetPasswordRequest req) {
        String cleanEmail = req.email().trim();
        User u = users.findByEmailIgnoreCase(cleanEmail)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "User not found"));

        PasswordResetOtp resetOtp = otpRepository.findTopByEmailAndUsedFalseOrderByExpiryTimeDesc(u.getEmail())
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.BAD_REQUEST, "No active password reset request found"));

        if (Instant.now().isAfter(resetOtp.getExpiryTime())) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Verification code has expired. Please request a new one.");
        }

        if (!resetOtp.getOtp().equals(req.otp().trim())) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Invalid verification code.");
        }

        u.setPassword(encoder.encode(req.newPassword()));
        users.save(u);

        resetOtp.setUsed(true);
        otpRepository.save(resetOtp);

        return Map.of("success", true, "message", "Password reset successfully. You can now log in with your new password.");
    }
}
