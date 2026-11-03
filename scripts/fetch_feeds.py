#!/usr/bin/env python3
"""RSS/Atom 사전 수집: scripts/feeds.tsv -> .cache/feeds/{items,status}.tsv (표준 라이브러리만 사용)."""
import html
import re
import sys
import urllib.request
import xml.etree.ElementTree as ET
from datetime import datetime, timedelta, timezone
from email.utils import parsedate_to_datetime
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
FEEDS = ROOT / "scripts" / "feeds.tsv"
OUT = ROOT / ".cache" / "feeds"
UA = "Mozilla/5.0 (X11; Linux x86_64) it-news-fetcher/1.0 (+https://github.com/Jaesung-kim/it-news)"
TIMEOUT = 30
WINDOW = timedelta(hours=36)
SUMMARY_LEN = 300


def clean(text, limit=None):
    if not text:
        return ""
    text = re.sub(r"<[^>]+>", " ", text)
    text = html.unescape(text)
    text = re.sub(r"<[^>]+>", " ", text)  # 이중 인코딩된 태그
    text = re.sub(r"\s+", " ", text).strip()
    return text[:limit] if limit else text


def local(tag):
    return tag.rsplit("}", 1)[-1].lower()


def child(el, *names):
    for c in el:
        if local(c.tag) in names:
            return c
    return None


def text_of(el, *names):
    c = child(el, *names)
    return (c.text or "").strip() if c is not None and c.text else ""


def parse_date(s):
    s = (s or "").strip()
    if not s:
        return None
    try:
        dt = parsedate_to_datetime(s)
    except (TypeError, ValueError, IndexError):
        dt = None
    if dt is None:
        try:
            dt = datetime.fromisoformat(s.replace("Z", "+00:00"))
        except ValueError:
            return None
    if dt.tzinfo is None:
        dt = dt.replace(tzinfo=timezone.utc)
    return dt


def parse(data):
    root = ET.fromstring(data)
    items = []
    if local(root.tag) == "feed":  # Atom
        for e in root:
            if local(e.tag) != "entry":
                continue
            link = ""
            for l in e:
                if local(l.tag) == "link" and l.get("rel", "alternate") == "alternate":
                    link = l.get("href", "")
                    break
            date = text_of(e, "published") or text_of(e, "updated")
            summ = child(e, "summary")
            if summ is None or not "".join(summ.itertext()).strip():
                summ = child(e, "content")
            summ = "".join(summ.itertext()) if summ is not None else ""
            items.append((text_of(e, "title"), link, date, summ))
    else:  # RSS 2.0 / RDF
        for it in root.iter():
            if local(it.tag) != "item":
                continue
            date = text_of(it, "pubdate") or text_of(it, "date") or text_of(it, "published")
            summ = text_of(it, "description") or text_of(it, "encoded")
            link = text_of(it, "link")
            if not link:
                g = child(it, "guid")
                if g is not None and g.get("isPermaLink", "true") == "true":
                    link = (g.text or "").strip()
            items.append((text_of(it, "title"), link, date, summ))
    return items


def main():
    OUT.mkdir(parents=True, exist_ok=True)
    now = datetime.now(timezone.utc)
    rows, status = [], []
    for line in FEEDS.read_text(encoding="utf-8").splitlines():
        if not line.strip() or line.startswith("#"):
            continue
        name, url = line.split("\t", 1)
        try:
            req = urllib.request.Request(url.strip(), headers={"User-Agent": UA, "Accept": "application/rss+xml, application/atom+xml, application/xml, text/xml, */*"})
            with urllib.request.urlopen(req, timeout=TIMEOUT) as r:
                data = r.read()
            n = 0
            for title, link, date, summ in parse(data):
                dt = parse_date(date)
                if dt is None or now - dt > WINDOW or not link:
                    continue
                rows.append("\t".join([name, clean(title), link.strip(), dt.astimezone(timezone.utc).isoformat(), clean(summ, SUMMARY_LEN)]))
                n += 1
            status.append(f"{name}\tOK({n})")
        except Exception as e:  # 피드 하나가 실패해도 계속
            reason = clean(f"{type(e).__name__}: {e}", 120)
            status.append(f"{name}\tFAIL({reason})")
    (OUT / "items.tsv").write_text("".join(r + "\n" for r in rows), encoding="utf-8")
    (OUT / "status.tsv").write_text("".join(s + "\n" for s in status), encoding="utf-8")
    print("\n".join(status))
    print(f"items: {len(rows)}")


if __name__ == "__main__":
    try:
        main()
    except Exception as e:
        print(f"fetch_feeds error: {e}", file=sys.stderr)
    sys.exit(0)
