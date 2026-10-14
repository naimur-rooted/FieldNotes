package com.fieldnotes.api.controller;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.Map;

@RestController
public class HealthController {

    @GetMapping("/")
    public Map<String, String> root() {
        return Map.of(
                "name", "Field Notes REST API",
                "status", "UP",
                "health", "/api/health",
                "frontend", "https://fieldnotes-app-rho.vercel.app"
        );
    }

    @GetMapping("/api/health")
    public Map<String, String> health() {
        return Map.of("status", "UP", "service", "fieldnotes-api");
    }
}
