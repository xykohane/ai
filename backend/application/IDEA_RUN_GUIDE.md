#  IDEA 中运行 Spring Boot 项目 - 完整指南

## ⚠️ 当前问题
IDEA 无法识别 Maven 项目，导致无法直接运行 `AicompanionApplication.java`

---

## ✅ 解决方案（3选1）

### **方案1：在 IDEA 中手动添加 Maven 项目（推荐）**

#### 步骤1.1：找到 pom.xml
在左侧项目面板中，展开路径：
```
application/
  └── pom.xml  ← 找到这个文件
```

#### 步骤1.2：右键添加为 Maven 项目
1. **右键点击 `pom.xml`**
2. 在弹出菜单中选择以下任一选项：
   - ✅ **"Add as Maven Project"**（添加为 Maven 项目）
   - 或 **"Import as Maven Project"**（导入为 Maven 项目）
   - 或 **"Maven → Add as Maven Project"**

3. **等待加载完成**
   - 右下角会出现进度条："Loading Maven projects..."
   - 右侧 Maven 工具窗口会显示项目结构
   - 可能需要 1-5 分钟下载依赖

#### 步骤1.3：运行应用
加载完成后：
1. 打开 `AicompanionApplication.java`
2. **右键点击类名** 或 **main 方法**
3. 选择 **"Run 'AicompanionApplication'"**
4. 查看控制台输出

---

### **方案2：使用 Maven 工具窗口添加**

如果右键菜单中没有 "Add as Maven Project" 选项：

#### 步骤2.1：打开 Maven 工具窗口
- 点击 IDEA 右侧边栏的 **"Maven"** 图标
- 或使用菜单：**View → Tool Windows → Maven**

#### 步骤2.2：添加 Maven 项目
1. 在 Maven 面板左上角，点击 **"+"** 号（添加按钮）
2. 选择 **"Add Maven Projects"**
3. 在文件选择对话框中，导航到：
   ```
   C:\Users\15060\Desktop\work\backend\application\pom.xml
   ```
4. 选中 `pom.xml`，点击 **OK**

#### 步骤2.3：等待加载并运行
- 等待依赖下载完成
- 右键运行 `AicompanionApplication.java`

---

### **方案3：重新打开项目（终极方案）**

如果上述方法都不行，重新让 IDEA 自动识别：

#### 步骤3.1：关闭当前项目
- 菜单：**File → Close Project**

#### 步骤3.2：重新打开 application 文件夹
1. 在欢迎界面点击 **"Open"**
2. **重要**：选择文件夹路径为：
   ```
   C:\Users\15060\Desktop\work\backend\application
   ```
   ️ 注意：是 `application` 文件夹，不是 `backend` 文件夹！
3. 点击 **OK**

#### 步骤3.3：自动导入 Maven
- IDEA 会自动检测到 `pom.xml`
- 右下角弹出提示："Maven projects need to be imported"
- 点击 **"Import Changes"** 或 **"Enable Auto-Import"**
- 等待加载完成

#### 步骤3.4：运行应用
- 打开 `AicompanionApplication.java`
- 右键 → Run

---

## 🔍 验证是否成功

### 检查点1：Maven 工具窗口有内容
- 右侧 Maven 面板应该显示项目结构
- 能看到 `Dependencies`、`Plugins` 等节点

### 检查点2：pom.xml 图标变化
- 左侧项目中 `pom.xml` 文件图标变为带 "M" 标志的 Maven 图标

### 检查点3：可以右键运行
- 在 `AicompanionApplication.java` 中右键有 "Run" 选项

---

##  常见问题排查

### Q1: 右键没有 "Add as Maven Project" 选项？
**解决**：使用方案2或方案3

### Q2: Maven 加载很慢或卡住？
**解决**：
1. 检查网络连接
2. 配置国内镜像（参考 `DOCKER_MIRROR_SETUP.md`）
3. 等待 5-10 分钟

### Q3: 加载后还是无法运行？
**解决**：
1. 检查 JDK 版本是否为 17：**File → Project Structure → Project → SDK**
2. 清理缓存：**File → Invalidate Caches / Restart**
3. 重新加载 Maven：Maven 面板 → 🔄 Reload All Maven Projects

### Q4: 运行时报错找不到依赖？
**解决**：
1. Maven 面板 → 右键项目 → **Reimport**
2. 或在终端执行（如果安装了 Maven）：
   ```powershell
   cd C:\Users\15060\Desktop\work\backend\application
   mvn clean install
   ```

---

## 🎯 成功后的预期结果

应用启动后，控制台应该显示：
```
Started AicompanionApplication in X.XXX seconds
```

访问地址：
- Swagger UI: http://localhost:8080/swagger-ui.html
- API 文档: http://localhost:8080/v3/api-docs

---

## 📞 需要帮助？

如果以上所有方案都无法解决，请提供：
1. 右键点击 `pom.xml` 时的截图
2. Maven 工具窗口的截图
3. IDEA 底部 Event Log 的内容

我会继续帮您诊断问题！
