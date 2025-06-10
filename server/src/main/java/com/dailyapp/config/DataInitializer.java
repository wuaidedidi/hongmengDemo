package com.dailyapp.config;

import com.dailyapp.model.User;
import com.dailyapp.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.boot.CommandLineRunner;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Component;

@Component
@RequiredArgsConstructor
public class DataInitializer implements CommandLineRunner {

    private final UserRepository userRepository;
    private final PasswordEncoder passwordEncoder;

    @Override
    public void run(String... args) {
        // 创建测试用户
        if (!userRepository.existsByUsername("大白兔")) {
            User user = new User();
            user.setUsername("大白兔");
            user.setPassword(passwordEncoder.encode("7758258"));
            userRepository.save(user);
        }
    }
} 