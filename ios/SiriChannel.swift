import Foundation
import Flutter

@available(iOS 16.0, *)
class SiriChannel {
    static let channelName = "com.freshtrack.siri"
    
    static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: channelName, binaryMessenger: registrar.messenger())
        let instance = SiriChannel()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }
    
    func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "getSiriIntent":
            result("FruitAnalysisIntent")
        default:
            result(FlutterMethodNotImplemented)
        }
    }
}