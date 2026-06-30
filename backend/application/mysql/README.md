# MySQL Docker 配置说明

## 目录结构

```
mysql/
├── conf/          # MySQL配置文件目录
│   └── my.cnf     # 自定义MySQL配置（可选）
└── logs/          # MySQL日志文件目录
    └── error.log  # 错误日志
```

## 使用方法

### 1. 启动MySQL容器

在项目根目录（application文件夹）下执行：

```bash
docker-compose up -d
```

### 2. 查看容器状态

```bash
docker-compose ps
```

### 3. 查看日志

```bash
docker-compose logs -f mysql
```

### 4. 停止容器

```bash
docker-compose down
```

### 5. 重启容器

```bash
docker-compose restart
```

## 数据库连接信息

- **主机**: localhost
- **端口**: 3306
- **数据库名**: aicompanion
- **用户名**: root / aicompanion
- **密码**: root / aicompanion

## DBeaver连接配置

1. 打开DBeaver
2. 新建连接 → 选择MySQL
3. 填写连接信息：
   - 主机: localhost
   - 端口: 3306
   - 数据库: aicompanion
   - 用户名: root
   - 密码: root
4. 测试连接
5. 完成

## 数据持久化

MySQL数据存储在Docker卷 `mysql_data` 中，即使删除容器，数据也不会丢失。

如需完全清除数据：

```bash
docker-compose down -v
```

## 初始化SQL脚本

放置在 `src/main/resources/sql/` 目录下的 `.sql` 文件会在MySQL首次启动时自动执行。

## 常见问题

### 1. 端口被占用

如果3306端口已被占用，修改 `docker-compose.yml` 中的端口映射：

```yaml
ports:
  - "3307:3306"  # 将宿主机的3307端口映射到容器的3306端口
```

### 2. 权限问题

确保当前用户有Docker执行权限。

### 3. 连接失败

- 检查容器是否正常运行：`docker-compose ps`
- 检查防火墙设置
- 确认MySQL已完全启动（可能需要等待几秒）
