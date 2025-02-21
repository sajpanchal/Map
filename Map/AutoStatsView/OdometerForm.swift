//
//  OdometerForm.swift
//  Map
//
//  Created by saj panchal on 2024-12-29.
//

import SwiftUI

struct OdometerForm: View {
    ///environment variable to dismiss this swiftui view.
    @Environment(\.dismiss) var dismiss
    ///fetch request for entity of autosummary which will store the fetchedResults of autosummary in this variable
   // @FetchRequest(entity: AutoSummary.entity(), sortDescriptors: []) var reports: FetchedResults<AutoSummary>
    ///fetch request for entity of settings which will store the fetchedResults of settings in this variable
  //  @FetchRequest(entity:Vehicle.entity(), sortDescriptors:[]) var vehicles: FetchedResults<Vehicle>
    ///environment variable of managedObjectContext that tracks changes to the instances of core data entities.
    @Environment(\.managedObjectContext) private var viewContext
    ///calendaryear
    var calenderYear: Int = 0
    var distanceUnit: String = ""
    ///binding variable for odometer Start readings
    @Binding var odometerStart: Double
    ///binding variable for odometer Stop readings
    @Binding var odometerEnd: Double
    ///binding variable for reports array index.
 // var reportIndex: Int = 0
    var vehicleIndex: Int = 0
    
    var todaysDate: String {
        let date = Date()
        let year = Calendar.current.component(.year, from: date)
        if year <= calenderYear {
            let today = date.formatted(date: .abbreviated, time: .omitted)
            return today
        }
        else {
            return "Dec 31, " + String(calenderYear)
        }
    }
    
    var body: some View {
        ///form to edit odometer settings.
      //  if let activeVehicle = vehicles.first(where: {$0.isActive}) {
       //     if let thisSettings = activeVehicle.settings {
                Form {
                    ///section with title for odometer start.
                    Section("Odometer readings on Jan 01, "+(String(calenderYear))) {
                        ///textfield with odometer start binding variable as value and format set as a number
                        TextField("Enter", value: $odometerStart, format: .number)
                        if !isEntryValid() {
                            Text("Odometer start can't be greater than Odometer end!")
                                .font(.caption2)
                                .foregroundStyle(.red)
                        }
                    }
                    ///textfield with odometer stop binding variable as value and format set as,a number
                    Section("Odometer readings on " + todaysDate) {
                        TextField("Enter", value: $odometerEnd, format: .number)
                        if !isEntryValid() {
                            Text("Odometer end can't be less than Odometer start!")
                                .font(.caption2)
                                .foregroundStyle(.red)
                        }
                    }
                    ///form submit button
                    Button {
                        ///check if the report index is not nil else dismiss the view.
                       
                        if !isEntryValid() {
                            return
                        }
                      
                        AutoSummary.updateReport(viewContext: viewContext, distanceUnit: distanceUnit, year: calenderYear, vehicleIndex: vehicleIndex, odometerStart: Int(odometerStart), odometerEnd: Int(odometerEnd))
                        if calenderYear == Calendar.current.component(.year, from: Date()) {
                            Vehicle.updateOdometer(viewContext: viewContext, vehicleIndex: vehicleIndex, odometerEnd: odometerEnd, distanceUnit: distanceUnit)
                        }
                        ///dismiss this view.
                        dismiss()
                    }
                    ///button label
                    label: {
                        Text("Save")
                    }
                }
            }
      //  }
      
   // }//
    func isEntryValid() -> Bool {
        if odometerStart > odometerEnd {
            return false
        }
        else {
            return true
        }
    }
}

#Preview {
    OdometerForm(calenderYear: 2023, distanceUnit: "km", odometerStart: .constant(0), odometerEnd: .constant(0), vehicleIndex: 0)
}
