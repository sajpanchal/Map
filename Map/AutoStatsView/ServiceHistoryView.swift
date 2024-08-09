//
//  ServiceHistoryView.swift
//  Map
//
//  Created by saj panchal on 2024-06-20.
//

import SwiftUI

struct ServiceHistoryView: View {
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
               
                ForEach(vehicle.getServices, id: \.self.uniqueID) { autoService in
                    NavigationLink(destination: UpdateServiceEntry(serviceEntry: autoService), label:  {
                        VStack {
                            Text(autoService.date!.formatted(date: .long, time: .omitted))
                                .font(.system(size: 14))
                                .fontWeight(.black)
                                .foregroundStyle(bgMode == .dark ? Color(UIColor.systemGray2) : Color(UIColor.darkGray))
                            Spacer()
                            HStack {
                                VStack {
                                    Text("Auto Shop")
                                        .font(.system(size: 12, weight: .semibold))
                                        .foregroundStyle(bgMode == .dark ? Color(UIColor.systemGray2) : Color(UIColor.darkGray))
                                    Text(autoService.location!)
                                        .font(.system(size: 16, weight: .bold))
                                        .foregroundStyle(redColor)
                                }
                               
                                Spacer()
                                VStack {
                                    Text("Cost")
                                        .font(.system(size: 12, weight: .semibold))
                                        .foregroundStyle(bgMode == .dark ? Color(UIColor.systemGray2) : Color(UIColor.darkGray))
                                    Text("$" + String(format:"%.2f",autoService.cost))
                                        .font(.system(size: 16, weight: .bold))
                                        .foregroundStyle(greenColor)
                                }
                           
                            }
                           Spacer()
                            Text("Updated on: " + autoService.getTimeStamp)
                                .font(.system(size: 8))
                                .foregroundStyle(bgMode == .dark ? Color(UIColor.systemGray2) : Color(UIColor.darkGray))
                        }
                        .padding(.horizontal,10)
                        .padding(.vertical, 5)
                    })
                      
                }
                .onDelete { indexSet in
                    for i in indexSet {
                        let service = vehicle.getServices[i]
                        vehicle.removeFromServices(service)
                        vehicle.serviceCost -= service.cost
                        Vehicle.saveContext(viewContext: viewContext)
                    }
                }
            }
            .navigationTitle("Service History")
        }
    }
}

#Preview {
    ServiceHistoryView(vehicle: Vehicle())
}
