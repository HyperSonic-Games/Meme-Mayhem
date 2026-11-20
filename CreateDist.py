"""
Packages the compiled client, server, assets, and licenses into a
cross platform distribution ZIP archive
"""

import platform
import sys
import zipfile
from pathlib import Path

ROOT_DIR = Path(__file__).resolve().parent
BUILD_DIR = ROOT_DIR / "build"
DIST_DIR = ROOT_DIR / "Dist"

IS_WINDOWS = sys.platform in ("win32", "cygwin", "msys")
EXE_EXT = ".exe" if IS_WINDOWS else ""

FILES = [
    f"MMClient{EXE_EXT}",
    f"MMServer{EXE_EXT}",
]

DIRECTORIES = [
    "Assets",
]

ROOT_FILES = [
    "LICENSE",
    "THIRD_PARTY_LICENSES.txt",
]

IGNORED_FILES = {
    ".DS_Store",
    "Thumbs.db",
    "desktop.ini",
}

def get_platform_tag() -> str:
    """Returns a normalized 'os-arch' string for Windows, macOS, or Linux (32-bit & 64-bit)."""
    plat = sys.platform.lower()

    if plat in ("win32", "cygwin", "msys"):
        os_name = "windows"
    elif plat == "darwin":
        os_name = "macos"
    elif plat.startswith("linux"):
        os_name = "linux"
    else:
        raise RuntimeError(f"Unsupported operating system: {sys.platform}")

    machine = platform.machine().lower()
    arch_map = {
        # 64 bit x86
        "amd64": "x86_64",
        "x86_64": "x86_64",
        "x64": "x86_64",
        # 32 bit x86
        "i386": "x86",
        "i486": "x86",
        "i586": "x86",
        "i686": "x86",
        "x86": "x86",
        # 64 bit ARM
        "arm64": "arm64",
        "aarch64": "arm64",
        # 32 bit ARM
        "arm": "arm",
        "armv6l": "arm",
        "armv7l": "arm",
        "armhf": "arm",
    }
    arch_name = arch_map.get(machine)
    if not arch_name:
        raise RuntimeError(f"Unsupported architecture: {platform.machine()}")

    return f"{os_name}-{arch_name}"


def main():
    if not BUILD_DIR.is_dir():
        raise FileNotFoundError(f"Build directory not found: {BUILD_DIR}")

    DIST_DIR.mkdir(parents=True, exist_ok=True)
    dist_file = DIST_DIR / f"MemeMayhem-{get_platform_tag()}.zip"
    asset_count = 0

    try:
        with zipfile.ZipFile(
            dist_file,
            "w",
            compression=zipfile.ZIP_DEFLATED,
            compresslevel=9,
        ) as archive:
            # Copy executables
            for filename in FILES:
                path = BUILD_DIR / filename
                if not path.is_file():
                    raise FileNotFoundError(f"Missing build file: {path}")
                archive.write(path, filename)

            # Copy entire asset directories
            for dirname in DIRECTORIES:
                path = BUILD_DIR / dirname
                if not path.is_dir():
                    raise FileNotFoundError(f"Missing build directory: {path}")
                for file in sorted(path.rglob("*")):
                    if not file.is_file() or file.name in IGNORED_FILES:
                        continue
                    archive.write(file, file.relative_to(BUILD_DIR))
                    asset_count += 1

            # Copy license files from project root
            for filename in ROOT_FILES:
                path = ROOT_DIR / filename
                if not path.is_file():
                    raise FileNotFoundError(f"Missing root file: {path}")
                archive.write(path, filename)

    except Exception:
        if dist_file.exists():
            dist_file.unlink()
        raise

    print(f"Created distribution: {dist_file}")
    print(f"Included {len(FILES)} executables.")
    print(f"Included {asset_count} asset files.")
    print(f"Included {len(ROOT_FILES)} license files.")


if __name__ == "__main__":
    main()
