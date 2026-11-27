#!/usr/bin/env python3
"""Generate the iTerm2 Dynamic Profiles file from iterm/base.json + iterm/colors/*.itermcolors.

Output: dotfiles/iterm/Library/Application Support/iTerm2/DynamicProfiles/dotfiles.json
(stowed into ~/Library/Application Support/iTerm2/DynamicProfiles/).

Profiles produced:
  "Dotfiles"            base profile (font, keys, scrollback, ...) + default theme colours
  "<Theme Name>"        one child profile per .itermcolors file, inheriting from "Dotfiles"

Add a theme: drop a .itermcolors file into iterm/colors/ (e.g. from
https://github.com/mbadolato/iTerm2-Color-Schemes) and re-run this script.
"""
import json
import os
import plistlib
import sys
import uuid
from pathlib import Path

HERE = Path(__file__).resolve().parent
REPO = HERE.parent
OUT = REPO / "dotfiles/iterm/Library/Application Support/iTerm2/DynamicProfiles/dotfiles.json"
NS = uuid.UUID("6f1f6a0e-2b7e-4c38-9a59-6a1b0d0f5e11")  # stable GUIDs across machines


def load_colors(path: Path) -> dict:
    with path.open("rb") as fh:
        data = plistlib.load(fh)
    # keep only colour dicts (keys like "Ansi 0 Color", "Background Color", ...)
    return {k: v for k, v in data.items() if k.endswith("Color") and isinstance(v, dict)}


def main() -> int:
    base = json.loads((HERE / "base.json").read_text())
    default_theme = base.pop("_default_theme")
    base = {k: v for k, v in base.items() if not k.startswith("_")}  # drop _comment_* notes
    themes = sorted((HERE / "colors").glob("*.itermcolors"))
    if not themes:
        print("no themes in iterm/colors", file=sys.stderr)
        return 1

    names = [t.stem for t in themes]
    if default_theme not in names:
        print(f"default theme {default_theme!r} not found", file=sys.stderr)
        return 1

    base_name = base["Name"]
    base["Guid"] = str(uuid.uuid5(NS, base_name))
    base.update(load_colors(HERE / "colors" / f"{default_theme}.itermcolors"))

    profiles = [base]
    for t in themes:
        p = {
            "Name": t.stem,
            "Guid": str(uuid.uuid5(NS, "theme:" + t.stem)),
            "Dynamic Profile Parent Name": base_name,
            "Tags": ["theme"],
        }
        p.update(load_colors(t))
        profiles.append(p)

    OUT.parent.mkdir(parents=True, exist_ok=True)
    OUT.write_text(json.dumps({"Profiles": profiles}, indent=2, sort_keys=False) + "\n")
    print(f"wrote {len(profiles)} profiles -> {OUT.relative_to(REPO)}")
    print(f"base GUID: {base['Guid']}")

    # iTerm watches the DynamicProfiles *folder*. The file there is a symlink into this repo,
    # so editing the repo copy doesn't change the folder and iTerm keeps the old profile.
    # Touching the symlink itself makes iTerm reload it immediately.
    link = Path.home() / "Library/Application Support/iTerm2/DynamicProfiles" / OUT.name
    if link.is_symlink():
        os.utime(link, follow_symlinks=False)
        print("iTerm notified (profiles reloaded)")
    return 0


if __name__ == "__main__":
    sys.exit(main())
