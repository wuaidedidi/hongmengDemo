package com.dailyapp;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.data.jpa.repository.config.EnableJpaAuditing;

@SpringBootApplication
@EnableJpaAuditing
public class DailyAppApplication {
    public static void main(String[] args) {
        SpringApplication.run(DailyAppApplication.class, args);
    }
} 