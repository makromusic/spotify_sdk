import Foundation

/// Which of the two authorization flows an incoming redirect URL belongs to.
enum SpotifyRedirectRoute: Equatable {
    /// getAuthorizationCode: the URL goes to the SPTSessionManager, which reads the `code`.
    case authorizationCode
    /// connectToSpotifyRemote: the URL goes to the SPTAppRemote, which reads the access token.
    case appRemote
}

/// Decides where a redirect belongs from the URL itself, so a request that has already been
/// answered can never capture the redirect of the next one.
///
/// The authorization code flow comes back carrying a `code`; an app remote authorize comes back
/// carrying an access token. Only the Spotify SDK can parse the latter, so the caller does that and
/// passes the answer in as [hasAccessToken].
///
/// A redirect carrying neither is an error or a cancellation. Nothing in that URL says which flow
/// it belongs to, so it goes to whichever request is still waiting -- and it has to go to the right
/// one, because each flow completes a different callback. Sending an authorization cancellation to
/// the app remote would leave `codeResult` unanswered and the Dart future hanging forever.
///
/// This lives apart from the plugin, free of Flutter and SpotifyiOS, so it can be tested directly.
func spotifyRedirectRoute(
    url: URL,
    hasAccessToken: Bool,
    isAwaitingAuthCode: Bool
) -> SpotifyRedirectRoute {
    let queryItems = URLComponents(url: url, resolvingAgainstBaseURL: false)?.queryItems ?? []
    if queryItems.contains(where: { $0.name == "code" }) {
        return .authorizationCode
    }
    if hasAccessToken {
        return .appRemote
    }
    return isAwaitingAuthCode ? .authorizationCode : .appRemote
}
