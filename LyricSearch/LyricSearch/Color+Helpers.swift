//
//  Color+Helpers.swift
//  Color+Helpers
//
//  Created by Deborah Newberry on 8/16/21.
//

import SwiftUI
import CoreData

extension Color {
    init?(hex: String?) {
        guard var hex = hex?.trimmingCharacters(in: .whitespacesAndNewlines).uppercased() else {
            return nil
        }
        
        if hex.hasPrefix("#") {
            hex.remove(at: hex.startIndex)
        }
        
        if hex.count != 6 {
            self.init(UIColor.gray)
            return
        }
        
        var rgbValue: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&rgbValue)
        
        let uiColor = UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
        
        self.init(uiColor)
    }
    
    var isLight: Bool {
        // UIColor.white / UIColor.black are greyscale and not RGB so we'll take care of these first.
        guard self != .white else { return true }
        guard self != .black else { return false }
        
        let threshold: Float = 0.7
        guard let originalCGColor = self.cgColor else { return false }
        
        // Convert it to the RGB colorspace.
        let rgbccColor = originalCGColor.converted(to: CGColorSpaceCreateDeviceRGB(), intent: .defaultIntent, options: nil)
        guard let components = rgbccColor?.components, components.count >= 3 else {
            return false
        }
        
        let brightness = Float(((components[0] * 299) + (components[1] * 587) + (components[2] * 114)) / 1000)
        return (brightness > threshold)
    }
}
