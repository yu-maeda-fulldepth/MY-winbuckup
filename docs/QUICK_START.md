# AUV/ROV 現場環境 バックアップ＆ワンクリック復元 クイックスタートガイド

海中ロボット（AUV / ROV）の現場試験では、水濡れ、塩害、電源サージ、落下などの過酷な環境により、PCが突然故障することがあります。
本システムは、**「普段の環境をワンクリックでバックアップ」** し、故障発生時には **「まっさらなPCへワンクリックで全ソフト・ドライバ・環境変数を再現」** できるように設計されています。

---

## 📁 ディレクトリ構成

```text
winbackup/
├── 🚀_RESTORE_ENVIRONMENT.bat        ★【新PC・復旧用】ダブルクリックでまっさら環境を完全再現
├── 🛠️_BACKUP_ENVIRONMENT.bat         ★【普段用】ダブルクリックで現在の環境を最新バックアップ
├── 📌_CREATE_DESKTOP_SHORTCUTS.bat    ★ デスクトップに上記2つのワンクリックショートカットを作成
│
├── custom_installers/                ★ AUV/ROV専用ソフト（QGroundControl, SonarView, Moxa等）のインストーラー
├── data/                             ★ バックアップデータ（ドライバ、winget定義、Python pip、環境変数）
│   ├── drivers/                      ★ サードパーティドライバ（COMポート、FTDI、USBシリアル等）
│   ├── installed-apps-inventory.csv  ★ 現在インストールされている全アプリの台帳
│   ├── winget-packages.json/.txt     ★ winget で導入可能なアプリ一覧
│   ├── pip-requirements.txt          ★ Python パッケージ一覧 (ROS, VehicleSimulator等)
│   ├── environment-variables.json    ★ ユーザー＆システム環境変数
│   └── gitconfig.backup              ★ Git設定
├── scripts/                          ★ PowerShell 自動化スクリプト本体
└── docs/                             ★ 運用マニュアル・トラブルシューティング
```

---

## 🛠️ 普段の運用：バックアップの更新手順

1. `📌_CREATE_DESKTOP_SHORTCUTS.bat` を実行して、デスクトップにショートカットを作成します。
2. 新しいソフトを入れたり、環境を変更した際は、デスクトップの **「🛠️ 環境バックアップ実行」**（または `🛠️_BACKUP_ENVIRONMENT.bat`）をダブルクリックします。
3. UAC（管理者権限）の確認が出たら「はい」を押します。
4. 全自動で以下のバックアップが行われます：
   - winget アプリケーションリスト
   - 全サードパーティ製デバイスドライバ（COMポート、FTDI等）
   - Python pip パッケージ (`pip freeze`)
   - VS Code / IDE 拡張機能
   - システム＆ユーザー環境変数
   - Git設定 (`.gitconfig`)
   - Downloadsフォルダ内にある専用インストーラーの同期
5. **この `winbackup` フォルダ全体を、試験用外付けポータブルSSD、USBメモリ、またはGoogle Drive等に同期・コピーして現場に持参してください。**

---

## 🚀 現場での復元手順（PCが故障したとき）

1. 現場の予備PC、または新調したクリーンなWindows PCを起動します。
2. 外付けSSDまたはUSBメモリを接続し、`winbackup` フォルダを開きます。
3. **「🚀_RESTORE_ENVIRONMENT.bat」をダブルクリックします。**
4. UAC（管理者権限）の確認が出たら「はい」を押します。
5. 全自動で以下の処理が実行されます：
   1. **winget の準備確認**
   2. **サードパーティドライバの一括インストール**（`pnputil` により、FTDIやMoxa、USBシリアルのドライバが即座に認識）
   3. **一般ソフトウェアの一括サイレントインストール**（Chrome, Git, VS Code, Python 3.14, 7-Zip, WinSCP, WinMerge, TeraTerm, VLC, BambuStudio等）
   4. **環境変数の復元・マージ**（既存のPATHを壊さずに安全マージ）
   5. **Git設定の復元**
   6. **Python 環境の自動復元**（`pip install -r pip-requirements.txt`）
   7. **VS Code 拡張機能の自動導入**
   8. **AUV/ROV専用ソフトの一括起動・インストール**（`custom_installers\` 内の QGroundControl, SonarView, SeaTrac PinPoint, Moxa, VirtualCommPort, Foxglove, PlotJuggler等）
6. 処理完了後、PCを再起動すれば、以前と全く同一の試験環境が完成します！

