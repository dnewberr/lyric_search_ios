//
//  LyricLyricSearchResultView.swift
//  LyricLyricSearchResultView
//
//  Created by Deborah Newberry on 8/15/21.
//

import Combine
import SwiftUI

struct LyricSearchResultView: View {
    private var cancellableBag = Set<AnyCancellable>()
    private let viewModel: LyricSearchResultViewModel
    private let output: LyricSearchResultViewModel.Output
    
    @State private var songTitle: String = ""
    @State private var url: String = ""
    @State private var currentError: Error? = nil
    @State private var presentError: Bool = false

    init(viewModel: LyricSearchResultViewModel) {
        self.viewModel = viewModel
        self.output = viewModel.bind()
    }
    
    var body: some View {
        ZStack {
            Color.gray.opacity(0.1).ignoresSafeArea()
            VStack {
                Text(songTitle)
                    .font(.headline)
                    .padding([.bottom], 8)
                Text(url)
                    .font(.subheadline)
                    .padding([.bottom], 8)
            }
            .padding(16)
        }
        .cornerRadius(8)
        .alert(isPresented: $presentError) {
            Alert(title: Text("Error"), message: Text(currentError?.localizedDescription ?? ""))
        }
        .onReceive(output.geniusSongTitlePublisher) { songTitle in
            self.songTitle = songTitle ?? "N/A"
        }
        .onReceive(output.geniusSongURLPublisher) { url in
            self.url = url ?? "N/A"
        }
        .onReceive(output.errorPublisher) { error in
            self.currentError = error
            self.presentError = error != nil
        }
    }
}

final class LyricSearchResultViewModel: ObservableObject {
    private let service: GeniusAPIService
    
    struct Output {
        var geniusSongTitlePublisher: AnyPublisher<String?, Never>
        var geniusSongURLPublisher: AnyPublisher<String?, Never>
        var errorPublisher: AnyPublisher<GeniusAPIError?, Never>
    }

    init(service: GeniusAPIService = GeniusAPIService()) {
        self.service = service
    }

    func search(query: String) {
        service.search(query: query)
    }
    
    func bind() -> Output {
        let responsePublisher = service.responsePublisher
        let geniusSongTitle = responsePublisher
            .map { $0.fullTitle }
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
        let geniusSongURL = responsePublisher
            .map { $0.url }
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
        let errorPublisher = service.errorPublisher
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()

        return Output(geniusSongTitlePublisher: geniusSongTitle,
                      geniusSongURLPublisher: geniusSongURL,
                      errorPublisher: errorPublisher)
    }
}
