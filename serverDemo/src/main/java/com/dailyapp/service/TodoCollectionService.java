package com.dailyapp.service;

import com.dailyapp.dto.TodoCollectionRequest;
import com.dailyapp.model.TodoCollection;
import com.dailyapp.model.TodoCollectionItem;
import com.dailyapp.repository.TodoCollectionRepository;
import com.dailyapp.repository.TodoCollectionItemRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;

@Service
@RequiredArgsConstructor
@Transactional
public class TodoCollectionService {
    
    private final TodoCollectionRepository todoCollectionRepository;
    private final TodoCollectionItemRepository todoCollectionItemRepository;
    
    public TodoCollection createTodoCollection(Long userId, TodoCollectionRequest request) {
        TodoCollection collection = new TodoCollection();
        collection.setUserId(userId);
        collection.setTitle(request.getTitle());
        collection.setDescription(request.getDescription());
        
        TodoCollection savedCollection = todoCollectionRepository.save(collection);
        
        // 创建子任务
        if (request.getItems() != null && !request.getItems().isEmpty()) {
            for (int i = 0; i < request.getItems().size(); i++) {
                TodoCollectionRequest.TodoCollectionItemRequest itemRequest = request.getItems().get(i);
                TodoCollectionItem item = new TodoCollectionItem();
                item.setCollectionId(savedCollection.getId());
                item.setTitle(itemRequest.getTitle());
                item.setDescription(itemRequest.getDescription());
                item.setDurationMinutes(itemRequest.getDurationMinutes());
                item.setOrderIndex(i);
                
                todoCollectionItemRepository.save(item);
            }
        }
        
        return savedCollection;
    }
    
    public TodoCollection updateTodoCollection(Long userId, Long collectionId, TodoCollectionRequest request) {
        TodoCollection collection = getTodoCollectionByIdAndUserId(collectionId, userId);
        
        collection.setTitle(request.getTitle());
        collection.setDescription(request.getDescription());
        
        return todoCollectionRepository.save(collection);
    }
    
    public TodoCollectionItem addItemToCollection(Long userId, Long collectionId, TodoCollectionRequest.TodoCollectionItemRequest itemRequest) {
        TodoCollection collection = getTodoCollectionByIdAndUserId(collectionId, userId);
        
        // 获取当前最大的orderIndex
        List<TodoCollectionItem> existingItems = todoCollectionItemRepository.findByCollectionIdOrderByOrderIndexAsc(collectionId);
        int nextOrderIndex = existingItems.size();
        
        TodoCollectionItem item = new TodoCollectionItem();
        item.setCollectionId(collectionId);
        item.setTitle(itemRequest.getTitle());
        item.setDescription(itemRequest.getDescription());
        item.setDurationMinutes(itemRequest.getDurationMinutes());
        item.setOrderIndex(nextOrderIndex);
        
        return todoCollectionItemRepository.save(item);
    }
    
    public TodoCollectionItem toggleCollectionItemStatus(Long userId, Long collectionId, Long itemId) {
        // 验证用户权限
        getTodoCollectionByIdAndUserId(collectionId, userId);
        
        Optional<TodoCollectionItem> itemOpt = todoCollectionItemRepository.findById(itemId);
        if (itemOpt.isEmpty() || !itemOpt.get().getCollectionId().equals(collectionId)) {
            throw new RuntimeException("子任务不存在或无权限访问");
        }
        
        TodoCollectionItem item = itemOpt.get();
        if (item.getIsCompleted()) {
            item.markIncomplete();
        } else {
            item.markCompleted();
        }
        
        TodoCollectionItem savedItem = todoCollectionItemRepository.save(item);
        
        // 检查是否所有子任务都已完成
        checkAndMarkCollectionCompleted(collectionId);
        
        return savedItem;
    }
    
    public TodoCollection startSequence(Long userId, Long collectionId) {
        TodoCollection collection = getTodoCollectionByIdAndUserId(collectionId, userId);
        
        collection.setIsSequenceActive(true);
        collection.setCurrentTaskIndex(0);
        
        return todoCollectionRepository.save(collection);
    }
    
    public TodoCollection stopSequence(Long userId, Long collectionId) {
        TodoCollection collection = getTodoCollectionByIdAndUserId(collectionId, userId);
        
        collection.setIsSequenceActive(false);
        collection.setCurrentTaskIndex(-1);
        
        return todoCollectionRepository.save(collection);
    }
    
    public TodoCollection nextTaskInSequence(Long userId, Long collectionId) {
        TodoCollection collection = getTodoCollectionByIdAndUserId(collectionId, userId);
        
        if (!collection.getIsSequenceActive()) {
            throw new RuntimeException("序列模式未激活");
        }
        
        List<TodoCollectionItem> items = todoCollectionItemRepository.findByCollectionIdOrderByOrderIndexAsc(collectionId);
        
        if (collection.getCurrentTaskIndex() < items.size() - 1) {
            collection.setCurrentTaskIndex(collection.getCurrentTaskIndex() + 1);
        } else {
            // 序列完成
            collection.setIsSequenceActive(false);
            collection.setCurrentTaskIndex(-1);
        }
        
        return todoCollectionRepository.save(collection);
    }
    
    @Transactional(readOnly = true)
    public List<TodoCollection> getUserTodoCollections(Long userId) {
        return todoCollectionRepository.findByUserIdOrderByCreateTimeDesc(userId);
    }
    
    @Transactional(readOnly = true)
    public List<TodoCollectionItem> getCollectionItems(Long userId, Long collectionId) {
        // 验证用户权限
        getTodoCollectionByIdAndUserId(collectionId, userId);
        return todoCollectionItemRepository.findByCollectionIdOrderByOrderIndexAsc(collectionId);
    }
    
    @Transactional(readOnly = true)
    public TodoCollection getTodoCollectionByIdAndUserId(Long collectionId, Long userId) {
        Optional<TodoCollection> collection = todoCollectionRepository.findById(collectionId);
        if (collection.isEmpty() || !collection.get().getUserId().equals(userId)) {
            throw new RuntimeException("待办合集不存在或无权限访问");
        }
        return collection.get();
    }
    
    public void deleteTodoCollection(Long userId, Long collectionId) {
        TodoCollection collection = getTodoCollectionByIdAndUserId(collectionId, userId);
        
        // 删除所有子任务
        todoCollectionItemRepository.deleteByCollectionId(collectionId);
        
        // 删除合集
        todoCollectionRepository.delete(collection);
    }
    
    public void deleteCollectionItem(Long userId, Long collectionId, Long itemId) {
        // 验证用户权限
        getTodoCollectionByIdAndUserId(collectionId, userId);
        
        Optional<TodoCollectionItem> itemOpt = todoCollectionItemRepository.findById(itemId);
        if (itemOpt.isEmpty() || !itemOpt.get().getCollectionId().equals(collectionId)) {
            throw new RuntimeException("子任务不存在或无权限访问");
        }
        
        todoCollectionItemRepository.delete(itemOpt.get());
    }
    
    private void checkAndMarkCollectionCompleted(Long collectionId) {
        Long totalItems = todoCollectionItemRepository.countTotalByCollectionId(collectionId);
        Long completedItems = todoCollectionItemRepository.countCompletedByCollectionId(collectionId);
        
        if (totalItems > 0 && totalItems.equals(completedItems)) {
            Optional<TodoCollection> collectionOpt = todoCollectionRepository.findById(collectionId);
            if (collectionOpt.isPresent()) {
                TodoCollection collection = collectionOpt.get();
                collection.markCompleted();
                todoCollectionRepository.save(collection);
            }
        }
    }
}