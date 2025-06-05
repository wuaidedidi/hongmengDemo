package com.dailyapp.repository;

import com.dailyapp.model.TodoCollection;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.time.LocalDateTime;
import java.util.List;

@Repository
public interface TodoCollectionRepository extends JpaRepository<TodoCollection, Long> {
    
    List<TodoCollection> findByUserIdOrderByCreateTimeDesc(Long userId);
    
    @Query("SELECT tc FROM TodoCollection tc WHERE tc.userId = :userId AND tc.createTime >= :startTime AND tc.createTime <= :endTime ORDER BY tc.createTime DESC")
    List<TodoCollection> findByUserIdAndCreateTimeBetween(@Param("userId") Long userId, 
                                                         @Param("startTime") LocalDateTime startTime, 
                                                         @Param("endTime") LocalDateTime endTime);
    
    @Query("SELECT COUNT(tc) FROM TodoCollection tc WHERE tc.userId = :userId AND tc.completedTime IS NOT NULL")
    Long countCompletedByUserId(@Param("userId") Long userId);
    
    @Query("SELECT COUNT(tc) FROM TodoCollection tc WHERE tc.userId = :userId")
    Long countTotalByUserId(@Param("userId") Long userId);
}