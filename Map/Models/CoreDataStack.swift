//
//  CoreDataStack.swift
//  Map
//
//  Created by saj panchal on 2024-07-09.
//

import Foundation
import CoreData

class CoreDataStack: ObservableObject {
    static let shared = CoreDataStack()
    
    lazy var persistantContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "AppDataModel")
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
