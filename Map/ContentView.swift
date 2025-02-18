//
//  ContentView.swift
//  Map
//
//  Created by saj panchal on 2023-08-03.
//

import SwiftUI
import CoreData
import CloudKit
struct ContentView: View {
    ///localSearch object is instantiated on rendering this view.
    @StateObject var localSearch = LocalSearch()
    @StateObject var locationDataManager = LocationDataManager()
    @Environment(\.managedObjectContext) private var viewContext
    ///boolean indicates whether user has already signed in or not.
    @State var isSignedIn = false
    @State var isInitialized = false
    var isEmpty: Bool {
        print("Called")
        do {
            let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Vehicle")
            let count  = try viewContext.count(for: request)
            print("counts: ", count)
            return count == 0
        } catch {
            print("error")
            return true
        }
    }

    var body: some View {
        ///if user is not signed in
        if !isSignedIn {
            ///show the signInView.
            SignInView(isSignedIn: $isSignedIn)
        }
        ///if user is already signed in, unlock the app navigation view.
        else {
            if isEmpty && !isInitialized {
                InitialSettingsView(locationDataManager: locationDataManager, isInitialized: $isInitialized)
            }
            else {
                TabView {
                    Map(locationDataManager: locationDataManager, localSearch: localSearch)
                        .tabItem {
                            Label("Map", systemImage: "mappin.and.ellipse")
                        }
                        .toolbar(localSearch.status != .localSearchCancelled ? .hidden : .visible, for: .tabBar)
                    
                    AutoStatsView(locationDataManager: locationDataManager)
                        .tabItem {
                            Label("Summary", systemImage: "steeringwheel")
                        }
                    
                        .toolbar(localSearch.status != .localSearchCancelled ? .hidden : .visible, for: .tabBar)
                    
                    SettingsView(locationDataManager: locationDataManager)
                        .tabItem {
                            Label("Settings", systemImage: "gearshape.fill")
                                .onTapGesture {
                                    
                                }
                        }
                        .toolbar(localSearch.status != .localSearchCancelled ? .hidden : .visible, for: .tabBar)
                }
                
            }
        }
    }
       
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
