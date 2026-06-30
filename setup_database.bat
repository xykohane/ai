@echo off
REM AI伴学平台数据库初始化脚本
REM 用于在本地MySQL环境中创建数据库和表结构

echo 正在初始化AI伴学平台数据库...

REM 检查是否有MySQL客户端
mysql --version >nul 2>&1
if %errorlevel% neq 0 (
    echo 错误：未找到MySQL客户端，请先安装MySQL
    echo 请访问 https://dev.mysql.com/downloads/installer/ 下载并安装MySQL
    pause
    exit /b 1
)

echo.
echo 请输入MySQL root用户的密码：
set /p rootpass="Root密码: "

REM 创建数据库和用户
echo 正在创建数据库和用户...
mysql -u root -p%rootpass% -e "CREATE DATABASE IF NOT EXISTS aicompanion DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;"
mysql -u root -p%rootpass% -e "CREATE USER IF NOT EXISTS 'aicompanion'@'%' IDENTIFIED BY 'aicompanion';"
mysql -u root -p%rootpass% -e "GRANT ALL PRIVILEGES ON aicompanion.* TO 'aicompanion'@'%';"
mysql -u root -p%rootpass% -e "FLUSH PRIVILEGES;"

echo.
echo 正在创建表结构并插入测试数据...
mysql -u aicompanion -paicompanion aicompanion < complete_ai_learning_platform_schema.sql

if %errorlevel% equ 0 (
    echo.
    echo 数据库初始化成功！
    echo.
    echo 连接信息：
    echo   - 主机: localhost
    echo   - 端口: 3306
    echo   - 数据库: aicompanion
    echo   - 用户名: aicompanion
    echo   - 密码: aicompanion
    echo.
    echo 现在可以使用DBeaver等工具连接数据库进行查看
) else (
    echo.
    echo 数据库初始化失败，请检查错误信息
)

pause