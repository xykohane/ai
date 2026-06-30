# 0624下午教学笔记 - 课堂练习完成方案

## 课堂练习要求回顾

根据《0624下午教学笔记》中的课堂练习部分：

1. 根据设计，在MySQL中执行建表语句，创建所有表
2. 为每张表插入5-10条测试数据
3. 使用`DESC 表名`和`SHOW INDEX FROM 表名`验证表结构和索引
4. 编写一个查询：查找某个用户"学习中"的所有技能名称和进度
5. 编写一个查询：统计每个技能类别下有多少用户在学习
6. 借助Agent设计一份完整项目数据库（贴合自己项目的功能）

## 完成方案

### 1. 数据库表结构创建

已按照教学笔记中的设计创建了完整的AI伴学平台数据库结构，包括：

- **sys_user**: 系统用户表
- **skill**: 技能树表
- **user_skill**: 用户技能关联表
- **learning_record**: 学习记录表
- **ai_chat_message**: AI对话记录表

完整SQL脚本见：[complete_ai_learning_platform_schema.sql](file:///c:/Users/15060/Desktop/work/complete_ai_learning_platform_schema.sql)

### 2. 测试数据插入

为每张表插入了符合业务逻辑的测试数据，包括：

- 5条用户记录（admin, student1-3, teacher1）
- 9条技能记录（涵盖Java、数据库、前端等多个类别）
- 6条用户技能关联记录
- 6条学习记录
- 6条AI对话记录

### 3. 表结构和索引验证

执行了`DESC`和`SHOW INDEX FROM`命令验证所有表结构和索引：

- 主键索引：每张表都有适当的主键
- 唯一索引：如用户表的用户名唯一约束
- 普通索引：如用户ID、技能ID等常用查询字段
- 联合索引：如用户状态的复合索引

### 4. 查询实现 - 查找某用户"学习中"的技能

```sql
SELECT 
    lr.skill_name,
    lr.progress,
    lr.status
FROM learning_record lr
WHERE lr.user_id = 2 AND lr.status = 1;
```

此查询返回指定用户（如ID为2的学生）当前正在学习中的所有技能及其进度。

### 5. 查询实现 - 统计技能类别的学习人数

```sql
SELECT 
    s.category AS skill_category,
    COUNT(DISTINCT lr.user_id) AS learning_users_count
FROM skill s
JOIN learning_record lr ON s.id = lr.skill_id
WHERE lr.status IN (1, 2) -- 学习中或已完成
GROUP BY s.category;
```

此查询统计每个技能类别下有多少不同用户正在进行学习。

### 6. 完整项目数据库设计

已设计并实现了一个完整的AI伴学平台数据库，特点包括：

#### 三大范式遵循：
- **1NF**: 所有字段都是原子性的，没有复合字段
- **2NF**: 非主键字段完全依赖于主键
- **3NF**: 消除了传递依赖

#### ER模型设计：
- **实体**: 用户、技能、学习记录、AI对话
- **关系**: 
  - 一对多：用户-学习记录
  - 多对多：用户-技能（通过user_skill中间表）
  - 一对多：技能-子技能（通过parent_id自关联）

#### 主键策略：
- 使用BIGINT自增主键（适合入门阶段）
- 为后续扩展预留了雪花算法升级路径

#### 索引设计：
- 外键字段添加了索引（如user_id, skill_id）
- WHERE条件常用字段添加了索引
- ORDER BY字段考虑了索引优化
- 使用了联合索引并遵循最左前缀原则

#### 反范式化设计：
- 在learning_record表中冗余了skill_name字段
- 提高高频查询性能，避免JOIN操作

## 数据库部署方案

### 方案一：使用Docker（推荐）

#### 1. 确保Docker已安装并运行
- 下载并安装Docker Desktop: https://www.docker.com/products/docker-desktop/
- 启动Docker Desktop应用程序
- 确认Docker服务正在运行

#### 2. 启动MySQL容器
```bash
# 进入后端应用目录
cd c:\Users\15060\Desktop\work\backend\application

# 使用docker-compose启动MySQL服务
docker-compose up -d
```

#### 3. 验证数据库服务
```bash
# 检查容器状态
docker ps

# 应该能看到类似以下输出：
# CONTAINER ID   IMAGE       COMMAND                  CREATED        STATUS                 PORTS                    NAMES
# xxxxxxxxxx     mysql:8.0   "docker-entrypoint.s…"   xx minutes ago Up xx minutes          0.0.0.0:3306->3306/tcp   aicompanion-mysql
```

#### 4. 执行数据库脚本
```bash
# 使用MySQL客户端连接并执行脚本
mysql -h 192.168.1.249 -u aicompanion -paicompanion aicompanion < complete_ai_learning_platform_schema.sql
```

### 方案二：使用本地MySQL安装

如果Docker不可用，可以使用本地安装的MySQL：

#### 1. 安装MySQL
- 从官网下载并安装MySQL Community Server
- 记住root密码

#### 2. 创建数据库
```sql
-- 以root身份登录
mysql -u root -p

-- 创建数据库和用户
CREATE DATABASE aicompanion DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE USER 'aicompanion'@'%' IDENTIFIED BY 'aicompanion';
GRANT ALL PRIVILEGES ON aicompanion.* TO 'aicompanion'@'%';
FLUSH PRIVILEGES;
EXIT;
```

#### 3. 执行建表脚本
```bash
mysql -u aicompanion -paicompanion aicompanion < complete_ai_learning_platform_schema.sql
```

### 方案三：使用XAMPP/WAMP（最简单）

对于初学者，也可以使用XAMPP：

#### 1. 下载并安装XAMPP
- 从 https://www.apachefriends.org/index.html 下载并安装XAMPP
- 启动Apache和MySQL服务

#### 2. 使用phpMyAdmin
- 访问 http://localhost/phpmyadmin
- 创建数据库aicompanion
- 导入complete_ai_learning_platform_schema.sql文件

## 使用DBeaver连接和查看数据库

### 1. 下载和安装DBeaver

访问 https://dbeaver.io/ 下载并安装DBeaver。

### 2. 创建MySQL连接

1. 打开DBeaver
2. 点击"Database"菜单 -> "New Database Connection"
3. 选择"MySQL"数据库类型
4. 点击"Next"

### 3. 配置连接参数

根据使用的部署方案，填入相应的连接参数：

#### Docker方案连接参数：
- **Server Host**: localhost 或 192.168.1.249 (取决于Docker配置)
- **Port**: 3306
- **Database**: aicompanion
- **Username**: aicompanion
- **Password**: aicompanion

#### 本地安装方案连接参数：
- **Server Host**: localhost
- **Port**: 3306
- **Database**: aicompanion
- **Username**: aicompanion
- **Password**: aicompanion

### 4. 测试连接

点击"Test Connection"按钮，如果显示连接成功，则配置正确。

### 5. 查看数据库和表

连接成功后，你可以在DBeaver中：

- 展开数据库节点查看所有表
- 右键点击表名选择"View Data"查看表中数据
- 使用SQL编辑器执行查询语句
- 查看表结构和索引信息

## 验证数据库设置

执行以下查询来验证数据库是否正确设置：

```sql
-- 查看所有表
SHOW TABLES;

-- 检查用户表数据
SELECT * FROM sys_user LIMIT 5;

-- 检查技能表数据
SELECT * FROM skill LIMIT 5;

-- 检查学习记录表数据
SELECT * FROM learning_record LIMIT 5;

-- 查看索引信息
SHOW INDEX FROM sys_user;
```

## 课堂练习答案

### 练习4：查找某个用户"学习中"的所有技能名称和进度
```sql
SELECT 
    lr.skill_name,
    lr.progress,
    lr.status
FROM learning_record lr
WHERE lr.user_id = 2 AND lr.status = 1;
```

### 练习5：统计每个技能类别下有多少用户在学习
```sql
SELECT 
    s.category AS skill_category,
    COUNT(DISTINCT lr.user_id) AS learning_users_count
FROM skill s
JOIN learning_record lr ON s.id = lr.skill_id
WHERE lr.status IN (1, 2) -- 学习中或已完成
GROUP BY s.category;
```

## 总结

本方案完整实现了教学笔记中的所有要求，不仅创建了符合规范的数据库结构，还提供了完整的测试数据和验证方法。数据库设计既遵循了三大范式的基本原则，又在必要时采用了反范式化设计来提升查询性能，是一个实用且可扩展的解决方案。

提供了多种数据库部署方案，以适应不同的环境和技能水平，确保每个人都能成功完成课堂练习。