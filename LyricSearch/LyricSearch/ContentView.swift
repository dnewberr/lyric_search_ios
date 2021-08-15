//
//  ContentView.swift
//  LyricSearch
//
//  Created by Deborah Newberry on 8/11/21.
//

import SwiftUI
import CoreData

struct ContentView: View {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @Environment(\.managedObjectContext) private var viewContext

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Item.timestamp, ascending: true)],
        animation: .default)
    private var items: FetchedResults<Item>

    @State private var showingAlert = false

    @State private var titleQuery: String = ""
    @State private var artistQuery: String = ""

    var body: some View {
        VStack {
            Button("Connect to Spotify") {
                SpotifyAuthService.main.authorize()
            }
            
            TextField("Enter title", text: $titleQuery)
            TextField("Enter artist", text: $artistQuery)
            
            Button("Search") {
                guard !titleQuery.isEmpty && !artistQuery.isEmpty else {
                    showingAlert = true
                    return
                }
                beginSearch()
            }
            
            List {
                ForEach(items) { item in
                    Text("Item at \(item.timestamp!, formatter: itemFormatter)")
                }
                .onDelete(perform: deleteItems)
            }
            .toolbar {
                #if os(iOS)
                EditButton()
                #endif

                Button(action: addItem) {
                    Label("Add Item", systemImage: "plus")
                }
            }
            .alert(isPresented: $showingAlert) {
                Alert(title: Text("Incomplete Info"), message: Text("Please fill out both the artist and song title."))
            }
        }
    }
    
    private func beginSearch() {
        let lyricsRequest = MMLyricsRequest(songTitle: titleQuery, artist: artistQuery)
        let apiService = MusixMatchAPIService()
        if #available(iOS 15.0.0, *) {
            Task {
                if let tracksFound = try? await apiService.search(request: lyricsRequest) {
                    print(tracksFound)
                }
            }
        } else {
            // Fallback on earlier versions
        }
    }
    
    private func addItem() {
        withAnimation {
            let newItem = Item(context: viewContext)
            newItem.timestamp = Date()

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

    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            offsets.map { items[$0] }.forEach(viewContext.delete)

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

private let itemFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .short
    formatter.timeStyle = .medium
    return formatter
}()

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
