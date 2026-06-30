# Maven 安装和配置指南

## ❓ 问题说明

运行 `mvn spring-boot:run` 时出现错误：
```
mvn : 无法将"mvn"项识别为 cmdlet、函数、脚本文件或可运行程序的名称
```

这是因为系统中没有安装Maven或未配置环境变量。

---

## ✅ 解决方案（3选1）

### **方案1：安装Maven（推荐）⭐**

#### Windows系统安装步骤：

##### **第1步：下载Maven**

1. 访问官网：https://maven.apache.org/download.cgi
2. 找到 "Binary zip archive" 
3. 下载最新版本（例如：apache-maven-3.9.6-bin.zip）

或直接下载：
```
https://dlcdn.apache.org/maven/maven-3/3.9.6/binaries/apache-maven-3.9.6-bin.zip
```

##### **第2步：解压文件**

1. 创建目录：`C:\Program Files\Apache\`
2. 将下载的zip文件解压到此目录
3. 最终路径应该是：`C:\Program Files\Apache\apache-maven-3.9.6\`

##### **第3步：配置环境变量**

**方法A：图形界面配置（推荐新手）**

1. 右键点击"此电脑" → "属性"
2. 点击"高级系统设置"
3. 点击"环境变量"按钮
4. 在"系统变量"区域，点击"新建"：
   ```
   变量名: MAVEN_HOME
   变量值: C:\Program Files\Apache\apache-maven-3.9.6
   ```
5. 找到"Path"变量，点击"编辑"
6. 点击"新建"，添加：
   ```
   %MAVEN_HOME%\bin
   ```
7. 点击"确定"保存所有设置

**方法B：使用PowerShell配置（需要管理员权限）**

以**管理员身份**打开PowerShell，执行：

```powershell
# 设置MAVEN_HOME环境变量
[Environment]::SetEnvironmentVariable('MAVEN_HOME', 'C:\Program Files\Apache\apache-maven-3.9.6', 'Machine')

# 添加到Path
$oldPath = [Environment]::GetEnvironmentVariable('Path', 'Machine')
$newPath = $oldPath + ';%MAVEN_HOME%\bin'
[Environment]::SetEnvironmentVariable('Path', $newPath, 'Machine')

Write-Host "Maven environment variables configured!" -ForegroundColor Green
Write-Host "Please open a NEW PowerShell window and run: mvn --version" -ForegroundColor Yellow
```

##### **第4步：验证安装**

1. **关闭当前所有PowerShell窗口**
2. 打开一个新的PowerShell窗口
3. 运行：
   ```powershell
   mvn --version
   ```

应该看到类似输出：
```
Apache Maven 3.9.6
Maven home: C:\Program Files\Apache\apache-maven-3.9.6
Java version: 17.0.x
...
```

##### **第5步：运行Spring Boot应用**

```powershell
cd "d:\Practical Training\6.12\application"
mvn spring-boot:run
```

---

### **方案2：使用IDE运行（最简单）⭐⭐**

如果您安装了IntelliJ IDEA或Eclipse，可以直接在IDE中运行，无需配置Maven。

#### **使用 IntelliJ IDEA：**

1. 打开IDEA
2. File → Open → 选择 `d:\Practical Training\6.12\application` 文件夹
3. 等待IDEA导入项目（会自动下载依赖）
4. 找到 `AicompanionApplication.java` 文件
5. 右键点击 → Run 'AicompanionApplication'

或者：
- 右侧Maven面板 → Lifecycle → spring-boot:run → 双击运行

#### **使用 Eclipse：**

1. File → Import → Existing Maven Projects
2. 选择项目目录
3. 右键点击项目 → Run As → Spring Boot App

---

### **方案3：使用Maven Wrapper（临时方案）**

如果不想安装Maven，可以使用Maven Wrapper。

让我帮您初始化Maven Wrapper：

```powershell
# 需要先安装一次Maven来生成wrapper文件
# 或者从其他Maven项目复制以下文件到项目中：
# - mvnw
# - mvnw.cmd
# - .mvn/wrapper/maven-wrapper.jar
# - .mvn/wrapper/maven-wrapper.properties
```

然后运行：
```powershell
.\mvnw spring-boot:run
```

---

## 🔧 常见问题

### Q1: 配置环境变量后仍然找不到mvn？

**解决：**
1. 确保完全关闭所有PowerShell/CMD窗口
2. 打开新的窗口再试
3. 检查环境变量是否正确：
   ```powershell
   echo $env:MAVEN_HOME
   echo $env:Path
   ```

### Q2: Java版本不匹配？

**错误信息：**
```
The specified JRE/JDK does not exist
```

**解决：**
Maven需要JDK 17（根据您的项目配置）。

检查Java版本：
```powershell
java -version
```

如果不是JDK 17，需要：
1. 下载JDK 17：https://www.oracle.com/java/technologies/downloads/#java17
2. 设置JAVA_HOME环境变量

### Q3: Maven下载依赖很慢？

**解决：配置国内镜像源**

编辑文件：`%MAVEN_HOME%\conf\settings.xml`

在 `<mirrors>` 标签内添加：

```xml
<mirror>
  <id>aliyun</id>
  <mirrorOf>central</mirrorOf>
  <name>Aliyun Maven</name>
  <url>https://maven.aliyun.com/repository/public</url>
</mirror>
```

### Q4: 端口8080被占用？

**解决：**

修改 `src/main/resources/application.yml`：

```yaml
server:
  port: 8081  # 改为其他端口
```

或在命令行指定：
```powershell
mvn spring-boot:run -Dspring-boot.run.arguments=--server.port=8081
```

---

## 📝 快速参考

### Maven常用命令

```powershell
# 清理并编译
mvn clean compile

# 打包
mvn clean package

# 运行应用
mvn spring-boot:run

# 跳过测试打包
mvn clean package -DskipTests

# 更新依赖
mvn clean install
```

### 环境变量检查

```powershell
# 检查MAVEN_HOME
echo $env:MAVEN_HOME

# 检查Java版本
java -version

# 检查Maven版本
mvn --version

# 检查Path中是否包含Maven
$env:Path -split ';' | Select-String "maven"
```

---

## 🎯 推荐方案对比

| 方案 | 难度 | 优点 | 缺点 |
|------|------|------|------|
| 安装Maven | 中等 | 一劳永逸，可在任何地方使用 | 需要配置环境变量 |
| 使用IDE | 简单 | 无需配置，功能强大 | 需要安装IDE |
| Maven Wrapper | 简单 | 无需安装Maven | 首次需要生成wrapper文件 |

**推荐：** 
- 初学者 → 使用IDE（方案2）
- 开发者 → 安装Maven（方案1）

---

## 📞 需要帮助？

如果仍然遇到问题：

1. 运行诊断脚本：
   ```powershell
   .\setup-maven.ps1
   ```

2. 提供以下信息：
   - Windows版本
   - Java版本：`java -version`
   - 完整的错误信息

祝您成功！🎉
