//
//  MapApp.swift
//  Map
//
//  Created by saj panchal on 2023-08-03.
//

import SwiftUI
import CoreData
import CloudKit
@main
struct MapApp: App {
    @StateObject private var coreDataStack = CoreDataStack.shared
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, coreDataStack.persistantContainer.viewContext)
        }
    }
}
