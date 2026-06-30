# 注册接口异常场景测试指南

## 📋 测试概述

本文档指导您使用ApiPost对注册接口进行至少3个异常场景的测试。

**接口信息：**
- URL: `http://localhost:8080/api/auth/register`
- Method: `POST`
- Content-Type: `application/json`

---

##  测试场景1：用户名为空

### **测试目的：**
验证当用户名为空时，系统能正确返回参数验证错误。

### **请求配置：**

**Headers:**
```
Content-Type: application/json
```

**Body (JSON):**
```json
{
  "username": "",
  "password": "123456",
  "email": "test@example.com"
}
```

### **预期响应：**
```json
{
  "code": 400,
  "message": "参数验证失败",
  "data": {
    "username": "用户名不能为空"
  }
}
```

### **在ApiPost中操作：**
1. 新建接口或复制现有注册接口
2. 设置URL为 `http://localhost:8080/api/auth/register`
3. Method选择 `POST`
4. Headers添加 `Content-Type: application/json`
5. Body选择raw/JSON，输入上述JSON
6. 点击发送
7. 查看响应是否符合预期

---

## 🧪 测试场景2：密码为空

### **测试目的：**
验证当密码为空时，系统能正确返回参数验证错误。

### **请求配置：**

**Headers:**
```
Content-Type: application/json
```

**Body (JSON):**
```json
{
  "username": "testuser2",
  "password": "",
  "email": "test2@example.com"
}
```

### **预期响应：**
```json
{
  "code": 400,
  "message": "参数验证失败",
  "data": {
    "password": "密码不能为空"
  }
}
```

### **在ApiPost中操作：**
同上，修改Body中的password字段为空字符串。

---

## 🧪 测试场景3：邮箱格式错误

### **测试目的：**
验证当邮箱格式不正确时，系统能正确返回参数验证错误。

### **请求配置：**

**Headers:**
```
Content-Type: application/json
```

**Body (JSON):**
```json
{
  "username": "testuser3",
  "password": "123456",
  "email": "invalid-email"
}
```

### **预期响应：**
```json
{
  "code": 400,
  "message": "参数验证失败",
  "data": {
    "email": "邮箱格式不正确"
  }
}
```

### **其他邮箱格式错误的测试用例：**
- `"email": "test@"` （缺少域名）
- `"email": "@example.com"` （缺少用户名）
- `"email": "test.example.com"` （缺少@符号）
- `"email": "test @ example.com"` （包含空格）

---

## 🧪 额外测试场景（可选）

### **场景4：所有字段都为空**

**Body:**
```json
{
  "username": "",
  "password": "",
  "email": ""
}
```

**预期响应：**
```json
{
  "code": 400,
  "message": "参数验证失败",
  "data": {
    "username": "用户名不能为空",
    "password": "密码不能为空",
    "email": "邮箱不能为空"
  }
}
```

### **场景5：完全不提供某些字段**

**Body:**
```json
{
  "username": "testuser5"
}
```

**预期响应：**
```json
{
  "code": 400,
  "message": "参数验证失败",
  "data": {
    "password": "密码不能为空",
    "email": "邮箱不能为空"
  }
}
```

---

## 📊 测试结果记录表

| 测试编号 | 测试场景 | 请求参数 | 预期结果 | 实际结果 | 状态 |
|---------|---------|---------|---------|---------|------|
| 1 | 用户名为空 | username="" | code=400, 提示用户名不能为空 | | 待测试 |
| 2 | 密码为空 | password="" | code=400, 提示密码不能为空 | | ⏳待测试 |
| 3 | 邮箱格式错误 | email="invalid" | code=400, 提示邮箱格式不正确 | | 待测试 |
| 4 | 全部为空 | 所有字段="" | code=400, 多个错误提示 | | ⏳待测试 |
| 5 | 缺少字段 | 只提供username | code=400, 提示缺失字段 | | ⏳待测试 |

---

##  如何判断测试通过

✅ **测试通过的标准：**
1. HTTP状态码为 `400`（Bad Request）
2. 响应code为 `400`
3. message包含"参数验证失败"
4. data中包含具体的字段错误信息

❌ **测试失败的情况：**
1. 返回了200状态码（说明验证未生效）
2. 返回了500状态码（说明有未处理的异常）
3. 错误提示信息不准确
4. 没有返回具体的字段错误信息

---

## 💡 测试技巧

### **1. 使用ApiPost的集合功能**
- 可以将所有测试用例保存到一个集合中
- 方便批量执行和回归测试

### **2. 使用环境变量**
- 设置baseUrl变量：`http://localhost:8080`
- 在不同环境中快速切换

### **3. 查看IDEA控制台日志**
- 每次测试后，查看IDEA控制台的日志输出
- 应该能看到类似这样的日志：
  ```
  WARN  xxx --- [nio-8080-exec-x] c.a.config.GlobalExceptionHandler : 参数验证失败: {username=用户名不能为空}
  ```

### **4. 断言响应**
- ApiPost支持添加断言
- 可以自动验证响应是否符合预期
- 例如：断言 `code == 400`

---

## 🚀 开始测试

### **步骤1：重启应用**
确保应用已重启以加载最新的异常处理代码

### **步骤2：打开ApiPost**
启动ApiPost软件

### **步骤3：执行测试场景1**
按照上述配置发送第一个测试请求

### **步骤4：记录结果**
将实际响应与预期响应对比，记录到测试表中

### **步骤5：继续其他场景**
依次执行剩余的测试场景

---

## ❓ 常见问题

### **Q1: 返回500错误而不是400？**
**原因：** 全局异常处理器可能没有正确捕获验证异常

**解决：** 
- 确认GlobalExceptionHandler中有`MethodArgumentNotValidException`的处理方法
- 重启应用

### **Q2: 返回200成功？**
**原因：** `@Valid`注解可能没有生效

**解决：**
- 检查Controller方法参数是否有`@Valid`注解
- 确认pom.xml中有`spring-boot-starter-validation`依赖

### **Q3: 错误信息是中文乱码？**
**原因：** 编码问题

**解决：**
- 确保application.yml中配置了UTF-8编码
- 检查IDEA的文件编码设置

---

## 📝 测试报告模板

完成测试后，可以生成如下报告：

```
# 注册接口异常测试报告

测试时间：2026-06-12
测试人员：XXX
测试环境：本地开发环境

## 测试总结
- 总测试数：5
- 通过数：5
- 失败数：0
- 通过率：100%

## 详细结果
1. ✅ 用户名为空 - 通过
2. ✅ 密码为空 - 通过
3. ✅ 邮箱格式错误 - 通过
4. ✅ 全部为空 - 通过
5. ✅ 缺少字段 - 通过

## 发现的问题
无

## 建议
无
```

---

现在开始测试吧！如果遇到任何问题，请告诉我具体的错误信息。😊
