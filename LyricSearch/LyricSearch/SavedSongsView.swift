//
//  SavedSongsView.swift
//  SavedSongsView
//
//  Created by Deborah Newberry on 8/16/21.
//

import SwiftUI

struct SavedSongsView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \SavedSong.timestamp, ascending: true)],
        animation: .default)
    private var savedSongs: FetchedResults<SavedSong>
    
    var body: some View {
        NavigationView {
            VStack(alignment: .leading) {
                Text("Saved songs")
                    .font(.largeTitle)
                    .padding(16)
                List {
                    ForEach(savedSongs) { savedSong in
                        NavigationLink(destination: HTMLView(savedSong: savedSong)) {
                            VStack {
                                Text(savedSong.songArtist?.name ?? "Unknown")
                                    .font(.headline)
                                Text(savedSong.title ?? "Unknown")
                                    .font(.subheadline)
                            }
                        }
                    }
                    .onDelete(perform: deleteItems)
                }
                .toolbar {
                    #if os(iOS)
                    EditButton()
                    #endif
                }
            }
        }
    }
    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            offsets.map { savedSongs[$0] }.forEach(viewContext.delete)
            
            do {
                try viewContext.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
}
