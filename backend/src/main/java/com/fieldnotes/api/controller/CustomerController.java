package com.fieldnotes.api.controller;

import com.fieldnotes.api.dto.CustomerRequest;
import com.fieldnotes.api.entity.Customer;
import com.fieldnotes.api.entity.User;
import com.fieldnotes.api.repository.CustomerRepository;
import com.fieldnotes.api.repository.UserRepository;
import jakarta.validation.Valid;
import org.springframework.http.HttpStatus;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.server.ResponseStatusException;

import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/customers")
public class CustomerController {

    private final CustomerRepository customers;
    private final UserRepository users;

    public CustomerController(CustomerRepository customers, UserRepository users) {
        this.customers = customers;
        this.users = users;
    }

    private Long uid(Authentication auth) { return (Long) auth.getPrincipal(); }

    @GetMapping
    public List<Map<String, Object>> list(Authentication auth) {
        return customers.findByUserIdOrderByUpdatedAtDesc(uid(auth)).stream()
                .map(c -> Map.<String, Object>of(
                        "id", c.getId(), "name", c.getName(),
                        "contactInfo", c.getContactInfo() == null ? "" : c.getContactInfo(),
                        "createdAt", c.getCreatedAt().toString(),
                        "updatedAt", c.getUpdatedAt().toString()))
                .toList();
    }

    @PostMapping
    public Map<String, Object> create(Authentication auth, @Valid @RequestBody CustomerRequest req) {
        User user = users.findById(uid(auth)).orElseThrow();
        Customer c = new Customer();
        c.setName(req.name());
        c.setContactInfo(req.contactInfo());
        c.setUser(user);
        c = customers.save(c);
        return Map.of("id", c.getId(), "name", c.getName(),
                "contactInfo", c.getContactInfo() == null ? "" : c.getContactInfo());
    }

    @GetMapping("/{id}")
    public Map<String, Object> get(Authentication auth, @PathVariable Long id) {
        Customer c = customers.findByIdAndUserId(id, uid(auth))
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND));
        return Map.of("id", c.getId(), "name", c.getName(),
                "contactInfo", c.getContactInfo() == null ? "" : c.getContactInfo());
    }

    @PutMapping("/{id}")
    public Map<String, Object> update(Authentication auth, @PathVariable Long id, @Valid @RequestBody CustomerRequest req) {
        Customer c = customers.findByIdAndUserId(id, uid(auth))
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND));
        c.setName(req.name());
        c.setContactInfo(req.contactInfo());
        c = customers.save(c);
        return Map.of("id", c.getId(), "name", c.getName(),
                "contactInfo", c.getContactInfo() == null ? "" : c.getContactInfo());
    }

    @DeleteMapping("/{id}")
    @ResponseStatus(HttpStatus.NO_CONTENT)
    public void delete(Authentication auth, @PathVariable Long id) {
        Customer c = customers.findByIdAndUserId(id, uid(auth))
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND));
        customers.delete(c);
    }
}
