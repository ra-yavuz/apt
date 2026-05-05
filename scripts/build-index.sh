#!/usr/bin/env bash
# Rebuild the apt repository indices and sign them.
#
# Inputs:
#   pool/**/*.deb     all packages to be indexed
#   $GPG_KEY_ID       fingerprint of the signing key (env var or arg)
#
# Outputs (all under dists/stable/):
#   main/binary-<arch>/Packages
#   main/binary-<arch>/Packages.gz
#   Release
#   Release.gpg                 (clear-detached signature, legacy clients)
#   InRelease                   (clear-signed, modern clients)
#
# Run from the repo root.

set -euo pipefail

GPG_KEY_ID=${GPG_KEY_ID:-${1:-}}
[ -n "$GPG_KEY_ID" ] || { echo "GPG_KEY_ID not set" >&2; exit 1; }

ROOT=$(pwd)
DIST=stable
COMPONENT=main

cd "$ROOT"

# Build per-arch Packages files. apt-ftparchive scans pool/ and emits the
# index relative to the current directory.
build_arch() {
    local arch=$1
    local outdir="dists/$DIST/$COMPONENT/binary-$arch"
    mkdir -p "$outdir"
    apt-ftparchive --arch "$arch" packages pool/ > "$outdir/Packages"
    gzip -kf9 "$outdir/Packages"
    echo "wrote $outdir/Packages ($(wc -l < "$outdir/Packages") lines)"
}

# Architecture-independent packages live under binary-all by Debian
# convention but apt clients fetch them via each concrete arch's Packages
# index too. We index amd64 and arm64 (the two architectures we'll
# realistically build for), plus an all-only index for completeness.
ARCHES="amd64 arm64 all"
for a in $ARCHES; do
    build_arch "$a"
done

# Top-level Release file.
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

# Append SHA256 sums for every Packages file. apt verifies these against
# the signed Release file, so the chain of trust is:
#   InRelease (or Release+Release.gpg, GPG signed)
#     -> SHA256 of Packages
#       -> SHA256 of each .deb (in Packages)
{
    echo "SHA256:"
    find . -type f \( -name 'Packages' -o -name 'Packages.gz' \) | sort | while read -r f; do
        size=$(stat -c%s "$f")
        sha=$(sha256sum "$f" | awk '{print $1}')
        # leading space, then hash size path-without-leading-./
        printf ' %s %16d %s\n' "$sha" "$size" "${f#./}"
    done
} >> Release

# Sign the Release file two ways. InRelease is the modern format
# (clear-signed, single-file). Release.gpg is the legacy detached
# signature, kept for older apt clients.
rm -f InRelease Release.gpg
gpg --batch --yes --default-key "$GPG_KEY_ID" --clearsign -o InRelease   Release
gpg --batch --yes --default-key "$GPG_KEY_ID" -abs       -o Release.gpg Release

cd "$ROOT"
echo
echo "Signed Release files:"
ls -la "dists/$DIST/InRelease" "dists/$DIST/Release" "dists/$DIST/Release.gpg"
