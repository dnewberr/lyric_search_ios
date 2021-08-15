//
//  SpotifyAuthService.swift
//  SpotifyAuthService
//
//  Created by Deborah Newberry on 8/14/21.
//

final class SpotifyAuthService: NSObject, SPTAppRemoteDelegate, SPTAppRemotePlayerStateDelegate {
    static let main: SpotifyAuthService = SpotifyAuthService()
    private override init() {}
    
    private let spotifyClientID = Bundle.stringValue(forKey: .spotifyClientId)
    private let spotifyRedirectURL = URL(string: "dnewberr-lyric-search://spotify-login-callback")!
    private var accessToken: String?
    private lazy var configuration = SPTConfiguration(clientID: spotifyClientID, redirectURL: spotifyRedirectURL)
    private lazy var appRemote: SPTAppRemote = {
        let appRemote = SPTAppRemote(configuration: self.configuration, logLevel: .debug)
        appRemote.connectionParameters.accessToken = self.accessToken
        appRemote.delegate = self
        return appRemote
    }()
    
    func appRemoteDidEstablishConnection(_ appRemote: SPTAppRemote) {
        appRemote.playerAPI?.delegate = self
        appRemote.playerAPI?.subscribe(toPlayerState: { (result, error) in
            if let error = error {
                debugPrint(error.localizedDescription)
            }
        })
    }
    
    func appRemote(_ appRemote: SPTAppRemote, didDisconnectWithError error: Error?) {
        print("disconnected")
    }
    
    func appRemote(_ appRemote: SPTAppRemote, didFailConnectionAttemptWithError error: Error?) {
        print("failed")
    }
    
    func playerStateDidChange(_ playerState: SPTAppRemotePlayerState) {
        debugPrint("Track name: %@", playerState.track.name)
    }
    
    func authorize() {
        appRemote.authorizeAndPlayURI("")
    }
    
    func attemptToEstablishConnection(fromUrl url: URL) {
        let parameters = appRemote.authorizationParameters(from: url);
        
        if let access_token = parameters?[SPTAppRemoteAccessTokenKey] {
            appRemote.connectionParameters.accessToken = access_token
            accessToken = access_token
        } else if let error_description = parameters?[SPTAppRemoteErrorDescriptionKey] {
            // Show the error
            debugPrint(error_description)
        }
    }
    
    func disconnect() {
        if appRemote.isConnected {
            appRemote.disconnect()
        }
    }
    
    func reconnect() {
        if let _ = appRemote.connectionParameters.accessToken {
            appRemote.connect()
        }
    }
}
