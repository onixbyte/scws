# SCWS MinGW Build Script
# Usage: .\build.ps1 [-Clean] [-Verbose]

param(
    [switch]$Clean,
    [switch]$Verbose
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function Write-Step([string]$Msg) { Write-Host "[INFO]  $Msg" -ForegroundColor Cyan }
function Write-Fail([string]$Msg) { Write-Host "[ERROR] $Msg" -ForegroundColor Red; exit 1 }

if (-not (Get-Command 'mingw32-make' -ErrorAction SilentlyContinue)) {
    Write-Fail "mingw32-make not found. Please install MinGW and add it to PATH."
}

$makeArgs = @('-f', 'Makefile.mingw')

if ($Clean) {
    Write-Step "Cleaning..."
    bash -c "mingw32-make $($makeArgs -join ' ') clean"
}

Write-Step "Compiling..."
$output = bash -c "mingw32-make $($makeArgs -join ' ') 2>&1"

if ($LASTEXITCODE -ne 0) {
    $output | Write-Host
    Write-Fail "Compilation failed."
}

if ($Verbose) {
    $output | Write-Host
} else {
    $output | Where-Object { $_ -match 'Linking|Build completed|error' } | Write-Host
}
