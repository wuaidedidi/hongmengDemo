package com.dailyapp.dto;

import lombok.Data;
import lombok.NoArgsConstructor;
import lombok.AllArgsConstructor;

import javax.validation.constraints.NotBlank;
import javax.validation.constraints.NotNull;
import javax.validation.constraints.Min;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class TodoItemRequest {
    @NotBlank(message = "标题不能为空")
    private String title;
    
    private String description;
    
    @NotBlank(message = "类型不能为空")
    private String type;
    
    @NotNull(message = "时长不能为空")
    @Min(value = 1, message = "时长必须大于0")
    private Integer duration;
    
    private Boolean isImportant = false;
    
    private Boolean isUrgent = false;
}