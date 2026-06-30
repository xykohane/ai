# IntelliJ IDEA JDK 17 Setup Helper
# This script helps you install and configure JDK 17 in IntelliJ IDEA

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  IntelliJ IDEA JDK 17 Setup" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

Write-Host "Since I cannot directly control IntelliJ IDEA, I'll guide you through the process." -ForegroundColor Yellow
Write-Host ""

Write-Host "=== Option 1: Install JDK 17 via IDEA (Recommended) ===" -ForegroundColor Cyan
Write-Host ""
Write-Host "Step 1: Open IntelliJ IDEA" -ForegroundColor Yellow
Write-Host ""

Write-Host "Step 2: Open Project Settings" -ForegroundColor Yellow
Write-Host "  File -> Project Structure (or press Ctrl+Alt+Shift+S)" -ForegroundColor White
Write-Host ""

Write-Host "Step 3: Add JDK 17" -ForegroundColor Yellow
Write-Host "  1. In the left panel, select 'SDKs'" -ForegroundColor White
Write-Host "  2. Click '+' button -> 'Download JDK'" -ForegroundColor White
Write-Host "  3. Configure:" -ForegroundColor Gray
Write-Host "     Vendor: Oracle OpenJDK or Eclipse Temurin" -ForegroundColor DarkGray
Write-Host "     Version: 17" -ForegroundColor DarkGray
Write-Host "  4. Click 'Download'" -ForegroundColor White
Write-Host "  5. Wait for download to complete" -ForegroundColor White
Write-Host ""

Write-Host "Step 4: Set JDK for Project" -ForegroundColor Yellow
Write-Host "  1. In the left panel, select 'Project'" -ForegroundColor White
Write-Host "  2. Set 'SDK' to the JDK 17 you just downloaded" -ForegroundColor White
Write-Host "  3. Set 'Language level' to '17 - Sealed types, always-strict floating-point semantics'" -ForegroundColor White
Write-Host "  4. Click 'Apply' -> 'OK'" -ForegroundColor White
Write-Host ""

Write-Host "Step 5: Update pom.xml" -ForegroundColor Yellow
Write-Host "  Change java.version back to 17 in pom.xml:" -ForegroundColor White
Write-Host "  <java.version>17</java.version>" -ForegroundColor Gray
Write-Host ""

Write-Host "Step 6: Reload Maven Project" -ForegroundColor Yellow
Write-Host "  Right-click pom.xml -> Reload Project" -ForegroundColor White
Write-Host ""

Write-Host "=== Option 2: Manual JDK 17 Installation ===" -ForegroundColor Cyan
Write-Host ""
Write-Host "If you prefer to install JDK 17 manually:" -ForegroundColor White
Write-Host ""
Write-Host "1. Download JDK 17:" -ForegroundColor Yellow
Write-Host "   Oracle: https://www.oracle.com/java/technologies/downloads/#java17" -ForegroundColor White
Write-Host "   Eclipse Temurin: https://adoptium.net/temurin/releases/?version=17" -ForegroundColor White
Write-Host "   Amazon Corretto: https://docs.aws.amazon.com/corretto/latest/corretto-17-ug/downloads-list.html" -ForegroundColor White
Write-Host ""
Write-Host "2. Install JDK 17 to a directory, e.g.:" -ForegroundColor Yellow
Write-Host "   C:\Program Files\Java\jdk-17" -ForegroundColor White
Write-Host ""
Write-Host "3. In IDEA: File -> Project Structure -> SDKs -> + -> Add JDK" -ForegroundColor Yellow
Write-Host "   Browse to the JDK installation directory" -ForegroundColor White
Write-Host ""
Write-Host "4. Follow Step 4-6 from Option 1" -ForegroundColor Yellow
Write-Host ""

Write-Host "=== Verification ===" -ForegroundColor Cyan
Write-Host ""
Write-Host "After configuration, verify in IDEA:" -ForegroundColor White
Write-Host "  File -> Project Structure -> Project" -ForegroundColor Gray
Write-Host "  SDK should show: 17 (or jdk-17.x.x)" -ForegroundColor Gray
Write-Host ""
Write-Host "Then run the application:" -ForegroundColor White
Write-Host "  Right-click AicompanionApplication.java -> Run" -ForegroundColor Gray
Write-Host ""

Write-Host "Would you like me to update pom.xml to use Java 17? (y/n)" -ForegroundColor Yellow
$response = Read-Host

if ($response -eq "y" -or $response -eq "Y") {
    Write-Host ""
    Write-Host "Updating pom.xml to Java 17..." -ForegroundColor Yellow
    
    $pomPath = "pom.xml"
    if (Test-Path $pomPath) {
        $content = Get-Content $pomPath -Raw
        $content = $content -replace '<java\.version>26</java\.version>', '<java.version>17</java.version>'
        $content | Set-Content $pomPath -NoNewline
        Write-Host "pom.xml updated successfully!" -ForegroundColor Green
        Write-Host "Please reload Maven project in IDEA." -ForegroundColor Yellow
    } else {
        Write-Host "pom.xml not found in current directory." -ForegroundColor Red
    }
}

Write-Host ""
Write-Host "For detailed instructions, see: MAVEN_INSTALL_GUIDE.md" -ForegroundColor Cyan
Write-Host ""
