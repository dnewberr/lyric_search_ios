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
    private let apiKey = Bundle.stringValue(forKey: .rapidAPIKey)
    
    let responsePublisher = PassthroughSubject<GeniusSong, Never>()
    let errorPublisher = PassthroughSubject<GeniusAPIError?, Never>()
    
    private struct Endpoints {
        static let search = "https://genius.p.rapidapi.com/search"
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
        request.addValue(apiKey, forHTTPHeaderField: Keys.apiKey)
        request.addValue("genius.p.rapidapi.com", forHTTPHeaderField: Keys.apiHost)
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
                let decodedResponse = try decoder.decode(GeniusResponse.self, from: data)
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


struct GeniusResponse: Codable {
    let response: GeniusHits
}

struct GeniusHits: Codable {
    let hits: [GeniusHit]
}

struct GeniusHit: Codable {
    let result: GeniusSong
}

struct GeniusSong: Codable {
    let id: Int
    let apiPath: String?
    let fullTitle: String?
    let title: String?
    let titleWithFeatured: String?
    let url: String?
    let songArtPrimaryColor: String?
    let songArtSecondaryColor: String?
    let songArtTextColor: String?
}

