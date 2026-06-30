# Auto-configure Docker Mirror for China users
# This script sets up Docker registry mirrors

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Docker Mirror Configuration Tool" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Check if Docker is installed
$dockerVersion = docker --version 2>&1
if ($LASTEXITCODE -ne 0) {
    Write-Host "Error: Docker is not installed" -ForegroundColor Red
    exit 1
}

Write-Host "Docker version: $dockerVersion" -ForegroundColor Green
Write-Host ""

# Define mirror configuration
$daemonJson = @{
    "registry-mirrors" = @(
        "https://docker.m.daocloud.io",
        "https://dockerproxy.com",
        "https://docker.mirrors.ustc.edu.cn",
        "https://hub-mirror.c.163.com"
    )
    "insecure-registries" = @()
    "debug" = $false
    "experimental" = $false
} | ConvertTo-Json -Depth 10

# Config file path
$configPath = "$env:USERPROFILE\.docker\daemon.json"
$configDir = "$env:USERPROFILE\.docker"

# Create directory if not exists
if (-Not (Test-Path $configDir)) {
    Write-Host "Creating Docker config directory..." -ForegroundColor Yellow
    New-Item -Path $configDir -ItemType Directory -Force | Out-Null
}

# Backup existing config if exists
if (Test-Path $configPath) {
    Write-Host "Backing up existing configuration..." -ForegroundColor Yellow
    $backupPath = "$configPath.backup.$(Get-Date -Format 'yyyyMMddHHmmss')"
    Copy-Item -Path $configPath -Destination $backupPath
    Write-Host "Backup saved to: $backupPath" -ForegroundColor Green
}

# Write new configuration
Write-Host "Writing new configuration..." -ForegroundColor Yellow
$daemonJson | Out-File -FilePath $configPath -Encoding UTF8

Write-Host ""
Write-Host "SUCCESS: Docker mirror configured!" -ForegroundColor Green
Write-Host ""
Write-Host "Configuration file: $configPath" -ForegroundColor Cyan
Write-Host ""
Write-Host "Mirrors configured:" -ForegroundColor Cyan
Write-Host "  - https://docker.m.daocloud.io" -ForegroundColor White
Write-Host "  - https://dockerproxy.com" -ForegroundColor White
Write-Host "  - https://docker.mirrors.ustc.edu.cn" -ForegroundColor White
Write-Host "  - https://hub-mirror.c.163.com" -ForegroundColor White
Write-Host ""
Write-Host "IMPORTANT: Please restart Docker Desktop manually!" -ForegroundColor Yellow
Write-Host ""
Write-Host "After restart, test with:" -ForegroundColor Cyan
Write-Host "  docker pull mysql:8.0" -ForegroundColor Gray
Write-Host ""

$restart = Read-Host "Do you want to view the configuration file? (y/n)"
if ($restart -eq "y") {
    notepad $configPath
}
