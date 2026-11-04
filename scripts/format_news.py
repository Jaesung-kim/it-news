#!/usr/bin/env python3
"""일별 페이지의 git diff(stdin)에서 새 기사를 읽어 텔레그램 HTML 메시지로 만든다.

메시지가 길면 기사 경계에서 나눈다. 각 메시지는 NUL 문자로 끝나며 stdout으로 나간다.
"""
import argparse
import html
import posixpath
import re
import sys
from datetime import date

LIMIT = 3800  # 텔레그램 한도는 태그를 뺀 글자 수 기준 4096자. 이모지 등을 고려해 여유를 둔다.
WEEKDAYS = "월화수목금토일"
LINK = re.compile(r"\[([^\]]+)\]\((\S+?)\)(?=\s*(?:·|$))")


def esc(text):
    return html.escape(text, quote=True)


def added_lines(diff):
    for line in diff.splitlines():
        if line.startswith("+") and not line.startswith("+++"):
            yield line[1:].strip()


def parse_articles(lines):
    articles = []
    for line in lines:
        if line.startswith("### "):
            articles.append({"title": line[4:].strip(), "bullets": [], "links": [], "source": ""})
        elif not articles:
            continue
        elif line.startswith("- "):
            articles[-1]["bullets"].append(line[2:].replace("**", "").strip())
        elif "[상세](" in line or "[원문](" in line:
            articles[-1]["links"] = LINK.findall(line)
            articles[-1]["source"] = LINK.sub("", line).strip(" ·")
    return articles


def link_target(url, daily, blob_url):
    if re.match(r"https?://", url):
        return url
    return f"{blob_url}/{posixpath.normpath(posixpath.join(posixpath.dirname(daily), url))}"


def render_article(number, article, daily, blob_url):
    """(HTML, 태그를 뺀 글자 수)를 돌려준다."""
    lines = [f"<b>{number}. {esc(article['title'])}</b>"]
    lines += [f"• {esc(b)}" for b in article["bullets"]]
    tail = [f'<a href="{esc(link_target(u, daily, blob_url))}">{esc(t)}</a>' for t, u in article["links"]]
    if article["source"]:
        tail.append(esc(article["source"]))
    if tail:
        lines.append(" · ".join(tail))
    text = "\n".join(lines)
    return text, len(html.unescape(re.sub(r"<[^>]+>", "", text)))


def build_messages(articles, args):
    day = date.fromisoformat(args.date)
    head = f"{args.icon} <b>{esc(args.name)}</b>{{part}}\n{args.date} ({WEEKDAYS[day.weekday()]}) {args.ampm} · 새 기사 {len(articles)}개"
    foot = f'<a href="{esc(args.blob_url)}/{esc(args.daily)}">오늘의 {esc(args.name)} 전체 보기</a>'

    chunks, current, size = [], [], 0
    for i, article in enumerate(articles, 1):
        text, length = render_article(i, article, args.daily, args.blob_url)
        if current and size + length + 2 > LIMIT - 200:  # 머리말·꼬리말 몫 200자
            chunks.append(current)
            current, size = [], 0
        current.append(text)
        size += length + 2
    chunks.append(current)

    messages = []
    for n, chunk in enumerate(chunks, 1):
        part = f" ({n}/{len(chunks)})" if len(chunks) > 1 else ""
        body = [head.format(part=part)] + chunk
        if n == len(chunks):
            body.append(foot)
        messages.append("\n\n".join(body))
    return messages


def main():
    ap = argparse.ArgumentParser()
    for name in ("icon", "name", "date", "ampm", "daily", "blob-url"):
        ap.add_argument(f"--{name}", required=True)
    args = ap.parse_args()
    args.blob_url = args.blob_url.rstrip("/")

    diff = sys.stdin.buffer.read().decode("utf-8", "replace")
    articles = parse_articles(added_lines(diff))
    if not articles:  # 형식이 어긋나면 run.sh가 링크만 담은 평문을 보낸다.
        print("format_news: 기사를 찾지 못함", file=sys.stderr)
        return
    for message in build_messages(articles, args):
        sys.stdout.buffer.write(message.encode("utf-8") + b"\0")


if __name__ == "__main__":
    main()
