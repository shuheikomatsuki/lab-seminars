# 研究室勉強会

研究室の勉強会・輪講・ゼミ向けに、テキストや論文などの PDF から **わかりやすい解説記事を自動生成** する MkDocs サイトです。

Claude Code / Codex / Agents 向けのスキルを活用し、PDF を渡すだけで記事・図が一括生成されます。

**サイト URL:** https://shuheikomatsuki.github.io/lab-seminars/

---

## 特徴

- PDF（教科書・論文）から解説記事・Mermaid 図を自動生成
- 論文紹介、教科書概要、教科書サブセクション深掘り記事に対応
- 登録済み PDF からページ範囲・セクション範囲を抽出可能
- MkDocs Material テーマによる見やすいドキュメントサイト
- LaTeX 数式・Mermaid 図・コードハイライトに対応
- GitHub Actions で GitHub Pages へ自動デプロイ

---

## セットアップ

### 必要なもの

- Python 3.11+
- [uv](https://github.com/astral-sh/uv)（パッケージマネージャー）
- Claude Code、Codex、または Agents のスキル実行環境

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

### 論文セッションを追加する

論文 PDF から論文紹介記事・Mermaid 図を生成し、サイトに追加します。

```text
/add-paper-session [slug] <pdf-path> [display-title] [YYYY-MM-DD]
```

例:

```text
/add-paper-session attention-is-all-you-need pdfs/attention.pdf "Attention Is All You Need"
/add-paper-session pdfs/attention.pdf "Attention Is All You Need"
```

### 教科書セッションを追加する

教科書 PDF から節全体の概要ページを生成し、サブセクション一覧と Mermaid 図を追加します。

```text
/add-textbook-session [slug] <pdf-path> [display-title] [YYYY-MM-DD]
```

例:

```text
/add-textbook-session dl-ch6-3 pdfs/deeplearning-ch6-3.pdf "DL Ch6.3 ベイズ線形回帰"
```

### 教科書サブセクション記事を追加する

既存の教科書セッションに、担当者別の深掘り記事を追加します。

```text
/add-textbook-session <session-id> <pdf-path> --sub <subsection-slug> [subsection-title] [presenter]
```

例:

```text
/add-textbook-session 2026-04-26-6-2 pdfs/6-2.pdf --sub 6-2-3 "6.2.3 隠れユニット活性化関数" 駒月柊平
```

### PDF ページを抽出する

登録済み PDF または PDF パスから、ページ範囲・セクション範囲を抽出します。抽出した PDF は `/add-textbook-session` の入力に使えます。

```text
/extract-pdf-pages <pdf-key-or-path> <pages-or-section> [output-filename] [--output-dir <dir>]
```

例:

```text
/extract-pdf-pages dl-book 6.3 dl-book_6-3.pdf
/extract-pdf-pages /absolute/path/to/textbook.pdf 204-212 dl-ch6-3.pdf --output-dir pdfs
```

### 新規プロジェクトを初期化する

このテンプレートを使って新しい勉強会サイトを作成する場合に使います。

```text
/setup-seminar-project <project-name> [description] [output-dir]
```

---

## 設定ファイル

プロジェクトルートの `seminar_config.yml` で、スキル実行時の既定値を設定できます。

```yaml
next_seminar_date: 2026-04-26
default_presenter: 駒月柊平
pdf_sources:
  dl-book: /absolute/path/to/deeplearning-book.pdf
pdf_output_dir: pdfs
```

| キー | 説明 | 省略時 |
|------|------|--------|
| `next_seminar_date` | セッションに使用する開催日 | 今日の日付 |
| `default_presenter` | 解説記事の発表者名 | `（担当者名）` プレースホルダー |
| `pdf_sources` | `/extract-pdf-pages` で使う PDF キーと絶対パスの対応 | 登録なし |
| `pdf_output_dir` | `/extract-pdf-pages` の出力先ディレクトリ | `pdfs` |

---

## ディレクトリ構成

```text
lab-seminars/
├── docs/
│   ├── index.md              # トップページ（セッション一覧）
│   ├── stylesheets/
│   │   └── extra.css         # カスタムスタイル
│   └── sessions/
│       └── <DATE>-<slug>/    # 各セッションの記事・図
├── .claude/
│   └── skills/               # Claude Code 用スキル
├── .codex/
│   └── skills/               # Codex 用スキル
├── .agents/
│   └── skills/               # Agents 用スキル
├── .github/
│   └── workflows/
│       └── deploy.yml        # GitHub Pages 自動デプロイ
├── pdfs/                     # PDF 置き場（.gitignore で除外）
├── seminar_config.yml        # 開催日・発表者・PDF 抽出のデフォルト設定
├── mkdocs.yml
└── pyproject.toml
```

各 `skills/` ディレクトリには、次の 4 つのスキルがサブモジュールとして配置されています。

- `add-paper-session`
- `add-textbook-session`
- `extract-pdf-pages`
- `setup-seminar-project`

---

## PDF の配置と抽出

手元の PDF をそのまま使う場合は、`pdfs/` ディレクトリに置いてからスキルに渡します。

```bash
cp /path/to/paper.pdf pdfs/
/add-paper-session my-paper pdfs/paper.pdf
```

教科書全体など大きな PDF から必要範囲だけを切り出す場合は、`seminar_config.yml` の `pdf_sources` に登録してから抽出します。

```text
/extract-pdf-pages dl-book 6.2 6-2.pdf
/add-textbook-session 6-2 pdfs/6-2.pdf "DL Ch6.2 多層ネットワーク"
```

---

## デプロイ

`main` ブランチにプッシュすると GitHub Actions が自動的に：

1. MkDocs でサイトをビルド
2. GitHub Pages (`gh-pages` ブランチ) にデプロイ
