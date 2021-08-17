//
//  Persistence.swift
//  LyricSearch
//
//  Created by Deborah Newberry on 8/11/21.
//

import CoreData

struct PersistenceController {
    static let shared = PersistenceController()

    static var preview: PersistenceController = {
        let result = PersistenceController(inMemory: true)
        let viewContext = result.container.viewContext
        let itemIds: [Int64] = [0, 1, 2, 3, 4]
        itemIds.forEach { id in
            let newLyrics = SavedLyrics(context: viewContext)
            newLyrics.id = id
            newLyrics.content = "<b>These aren't real lyrics.</b>"
            let newArtist = SavedArtist(context: viewContext)
            newArtist.id = id
            newArtist.name = "Saved artist"
            let newSong = SavedSong(context: viewContext)
            newSong.timestamp = Date()
            newSong.title = "Song title"
            newSong.id = id
            newSong.songLyrics = newLyrics
            newSong.songArtist = newArtist
        }
        do {
            try viewContext.save()
        } catch {
            // Replace this implementation with code to handle the error appropriately.
            // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
        return result
    }()

    let container: NSPersistentCloudKitContainer

    init(inMemory: Bool = false) {
        container = NSPersistentCloudKitContainer(name: "LyricSearch")
        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.

                /*
                Typical reasons for an error here include:
                * The parent directory does not exist, cannot be created, or disallows writing.
                * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                * The device is out of space.
                * The store could not be migrated to the current model version.
                Check the error message to determine what the actual problem was.
                */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
    }
}
