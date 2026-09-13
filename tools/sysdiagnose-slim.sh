#!/bin/bash
#
# sysdiagnose-slim.sh - shrink an iPhone/iPad sysdiagnose archive to a small zip
#
# A sysdiagnose (sysdiagnose_*.tar.gz, usually 200-500 MB) is mostly one binary
# log database (system_logs.logarchive) that only a Mac can read. Everything
# needed for a first diagnosis - crash, panic, hang and out-of-memory reports,
# process / memory / storage / battery / network snapshots, install and update
# logs - is small text. This script keeps the small text and drops the bulky
# binaries, so the result fits GitHub's 25 MB browser upload limit.
#
# Works on macOS (Terminal) and Linux. Needs: bash, tar, find, split, zip (or python3).
#
# Usage
#   bash sysdiagnose-slim.sh
#       finds the newest sysdiagnose_*.tar.gz in ~/Downloads, ~/Desktop or the current folder
#   bash sysdiagnose-slim.sh ~/Downloads/sysdiagnose_2026.09.13_10-00-00+0100_iPhone-OS_iPhone_23A341.tar.gz
#   bash sysdiagnose-slim.sh /path/to/an/already/unpacked/sysdiagnose_folder
#
# Result
#   <name>-slim.zip next to the archive (on the Desktop if that folder is read-only).
#   If the zip is bigger than 24 MB it is cut into <name>-slim.zip.part-aa, -ab, ...
#   Upload ALL the parts; they are joined again with:
#       cat <name>-slim.zip.part-* > <name>-slim.zip
#
# Options (environment variables)
#   SLIM_MAX_MB=24     part size limit in MB (GitHub browser upload allows 25 MB per file)

set -euo pipefail

MAX_MB="${SLIM_MAX_MB:-24}"

die() { echo "ERROR: $*" >&2; exit 1; }

for t in tar find split; do
  command -v "$t" >/dev/null 2>&1 || die "'$t' is not installed"
done
if ! command -v zip >/dev/null 2>&1 && ! command -v python3 >/dev/null 2>&1; then
  die "need either 'zip' or 'python3' to create the zip"
fi

# ---- 0. locate the source -------------------------------------------------
SRC="${1:-}"
if [ -z "$SRC" ]; then
  SRC="$(ls -t "$HOME"/Downloads/sysdiagnose_*.tar.gz "$HOME"/Desktop/sysdiagnose_*.tar.gz ./sysdiagnose_*.tar.gz 2>/dev/null | head -n 1 || true)"
  [ -n "$SRC" ] || die "no sysdiagnose_*.tar.gz found in ~/Downloads, ~/Desktop or the current folder.
Usage: bash $0 /path/to/sysdiagnose_....tar.gz"
  echo "Using the newest archive found: $SRC"
fi
[ -e "$SRC" ] || die "not found: $SRC"

case "$SRC" in
  *.tar.gz) BASE="${SRC%.tar.gz}" ;;
  *.tgz)    BASE="${SRC%.tgz}" ;;
  *)
    [ -d "$SRC" ] || die "expected a .tar.gz archive or an unpacked sysdiagnose folder: $SRC"
    BASE="${SRC%/}" ;;
esac

OUT_DIR="$(cd "$(dirname "$SRC")" && pwd)"
if [ ! -w "$OUT_DIR" ]; then
  if [ -d "$HOME/Desktop" ]; then OUT_DIR="$HOME/Desktop"; else OUT_DIR="$PWD"; fi
fi
NAME="$(basename "$BASE")"
OUT="$OUT_DIR/$NAME-slim.zip"

# ---- 1. what gets dropped ---------------------------------------------------
# Bulky binary parts that need a Mac to read, or are not needed for a first look.
EXCLUDES='
system_logs.logarchive
*.logarchive
*.tracev3
*.tailspin
*.ktrace
*.PLSQL
*.PLSQL-shm
*.PLSQL-wal
*.pklg
*.pcap
*.pcapng
'
set -f                                   # no filename globbing while we handle the patterns
TAR_EX=()
EXCL_LINE=""
for p in $EXCLUDES; do
  TAR_EX+=( "--exclude=$p" )
  EXCL_LINE="$EXCL_LINE $p"
done
set +f

TMP="$(mktemp -d "${TMPDIR:-/tmp}/sysdiagnose-slim.XXXXXX")"
trap 'rm -rf "$TMP"' EXIT
mkdir -p "$TMP/src"

# ---- 2. unpack without the bulk ----------------------------------------------
echo "1/4  Unpacking (the big binary logs are skipped) ..."
if [ -d "$SRC" ]; then
  tar "${TAR_EX[@]}" -cf - -C "$(dirname "$SRC")" "$(basename "$SRC")" | tar -xf - -C "$TMP/src"
else
  tar "${TAR_EX[@]}" -xzf "$SRC" -C "$TMP/src"
fi
[ -n "$(ls -A "$TMP/src")" ] || die "nothing was unpacked. Is this really a sysdiagnose .tar.gz?"

# Belt and braces: remove anything the tar exclusion missed (inside the temp copy only).
set -f
for p in $EXCLUDES; do
  find "$TMP/src" -name "$p" -prune -exec rm -rf {} + 2>/dev/null || true
done
set +f

# ---- 3. manifest ---------------------------------------------------------------
echo "2/4  Writing the manifest ..."
KEPT_FILES="$(find "$TMP/src" -type f | wc -l | tr -d ' ')"
KEPT_SIZE="$(du -sh "$TMP/src" | cut -f1)"
{
  echo "sysdiagnose-slim manifest"
  echo "created:      $(date)"
  echo "source:       $SRC"
  if [ -f "$SRC" ]; then echo "source size:  $(du -h "$SRC" | cut -f1)"; fi
  echo "kept:         $KEPT_FILES files, $KEPT_SIZE unpacked"
  echo "dropped:     $EXCL_LINE"
  echo
  echo "--- files kept (KB  path) ---"
  (cd "$TMP/src" && find . -type f -exec du -k {} + | sort -k2)
} > "$TMP/src/SLIM-MANIFEST.txt"

# ---- 4. zip ------------------------------------------------------------------
echo "3/4  Compressing $KEPT_FILES files ($KEPT_SIZE) ..."
rm -f "$OUT" "$OUT".part-*
if command -v zip >/dev/null 2>&1; then
  (cd "$TMP/src" && zip -q -r -9 -y "$OUT" .)
else
  python3 - "$TMP/src" "$OUT" <<'PY'
import os, sys, zipfile
src, out = sys.argv[1], sys.argv[2]
with zipfile.ZipFile(out, "w", zipfile.ZIP_DEFLATED, compresslevel=9) as z:
    for root, _dirs, files in os.walk(src):
        for f in files:
            p = os.path.join(root, f)
            if os.path.islink(p):
                continue
            z.write(p, os.path.relpath(p, src))
PY
fi

# ---- 5. size check and split ---------------------------------------------------
echo "4/4  Checking the size ..."
BYTES="$(wc -c < "$OUT" | tr -d ' ')"
MB=$(( (BYTES + 1048575) / 1048576 ))
echo
if [ "$MB" -gt "$MAX_MB" ]; then
  split -b "${MAX_MB}m" "$OUT" "$OUT.part-"
  rm -f "$OUT"
  PARTS="$(ls "$OUT".part-* | wc -l | tr -d ' ')"
  echo "DONE. The zip was $MB MB, so it was cut into $PARTS parts of at most $MAX_MB MB each."
  echo "Upload ALL of these files:"
  ls -1 "$OUT".part-*
  echo "(They are joined again with:  cat \"$OUT\".part-* > \"$OUT\")"
else
  echo "DONE. Upload this one file ($MB MB):"
  echo "$OUT"
fi
if [ "$MB" -gt 150 ]; then
  echo "WARNING: the result is still large. The exclusions may not have matched; mention this size when you report back."
fi
echo
echo "Upload to: github.com/eugenenikolajev-blip/hi -> branch claude/iphone-system-analysis-3fhpk5 -> folder iphone-logs -> Add file -> Upload files"
echo "The zip contains device identifiers, Wi-Fi names and your app list: keep the repository private."
