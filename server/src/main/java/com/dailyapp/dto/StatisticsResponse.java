package com.dailyapp.dto;

import lombok.Data;
import lombok.Builder;
import lombok.NoArgsConstructor;
import lombok.AllArgsConstructor;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class StatisticsResponse {
    private Integer totalFocusTime;        // 总专注时间（分钟）
    private Integer totalFocusCount;       // 总专注次数
    private Integer continuousDays;        // 连续专注天数
    private Integer totalDays;             // 总专注天数
    private Integer todayFocusTime;        // 今日专注时间
    private Integer weeklyFocusTime;       // 本周专注时间
    private Integer monthlyFocusTime;      // 本月专注时间
    private Integer currentStreak;         // 当前连续打卡天数
}