#!/usr/bin/env bash
# Portable apt index builder. Uses dpkg-deb + sha256sum + md5sum directly,
# so it works without apt-ftparchive (handy for environments that have
# only dpkg-dev). Produces the same Packages/Release output as
# build-index.sh.

set -euo pipefail

GPG_KEY_ID=${GPG_KEY_ID:-${1:-}}
[ -n "$GPG_KEY_ID" ] || { echo "GPG_KEY_ID not set" >&2; exit 1; }

ROOT=$(pwd)
DIST=stable
COMPONENT=main
ARCHES="amd64 arm64 all"

# Build a Packages stanza for one .deb. Filename is the path relative to
# the repo root, since apt fetches it relative to the dist URL.
gen_stanza() {
    local deb=$1
    local size sha256 md5
    size=$(stat -c%s "$deb")
    sha256=$(sha256sum "$deb" | awk '{print $1}')
    md5=$(md5sum "$deb" | awk '{print $1}')
    dpkg-deb -f "$deb" Package Version Architecture Maintainer Depends Section Priority Homepage Description
    printf 'Filename: %s\n' "$deb"
    printf 'Size: %s\n' "$size"
    printf 'MD5sum: %s\n' "$md5"
    printf 'SHA256: %s\n' "$sha256"
    printf '\n'
}

cd "$ROOT"

# Per-arch Packages files. A .deb with Architecture: all is included in
# every arch's index, since its binaries run anywhere.
for arch in $ARCHES; do
    out_dir="dists/$DIST/$COMPONENT/binary-$arch"
    mkdir -p "$out_dir"
    : > "$out_dir/Packages"
    while IFS= read -r -d '' deb; do
        deb_arch=$(dpkg-deb -f "$deb" Architecture)
        if [ "$arch" = "all" ]; then
            [ "$deb_arch" = "all" ] || continue
        else
            [ "$deb_arch" = "$arch" ] || [ "$deb_arch" = "all" ] || continue
        fi
        gen_stanza "$deb" >> "$out_dir/Packages"
    done < <(find pool -type f -name '*.deb' -print0 | sort -z)
    gzip -kf9 "$out_dir/Packages"
    lines=$(wc -l < "$out_dir/Packages")
    echo "wrote $out_dir/Packages ($lines lines)"
done

cd "dists/$DIST"
cat > Release <<EOF
Origin: ra-yavuz
Label: ra-yavuz Linux packages
Suite: stable
Codename: stable
Version: 1.0
Architectures: $ARCHES
Components: $COMPONENT
Description: Personal Debian/Ubuntu apt repository for ra-yavuz Linux tools.
Date: $(LC_ALL=C date -u '+%a, %d %b %Y %H:%M:%S UTC')
EOF
{
    echo "SHA256:"
    find . -type f \( -name 'Packages' -o -name 'Packages.gz' \) | sort | while read -r f; do
        size=$(stat -c%s "$f")
        sha=$(sha256sum "$f" | awk '{print $1}')
        printf ' %s %16d %s\n' "$sha" "$size" "${f#./}"
    done
} >> Release

rm -f InRelease Release.gpg
gpg --batch --yes --default-key "$GPG_KEY_ID" --clearsign -o InRelease   Release
gpg --batch --yes --default-key "$GPG_KEY_ID" -abs       -o Release.gpg Release

cd "$ROOT"
echo
echo "Signed Release files:"
ls -la "dists/$DIST/InRelease" "dists/$DIST/Release" "dists/$DIST/Release.gpg"
