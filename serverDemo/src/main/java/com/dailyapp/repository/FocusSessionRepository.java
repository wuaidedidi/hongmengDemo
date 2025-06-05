package com.dailyapp.repository;

import com.dailyapp.model.FocusSession;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;

import java.time.LocalDateTime;
import java.util.List;

public interface FocusSessionRepository extends JpaRepository<FocusSession, Long> {
    List<FocusSession> findByUserIdAndStartTimeBetween(Long userId, LocalDateTime start, LocalDateTime end);
    
    List<FocusSession> findByUserIdOrderByStartTimeDesc(Long userId);

    @Query("SELECT SUM(f.durationMinutes) FROM FocusSession f WHERE f.user.id = ?1 AND f.startTime BETWEEN ?2 AND ?3")
    Integer sumDurationByUserIdAndTimeRange(Long userId, LocalDateTime start, LocalDateTime end);
}