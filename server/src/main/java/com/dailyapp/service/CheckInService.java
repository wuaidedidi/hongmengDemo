package com.dailyapp.service;

import com.dailyapp.model.CheckIn;
import com.dailyapp.model.User;
import com.dailyapp.repository.CheckInRepository;
import com.dailyapp.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;
import java.time.LocalTime;

@Service
@RequiredArgsConstructor
public class CheckInService {

    private final CheckInRepository checkInRepository;
    private final UserRepository userRepository;

    @Transactional
    public CheckIn checkIn(Long userId) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new RuntimeException("用户不存在"));

        LocalDate today = LocalDate.now();
        LocalTime now = LocalTime.now();
        // 检查是否已经打卡
        if (checkInRepository.findByUserIdAndDate(userId, today).isPresent()) {
            throw new RuntimeException("今天已经打卡了");
        }

        // 获取昨天的打卡记录
        LocalDate yesterday = today.minusDays(1);
        CheckIn yesterdayCheckIn = checkInRepository.findByUserIdAndDate(userId, yesterday)
                .orElse(null);

        // 计算连续打卡天数
        int streakCount = (yesterdayCheckIn != null) ? yesterdayCheckIn.getStreakCount() + 1 : 1;

        CheckIn checkIn = new CheckIn();
        checkIn.setUser(user);
        checkIn.setDate(today);
        checkIn.setTime(now);
        checkIn.setStreakCount(streakCount);

        return checkInRepository.save(checkIn);
    }

    public Integer getCurrentStreak(Long userId) {
        return checkInRepository.findMaxStreakCountByUserId(userId);
    }

    public boolean hasCheckedInToday(Long userId) {
        return checkInRepository.findByUserIdAndDate(userId, LocalDate.now()).isPresent();
    }
} 