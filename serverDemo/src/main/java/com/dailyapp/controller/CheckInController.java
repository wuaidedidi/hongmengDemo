package com.dailyapp.controller;

import com.dailyapp.model.CheckIn;
import com.dailyapp.model.User;
import com.dailyapp.repository.UserRepository;
import com.dailyapp.service.CheckInService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/check-in")
@RequiredArgsConstructor
public class CheckInController {

    private final CheckInService checkInService;
    private final UserRepository userRepository;

    @PostMapping
    public ResponseEntity<CheckIn> checkIn(Authentication authentication) {
        Long userId = getUserIdFromAuthentication(authentication);
        return ResponseEntity.ok(checkInService.checkIn(userId));
    }

    @GetMapping("/streak")
    public ResponseEntity<Integer> getCurrentStreak(Authentication authentication) {
        Long userId = getUserIdFromAuthentication(authentication);
        return ResponseEntity.ok(checkInService.getCurrentStreak(userId));
    }

    @GetMapping("/today")
    public ResponseEntity<Boolean> hasCheckedInToday(Authentication authentication) {
        Long userId = getUserIdFromAuthentication(authentication);
        return ResponseEntity.ok(checkInService.hasCheckedInToday(userId));
    }

    private Long getUserIdFromAuthentication(Authentication authentication) {
        String username = authentication.getName();
        User user = userRepository.findByUsername(username)
                .orElseThrow(() -> new RuntimeException("用户不存在"));
        return user.getId();
    }
} 