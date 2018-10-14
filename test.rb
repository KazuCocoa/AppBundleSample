require 'appium_lib_core'

ANDROID_OPS = {
    caps: {
        platformName: :android,
        automationName: 'uiautomator2',
        platformVersion: '8.1',
        deviceName: 'Android Emulator',
        appPackage: 'com.kazu_cocoa.appbundlesample',
        appActivity: 'com.kazu_cocoa.appbundlesample.MainActivity',
        unicodeKeyboard: true,
        resetKeyboard: true
    },
    appium_lib: {
        export_session: true,
        wait: 30,
        wait_timeout: 20,
        wait_interval: 1
    }
}.freeze

system <<-CMD
java -jar apks/bundletool-all-0.6.0.jar build-apks \
  --bundle apks/release/release/app.aab \
  --output apks/AppBundleSample.apks \
  --connected-device \
  --device-id emulator-5554 \
  --ks apks/sign \
  --ks-key-alias key0 \
  --ks-pass pass:kazucocoa \
  --overwrite
CMD

system <<-CMD
java -jar apks/bundletool-all-0.6.0.jar install-apks \
  --apks apks/AppBundleSample.apks \
  --device-id emulator-5554
CMD

core ||= ::Appium::Core.for(ANDROID_OPS)
driver ||= core.start_driver

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

puts "finished"