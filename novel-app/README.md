# 小説執筆支援アプリ

Flask + HTML で動く、Windows 11 対応のローカル小説執筆支援ツールです。

---

## 機能一覧

| 機能 | 説明 |
|------|------|
| 文字数カウント | 総文字数・空白除く文字数・行数をリアルタイム表示 |
| プロットアウトライン | タイトル/ジャンル/テーマ/主人公/章構成をテンプレートに入力 |
| 雛形自動生成 | プロットから小説の骨格文章を自動生成（その後自由に編集可能） |
| 構成チェック | 必須項目の漏れ・章構成の問題点・改善提案を表示 |
| 推敲 | 文章の問題点（繰り返し・長文・表記ゆれ）をチェック |
| AI機能（オプション） | ANTHROPIC_API_KEY を設定すると Claude AI による高品質な生成・推敲が可能 |

---

## セットアップ手順（Windows 11）

### 1. Python のインストール
[python.org](https://www.python.org/) から Python 3.10 以上をインストール。
インストール時に **「Add Python to PATH」にチェックを入れる**こと。

### 2. ライブラリのインストール
コマンドプロンプト（または PowerShell）を開いて実行：

```
cd novel-app
pip install -r requirements.txt
```

### 3. アプリの起動

```
python app.py
```

起動後、ブラウザで以下を開く：

```
http://127.0.0.1:5000
```

---

## AI機能を使う場合（オプション）

Anthropic の API キーを取得し、環境変数に設定します。

**Windows コマンドプロンプト:**
```
set ANTHROPIC_API_KEY=sk-ant-xxxxxxxx
python app.py
```

**Windows PowerShell:**
```
$env:ANTHROPIC_API_KEY="sk-ant-xxxxxxxx"
python app.py
```

API キーがない場合でも、ローカルモードで基本機能はすべて使えます。

---

## ファイル構成

```
novel-app/
├── app.py              ← Flask サーバー（メインプログラム）
├── requirements.txt    ← 必要ライブラリ
├── README.md           ← この説明書
├── templates/
│   └── index.html      ← メイン画面
└── static/
    └── style.css       ← デザイン
```
