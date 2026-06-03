#!/usr/bin/env bash
set -euo pipefail

APK_PATH="${1:-/private/tmp/medicine-apk-verify/jiaanxin-android-1.0-6-play-signed.apk}"
BUCKET="${CLOUDFLARE_R2_BUCKET:-jiaanxin-downloads}"
KEY="android/jiaanxin-android-1.0-6-play-signed.apk"
FILENAME="jiaanxin-android-1.0-6-play-signed.apk"
EXPECTED_SHA256="462c7be07735bd8abbe5efec4a00bf309c982cc8620c0557afce34a0435307f2"

if [[ ! -f "$APK_PATH" ]]; then
  echo "APK not found: $APK_PATH" >&2
  exit 1
fi

ACTUAL_SHA256="$(shasum -a 256 "$APK_PATH" | awk '{print $1}')"
if [[ "$ACTUAL_SHA256" != "$EXPECTED_SHA256" ]]; then
  echo "SHA-256 mismatch for $APK_PATH" >&2
  echo "expected: $EXPECTED_SHA256" >&2
  echo "actual:   $ACTUAL_SHA256" >&2
  exit 1
fi

npx --yes wrangler@latest r2 object put "$BUCKET/$KEY" \
  --remote \
  --file "$APK_PATH" \
  --content-type "application/vnd.android.package-archive" \
  --content-disposition "attachment; filename=\"$FILENAME\"" \
  --cache-control "public, max-age=31536000, immutable"

echo "Uploaded $BUCKET/$KEY"
echo "Expected URL: https://download.jiaanxin.app/$KEY"
