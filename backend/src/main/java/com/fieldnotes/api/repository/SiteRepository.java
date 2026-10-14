package com.fieldnotes.api.repository;

import com.fieldnotes.api.entity.Site;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import java.util.List;
import java.util.Optional;

public interface SiteRepository extends JpaRepository<Site, Long> {

    // JOIN fetch so customer name comes in one query (no duplicate data stored)
    @Query("SELECT s FROM Site s JOIN FETCH s.customer WHERE s.user.id = :userId ORDER BY s.updatedAt DESC")
    List<Site> findAllByUserWithCustomer(@Param("userId") Long userId);

    @Query("SELECT s FROM Site s JOIN FETCH s.customer WHERE s.id = :id AND s.user.id = :userId")
    Optional<Site> findByIdAndUserWithCustomer(@Param("id") Long id, @Param("userId") Long userId);

    List<Site> findByUserIdAndCustomerIdOrderByUpdatedAtDesc(Long userId, Long customerId);

    Optional<Site> findByIdAndUserId(Long id, Long userId);
}
