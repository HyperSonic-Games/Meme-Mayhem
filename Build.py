import os
import shutil
from pathlib import Path


"""
Add deps by importing modules that expose:
    RULES = [...]
and appending them to DEP_MODULES
"""

import Magma.COPY_FILES as magma

class MemeMayhem:
    RULES = [
        {
            "from": "./Client/MMClient.exe",
            "to": "MMClient.exe",
            "os": "windows",
        }
]


def build():
    pass

DEP_MODULES = [
    magma,
    MemeMayhem
]


PROJECT_ROOT = Path(__file__).resolve().parent
BUILD_DIR = PROJECT_ROOT / "build"

ODIN_ROOT_RAW = os.environ.get("ODIN_ROOT")

if ODIN_ROOT_RAW is None:
    raise RuntimeError("ODIN_ROOT environment variable is not set")

ODIN_ROOT = Path(ODIN_ROOT_RAW)

RUNTIME_OS = "windows" if os.name == "nt" else "unix"


# -----------------------------
# HELPERS
# -----------------------------

def match_os(rule_os: str | None) -> bool:
    if rule_os is None:
        return True
    if rule_os == "windows":
        return RUNTIME_OS == "windows"
    if rule_os == "unix":
        return RUNTIME_OS != "windows"
    return False


def resolve(p: str) -> Path:
    if p.startswith("./"):
        return (PROJECT_ROOT / p[2:]).resolve()

    if ODIN_ROOT is None:
        raise RuntimeError("ODIN_ROOT is not set")

    return (ODIN_ROOT.joinpath("vendor", p)).resolve()


def copy(src: Path, dst: Path):
    if not src.exists():
        raise RuntimeError(f"Missing file: {src}")

    dst.parent.mkdir(parents=True, exist_ok=True)
    shutil.copy2(src, dst)

    print(f"[COPY] {src} -> {dst}")


# -----------------------------
# BUILD
# -----------------------------

def run():
    build()
    BUILD_DIR.mkdir(parents=True, exist_ok=True)

    for mod in DEP_MODULES:
        if not hasattr(mod, "RULES"):
            raise RuntimeError(f"Module missing RULES: {mod}")

        for rule in mod.RULES:

            if not match_os(rule.get("os")):
                continue

            src = resolve(rule["from"])
            dst = BUILD_DIR / rule["to"]

            copy(src, dst)



if __name__ == "__main__":
    run()