import Flutter

// Entry point named in pubspec.yaml (pluginClass). Replaces the former Objective-C
// SpotifySdkPlugin.h/.m shim: Swift Package Manager cannot mix Swift and Objective-C in one target.
public class SpotifySdkPlugin: NSObject, FlutterPlugin {
    public static func register(with registrar: FlutterPluginRegistrar) {
        SwiftSpotifySdkPlugin.register(with: registrar)
    }
}
