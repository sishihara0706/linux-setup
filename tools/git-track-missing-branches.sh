#!/usr/bin/env bash
# git-track-missing-branches.sh
# origin（既定: origin）にあるがローカルに無いブランチを自動で作成（追跡設定つき）
set -euo pipefail

remote="origin"
dry_run=false
prune=false

usage() {
  cat <<USAGE
Usage: $(basename "$0") [options]
  -r, --remote <name>  対象のリモート名（既定: origin）
  -n, --dry-run        実際には作成せず、やることだけ表示
  -p, --prune          取得時に --prune（消えたリモートブランチを掃除）
  -h, --help           このヘルプ

例:
  $(basename "$0")
  $(basename "$0") -p
  $(basename "$0") -r upstream -n
USAGE
}

# 引数処理
while [[ $# -gt 0 ]]; do
  case "$1" in
    -r|--remote) remote="$2"; shift 2;;
    -n|--dry-run) dry_run=true; shift;;
    -p|--prune) prune=true; shift;;
    -h|--help) usage; exit 0;;
    *) echo "Unknown option: $1"; usage; exit 1;;
  esac
done

# リモート取得
if $prune; then
  git fetch "$remote" --prune
else
  git fetch "$remote"
fi

# リモートのブランチ一覧（HEADは除外）を走査
git for-each-ref --format='%(refname:strip=3)' "refs/remotes/$remote" \
  | grep -vx 'HEAD' \
  | while IFS= read -r b; do
      if git show-ref --verify --quiet "refs/heads/$b"; then
        echo "skip : $b  (already exists locally)"
        continue
      fi
      echo "create: $b  ->  $remote/$b"
      if ! $dry_run; then
        git branch --track "$b" "$remote/$b"
      fi
    done

echo "done."

