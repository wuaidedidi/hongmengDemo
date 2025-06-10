-- 简化版数据初始化脚本
-- 修正字段名与实体类保持一致

-- 清理可能存在的冲突数据
DELETE FROM todo_collection_items WHERE id <= 10;
DELETE FROM todo_collections WHERE id <= 5;  
DELETE FROM todo_items WHERE id <= 10;
DELETE FROM focus_sessions WHERE id <= 25;
DELETE FROM users WHERE id <= 5;

-- 插入测试用户（用户名：大白兔，密码：7758258）
INSERT INTO users (id, username, password, created_at, updated_at) VALUES 
(1, '大白兔', '$2a$10$N9qo8uLOickgx2ZMRZoMye.IjZGgzJg7fQZm7W91NQeQvl9FLGW1O', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);

-- 插入待办合集数据（使用正确的字段名）
INSERT INTO todo_collections (id, user_id, title, description, is_sequence_active, current_task_index, create_time) VALUES 
(1, 1, '学习计划', '系统性学习新技术的计划', false, -1, CURRENT_TIMESTAMP),
(2, 1, '项目开发', '当前项目的开发任务', false, -1, CURRENT_TIMESTAMP),
(3, 1, '生活安排', '日常生活相关的待办事项', false, -1, CURRENT_TIMESTAMP);

-- 插入待办合集项目数据（使用正确的字段名）
INSERT INTO todo_collection_items (id, collection_id, title, description, duration_minutes, is_completed, order_index, create_time) VALUES 
(1, 1, 'ArkTS语法学习', '学习ArkTS的基础语法和特性', 60, false, 0, CURRENT_TIMESTAMP),
(2, 1, 'UI组件使用', '掌握HarmonyOS的UI组件库', 45, false, 1, CURRENT_TIMESTAMP),
(3, 1, '网络请求处理', '学习HTTP请求和数据处理', 30, true, 2, CURRENT_TIMESTAMP),
(4, 2, 'API设计', '设计RESTful API接口', 90, true, 0, CURRENT_TIMESTAMP),
(5, 2, '前端页面开发', '开发用户界面页面', 120, false, 1, CURRENT_TIMESTAMP),
(6, 2, '数据库设计', '设计应用的数据存储结构', 60, true, 2, CURRENT_TIMESTAMP),
(7, 3, '买菜购物', '购买本周所需的生活用品', 30, false, 0, CURRENT_TIMESTAMP),
(8, 3, '健身运动', '每周至少3次运动锻炼', 60, false, 1, CURRENT_TIMESTAMP);

-- 插入待办事项数据（使用正确的字段名）
INSERT INTO todo_items (id, user_id, title, description, type, duration, is_completed, is_important, is_urgent, create_time) VALUES 
(1, 1, '学习HarmonyOS开发', '深入学习HarmonyOS应用开发技术', 'STUDY', 60, false, true, false, CURRENT_TIMESTAMP),
(2, 1, '完成项目文档', '编写项目的技术文档和用户手册', 'WORK', 90, false, false, true, CURRENT_TIMESTAMP),
(3, 1, '代码重构', '优化现有代码结构，提高代码质量', 'WORK', 120, false, false, false, CURRENT_TIMESTAMP),
(4, 1, '测试用例编写', '为核心功能编写单元测试', 'WORK', 45, true, true, false, CURRENT_TIMESTAMP),
(5, 1, '性能优化', '分析和优化应用性能瓶颈', 'WORK', 90, false, false, true, CURRENT_TIMESTAMP);

-- 插入近期的专注会话数据（字段名已正确）
INSERT INTO focus_sessions (id, user_id, start_time, end_time, duration_minutes, task_description, created_at, updated_at, version) VALUES 
(1, 1, DATEADD('HOUR', -2, CURRENT_TIMESTAMP), DATEADD('MINUTE', -95, CURRENT_TIMESTAMP), 25, '学习Spring Boot开发', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, 0),
(2, 1, DATEADD('HOUR', -1, CURRENT_TIMESTAMP), DATEADD('MINUTE', -35, CURRENT_TIMESTAMP), 25, '复习数据库知识', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, 0),
(3, 1, DATEADD('DAY', -1, DATEADD('HOUR', -3, CURRENT_TIMESTAMP)), DATEADD('DAY', -1, DATEADD('HOUR', -2, DATEADD('MINUTE', -35, CURRENT_TIMESTAMP))), 25, '阅读技术文档', DATEADD('DAY', -1, CURRENT_TIMESTAMP), DATEADD('DAY', -1, CURRENT_TIMESTAMP), 0),
(4, 1, DATEADD('DAY', -1, DATEADD('HOUR', -1, CURRENT_TIMESTAMP)), DATEADD('DAY', -1, DATEADD('MINUTE', -35, CURRENT_TIMESTAMP)), 25, '编写代码练习', DATEADD('DAY', -1, CURRENT_TIMESTAMP), DATEADD('DAY', -1, CURRENT_TIMESTAMP), 0),
(5, 1, DATEADD('DAY', -2, DATEADD('HOUR', -4, CURRENT_TIMESTAMP)), DATEADD('DAY', -2, DATEADD('HOUR', -3, DATEADD('MINUTE', -35, CURRENT_TIMESTAMP))), 25, '学习HarmonyOS开发', DATEADD('DAY', -2, CURRENT_TIMESTAMP), DATEADD('DAY', -2, CURRENT_TIMESTAMP), 0);