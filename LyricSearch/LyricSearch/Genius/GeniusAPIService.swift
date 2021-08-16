//
//  GeniusAPIService.swift
//  GeniusAPIService
//
//  Created by Deborah Newberry on 8/15/21.
//

import Combine

final class GeniusAPIService {
    private let apiKey = Bundle.stringValue(forKey: .rapidAPIKey)
    
    let responsePublisher = PassthroughSubject<GeniusSong, Never>()
    let errorPublisher = PassthroughSubject<Error?, Never>()
    
    private struct Endpoints {
        static let search = "https://genius.p.rapidapi.com/search"
    }
    
    private struct Keys {
        static let apiHost = "x-rapidapi-host"
        static let apiKey = "x-rapidapi-key"
        static let query = "q"
    }
    
    func search(query: String) {
        var urlComponents = URLComponents(string: Endpoints.search)
        urlComponents?.queryItems = [
            URLQueryItem(name: Keys.query, value: query)
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
                self.errorPublisher.send(error)
                return
            }
            
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            
            guard let data = data else {
                print("no data")
                return
            }
            do {
                let decodedResponse = try decoder.decode(GeniusResponse.self, from: data)
                if let song = decodedResponse.response.hits.first?.result {
                    self.errorPublisher.send(nil)
                    self.responsePublisher.send(song)
                } else {
                    print("hits empty")
                }
            } catch {
                self.errorPublisher.send(error)
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
    let webPath: String?
//    "song_art_primary_color":"#bc9142"
//    "song_art_secondary_color":"#392c14"
//    "song_art_text_color":"#fff"
//    "primary_artist":{...}9 items
}

