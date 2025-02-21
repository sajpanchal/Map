//
//  AutoSummaryList.swift
//  Map
//
//  Created by saj panchal on 2024-12-27.
//

import SwiftUI

struct AutoSummaryList: View {
    ///environment variable dismiss is used to dismiss this view on execution.
    @Environment(\.dismiss) var dismiss
    ///environment variable managedObjectContext is used to track changes in the instances of core data entities.
    @Environment(\.managedObjectContext) private var viewContext
    ///state object locationdatamanager
    @StateObject var locationDataManager: LocationDataManager
    @FetchRequest(entity: Vehicle.entity(), sortDescriptors: []) var vehicles: FetchedResults<Vehicle>
    @FetchRequest(entity: AutoSummary.entity(), sortDescriptors: []) var reports: FetchedResults<AutoSummary>
    @FetchRequest(entity:Settings.entity(), sortDescriptors:[]) var settings: FetchedResults<Settings>
    
    var body: some View {
        NavigationStack {
            ///get the first vehicle instance from vehicles entity which is active
            if let vehicle = vehicles.first(where: {$0.isActive}) {
                ///enclose the navigation links in a list view.
                List {
                    ///iterate through each reports for a given vehicle.
                    ForEach(vehicle.getReports) { entry in
                        ///with desination as AutoSummaryView and label as text view.
                        NavigationLink {
                            ///on tap of the label in a given list item in a list the corresponding autosummary view for that item will appear.
                            AutoSummaryView(autoSummary: entry)
                        }
                        ///label is the view to be displayed for a given navigation link.
                        label: {
                            ///here it is a text view that shows autosummary of given Calendar year.
                            Text(entry.getCalenderYear)
                        }                       
                    }
                }
                ////on appear of this swiftui view this modifier will be executed once.
                .onAppear {
                    guard let activeVehicle = vehicles.first(where: {$0.isActive}) else {
                        return
                    }
                    
                    guard let thisSettings = activeVehicle.settings else {
                        return
                    }
                    ///call set fuel efficiency method of autosummary to calculate the fuel efficiency for each year for a given vehicle in a set units.
                    AutoSummary.setFuelEfficiency(viewContext: viewContext, vehicle: vehicle, settings: thisSettings)
                }              
                .navigationTitle("Auto Summary History")
                .navigationBarTitleDisplayMode(.inline)
            }
        }
    }
    
  
}

#Preview {
    AutoSummaryList(locationDataManager: LocationDataManager())
}
