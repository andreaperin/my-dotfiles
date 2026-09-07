#!/usr/bin/env python3
"""Report noctalia settings that live only on this machine.

noctalia 5 loads config in two layers:

    1. every *.toml in ~/.config/noctalia/     <- tracked in dotfiles
    2. ~/.local/state/noctalia/settings.toml   <- written by the Settings UI

Layer 2 wins, per key. So anything you change in the UI silently shadows the
dotfiles copy until you migrate it. That failure is invisible: the dotfiles
value is still there, it just stops taking effect.

This script prints what is sitting in layer 2. Blocks that are genuinely
machine-specific are ignored; everything else is drift you probably meant to
put in dotfiles.

Exit status: 0 = no drift, 1 = drift found (usable in a pre-commit hook).
"""

import os
import sys
import tomllib

STATE = os.path.expanduser(
    os.environ.get("NOCTALIA_STATE_HOME", "~/.local/state/noctalia")
)
if not STATE.rstrip("/").endswith("noctalia"):
    STATE = os.path.join(STATE, "noctalia")
STATE_FILE = os.path.join(STATE, "settings.toml")

# Top-level keys that belong to this machine and should never be shared.
#   lockscreen_widgets -> per-output pixel coordinates, keyed by connector
#                         name (DP-10, HDMI-A-1) which is not stable
#   wallpaper.last     -> rewritten every time the wallpaper changes
#   config_version     -> schema marker, managed by noctalia
MACHINE_LOCAL = {"lockscreen_widgets", "config_version"}
MACHINE_LOCAL_SUBKEYS = {"wallpaper": {"last", "monitors"}}


def flatten(obj, prefix=""):
    """Yield dotted key paths for every leaf value."""
    if isinstance(obj, dict):
        for k, v in obj.items():
            yield from flatten(v, f"{prefix}.{k}" if prefix else k)
    elif isinstance(obj, list) and obj and isinstance(obj[0], dict):
        yield prefix, f"<{len(obj)} entries>"
    else:
        yield prefix, obj


def main():
    if not os.path.exists(STATE_FILE):
        print(f"no state file at {STATE_FILE} - nothing to check")
        return 0

    with open(STATE_FILE, "rb") as fh:
        state = tomllib.load(fh)

    shared = {}
    for top, value in state.items():
        if top in MACHINE_LOCAL:
            continue
        if top in MACHINE_LOCAL_SUBKEYS and isinstance(value, dict):
            value = {
                k: v
                for k, v in value.items()
                if k not in MACHINE_LOCAL_SUBKEYS[top]
            }
            if not value:
                continue
        shared[top] = value

    if not shared:
        print("No drift. Everything in the state file is machine-specific.")
        return 0

    rows = [
        (k, v)
        for top, section in shared.items()
        for k, v in flatten(section, top)
    ]

    print(f"Settings that exist ONLY on this machine ({STATE_FILE}):\n")
    width = max(len(k) for k, _ in rows)
    for key, val in sorted(rows):
        print(f"  {key:<{width}}  = {val!r}")

    print(
        f"\n{len(rows)} setting(s) are overriding your dotfiles.\n"
        "These were changed in the Settings UI. For each one you want on every\n"
        "machine: copy it into the matching ~/dotfiles/noctalia/config/*.toml,\n"
        "then DELETE it from the state file, or the state copy keeps winning.\n"
        "\nVerify afterwards with:  noctalia config export merged"
    )
    return 1


if __name__ == "__main__":
    sys.exit(main())
