//
//  GarageView.swift
//  Map
//
//  Created by saj panchal on 2024-07-17.
//

import SwiftUI

struct GarageView: View {
    @FetchRequest(entity:Vehicle.entity(), sortDescriptors:[]) var vehicles: FetchedResults<Vehicle>
    @FetchRequest(entity:Settings.entity(), sortDescriptors:[]) var setting: FetchedResults<Settings>
    @Environment(\.managedObjectContext) private var viewContext
    @StateObject var locationDataManager: LocationDataManager
    @State var carText = ""
    @Binding var showGarage: Bool
    var body: some View {
        NavigationStack {
            List {
                ForEach(vehicles, id: \.self.uniqueID) { vehicle in
                    NavigationLink(destination: UpdateVehicleView(locationDataManager: locationDataManager, settings: setting.first!, showGarage: $showGarage, vehicle: vehicle), label: {
                        VehicleListItem(v: vehicles.firstIndex(of: vehicle) ?? 0)
                 })
                }
                .onDelete(perform: { indexSet in
                    for i in indexSet {
                        let vehicle = vehicles[i]
                        viewContext.delete(vehicle)
                        Vehicle.saveContext(viewContext: viewContext)
                    }
                })
            }
            .padding(.top,20)
            .navigationTitle("Your Auto Garage")
        }
    
    }
}

#Preview {
    GarageView(locationDataManager: LocationDataManager(), showGarage: .constant(false))
}
