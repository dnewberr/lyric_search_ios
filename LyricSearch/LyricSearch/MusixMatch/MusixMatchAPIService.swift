//
//  MusixMatchAPIService.swift
//  MusixMatchAPIService
//
//  Created by Deborah Newberry on 8/14/21.
//

@available(iOS 15.0.0, *)
protocol MusixMatchAPIService {
    // Returns all `MMLyrics` that match the given request.
    func getLyrics(_ request: MMLyricsRequest) async throws -> MMLyrics?
}

@available(iOS 15.0.0, *)
final class MusixMatchAPIServiceImpl: MusixMatchAPIService {
    private let baseUrl = "https://api.musixmatch.com/ws/1.1/"
    private let defaultQueryItems: [URLQueryItem] = {
        let apiKey = Bundle.stringValue(forKey: .musixMatchAPIKey)
        let apiKeyQueryItem = URLQueryItem(name: "apikey", value: apiKey)
        let formatQueryItem = URLQueryItem(name: "format", value: "json")
        let callbackQueryItem = URLQueryItem(name: "callback", value: "callback")
        return [apiKeyQueryItem, formatQueryItem, callbackQueryItem]
    }()
    
    private enum Endpoints: String {
        case search = "track.search"
        case lyric = "matcher.lyrics.get"
        
        var urlString: String {
            return self.rawValue
        }
    }
    
    func getLyrics(_ request: MMLyricsRequest) async throws -> MMLyrics? {
        var urlComponents = URLComponents(string: baseUrl + Endpoints.lyric.urlString)
        var queryItems = request.toQueryItems()
        queryItems.append(contentsOf: defaultQueryItems)
        urlComponents?.queryItems = queryItems
        
        print(urlComponents?.url ?? "")
        guard let url = urlComponents?.url else {
            fatalError("Malformed URL")
        }
        
        let (data, response) = try await URLSession.shared.data(from: url)
        print(response)
        try? print(JSONSerialization.jsonObject(with: data, options: []))
        return JSONDecoder().decodeMMResponse(MMLyricsResponse.self, from: data)?.lyrics
    }
}

extension JSONDecoder {
    func decodeMMResponse<T: Codable>(_ type: T.Type, from data: Data) -> T? {
        let object = BoilerPlate<T>.self
        do {
            let object = try decode(object.self, from: data)
            return object.message.body
        } catch {
            print(error)
            return nil
        }
    }
}

struct BoilerPlate<T: Codable>: Codable {
    let message: BoilerPlateMessage<T>
}

struct BoilerPlateMessage<T: Codable>: Codable {
    let body: T
}
