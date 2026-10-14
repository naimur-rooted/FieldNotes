package com.fieldnotes.api.repository;

import com.fieldnotes.api.entity.Customer;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.List;
import java.util.Optional;

public interface CustomerRepository extends JpaRepository<Customer, Long> {
    List<Customer> findByUserIdOrderByUpdatedAtDesc(Long userId);
    Optional<Customer> findByIdAndUserId(Long id, Long userId);
}
