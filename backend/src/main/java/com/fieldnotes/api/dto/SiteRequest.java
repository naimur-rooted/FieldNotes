package com.fieldnotes.api.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;

public record SiteRequest(
        @NotBlank String name,
        String address,
        @NotNull Long customerId) {}
