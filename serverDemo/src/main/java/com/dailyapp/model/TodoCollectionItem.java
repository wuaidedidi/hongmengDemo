package com.dailyapp.model;

import lombok.Data;
import lombok.NoArgsConstructor;
import lombok.AllArgsConstructor;

import javax.persistence.*;
import java.time.LocalDateTime;

@Entity
@Table(name = "todo_collection_items")
@Data
@NoArgsConstructor
@AllArgsConstructor
public class TodoCollectionItem {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    @Column(nullable = false)
    private Long collectionId;
    
    @Column(nullable = false, length = 255)
    private String title;
    
    @Column(length = 500)
    private String description;
    
    @Column(nullable = false)
    private Integer durationMinutes; // 预计时长（分钟）
    
    @Column(nullable = false)
    private Boolean isCompleted = false;
    
    @Column(nullable = false)
    private Integer orderIndex = 0; // 在合集中的顺序
    
    @Column(nullable = false)
    private LocalDateTime createTime;
    
    @Column
    private LocalDateTime completedTime;
    
    @Column
    private Integer actualFocusTime; // 实际专注时间（分钟）
    
    @PrePersist
    protected void onCreate() {
        createTime = LocalDateTime.now();
    }
    
    public void markCompleted() {
        this.isCompleted = true;
        this.completedTime = LocalDateTime.now();
    }
    
    public void markIncomplete() {
        this.isCompleted = false;
        this.completedTime = null;
    }
}