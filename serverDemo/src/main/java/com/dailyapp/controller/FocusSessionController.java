package com.dailyapp.controller;

import com.dailyapp.dto.FocusSessionRequest;
import com.dailyapp.dto.StatisticsResponse;
import com.dailyapp.model.FocusSession;
import com.dailyapp.model.User;
import com.dailyapp.repository.UserRepository;
import com.dailyapp.service.FocusSessionService;
import com.dailyapp.service.CheckInService;
import javax.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDate;
import java.util.List;

@RestController
@RequestMapping("/sessions")
@RequiredArgsConstructor
public class FocusSessionController {

    private final FocusSessionService focusSessionService;
    private final CheckInService checkInService;
    private final UserRepository userRepository;

    @PostMapping
    public ResponseEntity<FocusSession> createSession(
            Authentication authentication,
            @Valid @RequestBody FocusSessionRequest request) {
        Long userId = getUserIdFromAuthentication(authentication);
        return ResponseEntity.ok(focusSessionService.createSession(userId, request));
    }

    @GetMapping("/daily")
    public ResponseEntity<List<FocusSession>> getDailySessions(
            Authentication authentication,
            @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate date) {
        Long userId = getUserIdFromAuthentication(authentication);
        return ResponseEntity.ok(focusSessionService.getDailySessions(userId, date));
    }

    @GetMapping("/weekly")
    public ResponseEntity<List<FocusSession>> getWeeklySessions(
            Authentication authentication,
            @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate weekStart) {
        Long userId = getUserIdFromAuthentication(authentication);
        return ResponseEntity.ok(focusSessionService.getWeeklySessions(userId, weekStart));
    }

    @GetMapping("/monthly")
    public ResponseEntity<List<FocusSession>> getMonthlySessions(
            Authentication authentication,
            @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate monthStart) {
        Long userId = getUserIdFromAuthentication(authentication);
        return ResponseEntity.ok(focusSessionService.getMonthlySessions(userId, monthStart));
    }

    @GetMapping("/statistics")
    public ResponseEntity<StatisticsResponse> getStatistics(Authentication authentication) {
        Long userId = getUserIdFromAuthentication(authentication);
        
        // 获取各种统计数据
        LocalDate today = LocalDate.now();
        LocalDate weekStart = today.minusDays(today.getDayOfWeek().getValue() - 1);
        LocalDate monthStart = today.withDayOfMonth(1);
        
        // 计算总专注时间和次数
        List<FocusSession> allSessions = focusSessionService.getAllSessions(userId);
        Integer totalFocusTime = allSessions.stream()
                .mapToInt(FocusSession::getDurationMinutes)
                .sum();
        Integer totalFocusCount = allSessions.size();
        
        // 计算今日专注时间
        List<FocusSession> todaySessions = focusSessionService.getDailySessions(userId, today);
        Integer todayFocusTime = todaySessions.stream()
                .mapToInt(FocusSession::getDurationMinutes)
                .sum();
        
        // 计算本周专注时间
        List<FocusSession> weeklySessions = focusSessionService.getWeeklySessions(userId, weekStart);
        Integer weeklyFocusTime = weeklySessions.stream()
                .mapToInt(FocusSession::getDurationMinutes)
                .sum();
        
        // 计算本月专注时间
        List<FocusSession> monthlySessions = focusSessionService.getMonthlySessions(userId, monthStart);
        Integer monthlyFocusTime = monthlySessions.stream()
                .mapToInt(FocusSession::getDurationMinutes)
                .sum();
        
        // 获取连续打卡天数
        Integer currentStreak = checkInService.getCurrentStreak(userId);
        
        // 计算连续专注天数和总专注天数
        Integer continuousDays = focusSessionService.getContinuousFocusDays(userId);
        Integer totalDays = focusSessionService.getTotalFocusDays(userId);
        
        StatisticsResponse statistics = StatisticsResponse.builder()
                .totalFocusTime(totalFocusTime)
                .totalFocusCount(totalFocusCount)
                .continuousDays(continuousDays)
                .totalDays(totalDays)
                .todayFocusTime(todayFocusTime)
                .weeklyFocusTime(weeklyFocusTime)
                .monthlyFocusTime(monthlyFocusTime)
                .currentStreak(currentStreak)
                .build();
        
        return ResponseEntity.ok(statistics);
    }

    private Long getUserIdFromAuthentication(Authentication authentication) {
        String username = authentication.getName();
        User user = userRepository.findByUsername(username)
                .orElseThrow(() -> new RuntimeException("用户不存在: " + username));
        return user.getId();
    }
}