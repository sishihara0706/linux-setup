# command-register README

`command-register` は、`~/.bash_aliases` へエイリアスを簡単に追加するためのスクリプトです。

## 場所
- スクリプト: `~/tools/command-register`
- 仕様書: `~/tools/command-register-spec.md`

## 使い方
```bash
~/tools/command-register <alias_name> <command>
```

### 例
```bash
~/tools/command-register ll "ls -alF"
~/tools/command-register gs "git status -sb"
source ~/.bash_aliases
```

## 動作
- `~/.bash_aliases` が存在しなければ自動作成
- Bashの `printf %q` でエスケープし、`alias <name>=<escaped_command>` 形式で末尾に1行追記
- コマンド内のシングルクォートは安全にエスケープ

## エラー
- 引数不足: 使用方法を表示して終了
- 不正なエイリアス名: エラー表示して終了

エイリアス名に使える文字は `A-Z a-z 0-9 . _ -` です。

## 注意
- 同名エイリアスの重複チェックはしません（再登録すると追記されます）
- 追加後は `source ~/.bash_aliases` で反映してください
