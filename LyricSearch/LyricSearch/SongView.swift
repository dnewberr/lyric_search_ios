//
//  SongView.swift
//  SongView
//
//  Created by Deborah Newberry on 8/15/21.
//

import SwiftUI
import Combine

//struct SongView: View {
//    @State var songViewModel: SongViewModel?
//
//    var body: some View {
//        VStack {
//            if let viewModel = songViewModel {
//                Text(viewModel.songName)
//                Text(viewModel.songArtistName)
//                if let image = viewModel.image {
//                    Image(uiImage: image)
//                }
//            } else {
//                Text("No song to display")
//            }
//        }
//        .onAppear {
//            updateViewModel()
//        }
//    }
//
//    private func updateViewModel() {
//        guard let currentTrack = SpotifyAuthService.main.currentPlayerState?.track else { return }
//        SpotifyAuthService.main.currentPlayerState.
//        songViewModel = SongViewModel(track: currentTrack, image: nil)
//
//        SpotifyAuthService.main.fetchImage(for: currentTrack) { image, error in
//            guard error == nil else {
//                print(error!)
//                return
//            }
//
//            self.songViewModel = SongViewModel(track: currentTrack, image: image)
//        }
//    }
//
//}


//class SongViewModel: ObservableObject {
//    private let track: SPTAppRemoteTrack
//    let image: UIImage?
//
//    lazy var songName: String = {
//        return track.name
//    }()
//    lazy var songArtistName: String = {
//        return track.artist.name
//    }()
//
//    init(track: SPTAppRemoteTrack, image: UIImage?) {
//        self.track = track
//        self.image = image
//    }
//}
final class SongViewModel: ObservableObject {
    struct Output {
        var trackTitleName: AnyPublisher<String, Never>
        var trackArtistName: AnyPublisher<String, Never>
        var trackImage: AnyPublisher<UIImage, Never>
    }

    @Published var trackTitleName: String = ""
    @Published var trackArtistName: String = ""
    @Published var trackImage: UIImage = UIImage()

    func bind() -> Output {
        let trackPublisher = SpotifyAuthService.main.currentPlayerStatePublisher
            .map { $0.track }
        let trackTitleName = trackPublisher
            .map { $0.name }
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
        let trackArtistName = trackPublisher
            .map { $0.artist.name }
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
        let trackImage = SpotifyAuthService.main.currentImagePublisher
            .replaceNil(with: UIImage(systemName: "nosign")!)
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()

        return Output(trackTitleName: trackTitleName,
                      trackArtistName: trackArtistName,
                      trackImage: trackImage)
    }
}
struct SongView: View {
    private var cancellableBag = Set<AnyCancellable>()

    @ObservedObject var viewModel: SongViewModel

    init(viewModel: SongViewModel) {
        self.viewModel = viewModel

        let bindStruct = viewModel.bind()
        bindStruct.trackTitleName
            .assign(to: \.trackTitleName, on: viewModel)
            .store(in: &cancellableBag)
        bindStruct.trackArtistName
            .assign(to: \.trackArtistName, on: viewModel)
            .store(in: &cancellableBag)
        bindStruct.trackImage
            .assign(to: \.trackImage, on: viewModel)
            .store(in: &cancellableBag)
    }

    var body: some View {
        VStack {
            Text(viewModel.trackTitleName)
            Text(viewModel.trackArtistName)
            Image(uiImage: viewModel.trackImage)
        }
    }
}
