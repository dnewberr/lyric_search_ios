//
//  Response.swift
//  Response
//
//  Created by Deborah Newberry on 8/14/21.
//

protocol MMResponse: Codable {}

struct MMLyricsResponse: MMResponse, Codable {
    let lyrics: MMLyrics
}
