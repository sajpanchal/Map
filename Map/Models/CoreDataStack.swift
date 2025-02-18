//
//  CoreDataStack.swift
//  Map
//
//  Created by saj panchal on 2024-07-09.
//

import Foundation
import CloudKit
import CoreData
class CoreDataStack: ObservableObject {
    static let shared = CoreDataStack()
    
    lazy var persistantContainer: NSPersistentCloudKitContainer = {
        let container = NSPersistentCloudKitContainer(name: "AppDataModel")
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        container.viewContext.automaticallyMergesChangesFromParent = true
        do {
            try container.viewContext.setQueryGenerationFrom(.current)
        }
        catch {
            print(error.localizedDescription)
        }
        container.loadPersistentStores { _, error in
            if let error {
                fatalError("Failed to load persistant stores: \(error.localizedDescription)")
            }
            
        }
       return container
    }()
    private init() {
        
    }
}

extension CoreDataStack {
    func save() {
        
        guard persistantContainer.viewContext.hasChanges else {
            return
        }
        
        do {
            try persistantContainer.viewContext.save()
        }
        catch {
            print("Failed to save the context: ", error.localizedDescription)
        }
    }
    
}
