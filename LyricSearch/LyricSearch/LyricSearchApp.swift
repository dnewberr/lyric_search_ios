//
//  LyricSearchApp.swift
//  LyricSearch
//
//  Created by Deborah Newberry on 8/11/21.
//

import SwiftUI

@main
struct LyricSearchApp: App {
    let persistenceController = PersistenceController.shared
    @Environment(\.scenePhase) var scenePhase

    var body: some Scene {
        WindowGroup {
            TabView {
                ContentView()
                    .tabItem {
                        Image(systemName: "play.circle")
                        Text("Now Playing")
                    }
                    .environment(\.managedObjectContext, persistenceController.container.viewContext)
                
                SavedSongsView()
                    .tabItem {
                        Image(systemName: "square.and.arrow.down")
                        Text("Saved Songs")
                    }
                    .environment(\.managedObjectContext, persistenceController.container.viewContext)
            }
            .onOpenURL { url in
                SpotifyAuthService.main.attemptToEstablishConnection(fromUrl: url)
            }
        }
        .onChange(of: scenePhase) { newScenePhase in
              switch newScenePhase {
              case .active:
                  SpotifyAuthService.main.reconnect()
              case .inactive:
                  SpotifyAuthService.main.disconnect()
              case .background:
                  // No-op
                  break
              @unknown default:
                  // No-op
                  break
              }
            }
    }
}
