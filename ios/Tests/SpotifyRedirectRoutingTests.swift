import XCTest

@testable import SpotifyRedirectRouting

/// Redirects arrive from another app, so the plugin cannot ask who sent one -- it can only read the
/// URL and what it is still waiting for. These cover every combination of those two inputs.
final class SpotifyRedirectRoutingTests: XCTestCase {
    private let redirect = "makromusic://spotify-login-callback"

    private func route(
        _ url: String,
        hasAccessToken: Bool = false,
        isAwaitingAuthCode: Bool = false
    ) -> SpotifyRedirectRoute {
        spotifyRedirectRoute(
            url: URL(string: url)!,
            hasAccessToken: hasAccessToken,
            isAwaitingAuthCode: isAwaitingAuthCode
        )
    }

    // MARK: - A code in the URL settles it

    func testCodeGoesToTheAuthorizationCodeFlow() {
        XCTAssertEqual(route("\(redirect)?code=AQD123", isAwaitingAuthCode: true), .authorizationCode)
    }

    func testCodeGoesToTheAuthorizationCodeFlowEvenWhenNothingIsAwaitingIt() {
        XCTAssertEqual(route("\(redirect)?code=AQD123"), .authorizationCode)
    }

    func testCodeAlongsideOtherParametersIsStillRecognised() {
        XCTAssertEqual(route("\(redirect)?state=xyz&code=AQD123"), .authorizationCode)
    }

    /// `code` has to be a parameter of its own. Matching on substrings would send an app remote
    /// redirect down the authorization code path -- the misroute this routing exists to prevent.
    func testAParameterMerelyContainingCodeIsNotACode() {
        XCTAssertEqual(route("\(redirect)?error_code=42", hasAccessToken: true), .appRemote)
    }

    // MARK: - An access token means the app remote

    func testAccessTokenGoesToTheAppRemote() {
        XCTAssertEqual(route("\(redirect)#access_token=BQD456", hasAccessToken: true), .appRemote)
    }

    /// The regression this routing was written for. A finished authorization used to leave a flag
    /// standing, which sent the next app remote redirect to the session manager; the connect
    /// callback was never invoked and every connect timed out until the app was relaunched. Even
    /// with the stale signal asserted, an access token must still reach the app remote.
    func testAccessTokenGoesToTheAppRemoteEvenWhileAnAuthCodeRequestIsPending() {
        XCTAssertEqual(
            route("\(redirect)#access_token=BQD456", hasAccessToken: true, isAwaitingAuthCode: true),
            .appRemote
        )
    }

    // MARK: - Neither: whoever is waiting

    func testErrorGoesToTheAuthorizationCodeFlowWhileOneIsPending() {
        XCTAssertEqual(
            route("\(redirect)?error=access_denied", isAwaitingAuthCode: true),
            .authorizationCode
        )
    }

    func testErrorGoesToTheAppRemoteWhenNoAuthCodeRequestIsPending() {
        XCTAssertEqual(route("\(redirect)?error=access_denied"), .appRemote)
    }

    func testBareRedirectFollowsWhateverIsPending() {
        XCTAssertEqual(route(redirect, isAwaitingAuthCode: true), .authorizationCode)
        XCTAssertEqual(route(redirect), .appRemote)
    }

    func testUrlWithNoQueryAtAllDoesNotCrash() {
        XCTAssertEqual(route("makromusic://", isAwaitingAuthCode: true), .authorizationCode)
    }
}
