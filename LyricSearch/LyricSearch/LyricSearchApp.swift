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
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        WindowGroup {
            if #available(iOS 15.0.0, *) {
                ContentView(lyricSearchViewModel: AsyncLyricSearchViewModel(apiService: MusixMatchAPIServiceImpl()))
                    .environment(\.managedObjectContext, persistenceController.container.viewContext)
            } else {
                ContentView(lyricSearchViewModel: DefaultLyricSearchViewModel())
                    .environment(\.managedObjectContext, persistenceController.container.viewContext)
            }
        }
    }
}
