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

このプロジェクトには 3 つの Claude Code スキルが含まれます。

### `/add-textbook-session`

教科書の輪講セッションを追加するメインスキル。**2つのモード**があります。

**Mode 1 — 新規セッション作成**（セッションが未存在）:
```
/add-textbook-session [slug] <pdf-path> [display-title] [YYYY-MM-DD]
```

**Mode 2 — サブサブセクション深掘り記事追加**（セッションが既存）:
```
/add-textbook-session <session-id> <pdf-path> --sub <subsection-slug> [subsection-title] [presenter]
```

`slug` は省略可能（省略時はPDFファイル名から自動生成）。`date` 省略時は `seminar_config.yml` の `next_seminar_date` を使用。

**Mode 1 生成物:**
- `docs/sessions/<DATE>-<slug>/index.md` — サブサブセクション一覧付き概要ページ
- `docs/sessions/<DATE>-<slug>/slides.md` — Marp スライド（節全体カバー、10〜15枚）
- `docs/sessions/<DATE>-<slug>/diagrams/architecture.mmd` — Mermaid 概要図

**Mode 1 自動更新:**
- `mkdocs.yml` の `nav:` → `セッション:` にネストグループとして追加
- `docs/index.md` のセッション一覧テーブルに1行追加

**Mode 2 生成物:**
- `docs/sessions/<SESSION_ID>/<subsection-slug>.md` — 数式導出・具体例・議論点を含む深掘り記事

**Mode 2 自動更新:**
- `mkdocs.yml` の該当セッショングループにサブページを追加
- `docs/sessions/<SESSION_ID>/index.md` のサブセクション一覧テーブルを更新

### `/add-paper-session`

論文紹介セッションを追加するスキル（将来使用予定）。

```
/add-paper-session [slug] <pdf-path> [display-title] [YYYY-MM-DD]
```

教科書と異なり、Abstract/Method/Experiments/Limitationsの論文固有の構成で記事を生成します。

### `/setup-seminar-project`

MkDocs プロジェクトを新規初期化するスキル。このリポジトリ自体はすでに初期化済みなので、通常は使わない。

---

## ディレクトリ構成と役割

```
docs/sessions/<DATE>-<slug>/   各セッションのコンテンツ
  index.md                     概要ページ（サブサブセクション一覧・全体の流れ）
  <subsection-slug>.md         サブサブセクション深掘り記事（Mode 2 で追加）
  slides.md                    Marp スライド（CI でHTML/PDF変換）
  diagrams/*.mmd               Mermaid 図（CI でPNG変換）
  diagrams/*.d2                D2 図（CI でPNG変換）

.claude/skills/
  add-textbook-session/
    SKILL.md                   スキル定義（実行手順・2モード対応）
    assets/
      overview_template.md     Mode 1 概要ページ用テンプレート
      index_template.md        Mode 2 深掘り記事用テンプレート
      slides_template.md       スライド用テンプレート
    references/
      session_format.md        navフォーマット仕様（ネスト構造含む）
  add-paper-session/
    SKILL.md
    assets/
  setup-seminar-project/
    SKILL.md
    assets/

pdfs/                          PDF置き場（.gitignore で除外、コミット不可）
seminar_config.yml             開催日・発表者のデフォルト設定（任意）
```

---

## コーディング規約

### mkdocs.yml の nav エントリ

新規セッションはネスト構造のグループとして追加する（スペース4つ/6つ）：

```yaml
nav:
  - セッション:
    - <date> <display-title>:                          # スペース4つ
      - 概要: sessions/<DATE>-<slug>/index.md          # スペース6つ
      - サブセクション名: sessions/<DATE>-<slug>/slug.md  # スペース6つ
```

### docs/index.md のセッションテーブル

```markdown
| YYYY-MM-DD | [タイトル](sessions/DATE-slug/index.md) | [スライド](sessions/DATE-slug/slides.html) |
```

### index.md（概要ページ）の品質基準

- サブサブセクション一覧テーブルに全サブサブセクションを列挙する
- Mermaid 図で全体の流れを図示する
- まとめテーブルに各サブサブセクションの1行要点を記載する

### サブサブセクション深掘り記事の品質基準

- 数式はステップバイステップで導出し、各ステップに直感的な説明を添える
- Mermaid 図を最低1つ含める
- 前後のサブサブセクションとの接続を `!!! abstract` admonition で明示する
- 担当者の議論・疑問点を末尾に記載する

### slides.md の規約

- Marp frontmatter（`marp: true`, `math: katex` など）を必ず含める
- 全体10〜15枚、各サブサブセクション1〜3枚が目安
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
- `.claude/skills/` は `lab-seminar-skills` リポジトリの git submodule。スキルを更新した場合は submodule の更新も必要。
