////
////  AppDelegate.swift
////  AppDelegate
////
////  Created by Deborah Newberry on 8/11/21.
////
import UIKit
import SwiftUI

class AppDelegate: UIResponder, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        return true
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        SpotifyAuthService.main.attemptToEstablishConnection(fromUrl: url)
        return true
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        SpotifyAuthService.main.disconnect()
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        SpotifyAuthService.main.reconnect()
    }
}
