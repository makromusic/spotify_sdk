import SpotifyiOS

/// Streams the player state to Dart. See `PlayerStreamHandler` for why the handler is long lived.
class PlayerStateHandler: PlayerStreamHandler {
    override func bindSink(_ sink: FlutterEventSink?) {
        playerDelegate.playerStateSink = sink
    }
}
