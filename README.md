# 研究室勉強会

研究室の勉強会・輪講・ゼミ向けに、テキストや論文などの PDF から **わかりやすい解説記事を自動生成** する MkDocs サイトです。

Claude Code のスキルを活用し、PDF を渡すだけで記事・図が一括生成されます。

**サイト URL:** https://shuheikomatsuki.github.io/lab-seminars/

---

## 特徴

- PDF（教科書・論文）から解説記事・Mermaid図を自動生成
- MkDocs Material テーマによる見やすいドキュメントサイト
- LaTeX 数式・Mermaid 図・コードハイライトに対応
- GitHub Actions で GitHub Pages へ自動デプロイ

---

## セットアップ

### 必要なもの

- Python 3.11+
- [uv](https://github.com/astral-sh/uv)（パッケージマネージャー）
- [Claude Code](https://claude.ai/code)

### インストール

```bash
uv sync
```

### ローカルプレビュー

```bash
uv run mkdocs serve
```

http://127.0.0.1:8000 でプレビューできます。

---

## スキルの使い方

### セッションを追加する（`/add-seminar-session`）

PDF から解説記事・図を自動生成し、サイトに追加します。

```
/add-seminar-session [slug] <pdf-path> [display-title] [YYYY-MM-DD]
```

**引数：**

| 引数 | 必須 | 説明 |
|------|------|------|
| `slug` | - | URLセーフな識別子（例: `dl-ch6-2`, `attention-is-all-you-need`）。省略時はPDFファイル名から自動生成 |
| `pdf-path` | ✅ | PDF へのパス（`pdfs/` 相対パスまたは絶対パス）|
| `display-title` | - | ナビゲーションに表示するタイトル。省略時はPDF内容から自動推測 |
| `date` | - | `YYYY-MM-DD` 形式。省略時は `seminar_config.yml` の `next_seminar_date`、未設定なら今日の日付 |

**例：**

```
/add-seminar-session dl-ch6-2 pdfs/bishop-dl.pdf "DL Ch6.2 カーネル法" 2026-04-25
/add-seminar-session pdfs/attention-is-all-you-need.pdf
```

**生成されるファイル：**

```
docs/sessions/<DATE>-<slug>/
├── index.md          # 解説記事（LaTeX数式・Mermaid図・admonition付き）
└── diagrams/
    └── architecture.mmd  # Mermaid 概要図
```

---

### 新規プロジェクトを初期化する（`/setup-seminar-project`）

このテンプレートを使って新しいプロジェクトを作成する場合に使います。

```
/setup-seminar-project <project-name> [description] [output-dir]
```

---

## 設定ファイル（`seminar_config.yml`）

プロジェクトルートに `seminar_config.yml` を置くと、スキル実行時の既定値を設定できます。

```yaml
next_seminar_date: 2026-04-25   # 次回開催日（date引数省略時に使用）
default_presenter: 山田太郎     # 発表者名（担当:欄に自動挿入）
```

| キー | 説明 | 省略時 |
|------|------|--------|
| `next_seminar_date` | セッションに使用する開催日 | 今日の日付 |
| `default_presenter` | 解説記事の発表者名 | `（担当者名）` プレースホルダー |

---

## ディレクトリ構成

```
lab-seminars/
├── docs/
│   ├── index.md              # トップページ（セッション一覧）
│   ├── stylesheets/
│   │   └── extra.css         # カスタムスタイル
│   └── sessions/
│       └── <DATE>-<slug>/    # 各セッションの記事・図
├── .claude/
│   └── skills/
│       ├── add-seminar-session/    # セッション追加スキル
│       └── setup-seminar-project/ # プロジェクト初期化スキル
├── .github/
│   └── workflows/
│       └── deploy.yml        # GitHub Pages 自動デプロイ
├── pdfs/                     # PDF置き場（.gitignore で除外）
├── seminar_config.yml        # 開催日・発表者のデフォルト設定
├── mkdocs.yml
└── pyproject.toml
```

---

## デプロイ

`main` ブランチにプッシュすると GitHub Actions が自動的に：

1. D2 図を PNG に変換
2. MkDocs でサイトをビルド
3. GitHub Pages (`gh-pages` ブランチ) にデプロイ

---

## PDF の配置

PDF は `pdfs/` ディレクトリに置いてください（`.gitignore` で追跡除外済み）。

```bash
cp /path/to/paper.pdf pdfs/
/add-seminar-session my-paper pdfs/paper.pdf
```
