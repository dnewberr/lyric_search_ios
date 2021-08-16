//
//  SongView.swift
//  SongView
//
//  Created by Deborah Newberry on 8/15/21.
//

import Combine
import SwiftUI

struct SongView: View {
    private var cancellableBag = Set<AnyCancellable>()
    let viewModel: SongViewModel
    let output: SongViewModel.Output
    
    @State var songImage = UIImage(systemName: "nosign")!
    @State var songTitle = "No title"
    @State var songArtist = "No artist"

    init(viewModel: SongViewModel) {
        self.viewModel = viewModel
        self.output = viewModel.bind()
    }
    
    var body: some View {
        ZStack {
            Color.gray.opacity(0.1).ignoresSafeArea()
            VStack {
                Image(uiImage: songImage)
                    .cornerRadius(8)
                    .padding([.top, .bottom], 8)
                    .shadow(radius: 4)
                Text(songArtist)
                    .font(.headline)
                    .padding([.top], 8)
                Text(songTitle)
                    .font(.subheadline)
                    .padding([.bottom], 8)
            }
            .padding(16)
        }
        .cornerRadius(8)
        .onReceive(output.trackImagePublisher) { image in
            self.songImage = image
        }
        .onReceive(output.trackTitleNamePublisher) { title in
            self.songTitle = title
        }
        .onReceive(output.trackArtistNamePublisher) { artist in
            self.songArtist = artist
        }
        .frame(height: 300)
    }
}

final class SongViewModel: ObservableObject {
    struct Output {
        var trackTitleNamePublisher: AnyPublisher<String, Never>
        var trackArtistNamePublisher: AnyPublisher<String, Never>
        var trackImagePublisher: AnyPublisher<UIImage, Never>
    }

    func bind() -> Output {
        let trackPublisher = SpotifyAuthService.main.currentPlayerStatePublisher
            .map { $0.track }
        let trackTitleNamePublisher = trackPublisher
            .map { $0.name }
            .replaceNil(with: "N/A")
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
        let trackArtistNamePublisher = trackPublisher
            .map { $0.artist.name }
            .replaceNil(with: "N/A")
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
        let trackImagePublisher = SpotifyAuthService.main.currentImagePublisher
            .replaceNil(with: UIImage(systemName: "nosign")!)
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()

        return Output(trackTitleNamePublisher: trackTitleNamePublisher,
                      trackArtistNamePublisher: trackArtistNamePublisher,
                      trackImagePublisher: trackImagePublisher)
    }
}
