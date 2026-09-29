from __future__ import annotations

import json
import sys
from pathlib import Path

STRIP_KEYS = ("id", "version", "__requires", "gnetId")


def is_dashboard(obj: object) -> bool:
    return isinstance(obj, dict) and "panels" in obj


def sanitize(text: str) -> str | None:
    obj = json.loads(text)
    if not is_dashboard(obj):
        return None
    for key in STRIP_KEYS:
        obj.pop(key, None)
    return json.dumps(obj, indent=2, ensure_ascii=False) + "\n"


def main(argv: list[str]) -> int:
    check = "--check" in argv
    paths = [Path(arg) for arg in argv[1:] if not arg.startswith("-")]
    changed: list[Path] = []
    for path in paths:
        if path.suffix != ".json" or not path.is_file():
            continue
        original = path.read_text(encoding="utf-8")
        try:
            sanitized = sanitize(original)
        except json.JSONDecodeError as exc:
            print(f"{path}: invalid JSON: {exc}", file=sys.stderr)
            return 1
        if sanitized is None or sanitized == original:
            continue
        changed.append(path)
        if not check:
            path.write_text(sanitized, encoding="utf-8")
    if check and changed:
        print("Grafana dashboards need sanitizing:")
        for path in changed:
            print(f"  {path}")
        return 1
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv))
