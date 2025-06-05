以下是重新编排的Markdown格式需求文档，已根据您的要求调整为使用H2数据库和Java技术栈（去除了容器化相关部分）：

```markdown
# 鸿蒙每日打卡系统后端需求

## 技术栈要求

- **语言**: Java 17+
- **框架**: Spring Boot 3.x
- **数据库**: H2 (内存模式/文件模式)
- **构建工具**: Maven/Gradle
- **API风格**: RESTful JSON
- **安全**: JWT认证

## 数据库配置

```properties
# application.properties示例配置
spring.datasource.url=jdbc:h2:file:./data/dailydb;DB_CLOSE_ON_EXIT=FALSE
spring.datasource.driverClassName=org.h2.Driver
spring.datasource.username=sa
spring.datasource.password=
spring.h2.console.enabled=true
spring.h2.console.path=/h2-console
```

## 核心模块设计

### 1. 用户认证模块

#### 接口规范

| 端点                   | 方法   | 描述        |
|----------------------|------|-----------|
| `/api/auth/register` | POST | 用户注册      |
| `/api/auth/login`    | POST | 用户登录获取JWT |
| `/api/auth/me`       | GET  | 获取当前用户信息  |

#### 示例请求体

```json
// 注册/登录
{
  "username": "testuser",
  "password": "Test@1234"
}
```

### 2. 专注时间模块

#### 数据表结构

```sql
-- H2 SQL
CREATE TABLE IF NOT EXISTS focus_session (
  id BIGINT PRIMARY KEY AUTO_INCREMENT,
  user_id BIGINT NOT NULL,
  start_time TIMESTAMP NOT NULL,
  end_time TIMESTAMP NOT NULL,
  duration INT NOT NULL COMMENT '分钟',
  tag VARCHAR(50)
);

CREATE INDEX idx_user_time ON focus_session(user_id, start_time);
```

#### 统计接口

| 端点                      | 方法   | 参数                | 返回   |
|-------------------------|------|-------------------|------|
| `/api/sessions/daily`   | GET  | `date=2023-01-01` | 当日统计 |
| `/api/sessions/weekly`  | GET  | `week=2023-W01`   | 本周统计 |
| `/api/sessions/monthly` | GET  | `month=2023-01`   | 本月统计 |
| `/api/sessions`         | POST | 专注时段数据            | 创建记录 |

### 3. 打卡模块

#### 数据表结构

```sql
CREATE TABLE IF NOT EXISTS check_in (
  id BIGINT PRIMARY KEY AUTO_INCREMENT,
  user_id BIGINT NOT NULL,
  check_date DATE NOT NULL,
  streak_count INT NOT NULL,
  UNIQUE(user_id, check_date)
);
```

## 代码结构要求

```
src/
├── main/
│   ├── java/
│   │   └── com/dailyapp/
│   │       ├── config/       # 安全配置等
│   │       ├── controller/   # API端点
│   │       ├── dto/          # 数据传输对象
│   │       ├── exception/    # 异常处理
│   │       ├── model/        # 实体类
│   │       ├── repository/   # 数据访问
│   │       ├── service/      # 业务逻辑
│   │       └── DailyAppApplication.java
│   └── resources/
│       ├── application.properties
│       └── data.sql          # 初始化数据(可选)
└── test/                     # 单元测试
```

## 关键实现要点

### 1. JWT认证实现

```java
// SecurityConfig.java 示例片段
@Bean
public SecurityFilterChain securityFilterChain(HttpSecurity http) throws Exception {
    http
        .csrf().disable()
        .authorizeRequests()
            .requestMatchers("/api/auth/**").permitAll()
            .anyRequest().authenticated()
        .and()
        .addFilterBefore(jwtAuthFilter, UsernamePasswordAuthenticationFilter.class);
    return http.build();
}
```

### 2. 专注时段统计

```java
// FocusSessionService.java 方法示例
public DailyStatsDTO getDailyStats(Long userId, LocalDate date) {
    LocalDateTime start = date.atStartOfDay();
    LocalDateTime end = date.plusDays(1).atStartOfDay();
    
    List<FocusSession> sessions = repository.findByUserIdAndTimeRange(
        userId, start, end);
    
    // 计算统计逻辑...
}
```

## 测试要求

1. 控制器层单元测试（MockMVC）
2. 服务层单元测试（Mockito）
3. 集成测试（Testcontainers可选）

## 交付物清单

1. 完整的可运行Spring Boot项目
2. 数据库初始化脚本（schema.sql）
3. Swagger API文档
4. Postman测试集合（可选）
5. 简要的README使用说明

```

这个MD文档已经针对Cursor的读取优化：
1. 使用清晰的Markdown标题结构
2. 包含可直接执行的代码片段
3. 技术栈要求明确
4. 数据库使用H2的配置示例
5. 去除了容器化相关内容

您可以直接将此内容保存为`requirements.md`文件供Cursor读取生成项目。需要补充或调整任何细节可以随时告知。