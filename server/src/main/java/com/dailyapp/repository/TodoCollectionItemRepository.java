package com.dailyapp.repository;

import com.dailyapp.model.TodoCollectionItem;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface TodoCollectionItemRepository extends JpaRepository<TodoCollectionItem, Long> {
    
    List<TodoCollectionItem> findByCollectionIdOrderByOrderIndexAsc(Long collectionId);
    
    @Query("SELECT tci FROM TodoCollectionItem tci WHERE tci.collectionId = :collectionId AND tci.isCompleted = :isCompleted ORDER BY tci.orderIndex ASC")
    List<TodoCollectionItem> findByCollectionIdAndIsCompleted(@Param("collectionId") Long collectionId, 
                                                             @Param("isCompleted") Boolean isCompleted);
    
    @Query("SELECT COUNT(tci) FROM TodoCollectionItem tci WHERE tci.collectionId = :collectionId AND tci.isCompleted = true")
    Long countCompletedByCollectionId(@Param("collectionId") Long collectionId);
    
    @Query("SELECT COUNT(tci) FROM TodoCollectionItem tci WHERE tci.collectionId = :collectionId")
    Long countTotalByCollectionId(@Param("collectionId") Long collectionId);
    
    void deleteByCollectionId(Long collectionId);
}