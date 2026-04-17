#!/usr/bin/env bash
# new-session.sh — 新しいセッションをテンプレートから生成する
#
# 使い方:
#   bash scripts/new-session.sh <YYYY-MM-DD> <session-name>
#
# 例:
#   bash scripts/new-session.sh 2025-05-15 bert

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
TEMPLATE_DIR="$REPO_ROOT/templates/session"
SESSIONS_DIR="$REPO_ROOT/docs/sessions"

# --- 引数チェック ---
if [[ $# -ne 2 ]]; then
  echo "Usage: $0 <YYYY-MM-DD> <session-name>"
  echo "  e.g. $0 2025-05-15 bert"
  exit 1
fi

DATE="$1"
NAME="$2"
SESSION_ID="${DATE}-${NAME}"
DEST="$SESSIONS_DIR/$SESSION_ID"

# --- 日付フォーマット検証 ---
if ! [[ "$DATE" =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}$ ]]; then
  echo "Error: DATE must be in YYYY-MM-DD format (got: $DATE)"
  exit 1
fi

# --- 重複チェック ---
if [[ -d "$DEST" ]]; then
  echo "Error: Session '$SESSION_ID' already exists at $DEST"
  exit 1
fi

# --- テンプレートをコピー ---
cp -r "$TEMPLATE_DIR" "$DEST"

echo "Created: $DEST"
echo ""
echo "Next steps:"
echo "  1. Edit $DEST/index.md   — まとめページを記述"
echo "  2. Edit $DEST/slides.md  — Marpスライドを記述"
echo "  3. Edit $DEST/diagrams/  — 図ファイルを編集"
echo "  4. mkdocs.yml の nav に以下を追加:"
echo "       - ${DATE} ${NAME}: sessions/${SESSION_ID}/index.md"
