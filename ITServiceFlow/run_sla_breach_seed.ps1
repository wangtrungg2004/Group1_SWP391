#!/usr/bin/env pwsh
<#
.SYNOPSIS
    Execute SLA Breach Demo SQL seed script
.DESCRIPTION
    Runs the comprehensive SLA breach and reopen demo seed data script against ITServiceFlow database.
.PARAMETER Server
    SQL Server instance name (default: localhost or .)
.PARAMETER Database
    Database name (default: ITServiceFlow)
.PARAMETER SqlCmdPath
    Path to sqlcmd.exe (will auto-detect if not provided)
#>

param(
    [Parameter(Mandatory=$false)]
    [string]$Server = 'localhost',
    
    [Parameter(Mandatory=$false)]
    [string]$Database = 'ITServiceFlow',
    
    [Parameter(Mandatory=$false)]
    [string]$SqlCmdPath
)

# Auto-detect sqlcmd if not provided
if (-not $SqlCmdPath) {
    $possiblePaths = @(
        'C:\Program Files\Microsoft SQL Server\Client SDK\ODBC\170\Tools\Binn\sqlcmd.exe',
        'C:\Program Files\Microsoft SQL Server\Client SDK\ODBC\180\Tools\Binn\sqlcmd.exe',
        'C:\Program Files (x86)\Microsoft SQL Server\Client SDK\ODBC\170\Tools\Binn\sqlcmd.exe',
        'C:\Program Files (x86)\Microsoft SQL Server\Client SDK\ODBC\180\Tools\Binn\sqlcmd.exe',
        'sqlcmd.exe'
    )
    
    foreach ($path in $possiblePaths) {
        if (Test-Path $path) {
            $SqlCmdPath = $path
            break
        }
    }
}

if (-not $SqlCmdPath) {
    Write-Host "ERROR: Cannot find sqlcmd.exe. Please install SQL Server tools or provide -SqlCmdPath parameter." -ForegroundColor Red
    exit 1
}

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "SLA Breach Demo Seed Data Executor" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Configuration:" -ForegroundColor Yellow
Write-Host "  Server: $Server" -ForegroundColor White
Write-Host "  Database: $Database" -ForegroundColor White
Write-Host "  sqlcmd.exe: $SqlCmdPath" -ForegroundColor White
Write-Host ""

$script = "database\20260325_seed_comprehensive_sla_breach_reopen_demo.sql"

if (-not (Test-Path $script)) {
    Write-Host "ERROR: Script not found: $script" -ForegroundColor Red
    exit 1
}

Write-Host "Executing: $script" -ForegroundColor Yellow
Write-Host ""

# Execute the SQL script
$output = & $SqlCmdPath -S $Server -d $Database -i $script -E 2>&1

Write-Host $output

if ($LASTEXITCODE -eq 0) {
    Write-Host ""
    Write-Host "✓ Seed data successfully created!" -ForegroundColor Green
    Write-Host ""
    Write-Host "Demo users created (password: 123456):" -ForegroundColor Green
    Write-Host "  • demo.admin (Admin)" -ForegroundColor White
    Write-Host "  • demo.manager (Manager)" -ForegroundColor White
    Write-Host "  • demo.it (IT Support)" -ForegroundColor White
    Write-Host "  • demo.user (User)" -ForegroundColor White
    Write-Host ""
    Write-Host "Tickets created:" -ForegroundColor Green
    Write-Host "  • 3 BREACHED tickets (deadline already passed)" -ForegroundColor White
    Write-Host "  • 3 NEAR-BREACH tickets (deadline < 2 hours)" -ForegroundColor White
    Write-Host "  • 3 WATCH-LIST tickets (deadline < 4 hours)" -ForegroundColor White
    Write-Host "  • 3 REOPENED tickets (resolved then reopened)" -ForegroundColor White
    Write-Host ""
    exit 0
} else {
    Write-Host ""
    Write-Host "ERROR: Script execution failed (exit code: $LASTEXITCODE)" -ForegroundColor Red
    exit $LASTEXITCODE
}
