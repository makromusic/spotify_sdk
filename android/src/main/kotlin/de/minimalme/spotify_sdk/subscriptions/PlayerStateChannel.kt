package de.minimalme.spotify_sdk.subscriptions

import com.google.gson.Gson
import com.spotify.android.appremote.api.PlayerApi
import com.spotify.protocol.client.Subscription
import com.spotify.protocol.types.PlayerState
import io.flutter.plugin.common.EventChannel

/**
 * Streams the player state to Dart.
 *
 * The handler is installed on the event channel once, when the plugin attaches to the engine, and
 * outlives every app remote connection. Re-installing a stream handler resets the channel's active
 * sink to null without telling Dart, which orphans a live Dart subscription: its next cancel then
 * fails with "No active stream to cancel". So on reconnect [playerApi] is re-pointed at the new app
 * remote instead, and an already listening Dart subscription is re-subscribed transparently.
 */
class PlayerStateChannel : EventChannel.StreamHandler {

    private val errorSubscribePlayerState = "subscribePlayerStateError"

    private var events: EventChannel.EventSink? = null
    private var subscription: Subscription<PlayerState>? = null

    /** Player api of the currently connected app remote; null while disconnected. */
    var playerApi: PlayerApi? = null
        set(value) {
            field = value
            subscribeIfListening()
        }

    override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
        this.events = events
        subscribeIfListening()
    }

    override fun onCancel(arguments: Any?) {
        events = null
        cancelSubscription()
    }

    private fun subscribeIfListening() {
        val sink = events ?: return
        val api = playerApi ?: return

        cancelSubscription()
        val playerStateSubscription = api.subscribeToPlayerState()
        playerStateSubscription
                .setEventCallback { playerState -> sink.success(Gson().toJson(playerState)) }
                .setErrorCallback { throwable ->
                    sink.error(errorSubscribePlayerState, "error when subscribing to the player state", throwable.toString())
                }
        subscription = playerStateSubscription
    }

    private fun cancelSubscription() {
        // The subscription may belong to an app remote that is already gone.
        runCatching { subscription?.cancel() }
        subscription = null
    }
}
