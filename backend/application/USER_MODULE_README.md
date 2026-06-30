# 用户模块使用说明

## 项目结构

```
com.aicompanion
├── entity/          # 实体类
│   ├── BaseEntity.java
│   └── User.java
├── dto/             # 数据传输对象
│   ├── RegisterDTO.java
│   ├── LoginDTO.java
│   └── UserDTO.java
├── vo/              # 视图对象
│   ├── UserVO.java
│   └── LoginVO.java
├── mapper/          # Mapper接口
│   └── UserMapper.java
├── service/         # 服务层
│   ├── UserService.java
│   └── impl/UserServiceImpl.java
├── controller/      # 控制器
│   ├── AuthController.java
│   └── UserController.java
└── utils/           # 工具类
    └── JwtUtil.java
```

## 数据库初始化

1. 执行 `src/main/resources/sql/sys_user.sql` 文件创建数据库和表
2. 确保 `application.yml` 中的数据库配置正确（用户名、密码）

## API接口说明

### 1. 用户注册

**接口**: `POST /api/auth/register`

**请求体**:
```json
{
  "username": "testuser",
  "password": "123456",
  "email": "test@example.com"
}
```

**响应**:
```json
{
  "code": 200,
  "message": "注册成功",
  "data": null
}
```

### 2. 用户登录

**接口**: `POST /api/auth/login`

**请求体**:
```json
{
  "username": "testuser",
  "password": "123456"
}
```

**响应**:
```json
{
  "code": 200,
  "message": "登录成功",
  "data": {
    "token": "eyJhbGciOiJIUzI1NiJ9...",
    "user": {
      "id": 1,
      "username": "testuser",
      "nickname": null,
      "email": "test@example.com",
      "phone": null,
      "avatar": null,
      "role": "STUDENT",
      "status": 1
    }
  }
}
```

### 3. 获取当前用户信息

**接口**: `GET /api/users/me`

**请求头**:
```
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9...
```

**响应**:
```json
{
  "code": 200,
  "message": "success",
  "data": {
    "id": 1,
    "username": "testuser",
    "nickname": "测试用户",
    "email": "test@example.com",
    "phone": "13800138000",
    "avatar": "https://example.com/avatar.jpg",
    "role": "STUDENT",
    "status": 1
  }
}
```

### 4. 更新用户信息

**接口**: `PUT /api/users/{id}`

**请求头**:
```
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9...
```

**请求体**:
```json
{
  "nickname": "新昵称",
  "email": "newemail@example.com",
  "phone": "13800138000",
  "avatar": "https://example.com/new-avatar.jpg"
}
```

**响应**:
```json
{
  "code": 200,
  "message": "更新成功",
  "data": null
}
```

## 功能特性

1. **密码加密**: 使用MD5加密存储密码
2. **JWT认证**: 基于JWT的无状态认证机制
3. **参数校验**: 使用Jakarta Validation进行参数校验
4. **统一响应**: 所有接口使用统一的Result<T>返回格式
5. **角色管理**: 支持STUDENT/TEACHER/ADMIN三种角色
6. **用户状态**: 支持启用/禁用用户账号
7. **逻辑删除**: 使用MyBatis-Plus的逻辑删除功能

## 注意事项

1. 实际项目中建议使用BCrypt替代MD5进行密码加密
2. JWT密钥应该从配置文件读取，而不是硬编码在代码中
3. 可以添加拦截器或过滤器来验证Token的有效性
4. 建议添加全局异常处理器来统一处理异常
