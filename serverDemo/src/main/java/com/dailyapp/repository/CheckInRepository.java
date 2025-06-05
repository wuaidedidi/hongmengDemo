package com.dailyapp.repository;

import com.dailyapp.model.CheckIn;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;

import java.time.LocalDate;
import java.util.Optional;

public interface CheckInRepository extends JpaRepository<CheckIn, Long> {
    Optional<CheckIn> findByUserIdAndDate(Long userId, LocalDate date);

    @Query("SELECT MAX(c.streakCount) FROM CheckIn c WHERE c.user.id = ?1")
    Integer findMaxStreakCountByUserId(Long userId);
} 