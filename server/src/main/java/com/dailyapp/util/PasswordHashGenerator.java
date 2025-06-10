package com.dailyapp.util;

import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;

/**
 * 密码哈希生成工具类
 * 用于生成与应用程序兼容的BCrypt密码哈希
 */
public class PasswordHashGenerator {
    
    public static void main(String[] args) {
        BCryptPasswordEncoder encoder = new BCryptPasswordEncoder();
        
        // 为用户'大白兔'生成密码'7758258'的哈希
        String password = "7758258";
        String hashedPassword = encoder.encode(password);
        
        System.out.println("=== Password Hash Generator ===");
        System.out.println("Original Password: " + password);
        System.out.println("BCrypt Hash: " + hashedPassword);
        System.out.println("");
        System.out.println("Use this hash in your data.sql file:");
        System.out.println("INSERT INTO users (username, password, ...) VALUES ('大白兔', '" + hashedPassword + "', ...);");
        System.out.println("");
        
        // 验证哈希是否正确
        boolean matches = encoder.matches(password, hashedPassword);
        System.out.println("Verification: " + (matches ? "SUCCESS" : "FAILED"));
        
        // 生成几个不同的哈希值供选择
        System.out.println("");
        System.out.println("Alternative hashes (all valid):");
        for (int i = 0; i < 3; i++) {
            String altHash = encoder.encode(password);
            System.out.println((i + 1) + ". " + altHash);
        }
    }
}