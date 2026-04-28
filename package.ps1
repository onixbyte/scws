# SCWS Windows Distribution Package Builder
# Requires: MinGW (gcc, mingw32-make), PowerShell 5+
# Usage: .\package.ps1

#Requires -Version 5.0

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

# ── Configuration ────────────────────────────────────────────────────────────
$Version     = '1.2.3'
$PackageName = "scws-$Version-win64"
$BuildDir    = 'build'
$DistDir     = 'dist'
$PkgDir      = "$DistDir\$PackageName"
$ZipFile     = "$DistDir\$PackageName.zip"

# ── Helpers ──────────────────────────────────────────────────────────────────
function Write-Step([string]$Msg) { Write-Host "[INFO]  $Msg" -ForegroundColor Cyan }
function Write-Fail([string]$Msg) { Write-Host "[ERROR] $Msg" -ForegroundColor Red; exit 1 }

# ── Banner ───────────────────────────────────────────────────────────────────
Write-Host ""
Write-Host " SCWS Windows Package Builder v$Version" -ForegroundColor White
Write-Host " ========================================" -ForegroundColor DarkGray
Write-Host ""

# ── Check MinGW ──────────────────────────────────────────────────────────────
foreach ($tool in @('gcc', 'mingw32-make')) {
    if (-not (Get-Command $tool -ErrorAction SilentlyContinue)) {
        Write-Fail "$tool not found. Please install MinGW and add it to PATH."
    }
}
$GccVersion = (gcc --version 2>&1 | Select-Object -First 1)
Write-Step "Compiler : $GccVersion"

# ── Clean previous build ─────────────────────────────────────────────────────
Write-Step "Cleaning previous build..."
foreach ($path in @($BuildDir, $PkgDir)) {
    if (Test-Path $path) { Remove-Item $path -Recurse -Force }
}
if (Test-Path $ZipFile) { Remove-Item $ZipFile -Force }

# ── Compile ──────────────────────────────────────────────────────────────────
Write-Step "Compiling with MinGW..."
$buildLog = mingw32-make -f Makefile.mingw 2>&1
if ($LASTEXITCODE -ne 0) {
    $buildLog | Write-Host
    Write-Fail "Compilation failed."
}
Write-Step "Compilation succeeded."

# ── Stage package directory ──────────────────────────────────────────────────
Write-Step "Staging package files..."
foreach ($dir in @("$PkgDir\bin", "$PkgDir\etc", "$PkgDir\doc")) {
    New-Item -ItemType Directory -Path $dir -Force | Out-Null
}

$fileMappings = @(
    @{ Src = "$DistDir\scws.exe";           Dst = "$PkgDir\bin" },
    @{ Src = "$DistDir\scws-gen-dict.exe";  Dst = "$PkgDir\bin" },
    @{ Src = "etc\rules.ini";              Dst = "$PkgDir\etc" },
    @{ Src = "etc\rules.utf8.ini";         Dst = "$PkgDir\etc" },
    @{ Src = "etc\rules_cht.utf8.ini";     Dst = "$PkgDir\etc" },
    @{ Src = "README.md";                  Dst = "$PkgDir\doc" },
    @{ Src = "API.md";                     Dst = "$PkgDir\doc" },
    @{ Src = "COPYING";                    Dst = "$PkgDir\doc" }
)

foreach ($item in $fileMappings) {
    if (-not (Test-Path $item.Src)) { Write-Fail "Source file not found: $($item.Src)" }
    Copy-Item $item.Src -Destination $item.Dst -Force
}

# ── Create zip ───────────────────────────────────────────────────────────────
Write-Step "Creating zip archive: $ZipFile"

$use7Zip = $null -ne (Get-Command '7z' -ErrorAction SilentlyContinue)

if ($use7Zip) {
    7z a -tzip -mx=9 $ZipFile ".\$PkgDir\*" | Out-Null
} else {
    Compress-Archive -Path "$PkgDir\*" -DestinationPath $ZipFile -Force
}

if (-not (Test-Path $ZipFile)) {
    Write-Fail "Failed to create zip archive."
}

# ── Summary ──────────────────────────────────────────────────────────────────
$zipSizeKB = [math]::Round((Get-Item $ZipFile).Length / 1KB)
$contents  = $fileMappings | ForEach-Object {
    $rel = $item.Dst -replace [regex]::Escape($PkgDir + '\'), ''
    $leaf = Split-Path $_.Src -Leaf
    $folder = (Split-Path $_.Dst -Leaf)
    "    $folder\$leaf"
}

Write-Host ""
Write-Host " Package ready" -ForegroundColor Green
Write-Host " $('─' * 41)" -ForegroundColor DarkGray
Write-Host "  File : $ZipFile"
Write-Host "  Size : $zipSizeKB KB"
Write-Host "  Contents:"
$contents | Write-Host
Write-Host " $('─' * 41)" -ForegroundColor DarkGray
Write-Host ""
