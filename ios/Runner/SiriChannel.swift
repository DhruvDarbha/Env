import Flutter
import UIKit
import AppIntents

@available(iOS 16.0, *)
public class SiriChannel: NSObject, FlutterPlugin {
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "com.env.siri", binaryMessenger: registrar.messenger())
        let instance = SiriChannel()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "registerShortcuts":
            registerSiriShortcuts()
            result(nil)
        case "isSiriAvailable":
            result(true) // Always available on iOS 16+
        default:
            result(FlutterMethodNotImplemented)
        }
    }

    private func registerSiriShortcuts() {
        if #available(iOS 16.0, *) {
            // App shortcuts are automatically registered through EnvAppShortcuts
            // No additional action needed as the shortcuts are defined statically
        }
    }
}