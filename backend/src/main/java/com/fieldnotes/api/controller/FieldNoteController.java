package com.fieldnotes.api.controller;

import com.fieldnotes.api.dto.FieldNoteRequest;
import com.fieldnotes.api.entity.FieldNote;
import com.fieldnotes.api.entity.Site;
import com.fieldnotes.api.entity.User;
import com.fieldnotes.api.repository.FieldNoteRepository;
import com.fieldnotes.api.repository.SiteRepository;
import com.fieldnotes.api.repository.UserRepository;
import jakarta.validation.Valid;
import org.springframework.http.HttpStatus;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.server.ResponseStatusException;
import java.util.*;

@RestController
@RequestMapping("/api/notes")
public class FieldNoteController {
    private final FieldNoteRepository notes;
    private final SiteRepository sites;
    private final UserRepository users;
    public FieldNoteController(FieldNoteRepository notes, SiteRepository sites, UserRepository users) {
        this.notes = notes; this.sites = sites; this.users = users;
    }
    private Long uid(Authentication auth) { return (Long) auth.getPrincipal(); }
    private Map<String, Object> toMap(FieldNote n) {
        Map<String, Object> m = new HashMap<>();
        m.put("id", n.getId());
        m.put("siteId", n.getSite().getId());
        m.put("siteName", n.getSite().getName());
        m.put("customerId", n.getSite().getCustomer().getId());
        m.put("customerName", n.getSite().getCustomer().getName());
        m.put("title", n.getTitle());
        m.put("description", n.getDescription() == null ? "" : n.getDescription());
        m.put("location", n.getLocation() == null ? "" : n.getLocation());
        m.put("dateTime", n.getDateTime() == null ? null : n.getDateTime().toString());
        m.put("status", n.getStatus());
        m.put("createdAt", n.getCreatedAt().toString());
        m.put("updatedAt", n.getUpdatedAt().toString());
        return m;
    }
    @GetMapping
    public List<Map<String, Object>> list(Authentication auth,
            @RequestParam(required = false) Long siteId,
            @RequestParam(required = false) String status,
            @RequestParam(required = false, name = "q") String q) {
        String query = (q == null || q.isBlank()) ? null : q.trim();
        String st = (status == null || status.isBlank()) ? null : status.trim();
        if (siteId == null && st == null && query == null) {
            return notes.findAllByUserWithRelations(uid(auth)).stream().map(this::toMap).toList();
        }
        return notes.search(uid(auth), siteId, st, query).stream().map(this::toMap).toList();
    }
    @PostMapping
    public Map<String, Object> create(Authentication auth, @Valid @RequestBody FieldNoteRequest req) {
        Long userId = uid(auth);
        User user = users.findById(userId).orElseThrow();
        Site site = sites.findByIdAndUserId(req.siteId(), userId)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.BAD_REQUEST, "Invalid siteId"));
        FieldNote n = new FieldNote();
        n.setSite(site); n.setUser(user);
        n.setTitle(req.title()); n.setDescription(req.description());
        n.setLocation(req.location()); n.setDateTime(req.dateTime());
        n.setStatus(req.status() == null || req.status().isBlank() ? "OPEN" : req.status());
        n = notes.save(n);
        return toMap(notes.findByIdAndUserWithRelations(n.getId(), userId).orElse(n));
    }
    @GetMapping("/{id}")
    public Map<String, Object> get(Authentication auth, @PathVariable Long id) {
        FieldNote n = notes.findByIdAndUserWithRelations(id, uid(auth))
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND));
        return toMap(n);
    }
    @PutMapping("/{id}")
    public Map<String, Object> update(Authentication auth, @PathVariable Long id, @Valid @RequestBody FieldNoteRequest req) {
        Long userId = uid(auth);
        FieldNote n = notes.findByIdAndUserId(id, userId)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND));
        Site site = sites.findByIdAndUserId(req.siteId(), userId)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.BAD_REQUEST, "Invalid siteId"));
        n.setSite(site); n.setTitle(req.title());
        n.setDescription(req.description()); n.setLocation(req.location());
        n.setDateTime(req.dateTime());
        if (req.status() != null && !req.status().isBlank()) n.setStatus(req.status());
        notes.save(n);
        return toMap(notes.findByIdAndUserWithRelations(id, userId).orElse(n));
    }
    @DeleteMapping("/{id}")
    @ResponseStatus(HttpStatus.NO_CONTENT)
    public void delete(Authentication auth, @PathVariable Long id) {
        FieldNote n = notes.findByIdAndUserId(id, uid(auth))
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND));
        notes.delete(n);
    }
}

