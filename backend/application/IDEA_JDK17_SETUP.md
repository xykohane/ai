# 在IntelliJ IDEA中安装和配置JDK 17完整指南

## ✅ 已完成

- [x] pom.xml已更新为Java 17
- [x] 创建了自动配置脚本

---

## 🚀 快速配置步骤（5分钟完成）

### **第1步：打开IntelliJ IDEA项目设置**

1. 打开IntelliJ IDEA
2. 打开您的项目：`d:\Practical Training\6.12\application`
3. 按快捷键 **`Ctrl + Alt + Shift + S`** 
   - 或者菜单：**File → Project Structure**

---

### **第2步：下载JDK 17（在IDEA内）**

#### **方法A：通过IDEA直接下载（最简单）⭐**

1. 在Project Structure窗口左侧，点击 **"SDKs"**

2. 点击右上角的 **"+"** 按钮

3. 选择 **"Download JDK"**

4. 配置下载选项：
   ```
   Vendor（供应商）: 
     - 推荐选择 "Oracle OpenJDK" 或 "Eclipse Temurin"
   
   Version（版本）: 
     - 选择 "17"
   
   Installation path（安装路径）:
     - 保持默认即可，例如：C:\Users\你的用户名\.jdks\corretto-17.x.x
   ```

5. 点击 **"Download"** 按钮

6. 等待下载完成（大约100-200MB，需要几分钟）

7. 下载完成后会自动添加到SDK列表

#### **方法B：手动下载后添加**

如果网络不好，可以手动下载：

1. **下载JDK 17：**
   - Oracle JDK 17: https://www.oracle.com/java/technologies/downloads/#java17
   - Eclipse Temurin 17: https://adoptium.net/temurin/releases/?version=17
   - Amazon Corretto 17: https://docs.aws.amazon.com/corretto/latest/corretto-17-ug/downloads-list.html

2. **安装到本地：**
   - 运行安装程序
   - 记住安装路径，例如：`C:\Program Files\Java\jdk-17`

3. **在IDEA中添加：**
   - Project Structure → SDKs → "+" → "Add JDK"
   - 浏览到JDK安装目录
   - 点击OK

---

### **第3步：配置项目使用JDK 17**

1. 在Project Structure窗口左侧，点击 **"Project"**

2. 配置以下选项：
   ```
   SDK: 
     - 选择刚才下载的 "17" 或 "corretto-17.x.x"
   
   Language level:
     - 选择 "17 - Sealed types, always-strict floating-point semantics"
   ```

3. 点击 **"Apply"** → **"OK"**

---

### **第4步：配置Maven使用JDK 17**

1. 打开Settings：**File → Settings**（或 `Ctrl + Alt + S`）

2. 导航到：**Build, Execution, Deployment → Build Tools → Maven**

3. 找到 **"Runner"** 子项

4. 在 **"JRE"** 下拉框中选择JDK 17

5. 点击 **"Apply"** → **"OK"**

---

### **第5步：重新加载Maven项目**

1. 在右侧边栏找到 **"Maven"** 面板
   - 如果没有看到，点击菜单：**View → Tool Windows → Maven**

2. 点击刷新按钮 🔄（Reload All Maven Projects）
   - 或者右键点击 `pom.xml` → **"Reload Project"**

3. 等待依赖重新解析完成

---

### **第6步：验证配置**

1. **检查项目SDK：**
   - File → Project Structure → Project
   - 确认SDK显示为 "17" 或 "jdk-17.x.x"

2. **检查模块SDK：**
   - File → Project Structure → Modules
   - 确认所有模块的SDK都是17

3. **运行应用测试：**
   - 打开 `AicompanionApplication.java`
   - 点击绿色三角形 ▶️ Run
   - 查看控制台输出

---

## 📊 配置检查清单

完成以上步骤后，请确认：

- [ ] Project Structure → Project → SDK = 17
- [ ] Project Structure → Project → Language level = 17
- [ ] Settings → Maven → Runner → JRE = 17
- [ ] Maven项目已重新加载
- [ ] pom.xml中 `<java.version>17</java.version>`
- [ ] 应用可以成功启动

---

## ⚠️ 常见问题解决

### Q1: 找不到"Download JDK"选项？

**原因：** IDEA版本较老

**解决：**
- 升级IntelliJ IDEA到最新版本
- 或者使用方法B手动下载JDK 17

---

### Q2: JDK下载很慢或失败？

**解决：**
1. 使用国内镜像源下载JDK
2. 或者手动下载后添加（方法B）
3. 检查网络连接

---

### Q3: 运行时报错 "Unsupported class file major version"？

**原因：** JDK版本不匹配

**解决：**
1. 确认Project SDK是17
2. 确认Module SDK是17
3. 确认Maven Runner JRE是17
4. 重新加载Maven项目
5. File → Invalidate Caches / Restart

---

### Q4: Maven依赖下载失败？

**解决：配置阿里云镜像**

1. 找到Maven配置文件：
   - IDEA内置Maven: `%USERPROFILE%\.m2\settings.xml`
   - 或创建该文件

2. 添加镜像配置：
   ```xml
   <settings>
     <mirrors>
       <mirror>
         <id>aliyun</id>
         <mirrorOf>central</mirrorOf>
         <name>Aliyun Maven</name>
         <url>https://maven.aliyun.com/repository/public</url>
       </mirror>
     </mirrors>
   </settings>
   ```

3. 重新加载Maven项目

---

### Q5: 提示"Java 17 is required"？

**解决：**
1. 检查pom.xml中的java.version是否为17
2. 检查Project Structure中的SDK是否为17
3. 重新加载Maven项目

---

## 🎯 运行应用

配置完成后：

1. 打开 `src/main/java/com/aicompanion/AicompanionApplication.java`

2. 点击代码行号旁边的 **绿色三角形▶️**

3. 选择 **"Run 'AicompanionApplication'"**

4. 查看底部控制台，看到：
   ```
   Tomcat started on port(s): 8080 (http)
   Started AicompanionApplication in X.XXX seconds
   ```

5. 浏览器访问：http://localhost:8080

---

## 💡 快速命令参考

在IDEA中可以使用以下快捷键：

```
Ctrl + Alt + Shift + S  → 打开Project Structure
Ctrl + Alt + S          → 打开Settings
Ctrl + F9               → 构建项目
Shift + F10             → 运行应用
Shift + F9              → 调试应用
```

---

## 📝 当前项目配置

- **Java版本**: 17 ✅
- **Spring Boot**: 3.2.0
- **数据库**: MySQL 8.0 (Docker)
- **构建工具**: Maven

---

## 🔗 相关文档

- [MAVEN_INSTALL_GUIDE.md](./MAVEN_INSTALL_GUIDE.md) - Maven安装指南
- [QUICK_START.md](./QUICK_START.md) - 快速开始
- [TROUBLESHOOTING.md](./TROUBLESHOOTING.md) - 故障排除

---

祝您配置成功！🎉

如有问题，请提供具体的错误信息。
