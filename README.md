In this repository, you can see how to run test `.aab` file with Appium. The `.aab` file is [app-bundle](https://developer.android.com/guide/app-bundle/) feature.
`bundletool` hasn't matured yet. So, Appium haven't supported it yet. https://github.com/appium/appium-adb/pull/366

So, to run tests with `.aab`, we need to follow _test.rb_ way.

## Hint

- https://codelabs.developers.google.com/codelabs/your-first-dynamic-app/index.html?index=..%2F..%2Fio2018#4

### Note

Below worked with bundletool v 1.4.0 and Appium 1.20.2 as well.
Then, do not forget to set the bundletool in the `PATH` with executable permission as `bundletool.jar`.

#### Run tests with appium
1. Launch an emulator which is 10 and named "emulator-5554"
2. Launch Appium server
3. Run below command

```
$ bundle install
$ ruby test.rb
```

### Run with Appium 1.22.0

#### For UIA2 driver

**renamed the bundletool as `bundletool.jar`**

$ export PATH="/Users/kazuaki/GitHub/AppBundleSample/app/bundletool.jar:$PATH"

This case you can sign with your keys.

```
# Build apks with https://github.com/google/bundletool/releases
$ java -jar apks/bundletool.jar build-apks \
  --bundle apks/release/release/app.aab \
  --output apks/AppBundleSample.apks \
  --connected-device \
  --ks apks/sign \
  --ks-key-alias key0 \
  --ks-pass pass:kazucocoa \
  --overwrite
```

(Note that the '--connected-device' is to optimize the apks to the connected one.)

#### For Espresso driver

This case you must generate the `apks` with appium's keys https://github.com/appium/appium-adb/tree/master/keys to match the signature with Appium's espresso server.
(This repository already has the keystore that is generated by the appium's key)

Or you can sign your own. Then, please do not forget to give keystore etc as appium's capabilities.

```
$ java -jar apks/bundletool.jar build-apks \
  --bundle apks/release/release/app.aab \
  --output apks/AppBundleSample.apks \
  --connected-device \
  --ks appium-ks \
  --ks-key-alias appium \
  --ks-pass pass:appium \
  --overwrite
```

#### Run tests with appium
1. Launch an emulator which is 10 and named "emulator-5554"
2. Launch Appium server
3. Run below command

```
$ bundle install
$ ruby test.rb
```

# Deep dive
## Lesson
Generating `apks` for a specifit device builds `master`, language and resolution apks. When we unzip generated `AppBundleSample.apks`, we can see below apks for example. We can see application `.class` files in `base-master.apk`. English string resporces in `base-en.apk`. XXHDPI resources in `base-xxhdpi.apk`.

```
base-en.apk
base-master.apk
base-xxhdpi.apk
```

When we don't specify `--device-id emulator-5554`, we can see a bunch of apks in the `.apks`. Try to build without `--device-id` and unzip the result. You can see below apks.

```
 extracting: standalones/standalone-ldpi.apk
 extracting: standalones/standalone-tvdpi.apk
 extracting: standalones/standalone-mdpi.apk
 extracting: standalones/standalone-hdpi.apk
 extracting: splits/base-ldpi.apk
 extracting: splits/base-mdpi.apk
 extracting: splits/base-hdpi.apk
 extracting: splits/base-xhdpi.apk
 extracting: splits/base-xxhdpi.apk
 extracting: splits/base-xxxhdpi.apk
 extracting: splits/base-tvdpi.apk
 extracting: standalones/standalone-xhdpi.apk
 extracting: splits/base-ca.apk
 extracting: standalones/standalone-xxxhdpi.apk
 extracting: splits/base-fa.apk
 extracting: splits/base-da.apk
 extracting: splits/base-ka.apk
...
```

We can understand the behaviour, generating apks are for specific language/resolutions. So, if we'd like to run tests for various languages, it's good to change device languages and generate apks for it and install/run tests for it.

## Get device spec
The tool also provides `get-device-spec` command. It create below json file. As you can see, the generate command use the below specs to specify the combination of `apk`s in `apks` file. ah... good one. We can handle/manage apks from such specs.

```
$ java -jar apks/bundletool.jar get-device-spec --output apks/spec.json
$ cat spec.json
{
  "supportedAbis": ["x86"],
  "supportedLocales": ["en-US"],
  "screenDensity": 420,
  "sdkVersion": 27,
}
```

Another spec.

```
{
  "supportedAbis": ["arm64-v8a", "armeabi-v7a", "armeabi"],
  "supportedLocales": ["en-US"],
  "screenDensity": 420,
  "sdkVersion": 27
}
```

## How to install apk
- https://github.com/google/bundletool/blob/f855ea639a02216780b2813ce29bd6e927ad4503/src/main/java/com/android/tools/build/bundletool/device/DdmlibDevice.java

The above calls https://github.com/google/bundletool/blob/f855ea639a02216780b2813ce29bd6e927ad4503/src/main/java/com/android/tools/build/bundletool/device/DdmlibDevice.java#L89

## Get a test apk in `.apks`
- https://github.com/google/bundletool/blob/9a749b7445e8b654cec9dd4fbeb01f71d872c22c/src/main/java/com/android/tools/build/bundletool/commands/ExtractApksCommand.java#L135
    - Probably, we can observe this `extractedApkPath`, we can understand which apk will be installed by `bundletool`

## Multiple languages
- `install-apks` installs `base-master.apk` and only proper language/layout resources to a particular connected devices.
   - Even if the test apk has multiple languages resources, the install command install only one language whcih is curernt device language.
   - If you'd like to test multiple languages, you should follow below:
       - 1. Generate `apks` without `--connected-device --device-id emulator-5554` to build all variation's apks
       - 2. **Change system languages to you'd like to test**
       - 3. Run `install-apks` command to install proper resources from `.apks` file
       - 4. Do test

### not for me
We **must** change system locale before installing test APKs via `bundletool`.
~~If capability has `locale/language` preference, we must re-install apk via `bundletool` if installed app has no the resource.~~

<img src="https://user-images.githubusercontent.com/5511591/47019117-47363c80-d191-11e8-8355-f542ca3c300a.png" width=600>

Can we install **all of resources** using `--modules` flag? We must investigate further.

## Standalone directory
We can see `standalone` directory if we build `.apks` via _bundletool_ without `--connected-device --device-id emulator-5554`. I installed one of them in a device and tried to change device lang. Then, I saw the apk includes all of device languages resources.

```
standalones/standalone-hdpi.apk
standalones/standalone-ldpi.apk
standalones/standalone-mdpi.apk
standalones/standalone-tvdpi.apk
standalones/standalone-xhdpi.apk
standalones/standalone-xxhdpi.apk
standalones/standalone-xxxhdpi.apk
```

=> Larger `apk` include smaler's reources.
<img src="https://user-images.githubusercontent.com/5511591/47019106-3ede0180-d191-11e8-8603-baaf4bd370e6.png" width=600>


But the standalones has below variation. It probably happens when we use NDK or ML related feature to optimise modules for CPU architecture, for example. In the case, we can handle them refeering `supportedAbis` in device spec.

from [link](https://medium.com/mindorks/android-app-bundle-part-2-bundletool-6705b50bea4c)
```
standalone-arm64_v8a_hdpi.apk 6.8M
standalone-arm64_v8a_ldpi.apk 6.8M
standalone-arm64_v8a_mdpi.apk 6.8M
standalone-arm64_v8a_tvdpi.apk 6.9M
standalone-arm64_v8a_xhdpi.apk 6.8M
standalone-arm64_v8a_xxhdpi.apk 6.9M
standalone-arm64_v8a_xxxhdpi.apk 6.9M
standalone-armeabi_v7a_hdpi.apk 6.8M
standalone-armeabi_v7a_ldpi.apk 6.8M
standalone-armeabi_v7a_mdpi.apk 6.8M
standalone-armeabi_v7a_tvdpi.apk 6.9M
standalone-armeabi_v7a_xhdpi.apk 6.8M
standalone-armeabi_v7a_xxhdpi.apk 6.9M
standalone-armeabi_v7a_xxxhdpi.apk 6.9M
standalone-mips_hdpi.apk 6.8M
standalone-mips_ldpi.apk 6.8M
standalone-mips_mdpi.apk 6.8M
standalone-mips_tvdpi.apk 6.9M
standalone-mips_xhdpi.apk 6.8M
standalone-mips_xxhdpi.apk 6.9M
standalone-mips_xxxhdpi.apk 6.9M
standalone-x86_64_hdpi.apk 6.8M
standalone-x86_64_ldpi.apk 6.8M
standalone-x86_64_mdpi.apk 6.8M
standalone-x86_64_tvdpi.apk 6.9M
standalone-x86_64_xhdpi.apk 6.8M
standalone-x86_64_xxhdpi.apk 6.9M
standalone-x86_64_xxxhdpi.apk 6.9M
standalone-x86_hdpi.apk 6.9M
standalone-x86_ldpi.apk 6.8M
standalone-x86_mdpi.apk 6.8M
standalone-x86_tvdpi.apk 7.0M
standalone-x86_xhdpi.apk 6.9M
standalone-x86_xxhdpi.apk 6.9M
standalone-x86_xxxhdpi.apk 6.9M
```

## Install multiple apks

I didn't know, but we could install multiple apks via `install-multiple` command via `adb`.

```
app installation:
 install [-lrtsdg] [--instant] PACKAGE
 install-multiple [-lrtsdpg] [--instant] PACKAGE...
     push package(s) to the device and install them
     -l: forward lock application
     -r: replace existing application
     -t: allow test packages
     -s: install application on sdcard
     -d: allow version code downgrade (debuggable packages only)
     -p: partial application install (install-multiple only)
     -g: grant all runtime permissions
     --instant: cause the app to be installed as an ephemeral install app
 uninstall [-k] PACKAGE
     remove this app package from the device
     '-k': keep the data and cache directories
```
