"""
小説執筆支援アプリ - Flask バックエンド
"""

import os
import json
import re
from flask import Flask, render_template, request, jsonify

app = Flask(__name__)

# Claude API（オプション）
try:
    import anthropic
    ANTHROPIC_API_KEY = os.environ.get("ANTHROPIC_API_KEY", "")
    claude_client = anthropic.Anthropic(api_key=ANTHROPIC_API_KEY) if ANTHROPIC_API_KEY else None
except ImportError:
    claude_client = None


# ------------------------------------------------------------------ #
# ルート
# ------------------------------------------------------------------ #

@app.route("/")
def index():
    return render_template("index.html")


# ------------------------------------------------------------------ #
# 文字数カウント
# ------------------------------------------------------------------ #

@app.route("/api/count", methods=["POST"])
def count_chars():
    data = request.get_json()
    text = data.get("text", "")
    # 改行・スペースを含む全文字数と、空白を除いた文字数
    total = len(text)
    no_space = len(re.sub(r"[\s\u3000]", "", text))
    lines = text.count("\n") + 1 if text else 0
    return jsonify({"total": total, "no_space": no_space, "lines": lines})


# ------------------------------------------------------------------ #
# 雛形自動生成（プロットから）
# ------------------------------------------------------------------ #

@app.route("/api/generate_draft", methods=["POST"])
def generate_draft():
    data = request.get_json()
    plot = data.get("plot", {})

    title = plot.get("title", "無題")
    genre = plot.get("genre", "")
    theme = plot.get("theme", "")
    protagonist = plot.get("protagonist", "")
    antagonist = plot.get("antagonist", "")
    setting = plot.get("setting", "")
    chapters = plot.get("chapters", [])

    if claude_client:
        # Claude API で生成
        chapters_text = "\n".join(
            f"・第{i+1}章: {c.get('title','')} — {c.get('summary','')}"
            for i, c in enumerate(chapters)
        )
        prompt = f"""あなたはプロの小説家です。以下のプロット情報をもとに、小説の文章雛形を日本語で作成してください。
各章の冒頭文（100〜200文字程度）を書き、後で作者が加筆できるよう [ここに続きを書く] というプレースホルダーを入れてください。

【タイトル】{title}
【ジャンル】{genre}
【テーマ】{theme}
【主人公】{protagonist}
【敵役/対立者】{antagonist}
【舞台】{setting}
【章構成】
{chapters_text}

小説の雛形を出力してください。"""

        message = claude_client.messages.create(
            model="claude-sonnet-4-6",
            max_tokens=2000,
            messages=[{"role": "user", "content": prompt}],
        )
        draft = message.content[0].text
    else:
        # ローカル生成（テンプレートベース）
        draft = _generate_draft_local(title, genre, theme, protagonist, antagonist, setting, chapters)

    return jsonify({"draft": draft})


def _generate_draft_local(title, genre, theme, protagonist, antagonist, setting, chapters):
    """Claude API なしでテンプレートから雛形を生成する"""
    lines = []
    lines.append(f"# {title}")
    lines.append("")
    if genre:
        lines.append(f"ジャンル: {genre}")
    if theme:
        lines.append(f"テーマ: {theme}")
    lines.append("")
    lines.append("---")
    lines.append("")

    # プロローグ
    lines.append("## プロローグ")
    lines.append("")
    if setting:
        lines.append(f"　{setting}——その場所に、一つの物語が始まろうとしていた。")
    else:
        lines.append("　物語は静かに幕を開ける。")
    if protagonist:
        lines.append(f"　{protagonist}は、この日を境に、二度と元の日常には戻れないことを、まだ知らなかった。")
    lines.append("")
    lines.append("[ここに続きを書く]")
    lines.append("")

    # 各章
    for i, chapter in enumerate(chapters):
        ch_title = chapter.get("title", f"第{i+1}章")
        ch_summary = chapter.get("summary", "")
        lines.append(f"## 第{i+1}章　{ch_title}")
        lines.append("")
        if ch_summary:
            lines.append(f"　{ch_summary}")
            lines.append("")
        if protagonist:
            lines.append(f"　{protagonist}は")
        else:
            lines.append("　主人公は")
        lines.append("[ここに続きを書く]")
        lines.append("")

    # エピローグ
    lines.append("## エピローグ")
    lines.append("")
    lines.append("　すべてが終わったとき、残ったのは——")
    lines.append("")
    lines.append("[ここに続きを書く]")
    lines.append("")

    return "\n".join(lines)


# ------------------------------------------------------------------ #
# 構成チェック
# ------------------------------------------------------------------ #

@app.route("/api/check_structure", methods=["POST"])
def check_structure():
    data = request.get_json()
    plot = data.get("plot", {})
    draft = data.get("draft", "")

    issues = []
    suggestions = []

    # プロットの必須項目チェック
    required_fields = {
        "title": "タイトル",
        "genre": "ジャンル",
        "theme": "テーマ",
        "protagonist": "主人公",
        "setting": "舞台・世界観",
    }
    for key, label in required_fields.items():
        if not plot.get(key, "").strip():
            issues.append(f"「{label}」が未入力です。")

    chapters = plot.get("chapters", [])
    if len(chapters) == 0:
        issues.append("章が1つも設定されていません。")
    elif len(chapters) < 3:
        suggestions.append("章の数が少なめです。「起承転結」を意識して3〜5章程度を目安にしましょう。")

    for i, ch in enumerate(chapters):
        if not ch.get("title", "").strip():
            issues.append(f"第{i+1}章のタイトルが未入力です。")
        if not ch.get("summary", "").strip():
            suggestions.append(f"第{i+1}章のあらすじを入力するとより詳細な雛形が生成されます。")

    # 雛形テキストチェック
    if draft:
        placeholder_count = draft.count("[ここに続きを書く]")
        if placeholder_count > 0:
            suggestions.append(f"雛形に {placeholder_count} 箇所の未記入プレースホルダーがあります。")

        char_count = len(re.sub(r"[\s\u3000]", "", draft))
        if char_count < 200:
            suggestions.append("本文の文字数がまだ少なめです。各章を肉付けしていきましょう。")

    if claude_client:
        # Claude API で構成アドバイス
        chapters_text = "\n".join(
            f"・第{i+1}章: {c.get('title','')} — {c.get('summary','')}"
            for i, c in enumerate(chapters)
        )
        prompt = f"""以下の小説プロットの構成を評価し、改善点を3点以内で簡潔に日本語でアドバイスしてください。
箇条書きで出力してください。

【タイトル】{plot.get('title','')}
【テーマ】{plot.get('theme','')}
【主人公】{plot.get('protagonist','')}
【章構成】
{chapters_text}"""
        message = claude_client.messages.create(
            model="claude-sonnet-4-6",
            max_tokens=500,
            messages=[{"role": "user", "content": prompt}],
        )
        ai_advice = message.content[0].text
        suggestions.append("【AIアドバイス】\n" + ai_advice)

    return jsonify({"issues": issues, "suggestions": suggestions})


# ------------------------------------------------------------------ #
# 推敲（文章チェック）
# ------------------------------------------------------------------ #

@app.route("/api/proofread", methods=["POST"])
def proofread():
    data = request.get_json()
    text = data.get("text", "")

    if not text.strip():
        return jsonify({"result": "テキストが空です。"})

    if claude_client:
        prompt = f"""あなたはプロの文章校正者です。以下の小説の文章を推敲してください。

チェック項目：
1. 誤字・脱字・表記ゆれ
2. 文章のリズムと読みやすさ
3. 同じ表現の繰り返し
4. 描写の改善提案

修正提案は箇条書きで、具体的な修正例とともに日本語で出力してください。
問題がなければ「特に大きな問題は見当たりません。」と答えてください。

【対象文章】
{text[:2000]}"""

        message = claude_client.messages.create(
            model="claude-sonnet-4-6",
            max_tokens=1000,
            messages=[{"role": "user", "content": prompt}],
        )
        result = message.content[0].text
    else:
        # ローカル簡易チェック
        result = _proofread_local(text)

    return jsonify({"result": result})


def _proofread_local(text):
    """Claude API なしの簡易推敲チェック"""
    issues = []

    # 同じ文末表現の連続チェック
    endings = re.findall(r"。\s*\n*([^。\n]{0,30}。)", text)
    seen = {}
    for end in endings:
        tail = end[-6:] if len(end) >= 6 else end
        seen[tail] = seen.get(tail, 0) + 1
    for tail, count in seen.items():
        if count >= 3:
            issues.append(f"「〜{tail}」のような文末表現が{count}回繰り返されています。変化をつけましょう。")

    # 「〜た。〜た。〜た。」 連続チェック
    ta_seq = re.findall(r"た。", text)
    if len(ta_seq) >= 5:
        issues.append("「〜た。」で終わる文が多く続いています。リズムを変えてみましょう。")

    # 長すぎる一文チェック
    sentences = re.split(r"[。！？]", text)
    long_sents = [s for s in sentences if len(s) > 100]
    if long_sents:
        issues.append(f"{len(long_sents)}文が100文字を超えています。読点や句点で区切ることを検討してください。")

    # 表記ゆれチェック（簡易）
    variants = [
        ("下さい", "ください"),
        ("出来る", "できる"),
        ("様", "よう"),
    ]
    for formal, casual in variants:
        if formal in text and casual in text:
            issues.append(f"「{formal}」と「{casual}」が混在しています。表記を統一しましょう。")

    if issues:
        return "【推敲チェック結果】\n" + "\n".join(f"・{i}" for i in issues)
    else:
        return "特に大きな問題は見当たりません。よく書けています！"


# ------------------------------------------------------------------ #
# メイン
# ------------------------------------------------------------------ #

if __name__ == "__main__":
    print("=" * 50)
    print("小説執筆支援アプリを起動しています...")
    print("ブラウザで http://127.0.0.1:5000 を開いてください")
    if claude_client:
        print("Claude API: 有効（AI生成・推敲機能が使用可能）")
    else:
        print("Claude API: 無効（ローカルモードで動作中）")
        print("  ※ AI機能を使う場合は環境変数 ANTHROPIC_API_KEY を設定してください")
    print("=" * 50)
    app.run(debug=False, host="127.0.0.1", port=5000)
