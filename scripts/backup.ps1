# ==============================================================================
# scripts\backup.ps1 - 環境＆ソフトウェア完全バックアップスクリプト
# ==============================================================================

[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8

$rootDir = Split-Path -Parent $PSScriptRoot
. "$PSScriptRoot\utils.ps1"

Write-Step "Windows環境 & ソフトウェア バックアップ処理を開始します"
Write-Info "バックアップ保存先: $rootDir\data"

# 1. winget パッケージリストのエクスポート
Write-Step "Step 1: winget パッケージリストのバックアップ"
try {
    if (Get-Command winget -ErrorAction SilentlyContinue) {
        $wingetJson = "$rootDir\data\winget-packages.json"
        Write-Info "winget export を実行中..."
        # winget export はソース同意オプションやエラーを無視してエクスポート
        winget export -o "$wingetJson" --accept-source-agreements 2>&1 | Out-Null
        if (Test-Path $wingetJson) {
            Write-Success "winget-packages.json を作成しました。"
        }

        # フォールバック用: wingetで直接インストール可能なIDリストも作成
        $fallbackPackages = @(
            "7zip.7zip",
            "voidtools.Everything",
            "Gyan.FFmpeg",
            "Fork.Fork",
            "Git.Git",
            "Google.Chrome",
            "Google.GoogleDrive",
            "Google.JapaneseIME",
            "Microsoft.OpenJDK.17",
            "Microsoft.VisualStudioCode",
            "OpenJS.NodeJS.LTS",
            "Python.Python.3.14",
            "sakura-editor.sakura",
            "Atlassian.Sourcetree",
            "TeraTermProject.teraterm5",
            "VideoLAN.VLC",
            "WinMerge.WinMerge",
            "WinSCP.WinSCP",
            "Bambulab.Bambustudio",
            "Google.PlatformTools",
            "Microsoft.VCRedist.2015+.x64",
            "Microsoft.VCRedist.2015+.x86"
        )
        $fallbackFile = "$rootDir\data\winget-packages.txt"
        $fallbackPackages | Out-File -FilePath $fallbackFile -Encoding utf8
        Write-Success "winget-packages.txt (推奨パッケージリスト) を作成しました。"
    } else {
        Write-WarningMessage "winget コマンドが見つかりませんでした。"
    }
} catch {
    Write-ErrorMessage "winget エクスポート中にエラーが発生しました: $_"
}

# 2. インストール済み全アプリ台帳の作成 (レジストリ)
Write-Step "Step 2: インストール済み全ソフトウェア台帳の作成"
try {
    $regPaths = @(
        'HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*',
        'HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*',
        'HKCU:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*'
    )
    $installedApps = Get-ItemProperty -Path $regPaths -ErrorAction SilentlyContinue |
        Where-Object { $_.DisplayName -and $_.SystemComponent -ne 1 } |
        Select-Object DisplayName, DisplayVersion, Publisher, InstallLocation, UninstallString, HelpLink, URLInfoAbout |
        Sort-Object DisplayName

    $inventoryCsv = "$rootDir\data\installed-apps-inventory.csv"
    $installedApps | Export-Csv -Path $inventoryCsv -NoTypeInformation -Encoding utf8
    Write-Success "全ソフトウェア台帳を作成しました (件数: $($installedApps.Count) 件): $inventoryCsv"
} catch {
    Write-ErrorMessage "ソフトウェア台帳の作成中にエラーが発生しました: $_"
}

# 3. ハードウェアドライバのバックアップ (COMポート・FTDI・シリアル・PCデバイス等)
Write-Step "Step 3: ハードウェア＆サードパーティドライバのバックアップ"
$driversDir = "$rootDir\data\drivers"
if (-not (Test-Path $driversDir)) {
    New-Item -ItemType Directory -Path $driversDir -Force | Out-Null
}
try {
    Write-Info "pnputil を用いてサードパーティドライバを抽出中 (数分かかる場合があります)..."
    $pnpResult = pnputil /export-driver * "$driversDir" 2>&1
    $exportedInfCount = (Get-ChildItem -Path $driversDir -Filter *.inf -Recurse -ErrorAction SilentlyContinue).Count
    Write-Success "サードパーティドライバのバックアップ完了: $exportedInfCount 件のINFドライバを抽出しました。"
} catch {
    Write-ErrorMessage "ドライバ抽出中にエラーが発生しました: $_"
}

# 4. Python pip パッケージのバックアップ
Write-Step "Step 4: Python pip パッケージのバックアップ"
$pipFile = "$rootDir\data\pip-requirements.txt"
try {
    if (Get-Command pip -ErrorAction SilentlyContinue) {
        $pipFreeze = pip freeze
        $pipFreeze | Out-File -FilePath $pipFile -Encoding utf8
        Write-Success "Python パッケージ一覧を保存しました: $pipFile (パッケージ数: $($pipFreeze.Count))"
    } else {
        Write-WarningMessage "pip コマンドが見つかりませんでした。"
    }
} catch {
    Write-ErrorMessage "pip freeze 実行中にエラーが発生しました: $_"
}

# 5. VS Code / Antigravity IDE 拡張機能のバックアップ
Write-Step "Step 5: VS Code 拡張機能リストのバックアップ"
$extFile = "$rootDir\data\vscode-extensions.txt"
try {
    $extensions = @()
    if (Get-Command code -ErrorAction SilentlyContinue) {
        $extensions += (code --list-extensions)
    }
    $extDirs = @("$HOME\.vscode\extensions", "$HOME\.antigravity-ide\extensions")
    foreach ($dir in $extDirs) {
        if (Test-Path $dir) {
            $dirs = Get-ChildItem -Path $dir -Directory | Select-Object -ExpandProperty Name
            foreach ($d in $dirs) {
                # バージョン番号のハイフン以降を取り除いて拡張機能IDっぽく整形
                if ($d -match '^([a-zA-Z0-9_-]+\.[a-zA-Z0-9_-]+)-[0-9]') {
                    $extensions += $matches[1]
                }
            }
        }
    }
    $extensions = $extensions | Where-Object { $_ } | Select-Object -Unique | Sort-Object
    $extensions | Out-File -FilePath $extFile -Encoding utf8
    Write-Success "VS Code 拡張機能リストを保存しました: $extFile (拡張機能数: $($extensions.Count))"
} catch {
    Write-ErrorMessage "拡張機能リスト作成中にエラーが発生しました: $_"
}

# 6. 環境変数 (User & System) のバックアップ
Write-Step "Step 6: システム＆ユーザー環境変数のバックアップ"
$envFile = "$rootDir\data\environment-variables.json"
try {
    $userEnv = [Environment]::GetEnvironmentVariables('User')
    $machineEnv = [Environment]::GetEnvironmentVariables('Machine')

    $envData = @{
        BackupDate = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")
        User = $userEnv
        Machine = $machineEnv
    }
    $envData | ConvertTo-Json -Depth 5 | Out-File -FilePath $envFile -Encoding utf8
    Write-Success "環境変数を保存しました: $envFile"
} catch {
    Write-ErrorMessage "環境変数のバックアップ中にエラーが発生しました: $_"
}

# 7. Git 設定のバックアップ
Write-Step "Step 7: Git設定 (.gitconfig) のバックアップ"
$gitConfigFile = "$HOME\.gitconfig"
$gitBackupFile = "$rootDir\data\gitconfig.backup"
try {
    if (Test-Path $gitConfigFile) {
        Copy-Item -Path $gitConfigFile -Destination $gitBackupFile -Force
        Write-Success ".gitconfig をバックアップしました: $gitBackupFile"
    } else {
        Write-Info ".gitconfig は見つかりませんでした。"
    }
} catch {
    Write-ErrorMessage "Git設定バックアップ中にエラーが発生しました: $_"
}

# 8. AUV/ROV 専用ソフトのインストーラー自動収集 (Downloadsフォルダより)
Write-Step "Step 8: AUV/ROV 専用ソフトのインストーラー自動収集"
$customInstallersDir = "$rootDir\custom_installers"
$targetKeywords = @('QGroundControl', 'SonarView', 'PinPoint', 'SeaTrac', 'moxa', 'PlotJuggler', 'foxglove', 'VirtualCommPort', 'NortekNucleus')
$downloadsDir = "$HOME\Downloads"

try {
    if (Test-Path $downloadsDir) {
        Write-Info "Downloads フォルダから AUV/ROV 関連インストーラーを探索中..."
        $foundFiles = Get-ChildItem -Path $downloadsDir -Include *.exe,*.msi,*.zip -File -Recurse -ErrorAction SilentlyContinue |
            Where-Object {
                $name = $_.Name
                foreach ($kw in $targetKeywords) {
                    if ($name -match $kw) { return $true }
                }
                return $false
            }

        foreach ($file in $foundFiles) {
            $dest = Join-Path $customInstallersDir $file.Name
            if (-not (Test-Path $dest)) {
                Write-Info "インストーラーをコピー中: $($file.Name) ($( [math]::Round($file.Length / 1MB, 1) ) MB)"
                Copy-Item -Path $file.FullName -Destination $dest -Force
                Write-Success "収集完了: $($file.Name)"
            } else {
                Write-Info "既に存在します: $($file.Name)"
            }
        }
    }
} catch {
    Write-ErrorMessage "インストーラー収集中にエラーが発生しました: $_"
}

Write-Step "すべてのバックアップ処理が完了しました！"
Write-Host "保存先ディレクトリ: $rootDir" -ForegroundColor Green
Write-Host "この winbackup フォルダ全体を外付けSSDやUSBメモリに保存しておけば、" -ForegroundColor Cyan
Write-Host "故障時や新PCで『🚀_RESTORE_ENVIRONMENT.bat』を実行するだけで即座に復元できます。" -ForegroundColor Cyan
