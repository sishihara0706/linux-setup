# command-register 仕様書

## 1. 概要
`command-register` は、Bash エイリアスを `~/.bash_aliases` に追記登録するためのコマンドラインツール。

配置先: `~/tools/command-register`

## 2. 目的
- エイリアス登録を1コマンドで実施できるようにする
- `~/.bash_aliases` への手作業編集を減らす

## 3. 実行形式
```bash
command-register <alias_name> <command>
```

## 4. 引数仕様
1. `<alias_name>`
- 登録するエイリアス名
- 許可文字: `A-Z a-z 0-9 . _ -`

2. `<command>`
- エイリアスに紐づけるコマンド文字列
- 第2引数以降は空白区切りで連結して1つのコマンドとして扱う

## 5. 動作仕様
1. 引数が2つ未満の場合
- エラーメッセージを出力し終了（終了コード: 1）

2. エイリアス名が不正な場合
- エラーメッセージを出力し終了（終了コード: 1）

3. 正常時
- `~/.bash_aliases` がなければ作成
- Bashの `printf %q` でコマンドをエスケープし、`alias <alias_name>=<escaped_command>` 形式で1行追記
- シングルクォートを含むコマンドは安全にエスケープして保存
- 追記した行を表示
- `source ~/.bash_aliases` 実行を促すメッセージを表示

## 6. 出力例
```text
Added: alias ll=ls\ -alF
Run: source ~/.bash_aliases
```

## 7. 使用例
```bash
~/tools/command-register ll "ls -alF"
~/tools/command-register gs "git status -sb"
source ~/.bash_aliases
```

## 8. 注意事項
- 同一エイリアス名の重複チェックは行わない（同名を再登録すると追記される）
- 反映にはシェル再読み込み（`source ~/.bash_aliases` など）が必要

## 9. 終了コード
- `0`: 正常終了
- `1`: 引数不足またはエイリアス名不正
