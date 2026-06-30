# AI伴学平台数据库环境搭建指南

## 使用Docker创建MySQL数据库

### 1. 启动MySQL容器

```bash
# 进入后端应用目录
cd c:\Users\15060\Desktop\work\backend\application

# 使用docker-compose启动MySQL服务
docker-compose up -d
```

### 2. 验证数据库服务

```bash
# 检查容器状态
docker ps

# 应该能看到类似以下输出：
# CONTAINER ID   IMAGE       COMMAND                  CREATED        STATUS                 PORTS                    NAMES
# xxxxxxxxxx     mysql:8.0   "docker-entrypoint.s…"   xx minutes ago Up xx minutes          0.0.0.0:3306->3306/tcp   aicompanion-mysql
```

### 3. 连接数据库

数据库连接信息如下：

- **主机**: 192.168.1.249 (或根据实际情况调整)
- **端口**: 3306
- **数据库名**: aicompanion
- **用户名**: aicompanion
- **密码**: aicompanion

### 4. 执行数据库脚本

将之前创建的完整数据库脚本导入到数据库中：

```bash
# 使用MySQL客户端连接并执行脚本
mysql -h 192.168.1.249 -u aicompanion -paicompanion aicompanion < complete_ai_learning_platform_schema.sql
```

或者使用图形化工具如DBeaver进行导入。

## 使用DBeaver连接和查看数据库

### 1. 下载和安装DBeaver

访问 https://dbeaver.io/ 下载并安装DBeaver。

### 2. 创建MySQL连接

1. 打开DBeaver
2. 点击"Database"菜单 -> "New Database Connection"
3. 选择"MySQL"数据库类型
4. 点击"Next"

### 3. 配置连接参数

在连接设置中填入以下信息：

- **Server Host**: 192.168.1.249 (或实际IP)
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

## 故障排除

如果遇到连接问题：

1. 确认Docker服务已启动
2. 确认MySQL容器正在运行
3. 检查防火墙设置是否阻止了3306端口
4. 确认IP地址是否正确（可以用`docker inspect`命令查看容器IP）