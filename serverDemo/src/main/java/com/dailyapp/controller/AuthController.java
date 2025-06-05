package com.dailyapp.controller;

import com.dailyapp.dto.AuthRequest;
import com.dailyapp.dto.AuthResponse;
import com.dailyapp.service.AuthService;
import javax.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/auth")
@RequiredArgsConstructor
public class AuthController {

    private final AuthService authService;

    @PostMapping("/register")
    public ResponseEntity<AuthResponse> register(@Valid @RequestBody AuthRequest request) {
        return ResponseEntity.ok(authService.register(request));
    }

    @PostMapping("/login")
    public ResponseEntity<AuthResponse> login(@Valid @RequestBody AuthRequest request) {
        try {
            return ResponseEntity.ok(authService.login(request));
        } catch (Exception e) {
            // 登录失败，返回 401 状态码，并返回错误信息
            return ResponseEntity.status(401).body(new AuthResponse(null, e.getMessage()));
        }
    }
} 