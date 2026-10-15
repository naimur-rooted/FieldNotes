package com.fieldnotes.api.dto;

public record ForgotPasswordResponse(
        String message,
        boolean emailSent,
        String previewOtp
) {}
