package com.dailyapp.service;

import com.dailyapp.dto.TodoItemRequest;
import com.dailyapp.model.TodoItem;
import com.dailyapp.repository.TodoItemRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;

@Service
@RequiredArgsConstructor
@Transactional
public class TodoItemService {
    
    private final TodoItemRepository todoItemRepository;
    
    public TodoItem createTodoItem(Long userId, TodoItemRequest request) {
        TodoItem todoItem = new TodoItem();
        todoItem.setUserId(userId);
        todoItem.setTitle(request.getTitle());
        todoItem.setDescription(request.getDescription());
        todoItem.setType(request.getType());
        todoItem.setDuration(request.getDuration());
        todoItem.setIsImportant(request.getIsImportant());
        todoItem.setIsUrgent(request.getIsUrgent());
        todoItem.setIsCompleted(false);
        
        return todoItemRepository.save(todoItem);
    }
    
    public TodoItem updateTodoItem(Long userId, Long todoId, TodoItemRequest request) {
        TodoItem todoItem = getTodoItemByIdAndUserId(todoId, userId);
        
        todoItem.setTitle(request.getTitle());
        todoItem.setDescription(request.getDescription());
        todoItem.setType(request.getType());
        todoItem.setDuration(request.getDuration());
        todoItem.setIsImportant(request.getIsImportant());
        todoItem.setIsUrgent(request.getIsUrgent());
        
        return todoItemRepository.save(todoItem);
    }
    
    public TodoItem toggleTodoItemStatus(Long userId, Long todoId) {
        TodoItem todoItem = getTodoItemByIdAndUserId(todoId, userId);
        
        if (todoItem.getIsCompleted()) {
            todoItem.markIncomplete();
        } else {
            todoItem.markCompleted();
        }
        
        return todoItemRepository.save(todoItem);
    }
    
    public TodoItem updateFocusTime(Long userId, Long todoId, Integer focusTime) {
        TodoItem todoItem = getTodoItemByIdAndUserId(todoId, userId);
        todoItem.setFocusTime(focusTime);
        return todoItemRepository.save(todoItem);
    }
    
    @Transactional(readOnly = true)
    public List<TodoItem> getUserTodoItems(Long userId) {
        return todoItemRepository.findByUserIdOrderByCreateTimeDesc(userId);
    }
    
    @Transactional(readOnly = true)
    public List<TodoItem> getUserTodoItemsByStatus(Long userId, Boolean isCompleted) {
        return todoItemRepository.findByUserIdAndIsCompletedOrderByCreateTimeDesc(userId, isCompleted);
    }
    
    @Transactional(readOnly = true)
    public List<TodoItem> getUserTodoItemsByType(Long userId, String type) {
        return todoItemRepository.findByUserIdAndTypeOrderByCreateTimeDesc(userId, type);
    }
    
    @Transactional(readOnly = true)
    public TodoItem getTodoItemByIdAndUserId(Long todoId, Long userId) {
        Optional<TodoItem> todoItem = todoItemRepository.findById(todoId);
        if (todoItem.isEmpty() || !todoItem.get().getUserId().equals(userId)) {
            throw new RuntimeException("待办事项不存在或无权限访问");
        }
        return todoItem.get();
    }
    
    public void deleteTodoItem(Long userId, Long todoId) {
        TodoItem todoItem = getTodoItemByIdAndUserId(todoId, userId);
        todoItemRepository.delete(todoItem);
    }
    
    @Transactional(readOnly = true)
    public List<TodoItem> getTodoItemsInDateRange(Long userId, LocalDateTime startTime, LocalDateTime endTime) {
        return todoItemRepository.findByUserIdAndCreateTimeBetween(userId, startTime, endTime);
    }
}