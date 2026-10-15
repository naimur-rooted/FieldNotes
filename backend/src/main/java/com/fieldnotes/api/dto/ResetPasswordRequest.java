package com.fieldnotes.api.dto;

import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;

public record ResetPasswordRequest(
        @Email @NotBlank String email,
        @NotBlank String otp,
        @NotBlank @Size(min = 6, message = "Password must be at least 6 characters") String newPassword
) {}
