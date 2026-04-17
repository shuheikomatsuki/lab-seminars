---
marp: true
theme: default
paginate: true
header: "研究室勉強会 2025-04-18"
footer: "Whisper: Robust Speech Recognition via Large-Scale Weak Supervision"
---

# Whisper
## Robust Speech Recognition via Large-Scale Weak Supervision

Radford et al., OpenAI (2022)

発表者：（担当者名）
2025-04-18

---

## 背景・動機

- 音声認識の既存アプローチ：小規模な**高品質ラベルデータ**でファインチューニング
- 問題点：特定ドメインへの過学習、汎化性能が低い

**Whisperの提案：**
- Web から収集した **680,000時間** の弱ラベル音声データで学習
- ゼロショットで多様なドメインに汎化

---

## モデルアーキテクチャ

```
音声 (16kHz)
  ↓ Log-Mel Spectrogram (80ch, 30秒)
  ↓ Encoder (Transformer)
  ↓ Decoder (Transformer)
  ↓ テキスト出力
```

- 標準的な **Encoder-Decoder Transformer**
- 特殊トークンでタスクを切り替え（転写 / 翻訳 / 言語識別）

---

## 多タスク学習

| トークン | 意味 |
|----------|------|
| `<\|transcribe\|>` | 音声→テキスト転写 |
| `<\|translate\|>` | 音声→英語翻訳 |
| `<\|ja\|>` | 言語識別（日本語） |
| `<\|nospeech\|>` | 無音区間 |

→ **1つのモデルで99言語対応**

---

## 学習データ

- 合計 **680,000時間** の音声+テキストペア
- Web クロールで収集 → 品質フィルタリング
- 多言語データを含む（英語が最多）

弱教師あり ≠ ノイズが多い
→ 大規模さがノイズを凌駕

---

## 実験結果

- LibriSpeech (clean): WER **2.7%** （ゼロショット）
- 多言語 Fleurs: 多くの言語で SOTA 水準
- 特にロバスト性が高い（ドメイン外でも安定）

---

## まとめ

1. **大規模弱教師学習** により汎化性能を大幅向上
2. **Encoder-Decoder Transformer** + 特殊トークンで多タスク対応
3. ゼロショットで既存の教師ありモデルに匹敵

**次のステップ：** Whisper の日本語性能検証、finetune 実験

---

## Q&A

ご質問・ご議論をどうぞ
