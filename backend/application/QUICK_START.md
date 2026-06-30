# 🚀 快速开始 - Docker MySQL + DBeaver

## ⚠️ 重要：首次使用前必读

### 如果遇到镜像拉取失败错误：

```
Error response from daemon: failed to resolve reference "docker.io/library/mysql:8.0"
```

**请执行以下步骤：**

1. **运行镜像加速器配置脚本**
   ```powershell
   cd "d:\Practical Training\6.12\application"
   .\setup-docker-mirror.ps1
   ```

2. **重启 Docker Desktop**
   - 右键点击任务栏Docker图标
   - 选择 "Restart Docker Desktop"
   - 等待完全重启

3. **验证配置**
   ```powershell
   docker info | Select-String "Registry Mirrors"
   ```

4. **重新尝试启动**
   ```powershell
   .\start-mysql.ps1
   # 选择选项 1
   ```

详细配置指南：[DOCKER_MIRROR_SETUP.md](./DOCKER_MIRROR_SETUP.md)

---

## ⚡ 三步快速启动

### 第一步：启动MySQL容器

**方法1：使用快速启动脚本（推荐）**
```powershell
cd "d:\Practical Training\6.12\application"
.\start-mysql.ps1
# 选择选项 1 - 启动MySQL容器
```

**方法2：手动启动**
```powershell
cd "d:\Practical Training\6.12\application"
docker-compose up -d
```

### 第二步：等待初始化（约5-10秒）

查看容器状态：
```powershell
docker-compose ps
```

看到 `healthy` 状态表示就绪 ✅

### 第三步：在DBeaver中连接

1. 打开 DBeaver
2. 新建连接 → 选择 MySQL
3. 填写连接信息：
   ```
   主机: localhost
   端口: 3306
   数据库: aicompanion
   用户名: root
   密码: root
   ```
4. 点击"测试连接"
5. 点击"完成"

---

## 📊 验证数据

连接成功后，您应该能看到：
- 数据库：`aicompanion`
- 表：`sys_user`
- 测试数据：3条记录（admin, teacher1, student1）

---

## 🔧 常用命令

```powershell
# 启动
docker-compose up -d

# 停止
docker-compose down

# 查看日志
docker-compose logs -f mysql

# 重启
docker-compose restart

# 进入MySQL命令行
docker exec -it aicompanion-mysql mysql -uroot -proot
```

---

## 📝 数据库信息

| 项目 | 值 |
|------|-----|
| 主机 | localhost |
| 端口 | 3306 |
| 数据库名 | aicompanion |
| Root用户 | root / root |
| 普通用户 | aicompanion / aicompanion |

---

## ❓ 遇到问题？

查看详细指南：[DBEAVER_CONNECTION_GUIDE.md](./DBEAVER_CONNECTION_GUIDE.md)

常见问题速查：

**Q: 连接被拒绝？**
```powershell
# 检查容器是否运行
docker-compose ps
# 查看日志
docker-compose logs mysql
```

**Q: 端口被占用？**
修改 `docker-compose.yml` 中的端口为 `3307:3306`

**Q: 看不到表？**
SQL脚本会自动执行，或手动执行 `src/main/resources/sql/sys_user.sql`

---

## 🎯 下一步

### 运行Spring Boot应用

**前提条件：** 需要安装Maven或使用IDE

#### 方法1：使用Maven命令行

如果已安装Maven：
```powershell
cd "d:\Practical Training\6.12\application"
mvn spring-boot:run
```

如果未安装Maven，请先查看：[MAVEN_INSTALL_GUIDE.md](./MAVEN_INSTALL_GUIDE.md)

#### 方法2：使用IDE（推荐新手）

**IntelliJ IDEA:**
1. File → Open → 选择 `application` 文件夹
2. 等待项目导入完成
3. 找到 `AicompanionApplication.java`
4. 右键 → Run 'AicompanionApplication'

**Eclipse:**
1. File → Import → Existing Maven Projects
2. 选择项目目录
3. 右键项目 → Run As → Spring Boot App

#### 方法3：打包后运行

```powershell
# 打包
cd "d:\Practical Training\6.12\application"
mvn clean package -DskipTests

# 运行JAR文件
java -jar target/aicompanion-1.0.0.jar
```

应用启动后，访问：http://localhost:8080

祝开发愉快！🎉
