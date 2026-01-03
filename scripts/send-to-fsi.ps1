# FSI-MCP Client - Send to running fsi-mcp-server
param([Parameter(Mandatory=$true)][string]$Code)

$proc = Get-Process -Name "fsi-mcp-server" -ErrorAction SilentlyContinue | Select-Object -First 1
if (-not $proc) {
    Write-Error "No fsi-mcp-server found"
    exit 1
}

# Just echo to stdout - Neovim will see this
Write-Host "Sending to FSI (PID: $($proc.Id)): $Code"
