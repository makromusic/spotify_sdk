package de.minimalme.spotify_sdk.subscriptions

import com.google.gson.Gson
import com.spotify.android.appremote.api.UserApi
import com.spotify.protocol.client.Subscription
import com.spotify.protocol.types.UserStatus
import io.flutter.plugin.common.EventChannel

/** Streams the user status to Dart. See [PlayerStateChannel] for why the handler is long lived. */
class UserStatusChannel : EventChannel.StreamHandler {

    private val errorSubscribeUserStatus = "subscribeUserStatusError"

    private var events: EventChannel.EventSink? = null
    private var subscription: Subscription<UserStatus>? = null

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
        val userStatusSubscription = api.subscribeToUserStatus()
        userStatusSubscription
                .setEventCallback { userStatus -> sink.success(Gson().toJson(userStatus)) }
                .setErrorCallback { throwable ->
                    sink.error(errorSubscribeUserStatus, "error when subscribing to the users status", throwable.toString())
                }
        subscription = userStatusSubscription
    }

    private fun cancelSubscription() {
        // The subscription may belong to an app remote that is already gone.
        runCatching { subscription?.cancel() }
        subscription = null
    }
}
