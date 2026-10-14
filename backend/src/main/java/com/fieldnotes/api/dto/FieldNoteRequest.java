package com.fieldnotes.api.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import java.time.Instant;

public record FieldNoteRequest(
        @NotNull Long siteId,
        @NotBlank String title,
        String description,
        String location,
        Instant dateTime,
        String status) {}
