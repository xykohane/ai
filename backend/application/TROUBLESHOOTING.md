# 🔧 故障排除指南

## 问题1：PowerShell脚本执行错误

### 错误信息：
```
表达式或语句中包含意外的标记"}"
switch 语句的子句中缺少语句块
```

### 原因：
PowerShell脚本编码问题，中文字符导致解析失败。

### ✅ 解决方案：

**已修复！** 脚本已改为英文版本，现在可以正常运行。

如果仍然有问题，尝试：

```powershell
# 方法1：设置执行策略
Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy RemoteSigned -Force

# 方法2：使用Bypass策略运行
powershell -ExecutionPolicy Bypass -File .\start-mysql.ps1

# 方法3：直接在PowerShell中运行命令
docker-compose up -d
```

---

## 问题2：Docker镜像拉取失败 ⭐

### 错误信息：
```
Error response from daemon: failed to resolve reference "docker.io/library/mysql:8.0"
failed to do request: Head "https://registry-1.docker.io/v2/library/mysql/manifests/8.0": EOF
```

### 原因：
Docker Hub在国内访问受限，需要配置镜像加速器。

### ✅ 解决方案（3步）：

#### 步骤1：运行自动配置脚本

```powershell
cd "d:\Practical Training\6.12\application"
.\setup-docker-mirror.ps1
```

这个脚本会自动：
- 创建Docker配置文件
- 添加国内镜像源
- 备份原有配置

#### 步骤2：重启Docker Desktop

1. 右键点击任务栏Docker图标 🐳
2. 选择 **"Restart Docker Desktop"**
3. 等待完全重启（约30秒）

#### 步骤3：验证并启动

```powershell
# 验证镜像配置
docker info | Select-String "Registry Mirrors"

# 应该看到类似输出：
# Registry Mirrors:
#  https://docker.m.daocloud.io/
#  https://dockerproxy.com/
#  ...

# 测试拉取镜像
docker pull mysql:8.0

# 启动MySQL容器
.\start-mysql.ps1
# 选择选项 1
```

### 备选方案：

如果自动脚本不起作用，手动配置：

1. **编辑配置文件**
   ```powershell
   notepad "$env:USERPROFILE\.docker\daemon.json"
   ```

2. **添加以下内容**
   ```json
   {
     "registry-mirrors": [
       "https://docker.m.daocloud.io",
       "https://dockerproxy.com",
       "https://docker.mirrors.ustc.edu.cn",
       "https://hub-mirror.c.163.com"
     ],
     "insecure-registries": [],
     "debug": false,
     "experimental": false
   }
   ```

3. **保存并重启Docker**

4. **阿里云专属加速器（最快）**
   - 访问：https://cr.console.aliyun.com/
   - 获取个人专属加速器地址
   - 替换配置文件中的镜像地址

---

## 问题3：端口被占用

### 错误信息：
```
Bind for 0.0.0.0:3306 failed: port is already allocated
```

### 原因：
3306端口已被其他程序占用（可能是本地安装的MySQL）。

### ✅ 解决方案：

#### 方案1：停止占用端口的程序

```powershell
# 查找占用3306端口的进程
netstat -ano | findstr :3306

# 假设PID是12345，结束进程
taskkill /F /PID 12345
```

#### 方案2：修改Docker端口映射

编辑 `docker-compose.yml`：

```yaml
ports:
  - "3307:3306"  # 改为3307端口
```

然后DBeaver连接时使用端口 **3307**。

---

## 问题4：容器启动后立即退出

### 检查日志：

```powershell
docker-compose logs mysql
```

### 常见原因及解决：

**原因1：数据目录权限问题**
```powershell
# 删除容器和数据卷，重新启动
docker-compose down -v
docker-compose up -d
```

**原因2：配置文件错误**
```powershell
# 检查docker-compose.yml语法
docker-compose config
```

**原因3：内存不足**
- 增加Docker Desktop分配的内存
- Settings → Resources → Memory → 至少2GB

---

## 问题5：DBeaver连接失败

### 错误信息：
```
Connection refused
Communications link failure
```

### ✅ 排查步骤：

#### 1. 检查容器状态
```powershell
docker-compose ps
```

应该看到：
```
NAME                STATUS              PORTS
aicompanion-mysql   Up (healthy)        0.0.0.0:3306->3306/tcp
```

如果状态不是 `Up (healthy)`，等待几秒再试。

#### 2. 检查容器日志
```powershell
docker-compose logs mysql
```

查看是否有错误信息。

#### 3. 测试端口连通性
```powershell
Test-NetConnection localhost -Port 3306
```

应该看到 `TcpTestSucceeded : True`

#### 4. 检查DBeaver配置

确认以下设置：
- 主机：`localhost`（不是127.0.0.1）
- 端口：`3306`
- 数据库：`aicompanion`
- 用户名：`root`
- 密码：`root`

#### 5. 驱动属性设置

在DBeaver连接设置中：
- 切换到 "驱动属性" 标签
- 找到 `allowPublicKeyRetrieval`
- 设置为 `true`

或者在URL中添加：
```
jdbc:mysql://localhost:3306/aicompanion?allowPublicKeyRetrieval=true
```

---

## 问题6：看不到sys_user表

### 原因：
SQL初始化脚本未执行。

### ✅ 解决方案：

#### 方法1：重新创建容器

```powershell
# 删除容器和数据
docker-compose down -v

# 重新启动（会再次执行SQL脚本）
docker-compose up -d

# 等待10秒
Start-Sleep -Seconds 10

# 检查表是否创建
docker exec -it aicompanion-mysql mysql -uroot -proot -e "USE aicompanion; SHOW TABLES;"
```

#### 方法2：手动执行SQL

1. 在DBeaver中打开SQL编辑器
2. 复制 `src/main/resources/sql/sys_user.sql` 的内容
3. 执行SQL

#### 方法3：命令行执行

```powershell
docker exec -i aicompanion-mysql mysql -uroot -proot aicompanion < src/main/resources/sql/sys_user.sql
```

---

## 问题7：时区不正确

### 症状：
查询时间比实际时间少8小时。

### ✅ 解决方案：

已在 `docker-compose.yml` 中配置：

```yaml
command:
  - --default-time-zone=+08:00
```

如果仍然有问题：

```sql
-- 在MySQL中执行
SET GLOBAL time_zone = '+8:00';
SET time_zone = '+8:00';
```

---

## 问题8：中文乱码

### 症状：
插入中文数据后显示为 `???` 或乱码。

### ✅ 解决方案：

已在配置中设置utf8mb4字符集：

```yaml
command:
  - --character-set-server=utf8mb4
  - --collation-server=utf8mb4_unicode_ci
```

验证字符集：

```sql
SHOW VARIABLES LIKE 'character_set%';
SHOW VARIABLES LIKE 'collation%';
```

应该看到：
```
character_set_server = utf8mb4
collation_server = utf8mb4_unicode_ci
```

---

## 问题9：Docker Desktop无法启动

### ✅ 解决方案：

1. **检查Hyper-V是否启用**
   ```powershell
   # 以管理员身份运行PowerShell
   Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Hyper-V -All
   ```

2. **重置Docker**
   - Settings → Troubleshoot → Reset to factory defaults
   - 注意：这会删除所有容器和镜像

3. **重新安装Docker Desktop**
   - 卸载当前版本
   - 从官网下载最新版本：https://www.docker.com/products/docker-desktop

---

## 问题10：磁盘空间不足

### 检查Docker占用空间：

```powershell
docker system df
```

### 清理空间：

```powershell
# 清理未使用的镜像
docker image prune -a

# 清理未使用的容器
docker container prune

# 清理未使用的卷
docker volume prune

# 一键清理所有
docker system prune -a --volumes
```

---

## 📞 获取帮助

如果以上方法都无法解决问题：

1. **收集诊断信息**
   ```powershell
   # Docker版本
   docker --version
   
   # Docker信息
   docker info
   
   # 容器状态
   docker-compose ps
   
   # 容器日志
   docker-compose logs mysql > mysql-logs.txt
   ```

2. **查看详细文档**
   - [Docker镜像配置](./DOCKER_MIRROR_SETUP.md)
   - [DBeaver连接指南](./DBEAVER_CONNECTION_GUIDE.md)
   - [MySQL配置说明](./mysql/README.md)

3. **提供以下信息寻求帮助**
   - 操作系统版本
   - Docker版本
   - 完整的错误信息
   - 已尝试的解决方案

---

## 🎯 快速诊断清单

按顺序检查：

- [ ] Docker Desktop已安装并运行
- [ ] 已配置镜像加速器（中国大陆用户）
- [ ] Docker已重启使配置生效
- [ ] 可以成功拉取镜像：`docker pull mysql:8.0`
- [ ] 容器状态正常：`docker-compose ps`
- [ ] 端口未被占用
- [ ] DBeaver配置正确
- [ ] SQL脚本已执行

全部勾选后，应该可以正常使用！✅

---

祝您问题解决！🎉
