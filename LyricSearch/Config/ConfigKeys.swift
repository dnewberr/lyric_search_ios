enum ConfigKey: String {
    case musixMatchAPIKey = "MUSIX_MATCH_API_KEY"
    case spotifyClientId = "SPOTIFY_CLIENT_ID"
}

extension Bundle {
    class func stringValue(forKey key: ConfigKey) -> String {
        guard let value = main.infoDictionary?[key.rawValue] as? String else {
            fatalError("Value not found for key \(key.rawValue)")
        }
        
        return value
    }
}
