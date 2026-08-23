#!/bin/bash
#
# Build and install software from local PKGBUILD directories
# (for anything not in the official repos that you maintain yourself,
#  instead of relying on the AUR).
#
# Assumes sources are already fetched/up to date in each package's src/
# (e.g. after running check-updates.sh, which runs `makepkg -co`).
#
# Usage:
#   ./build-packages.sh              -> auto-detects every subdir with a PKGBUILD
#   ./build-packages.sh pkgA pkgB    -> only build the named directories
#
# For each package directory:
#   1. updpkgsums    -> refresh checksums to match already-fetched sources
#   2. makepkg -sirc  -> build (reusing existing sources) and install

set -uo pipefail

DIRS=()

for arg in "$@"; do
    DIRS+=("${arg%/}")
done

# Auto-detect: if no directories given, use every immediate subdir containing a PKGBUILD
if [ "${#DIRS[@]}" -eq 0 ]; then
    for d in */; do
        d="${d%/}"
        if [ -f "$d/PKGBUILD" ]; then
            DIRS+=("$d")
        fi
    done
fi

if [ "${#DIRS[@]}" -eq 0 ]; then
    echo "No package directories with a PKGBUILD found (and none specified)."
    exit 1
fi

echo "Packages to build: ${DIRS[*]}"
echo

BASE_DIR="$(pwd)"
FAILED=()
SUCCEEDED=()

for pkgdir in "${DIRS[@]}"; do
    echo "=============================================="
    echo ":: Building package: $pkgdir"
    echo "=============================================="

    if [ ! -d "$pkgdir" ]; then
        echo "!! Directory '$pkgdir' not found, skipping."
        FAILED+=("$pkgdir (missing directory)")
        continue
    fi

    if [ ! -f "$pkgdir/PKGBUILD" ]; then
        echo "!! No PKGBUILD found in '$pkgdir', skipping."
        FAILED+=("$pkgdir (no PKGBUILD)")
        continue
    fi

    cd "$BASE_DIR/$pkgdir" || { FAILED+=("$pkgdir (cd failed)"); continue; }

    echo "-- Step 1: updpkgsums (refresh checksums)"
    if ! updpkgsums; then
        echo "!! updpkgsums failed for $pkgdir"
        FAILED+=("$pkgdir (updpkgsums)")
        cd "$BASE_DIR"
        continue
    fi

    echo "-- Step 2: makepkg -sirc (build + install)"
    if ! makepkg -sirc; then
        echo "!! makepkg -sirc failed for $pkgdir"
        FAILED+=("$pkgdir (makepkg -sirc)")
        cd "$BASE_DIR"
        continue
    fi

    echo ":: $pkgdir installed successfully."
    SUCCEEDED+=("$pkgdir")
    cd "$BASE_DIR"
done

echo
echo "=============================================="
echo "Summary"
echo "=============================================="
if [ "${#SUCCEEDED[@]}" -gt 0 ]; then
    echo "Succeeded:"
    for s in "${SUCCEEDED[@]}"; do
        echo "  - $s"
    done
fi

if [ "${#FAILED[@]}" -eq 0 ]; then
    echo
    echo "All packages built and installed successfully."
else
    echo
    echo "Failed:"
    for f in "${FAILED[@]}"; do
        echo "  - $f"
    done
    exit 1
fi
