package com.fieldnotes.api.repository;

import com.fieldnotes.api.entity.FieldNote;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import java.util.List;
import java.util.Optional;

public interface FieldNoteRepository extends JpaRepository<FieldNote, Long> {

    // JOINs across note -> site -> customer so related info is retrieved relationally
    @Query("SELECT n FROM FieldNote n JOIN FETCH n.site s JOIN FETCH s.customer WHERE n.user.id = :userId ORDER BY n.updatedAt DESC")
    List<FieldNote> findAllByUserWithRelations(@Param("userId") Long userId);

    @Query("SELECT n FROM FieldNote n JOIN FETCH n.site s JOIN FETCH s.customer WHERE n.id = :id AND n.user.id = :userId")
    Optional<FieldNote> findByIdAndUserWithRelations(@Param("id") Long id, @Param("userId") Long userId);

    @Query("SELECT n FROM FieldNote n JOIN FETCH n.site s JOIN FETCH s.customer " +
           "WHERE n.user.id = :userId AND (cast(:siteId as long) IS NULL OR s.id = :siteId) " +
           "AND (cast(:status as string) IS NULL OR n.status = :status) " +
           "AND (cast(:q as string) IS NULL OR LOWER(n.title) LIKE LOWER(CONCAT('%', cast(:q as string), '%')) " +
           "OR LOWER(n.description) LIKE LOWER(CONCAT('%', cast(:q as string), '%')) " +
           "OR LOWER(s.name) LIKE LOWER(CONCAT('%', cast(:q as string), '%')) " +
           "OR LOWER(s.customer.name) LIKE LOWER(CONCAT('%', cast(:q as string), '%'))) " +
           "ORDER BY n.updatedAt DESC")
    List<FieldNote> search(@Param("userId") Long userId,
                           @Param("siteId") Long siteId,
                           @Param("status") String status,
                           @Param("q") String q);

    Optional<FieldNote> findByIdAndUserId(Long id, Long userId);
    List<FieldNote> findByUserIdAndSiteIdOrderByUpdatedAtDesc(Long userId, Long siteId);
}
