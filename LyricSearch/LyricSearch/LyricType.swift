//
//  LyricType.swift
//  LyricType
//
//  Created by Deborah Newberry on 8/16/21.
//

enum LyricType: Int, CaseIterable, Identifiable {
    case original
    case romanized
    case translation
    
    var id: Int {
        return rawValue
    }
    
    var displayName: String {
        switch self {
        case .original: return "Original"
        case .romanized: return "Romanized"
        case .translation: return "Translation"
        }
    }
    
    var queryExtension: String {
        switch self {
        case .original: return ""
        case .romanized: return "Romanized"
        case .translation: return "Translation"
        }
    }
}
