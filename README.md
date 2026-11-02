# AUV / ROV 現場対応 Windows環境 完全バックアップ＆ワンクリック復元システム

AUVやROVなどの過酷な海洋・水槽試験におけるPC故障や緊急機材交換に備え、
**「現在のWindows環境を一括バックアップ」** し、
**「まっさらなPCからワンクリックで全ソフト・全ドライバ・全環境変数を完全再現」** するためのポータブルシステムです。

---

## 🌟 特徴と再現できるもの

1. **一般ソフトウェアの一括サイレントインストール (winget)**
   - Chrome, VS Code, Git, Python 3.14, 7-Zip, WinSCP, WinMerge, TeraTerm, VLC, Bambu Studio, Fork, Everything, SourceTree 等を全自動導入
2. **AUV / ROV 現場専用ソフトウェアの自動セットアップ**
   - QGroundControl, SonarView, SeaTrac PinPoint (USBL), Moxa Driver Manager, PComm Lite, VirtualCommPort, PlotJuggler, Foxglove Studio, Nortek Nucleus 等をインストーラー同梱で自動実行
3. **ハードウェア・サードパーティドライバの丸ごと抽出＆一括復元**
   - `pnputil` により、現場で最もトラブルになりやすい **シリアル変換IC (FTDI / Moxa / Prolific / USB-UART等) のドライバ (370件以上)** を自動インストール
4. **Python 開発・解析環境の一括復元**
   - `pip freeze` により、`foxglove-websocket`, `rosbags`, `python_vehicle_simulator` 等を含む78個のpipライブラリを一発インストール
5. **システム＆ユーザー環境変数・Git設定の復元**
   - 既存のPATHを壊さずにマージ復元、`.gitconfig` 設定も自動復旧

---

## 📁 フォルダ構成

```text
winbackup/
├── RESTORE_ENVIRONMENT.bat        ★【新PC・復旧用】ダブルクリックでまっさら環境を完全再現
├── BACKUP_ENVIRONMENT.bat         ★【ローカル用】ダブルクリックで最新環境を自動バックアップ
├── BACKUP_AND_PUSH.bat            ★【GitHub用】環境バックアップ＆GitHubへ自動プッシュ
├── SCHEDULE_AUTO_BACKUP.bat       ★【定期実行】タスクスケジューラに自動バックアップを登録
├── CREATE_DESKTOP_SHORTCUTS.bat   ★ デスクトップにワンクリック用ショートカットを作成
│
├── custom_installers/             ★ AUV/ROV専用ソフトのインストーラー保管庫 (.exe / .msi / .zip)
│   ├── QGroundControl-installer-AMD64.exe
│   ├── SonarView-1.14.83.exe
│   ├── PinPoint-Setup-2.18.3.0-x86_64.exe (SeaTrac)
│   ├── moxa-win-driver-manager...zip
│   ├── NortekAS.NortekNucleus...zip
│   ├── foxglove-latest-win.exe
│   ├── PlotJuggler-3.999.9-Windows-x64.exe
│   └── VirtualCommPort-installer-2.5.3.exe
│
├── data/                          ★ バックアップデータ本体
│   ├── drivers/                   ★ サードパーティ製デバイスドライバ一式 (378件)
│   ├── winget-packages.json/.txt  ★ winget アプリケーション定義
│   ├── pip-requirements.txt       ★ Python pip パッケージ一覧
│   ├── vscode-extensions.txt      ★ VS Code / IDE 拡張機能リスト
│   ├── environment-variables.json ★ システム＆ユーザー環境変数
│   ├── installed-apps-inventory.csv★ インストール済み全ソフトの台帳リスト
│   └── gitconfig.backup           ★ Git設定バックアップ
│
├── scripts/                       ★ 自動化スクリプト本体 (PowerShell)
└── docs/                          ★ マニュアル
    ├── QUICK_START.md             ★ クイックスタートガイド
    └── DISASTER_RECOVERY_GUIDE.md ★ 海洋試験でのPC故障対策・丸ごとクローン復旧手順
```

---

## 🚀 使い方

### 1. GitHub への定期自動プッシュ（推奨）
- **タスクスケジューラ登録**: `SCHEDULE_AUTO_BACKUP.bat`（またはデスクトップの「Windows環境_定期自動バックアップ設定」）を実行し、`1` を選択すると、**毎週月曜日 09:00 に最新環境をバックアップ＆GitHubへ自動プッシュ** します。
- **今すぐプッシュしたい場合**: デスクトップの **「Windows環境_GitHubバックアップ実行」** または `BACKUP_AND_PUSH.bat` をダブルクリックするだけです。
- ※ GitHubの100MB制限を回避するため、大容量インストーラー (`custom_installers/*.exe` 等) や大容量ドライババイナリは `.gitignore` で保護され、軽量な設定・定義ファイルのみが安全にプッシュされます。

### 2. オフライン現場用バックアップ（SSD / USBメモリ）
- デスクトップの **「Windows環境_一括バックアップ」** または `BACKUP_ENVIRONMENT.bat` をダブルクリックします。
- この `winbackup` フォルダ全体を外付けポータブルSSDやUSBメモリにコピーすれば、大容量インストーラーや全ドライバも含めた完全オフライン復元パックになります。

### 3. まっさらなPCからのワンクリック復元
- 新しいPCで本リポジトリを `git clone` するか、外付けSSD/USBを挿します。
- **`RESTORE_ENVIRONMENT.bat`**（またはデスクトップショートカット）をダブルクリックするだけです。
- 全自動でソフト導入、ドライバ認識、環境変数設定、Pythonライブラリ導入が走ります。
- 完了後、PCを再起動すれば試験環境が元通りになります！

