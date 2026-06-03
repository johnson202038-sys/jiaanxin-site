#!/usr/bin/env bash
set -euo pipefail

APK_PATH="${1:-/private/tmp/medicine-apk-verify/jiaanxin-android-1.0-7-play-signed.apk}"
BUCKET="${CLOUDFLARE_R2_BUCKET:-jiaanxin-downloads}"
KEY="android/jiaanxin-android-1.0-7-play-signed.apk"
FILENAME="jiaanxin-android-1.0-7-play-signed.apk"
EXPECTED_SHA256="a15e56e68a4500f71eaed766277c700b4ce84b402bce068514c6bde7cec992a3"

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
