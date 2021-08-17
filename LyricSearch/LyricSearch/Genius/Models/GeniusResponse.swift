//
//  GeniusResponse.swift
//  GeniusResponse
//
//  Created by Deborah Newberry on 8/16/21.
//

import Foundation

// Response Boilerplate
struct GeniusResponse: Codable {
    let response: GeniusHits
}

struct GeniusHits: Codable {
    let hits: [GeniusHit]
}

struct GeniusHit: Codable {
    let result: GeniusSong
}
