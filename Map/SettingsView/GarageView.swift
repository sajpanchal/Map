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
    var body: some View {
        List {
            ForEach(vehicles, id: \.self.uniqueID) { vehicle in
                
                NavigationLink(destination: UpdateVehicleView(locationDataManager: locationDataManager, settings: setting.first!, vehicle: vehicle), label: {
                 HStack {
                         VStack {
                             Text(vehicle.getVehicleText)
                                 .frame(alignment: .leading)
                                 .font(.subheadline)
                                 .fontWeight(.bold)
                            
                              
                                 Text(String(vehicle.year))
                                 .frame(alignment: .leading)
                                 .font(.system(size: 10))
                                 .fontWeight(.regular)
                             
                                                                     
                                                                   
                         }
                     Spacer()
                         HStack {
                            
                             Image(systemName: "car.fill")
                                 .font(.system(size: 20))
                                 .foregroundStyle(.blue)
                             if vehicle.getFuelEngine == "Gas" {
                                
                                 Image(systemName: "fuelpump.fill")
                                     .font(.system(size: 20))
                                     .foregroundStyle(.yellow)
                             }
                             else if vehicle.getFuelEngine == "EV" {
                                 
                                 Image(systemName: "bolt.batteryblock.fill")
                                     .font(.system(size: 20))
                                     .foregroundStyle(.green)
                                 
                             }
                             else {
                                 
                                 Image(systemName: "fuelpump.fill")
                                     .font(.system(size: 20))
                                     .foregroundStyle(.yellow)
                             
                                 Image(systemName: "bolt.batteryblock.fill")
                                     .font(.system(size: 20))
                                     .foregroundStyle(.green)
                             }
                           
                         }
                        
                        
                         
                       
                     
                    
                 }
                 .onAppear {
                    // carText = vehicle.getMake + " " + vehicle.getModel.replacingOccurrences(of: "_", with: " ") + " " + vehicle.getModel.replacingOccurrences(of: "_", with: " ")
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

#Preview {
    GarageView(locationDataManager: LocationDataManager())
}
