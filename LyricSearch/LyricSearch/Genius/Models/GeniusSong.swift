//
//  GeniusSong.swift
//  GeniusSong
//
//  Created by Deborah Newberry on 8/16/21.
//

struct GeniusSong: Codable {
    let id: Int64
    let apiPath: String?
    let fullTitle: String?
    let title: String?
    let titleWithFeatured: String?
    let url: String?
    let songArtPrimaryColor: String?
    let songArtSecondaryColor: String?
    let songArtTextColor: String?
    let primaryArtist: GeniusArtist?
}

struct GeniusArtist: Codable {
    let id: Int64
    let name: String
}
