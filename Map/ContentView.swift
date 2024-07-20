//
//  ContentView.swift
//  Map
//
//  Created by saj panchal on 2023-08-03.
//

import SwiftUI
import CoreData
struct ContentView: View {
    ///localSearch object is instantiated on rendering this view.
    @StateObject var localSearch = LocalSearch()
    @StateObject var locationDataManager = LocationDataManager()
    @State var vehicles: [AutoVehicle] = []
    @State var vehicle: AutoVehicle?
    @Environment(\.managedObjectContext) private var viewContext
//    let request: NSFetchRequest = {
//        let request = Settings.fetchRequest()
//        return request
//    }()
    var isEmpty: Bool {
        //print("requesting")
        do {
            let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Vehicle")
            let count  = try viewContext.count(for: request)
            return count == 0
        } catch {
            return true
        }
    }
    //@FetchRequest(entity:Vehicle.entity(), sortDescriptors:[]) var setting: FetchedResults<Vehicle>

    var body: some View {
        if isEmpty {
           // SettingsView(locationDataManager: locationDataManager, vehicles: $vehicles, vehicle: $vehicle)
            InitialSettingsView(locationDataManager: locationDataManager)
        }
        else {
            TabView {
                Map(locationDataManager: locationDataManager, localSearch: localSearch, vehicle: $vehicle, vehicles: $vehicles)
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
                    }
                    .toolbar(localSearch.status != .localSearchCancelled ? .hidden : .visible, for: .tabBar)
            }
            .onAppear{
                vehicle = vehicles.first(where: {$0.isActive})
                if let object = vehicle {
                    locationDataManager.odometer = object.odometer ?? 0
                    locationDataManager.trip = object.trip ?? 0
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
