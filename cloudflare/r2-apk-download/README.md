# Android APK first-party download

This folder documents the Cloudflare R2 setup for serving the temporary Android
APK from a first-party attachment URL:

`https://download.jiaanxin.app/android/jiaanxin-android-1.0-6-play-signed.apk`

## Current artifact

- Local verified APK:
  `/private/tmp/medicine-apk-verify/jiaanxin-android-1.0-6-play-signed.apk`
- Filename:
  `jiaanxin-android-1.0-6-play-signed.apk`
- Object key:
  `android/jiaanxin-android-1.0-6-play-signed.apk`
- Size:
  `84,057,722 bytes`
- SHA-256:
  `462c7be07735bd8abbe5efec4a00bf309c982cc8620c0557afce34a0435307f2`
- Verified:
  package `app.jiaanxin.mobile`, `versionCode=6`, `versionName=1.0`,
  `apksigner verify` PASS, `unzip -t` PASS.

Do not commit the APK or AAB into this repository.

## Cloudflare shape

- DNS is on Cloudflare nameservers.
- Bucket: `jiaanxin-downloads`
- Custom domain: `download.jiaanxin.app`
- The custom domain should not be registered as an Android App Link.
- The object must be uploaded with attachment HTTP metadata:
  - `Content-Type: application/vnd.android.package-archive`
  - `Content-Disposition: attachment; filename="jiaanxin-android-1.0-6-play-signed.apk"`
  - `X-Content-Type-Options: nosniff`
  - `Cache-Control: public, max-age=31536000, immutable`

## Wrangler flow

After `npx --yes wrangler@latest login` succeeds:

```bash
npx --yes wrangler@latest r2 bucket create jiaanxin-downloads
```

If the bucket already exists, skip creation.

Upload the verified APK:

```bash
cloudflare/r2-apk-download/upload-apk6-to-r2.sh
```

Attach the custom domain. Wrangler currently requires the Cloudflare zone id:

```bash
npx --yes wrangler@latest r2 bucket domain add jiaanxin-downloads \
  --domain download.jiaanxin.app \
  --zone-id <CLOUDFLARE_ZONE_ID>
```

Then verify:

```bash
curl -sS -I https://download.jiaanxin.app/android/jiaanxin-android-1.0-6-play-signed.apk
curl -sS https://download.jiaanxin.app/android/jiaanxin-android-1.0-6-play-signed.apk \
  -o /private/tmp/jiaanxin-apk6-download-check.apk
shasum -a 256 /private/tmp/jiaanxin-apk6-download-check.apk
```

Only after the first-party URL returns the correct headers and checksum should
`download/index.html` be updated to point at `download.jiaanxin.app`.

