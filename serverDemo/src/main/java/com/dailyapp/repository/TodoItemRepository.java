package com.dailyapp.repository;

import com.dailyapp.model.TodoItem;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.time.LocalDateTime;
import java.util.List;

@Repository
public interface TodoItemRepository extends JpaRepository<TodoItem, Long> {
    
    List<TodoItem> findByUserIdOrderByCreateTimeDesc(Long userId);
    
    List<TodoItem> findByUserIdAndIsCompletedOrderByCreateTimeDesc(Long userId, Boolean isCompleted);
    
    List<TodoItem> findByUserIdAndTypeOrderByCreateTimeDesc(Long userId, String type);
    
    @Query("SELECT t FROM TodoItem t WHERE t.userId = :userId AND t.createTime >= :startTime AND t.createTime <= :endTime ORDER BY t.createTime DESC")
    List<TodoItem> findByUserIdAndCreateTimeBetween(@Param("userId") Long userId, 
                                                   @Param("startTime") LocalDateTime startTime, 
                                                   @Param("endTime") LocalDateTime endTime);
    
    @Query("SELECT COUNT(t) FROM TodoItem t WHERE t.userId = :userId AND t.isCompleted = true")
    Long countCompletedByUserId(@Param("userId") Long userId);
    
    @Query("SELECT COUNT(t) FROM TodoItem t WHERE t.userId = :userId")
    Long countTotalByUserId(@Param("userId") Long userId);
    
    @Query("SELECT SUM(t.focusTime) FROM TodoItem t WHERE t.userId = :userId AND t.isCompleted = true AND t.focusTime IS NOT NULL")
    Long sumFocusTimeByUserId(@Param("userId") Long userId);
}