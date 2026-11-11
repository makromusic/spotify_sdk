import Foundation
import SpotifyiOS

extension SwiftSpotifySdkPlugin {
    public func scopeStringsToEnums(scopes: [String]?) -> SPTScope {
        var sptScope = SPTScope()
        
        if(scopes?.contains("user-top-read") == true) {
            sptScope.insert(.userTopRead)
        }
        if(scopes?.contains("user-read-recently-played") == true) {
            sptScope.insert(.userReadRecentlyPlayed)
        }
        if(scopes?.contains("user-read-playback-state") == true) {
            sptScope.insert(.userReadPlaybackState)
        }
        if(scopes?.contains("user-modify-playback-state") == true) {
            sptScope.insert(.userModifyPlaybackState)
        }
        if(scopes?.contains("user-read-currently-playing") == true) {
            sptScope.insert(.userReadCurrentlyPlaying)
        }
        if(scopes?.contains("app-remote-control") == true) {
            sptScope.insert(.appRemoteControl)
        }
        if(scopes?.contains("streaming") == true) {
            sptScope.insert(.streaming)
        }
        if(scopes?.contains("playlist-read-private") == true) {
            sptScope.insert(.playlistReadPrivate)
        }
        if(scopes?.contains("playlist-read-collaborative") == true) {
            sptScope.insert(.playlistReadCollaborative)
        }
        if(scopes?.contains("playlist-modify-public") == true) {
            sptScope.insert(.playlistModifyPublic)
        }
        if(scopes?.contains("playlist-modify-private") == true) {
            sptScope.insert(.playlistModifyPrivate)
        }
        if(scopes?.contains("user-follow-modify") == true) {
            sptScope.insert(.userFollowModify)
        }
        if(scopes?.contains("user-follow-read") == true) {
            sptScope.insert(.userFollowRead)
        }
        if(scopes?.contains("user-library-read") == true) {
            sptScope.insert(.userLibraryRead)
        }
        if(scopes?.contains("user-library-modify") == true) {
            sptScope.insert(.userLibraryModify)
        }
        if(scopes?.contains("user-read-email") == true) {
            sptScope.insert(.userReadEmail)
        }
        if(scopes?.contains("user-read-private") == true) {
            sptScope.insert(.userReadPrivate)
        }
        if(scopes?.contains("ugc-image-upload") == true) {
            sptScope.insert(.ugcImageUpload)
        }
        return sptScope
    }
}

