//
//  FuelHistoryView.swift
//  Map
//
//  Created by saj panchal on 2024-06-20.
//

import SwiftUI

struct FuelHistoryView: View {
    @Environment (\.colorScheme) var bgMode: ColorScheme
    @Environment(\.managedObjectContext) private var viewContext
    var greenColor = Color(red: 0.257, green: 0.756, blue: 0.346)
    var lightGreenColor = Color(red: 0.723, green: 1.0, blue: 0.856)
    var skyColor = Color(red:0.031, green:0.739, blue:0.861)
    var lightSkyColor = Color(red:0.657, green:0.961, blue: 1.0)
    var redColor = Color(red:0.861, green: 0.194, blue:0.0)
    var lightRedColor = Color(red:1.0, green:0.654, blue:0.663)
    var yellowColor = Color(red:1.0, green: 0.80, blue: 0.0)
    var lightYellowColor = Color(red:0.938, green: 1.0, blue: 0.84)
    var vehicle: Vehicle
    var body: some View {
        NavigationStack {
            List {
                ForEach(vehicle.getFuellings, id:\.self.uniqueID) { fuelData in
                    NavigationLink(destination: UpdateFuelEntry(fuelEntry: fuelData), label: {
                            VStack {
                                Text((fuelData.date!.formatted(date: .long, time: .omitted)))
                                    .font(.system(size: 14))
                                    .fontWeight(.black)
                                    .foregroundStyle(bgMode == .dark ? Color(UIColor.systemGray2) : Color(UIColor.darkGray))
                                    Spacer()
                                HStack {
                                    VStack {
                                        Text("Fuel Station")
                                            .font(.system(size: 12, weight: .semibold))
                                            .foregroundStyle(bgMode == .dark ? Color(UIColor.systemGray2) : Color(UIColor.darkGray))
                                        Text(fuelData.location!)
                                            .font(.system(size: 16, weight: .bold))
                                            .foregroundStyle(redColor)
                                           
                                    }
                                    .frame(width: 100)
                                   
                                    Spacer()
                                    VStack {
                                        Text("Volume")
                                            .font(.system(size: 12, weight: .semibold))
                                            .foregroundStyle(bgMode == .dark ? Color(UIColor.systemGray2) : Color(UIColor.darkGray))
                                        Text(String(format:"%.2f",fuelData.volume) + " L")
                                            .font(.system(size: 16, weight: .bold))
                                            .foregroundStyle(yellowColor)
                                       
                             
                                    }
                                    Spacer()
                                    VStack {
                                        Text("Cost")
                                            .font(.system(size: 12, weight: .semibold))
                                            .foregroundStyle(bgMode == .dark ? Color(UIColor.systemGray2) : Color(UIColor.darkGray))
                                        Text("$" + String(format:"%.2f",fuelData.cost))
                                            .font(.system(size: 16, weight: .bold))
                                            .foregroundStyle(greenColor)
                                    }
                                }
                                Spacer()
                                HStack {
                                    Text("Trip Summary")
                                        .font(.system(size: 12, weight: .semibold))
                                        .foregroundStyle(bgMode == .dark ? Color(UIColor.systemGray2) : Color(UIColor.darkGray))
                                    Text(String(format:"%.2f",fuelData.lasttrip) + " km")
                                        .font(.system(size: 16, weight: .bold))
                                        .foregroundStyle(skyColor)
                                }
                                Spacer()
                                Text("updated on: " + fuelData.getTimeStamp)
                                    .font(.system(size: 8))
                                    .foregroundStyle(bgMode == .dark ? Color(UIColor.systemGray2) : Color(UIColor.darkGray))
                            }
                            .padding(.horizontal,10)
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
