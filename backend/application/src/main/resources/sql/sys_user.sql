-- 设置客户端字符集为utf8mb4，防止中文乱码
SET NAMES utf8mb4;

-- 创建数据库（如果不存在）
CREATE DATABASE IF NOT EXISTS aicompanion DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

USE aicompanion;

-- 创建用户表
CREATE TABLE IF NOT EXISTS sys_user (
    id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '主键ID',
    username VARCHAR(50) NOT NULL UNIQUE COMMENT '用户名',
    password VARCHAR(100) NOT NULL COMMENT '密码',
    nickname VARCHAR(50) COMMENT '昵称',
    email VARCHAR(100) COMMENT '邮箱',
    phone VARCHAR(20) COMMENT '手机号',
    avatar VARCHAR(255) COMMENT '头像URL',
    role VARCHAR(20) DEFAULT 'STUDENT' COMMENT '角色：STUDENT/TEACHER/ADMIN',
    status TINYINT DEFAULT 1 COMMENT '状态：0-禁用，1-正常',
    deleted TINYINT DEFAULT 0 COMMENT '逻辑删除：0-未删除，1-已删除',
    create_time DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    update_time DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    INDEX idx_username (username),
    INDEX idx_email (email),
    INDEX idx_phone (phone)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='用户表';

-- 插入测试数据（可选）
INSERT INTO sys_user (username, password, nickname, email, role, status) VALUES
('admin', 'e10adc3949ba59abbe56e057f20f883e', '管理员', 'admin@example.com', 'ADMIN', 1),
('teacher1', 'e10adc3949ba59abbe56e057f20f883e', '张老师', 'teacher1@example.com', 'TEACHER', 1),
('student1', 'e10adc3949ba59abbe56e057f20f883e', '李同学', 'student1@example.com', 'STUDENT', 1);

-- 说明：测试数据的密码都是 123456 的MD5值
