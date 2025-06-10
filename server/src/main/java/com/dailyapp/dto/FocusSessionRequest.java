package com.dailyapp.dto;

import javax.validation.constraints.NotBlank;
import javax.validation.constraints.NotNull;
import lombok.Data;

@Data
public class FocusSessionRequest {
    @NotNull(message = "开始时间不能为空")
    private String startTime;

    @NotNull(message = "结束时间不能为空")
    private String endTime;

    @NotNull(message = "专注时长不能为空")
    private Integer durationMinutes;

    @NotBlank(message = "任务描述不能为空")
    private String taskDescription;
} 