-NoLogo -NoProfile
 
Write-Host "This script will install chocolatey, git, github-cli, as well as non Choco essentials." -ForegroundColor Green
  
 
#function to update system path after installation
 
function Update-Environment-Path
{
    $env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") `
        + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")
}
 
$ifChocoInstalled = powershell -NoLogo -NoProfile choco -v 
 
 
#Choco installation
if(-not($ifChocoInstalled)){
    Write-host "Chocolatey is not installed, installation begin now " -ForegroundColor Green
    Set-ExecutionPolicy Bypass -Scope Process -Force;
    iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
 
    Update-Environment-Path
 
    }
 
 else{
    Write-host "Chocolatey $ifChocoInstalled is already installed" -ForegroundColor Green
}
 



 
#GIT Installation
 
$ifGITInstalled = powershell -NoLogo -NoProfile git --version 
 
if(-not($ifGITInstalled)){
    Write-host "GIT is not installed, installation begin now " -ForegroundColor Green
    Set-ExecutionPolicy Bypass -Scope Process -Force;
    choco install git --yes
     
    Update-Environment-Path
 
    }
 
 else{
    Write-host "$ifGITInstalled is already installed" -ForegroundColor Green
}
 
$ifghInstalled = powershell -NoLogo -NoProfile gh --version 
 
if(-not($ifghInstalled)){ 
    Write-host "gh is not installed, installation begin now " -ForegroundColor Green
    Set-ExecutionPolicy Bypass -Scope Process -Force;
    choco install gh --yes
     
    Update-Environment-Path
 
    }
 
 else{
    Write-host "$ifghInstalled is already installed" -ForegroundColor Green
}


$ifbobInstalled = powershell -NoLogo -NoProfile where bob 
 
 
#bob installation
if(-not($ifbobInstalled)){
    Write-host "bob is not installed, installation begin now " -ForegroundColor Green
    Set-ExecutionPolicy Bypass -Scope Process -Force;
    curl.exe -L ('https://github.com/MordechaiHadad/bob/releases/latest/download/bob-windows-x86_64.zip') -o c:\bob.zip  
    7z x c:/temp/bob.zip -oc:/bob 
    [System.Environment]::SetEnvironmentVariable("Path","Env:Path + c:/bob", "User") 
    Remove-Item -path c:/temp/bob.zip
    Update-Environment-Path
    
 
    }
 
 else{
    Write-host "bob $ifbobInstalled is already installed" -ForegroundColor Green
}
$ifnvimInstalled = powershell -NoLogo -NoProfile where.exe nvim

if ($ifnvimInstalled -and $ifnvimInstalled[0] -ne "bob\nvim-bin\nvim.exe") {
    # Uninstall existing Neovim installation from regular Windows installation
    # $regularUninstallCommand = '<Uninstall Command for Regular Windows Installation>'
    # if ($regularUninstallCommand) {
    #     Write-Host "Uninstalling existing Neovim installation (Regular Windows Installation)" -ForegroundColor Yellow
    #     Invoke-Expression $regularUninstallCommand
    # }

    # Uninstall existing Neovim installation from Chocolatey
    $chocoListOutput = powershell -NoLogo -NoProfile choco list nvim
    $chocoInstalled = $chocoListOutput -ne ""
    if ($chocoInstalled) {
        Write-Host "Uninstalling existing Neovim installation (Chocolatey)" -ForegroundColor Yellow
        powershell -NoLogo -NoProfile choco uninstall nvim -y
        Write-Host "Refreshing environment variables" -ForegroundColor Yellow
        powershell -NoLogo -NoProfile refreshenv
    }

    # Run the command to install Neovim through Bob
    Write-Host "Installing Neovim through Bob" -ForegroundColor Yellow
    powershell -NoLogo -NoProfile -Command "bob use stable"

    Write-Host "Installed Neovim through Bob successfully" -ForegroundColor Green
} elseif ($ifnvimInstalled -eq $null) {
    Write-Host "Neovim is not installed, something obviously went wrong" -ForegroundColor Red
} else {
    Write-Host "Neovim is already installed through Bob" -ForegroundColor Green
} 
# $ifbobInstalled = powershell -NoLogo -NoProfile where.exe bob 
# $uninstallPath = Get-Command nvim | Select-Object -ExpandProperty Source & $uninstallPath --uninstall
# if(($ifbobInstalled)){
# if(($ifnvimInstalled)){
# $Installer = New-Object -ComObject WindowsInstaller.Installer
# $nvim = 
#   ( $Installer.ProductsEx("", "", 7) 
#     |Where-Object{$_.InstallProperty("ProductName ") -like "Neovim"}) 
#       |  Select-Object -First 1
# $msiProductCode = $nvim.ProductCode()
# if($msiProductCode)  {
#     Write-host "Uninstall neovim installed in any other way other than through Bob. " -ForegroundColor Red
# } 
#   } 
#   } 
# else {
#
#     Write-host "bob is not installed, Something obviously went wrong" -ForegroundColor Red
#
#   }
#
#
# if(($ifbobInstalled)){
#
#     Write-host "bob $ifbobInstalled is already installed" -ForegroundColor Green
#
#   } 
# else {
#
#     Write-host "bob is not installed, Something obviously went wrong" -ForegroundColor Red
#
#   }
#
#
#
#
Update-Environment-Path
