//
//  GeniusAPIService.swift
//  GeniusAPIService
//
//  Created by Deborah Newberry on 8/15/21.
//

import Combine

enum GeniusAPIError: Error {
    case noResults
    case decodingError(_ error: Error)
    case apiError(_ error: Error)
    
    var message: String {
        switch self {
        case .noResults:
            return "No results found."
        case let .decodingError(error):
            return "Something went wrong when reading output: \(error.localizedDescription)"
        case let .apiError(error):
            return "Something went wrong when querying: \(error.localizedDescription)"
        }
    }
}

final class GeniusAPIService {
    let responsePublisher = PassthroughSubject<GeniusSong, Never>()
    let errorPublisher = PassthroughSubject<GeniusAPIError?, Never>()
    
    private struct Endpoints {
        static let search = "https://genius.p.rapidapi.com/search"
    }
    
    private struct HeaderValues {
        static let apiKey = Bundle.stringValue(forKey: .rapidAPIKey)
        static let apiHost = "genius.p.rapidapi.com"
    }
    
    private struct Keys {
        static let apiHost = "x-rapidapi-host"
        static let apiKey = "x-rapidapi-key"
        static let query = "q"
    }
    
    func search(query: String, lyricType: LyricType) {
        let fullQuery = "\(query) \(lyricType.queryExtension)"
        var urlComponents = URLComponents(string: Endpoints.search)
        urlComponents?.queryItems = [
            URLQueryItem(name: Keys.query, value: fullQuery)
        ]
        guard let url = urlComponents?.url else {
            fatalError("Malformed URL")
        }
        
        var request = URLRequest(url: url)
        request.addValue(HeaderValues.apiKey, forHTTPHeaderField: Keys.apiKey)
        request.addValue(HeaderValues.apiHost, forHTTPHeaderField: Keys.apiHost)
        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            guard let self = self else { return }
            if let error = error {
                self.errorPublisher.send(.apiError(error))
                return
            }
            
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            
            guard let data = data else {
                self.errorPublisher.send(.noResults)
                return
            }
            do {
                let decodedResponse = try decoder.decode(GeniusSearchResponse.self, from: data)
                if let song = decodedResponse.response.hits.first?.result {
                    self.errorPublisher.send(nil)
                    self.responsePublisher.send(song)
                    print("🎶 \(song)")
                } else {
                    self.errorPublisher.send(.noResults)
                }
            } catch {
                self.errorPublisher.send(.decodingError(error))
            }
        }.resume()
    }
}
