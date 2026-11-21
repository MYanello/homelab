#!/bin/sh
set -eu

MODE=adf
DEV=
for arg in "$@"; do
  case "$arg" in
    adf|fb) MODE="$arg" ;;
    *) DEV="$arg" ;;
  esac
done
: "${DEV:=net1;dev0}"

case "$MODE" in
  fb) SOURCE="FlatBed" ;;
  *) SOURCE="Automatic Document Feeder(left aligned)" ;;
esac

WORK=/tmp/scan
mkdir -p "$WORK"
rm -f "$WORK"/*.tif "$WORK"/*.pdf

echo "scan: mode=$MODE device=$DEV source=$SOURCE"

case "$DEV" in
  *net*) sleep 1 ;;
esac

attempt=0
while : ; do
  rc=0
  scanimage \
    --device-name "brother4:$DEV" \
    --source "$SOURCE" \
    --resolution 600 \
    --batch="$WORK/page-%04d.tif" || rc=$?
  if [ "$rc" -eq 0 ] || [ "$rc" -eq 7 ]; then
    break
  fi
  attempt=$((attempt + 1))
  if [ "$attempt" -ge 3 ]; then
    echo "scanimage exited $rc after $attempt attempts" >&2
    exit "$rc"
  fi
  sleep 1
  rm -f "$WORK"/*.tif
done

set -- "$WORK"/page-*.tif
if [ ! -e "$1" ]; then
  echo "no pages returned by $SOURCE" >&2
  exit 0
fi

img2pdf --output "$WORK/scan.pdf" "$@"

DEST=${SCAN_DROP_DIR:-/consume}
mkdir -p "$DEST"
find "$DEST" -maxdepth 1 -name '.incoming-*.tmp' -mmin +60 -delete
NAME="scan-$(date +%Y%m%d-%H%M%S).pdf"
install -m 644 "$WORK/scan.pdf" "$DEST/.incoming-$NAME.tmp"
mv "$DEST/.incoming-$NAME.tmp" "$DEST/$NAME"

echo "dropped $DEST/$NAME"
rm -f "$WORK"/*.tif "$WORK"/*.pdf
