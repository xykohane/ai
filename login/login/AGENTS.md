#### 1、流程图

```
用户输入用户名和密码
        │
        ▼
点击"登录"按钮 → handleLogin()
        │
        ▼
校验输入是否为空
        │
        ├─ 空 → 显示错误提示 "请输入用户名和密码"
        │
        ▼ (非空)
调用 AuthApi.login({ username, password })
        │
        ├─ 失败 → catch → 显示错误信息
        │
        ▼ (成功)
保存 Token → TokenUtil.saveToken(context, res.token)
保存用户信息 → TokenUtil.saveUserInfo(context, res.userId, res.username)
        │
        ▼
跳转首页 → router.replaceUrl({ url: 'pages/Home' })
```

#### 2、Login.ets 登录逻辑

```typescript
async handleLogin() {
  // 1. 校验输入
  if (!this.username.trim() || !this.password.trim()) {
    this.errorMsg = '请输入用户名和密码'
    return
  }

  this.loading = true
  this.errorMsg = ''

  try {
    // 2. 调用登录 API
    const data: LoginRequest = { username: this.username, password: this.password }
    const res = await AuthApi.login(data)

    // 3. 保存 Token 和用户信息到本地
    await TokenUtil.saveToken(this.context, res.token)
    await TokenUtil.saveUserInfo(this.context, res.userId, res.username)

    // 4. 跳转到首页（replaceUrl 不保留登录页，用户按返回键不会回到登录页）
    router.replaceUrl({ url: 'pages/Home' })
  } catch (err) {
    // 5. 登录失败，显示错误信息
    this.errorMsg = (err as Error).message || '登录失败'
  } finally {
    this.loading = false
  }
}
```

要点：

| 步骤         | 代码                             | 说明                     |
| ------------ | -------------------------------- | ------------------------ |
| 校验         | `!this.username.trim()`          | 去掉空格后检查是否为空   |
| loading 控制 | `this.loading = true/false`      | 防止重复点击             |
| API 调用     | `await AuthApi.login(data)`      | 封装好的 API，一行搞定   |
| Token 保存   | `await TokenUtil.saveToken(...)` | 持久化到本地存储         |
| 页面跳转     | `router.replaceUrl(...)`         | 替换当前页面（不可回退） |
| 错误处理     | `catch → this.errorMsg`          | 显示后端返回的错误信息   |

#### 3、自动登录

登录页面还有一个智能逻辑——如果本地已有 Token，自动跳转首页：

```typescript
async aboutToAppear() {
  const token = await TokenUtil.getToken(this.context)
  if (token) {
    router.replaceUrl({ url: 'pages/Home' })  // 有 Token 直接进首页
  }
  // 没有 Token 就留在登录页
}
```

