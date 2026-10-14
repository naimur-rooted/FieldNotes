package com.fieldnotes.api.controller;

import com.fieldnotes.api.dto.SiteRequest;
import com.fieldnotes.api.entity.Customer;
import com.fieldnotes.api.entity.Site;
import com.fieldnotes.api.entity.User;
import com.fieldnotes.api.repository.CustomerRepository;
import com.fieldnotes.api.repository.SiteRepository;
import com.fieldnotes.api.repository.UserRepository;
import jakarta.validation.Valid;
import org.springframework.http.HttpStatus;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.server.ResponseStatusException;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/sites")
public class SiteController {

    private final SiteRepository sites;
    private final CustomerRepository customers;
    private final UserRepository users;

    public SiteController(SiteRepository sites, CustomerRepository customers, UserRepository users) {
        this.sites = sites;
        this.customers = customers;
        this.users = users;
    }

    private Long uid(Authentication auth) { return (Long) auth.getPrincipal(); }

    private Map<String, Object> toMap(Site s) {
        Map<String, Object> m = new HashMap<>();
        m.put("id", s.getId());
        m.put("name", s.getName());
        m.put("address", s.getAddress() == null ? "" : s.getAddress());
        m.put("customerId", s.getCustomer().getId());
        m.put("customerName", s.getCustomer().getName());
        m.put("createdAt", s.getCreatedAt().toString());
        m.put("updatedAt", s.getUpdatedAt().toString());
        return m;
    }

    // JOIN fetch: site + customer name in one query
    @GetMapping
    public List<Map<String, Object>> list(Authentication auth,
                                          @RequestParam(required = false) Long customerId) {
        Long userId = uid(auth);
        List<Site> result = (customerId == null)
                ? sites.findAllByUserWithCustomer(userId)
                : sites.findByUserIdAndCustomerIdOrderByUpdatedAtDesc(userId, customerId);
        return result.stream().map(this::toMap).toList();
    }

    @PostMapping
    public Map<String, Object> create(Authentication auth, @Valid @RequestBody SiteRequest req) {
        Long userId = uid(auth);
        User user = users.findById(userId).orElseThrow();
        Customer customer = customers.findByIdAndUserId(req.customerId(), userId)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.BAD_REQUEST, "Invalid customerId"));
        Site s = new Site();
        s.setName(req.name());
        s.setAddress(req.address());
        s.setCustomer(customer);
        s.setUser(user);
        s = sites.save(s);
        return toMap(sites.findByIdAndUserWithCustomer(s.getId(), userId).orElse(s));
    }

    @GetMapping("/{id}")
    public Map<String, Object> get(Authentication auth, @PathVariable Long id) {
        Site s = sites.findByIdAndUserWithCustomer(id, uid(auth))
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND));
        return toMap(s);
    }

    @PutMapping("/{id}")
    public Map<String, Object> update(Authentication auth, @PathVariable Long id, @Valid @RequestBody SiteRequest req) {
        Long userId = uid(auth);
        Site s = sites.findByIdAndUserId(id, userId)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND));
        Customer customer = customers.findByIdAndUserId(req.customerId(), userId)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.BAD_REQUEST, "Invalid customerId"));
        s.setName(req.name());
        s.setAddress(req.address());
        s.setCustomer(customer);
        sites.save(s);
        return toMap(sites.findByIdAndUserWithCustomer(id, userId).orElse(s));
    }

    @DeleteMapping("/{id}")
    @ResponseStatus(HttpStatus.NO_CONTENT)
    public void delete(Authentication auth, @PathVariable Long id) {
        Site s = sites.findByIdAndUserId(id, uid(auth))
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND));
        sites.delete(s);
    }
}
