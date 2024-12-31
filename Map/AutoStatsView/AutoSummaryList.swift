//
//  AutoSummaryList.swift
//  Map
//
//  Created by saj panchal on 2024-12-27.
//

import SwiftUI

struct AutoSummaryList: View {
    @FetchRequest(entity: Vehicle.entity(), sortDescriptors: []) var vehicles: FetchedResults<Vehicle>
    @FetchRequest(entity: AutoSummary.entity(), sortDescriptors: []) var reports: FetchedResults<AutoSummary>
    var body: some View {
        NavigationStack {
            if let vehicle = vehicles.first(where: {$0.isActive}) {
              
                List {
                    ForEach(vehicle.getReports) { entry in
                        NavigationLink {
                            AutoSummaryView(autoSummary: entry, reportIndex: reports.firstIndex(of: entry))
                        }
                        label: {
                            Text(entry.getCalenderYear + " Auto Summary")
                        }                       
                    }
                }
                .onAppear {
                    if vehicle.getReports.isEmpty {
                        print("empty")
                       
                        print("vehicleID:\(vehicle.objectID)")
                        print("vehicleName:\(vehicle.getVehicleText)")
                    }
                    else {
                        for i in vehicle.getReports {
                            print(i.calenderYear)
                            print(i.annualTrip)
                            
                        }
                    }
                }
                .navigationTitle("Auto Summary History")
            }
            
        }
        
    }
}

#Preview {
    AutoSummaryList()
}
