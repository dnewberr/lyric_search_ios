//
//  ContentView.swift
//  LyricSearch
//
//  Created by Deborah Newberry on 8/11/21.
//

import SwiftUI
import CoreData

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Item.timestamp, ascending: true)],
        animation: .default)
    private var items: FetchedResults<Item>
    private let songViewModel = SongViewModel()
    private let lyricSearchResultViewModel = LyricSearchResultViewModel()

    var body: some View {
        VStack {
            Button("Connect to Spotify") {
                SpotifyAuthService.main.authorize()
            }
            Spacer()
            SongView(viewModel: songViewModel)
            Spacer()
            LyricSearchResultView(viewModel: lyricSearchResultViewModel)
        }.onReceive(SpotifyAuthService.main.currentPlayerStatePublisher) { currentState in
            lyricSearchResultViewModel.search(query: currentState.track.searchableQuery)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
                
    }
}

extension SPTAppRemoteTrack {
    var searchableQuery: String {
        return "\(self.name) \(self.artist.name)"
    }
}
