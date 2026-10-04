#!/usr/bin/env python3
"""يضبط web/index.html و web/manifest.json (المولَّدين بـ flutter create)
ليناسبا تطبيقًا عربيًا من اليمين لليسار قابلًا للإضافة إلى الشاشة الرئيسية."""
import json
import pathlib
import re

TITLE = "تام — سجل المنتسبين"
DESC = "سجل منتسبي نقابة تحالف أساتذة موريتانيا"
THEME = "#0D5344"

idx = pathlib.Path("web/index.html")
s = idx.read_text(encoding="utf-8")
s = re.sub(r"<html[^>]*>", '<html lang="ar" dir="rtl">', s, count=1)
s = re.sub(r"<title>.*?</title>", f"<title>{TITLE}</title>", s, count=1, flags=re.S)
s = re.sub(r'(<meta name="description" content=")[^"]*(")', rf"\g<1>{DESC}\g<2>", s, count=1)
s = re.sub(r'(<meta name="apple-mobile-web-app-title" content=")[^"]*(")', r"\g<1>تام\g<2>", s, count=1)
if 'name="theme-color"' not in s:
    s = s.replace("</head>", f'  <meta name="theme-color" content="{THEME}">\n</head>', 1)
idx.write_text(s, encoding="utf-8")

mf = pathlib.Path("web/manifest.json")
m = json.loads(mf.read_text(encoding="utf-8"))
m.update({
    "name": TITLE,
    "short_name": "تام",
    "description": DESC,
    "lang": "ar",
    "dir": "rtl",
    "display": "standalone",
    "theme_color": THEME,
    "background_color": "#FFFFFF",
})
mf.write_text(json.dumps(m, ensure_ascii=False, indent=2), encoding="utf-8")
print("web/index.html + web/manifest.json configured")
