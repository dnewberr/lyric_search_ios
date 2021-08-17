//
//  ContentView.swift
//  LyricSearch
//
//  Created by Deborah Newberry on 8/11/21.
//

import CoreData
import SwiftUI

struct ContentView: View {
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.managedObjectContext) private var viewContext
    private let songViewModel = SongViewModel()
    private let lyricSearchResultViewModel: LyricSearchResultViewModel
    private let lyricSearchResultViewModelOutput: LyricSearchResultViewModel.Output
    
    @State var isConnectedToSpotify: Bool = false
    @State var lyricType: LyricType = .original
    
    private static let defaultBackgroundColor = Color.gray
    
    @State var textColor: Color = Color.black
    @State var backgroundColor: Color = ContentView.defaultBackgroundColor
    
    @State private var webViewUrl: URL?
    @State private var currentLyricsError: GeniusAPIError? = nil
    @State private var isCurrentSongSaved = false
    @State private var currentSong: GeniusSong?
    
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
                HStack {
                SongView(viewModel: songViewModel)
                    .foregroundColor(textColor)
                    Spacer()
                    Image(systemName: isCurrentSongSaved ? "heart.fill" : "heart")
                        .onTapGesture {
                            didTapSaveButton()
                        }
                        .padding([.trailing], 4)
                }
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
            if !isConnected {
                currentSong = nil
            }
        }
        .onReceive(lyricSearchResultViewModelOutput.geniusSongURLPublisher) { url in
            webViewUrl = url
        }
        .onReceive(lyricSearchResultViewModelOutput.errorPublisher) { error in
            currentLyricsError = error
        }
        .onReceive(lyricSearchResultViewModelOutput.geniusSongPublisher) { song in
            setColorTheme(song: song)
            updateSaveIcon(song: song)
            currentSong = song
        }
        .padding(16)
        .background(backgroundColor.opacity(0.25).ignoresSafeArea())
    }
    
    private func didTapSaveButton() {
        guard let currentSong = currentSong else {
            return
        }

        if isCurrentSongSaved {
            // TODO
            return
        } else {
            // add and save TODO
            let newLyrics = SavedLyrics(context: viewContext)
            newLyrics.id = currentSong.id
            newLyrics.content = "<b>These aren't real lyrics.</b>"
            
            let newSong = SavedSong(context: viewContext)
            newSong.timestamp = Date()
            newSong.title = currentSong.title
            newSong.id = currentSong.id
            newSong.songLyrics = newLyrics
            
            if let artist = currentSong.primaryArtist {
                let newArtist = SavedArtist(context: viewContext)
                newArtist.id = artist.id
                newArtist.name = artist.name
                newSong.songArtist = newArtist
            }
        }
        
        do {
            try viewContext.save()
            isCurrentSongSaved.toggle()
        } catch {
            // Replace this implementation with code to handle the error appropriately.
            // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
    }
    
    private func updateSaveIcon(song: GeniusSong) {
        let fetchRequest = FetchRequest<SavedSong>(entity: SavedSong.entity(),
                                                   sortDescriptors: [],
                                                   predicate: NSPredicate(format: "id = %d", song.id))
        isCurrentSongSaved = !fetchRequest.wrappedValue.isEmpty
    }
    
    private func setColorTheme(song: GeniusSong) {
        let defaultTextColor = colorScheme == .dark ? Color.black : Color.white
        
        backgroundColor = Color(hex: song.songArtPrimaryColor) ?? ContentView.defaultBackgroundColor
        textColor = Color(hex: song.songArtSecondaryColor) ?? defaultTextColor
        
        // Ensure the text and bg are not both light
        if backgroundColor.isLight && textColor.isLight {
            textColor = defaultTextColor
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
