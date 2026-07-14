package de.minimalme.spotify_sdk.subscriptions

import com.google.gson.Gson
import com.spotify.android.appremote.api.PlayerApi
import com.spotify.protocol.client.Subscription
import com.spotify.protocol.types.PlayerContext
import io.flutter.plugin.common.EventChannel

/** Streams the player context to Dart. See [PlayerStateChannel] for why the handler is long lived. */
class PlayerContextChannel : EventChannel.StreamHandler {

    private val errorSubscribePlayerContext = "subscribePlayerContextError"

    private var events: EventChannel.EventSink? = null
    private var subscription: Subscription<PlayerContext>? = null

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
        val playerContextSubscription = api.subscribeToPlayerContext()
        playerContextSubscription
                .setEventCallback { playerContext -> sink.success(Gson().toJson(playerContext)) }
                .setErrorCallback { throwable ->
                    sink.error(errorSubscribePlayerContext, "error when subscribing to the player context", throwable.toString())
                }
        subscription = playerContextSubscription
    }

    private fun cancelSubscription() {
        // The subscription may belong to an app remote that is already gone.
        runCatching { subscription?.cancel() }
        subscription = null
    }
}
