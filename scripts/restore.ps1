# ==============================================================================
# scripts\restore.ps1 - 環境＆ソフトウェア完全復元スクリプト
# ==============================================================================

[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8

$rootDir = Split-Path -Parent $PSScriptRoot
. "$PSScriptRoot\utils.ps1"

Write-Step "Windows環境 & ソフトウェア ワンクリック復元を開始します"
Write-Info "参照先データディレクトリ: $rootDir\data"

# 1. winget の存在確認
Write-Step "Step 1: winget (Windows パッケージ マネージャー) の確認"
$hasWinget = [bool](Get-Command winget -ErrorAction SilentlyContinue)
if (-not $hasWinget) {
    Write-WarningMessage "winget が見つかりません。Microsoft Store または GitHub から App Installer をインストールしてください。"
    Write-Info "ブラウザを開いて入手先を表示します..."
    Start-Process "https://aka.ms/getwinget"
    Read-Host "winget のインストール完了後、Enterキーを押してください..."
} else {
    Write-Success "winget は利用可能です。"
}

# 2. サードパーティドライバの一括復元 (COMポート・シリアル通信・ハードウェア等)
Write-Step "Step 2: デバイスドライバの一括復元 (COMポート / USBシリアル / ハードウェア)"
$driversDir = "$rootDir\data\drivers"
if (Test-Path $driversDir) {
    $infFiles = Get-ChildItem -Path $driversDir -Filter *.inf -Recurse -ErrorAction SilentlyContinue
    if ($infFiles.Count -gt 0) {
        Write-Info "$($infFiles.Count) 個のドライバINFファイルを検出しました。システムへ一括インストール中..."
        # pnputil でサブディレクトリ含めて一括インストール
        $pnpOut = pnputil /add-driver "$driversDir\*.inf" /subdirs /install 2>&1
        Write-Success "ドライバのインポート処理が完了しました。"
    } else {
        Write-Info "ドライバINFファイルが見つかりませんでした (スキップします)。"
    }
} else {
    Write-Info "ドライバフォルダが存在しません (スキップします)。"
}

# 3. 一般ソフトウェアの一括インストール (winget)
Write-Step "Step 3: ソフトウェアの一括インストール (winget)"
$wingetJson = "$rootDir\data\winget-packages.json"
$wingetTxt = "$rootDir\data\winget-packages.txt"

$importSuccess = $false
if (Test-Path $wingetJson) {
    Write-Info "winget import による一括インストールを試みます..."
    try {
        winget import -i "$wingetJson" --accept-source-agreements --accept-package-agreements --ignore-unavailable
        if ($LASTEXITCODE -eq 0) {
            $importSuccess = $true
            Write-Success "winget import によるインストールが完了しました。"
        }
    } catch {
        Write-WarningMessage "winget import で一部スキップまたはエラーがありました。"
    }
}

# もし winget-packages.txt があれば、確実性のために個別インストールも巡回
if (Test-Path $wingetTxt) {
    Write-Info "推奨パッケージリスト (winget-packages.txt) の個別インストール確認..."
    $packages = Get-Content $wingetTxt | Where-Object { $_ -and -not $_.StartsWith('#') }
    foreach ($pkg in $packages) {
        $pkg = $pkg.Trim()
        Write-Info "パッケージ [$pkg] をインストール/確認中..."
        winget install --id "$pkg" -e --silent --accept-source-agreements --accept-package-agreements 2>&1 | Out-Null
    }
    Write-Success "winget パッケージの一括確認・導入が完了しました。"
}

# 4. システム＆ユーザー環境変数の復元
Write-Step "Step 4: システム＆ユーザー環境変数の復元"
$envFile = "$rootDir\data\environment-variables.json"
if (Test-Path $envFile) {
    try {
        $json = Get-Content $envFile -Raw -Encoding utf8 | ConvertFrom-Json
        
        # ユーザー環境変数の復元
        if ($json.User) {
            $currentPath = [Environment]::GetEnvironmentVariable('Path', 'User')
            $pathItems = @()
            if ($currentPath) { $pathItems = $currentPath -split ';' }

            $json.User.psobject.properties | ForEach-Object {
                $name = $_.Name
                $val = $_.Value
                if ($name -ieq 'Path') {
                    # PATHは既存を壊さずマージ
                    $newItems = $val -split ';'
                    foreach ($item in $newItems) {
                        if ($item -and ($pathItems -notcontains $item)) {
                            $pathItems += $item
                        }
                    }
                    [Environment]::SetEnvironmentVariable('Path', ($pathItems -join ';'), 'User')
                } else {
                    [Environment]::SetEnvironmentVariable($name, $val, 'User')
                }
            }
            Write-Success "ユーザー環境変数を復元・マージしました。"
        }

        # システム環境変数の復元 (管理者権限)
        if ($json.Machine) {
            $currentSysPath = [Environment]::GetEnvironmentVariable('Path', 'Machine')
            $sysPathItems = @()
            if ($currentSysPath) { $sysPathItems = $currentSysPath -split ';' }

            $json.Machine.psobject.properties | ForEach-Object {
                $name = $_.Name
                $val = $_.Value
                if ($name -ieq 'Path') {
                    $newItems = $val -split ';'
                    foreach ($item in $newItems) {
                        if ($item -and ($sysPathItems -notcontains $item)) {
                            $sysPathItems += $item
                        }
                    }
                    [Environment]::SetEnvironmentVariable('Path', ($sysPathItems -join ';'), 'Machine')
                } else {
                    [Environment]::SetEnvironmentVariable($name, $val, 'Machine')
                }
            }
            Write-Success "システム環境変数を復元・マージしました。"
        }
    } catch {
        Write-ErrorMessage "環境変数復元中にエラーが発生しました: $_"
    }
}

# 5. Git 設定 (.gitconfig) の復元
Write-Step "Step 5: Git設定 (.gitconfig) の復元"
$gitBackupFile = "$rootDir\data\gitconfig.backup"
$gitConfigFile = "$HOME\.gitconfig"
if (Test-Path $gitBackupFile) {
    Copy-Item -Path $gitBackupFile -Destination $gitConfigFile -Force
    Write-Success ".gitconfig を復元しました: $gitConfigFile"
} else {
    Write-Info "Git設定バックアップは見つかりませんでした (スキップ)。"
}

# 6. Python 環境 (pip packages) の復元
Write-Step "Step 6: Python 環境 (pip packages) の復元"
$pipFile = "$rootDir\data\pip-requirements.txt"
if (Test-Path $pipFile) {
    # PATHを再読み込みして最新のpython/pipを検出
    $env:Path = [Environment]::GetEnvironmentVariable('Path', 'Machine') + ';' + [Environment]::GetEnvironmentVariable('Path', 'User')
    if (Get-Command pip -ErrorAction SilentlyContinue) {
        Write-Info "pip を最新版に更新中..."
        python -m pip install --upgrade pip 2>&1 | Out-Null
        Write-Info "pip-requirements.txt からパッケージを一括インストール中 (数分かかる場合があります)..."
        python -m pip install -r "$pipFile"
        Write-Success "Python パッケージの復元が完了しました。"
    } else {
        Write-WarningMessage "pip コマンドが認識されませんでした。PC再起動後に手動で 'pip install -r data\pip-requirements.txt' を実行してください。"
    }
}

# 7. VS Code 拡張機能の復元
Write-Step "Step 7: VS Code 拡張機能の復元"
$extFile = "$rootDir\data\vscode-extensions.txt"
if (Test-Path $extFile) {
    $env:Path = [Environment]::GetEnvironmentVariable('Path', 'Machine') + ';' + [Environment]::GetEnvironmentVariable('Path', 'User')
    if (Get-Command code -ErrorAction SilentlyContinue) {
        $extensions = Get-Content $extFile | Where-Object { $_ -and -not $_.StartsWith('#') }
        foreach ($ext in $extensions) {
            $ext = $ext.Trim()
            Write-Info "VS Code 拡張機能 [$ext] をインストール中..."
            code --install-extension "$ext" --force 2>&1 | Out-Null
        }
        Write-Success "VS Code 拡張機能の復元が完了しました。"
    } else {
        Write-WarningMessage "code コマンドが見つかりませんでした (スキップ)。"
    }
}

# 8. AUV/ROV 専用ソフト (custom_installers) のインストール
Write-Step "Step 8: AUV/ROV 専用ソフトウェアのインストール (QGroundControl, SonarView, Moxa等)"
$customInstallersDir = "$rootDir\custom_installers"
if (Test-Path $customInstallersDir) {
    # まず zip があれば自動解凍
    $zipFiles = Get-ChildItem -Path $customInstallersDir -Filter *.zip -File -ErrorAction SilentlyContinue
    foreach ($zip in $zipFiles) {
        $extractFolder = Join-Path $customInstallersDir $zip.BaseName
        if (-not (Test-Path $extractFolder)) {
            Write-Info "Zipファイルを解凍中: $($zip.Name)..."
            Expand-Archive -Path $zip.FullName -DestinationPath $extractFolder -Force
            Write-Success "解凍完了: $extractFolder"
        }
    }

    # exe / msi インストーラーを順次実行
    $installerFiles = Get-ChildItem -Path $customInstallersDir -Include *.exe,*.msi -File -Recurse -ErrorAction SilentlyContinue |
        Where-Object { $_.Name -notmatch 'uninstall|unins' }

    if ($installerFiles.Count -gt 0) {
        Write-Info "$($installerFiles.Count) 個の専用インストーラーを検出しました。"
        Write-Host "※ インストーラーが画面に表示された場合は、画面の指示に従って完了させてください。" -ForegroundColor Yellow

        foreach ($inst in $installerFiles) {
            Write-Info "起動中: $($inst.Name)..."
            # サイレント引数の推測
            $args = ""
            if ($inst.Extension -ieq '.msi') {
                $args = "/i `"$($inst.FullName)`" /qn"
                Start-Process "msiexec.exe" -ArgumentList $args -Wait
            } else {
                # 一般的なインストーラーの起動 (待機)
                $proc = Start-Process -FilePath $inst.FullName -Wait -PassThru
            }
            Write-Success "完了または次のインストーラーへ進みます: $($inst.Name)"
        }
    } else {
        Write-Info "custom_installers にインストーラーがありませんでした。"
    }
}

Write-Step "すべての環境復元処理が完了しました！"
Write-Host "システム設定やドライバ、PATHの反映のため、PCの再起動を推奨します。" -ForegroundColor Green

