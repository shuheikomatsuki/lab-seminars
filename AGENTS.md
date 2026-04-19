# AGENTS.md

このファイルは AI エージェントがこのリポジトリで作業する際の仕様書です。

---

## プロジェクト目的

研究室の勉強会・輪講・ゼミにおいて、**教科書や論文の PDF から誰でも理解できる解説記事とプレゼンスライドを自動生成**すること。

手作業でのまとめ作業を削減し、発表準備の効率化と知識の蓄積・共有を実現する。

---

## 技術スタック

| 用途 | ツール |
|------|--------|
| ドキュメントサイト | MkDocs + Material テーマ |
| スライド生成 | Marp（Markdown → HTML/PDF） |
| 図の記述 | Mermaid（フローチャート・シーケンス図）、D2（アーキテクチャ図）|
| 数式 | MathJax / KaTeX（LaTeX 記法）|
| パッケージ管理 | uv（Python 3.11+）|
| CI/CD | GitHub Actions → GitHub Pages |

---

## 利用可能なスキル

### `add-seminar-session`

**トリガー条件（いずれか）：**
- `/add-seminar-session` が呼ばれた
- PDF・論文・教科書から記事・スライドを作りたい
- 勉強会セッション・輪講・ゼミの追加を依頼された
- `まとめ記事`・`スライド` の生成を依頼された

**引数：**
```
[slug] <pdf-path> [display-title] [YYYY-MM-DD]
```

`slug` は省略可能。省略時はPDFファイル名から自動生成。`date` 省略時は `seminar_config.yml` の `next_seminar_date` を使用（未設定なら今日の日付）。

**実行フロー：**

0. **設定ファイル読み込み** — `seminar_config.yml` から `next_seminar_date`・`default_presenter` を取得
1. **PDF 読み込み** — 章・節構造、主要概念、数式、出典を把握する
2. **ディレクトリ作成** — `docs/sessions/<DATE>-<slug>/diagrams/`
3. **index.md 生成** — 自己完結した解説記事（`default_presenter` を担当者欄に挿入）
   - LaTeX 数式（変数の意味を添える）
   - Mermaid 図（最低1つ）
   - admonition で重要点を強調
   - 比較テーブル
4. **slides.md 生成** — Marp スライド（10〜15枚、`default_presenter` を発表者欄に挿入）
5. **architecture.mmd 生成** — 概要を俯瞰する Mermaid 図
6. **mkdocs.yml 更新** — `nav:` → `セッション:` に追加
7. **docs/index.md 更新** — セッション一覧テーブルに追加
8. **ビルド確認** — `uv run mkdocs build --strict` を実行し、エラーがあれば修正

**テンプレート参照先：**
- `index.md` → `.claude/skills/add-seminar-session/assets/index_template.md`
- `slides.md` → `.claude/skills/add-seminar-session/assets/slides_template.md`
- フォーマット仕様 → `.claude/skills/add-seminar-session/references/session_format.md`

---

### `setup-seminar-project`

**トリガー条件：**
- `/setup-seminar-project` が呼ばれた
- 新しい勉強会サイトを一から作りたい

**引数：**
```
<project-name> [description] [output-dir]
```

**実行フロー：**
1. `mkdocs.yml` の存在確認（既存プロジェクトへの上書き防止）
2. ディレクトリ構造を作成
3. `pyproject.toml`・`mkdocs.yml`・`docs/index.md`・`extra.css`・`.gitignore` を生成
4. `add-seminar-session` スキルをコピー
5. `uv sync` で依存関係インストール

---

## エージェントの行動指針

### コンテンツ品質

- **自己完結性**: index.md は PDF を読んでいない読者でも理解できる記事にする
- **数式の説明**: 数式を書いたら必ず変数・記号の意味を日本語で添える
- **図の活用**: 概念の関係・フロー・歴史的変遷など、文章では伝わりにくいものは Mermaid 図で表現する
- **admonition の使い分け**:
  - `!!! note` — 補足・定義
  - `!!! warning` — 注意点・落とし穴
  - `!!! success` — 重要な洞察・まとめ

### ファイル操作のルール

- `pdfs/` 内の PDF はコミットしない（`.gitignore` 対象）
- `mkdocs.yml` 編集時はインデントをスペース4つで統一する
- セッション ID は `YYYY-MM-DD-<slug>` 形式を厳守する
- スキルのテンプレートファイル（`assets/`）は参照のみ。直接編集しない
- `.claude/skills/` と `.codex/skills/` は `lab-seminar-skills` リポジトリの git submodule。テンプレートを修正する場合は `lab-seminar-skills` リポジトリを直接編集し、コミット・プッシュ後に `git submodule update --remote` でサブモジュールを更新する。submodule 内のファイルを直接編集してはならない

### nav エントリのフォーマット

```yaml
nav:
  - セッション:
    - sessions/2026-04-18-dl-ch6-1/index.md
```

### セッション一覧テーブルのフォーマット

```markdown
| YYYY-MM-DD | [タイトル](sessions/DATE-slug/index.md) | [スライド](sessions/DATE-slug/slides.md) |
```

---

## ファイル構成

```
lab-seminars/
├── docs/
│   ├── index.md                     # トップページ（セッション一覧テーブル）
│   ├── stylesheets/extra.css        # カスタムスタイル
│   └── sessions/
│       └── <DATE>-<slug>/
│           ├── index.md             # 解説記事
│           ├── slides.md            # Marpスライド
│           └── diagrams/
│               ├── architecture.mmd # Mermaid概要図
│               └── *.d2             # D2図（任意）
├── .claude/skills/
│   ├── add-seminar-session/
│   │   ├── SKILL.md                 # スキル実行仕様
│   │   ├── assets/                  # テンプレート群
│   │   └── references/              # フォーマット仕様
│   └── setup-seminar-project/
│       ├── SKILL.md
│       └── assets/
├── .github/workflows/deploy.yml     # CI/CD（Marp変換・MkDocsビルド・Pages公開）
├── pdfs/                            # PDF置き場（gitignore対象）
├── seminar_config.yml               # 開催日・発表者のデフォルト設定（任意）
├── mkdocs.yml
├── pyproject.toml
├── CLAUDE.md
└── AGENTS.md
```

---

## よく使うコマンド

```bash
uv sync                  # 依存関係インストール
uv run mkdocs serve      # ローカルプレビュー（http://127.0.0.1:8000）
uv run mkdocs build      # 静的ファイルをビルド（site/ に出力）
```
