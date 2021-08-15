//
//  MusixMatchAPIService.swift
//  MusixMatchAPIService
//
//  Created by Deborah Newberry on 8/14/21.
//

final class MusixMatchAPIService {
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
    
    @available(iOS 15.0.0, *)
    func search(request: LyricsRequest) async throws -> [Lyrics]? {
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
        return try? JSONDecoder().decode(LyricsResponse.self, from: data).lyrics
    }
}

struct LyricsRequest {
    private enum Parameter: String {
        case songTitle = "q_track"
        case artist = "q_artist"
        
        var fieldName: String {
            return self.rawValue
        }
    }
    
    let songTitle: String
    let artist: String
    
    func toQueryItems() -> [URLQueryItem] {
        return [
            URLQueryItem(name: Parameter.songTitle.fieldName, value: songTitle),
            URLQueryItem(name: Parameter.artist.fieldName, value: artist)
        ]
    }
}


struct LyricsResponse: Codable {
    let lyrics: [Lyrics]
}

struct Track: Codable {
    let instrumental: Int?
    let album_coverart_350x350: String?
    let first_release_date: String?
    let track_isrc: String?
    let explicit: Int?
    let track_edit_url: String?
    let num_favourite: Int?
    let album_coverart_500x500: String?
    let album_name: String?
    let track_rating: Int?
    let track_share_url: String?
    let track_soundcloud_id: Int?
    let artist_name: String?
    let album_coverart_800x800: String?
    let album_coverart_100x100: String?
    let track_name_translation_list: [String]?
    let track_name: String?
    let restricted: Int?
    let has_subtitles: Int?
    let updated_time: String?
    let subtitle_id: Int?
    let lyrics_id: Int?
    let track_spotify_id: String?
    let has_lyrics: Int?
    let artist_id: Int?
    let album_id: Int?
    let artist_mbid: String?
//    let secondary_genres: [Genre]? // TODO
    let commontrack_vanity_id: String?
    let track_id: Int?
    let track_xboxmusic_id: String?
//    let primary_genres: Genre?
    let track_length: Int?
    let track_mbid: String?
    let commontrack_id: Int?
}

struct Lyrics: Codable {
    let instrumental: Int?
    let pixel_tracking_url: String?
    let publisher_list: [String]?
    let lyrics_language_description: String?
    let restricted: Int?
    let updated_time: String?
    let explicit: Int?
    let lyrics_copyright: String?
    let html_tracking_url: String?
    let lyrics_language: String?
    let script_tracking_url: String?
    let verified: Int?
    let lyrics_body: String?
    let lyrics_id: Int?
    let writer_list: [String]?
    let can_edit: Int?
    let action_requested: String?
    let locked: Int?
}
