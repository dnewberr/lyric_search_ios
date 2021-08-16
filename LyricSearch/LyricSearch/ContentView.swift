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
    
    @State var buttonTitle: String = "Connect to Spotify"
    @State var buttonDisabled: Bool = false

    var body: some View {
        VStack(alignment: .leading)  {
            Button(buttonTitle) {
                SpotifyAuthService.main.authorize()
            }
            .disabled(buttonDisabled)
            Spacer()
            HStack {
                Text("Lyrics")
                    .font(.largeTitle)
                SongView(viewModel: songViewModel)
            }
            LyricSearchResultView(viewModel: lyricSearchResultViewModel)
        }
        .padding(16)
        .onReceive(SpotifyAuthService.main.currentPlayerStatePublisher) { currentState in
            lyricSearchResultViewModel.search(query: currentState.track.searchableQuery)
        }
        .onReceive(SpotifyAuthService.main.isConnectedPublisher) { isConnected in
            buttonTitle = isConnected ? "Connected to Spotify" : "Connect to Spotify"
            buttonDisabled = isConnected
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
