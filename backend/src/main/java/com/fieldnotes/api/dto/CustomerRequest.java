package com.fieldnotes.api.dto;

import jakarta.validation.constraints.NotBlank;

public record CustomerRequest(@NotBlank String name, String contactInfo) {}
