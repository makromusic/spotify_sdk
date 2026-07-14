import SpotifyiOS

/// Base for the player state / player context stream handlers.
///
/// The handler is installed on its event channel once, at plugin registration, and outlives every
/// app remote connection. `FlutterEventChannel.setStreamHandler` installs a fresh message handler
/// whose `currentSink` starts out nil, so re-installing a handler on every connect silently forgets
/// the sink a live Dart subscription is still holding; that subscription's next cancel then fails
/// with "No active stream to cancel". Instead, [appRemote] is re-pointed on every connect and
/// [subscribeToPlayerAPI] re-arms an already listening Dart subscription against the new remote.
class PlayerStreamHandler: StatusHandler {
    let playerDelegate: PlayerDelegate

    /// The currently connected app remote; nil until the first connection is established.
    var appRemote: SPTAppRemote?

    init(playerDelegate: PlayerDelegate) {
        self.playerDelegate = playerDelegate
        super.init()
    }

    /// Routes this stream's events to `sink`, or detaches them when nil. Overridden by subclasses.
    func bindSink(_ sink: FlutterEventSink?) {}

    override func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        _ = super.onListen(withArguments: arguments, eventSink: events)
        bindSink(events)
        subscribeToPlayerAPI()
        return nil
    }

    override func onCancel(withArguments arguments: Any?) -> FlutterError? {
        bindSink(nil)
        return super.onCancel(withArguments: arguments)
    }

    /// (Re-)arms the player API subscription against the current app remote. Called when Dart starts
    /// listening and again on every newly established connection, so a live Dart subscription keeps
    /// receiving events across reconnects. The player API is only available while connected, so this
    /// is a no-op otherwise.
    func subscribeToPlayerAPI() {
        guard eventSink != nil, let playerAPI = appRemote?.playerAPI else { return }
        playerAPI.delegate = playerDelegate
        playerAPI.subscribe { (_, _) -> Void in }
    }
}
