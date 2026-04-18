# CLAUDE.md

このファイルは Claude Code がこのリポジトリで作業する際のガイドラインです。

---

## プロジェクト概要

研究室の勉強会・輪講・ゼミ向けに、PDF（教科書・論文）から **解説記事・Marp スライド・Mermaid 図を自動生成** する MkDocs サイト。

- **サイトジェネレーター:** MkDocs + Material テーマ
- **パッケージマネージャー:** uv
- **ホスティング:** GitHub Pages（`main` プッシュで自動デプロイ）

---

## スキル

このプロジェクトには 2 つの Claude Code スキルが含まれます。

### `/add-seminar-session`

PDF から新しいセッションを追加するメインスキル。

```
/add-seminar-session [slug] <pdf-path> [display-title] [YYYY-MM-DD]
```

`slug` は省略可能（省略時はPDFファイル名から自動生成）。`date` 省略時は `seminar_config.yml` の `next_seminar_date` を使用。

**生成物:**
- `docs/sessions/<DATE>-<slug>/index.md` — 自己完結した解説記事
- `docs/sessions/<DATE>-<slug>/slides.md` — Marp スライド（10〜15枚）
- `docs/sessions/<DATE>-<slug>/diagrams/architecture.mmd` — Mermaid 概要図

**自動更新:**
- `mkdocs.yml` の `nav:` → `セッション:` に1行追加
- `docs/index.md` のセッション一覧テーブルに1行追加

### `/setup-seminar-project`

MkDocs プロジェクトを新規初期化するスキル。このリポジトリ自体はすでに初期化済みなので、通常は使わない。

---

## ディレクトリ構成と役割

```
docs/sessions/<DATE>-<slug>/   各セッションのコンテンツ
  index.md                     解説記事（MkDocs でレンダリング）
  slides.md                    Marp スライド（CI でHTML/PDF変換）
  diagrams/*.mmd               Mermaid 図（CI でPNG変換）
  diagrams/*.d2                D2 図（CI でPNG変換）

.claude/skills/
  add-seminar-session/
    SKILL.md                   スキル定義（実行手順）
    assets/                    テンプレートファイル群
    references/                フォーマット仕様
  setup-seminar-project/
    SKILL.md
    assets/

pdfs/                          PDF置き場（.gitignore で除外、コミット不可）
seminar_config.yml             開催日・発表者のデフォルト設定（任意）
```

---

## コーディング規約

### mkdocs.yml の nav エントリ

セッションを追加するときのインデントは **スペース4つ**（タブ不可）：

```yaml
nav:
  - セッション:
    - sessions/2026-04-18-dl-ch6-1/index.md
    - sessions/2026-04-25-dl-ch6-2/index.md   # ← 新規追加はここ
```

### docs/index.md のセッションテーブル

```markdown
| YYYY-MM-DD | [タイトル](sessions/DATE-slug/index.md) | [スライド](sessions/DATE-slug/slides.md) |
```

### index.md の品質基準

- 数式はインライン `$...$` またはブロック `$$...$$` で記述し、変数の意味を文中で説明する
- Mermaid 図を最低1つ含める
- 重要な洞察は admonition（`!!! note` / `!!! warning` / `!!! success`）で強調する
- 比較・対照はテーブルを使う
- PDF を読んでいない人が読んでも理解できる自己完結した記事にする

### slides.md の規約

- Marp frontmatter（`marp: true`, `math: mathjax` など）を必ず含める
- 全体10〜15枚、各節1〜3枚が目安
- `---` でスライドを区切る

---

## よく使うコマンド

```bash
# ローカルプレビュー
uv run mkdocs serve

# 依存関係インストール
uv sync
```

---

## 注意事項

- `pdfs/` は `.gitignore` で除外済み。PDF は絶対にコミットしない。
- `site/` と `.venv/` もコミット不可（gitignore 済み）。
- `mkdocs.yml` を編集するときはインデントに注意（YAML はスペース厳格）。
- スキルのテンプレート（`.claude/skills/*/assets/`）を直接編集した場合、既存セッションには反映されない（新規セッションのみ適用）。
