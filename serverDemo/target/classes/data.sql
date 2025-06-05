-- 初始化数据脚本
-- 创建用户：大白兔，密码：7758258
-- 注意：密码使用BCrypt加密，这里是7758258的BCrypt哈希值

-- 插入用户数据（用户名：大白兔，密码：7758258）
-- BCrypt哈希值使用strength=10生成，与Spring Security默认配置兼容
INSERT INTO users (id, username, password, created_at, updated_at) VALUES 
(1, '大白兔', '$2a$10$N9qo8uLOickgx2ZMRZoMye.IjZGgzJg7fQZm7W91NQeQvl9FLGW1O', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);

-- 插入待办事项数据
INSERT INTO todo_items (id, user_id, title, description, completed, priority, created_at, updated_at) VALUES 
(1, 1, '学习HarmonyOS开发', '深入学习HarmonyOS应用开发技术', false, 'HIGH', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
(2, 1, '完成项目文档', '编写项目的技术文档和用户手册', false, 'MEDIUM', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
(3, 1, '代码重构', '优化现有代码结构，提高代码质量', false, 'LOW', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
(4, 1, '测试用例编写', '为核心功能编写单元测试', true, 'HIGH', DATEADD('DAY', -1, CURRENT_TIMESTAMP), CURRENT_TIMESTAMP),
(5, 1, '性能优化', '分析和优化应用性能瓶颈', false, 'MEDIUM', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);

-- 插入待办合集数据
INSERT INTO todo_collections (id, user_id, name, description, created_at, updated_at) VALUES 
(1, 1, '学习计划', '系统性学习新技术的计划', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
(2, 1, '项目开发', '当前项目的开发任务', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
(3, 1, '生活安排', '日常生活相关的待办事项', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);

-- 插入待办合集项目数据
INSERT INTO todo_collection_items (id, collection_id, title, description, completed, order_index, created_at, updated_at) VALUES 
(1, 1, 'ArkTS语法学习', '学习ArkTS的基础语法和特性', false, 1, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
(2, 1, 'UI组件使用', '掌握HarmonyOS的UI组件库', false, 2, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
(3, 1, '网络请求处理', '学习HTTP请求和数据处理', true, 3, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
(4, 2, 'API设计', '设计RESTful API接口', true, 1, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
(5, 2, '前端页面开发', '开发用户界面页面', false, 2, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
(6, 2, '数据库设计', '设计应用的数据存储结构', true, 3, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
(7, 3, '买菜购物', '购买本周所需的生活用品', false, 1, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
(8, 3, '健身运动', '每周至少3次运动锻炼', false, 2, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);

-- 插入专注会话数据（最近30天的数据）
-- 今天的数据
INSERT INTO focus_sessions (id, user_id, start_time, end_time, duration_minutes, task_description, created_at, updated_at, version) VALUES 
(1, 1, DATEADD('HOUR', -2, CURRENT_TIMESTAMP), DATEADD('MINUTE', -95, CURRENT_TIMESTAMP), 25, '学习Spring Boot开发', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, 0),
(2, 1, DATEADD('HOUR', -1, CURRENT_TIMESTAMP), DATEADD('MINUTE', -35, CURRENT_TIMESTAMP), 25, '复习数据库知识', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, 0);

-- 昨天的数据
INSERT INTO focus_sessions (id, user_id, start_time, end_time, duration_minutes, task_description, created_at, updated_at, version) VALUES 
(3, 1, DATEADD('DAY', -1, DATEADD('HOUR', -3, CURRENT_TIMESTAMP)), DATEADD('DAY', -1, DATEADD('HOUR', -2, DATEADD('MINUTE', -35, CURRENT_TIMESTAMP))), 25, '阅读技术文档', DATEADD('DAY', -1, CURRENT_TIMESTAMP), DATEADD('DAY', -1, CURRENT_TIMESTAMP), 0),
(4, 1, DATEADD('DAY', -1, DATEADD('HOUR', -1, CURRENT_TIMESTAMP)), DATEADD('DAY', -1, DATEADD('MINUTE', -35, CURRENT_TIMESTAMP)), 25, '编写代码练习', DATEADD('DAY', -1, CURRENT_TIMESTAMP), DATEADD('DAY', -1, CURRENT_TIMESTAMP), 0),
(5, 1, DATEADD('DAY', -1, DATEADD('MINUTE', -30, CURRENT_TIMESTAMP)), DATEADD('DAY', -1, DATEADD('MINUTE', -5, CURRENT_TIMESTAMP)), 25, '项目规划', DATEADD('DAY', -1, CURRENT_TIMESTAMP), DATEADD('DAY', -1, CURRENT_TIMESTAMP), 0);

-- 前天的数据
INSERT INTO focus_sessions (id, user_id, start_time, end_time, duration_minutes, task_description, created_at, updated_at, version) VALUES 
(6, 1, DATEADD('DAY', -2, DATEADD('HOUR', -4, CURRENT_TIMESTAMP)), DATEADD('DAY', -2, DATEADD('HOUR', -3, DATEADD('MINUTE', -35, CURRENT_TIMESTAMP))), 25, '学习HarmonyOS开发', DATEADD('DAY', -2, CURRENT_TIMESTAMP), DATEADD('DAY', -2, CURRENT_TIMESTAMP), 0),
(7, 1, DATEADD('DAY', -2, DATEADD('HOUR', -2, CURRENT_TIMESTAMP)), DATEADD('DAY', -2, DATEADD('HOUR', -1, DATEADD('MINUTE', -35, CURRENT_TIMESTAMP))), 25, '调试应用程序', DATEADD('DAY', -2, CURRENT_TIMESTAMP), DATEADD('DAY', -2, CURRENT_TIMESTAMP), 0);

-- 3天前的数据
INSERT INTO focus_sessions (id, user_id, start_time, end_time, duration_minutes, task_description, created_at, updated_at, version) VALUES 
(8, 1, DATEADD('DAY', -3, DATEADD('HOUR', -3, CURRENT_TIMESTAMP)), DATEADD('DAY', -3, DATEADD('HOUR', -2, DATEADD('MINUTE', -35, CURRENT_TIMESTAMP))), 25, '设计数据库结构', DATEADD('DAY', -3, CURRENT_TIMESTAMP), DATEADD('DAY', -3, CURRENT_TIMESTAMP), 0),
(9, 1, DATEADD('DAY', -3, DATEADD('HOUR', -1, CURRENT_TIMESTAMP)), DATEADD('DAY', -3, DATEADD('MINUTE', -35, CURRENT_TIMESTAMP)), 25, '编写API接口', DATEADD('DAY', -3, CURRENT_TIMESTAMP), DATEADD('DAY', -3, CURRENT_TIMESTAMP), 0);

-- 4天前的数据
INSERT INTO focus_sessions (id, user_id, start_time, end_time, duration_minutes, task_description, created_at, updated_at, version) VALUES 
(10, 1, DATEADD('DAY', -4, DATEADD('HOUR', -2, CURRENT_TIMESTAMP)), DATEADD('DAY', -4, DATEADD('HOUR', -1, DATEADD('MINUTE', -35, CURRENT_TIMESTAMP))), 25, '学习前端开发', DATEADD('DAY', -4, CURRENT_TIMESTAMP), DATEADD('DAY', -4, CURRENT_TIMESTAMP), 0);

-- 5天前的数据
INSERT INTO focus_sessions (id, user_id, start_time, end_time, duration_minutes, task_description, created_at, updated_at, version) VALUES 
(11, 1, DATEADD('DAY', -5, DATEADD('HOUR', -3, CURRENT_TIMESTAMP)), DATEADD('DAY', -5, DATEADD('HOUR', -2, DATEADD('MINUTE', -35, CURRENT_TIMESTAMP))), 25, '系统架构设计', DATEADD('DAY', -5, CURRENT_TIMESTAMP), DATEADD('DAY', -5, CURRENT_TIMESTAMP), 0),
(12, 1, DATEADD('DAY', -5, DATEADD('HOUR', -1, CURRENT_TIMESTAMP)), DATEADD('DAY', -5, DATEADD('MINUTE', -35, CURRENT_TIMESTAMP)), 25, '代码重构', DATEADD('DAY', -5, CURRENT_TIMESTAMP), DATEADD('DAY', -5, CURRENT_TIMESTAMP), 0);

-- 6天前的数据
INSERT INTO focus_sessions (id, user_id, start_time, end_time, duration_minutes, task_description, created_at, updated_at, version) VALUES 
(13, 1, DATEADD('DAY', -6, DATEADD('HOUR', -2, CURRENT_TIMESTAMP)), DATEADD('DAY', -6, DATEADD('HOUR', -1, DATEADD('MINUTE', -35, CURRENT_TIMESTAMP))), 25, '性能优化', DATEADD('DAY', -6, CURRENT_TIMESTAMP), DATEADD('DAY', -6, CURRENT_TIMESTAMP), 0);

-- 一周前的数据
INSERT INTO focus_sessions (id, user_id, start_time, end_time, duration_minutes, task_description, created_at, updated_at, version) VALUES 
(14, 1, DATEADD('DAY', -7, DATEADD('HOUR', -4, CURRENT_TIMESTAMP)), DATEADD('DAY', -7, DATEADD('HOUR', -3, DATEADD('MINUTE', -35, CURRENT_TIMESTAMP))), 25, '需求分析', DATEADD('DAY', -7, CURRENT_TIMESTAMP), DATEADD('DAY', -7, CURRENT_TIMESTAMP), 0),
(15, 1, DATEADD('DAY', -7, DATEADD('HOUR', -2, CURRENT_TIMESTAMP)), DATEADD('DAY', -7, DATEADD('HOUR', -1, DATEADD('MINUTE', -35, CURRENT_TIMESTAMP))), 25, '技术调研', DATEADD('DAY', -7, CURRENT_TIMESTAMP), DATEADD('DAY', -7, CURRENT_TIMESTAMP), 0);

-- 更早的一些数据（用于统计历史数据）
INSERT INTO focus_sessions (id, user_id, start_time, end_time, duration_minutes, task_description, created_at, updated_at, version) VALUES 
(16, 1, DATEADD('DAY', -10, DATEADD('HOUR', -2, CURRENT_TIMESTAMP)), DATEADD('DAY', -10, DATEADD('HOUR', -1, DATEADD('MINUTE', -35, CURRENT_TIMESTAMP))), 25, '项目启动会议', DATEADD('DAY', -10, CURRENT_TIMESTAMP), DATEADD('DAY', -10, CURRENT_TIMESTAMP), 0),
(17, 1, DATEADD('DAY', -12, DATEADD('HOUR', -3, CURRENT_TIMESTAMP)), DATEADD('DAY', -12, DATEADD('HOUR', -2, DATEADD('MINUTE', -35, CURRENT_TIMESTAMP))), 25, '环境搭建', DATEADD('DAY', -12, CURRENT_TIMESTAMP), DATEADD('DAY', -12, CURRENT_TIMESTAMP), 0),
(18, 1, DATEADD('DAY', -15, DATEADD('HOUR', -1, CURRENT_TIMESTAMP)), DATEADD('DAY', -15, DATEADD('MINUTE', -35, CURRENT_TIMESTAMP)), 25, '学习新技术', DATEADD('DAY', -15, CURRENT_TIMESTAMP), DATEADD('DAY', -15, CURRENT_TIMESTAMP), 0),
(19, 1, DATEADD('DAY', -18, DATEADD('HOUR', -2, CURRENT_TIMESTAMP)), DATEADD('DAY', -18, DATEADD('HOUR', -1, DATEADD('MINUTE', -35, CURRENT_TIMESTAMP))), 25, '代码审查', DATEADD('DAY', -18, CURRENT_TIMESTAMP), DATEADD('DAY', -18, CURRENT_TIMESTAMP), 0),
(20, 1, DATEADD('DAY', -20, DATEADD('HOUR', -3, CURRENT_TIMESTAMP)), DATEADD('DAY', -20, DATEADD('HOUR', -2, DATEADD('MINUTE', -35, CURRENT_TIMESTAMP))), 25, '测试用例编写', DATEADD('DAY', -20, CURRENT_TIMESTAMP), DATEADD('DAY', -20, CURRENT_TIMESTAMP), 0);

-- 设置序列的下一个值
ALTER SEQUENCE USERS_SEQ RESTART WITH 2;
ALTER SEQUENCE FOCUS_SESSIONS_SEQ RESTART WITH 21;
ALTER SEQUENCE TODO_ITEMS_SEQ RESTART WITH 6;
ALTER SEQUENCE TODO_COLLECTIONS_SEQ RESTART WITH 4;
ALTER SEQUENCE TODO_COLLECTION_ITEMS_SEQ RESTART WITH 9;