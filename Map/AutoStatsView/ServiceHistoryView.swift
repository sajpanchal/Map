//
//  ServiceHistoryView.swift
//  Map
//
//  Created by saj panchal on 2024-06-20.
//

import SwiftUI

struct ServiceHistoryView: View {
    @Environment(\.colorScheme) var bgMode: ColorScheme
    @Environment(\.managedObjectContext) private var viewContext
    @Binding var showServiceHistoryView: Bool
    var vehicle: Vehicle
    var body: some View {
        NavigationStack {
          
            List {
               
                ForEach(vehicle.getServices, id: \.self.uniqueID) { autoService in
                    NavigationLink(destination: UpdateServiceEntry(serviceEntry: autoService, showServiceHistoryView: $showServiceHistoryView), label:  {
                        VStack {
                            Text(autoService.date!.formatted(date: .long, time: .omitted))
                                .font(.system(size: 12))
                                .fontWeight(.black)
                                .foregroundStyle(bgMode == .dark ? Color(UIColor.systemGray2) : Color(UIColor.darkGray))
                            Spacer()
                            HStack {
                                VStack {
                                    Text("Auto Shop")
                                        .font(.system(size: 10, weight: .semibold))
                                        .foregroundStyle(bgMode == .dark ? Color(UIColor.systemGray2) : Color(UIColor.darkGray))
                                    Text(autoService.location!)
                                        .font(.system(size: 16, weight: .bold))
                                        .foregroundStyle(Color(AppColors.invertBlueColor.rawValue))
                                }
                               
                                Spacer()
                                VStack {
                                    Text("Cost")
                                        .font(.system(size: 10, weight: .semibold))
                                        .foregroundStyle(bgMode == .dark ? Color(UIColor.systemGray2) : Color(UIColor.darkGray))
                                    Text("$" + String(format:"%.2f",autoService.cost))
                                        .font(.system(size: 14, weight: .bold))
                                        .foregroundStyle(Color(AppColors.invertRed.rawValue))
                                }
                           
                            }
                           Spacer()
                            Text("Updated on: " + autoService.getTimeStamp)
                                .font(.system(size: 8))
                                .foregroundStyle(bgMode == .dark ? Color(UIColor.systemGray2) : Color(UIColor.darkGray))
                        }
                       
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
    ServiceHistoryView(showServiceHistoryView: .constant(false), vehicle: Vehicle())
}
