# DBeaver连接Docker MySQL完整指南

## 📋 前置条件

1. ✅ 已安装 Docker Desktop
2. ✅ 已安装 DBeaver Community Edition（或Enterprise）
3. ✅ 项目中的 docker-compose.yml 已配置完成

---

## 🚀 第一步：启动MySQL容器

### 方法1：使用命令行（推荐）

1. 打开 PowerShell 或 CMD
2. 进入项目目录：
```powershell
cd "d:\Practical Training\6.12\application"
```

3. 启动MySQL容器：
```powershell
docker-compose up -d
```

4. 查看容器状态：
```powershell
docker-compose ps
```

看到以下输出表示成功：
```
NAME                STATUS              PORTS
aicompanion-mysql   Up (healthy)        0.0.0.0:3307->3306/tcp, 33060/tcp
```

### 方法2：使用Docker Desktop图形界面

1. 打开 Docker Desktop
2. 点击 "Containers" 标签
3. 找到 `aicompanion-mysql` 容器
4. 点击播放按钮启动

---

## 🔧 第二步：在DBeaver中创建连接

### 详细步骤：

#### 1. 打开DBeaver
- 双击桌面图标或从开始菜单启动

#### 2. 新建数据库连接
- 点击左上角 **"新建连接"** 按钮（插头图标）
- 或者按快捷键 `Ctrl + N`
- 或者菜单：**数据库 → 新建连接**

#### 3. 选择数据库类型
- 在搜索框输入：`mysql`
- 选择 **MySQL** 图标
- 点击 **"下一步"**

#### 4. 填写连接信息

**主选项卡：**
```
主机: localhost
端口: 3307
数据库: aicompanion
用户名: aicompanion
密码: aicompanion
```

**其他设置（可选）：**
- 连接名称：`AI Companion MySQL`（方便识别）
- 勾选 "保存本地密码"

#### 5. 测试连接
- 点击左下角 **"测试连接"** 按钮
- 如果显示 "连接成功"，说明配置正确 ✅
- 如果失败，请查看下方的"常见问题"部分

#### 6. 完成配置
- 点击 **"完成"** 按钮
- 新连接会出现在左侧"数据库导航"面板中

#### 7. 打开连接
- 双击新建的连接
- 展开可以看到数据库和表

---

## 📊 第三步：执行SQL脚本

### 方法1：通过DBeaver执行

1. 在DBeaver中右键点击 `aicompanion` 数据库
2. 选择 **"SQL编辑器 → 新建SQL脚本"**
3. 复制粘贴 `src/main/resources/sql/sys_user.sql` 的内容
4. 点击执行按钮（绿色三角形）或按 `Ctrl + Enter`

### 方法2：自动初始化（推荐）

SQL脚本已配置为自动执行：
- 文件位置：`src/main/resources/sql/sys_user.sql`
- 首次启动容器时会自动执行
- 无需手动操作

---

## ✅ 验证连接

### 在DBeaver中验证：

1. 展开左侧的数据库连接
2. 展开 `aicompanion` 数据库
3. 展开 "表格" 节点
4. 应该能看到 `sys_user` 表
5. 右键点击表 → "查看数据"
6. 应该能看到3条测试数据

### 在命令行验证：

```powershell
# 进入MySQL容器
docker exec -it aicompanion-mysql mysql -uroot -proot

# 切换到数据库
USE aicompanion;

# 查看所有表
SHOW TABLES;

# 查看用户数据
SELECT * FROM sys_user;

# 退出
EXIT;
```

---

## ⚙️ 常用DBeaver操作

### 1. 查看表结构
- 右键点击表 → "查看表"
- 可以查看字段、索引、外键等信息

### 2. 编辑数据
- 右键点击表 → "查看数据"
- 直接修改单元格内容
- 按 `Ctrl + S` 保存更改

### 3. 执行自定义SQL
- 按 `F3` 打开SQL编辑器
- 编写SQL语句
- 按 `Ctrl + Enter` 执行

### 4. 导出/导入数据
- 右键点击表 → "导出数据" / "导入数据"
- 支持CSV、Excel、SQL等多种格式

### 5. 生成ER图
- 右键点击数据库 → "ER图"
- 可视化查看表关系

---

## ❗ 常见问题及解决方案

### 问题1：连接被拒绝 (Connection refused)

**原因：** MySQL容器未启动或未完全启动

**解决：**
```powershell
# 检查容器状态
docker-compose ps

# 查看日志
docker-compose logs -f mysql

# 等待几秒后重试
```

### 问题2：端口被占用

**错误信息：** `Bind for 0.0.0.0:3306 failed: port is already allocated`

**解决：**
1. 停止占用3306端口的程序
2. 或修改 `docker-compose.yml` 中的端口映射：
```yaml
ports:
  - "3307:3306"  # 改为3307端口
```
3. 重启容器：
```powershell
docker-compose down
docker-compose up -d
```
4. DBeaver连接时使用新端口：`localhost:3307`

### 问题3：认证插件错误

**错误信息：** `Authentication plugin 'caching_sha2_password' cannot be loaded`

**解决：**
在DBeaver连接设置中：
1. 切换到 "驱动属性" 选项卡
2. 找到 `allowPublicKeyRetrieval`
3. 设置为 `true`

或在URL中添加参数：
```
jdbc:mysql://localhost:3306/aicompanion?allowPublicKeyRetrieval=true
```

### 问题4：时区错误

**错误信息：** `The server time zone value is unrecognized`

**解决：**
已在 `docker-compose.yml` 中配置：
```yaml
command:
  - --default-time-zone=+08:00
```

### 问题5：无法看到表

**原因：** SQL脚本未执行

**解决：**
1. 检查 `src/main/resources/sql/sys_user.sql` 是否存在
2. 手动执行SQL脚本（见上文"执行SQL脚本"部分）
3. 或删除容器重新创建：
```powershell
docker-compose down -v
docker-compose up -d
```

### 问题6：密码错误

**解决：**
确认使用的是正确的密码：
- 用户名：`root`
- 密码：`root`

或在 `docker-compose.yml` 中查看配置的密码。

---

## 🔐 安全建议

### 生产环境配置

1. **不要使用默认密码**
   - 修改 `docker-compose.yml` 中的密码
   - 使用强密码（包含大小写字母、数字、特殊字符）

2. **不要暴露3306端口到公网**
   - 仅在开发环境使用端口映射
   - 生产环境使用Docker网络内部通信

3. **使用环境变量文件**
   创建 `.env` 文件：
   ```env
   MYSQL_ROOT_PASSWORD=your_secure_password
   MYSQL_PASSWORD=your_secure_password
   ```
   
   在 `docker-compose.yml` 中引用：
   ```yaml
   environment:
     MYSQL_ROOT_PASSWORD: ${MYSQL_ROOT_PASSWORD}
     MYSQL_PASSWORD: ${MYSQL_PASSWORD}
   ```

4. **添加 .env 到 .gitignore**
   ```
   echo ".env" >> .gitignore
   ```

---

## 📝 快速参考卡片

### Docker命令速查

```powershell
# 启动
docker-compose up -d

# 停止
docker-compose down

# 重启
docker-compose restart

# 查看日志
docker-compose logs -f mysql

# 进入容器
docker exec -it aicompanion-mysql bash

# 查看容器状态
docker-compose ps

# 删除容器和数据卷
docker-compose down -v
```

### DBeaver连接信息

```
主机: localhost
端口: 3307
数据库: aicompanion
用户名: aicompanion
密码: aicompanion
驱动: MySQL 8.0+
```

### 测试账号

```sql
-- 管理员
用户名: admin
密码: 123456

-- 教师
用户名: teacher1
密码: 123456

-- 学生
用户名: student1
密码: 123456
```

---

## 🎯 下一步

连接成功后，您可以：

1. ✅ 运行Spring Boot应用
2. ✅ 测试用户注册/登录API
3. ✅ 在DBeaver中查看数据变化
4. ✅ 学习更多DBeaver高级功能

祝您使用愉快！🎉
