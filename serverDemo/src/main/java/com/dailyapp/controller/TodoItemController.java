package com.dailyapp.controller;

import com.dailyapp.dto.TodoItemRequest;
import com.dailyapp.model.TodoItem;
import com.dailyapp.model.User;
import com.dailyapp.repository.UserRepository;
import com.dailyapp.service.TodoItemService;
import lombok.RequiredArgsConstructor;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

import javax.validation.Valid;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.LocalTime;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/todos")
@RequiredArgsConstructor
public class TodoItemController {
    
    private final TodoItemService todoItemService;
    private final UserRepository userRepository;
    
    @PostMapping
    public ResponseEntity<TodoItem> createTodoItem(
            Authentication authentication,
            @Valid @RequestBody TodoItemRequest request) {
        if (authentication == null) {
            return ResponseEntity.status(401).build();
        }
        Long userId = getUserIdFromAuthentication(authentication);
        TodoItem todoItem = todoItemService.createTodoItem(userId, request);
        return ResponseEntity.ok(todoItem);
    }
    
    @GetMapping
    public ResponseEntity<List<TodoItem>> getUserTodoItems(Authentication authentication) {
        if (authentication == null) {
            return ResponseEntity.ok(List.of());
        }
        Long userId = getUserIdFromAuthentication(authentication);
        List<TodoItem> todoItems = todoItemService.getUserTodoItems(userId);
        return ResponseEntity.ok(todoItems);
    }
    
    @GetMapping("/status/{isCompleted}")
    public ResponseEntity<List<TodoItem>> getUserTodoItemsByStatus(
            Authentication authentication,
            @PathVariable Boolean isCompleted) {
        Long userId = getUserIdFromAuthentication(authentication);
        List<TodoItem> todoItems = todoItemService.getUserTodoItemsByStatus(userId, isCompleted);
        return ResponseEntity.ok(todoItems);
    }
    
    @GetMapping("/type/{type}")
    public ResponseEntity<List<TodoItem>> getUserTodoItemsByType(
            Authentication authentication,
            @PathVariable String type) {
        Long userId = getUserIdFromAuthentication(authentication);
        List<TodoItem> todoItems = todoItemService.getUserTodoItemsByType(userId, type);
        return ResponseEntity.ok(todoItems);
    }
    
    @GetMapping("/date-range")
    public ResponseEntity<List<TodoItem>> getTodoItemsInDateRange(
            Authentication authentication,
            @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate startDate,
            @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate endDate) {
        Long userId = getUserIdFromAuthentication(authentication);
        LocalDateTime startTime = startDate.atStartOfDay();
        LocalDateTime endTime = endDate.atTime(LocalTime.MAX);
        List<TodoItem> todoItems = todoItemService.getTodoItemsInDateRange(userId, startTime, endTime);
        return ResponseEntity.ok(todoItems);
    }
    
    @GetMapping("/{todoId}")
    public ResponseEntity<TodoItem> getTodoItem(
            Authentication authentication,
            @PathVariable Long todoId) {
        Long userId = getUserIdFromAuthentication(authentication);
        TodoItem todoItem = todoItemService.getTodoItemByIdAndUserId(todoId, userId);
        return ResponseEntity.ok(todoItem);
    }
    
    @PutMapping("/{todoId}")
    public ResponseEntity<TodoItem> updateTodoItem(
            Authentication authentication,
            @PathVariable Long todoId,
            @Valid @RequestBody TodoItemRequest request) {
        Long userId = getUserIdFromAuthentication(authentication);
        TodoItem todoItem = todoItemService.updateTodoItem(userId, todoId, request);
        return ResponseEntity.ok(todoItem);
    }
    
    @PatchMapping("/{todoId}/toggle")
    @PutMapping("/{todoId}/toggle")
    public ResponseEntity<TodoItem> toggleTodoItemStatus(
            Authentication authentication,
            @PathVariable Long todoId) {
        Long userId = getUserIdFromAuthentication(authentication);
        TodoItem todoItem = todoItemService.toggleTodoItemStatus(userId, todoId);
        return ResponseEntity.ok(todoItem);
    }
    
    @PatchMapping("/{todoId}/focus-time")
    @PutMapping("/{todoId}/focus-time")
    public ResponseEntity<TodoItem> updateFocusTime(
            Authentication authentication,
            @PathVariable Long todoId,
            @RequestBody Map<String, Integer> request) {
        Long userId = getUserIdFromAuthentication(authentication);
        Integer focusTime = request.get("focusTime");
        if (focusTime == null || focusTime < 0) {
            return ResponseEntity.badRequest().build();
        }
        TodoItem todoItem = todoItemService.updateFocusTime(userId, todoId, focusTime);
        return ResponseEntity.ok(todoItem);
    }
    
    @DeleteMapping("/{todoId}")
    public ResponseEntity<Void> deleteTodoItem(
            Authentication authentication,
            @PathVariable Long todoId) {
        Long userId = getUserIdFromAuthentication(authentication);
        todoItemService.deleteTodoItem(userId, todoId);
        return ResponseEntity.ok().build();
    }
    
    private Long getUserIdFromAuthentication(Authentication authentication) {
        String username = authentication.getName();
        User user = userRepository.findByUsername(username)
                .orElseThrow(() -> new RuntimeException("用户不存在"));
        return user.getId();
    }
}