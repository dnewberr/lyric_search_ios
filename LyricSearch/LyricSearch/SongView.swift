//
//  SongView.swift
//  SongView
//
//  Created by Deborah Newberry on 8/15/21.
//

import SwiftUI
import Combine

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
        ZStack {
            Color.gray.opacity(0.1).ignoresSafeArea()
            VStack {
                Text("Now Playing")
                    .font(.title)
                Image(uiImage: viewModel.trackImage)
                    .cornerRadius(8)
                    .padding([.top, .bottom], 8)
                    .shadow(radius: 4)
                Text(viewModel.trackTitleName)
                    .font(.headline)
                    .padding([.top], 8)
                Text(viewModel.trackArtistName)
                    .font(.subheadline)
                    .padding([.bottom], 8)
            }
            .padding(16)
        }
        .cornerRadius(8)
        .padding(16)
    }
}

final class SongViewModel: ObservableObject {
    struct Output {
        var trackTitleName: AnyPublisher<String, Never>
        var trackArtistName: AnyPublisher<String, Never>
        var trackImage: AnyPublisher<UIImage, Never>
    }

    @Published var trackTitleName: String = "No title"
    @Published var trackArtistName: String = "No artist"
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
