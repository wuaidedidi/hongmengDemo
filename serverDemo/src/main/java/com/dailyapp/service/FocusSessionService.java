package com.dailyapp.service;

import com.dailyapp.dto.FocusSessionRequest;
import com.dailyapp.model.FocusSession;
import com.dailyapp.model.User;
import com.dailyapp.repository.FocusSessionRepository;
import com.dailyapp.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.LocalTime;
import java.time.format.DateTimeFormatter;
import java.util.List;
import java.util.Set;
import java.util.HashSet;

@Service
@RequiredArgsConstructor
public class FocusSessionService {

    private final FocusSessionRepository focusSessionRepository;
    private final UserRepository userRepository;
    private static final DateTimeFormatter DATE_TIME_FORMATTER = DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss");

    @Transactional
    public FocusSession createSession(Long userId, FocusSessionRequest request) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new RuntimeException("用户不存在"));

        FocusSession session = new FocusSession();
        session.setUser(user);
        session.setStartTime(LocalDateTime.parse(request.getStartTime(), DATE_TIME_FORMATTER));
        session.setEndTime(LocalDateTime.parse(request.getEndTime(), DATE_TIME_FORMATTER));
        session.setDurationMinutes(request.getDurationMinutes());
        session.setTaskDescription(request.getTaskDescription());

        return focusSessionRepository.save(session);
    }

    public List<FocusSession> getDailySessions(Long userId, LocalDate date) {
        LocalDateTime start = date.atStartOfDay();
        LocalDateTime end = date.atTime(LocalTime.MAX);
        return focusSessionRepository.findByUserIdAndStartTimeBetween(userId, start, end);
    }

    public List<FocusSession> getWeeklySessions(Long userId, LocalDate weekStart) {
        LocalDateTime start = weekStart.atStartOfDay();
        LocalDateTime end = weekStart.plusDays(7).atTime(LocalTime.MAX);
        return focusSessionRepository.findByUserIdAndStartTimeBetween(userId, start, end);
    }

    public List<FocusSession> getMonthlySessions(Long userId, LocalDate monthStart) {
        LocalDateTime start = monthStart.atStartOfDay();
        LocalDateTime end = monthStart.plusMonths(1).atTime(LocalTime.MAX);
        return focusSessionRepository.findByUserIdAndStartTimeBetween(userId, start, end);
    }

    public Integer getTotalDuration(Long userId, LocalDateTime start, LocalDateTime end) {
        return focusSessionRepository.sumDurationByUserIdAndTimeRange(userId, start, end);
    }

    public List<FocusSession> getAllSessions(Long userId) {
        return focusSessionRepository.findByUserIdOrderByStartTimeDesc(userId);
    }

    public Integer getContinuousFocusDays(Long userId) {
        // 获取用户所有专注记录，按日期分组
        List<FocusSession> sessions = focusSessionRepository.findByUserIdOrderByStartTimeDesc(userId);
        if (sessions.isEmpty()) {
            return 0;
        }

        // 按日期分组统计
        Set<LocalDate> focusDates = sessions.stream()
                .map(session -> session.getStartTime().toLocalDate())
                .collect(java.util.stream.Collectors.toSet());

        // 计算连续天数
        LocalDate today = LocalDate.now();
        int continuousDays = 0;
        LocalDate checkDate = today;

        while (focusDates.contains(checkDate)) {
            continuousDays++;
            checkDate = checkDate.minusDays(1);
        }

        return continuousDays;
    }

    public Integer getTotalFocusDays(Long userId) {
        List<FocusSession> sessions = focusSessionRepository.findByUserIdOrderByStartTimeDesc(userId);
        if (sessions.isEmpty()) {
            return 0;
        }

        // 统计不重复的专注日期数量
        Set<LocalDate> focusDates = sessions.stream()
                .map(session -> session.getStartTime().toLocalDate())
                .collect(java.util.stream.Collectors.toSet());

        return focusDates.size();
    }
}