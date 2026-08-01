#!/usr/bin/env python3
"""Stamp a new build version into version.json, js/version.js and index.html.
Run before committing any change to the app's HTML/CSS/JS."""
import json, re, datetime, pathlib

root = pathlib.Path(__file__).resolve().parent.parent
v = datetime.datetime.now().strftime("%Y%m%d-%H%M")

(root / "version.json").write_text(json.dumps({"version": v}) + "\n")
(root / "js" / "version.js").write_text(f'window.APP_VERSION = "{v}";\n')

html = (root / "index.html").read_text()
html = re.sub(r'\?v=[A-Za-z0-9.\-]+"', f'?v={v}"', html)
(root / "index.html").write_text(html)
print("version", v)
