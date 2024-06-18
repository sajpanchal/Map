//
//  ContentView.swift
//  Map
//
//  Created by saj panchal on 2023-08-03.
//

import SwiftUI

struct ContentView: View {
    ///localSearch object is instantiated on rendering this view.
    @StateObject var localSearch = LocalSearch()
    
    var body: some View {
        TabView {
            Map(localSearch: localSearch)
                .tabItem {
                    Label("Map", systemImage: "mappin.and.ellipse")
                }
                .toolbar(localSearch.status != .localSearchCancelled ? .hidden : .visible, for: .tabBar)
            
            StatsView()
                .tabItem {
                    Label("AutoStats", systemImage: "steeringwheel")
                }
                .toolbar(localSearch.status != .localSearchCancelled ? .hidden : .visible, for: .tabBar)
            
            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gearshape.fill")
                }
                .toolbar(localSearch.status != .localSearchCancelled ? .hidden : .visible, for: .tabBar)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
