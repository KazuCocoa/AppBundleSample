
```
# Build apks with https://github.com/google/bundletool/releases
$ java -jar apks/bundletool-all-0.6.0.jar build-apks \
  --bundle AppBundleSample/apks/release/release/app.aab \
  --output test.apks \
  --connected-device \
  --device-id emulator-5554 \
  --ks AppBundleSample/sign \
  --ks-key-alias key0 \
  --ks-pass kazucocoa

# Generated by the above command
$ java -jar apks/bundletool-all-0.6.0.jar install-apks \
  --apks apks/AppBundleSample.apks \
  --device-id emulator-5554
```
