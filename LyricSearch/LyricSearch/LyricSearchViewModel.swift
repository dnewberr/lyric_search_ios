//
//  LyricSearchViewModel.swift
//  LyricSearchViewModel
//
//  Created by Deborah Newberry on 8/14/21.
//

import Foundation

protocol LyricSearchViewModel {
    func getLyrics(artist: String, songTitle: String) -> MMLyrics?
}

struct DefaultLyricSearchViewModel: LyricSearchViewModel {
    func getLyrics(artist: String, songTitle: String) -> MMLyrics? {
        // TODO
        return nil
    }
}

@available(iOS 15.0.0, *)
struct AsyncLyricSearchViewModel: LyricSearchViewModel {
    let apiService: MusixMatchAPIService
    
    func getLyrics(artist: String, songTitle: String) -> MMLyrics? {
        let lyricsRequest = MMLyricsRequest(songTitle: songTitle, artist: artist)
        Task { () -> MMLyrics? in
            if let lyricsFound = try? await apiService.getLyrics(lyricsRequest) {
                print(lyricsFound)
                return lyricsFound
            }
            return nil
        }
        
        return nil
    }
}
