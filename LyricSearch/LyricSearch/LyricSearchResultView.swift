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
    @ObservedObject var viewModel: LyricSearchResultViewModel

    init(viewModel: LyricSearchResultViewModel) {
        self.viewModel = viewModel

        let bindStruct = viewModel.bind()
        bindStruct.geniusSongTitlePublisher
            .assign(to: \.geniusSongTitle, on: viewModel)
            .store(in: &cancellableBag)
        bindStruct.geniusSongURLPublisher
            .assign(to: \.geniusSongURL, on: viewModel)
            .store(in: &cancellableBag)
        bindStruct.errorPublisher
            .assign(to: \.requestError, on: viewModel)
            .store(in: &cancellableBag)
    }

    var body: some View {
        ZStack {
            Color.gray.opacity(0.1).ignoresSafeArea()
            VStack {
                Text("Result")
                    .font(.largeTitle)
                    .padding([.bottom], 8)
                Text(viewModel.geniusSongTitle ?? "N/A")
                    .font(.headline)
                    .padding([.bottom], 8)
                Text(viewModel.geniusSongURL ?? "N/A")
                    .font(.subheadline)
                    .padding([.bottom], 8)
                Text(viewModel.requestError?.localizedDescription ?? "No error")
                    .font(.callout)
                    .padding([.bottom], 8)
            }
            .padding(16)
        }
        .cornerRadius(8)
        .padding(16)
    }
}

final class LyricSearchResultViewModel: ObservableObject {
    private let service: GeniusAPIService
    
    struct Output {
        var geniusSongTitlePublisher: AnyPublisher<String?, Never>
        var geniusSongURLPublisher: AnyPublisher<String?, Never>
        var errorPublisher: AnyPublisher<Error?, Never>
    }

    @Published var geniusSongTitle: String?
    @Published var geniusSongURL: String?
    @Published var requestError: Error?
    
    init(service: GeniusAPIService = GeniusAPIService()) {
        self.service = service
    }

    func bind() -> Output {
        let responsePublisher = service.responsePublisher
        let geniusSongTitle = responsePublisher
            .map { $0.fullTitle }
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
        let geniusSongURL = responsePublisher
            .map { $0.webPath }
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
