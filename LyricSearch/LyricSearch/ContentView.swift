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
        sortDescriptors: [NSSortDescriptor(keyPath: \SavedSong.timestamp, ascending: true)],
        animation: .default)
    private var items: FetchedResults<SavedSong>
    private let songViewModel = SongViewModel()
    private let lyricSearchResultViewModel: LyricSearchResultViewModel
    private let lyricSearchResultViewModelOutput: LyricSearchResultViewModel.Output
    
    @State var isConnectedToSpotify: Bool = false
    @State var lyricType: LyricType = .original
    
    private static let defaultBackgroundColor = Color.gray
    private static let defaultTextColor = Color.black
    
    @State var textColor: Color = ContentView.defaultTextColor
    @State var backgroundColor: Color = ContentView.defaultBackgroundColor
    
    
    @State private var webViewUrl: URL?
    @State private var currentLyricsError: GeniusAPIError? = nil
    
    init() {
        self.lyricSearchResultViewModel = LyricSearchResultViewModel()
        self.lyricSearchResultViewModelOutput = lyricSearchResultViewModel.bind()
    }

    var body: some View {
        VStack(alignment: .leading)  {
            if !isConnectedToSpotify {
                Button("Connect to Spotify") {
                    SpotifyAuthService.main.authorize()
                }
                .font(.largeTitle)
            } else {
                SongView(viewModel: songViewModel)
                    .foregroundColor(textColor)
            }
            Picker(selection: $lyricType, label: Text("Lyric Style")) {
                ForEach(LyricType.allCases) {
                    Text($0.displayName).tag($0)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
            .onChange(of: lyricType) { lyricType in
                lyricSearchResultViewModel.updateCurrentSearch(for: lyricType)
            }
            if let error = currentLyricsError {
                Text(error.message)
                Spacer()
            } else {
                WebView(url: webViewUrl)
                    .cornerRadius(8)
            }
        }
        .onReceive(SpotifyAuthService.main.currentPlayerStatePublisher) { currentState in
            lyricSearchResultViewModel.search(query: currentState.track.searchableQuery, lyricType: lyricType)
        }
        .onReceive(SpotifyAuthService.main.isConnectedPublisher) { isConnected in
            isConnectedToSpotify = isConnected
        }
        .onReceive(lyricSearchResultViewModelOutput.geniusSongURLPublisher) { url in
            webViewUrl = url
        }
        .onReceive(lyricSearchResultViewModelOutput.errorPublisher) { error in
            currentLyricsError = error
        }
        .onReceive(lyricSearchResultViewModelOutput.geniusSongPublisher) { song in
            backgroundColor = Color(hex: song.songArtPrimaryColor) ?? ContentView.defaultBackgroundColor
            textColor = Color(hex: song.songArtSecondaryColor) ?? ContentView.defaultTextColor
            
            // Ensure the text and bg are not both light
            if backgroundColor.isLight && textColor.isLight {
                textColor = ContentView.defaultTextColor
            }
        }
        .padding(16)
        .background(backgroundColor.opacity(0.25).ignoresSafeArea())
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
