# Docker 镜像加速器配置指南

## 问题说明

您遇到的错误：
```
Error response from daemon: failed to resolve reference "docker.io/library/mysql:8.0"
```

这是因为Docker Hub在国内访问较慢或被墙，需要配置镜像加速器。

---

## 🚀 解决方案（3选1）

### 方案1：使用阿里云镜像加速器（推荐）⭐

#### 步骤：

1. **获取加速器地址**
   - 访问：https://cr.console.aliyun.com/
   - 登录后点击左侧 "镜像加速器"
   - 复制您的专属加速器地址（格式：`https://xxxxx.mirror.aliyuncs.com`）

2. **配置Docker Desktop**
   - 打开 Docker Desktop
   - 点击右上角齿轮图标 ⚙️（Settings）
   - 选择 "Docker Engine"
   - 在JSON配置中添加 `"registry-mirrors"` 字段

3. **修改配置文件**
   
   找到并编辑文件：`C:\Users\你的用户名\.docker\daemon.json`
   
   或者在Docker Desktop中直接编辑：
   ```json
   {
     "registry-mirrors": [
       "https://xxxxx.mirror.aliyuncs.com"
     ],
     "insecure-registries": [],
     "debug": false,
     "experimental": false
   }
   ```
   
   > 将 `https://xxxxx.mirror.aliyuncs.com` 替换为你的实际加速器地址

4. **重启Docker**
   - 点击 "Apply & Restart"
   - 等待Docker重启完成

5. **验证配置**
   ```powershell
   docker info
   ```
   查看输出中是否有 "Registry Mirrors" 字段

---

### 方案2：使用多个公共镜像源

如果不想注册阿里云，可以使用以下公共镜像源：

编辑 `C:\Users\你的用户名\.docker\daemon.json`：

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

然后重启Docker Desktop。

---

### 方案3：手动下载镜像（备用方案）

如果以上方法都不行，可以手动下载：

```powershell
# 方法1：从其他镜像站拉取
docker pull docker.m.daocloud.io/library/mysql:8.0
docker tag docker.m.daocloud.io/library/mysql:8.0 mysql:8.0

# 方法2：使用代理（如果有）
# 在Docker Desktop设置中配置HTTP/HTTPS代理
```

---

## ✅ 验证配置

配置完成后，执行以下命令测试：

```powershell
# 1. 检查Docker信息
docker info | Select-String "Registry Mirrors"

# 2. 尝试拉取镜像
docker pull mysql:8.0

# 3. 启动容器
cd "d:\Practical Training\6.12\application"
docker-compose up -d

# 4. 查看状态
docker-compose ps
```

---

## 🔧 常见问题

### Q1: 找不到 daemon.json 文件？

**解决：**
```powershell
# 创建配置文件
New-Item -Path "$env:USERPROFILE\.docker\daemon.json" -ItemType File -Force

# 然后用记事本编辑
notepad "$env:USERPROFILE\.docker\daemon.json"
```

### Q2: 配置后仍然无法拉取？

**解决：**
1. 确认Docker已完全重启
2. 尝试更换其他镜像源
3. 检查防火墙设置
4. 使用手机热点测试（排除网络问题）

### Q3: 如何查看当前使用的镜像源？

```powershell
docker info
```

查找输出中的 "Registry Mirrors" 部分。

### Q4: 镜像拉取很慢？

**解决：**
- 使用阿里云专属加速器（最快）
- 检查网络连接
- 尝试非高峰时段下载

---

## 📝 快速操作脚本

创建一个快速配置脚本 `setup-docker-mirror.ps1`：

```powershell
# 自动配置Docker镜像加速器
$daemonJson = @"
{
  "registry-mirrors": [
    "https://docker.m.daocloud.io",
    "https://dockerproxy.com",
    "https://docker.mirrors.ustc.edu.cn"
  ],
  "insecure-registries": [],
  "debug": false,
  "experimental": false
}
"@

$configPath = "$env:USERPROFILE\.docker\daemon.json"

# 创建目录（如果不存在）
New-Item -Path "$env:USERPROFILE\.docker" -ItemType Directory -Force | Out-Null

# 写入配置
$daemonJson | Out-File -FilePath $configPath -Encoding UTF8

Write-Host "Docker mirror configured!" -ForegroundColor Green
Write-Host "Please restart Docker Desktop manually." -ForegroundColor Yellow
```

运行此脚本后，手动重启Docker Desktop即可。

---

## 🎯 推荐配置

对于中国大陆用户，最佳实践：

1. **首选**：阿里云个人专属加速器（稳定、快速）
2. **备选**： DaoCloud + USTC 组合
3. **应急**：手动从国内镜像站下载

---

## 📞 需要帮助？

如果仍然遇到问题：

1. 检查Docker版本：`docker --version`
2. 查看Docker日志：Docker Desktop → Troubleshoot → Get Support
3. 提供错误信息截图

祝您配置成功！🎉
