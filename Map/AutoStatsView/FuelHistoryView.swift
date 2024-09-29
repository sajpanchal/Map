//
//  FuelHistoryView.swift
//  Map
//
//  Created by saj panchal on 2024-06-20.
//

import SwiftUI

struct FuelHistoryView: View {
    @FetchRequest(entity: Settings.entity(), sortDescriptors:[]) var settings: FetchedResults<Settings>
    @Environment(\.colorScheme) var bgMode: ColorScheme
    @Environment(\.managedObjectContext) private var viewContext

    var vehicle: Vehicle
    var body: some View {
        NavigationStack {
            List {
                ForEach(vehicle.getFuellings, id:\.self.uniqueID) { fuelData in
                    NavigationLink(destination: UpdateFuelEntry(fuelEntry: fuelData), label: {
                            VStack {
                                Text((fuelData.date!.formatted(date: .long, time: .omitted)))
                                    .font(.system(size: 12))
                                    .fontWeight(.black)
                                    .foregroundStyle(bgMode == .dark ? Color(UIColor.systemGray2) : Color(UIColor.darkGray))
                                    Spacer()
                                HStack {
                                    VStack {
                                        Text("Fuel Station")
                                            .font(.system(size: 10, weight: .semibold))
                                            .foregroundStyle(bgMode == .dark ? Color(UIColor.systemGray2) : Color(UIColor.darkGray))
                                        Text(fuelData.location!)
                                            .font(.system(size: 14, weight: .bold))
                                            .foregroundStyle(Color(AppColors.invertBlueColor.rawValue))
                                           
                                    }
                                  
                                   
                                    Spacer()
                                    VStack {
                                        Text("Volume")
                                            .font(.system(size: 12, weight: .semibold))
                                            .foregroundStyle(bgMode == .dark ? Color(UIColor.systemGray2) : Color(UIColor.darkGray))
                                        if settings.first!.fuelVolumeUnit == "Litre" {
                                            Text(String(format:"%.2f",fuelData.volume) + " L")
                                                .font(.system(size: 14, weight: .bold))
                                                .foregroundStyle(Color(AppColors.invertYellow.rawValue))
                                        }
                                        else {
                                            Text(String(format:"%.2f",fuelData.getVolumeGallons) + " GL")
                                                .font(.system(size: 14, weight: .bold))
                                                .foregroundStyle(Color(AppColors.invertYellow.rawValue))
                                        }
                                       
                                       
                             
                                    }
                                    Spacer()
                                    VStack {
                                        Text("Cost")
                                            .font(.system(size: 10, weight: .semibold))
                                            .foregroundStyle(bgMode == .dark ? Color(UIColor.systemGray2) : Color(UIColor.darkGray))
                                        Text("$" + String(format:"%.2f",fuelData.cost))
                                            .font(.system(size: 14, weight: .bold))
                                            .foregroundStyle(Color(AppColors.invertOrange.rawValue))
                                    }
                                }
                                Spacer()
                                HStack {
                                    Text("Trip Summary")
                                        .font(.system(size: 10, weight: .semibold))
                                        .foregroundStyle(bgMode == .dark ? Color(UIColor.systemGray2) : Color(UIColor.darkGray))
                                    if settings.first!.getDistanceUnit == "km" {
                                        Text(String(format:"%.2f",fuelData.lasttrip) + " km")
                                            .font(.system(size: 14, weight: .bold))
                                            .foregroundStyle(Color(AppColors.invertSky.rawValue))
                                    }
                                    else {
                                        Text(String(format:"%.2f",fuelData.getLastTripMiles) + " miles")
                                            .font(.system(size: 14, weight: .bold))
                                            .foregroundStyle(Color(AppColors.invertSky.rawValue))
                                    }
                                   
                                }
                                Spacer()
                                Text("updated on: " + fuelData.getTimeStamp)
                                    .font(.system(size: 8))
                                    .foregroundStyle(bgMode == .dark ? Color(UIColor.systemGray2) : Color(UIColor.darkGray))
                            }
                          
                            .padding(.vertical, 5)
                        })
                          
                        
                      
                }
                .onDelete { indexSet in
                    for i in indexSet {
                       let fuelling = vehicle.getFuellings[i]
                        vehicle.removeFromFuellings(fuelling)
                        vehicle.fuelCost -= fuelling.cost
                        Vehicle.saveContext(viewContext: viewContext)
                    }
                    
                }
            }
            .navigationTitle("Fuelling History")
        }
      
    }
}

#Preview {
    FuelHistoryView(vehicle: Vehicle())
}
