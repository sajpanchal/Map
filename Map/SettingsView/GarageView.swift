//
//  GarageView.swift
//  Map
//
//  Created by saj panchal on 2024-07-17.
//

import SwiftUI

struct GarageView: View {
    @FetchRequest(entity:Vehicle.entity(), sortDescriptors:[NSSortDescriptor(keyPath: \Vehicle.isActive, ascending: false)]) var vehicles: FetchedResults<Vehicle>
    @FetchRequest(entity:Settings.entity(), sortDescriptors:[]) var setting: FetchedResults<Settings>
    @Environment(\.managedObjectContext) private var viewContext
    @StateObject var locationDataManager: LocationDataManager
    @State var carText = ""
    @Binding var showGarage: Bool
    var skyColor = Color(red:0.031, green:0.739, blue:0.861)
    var body: some View {
        NavigationStack {
            List {
                ForEach(vehicles, id: \.self.uniqueID) { vehicle in
                    NavigationLink(destination: UpdateVehicleView(locationDataManager: locationDataManager, settings: setting.first!, showGarage: $showGarage, vehicle: vehicle), label: {                    
                        VStack {
                            Text(vehicle.getVehicleText + " " + vehicle.getFuelEngine)
                                .fontWeight(.bold)
                                .font(Font.system(size: 18))
                                .foregroundStyle(skyColor)
                            Text(vehicle.getYear)
                                .fontWeight(.semibold)
                                .font(Font.system(size: 14))
                                .foregroundStyle(Color.gray)
                        }
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
