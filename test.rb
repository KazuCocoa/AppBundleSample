require 'appium_lib_core'

ANDROID_OPS_EN = {
    caps: {
        platformName: :android,
        # automationName: :uiautomator2,
        automationName: :espresso,
        platformVersion: '10',
        deviceName: 'Android Emulator',
        # app: "#{Dir.pwd}/apks/AppBundleSample.apks",
        app: "#{Dir.pwd}/apks/appium-ks-signed-AppBundleSample.apks",
        appPackage: 'com.kazu_cocoa.appbundlesample',
        appActivity: 'com.kazu_cocoa.appbundlesample.MainActivity',
        unicodeKeyboard: true,
        resetKeyboard: true,
        language: "en",
        locale: "US",
        fullReset: true
    },
    appium_lib: {
        export_session: true,
        wait: 30,
        wait_timeout: 20,
        wait_interval: 1
    }
}.freeze

ANDROID_OPS_JP = {
    caps: {
        platformName: :android,
        # automationName: 'uiautomator2',
        automationName: :espresso,
        platformVersion: '10',
        deviceName: 'Android Emulator',
        # app: "#{Dir.pwd}/apks/AppBundleSample.apks",
        app: "#{Dir.pwd}/apks/appium-ks-signed-AppBundleSample.apks",
        appPackage: 'com.kazu_cocoa.appbundlesample',
        appActivity: 'com.kazu_cocoa.appbundlesample.MainActivity',
        unicodeKeyboard: true,
        resetKeyboard: true,
        language: "ja",
        locale: "JP",
        fullReset: true
    },
    appium_lib: {
        export_session: true,
        wait: 30,
        wait_timeout: 20,
        wait_interval: 1
    }
}.freeze

# You can generate a proper apks for particular devices with below flags
# --connected-device \
# --device-id emulator-5554 \
# system <<-CMD
# java -jar apks/bundletool-all-1.4.0.jar build-apks \
#   --bundle apks/release/release/app.aab \
#   --output apks/AppBundleSample.apks \
#   --ks apks/sign \
#   --ks-key-alias key0 \
#   --ks-pass pass:kazucocoa \
#   --overwrite
# CMD

core = ::Appium::Core.for(ANDROID_OPS_EN)
driver = core.start_driver

home_text = driver.find_element :id, "com.kazu_cocoa.appbundlesample:id/message"
unless home_text.text == "Home"
  puts "test failed since dashboard_text.text isn't Home"
  exit
end

dashboard = driver.find_element :id, "com.kazu_cocoa.appbundlesample:id/navigation_dashboard"
dashboard.click

dashboard_text = driver.find_element :id, "com.kazu_cocoa.appbundlesample:id/message"
unless dashboard_text.text == "Dashboard"
  puts "test failed since dashboard_text.text isn't Home"
  exit
end

puts "finished EN"

core = ::Appium::Core.for(ANDROID_OPS_JP)
driver = core.start_driver

home_text = driver.find_element :id, "com.kazu_cocoa.appbundlesample:id/message"
unless home_text.text == "ホーム"
  puts "test failed since dashboard_text.text isn't Home"
  exit
end

dashboard = driver.find_element :id, "com.kazu_cocoa.appbundlesample:id/navigation_dashboard"
dashboard.click

dashboard_text = driver.find_element :id, "com.kazu_cocoa.appbundlesample:id/message"
unless dashboard_text.text == "ダッシュボード"
  puts "test failed since dashboard_text.text isn't Home"
  exit
end

puts "finished JP"
