# AI伴学平台后端项目

## 项目概述

这是一个AI伴学平台的后端项目，基于Spring Boot构建，使用MySQL作为数据库存储。

## 环境要求

- JDK 17+
- Maven 3.8+
- Docker (用于运行MySQL数据库)

## 数据库设置

项目使用Docker容器化的MySQL数据库。在运行后端应用之前，请确保数据库容器正在运行：

```bash
# 启动MySQL数据库容器
cd c:\Users\15060\Desktop\work\backend\application
docker-compose up -d
```

数据库将在localhost:3306可用，数据库名称为aicompanion，用户名和密码均为aicompanion。

## 运行项目

### 方法1：使用IDE

1. 在IDE中打开项目
2. 确保Docker中的MySQL容器正在运行
3. 运行AicompanionApplication类的main方法

### 方法2：使用Maven

```bash
# 构建项目
mvn clean package -DskipTests

# 运行项目
java -jar target/application-0.0.1-SNAPSHOT.jar
```

## 数据库结构

数据库包含以下表：

- `sys_user`: 系统用户表
- `skill`: 技能树表
- `user_skill`: 用户技能关联表
- `learning_record`: 学习记录表
- `ai_chat_message`: AI对话记录表

## API文档

启动项目后，可以通过以下URL访问API文档：
- Swagger UI: http://localhost:8080/swagger-ui.html
- API文档: http://localhost:8080/v3/api-docs

## 注意事项

- 项目连接的数据库已经预填充了示例数据
- 数据库容器已配置数据持久化，重启不会丢失数据
- 如果需要重新初始化数据库，可以删除容器卷并重新启动