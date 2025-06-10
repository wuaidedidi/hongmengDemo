package com.dailyapp.dto;

import lombok.Data;
import lombok.NoArgsConstructor;
import lombok.AllArgsConstructor;

import javax.validation.constraints.NotBlank;
import java.util.List;
import java.util.ArrayList;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class TodoCollectionRequest {
    @NotBlank(message = "合集标题不能为空")
    private String title;
    
    private String description;
    
    private List<TodoCollectionItemRequest> items = new ArrayList<>();
    
    @Data
    @NoArgsConstructor
    @AllArgsConstructor
    public static class TodoCollectionItemRequest {
        @NotBlank(message = "子任务标题不能为空")
        private String title;
        
        private String description;
        
        private Integer durationMinutes = 25;
        
        private Integer orderIndex = 0;
    }
}