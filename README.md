# linux-setup

自分用の Linux 初期セットアップを自動化するためのリポジトリです。

ディストリビューションごとにパッケージ管理処理を分離しつつ、Vim・Bash aliases・Git 設定などの dotfiles は共通で管理します。

## 対応OS

現在は以下を想定しています。

* elementary OS
* Ubuntu
* Raspberry Pi OS
* Rocky Linux
* Arch Linux

`setup.sh` が `/etc/os-release` を読み取り、実行中のOSを判定して対応するセットアップスクリプトを呼び出します。

## ディレクトリ構成

```text
linux-setup/
├── setup.sh
├── distro/
│   ├── common.sh
│   ├── elementary.sh
│   ├── ubuntu.sh
│   ├── raspbian.sh
│   ├── rocky.sh
│   └── arch.sh
├── dotfiles/
│   ├── bash_aliases
│   ├── vimrc
│   └── gitconfig
└── README.md
```

## セットアップの流れ

新しいLinux環境では、最初にGitだけを手動でインストールします。

```text
Linuxをインストール
        ↓
Gitを手動でインストール
        ↓
このリポジトリをclone
        ↓
setup.shを実行
        ↓
OSごとのパッケージをインストール
        ↓
共通dotfilesを設定
```

Gitはこのリポジトリ自体を取得するために必要なので、セットアップスクリプトの前提としています。

## 1. Gitをインストール

### elementary OS / Ubuntu / Raspberry Pi OS

```bash
sudo apt update
sudo apt install -y git
```

### Rocky Linux

```bash
sudo dnf install -y git
```

### Arch Linux

```bash
sudo pacman -Sy --needed git
```

Gitが利用できることを確認します。

```bash
git --version
```

## 2. リポジトリをclone

```bash
git clone https://github.com/sishihara0706/linux-setup.git
cd linux-setup
```

自分のGitHubリポジトリURLに置き換えてください。

## 3. セットアップを実行

初回のみ `setup.sh` に実行権限を付与します。

```bash
chmod +x setup.sh
```

その後、セットアップを実行します。

```bash
./setup.sh
```

## setup.sh の役割

`setup.sh` は `/etc/os-release` を読み取り、現在のLinuxディストリビューションを判定します。

例えば elementary OS では、

```text
setup.sh
  ↓
/etc/os-release を読み込む
  ↓
ID=elementary
  ↓
distro/elementary.sh
  ↓
aptによるパッケージインストール
  ↓
distro/common.sh
  ↓
dotfiles設定
```

という流れになります。

Rocky Linuxなら `rocky.sh`、Arch Linuxなら `arch.sh` が選択されます。
Raspberry Pi OS では `ID=raspbian` を判定し、`raspbian.sh` が選択されます。

## OSごとの処理

OS依存の処理は `distro/` 以下に配置します。

### elementary OS

```text
distro/elementary.sh
```

`apt` を使用して、開発ツールや基本コマンドをインストールします。

### Ubuntu

```text
distro/ubuntu.sh
```

Ubuntu向けの `apt` パッケージをインストールします。

### Raspberry Pi OS

```text
distro/raspbian.sh
```

Raspberry Pi OS向けの `apt` パッケージをインストールし、SSHを有効化します。

### Rocky Linux

```text
distro/rocky.sh
```

`dnf` を使用して、Rocky Linux向けのパッケージや開発ツールをインストールします。

### Arch Linux

```text
distro/arch.sh
```

`pacman` を使用して必要なパッケージをインストールします。

## 共通設定

OSに依存しない設定は、

```text
distro/common.sh
```

で管理します。

現在は主に以下を行います。

* `.bash_aliases` の設定
* `.vimrc` の設定
* `.gitconfig` の設定
* Gitのユーザー名・メールアドレスの対話設定
* `.bashrc` から `.bash_aliases` を読み込む設定
* 既存dotfilesのバックアップ
* リポジトリ内dotfilesへのシンボリックリンク作成

## dotfiles

実際の設定ファイルは `dotfiles/` に保存します。

### Bash aliases

```text
dotfiles/bash_aliases
```

例:

```bash
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'

alias ..='cd ..'
alias ...='cd ../..'

alias grep='grep --color=auto'

alias gs='git status'
alias ga='git add'
alias gc='git commit'
alias gd='git diff'
alias gl='git log --oneline --graph --decorate --all'

alias ports='ss -tulpn'
```

### Vim

```text
dotfiles/vimrc
```

Vimの共通設定を管理します。

セットアップ後は、例えば次のような構成になります。

```text
~/.vimrc
    ↓ symbolic link
~/linux-setup/dotfiles/vimrc
```

そのため、

```bash
vim ~/.vimrc
```

で設定を変更すると、実際にはリポジトリ内の `dotfiles/vimrc` が変更されます。

変更後はそのままGitで管理できます。

```bash
git diff
git add dotfiles/vimrc
git commit -m "Update vim config"
git push
```

### Git

```text
dotfiles/gitconfig
```

共通のGit設定を管理します。

ユーザー名やメールアドレスは `setup.sh` の実行中に入力します。入力した値は、Git管理されない `~/.gitconfig.local` に保存されます。既存の値がある場合は初期値として表示されるため、変更しなければ Enter だけで引き継げます。

非対話環境では、環境変数でも指定できます。

```bash
GIT_USER_NAME="Your Name" GIT_USER_EMAIL="you@example.com" ./setup.sh
```

共通の `~/.gitconfig` から、この個人設定ファイルを読み込む構成です。

## GitHub CLI

GitHub CLI (`gh`) もOSに合った方法でインストールします。セットアップ後、次のコマンドでGitHubにログインできます。

```bash
gh auth login
```

## シンボリックリンク

dotfilesはホームディレクトリへコピーするのではなく、基本的にシンボリックリンクとして配置します。

例えば、

```text
~/.bash_aliases
      ↓
~/linux-setup/dotfiles/bash_aliases
```

となります。

この方式にすることで、実際に使用している設定ファイルとGitで管理している設定ファイルを同じものにできます。

設定変更後に、

```bash
git diff
```

を実行すれば、自分が変更した設定をすぐ確認できます。

## 既存設定のバックアップ

すでに以下のような設定ファイルが存在する場合、

```text
~/.vimrc
~/.bash_aliases
~/.gitconfig
```

そのまま上書きせず、バックアップを作成してからシンボリックリンクを設定します。

例:

```text
~/.vimrc
↓
~/.vimrc.backup
```

バックアップファイルがすでに存在する場合は、日時付きのファイル名を使用します。

## Bash aliases の読み込み

`common.sh` は `~/.bashrc` に以下の行が存在するか確認します。

```bash
[ -f ~/.bash_aliases ] && source ~/.bash_aliases
```

存在しない場合のみ追加します。

そのため、`setup.sh` を複数回実行しても同じ設定行が増殖しないようになっています。

セットアップ後、現在のシェルに設定を反映するには、

```bash
source ~/.bashrc
```

を実行します。

またはターミナルを開き直してください。

## 再実行について

このリポジトリでは、できるだけセットアップスクリプトを繰り返し実行できる構成を目指しています。

```bash
./setup.sh
```

を再実行しても、

* 同じ `.bashrc` 設定を何度も追加しない
* 既存設定を不用意に上書きしない
* すでにインストール済みのパッケージでも問題なく処理できる

といった冪等性を意識します。

## 新しいLinux環境への導入

新しいPCやVMへLinuxをインストールした場合も、基本的に必要な操作は次の3段階だけです。

```text
1. Gitをインストール
2. linux-setupをclone
3. ./setup.sh
```

例として Ubuntu / elementary OS なら、

```bash
sudo apt update
sudo apt install -y git

git clone https://github.com/sishihara0706/linux-setup.git
cd linux-setup

chmod +x setup.sh
./setup.sh
```

## 新しいディストリビューションを追加する場合

例えばFedoraを追加する場合、

```text
distro/fedora.sh
```

を作成します。

そのうえで `setup.sh` のOS判定に追加します。

```bash
case "${ID:-}" in
    elementary)
        source "$SCRIPT_DIR/distro/elementary.sh"
        ;;
    ubuntu)
        source "$SCRIPT_DIR/distro/ubuntu.sh"
        ;;
    rocky)
        source "$SCRIPT_DIR/distro/rocky.sh"
        ;;
    arch)
        source "$SCRIPT_DIR/distro/arch.sh"
        ;;
    *)
        echo "Unsupported OS: ${ID:-unknown}"
        exit 1
        ;;
esac
```

OS固有の処理は各ディストリビューション用スクリプトに置き、共通設定は `common.sh` に残します。

## 今後追加したいもの

今後は必要に応じて以下を追加します。

* Neovim設定
* tmux設定
* SSH設定
* GitHub CLI
* Docker
* Python / uv
* Go
* Node.js
* GNOME / KDE Plasma / Pantheon向け設定
* ShellCheckによる静的解析
* セットアップスクリプトのテスト
* distro間のパッケージ名差分の整理

## 方針

このリポジトリでは、

```text
OS依存のパッケージ管理
        +
OS非依存の個人設定
```

を分離します。

そのため、Linuxディストリビューションを変更しても、自分のVim・Bash・Gitなどの環境をできるだけ同じ状態に再現することを目指します。

## 注意

このスクリプトではパッケージのインストールやホームディレクトリ内の設定変更を行います。

実行前に内容を確認してください。

特に各ディストリビューションのスクリプトでは、

```text
apt
dnf
pacman
```

などを使用してシステムパッケージを変更します。
