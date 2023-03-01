//
//  StorageManager.swift
//  ShiftTestApp
//
//  Created by Илья Дубенский on 24.02.2023.
//

import CoreData

final class StorageManager {

    static let shared: StorageManager = .init()

    private let persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "ShiftTestApp")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    private var viewContext: NSManagedObjectContext {
        persistentContainer.viewContext
    }

    // MARK: - Core Data Saving support
    func saveContext() {
        if viewContext.hasChanges {
            do {
                try viewContext.save()
            } catch {
                let error = error as NSError
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }
    }

    /// Read
    func getFetchedResultsController(entityName: String,
                                     keyForSort: String) -> NSFetchedResultsController<NSFetchRequestResult> {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
        let sortDescriptor = NSSortDescriptor(key: keyForSort, ascending: true)

        fetchRequest.sortDescriptors = [sortDescriptor]

        let fetchResultsController = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: viewContext,
            sectionNameKeyPath: nil,
            cacheName: nil
        )
        return fetchResultsController
    }

    /// Create
    func saveNote(withTitle title: String, andText text: String) {
        let note = Note(context: viewContext)
        note.title = title
        note.text = text
        note.date = Date()
        saveContext()
    }

    /// Delete
    func delete(note: Note) {
        viewContext.delete(note)
        saveContext()
    }

    /// Update
    func update(note: Note, withNewTitle title: String, andText text: String) {
        note.title = title
        note.text = text
        saveContext()
    }
}
