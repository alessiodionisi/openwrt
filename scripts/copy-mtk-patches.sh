#!/bin/bash
#
# Copy/remove kernel patches needed for BPI-R4 Pro 8X from the MTK feed.
#
# Usage:
#   ./scripts/copy-mtk-patches.sh          # copy patches
#   ./scripts/copy-mtk-patches.sh clean    # remove copied patches
#

set -e

FEED_DIR="../mtk-openwrt-feeds/25.12/files/target/linux/mediatek/patches-6.12"
TARGET_DIR="target/linux/mediatek/patches-6.12"

# Patch categories needed for BPI-R4 Pro 8X (MT7988A + MXL86252C + AS21XXX)
# Full series (sequential dependencies): eth, ppe
# Individual patches: everything else
NEEDED_GLOBS="
999-clk-02-*.patch
999-clk-03-*.patch
999-clk-04-*.patch
999-dsa-04-*.patch
999-dsa-05-*.patch
999-dsa-06-*.patch
999-dts-09-*.patch
999-dts-10-*.patch
999-dts-11-*.patch
999-dts-mt7988a-rfb-05-*.patch
999-dts-mt7988a-rfb-09-*.patch
999-dts-mt7988a-rfb-18-*.patch
999-ephy-as21xxx-01-*.patch
999-ephy-gpy211-*.patch
999-eth-*.patch
999-lvts-*.patch
999-net-01-*.patch
999-pcs-*.patch
999-ppe-*.patch
999-pwm-02-*.patch
999-sfp-02-*.patch
999-spi-nand-*.patch
999-tphy-*.patch
999-wed-01-*.patch
999-wed-03-*.patch
999-wed-04-*.patch
999-wed-13-*.patch
999-wed-14-*.patch
999-wed-16-*.patch
999-xHCI-01-*.patch
"

resolve_patches() {
  local patches=""
  for glob in $NEEDED_GLOBS; do
    for f in "$FEED_DIR"/$glob; do
      [ -f "$f" ] && patches="$patches $(basename "$f")"
    done
  done
  echo "$patches"
}

do_copy() {
  if [ ! -d "$FEED_DIR" ]; then
    echo "Error: MTK feed not found at $FEED_DIR"
    echo "Run: ./scripts/feeds update mtk_openwrt_feed"
    exit 1
  fi

  local copied=0
  for name in $(resolve_patches); do
    cp "$FEED_DIR/$name" "$TARGET_DIR/$name"
    copied=$((copied + 1))
  done

  echo "Copied $copied patches"
}

do_clean() {
  if [ ! -d "$FEED_DIR" ]; then
    echo "Error: MTK feed not found at $FEED_DIR"
    echo "Run: ./scripts/feeds update mtk_openwrt_feed"
    exit 1
  fi

  local removed=0
  for name in $(resolve_patches); do
    if [ -f "$TARGET_DIR/$name" ]; then
      rm "$TARGET_DIR/$name"
      removed=$((removed + 1))
    fi
  done

  echo "Removed $removed patches"
}

case "${1:-copy}" in
copy)
  do_copy
  ;;
clean)
  do_clean
  ;;
*)
  echo "Usage: $0 [copy|clean]"
  exit 1
  ;;
esac
