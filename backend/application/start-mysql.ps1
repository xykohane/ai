# 启动MySQL数据库服务
Write-Host "正在启动MySQL数据库服务..." -ForegroundColor Green

# 检查Docker是否运行
$dockerRunning = docker info 2>$null
if ($LASTEXITCODE -ne 0) {
    Write-Host "错误: Docker未运行，请先启动Docker Desktop" -ForegroundColor Red
    exit 1
}

# 进入项目目录
Set-Location $PSScriptRoot

# 启动MySQL容器
Write-Host "启动MySQL容器..." -ForegroundColor Yellow
docker-compose up -d mysql

# 等待容器启动
Write-Host "等待容器启动..." -ForegroundColor Yellow
Start-Sleep -Seconds 10

# 检查容器状态
$containerStatus = docker ps --filter "name=aicompanion-mysql" --format "{{.Status}}"
if ($containerStatus -match "Up") {
    Write-Host "✓ MySQL容器已成功启动" -ForegroundColor Green
    Write-Host ""
    Write-Host "连接信息:" -ForegroundColor Cyan
    Write-Host "  主机: localhost" -ForegroundColor White
    Write-Host "  端口: 3307" -ForegroundColor White
    Write-Host "  数据库: aicompanion" -ForegroundColor White
    Write-Host "  用户名: aicompanion" -ForegroundColor White
    Write-Host "  密码: aicompanion" -ForegroundColor White
    Write-Host ""
    Write-Host "DBeaver连接步骤:" -ForegroundColor Cyan
    Write-Host "  1. 打开DBeaver" -ForegroundColor White
    Write-Host "  2. 新建连接 -> 选择MySQL" -ForegroundColor White
    Write-Host "  3. 填写上述连接信息" -ForegroundColor White
    Write-Host "  4. 测试连接并保存" -ForegroundColor White
} else {
    Write-Host "✗ MySQL容器启动失败" -ForegroundColor Red
    Write-Host "查看日志:" -ForegroundColor Yellow
    docker-compose logs mysql
}
