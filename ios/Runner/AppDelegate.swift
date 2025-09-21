import UIKit
import Flutter
import GoogleMaps
import AppIntents

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    // Configure Google Maps with API key
    GMSServices.provideAPIKey("AIzaSyBvliiQSooQGNzWZaFjl87lsk9J-X5kPdw")

    GeneratedPluginRegistrant.register(with: self)

    // Register Siri channel
    if #available(iOS 16.0, *) {
        SiriChannel.register(with: self.registrar(forPlugin: "SiriChannel")!)
        // EnvAppShortcuts will be updated automatically when shortcuts are registered
    }

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  // Handle URL schemes for deep linking
  override func application(_ application: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
    if url.scheme == "env" {
      // Handle the deep link in Flutter
      let methodChannel = FlutterMethodChannel(name: "com.env.siri", binaryMessenger: (window?.rootViewController as! FlutterViewController).binaryMessenger)
      methodChannel.invokeMethod("handleDeepLink", arguments: url.absoluteString)
      return true
    }

    return super.application(application, open: url, options: options)
  }
}