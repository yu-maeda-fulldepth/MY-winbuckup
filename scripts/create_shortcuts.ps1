# ==============================================================================
# scripts\create_shortcuts.ps1 - デスクトップショートカット作成スクリプト
# ==============================================================================

[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$rootDir = Split-Path -Parent $PSScriptRoot

$wsh = New-Object -ComObject WScript.Shell
$desktop = [Environment]::GetFolderPath('Desktop')

# 1. バックアップ ＆ GitHubプッシュ
$scBackupPush = $wsh.CreateShortcut("$desktop\Windows環境_GitHubバックアップ実行.lnk")
$scBackupPush.TargetPath = "$rootDir\BACKUP_AND_PUSH.bat"
$scBackupPush.WorkingDirectory = "$rootDir"
$scBackupPush.Description = "環境をバックアップし、GitHubリポジトリ (MY-winbuckup) へプッシュします"
$scBackupPush.IconLocation = "shell32.dll,259"
$scBackupPush.Save()

# 2. 定期自動バックアップ設定 (タスクスケジューラ)
$scSchedule = $wsh.CreateShortcut("$desktop\Windows環境_定期自動バックアップ設定.lnk")
$scSchedule.TargetPath = "$rootDir\SCHEDULE_AUTO_BACKUP.bat"
$scSchedule.WorkingDirectory = "$rootDir"
$scSchedule.Description = "Windowsタスクスケジューラに自動バックアップを登録・設定します"
$scSchedule.IconLocation = "shell32.dll,165"
$scSchedule.Save()

# 3. 復元用ショートカット
$scRestore = $wsh.CreateShortcut("$desktop\Windows環境_ワンクリック復元.lnk")
$scRestore.TargetPath = "$rootDir\RESTORE_ENVIRONMENT.bat"
$scRestore.WorkingDirectory = "$rootDir"
$scRestore.Description = "バックアップからすべてのソフトと環境をワンクリックで復元します"
$scRestore.IconLocation = "shell32.dll,246"
$scRestore.Save()

Write-Host "デスクトップにショートカットを作成しました！" -ForegroundColor Green
Write-Host "  ・Windows環境_GitHubバックアップ実行.lnk" -ForegroundColor Cyan
Write-Host "  ・Windows環境_定期自動バックアップ設定.lnk" -ForegroundColor Cyan
Write-Host "  ・Windows環境_ワンクリック復元.lnk" -ForegroundColor Cyan
