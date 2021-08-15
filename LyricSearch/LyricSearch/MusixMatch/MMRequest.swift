//
//  MMRequest.swift
//  MMRequest
//
//  Created by Deborah Newberry on 8/14/21.
//

protocol MMRequest {}

struct MMLyricsRequest: MMRequest {
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
