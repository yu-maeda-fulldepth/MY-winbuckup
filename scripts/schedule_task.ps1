# ==============================================================================
# scripts\schedule_task.ps1 - Windows タスクスケジューラ登録＆管理
# ==============================================================================

param(
    [string]$Option = ""
)

[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8

$rootDir = Split-Path -Parent $PSScriptRoot
. "$PSScriptRoot\utils.ps1"

Write-Step "Windows タスク スケジューラ 自動バックアップ設定"

$taskName = "WinBackup_AutoPush_GitHub"
$existingTask = Get-ScheduledTask -TaskName $taskName -ErrorAction SilentlyContinue

Write-Host "現在の状態: " -NoNewline
if ($existingTask) {
    Write-Host "【登録済み】 (状態: $($existingTask.State))" -ForegroundColor Green
    $taskInfo = Get-ScheduledTaskInfo -TaskName $taskName -ErrorAction SilentlyContinue
    if ($taskInfo) {
        Write-Host "  ・最終実行日時: $($taskInfo.LastRunTime)"
        Write-Host "  ・次回実行日時: $($taskInfo.NextRunTime)"
    }
} else {
    Write-Host "【未登録】" -ForegroundColor Yellow
}

$choice = $Option
if ([string]::IsNullOrWhiteSpace($choice)) {
    Write-Host ""
    Write-Host "実行したい操作の番号を入力してください:" -ForegroundColor Cyan
    Write-Host "  [1] 毎週月曜日 09:00 に自動実行するタスクを登録 (推奨)"
    Write-Host "  [2] 毎日 18:00 (退勤時) に自動実行するタスクを登録"
    Write-Host "  [3] PCログオン時 (起動時) に自動実行するタスクを登録"
    Write-Host "  [4] 既存の自動タスクを解除 (削除) する"
    Write-Host "  [Q] 何もせず終了"
    Write-Host ""

    $choice = Read-Host "選択 (1/2/3/4/Q) [初期値: 1]"
    if ([string]::IsNullOrWhiteSpace($choice)) { $choice = "1" }
}

if ($choice -eq 'Q' -or $choice -eq 'q') {
    Write-Info "終了します。"
    exit 0
}

if ($choice -eq '4') {
    if ($existingTask) {
        Unregister-ScheduledTask -TaskName $taskName -Confirm:$false
        Write-Success "タスク [$taskName] を削除しました。"
    } else {
        Write-Info "登録されているタスクはありません。"
    }
    exit 0
}

# トリガー設定
$trigger = $null
switch ($choice) {
    "1" {
        $trigger = New-ScheduledTaskTrigger -Weekly -DaysOfWeek Monday -At 09:00
        Write-Info "トリガー: 毎週月曜日 09:00"
    }
    "2" {
        $trigger = New-ScheduledTaskTrigger -Daily -At 18:00
        Write-Info "トリガー: 毎日 18:00"
    }
    "3" {
        $trigger = New-ScheduledTaskTrigger -AtLogOn
        Write-Info "トリガー: PCログオン時"
    }
    Default {
        Write-ErrorMessage "不正な選択です。"
        exit 1
    }
}

# アクション設定 (管理者権限で実行、バックグラウンド)
$scriptPath = "$rootDir\scripts\backup_and_push.ps1"
$action = New-ScheduledTaskAction `
    -Execute "powershell.exe" `
    -Argument "-NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -File `"$scriptPath`"" `
    -WorkingDirectory "$rootDir"

# 設定 (電源接続時のみでなくバッテリーでも実行、遅延実行許可)
$settings = New-ScheduledTaskSettingsSet `
    -AllowStartIfOnBatteries `
    -DontStopIfGoingOnBatteries `
    -StartWhenAvailable `
    -RunOnlyIfNetworkAvailable

# 登録 (管理者権限があればHighest、一般権限ならLimited)
try {
    # 既存があれば先に削除
    if ($existingTask) {
        Unregister-ScheduledTask -TaskName $taskName -Confirm:$false
    }

    $currentUser = [System.Security.Principal.WindowsIdentity]::GetCurrent().Name
    $runLevel = "Limited"
    if (Test-IsAdmin) {
        $runLevel = "Highest"
    }

    Register-ScheduledTask `
        -TaskName $taskName `
        -Description "Windows環境バックアップを自動更新し、GitHub (MY-winbuckup) へ自動プッシュします。" `
        -Action $action `
        -Trigger $trigger `
        -Settings $settings `
        -User $currentUser `
        -RunLevel $runLevel | Out-Null

    Write-Success "タスク スケジューラに [$taskName] を正常に登録しました！ (実行レベル: $runLevel)"
    Write-Host "※ 指定時刻にPCが起動していなかった場合も、次回起動時に自動で実行されます。" -ForegroundColor Cyan
} catch {
    Write-ErrorMessage "タスク登録中にエラーが発生しました: $_"
    Write-WarningMessage "管理者権限が必要な場合があります。『SCHEDULE_AUTO_BACKUP.bat』を右クリックして『管理者として実行』してください。"
}
