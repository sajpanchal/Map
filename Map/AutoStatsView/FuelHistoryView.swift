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
    var yellowColor = Color(red:0.975, green: 0.646, blue: 0.207)
    var lightYellowColor = Color(red:0.938, green: 1.0, blue: 0.781)
    var vehicle: Vehicle
    var body: some View {
        NavigationStack {
            List {
                ForEach(vehicle.getFuellings, id:\.self.uniqueID) { fuelData in
                        Group {
                            VStack {
                                Text((fuelData.date!.formatted(date: .long, time: .omitted)))
                                    .font(.system(size: 15))
                                    .fontWeight(.black)
                                    .foregroundStyle(redColor)
                                   // .foregroundStyle(bgMode == .dark ? Color(UIColor.systemGray2) : Color(UIColor.darkGray))
                                    Spacer()
                                HStack {
                                    VStack {
                                        Text("Fuel Station")
                                            .font(.system(size: 12, weight: .semibold))
                                            .foregroundStyle(bgMode == .dark ? Color(UIColor.systemGray2) : Color(UIColor.darkGray))
                                        Text(fuelData.location!)
                                            .fontWeight(.bold)
                                            .foregroundStyle(skyColor)
                                    }
                                    .frame(width: 100)
                                   
                                    Spacer()
                                    VStack {
                                        Text("Fuel")
                                            .font(.system(size: 12, weight: .semibold))
                                            .foregroundStyle(bgMode == .dark ? Color(UIColor.systemGray2) : Color(UIColor.darkGray))
                                        Text(String(format:"%.2f",fuelData.volume) + " L")
                                            .fontWeight(.bold)
                                            .foregroundStyle(yellowColor)
                                       
                             
                                    }
                                    Spacer()
                                    VStack {
                                        Text("Cost")
                                            .font(.system(size: 12, weight: .semibold))
                                            .foregroundStyle(bgMode == .dark ? Color(UIColor.systemGray2) : Color(UIColor.darkGray))
                                        Text("$" + String(format:"%.2f",fuelData.cost))
                                            .fontWeight(.bold)
                                            .foregroundStyle(greenColor)
                                    }
                                  
                                   
                                }
                               Spacer()
                                
                                Text("timeStamp: " + fuelData.getTimeStamp)
                                    .font(.system(size: 8))
                                    .foregroundStyle(bgMode == .dark ? Color(UIColor.systemGray2) : Color(UIColor.darkGray))
                            }
                            .padding(10)
                        }
                        .onTapGesture {
                          
                    }
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
