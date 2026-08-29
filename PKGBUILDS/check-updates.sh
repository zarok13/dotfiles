#!/bin/bash
#
# Check for available updates on locally-built PKGBUILD packages,
# WITHOUT building anything. Useful before running build-packages.sh.
#
# For each package directory:
#   1. updpkgsums   -> refresh checksums to match already-fetched sources
#   2. Runs `makepkg -co` (clean + fetch sources only) so any pkgver()
#      function gets a chance to auto-bump pkgver= in the PKGBUILD
#
# Usage:
#   ./check-updates.sh                 -> auto-detects every subdir with a PKGBUILD
#   ./check-updates.sh pkgA pkgB       -> only check the named directories
#   ./check-updates.sh --quiet ...     -> only print packages that have updates

set -uo pipefail

QUIET=0
DIRS=()

for arg in "$@"; do
    case "$arg" in
        --quiet)
            QUIET=1
            ;;
        *)
            DIRS+=("${arg%/}")
            ;;
    esac
done

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

BASE_DIR="$(pwd)"
UPDATES=()
UPTODATE=()
ERRORS=()

get_pkgname() {
    local dir="$1"
    local name
    name=$(grep -m1 '^pkgname=' "$dir/PKGBUILD" \
        | sed -E "s/^pkgname=\(?['\"]?([A-Za-z0-9._+-]+).*/\1/")
    if [ -z "$name" ]; then
        name="$dir"
    fi
    echo "$name"
}

get_pkgver_pkgrel() {
    local dir="$1"
    local pkgver pkgrel
    pkgver=$(grep -m1 '^pkgver=' "$dir/PKGBUILD" | cut -d= -f2)
    pkgrel=$(grep -m1 '^pkgrel=' "$dir/PKGBUILD" | cut -d= -f2)
    echo "${pkgver}-${pkgrel}"
}

for pkgdir in "${DIRS[@]}"; do
    if [ ! -f "$pkgdir/PKGBUILD" ]; then
        ERRORS+=("$pkgdir (no PKGBUILD)")
        continue
    fi

    [ "$QUIET" -eq 0 ] && echo ":: Checking $pkgdir ..."

    pkgname=$(get_pkgname "$pkgdir")
    old_full_ver=$(get_pkgver_pkgrel "$pkgdir")

    installed_ver=$(pacman -Q "$pkgname" 2>/dev/null | awk '{print $2}')
    if [ -z "$installed_ver" ]; then
        installed_ver="(not installed)"
    fi

    cd "$BASE_DIR/$pkgdir" || { ERRORS+=("$pkgdir (cd failed)"); continue; }

    echo "-- updpkgsums (refresh checksums)"
    if ! updpkgsums; then
        echo "!! updpkgsums failed for $pkgdir"
        FAILED+=("$pkgdir (updpkgsums)")
        cd "$BASE_DIR"
        continue
    fi

    # Sanitize in case pkgdir contains slashes, so the log path is always a flat filename.
    safe_name="${pkgdir//\//_}"

    # Show makepkg's real output live, and also keep a copy in /tmp for reference.
    if ! makepkg -co 2>&1 | tee "/tmp/check-updates-${safe_name}.log"; then
        # Even if the build check fails (e.g. stale checksum), pkgver() may
        # still have already updated pkgver= before failing, so we keep going.
        :
    fi

    cd "$BASE_DIR"

    new_full_ver=$(get_pkgver_pkgrel "$pkgdir")

    if [ "$installed_ver" = "(not installed)" ]; then
        echo "  [$pkgname] not installed. Available: $new_full_ver"
        UPDATES+=("$pkgname: not installed -> $new_full_ver")
        continue
    fi

    if [ "$new_full_ver" != "$installed_ver" ]; then
        echo "  [$pkgname] update available: $installed_ver -> $new_full_ver"
        UPDATES+=("$pkgname: $installed_ver -> $new_full_ver")
    else
        [ "$QUIET" -eq 0 ] && echo "  [$pkgname] up to date ($installed_ver)"
        UPTODATE+=("$pkgname ($installed_ver)")
    fi
done

echo
echo "=============================================="
echo "Summary"
echo "=============================================="

if [ "${#UPDATES[@]}" -gt 0 ]; then
    echo "Updates available:"
    for u in "${UPDATES[@]}"; do
        echo "  - $u"
    done
else
    echo "No updates available."
fi

if [ "$QUIET" -eq 0 ] && [ "${#UPTODATE[@]}" -gt 0 ]; then
    echo
    echo "Up to date:"
    for u in "${UPTODATE[@]}"; do
        echo "  - $u"
    done
fi

if [ "${#ERRORS[@]}" -gt 0 ]; then
    echo
    echo "Errors:"
    for e in "${ERRORS[@]}"; do
        echo "  - $e"
    done
fi

if [ "${#UPDATES[@]}" -gt 0 ]; then
    exit 2
fi
exit 0
