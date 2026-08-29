# パッケージ管理設計

## 1. 目的

この文書は、Linux初期セットアップで導入するパッケージの管理方法を定義する。

従来は各OS用スクリプトがパッケージ一覧を直接保持していたため、同じ用途のツールが複数ファイルに重複し、追加や削除の際にOSごとの更新漏れが起きやすかった。

現在の設計では、必要なツールを用途別の論理グループとして一元管理し、OSごとのスクリプトが論理名を実際のパッケージ名へ変換する。これにより、「何を導入するか」と「各OSでどう導入するか」を分離する。

## 2. 設計方針

- 論理的に必要なツールは `distro/packages.sh` に一度だけ定義する。
- パッケージ名のディストリビューション差分は各OSの `map_package()` で吸収する。
- OS固有スクリプトは、パッケージ更新、リポジトリ設定、サービス有効化などの固有処理を担当する。
- Debian系の elementary OS と Raspberry Pi OS は、可能な限りUbuntu向け処理を再利用する。
- dotfilesを設定する既存の `distro/common.sh` は、パッケージ管理とは責務が異なるため変更しない。
- 論理名から同じ実パッケージへ複数回変換された場合は、インストール前に重複を除外する。

## 3. ファイル構成と責務

```text
setup.sh
  ├── distro/packages.sh       論理グループと共通の解決処理
  ├── distro/ubuntu.sh         APT向けマッピングとインストール
  ├── distro/elementary.sh     Ubuntu向け処理を再利用
  ├── distro/raspberrypi.sh    Ubuntu向け処理とPi固有マッピング
  ├── distro/rocky.sh          DNF向けマッピングとインストール
  ├── distro/arch.sh           pacman向けマッピングとインストール
  └── distro/common.sh         OS共通のdotfiles設定
```

`setup.sh` は `/etc/os-release` の `ID` を読み、対応するOS用スクリプトを読み込む。その後、OS側が提供する `install_packages()` と、dotfiles用の `setup_common()` を順番に実行する。

## 4. 論理パッケージグループ

### common

日常的なシェル操作、ファイル操作、検索、Git作業に使用する基本ツールを管理する。

```text
git curl wget vim tmux htop tree jq unzip zip rsync ripgrep fd
```

### development

C/C++を中心とするビルド、デバッグ、静的検査に必要なツールを管理する。

```text
build-essential clang cmake ninja pkg-config gdb valgrind strace ltrace shellcheck
```

`build-essential` は論理名であり、Ubuntu系では同名パッケージ、Rocky Linuxでは `Development Tools` グループ、Arch Linuxでは `base-devel` に対応する。

### network

ネットワークの疎通確認、名前解決、性能測定、パケット調査に使用するツールを管理する。

```text
netcat nmap tcpdump dnsutils traceroute iperf3 ethtool lsof
```

### python

Pythonプロジェクトの実行環境と、分離された環境を作るための基盤だけを管理する。

```text
python3 pip venv pipx
```

requests、NumPy、FastAPIなどのアプリケーションライブラリはグローバルにインストールしない。プロジェクトごとの仮想環境またはuvで管理する。

ruff、mypy、pre-commitなどのPython製CLIもOSパッケージのバージョンへ固定せず、次のいずれかで独立して管理する。

```bash
pipx install ruff
uv tool install ruff
```

uv自体の導入処理は現時点ではセットアップに含めず、公式のスタンドアロンインストーラーなどで導入できる余地を残す。

### raspberrypi

GPIO、I2C、MQTTなどRaspberry Pi固有の利用に必要なツールを管理する。このグループはRaspberry Pi OSでのみ選択する。

```text
raspi-config i2c-tools gpiozero lgpio gpiod mqtt-client
```

## 5. パッケージ名のマッピング

論理名と実パッケージ名が同じ場合、各OSの `map_package()` は論理名をそのまま使用する。名前が異なるものだけを明示的に変換する。

代表的な変換は次のとおり。

| 論理名 | Ubuntu / elementary | Raspberry Pi OS | Rocky Linux | Arch Linux |
| --- | --- | --- | --- | --- |
| `build-essential` | `build-essential` | `build-essential` | `Development Tools` | `base-devel` |
| `fd` | `fd-find` | `fd-find` | `fd-find` または `fd` | `fd` |
| `ninja` | `ninja-build` | `ninja-build` | `ninja-build` | `ninja` |
| `pkg-config` | `pkg-config` | `pkg-config` | `pkgconf-pkg-config` | `pkgconf` |
| `netcat` | `netcat-openbsd` | `netcat-openbsd` | `nmap-ncat` | `openbsd-netcat` |
| `dnsutils` | `dnsutils` | `dnsutils` | `bind-utils` | `bind` |
| `python3` | `python3` | `python3` | `python3` | `python` |
| `pip` | `python3-pip` | `python3-pip` | `python3-pip` | `python-pip` |
| `venv` | `python3-venv` | `python3-venv` | `python3` | `python` |
| `pipx` | `pipx` | `pipx` | `pipx` | `python-pipx` |
| `gpiozero` | 対象外 | `python3-gpiozero` | 対象外 | 対象外 |
| `lgpio` | 対象外 | `python3-lgpio` | 対象外 | 対象外 |
| `mqtt-client` | 対象外 | `mosquitto-clients` | 対象外 | 対象外 |

Rocky Linuxの `fd` は利用可能なパッケージを実行時に確認し、`fd-find`、`fd` の順で選択する。どちらも見つからない場合は警告を表示し、ほかのパッケージの解決を継続する。

## 6. 処理フロー

```text
/etc/os-releaseを読む
        ↓
OS用スクリプトを読み込む
        ↓
使用する論理グループを選ぶ
        ↓
各論理名をmap_package()で変換
        ↓
変換後の重複を除外
        ↓
OSのパッケージマネージャーでインストール
        ↓
GitHub CLIとSSHをOS固有の方法で設定
        ↓
共通dotfilesを設定
```

Ubuntu、elementary OS、Rocky Linux、Arch Linuxは `common development network python` を選択する。Raspberry Pi OSはこれらに `raspberrypi` を追加する。

## 7. Debian系での再利用

`distro/ubuntu.sh` はAPT系の共通実装として、次の機能を提供する。

- APTによる更新とパッケージインストール
- Debian系のパッケージ名変換を行う `map_debian_package()`
- GitHub CLIリポジトリの設定
- SSHサービスの有効化

`distro/elementary.sh` は表示名を設定してUbuntu実装を読み込むだけである。

`distro/raspberrypi.sh` はUbuntu実装を読み込んだ後、選択グループへ `raspberrypi` を追加し、Pi固有パッケージだけを上書きして変換する。それ以外は `map_debian_package()` に委譲する。

## 8. OS固有処理

パッケージの論理グループ外で、既存動作を維持するために次の処理をOS側へ残す。

- Ubuntu系: GitHub CLI公式APTリポジトリの設定
- Rocky Linux: EPELとGitHub CLIリポジトリの設定、`Development Tools` の導入
- Arch Linux: `github-cli` と `openssh` の導入
- 全OS: SSHサービスの有効化

これらは単純な名前変換では表現できないリポジトリ操作、パッケージグループ操作、サービス操作であるため、共通の論理パッケージ定義へ含めない。

## 9. 拡張方法

### ツールを追加する場合

1. 用途に対応する `distro/packages.sh` の論理グループへ論理名を追加する。
2. OSごとに名前が異なる場合だけ、各OSの `map_package()` へ変換を追加する。
3. 全OSでグループを解決し、同じ用途のパッケージが重複していないことを確認する。

### グループを追加する場合

1. `distro/packages.sh` に配列を追加する。
2. `install_package_groups()` のグループ選択へ追加する。
3. 対象OSの `package_groups()` または `install_package_groups` 呼び出しへグループ名を追加する。
4. OS固有名があれば `map_package()` に追加する。

### OSを追加する場合

1. `distro/<os>.sh` を作成する。
2. `distro/packages.sh` を読み込む。
3. `install_packages()` と `map_package()` を実装する。
4. `setup.sh` のOS判定へ追加する。
5. 既存OSと同系統なら、UbuntuとRaspberry Pi OSのように既存処理の再利用を優先する。

## 10. 検証方針

変更時は最低限、次を確認する。

```bash
bash -n setup.sh distro/*.sh
git diff --check
```

加えて、各OSの `map_package()` を読み込んで論理グループを展開し、次を確認する。

- 必須の論理名が実パッケージ名へ解決されること
- 同じ実パッケージが重複しないこと
- Raspberry Pi固有グループが他OSへ混入しないこと
- netcatなど名称の異なるパッケージが正しく変換されること
