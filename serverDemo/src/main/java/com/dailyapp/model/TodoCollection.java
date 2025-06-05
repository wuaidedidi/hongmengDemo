package com.dailyapp.model;

import lombok.Data;
import lombok.NoArgsConstructor;
import lombok.AllArgsConstructor;

import javax.persistence.*;
import java.time.LocalDateTime;
import java.util.List;
import java.util.ArrayList;

@Entity
@Table(name = "todo_collections")
@Data
@NoArgsConstructor
@AllArgsConstructor
public class TodoCollection {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    @Column(nullable = false)
    private Long userId;
    
    @Column(nullable = false, length = 255)
    private String title;
    
    @Column(length = 500)
    private String description;
    
    @Column(nullable = false)
    private Boolean isSequenceActive = false;
    
    @Column
    private Integer currentTaskIndex = -1;
    
    @Column(nullable = false)
    private LocalDateTime createTime;
    
    @Column
    private LocalDateTime completedTime;
    
    @OneToMany(mappedBy = "collectionId", cascade = CascadeType.ALL, fetch = FetchType.LAZY)
    private List<TodoCollectionItem> items = new ArrayList<>();
    
    @PrePersist
    protected void onCreate() {
        createTime = LocalDateTime.now();
    }
    
    public boolean isAllItemsCompleted() {
        return items.stream().allMatch(TodoCollectionItem::getIsCompleted);
    }
    
    public void markCompleted() {
        this.completedTime = LocalDateTime.now();
    }
}