package de.minimalme.spotify_sdk.subscriptions

import com.google.gson.Gson
import com.spotify.android.appremote.api.UserApi
import com.spotify.protocol.client.Subscription
import com.spotify.protocol.types.Capabilities
import io.flutter.plugin.common.EventChannel

/** Streams the user capabilities to Dart. See [PlayerStateChannel] for why the handler is long lived. */
class CapabilitiesChannel : EventChannel.StreamHandler {

    private val errorSubscribeCapabilities = "subscribeCapabilitiesError"

    private var events: EventChannel.EventSink? = null
    private var subscription: Subscription<Capabilities>? = null

    /** User api of the currently connected app remote; null while disconnected. */
    var userApi: UserApi? = null
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
        val api = userApi ?: return

        cancelSubscription()
        val capabilitiesSubscription = api.subscribeToCapabilities()
        capabilitiesSubscription
                .setEventCallback { capabilities -> sink.success(Gson().toJson(capabilities)) }
                .setErrorCallback { throwable ->
                    sink.error(errorSubscribeCapabilities, "error when subscribing to the users capabilities", throwable.toString())
                }
        subscription = capabilitiesSubscription
    }

    private fun cancelSubscription() {
        // The subscription may belong to an app remote that is already gone.
        runCatching { subscription?.cancel() }
        subscription = null
    }
}
