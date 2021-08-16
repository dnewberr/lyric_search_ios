//
//  ContentView.swift
//  LyricSearch
//
//  Created by Deborah Newberry on 8/11/21.
//

import SwiftUI
import CoreData


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
    
    @State var lyricType: LyricType = .original

    var body: some View {
        ZStack {
            Color.gray.opacity(0.1).ignoresSafeArea()
            VStack(alignment: .leading)  {
                Button(buttonTitle) {
                    SpotifyAuthService.main.authorize()
                }
                .disabled(buttonDisabled)
                Spacer()
                HStack {
                    SongView(viewModel: songViewModel)
                    Text("Style: \(lyricType.displayName)")
                }
                Picker(selection: $lyricType, label: Text("")) {
                    ForEach(LyricType.allCases) {
                        Text($0.displayName).tag($0)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .onChange(of: lyricType) { lyricType in
                    lyricSearchResultViewModel.updateCurrentSearch(for: lyricType)
                }
                LyricSearchResultView(viewModel: lyricSearchResultViewModel)
            }
            .padding(16)
        }
        .onReceive(SpotifyAuthService.main.currentPlayerStatePublisher) { currentState in
            lyricSearchResultViewModel.search(query: currentState.track.searchableQuery, lyricType: lyricType)
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
