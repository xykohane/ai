# Maven Installation and Configuration Script for Windows

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Maven Setup Helper" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Check if Maven is already installed
$mavenVersion = mvn --version 2>&1
if ($LASTEXITCODE -eq 0) {
    Write-Host "Maven is already installed:" -ForegroundColor Green
    Write-Host $mavenVersion[0] -ForegroundColor White
    Write-Host ""
    Write-Host "You can now use: mvn spring-boot:run" -ForegroundColor Yellow
    exit 0
}

Write-Host "Maven is not installed or not configured." -ForegroundColor Yellow
Write-Host ""

# Provide installation instructions
Write-Host "=== Installation Instructions ===" -ForegroundColor Cyan
Write-Host ""
Write-Host "Step 1: Download Maven" -ForegroundColor Yellow
Write-Host "  Visit: https://maven.apache.org/download.cgi" -ForegroundColor White
Write-Host "  Download: apache-maven-3.x.x-bin.zip" -ForegroundColor White
Write-Host ""

Write-Host "Step 2: Extract to a directory" -ForegroundColor Yellow
Write-Host "  Example: C:\Program Files\Apache\maven" -ForegroundColor White
Write-Host ""

Write-Host "Step 3: Set Environment Variables" -ForegroundColor Yellow
Write-Host ""
Write-Host "Option A: Manual Configuration" -ForegroundColor Cyan
Write-Host "  1. Right-click 'This PC' -> Properties" -ForegroundColor White
Write-Host "  2. Click 'Advanced system settings'" -ForegroundColor White
Write-Host "  3. Click 'Environment Variables'" -ForegroundColor White
Write-Host "  4. Under 'System variables', click 'New':" -ForegroundColor White
Write-Host "     Variable name: MAVEN_HOME" -ForegroundColor Gray
Write-Host "     Variable value: C:\Program Files\Apache\maven" -ForegroundColor Gray
Write-Host "  5. Find 'Path' variable, click 'Edit', add:" -ForegroundColor White
Write-Host "     %MAVEN_HOME%\bin" -ForegroundColor Gray
Write-Host ""

Write-Host "Option B: Using PowerShell (Run as Administrator)" -ForegroundColor Cyan
Write-Host "  [Environment]::SetEnvironmentVariable('MAVEN_HOME', 'C:\Program Files\Apache\maven', 'Machine')" -ForegroundColor Gray
Write-Host "  [Environment]::SetEnvironmentVariable('Path', \$env:Path + ';%MAVEN_HOME%\bin', 'Machine')" -ForegroundColor Gray
Write-Host ""

Write-Host "Step 4: Verify Installation" -ForegroundColor Yellow
Write-Host "  Open a NEW PowerShell window and run:" -ForegroundColor White
Write-Host "  mvn --version" -ForegroundColor Gray
Write-Host ""

Write-Host "=== Alternative: Use IDE ===" -ForegroundColor Cyan
Write-Host "If you have IntelliJ IDEA or Eclipse:" -ForegroundColor White
Write-Host "  - They have built-in Maven support" -ForegroundColor White
Write-Host "  - You can run the application directly from the IDE" -ForegroundColor White
Write-Host ""

Write-Host "For more help, see: QUICK_START.md" -ForegroundColor Yellow
Write-Host ""
