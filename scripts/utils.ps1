# ==============================================================================
# scripts\utils.ps1 - ユーティリティ共通関数
# ==============================================================================

function Write-Step {
    param([string]$message)
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    Write-Host ""
    Write-Host "======================================================================" -ForegroundColor Cyan
    Write-Host " [$timestamp] $message" -ForegroundColor Cyan
    Write-Host "======================================================================" -ForegroundColor Cyan
}

function Write-Success {
    param([string]$message)
    $timestamp = Get-Date -Format "HH:mm:ss"
    Write-Host "  [OK $timestamp] $message" -ForegroundColor Green
}

function Write-Info {
    param([string]$message)
    $timestamp = Get-Date -Format "HH:mm:ss"
    Write-Host "  [.. $timestamp] $message" -ForegroundColor Gray
}

function Write-WarningMessage {
    param([string]$message)
    $timestamp = Get-Date -Format "HH:mm:ss"
    Write-Host "  [WARN $timestamp] $message" -ForegroundColor Yellow
}

function Write-ErrorMessage {
    param([string]$message)
    $timestamp = Get-Date -Format "HH:mm:ss"
    Write-Host "  [ERROR $timestamp] $message" -ForegroundColor Red
}

function Test-IsAdmin {
    $currentPrincipal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
    return $currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

function Require-Admin {
    if (-not (Test-IsAdmin)) {
        Write-WarningMessage "管理者権限が必要です。UACダイアログで許可してください..."
        $scriptPath = $MyInvocation.PSCommandPath
        $psi = New-Object System.Diagnostics.ProcessStartInfo
        $psi.FileName = "powershell.exe"
        $psi.Arguments = "-NoProfile -ExecutionPolicy Bypass -File `"$scriptPath`""
        $psi.Verb = "runas"
        try {
            [System.Diagnostics.Process]::Start($psi)
            exit 0
        } catch {
            Write-ErrorMessage "管理者権限の昇格に失敗しました。管理者としてPowerShellを実行してください。"
            exit 1
        }
    }
}

