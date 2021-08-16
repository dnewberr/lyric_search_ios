//
//  SpotifyAuthService.swift
//  SpotifyAuthService
//
//  Created by Deborah Newberry on 8/14/21.
//

import Combine

final class SpotifyAuthService: NSObject, SPTAppRemoteDelegate, SPTAppRemotePlayerStateDelegate {
    private var cancellableBag = Set<AnyCancellable>()
    
    static let main: SpotifyAuthService = SpotifyAuthService()
    private override init() {
        super.init()
        currentPlayerStatePublisher
            .removeDuplicates(by: { firstState, secondState in
                return firstState.hash == secondState.hash
            })
            .map { $0.track }
            .sink { [weak self] track in
                self?.appRemote.imageAPI?.fetchImage(forItem: track, with: .init(width: 200, height: 200), callback: { (response, error) in
                    if let error = error {
                        print(error)
                    }
                    self?.currentImagePublisher.send(response as? UIImage)
                })
            }
            .store(in: &cancellableBag)
        
        isConnectedPublisher.send(false)
    }
    
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
    
    let currentPlayerStatePublisher = PassthroughSubject<SPTAppRemotePlayerState, Never>()
    let currentImagePublisher = PassthroughSubject<UIImage?, Never>()
    let isConnectedPublisher = PassthroughSubject<Bool, Never>()
    
    func appRemoteDidEstablishConnection(_ appRemote: SPTAppRemote) {
        isConnectedPublisher.send(true)
        appRemote.playerAPI?.delegate = self
        appRemote.playerAPI?.subscribe(toPlayerState: { (result, error) in
            if let error = error {
                debugPrint(error.localizedDescription)
            }
        })
    }
    
    func appRemote(_ appRemote: SPTAppRemote, didDisconnectWithError error: Error?) {
        isConnectedPublisher.send(false)
        print("disconnected")
    }
    
    func appRemote(_ appRemote: SPTAppRemote, didFailConnectionAttemptWithError error: Error?) {
        isConnectedPublisher.send(false)
        print("failed")
    }
    
    func playerStateDidChange(_ playerState: SPTAppRemotePlayerState) {
        currentPlayerStatePublisher.send(playerState)
    }
    
    func authorize() {
        appRemote.authorizeAndPlayURI("")
    }
    
    func attemptToEstablishConnection(fromUrl url: URL) {
        let parameters = appRemote.authorizationParameters(from: url);
        
        if let accessToken = parameters?[SPTAppRemoteAccessTokenKey] {
            appRemote.connectionParameters.accessToken = accessToken
            self.accessToken = accessToken
        } else if let errorDescription = parameters?[SPTAppRemoteErrorDescriptionKey] {
            // Show the error
            debugPrint(errorDescription)
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
