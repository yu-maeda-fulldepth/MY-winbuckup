# ==============================================================================
# scripts\backup_and_push.ps1 - バックアップ更新 ＆ GitHubプッシュ自動化
# ==============================================================================

[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8

$rootDir = Split-Path -Parent $PSScriptRoot
. "$PSScriptRoot\utils.ps1"

Write-Step "Windows環境バックアップ ＆ GitHubプッシュ処理を開始します"

# 1. バックアップスクリプトを実行
Write-Info "最新のバックアップデータを収集中..."
& "$PSScriptRoot\backup.ps1"

# 2. Git 状態チェック
Write-Step "Step 9: Git ステータス確認 ＆ コミット"
Set-Location $rootDir

# safe.directory の確認
git config --global --add safe.directory $rootDir 2>&1 | Out-Null

git add -A

# 差分があるかチェック
$gitDiff = git status --porcelain
if ($gitDiff) {
    $now = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $commitMsg = "Auto backup: $now"
    Write-Info "変更を検出しました。コミットを作成します: $commitMsg"
    git commit -m "$commitMsg"
    
    Write-Step "Step 10: GitHub へプッシュ"
    Write-Info "リポジトリ (origin/main) へプッシュ中..."
    $pushResult = git push origin main 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Success "GitHub へのプッシュが正常に完了しました！"
        Write-Host "リポジトリ: https://github.com/yu-maeda-fulldepth/MY-winbuckup" -ForegroundColor Green
    } else {
        Write-ErrorMessage "GitHub へのプッシュに失敗しました:"
        $pushResult | ForEach-Object { Write-Host "  $_" -ForegroundColor Red }
        Write-WarningMessage "認証が必要な場合は 'git push origin main' を手動実行して認証を完了させてください。"
    }
} else {
    Write-Success "前回のバックアップから変更はありませんでした。プッシュをスキップします。"
}

Write-Step "バックアップ ＆ プッシュ処理が完了しました"
