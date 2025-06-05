package com.dailyapp.controller;

import com.dailyapp.dto.TodoCollectionRequest;
import com.dailyapp.model.TodoCollection;
import com.dailyapp.model.TodoCollectionItem;
import com.dailyapp.model.User;
import com.dailyapp.repository.UserRepository;
import com.dailyapp.service.TodoCollectionService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

import javax.validation.Valid;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/todo-collections")
@RequiredArgsConstructor
public class TodoCollectionController {
    
    private final TodoCollectionService todoCollectionService;
    private final UserRepository userRepository;
    
    @PostMapping
    public ResponseEntity<TodoCollection> createTodoCollection(
            Authentication authentication,
            @Valid @RequestBody TodoCollectionRequest request) {
        Long userId = getUserIdFromAuthentication(authentication);
        TodoCollection collection = todoCollectionService.createTodoCollection(userId, request);
        return ResponseEntity.ok(collection);
    }
    
    @GetMapping
    public ResponseEntity<List<TodoCollection>> getUserTodoCollections(Authentication authentication) {
        Long userId = getUserIdFromAuthentication(authentication);
        List<TodoCollection> collections = todoCollectionService.getUserTodoCollections(userId);
        return ResponseEntity.ok(collections);
    }
    
    @GetMapping("/{collectionId}")
    public ResponseEntity<TodoCollection> getTodoCollection(
            Authentication authentication,
            @PathVariable Long collectionId) {
        Long userId = getUserIdFromAuthentication(authentication);
        TodoCollection collection = todoCollectionService.getTodoCollectionByIdAndUserId(collectionId, userId);
        return ResponseEntity.ok(collection);
    }
    
    @GetMapping("/{collectionId}/items")
    public ResponseEntity<List<TodoCollectionItem>> getCollectionItems(
            Authentication authentication,
            @PathVariable Long collectionId) {
        Long userId = getUserIdFromAuthentication(authentication);
        List<TodoCollectionItem> items = todoCollectionService.getCollectionItems(userId, collectionId);
        return ResponseEntity.ok(items);
    }
    
    @PutMapping("/{collectionId}")
    public ResponseEntity<TodoCollection> updateTodoCollection(
            Authentication authentication,
            @PathVariable Long collectionId,
            @Valid @RequestBody TodoCollectionRequest request) {
        Long userId = getUserIdFromAuthentication(authentication);
        TodoCollection collection = todoCollectionService.updateTodoCollection(userId, collectionId, request);
        return ResponseEntity.ok(collection);
    }
    
    @PostMapping("/{collectionId}/items")
    public ResponseEntity<TodoCollectionItem> addItemToCollection(
            Authentication authentication,
            @PathVariable Long collectionId,
            @Valid @RequestBody TodoCollectionRequest.TodoCollectionItemRequest request) {
        Long userId = getUserIdFromAuthentication(authentication);
        TodoCollectionItem item = todoCollectionService.addItemToCollection(userId, collectionId, request);
        return ResponseEntity.ok(item);
    }
    
    @PatchMapping("/{collectionId}/items/{itemId}/toggle")
    @PutMapping("/{collectionId}/items/{itemId}/toggle")
    public ResponseEntity<TodoCollectionItem> toggleCollectionItemStatus(
            Authentication authentication,
            @PathVariable Long collectionId,
            @PathVariable Long itemId) {
        Long userId = getUserIdFromAuthentication(authentication);
        TodoCollectionItem item = todoCollectionService.toggleCollectionItemStatus(userId, collectionId, itemId);
        return ResponseEntity.ok(item);
    }
    
    @PatchMapping("/{collectionId}/sequence/start")
    @PutMapping("/{collectionId}/sequence/start")
    public ResponseEntity<TodoCollection> startSequence(
            Authentication authentication,
            @PathVariable Long collectionId) {
        Long userId = getUserIdFromAuthentication(authentication);
        TodoCollection collection = todoCollectionService.startSequence(userId, collectionId);
        return ResponseEntity.ok(collection);
    }
    
    @PatchMapping("/{collectionId}/sequence/stop")
    @PutMapping("/{collectionId}/sequence/stop")
    public ResponseEntity<TodoCollection> stopSequence(
            Authentication authentication,
            @PathVariable Long collectionId) {
        Long userId = getUserIdFromAuthentication(authentication);
        TodoCollection collection = todoCollectionService.stopSequence(userId, collectionId);
        return ResponseEntity.ok(collection);
    }
    
    @PatchMapping("/{collectionId}/sequence/next")
    @PutMapping("/{collectionId}/sequence/next")
    public ResponseEntity<TodoCollection> nextTaskInSequence(
            Authentication authentication,
            @PathVariable Long collectionId) {
        Long userId = getUserIdFromAuthentication(authentication);
        TodoCollection collection = todoCollectionService.nextTaskInSequence(userId, collectionId);
        return ResponseEntity.ok(collection);
    }
    
    @DeleteMapping("/{collectionId}")
    public ResponseEntity<Void> deleteTodoCollection(
            Authentication authentication,
            @PathVariable Long collectionId) {
        Long userId = getUserIdFromAuthentication(authentication);
        todoCollectionService.deleteTodoCollection(userId, collectionId);
        return ResponseEntity.ok().build();
    }
    
    @DeleteMapping("/{collectionId}/items/{itemId}")
    public ResponseEntity<Void> deleteCollectionItem(
            Authentication authentication,
            @PathVariable Long collectionId,
            @PathVariable Long itemId) {
        Long userId = getUserIdFromAuthentication(authentication);
        todoCollectionService.deleteCollectionItem(userId, collectionId, itemId);
        return ResponseEntity.ok().build();
    }
    
    private Long getUserIdFromAuthentication(Authentication authentication) {
        String username = authentication.getName();
        User user = userRepository.findByUsername(username)
                .orElseThrow(() -> new RuntimeException("用户不存在"));
        return user.getId();
    }
}