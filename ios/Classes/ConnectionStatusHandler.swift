import SpotifyiOS

class ConnectionStatusHandler: StatusHandler, SPTAppRemoteDelegate {

    var tokenResult: FlutterResult?
    var codeResult: FlutterResult?
    var connectionResult: FlutterResult?

    /// Called once a connection is established, so the player stream handlers can re-arm a Dart
    /// subscription that is already listening against the newly available player API.
    var onConnectionEstablished: (() -> Void)?

    func appRemoteDidEstablishConnection(_ appRemote: SPTAppRemote) {
        onConnectionEstablished?()
        connectionResult?(true)
        tokenResult?(appRemote.connectionParameters.accessToken)
        eventSink?("{\"connected\": true}")

        connectionResult = nil
        tokenResult = nil
        codeResult = nil
    }

    func appRemote(_ appRemote: SPTAppRemote, didFailConnectionAttemptWithError error: Error?) {
        defer {
            connectionResult = nil
            tokenResult = nil
            codeResult = nil
        }

        if error != nil {
            // report spotify remote error to plugin
            eventSink?("{\"connected\": false, \"errorCode\": \"\(error!._code)\", \"errorDetails\": \"\(error!.localizedDescription)\"}")
            connectionResult?(FlutterError(code: String(error!._code), message: error!.localizedDescription, details: nil))
            tokenResult?(FlutterError(code: String(error!._code), message: error!.localizedDescription, details: nil))
            codeResult?(FlutterError(code: String(error!._code), message: error!.localizedDescription, details: nil))
        } else {
            // report disconnection to plugin
            eventSink?("{\"connected\": false}")
            connectionResult?(FlutterError(code: "errorConnection", message: "Failed Connection Attempt", details: nil))
            tokenResult?(FlutterError(code: "errorConnection", message: "Failed Connection Attempt", details: nil))
            codeResult?(FlutterError(code: "errorConnection", message: "Failed Connection Attempt", details: nil))
        }
    }

    func appRemote(_ appRemote: SPTAppRemote, didDisconnectWithError error: Error?) {
        if error != nil {
            // report spotify remote error to plugin
            eventSink?("{\"connected\": false, \"errorCode\": \"\(error!._code)\", \"errorDetails\": \"\(error!.localizedDescription)\"}")
        } else {
            // report disconnection to plugin
            eventSink?("{\"connected\": false}")
        }
    }
}
