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
    
    @State private var url: URL?
    @State private var currentError: Error? = nil
    @State private var presentError: Bool = false

    init(viewModel: LyricSearchResultViewModel) {
        self.viewModel = viewModel
        self.output = viewModel.bind()
    }
    
    var body: some View {
        VStack {
            WebView(url: url)
        }
        .cornerRadius(8)
        .alert(isPresented: $presentError) {
            Alert(title: Text("Error"), message: Text(currentError?.localizedDescription ?? ""))
        }
        .onReceive(output.geniusSongURLPublisher) { url in
            self.url = url
        }
        .onReceive(output.errorPublisher) { error in
            self.currentError = error
            self.presentError = error != nil
        }
    }
}

final class LyricSearchResultViewModel: ObservableObject {
    private let service: GeniusAPIService
    private var lastQuery: String?
    
    struct Output {
        var geniusSongURLPublisher: AnyPublisher<URL?, Never>
        var errorPublisher: AnyPublisher<GeniusAPIError?, Never>
    }

    init(service: GeniusAPIService = GeniusAPIService()) {
        self.service = service
    }

    func search(query: String, lyricType: LyricType) {
        lastQuery = query
        service.search(query: query, lyricType: lyricType)
    }
    
    func updateCurrentSearch(for lyricType: LyricType) {
        guard let lastQuery = self.lastQuery else { return }
        search(query: lastQuery, lyricType: lyricType)
    }
    
    func bind() -> Output {
        let geniusSongURL = service.responsePublisher
            .map { song -> URL? in
                guard let urlString = song.url else {
                    return nil
                }
                return URL(string: urlString)
            }
            .removeDuplicates()
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
        let errorPublisher = service.errorPublisher
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()

        return Output(geniusSongURLPublisher: geniusSongURL,
                      errorPublisher: errorPublisher)
    }
}
