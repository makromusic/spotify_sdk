import SpotifyiOS

/// Streams the player context to Dart. See `PlayerStreamHandler` for why the handler is long lived.
class PlayerContextHandler: PlayerStreamHandler {
    override func bindSink(_ sink: FlutterEventSink?) {
        playerDelegate.playerContextSink = sink
    }
}
