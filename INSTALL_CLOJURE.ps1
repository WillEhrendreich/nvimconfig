# Clojure Development Setup Script
# This script adds Java and Clojure tools to your permanent Windows PATH

# Add OpenJDK to PATH (permanently)
$javaPath = "C:\Program Files\OpenJDK\jdk-25\bin"
$chocoPath = "C:\ProgramData\chocolatey\bin"

$currentPath = [Environment]::GetEnvironmentVariable("Path", "User")

if ($currentPath -notlike "*$javaPath*") {
    Write-Host "Adding Java to PATH..."
    $newPath = "$javaPath;$currentPath"
    [Environment]::SetEnvironmentVariable("Path", $newPath, "User")
    Write-Host "✓ Java added to PATH"
} else {
    Write-Host "✓ Java already in PATH"
}

if ($currentPath -notlike "*$chocoPath*") {
    Write-Host "Adding Chocolatey bin to PATH..."
    $newPath = [Environment]::GetEnvironmentVariable("Path", "User")
    $newPath = "$chocoPath;$newPath"
    [Environment]::SetEnvironmentVariable("Path", $newPath, "User")
    Write-Host "✓ Chocolatey bin added to PATH"
} else {
    Write-Host "✓ Chocolatey bin already in PATH"
}

Write-Host ""
Write-Host "✅ Setup complete! Please restart PowerShell or your terminal for changes to take effect."
Write-Host ""
Write-Host "Verify installation by running:"
Write-Host "  java -version"
Write-Host "  lein --version"
Write-Host "  clojure-lsp --version"
