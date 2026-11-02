# AUV / ROV 現場専用ソフトウェア・インストーラー置き場

このフォルダには、**Windows パッケージマネージャー (winget) に登録されていない現場専用のソフトウェア・インストーラー (.exe / .msi / .zip)** を格納します。

新PCで `🚀_RESTORE_ENVIRONMENT.bat` を実行した際、このフォルダ内にあるインストーラーが**全自動で順次実行**され、一括導入されます。

---

## 格納対象の主要ソフトウェア一覧と入手元

| ソフトウェア名 | バージョン (現在の環境) | 用途・機能 | 公式入手先 / ダウンロードURL |
| :--- | :--- | :--- | :--- |
| **QGroundControl** | 5.1.x / 最新 | AUV/ROV/ArduSub/PX4 地上管制ステーション (GCS) | [QGroundControl Releases](https://github.com/mavlink/qgroundcontrol/releases) |
| **SonarView** | 1.14.83 | Cerulean Sonar 製ソナービジュアライザ | [Cerulean Sonar Releases](https://github.com/CeruleanSonar/SonarView/releases) |
| **SeaTrac PinPoint** | 2.18.3.0 | Blueprint Subsea 製 USBL水中音響測位システム | [Blueprint Subsea Software](https://www.blueprintsubsea.com/) |
| **Moxa Windows Driver Manager** | 4.5 | Moxa 製シリアルデバイスサーバー (NPort等) ドライバ | [Moxa Support & Downloads](https://www.moxa.com/en/support) |
| **PComm Lite** | 1.9 | Moxa 製シリアル通信診断・テストユーティリティ | [Moxa PComm Lite](https://www.moxa.com/en/products/industrial-edge-connectivity/serial-device-servers/serial-media-converters/pcomm-lite) |
| **VirtualCommPort** | 2.53 | NetBurner 製仮想COMポートドライバー | [NetBurner Tools](https://www.netburner.com/) |
| **PlotJuggler** | 3.999.9 / 4.x | 時系列データ・ROSトピックプロットツール | [PlotJuggler Releases](https://github.com/facontidavide/PlotJuggler/releases) |
| **Foxglove Studio** | 3.4.0 | ROS / ロボティクスデータ可視化プラットフォーム | [Foxglove Download](https://foxglove.dev/download) |
| **Nortek Nucleus** | 2.8.2.0 | Nortek 製 DVL (ドップラー流速ログ) 制御ソフト | [Nortek AS Software](https://www.nortekgroup.com/) |

---

## 使い方・メンテナンス

1. `🛠️_BACKUP_ENVIRONMENT.bat` を実行すると、ユーザーの `Downloads` フォルダ内に上記インストーラーが存在する場合、**自動的にこのフォルダへコピー・集約**されます。
2. 新しいインストーラーを入手した場合は、このフォルダに `.exe` や `.msi`、`.zip` をそのまま配置してください。
3. `🚀_RESTORE_ENVIRONMENT.bat` 実行時に、`.zip` は自動解凍され、各インストーラーが自動的に起動します。

