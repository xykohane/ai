-- AI伴学平台完整数据库设计
-- 根据0624下午教学笔记创建

-- 创建数据库（如果不存在）
CREATE DATABASE IF NOT EXISTS aicompanion DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

USE aicompanion;

-- 1. 用户表（已有，按需调整）
DROP TABLE IF EXISTS sys_user;
CREATE TABLE sys_user (
  id          BIGINT AUTO_INCREMENT PRIMARY KEY,
  username    VARCHAR(50)  NOT NULL UNIQUE COMMENT '用户名',
  password    VARCHAR(100) NOT NULL COMMENT '密码',
  nickname    VARCHAR(50)  DEFAULT '' COMMENT '昵称',
  email       VARCHAR(100) DEFAULT '' COMMENT '邮箱',
  avatar      VARCHAR(255) DEFAULT '' COMMENT '头像',
  role        VARCHAR(20)  DEFAULT 'student' COMMENT '角色：student/admin',
  status      TINYINT      DEFAULT 1 COMMENT '0-禁用 1- 正常',
  deleted     TINYINT      DEFAULT 0 COMMENT '0-正常 1- 已删除',
  create_time DATETIME     DEFAULT CURRENT_TIMESTAMP,
  update_time DATETIME     DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  INDEX idx_status(status),
  INDEX idx_role(role)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='系统用户表';

-- 2. 技能表
DROP TABLE IF EXISTS skill;
CREATE TABLE skill (
  id            BIGINT AUTO_INCREMENT PRIMARY KEY,
  name          VARCHAR(100) NOT NULL COMMENT '技能名称',
  category      VARCHAR(50)  NOT NULL COMMENT '技能类别',
  description   TEXT         DEFAULT NULL COMMENT '技能描述',
  level         TINYINT      DEFAULT 1 COMMENT '难度等级 1-5',
  parent_id     BIGINT       DEFAULT 0 COMMENT '父技能ID,0 顶层 id',
  sort_order    INT          DEFAULT 0 COMMENT '排序',
  create_time   DATETIME     DEFAULT CURRENT_TIMESTAMP,
  INDEX idx_category(category),
  INDEX idx_parent_id(parent_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='技能树表';

-- 3. 用户技能关联表
DROP TABLE IF EXISTS user_skill;
CREATE TABLE user_skill (
  id           BIGINT AUTO_INCREMENT PRIMARY KEY,
  user_id      BIGINT  NOT NULL,
  skill_id     BIGINT  NOT NULL,
  level        TINYINT DEFAULT 0 COMMENT '掌握程度 0-5',
  status       TINYINT DEFAULT 0 COMMENT '0-未开始 1- 学习中 2- 已掌握',
  update_time  DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  UNIQUE KEY uk_user_skill (user_id, skill_id),
  INDEX idx_user_id (user_id),
  INDEX idx_skill_id (skill_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='用户技能关联表';

-- 4. 学习记录表
DROP TABLE IF EXISTS learning_record;
CREATE TABLE learning_record (
  id               BIGINT AUTO_INCREMENT PRIMARY KEY,
  user_id          BIGINT   NOT NULL,
  skill_id         BIGINT   NOT NULL COMMENT '学习资源 ID',
  skill_name       VARCHAR(200) DEFAULT '' COMMENT '资源名称（冗余，减少 JOIN；历史数据快照）',
  progress         INT      DEFAULT 0 COMMENT '进度百分比 0-100',
  study_seconds    INT      DEFAULT 0 COMMENT '累计学习秒数',
  status           TINYINT  DEFAULT 0 COMMENT '0-未开始 1- 学习中 2- 已完成',
  first_study_time DATETIME DEFAULT NULL COMMENT '首次学习时间',
  last_study_time  DATETIME DEFAULT NULL COMMENT '最近学习时间',
  complete_time    DATETIME DEFAULT NULL COMMENT '完成时间',
  create_time      DATETIME DEFAULT CURRENT_TIMESTAMP,
  INDEX idx_user_id (user_id),
  INDEX idx_skill_id (skill_id),
  INDEX idx_user_status (user_id, status)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='学习记录表';

-- 5. AI对话记录表
DROP TABLE IF EXISTS ai_chat_message;
CREATE TABLE ai_chat_message (
  id          BIGINT AUTO_INCREMENT PRIMARY KEY,
  user_id     BIGINT      NOT NULL,
  session_id  VARCHAR(64)  NOT NULL COMMENT '对话会话 ID',
  role        VARCHAR(20)  NOT NULL COMMENT 'user/assistant/system',
  content     TEXT        NOT NULL COMMENT '消息内容',
  model       VARCHAR(50)  DEFAULT '' COMMENT '使用的模型',
  tokens_used INT         DEFAULT 0 COMMENT '消耗Token 数',
  create_time DATETIME    DEFAULT CURRENT_TIMESTAMP,
  INDEX idx_user_session (user_id, session_id),
  INDEX idx_create_time (create_time)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='AI对话记录表';

-- 插入测试数据

-- 用户测试数据
INSERT INTO sys_user (username, password, nickname, email, role, status) VALUES
('admin', 'e10adc3949ba59abbe56e057f20f883e', '管理员', 'admin@example.com', 'admin', 1),
('student1', 'e10adc3949ba59abbe56e057f20f883e', '学生1', 'student1@example.com', 'student', 1),
('student2', 'e10adc3949ba59abbe56e057f20f883e', '学生2', 'student2@example.com', 'student', 1),
('teacher1', 'e10adc3949ba59abbe56e057f20f883e', '教师1', 'teacher1@example.com', 'admin', 1),
('student3', 'e10adc3949ba59abbe56e057f20f883e', '学生3', 'student3@example.com', 'student', 1);

-- 技能测试数据
INSERT INTO skill (name, category, description, level, parent_id, sort_order) VALUES
('Java', '编程语言', 'Java编程语言基础', 1, 0, 1),
('JavaSE', '编程语言', 'Java SE核心知识', 2, 1, 1),
('JavaWeb', '编程语言', 'Java Web开发技术', 3, 1, 2),
('Spring', '框架', 'Spring框架', 3, 1, 3),
('SpringBoot', '框架', 'Spring Boot框架', 4, 4, 1),
('SpringCloud', '框架', 'Spring Cloud微服务', 5, 4, 2),
('MySQL', '数据库', 'MySQL数据库', 3, 0, 2),
('Vue', '前端', 'Vue前端框架', 3, 0, 3),
('OS', '系统', '操作系统', 2, 0, 4);

-- 用户技能关联测试数据
INSERT INTO user_skill (user_id, skill_id, level, status) VALUES
(2, 1, 3, 2),  -- student1 学习 Java，掌握程度3，已完成
(2, 2, 2, 2),  -- student1 学习 JavaSE，掌握程度2，已完成
(2, 4, 1, 1),  -- student1 学习 Spring，掌握程度1，学习中
(3, 1, 4, 2),  -- student2 学习 Java，掌握程度4，已完成
(3, 7, 3, 2),  -- student2 学习 MySQL，掌握程度3，已完成
(4, 1, 5, 2);  -- teacher1 学习 Java，掌握程度5，已完成

-- 学习记录测试数据
INSERT INTO learning_record (user_id, skill_id, skill_name, progress, study_seconds, status, first_study_time, last_study_time) VALUES
(2, 1, 'Java', 100, 3600, 2, '2024-06-20 10:00:00', '2024-06-22 15:00:00'),
(2, 2, 'JavaSE', 100, 7200, 2, '2024-06-21 10:00:00', '2024-06-23 14:00:00'),
(2, 4, 'Spring', 60, 1800, 1, '2024-06-24 09:00:00', '2024-06-24 12:00:00'),
(3, 1, 'Java', 100, 5400, 2, '2024-06-19 11:00:00', '2024-06-21 16:00:00'),
(3, 7, 'MySQL', 100, 2700, 2, '2024-06-20 14:00:00', '2024-06-22 10:00:00'),
(4, 1, 'Java', 100, 10800, 2, '2024-06-18 09:00:00', '2024-06-20 17:00:00');

-- AI对话记录测试数据
INSERT INTO ai_chat_message (user_id, session_id, role, content, model, tokens_used) VALUES
(2, 'session_001', 'user', '请解释一下Java中的封装概念', 'gpt-4', 20),
(2, 'session_001', 'assistant', '封装是面向对象编程的重要特性之一...', 'gpt-4', 150),
(3, 'session_002', 'user', '如何在Spring Boot中配置数据库连接？', 'gpt-4', 25),
(3, 'session_002', 'assistant', '在application.properties或application.yml文件中配置...', 'gpt-4', 200),
(2, 'session_003', 'user', 'Java中的垃圾回收机制是什么？', 'claude', 22),
(2, 'session_003', 'assistant', 'Java的垃圾回收机制是自动内存管理的重要组成部分...', 'claude', 180);

-- 验证表结构和索引
-- 用户表结构验证
DESC sys_user;
SHOW INDEX FROM sys_user;

-- 技能表结构验证
DESC skill;
SHOW INDEX FROM skill;

-- 用户技能关联表结构验证
DESC user_skill;
SHOW INDEX FROM user_skill;

-- 学习记录表结构验证
DESC learning_record;
SHOW INDEX FROM learning_record;

-- AI对话记录表结构验证
DESC ai_chat_message;
SHOW INDEX FROM ai_chat_message;

-- 课堂练习4：查找某个用户"学习中"的所有技能名称和进度
SELECT 
    lr.skill_name,
    lr.progress,
    lr.status
FROM learning_record lr
WHERE lr.user_id = 2 AND lr.status = 1;

-- 课堂练习5：统计每个技能类别下有多少用户在学习
SELECT 
    s.category AS skill_category,
    COUNT(DISTINCT lr.user_id) AS learning_users_count
FROM skill s
JOIN learning_record lr ON s.id = lr.skill_id
WHERE lr.status IN (1, 2) -- 学习中或已完成
GROUP BY s.category;
