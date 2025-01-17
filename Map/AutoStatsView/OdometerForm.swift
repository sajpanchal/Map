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
    @FetchRequest(entity: AutoSummary.entity(), sortDescriptors: []) var reports: FetchedResults<AutoSummary>
    ///fetch request for entity of settings which will store the fetchedResults of settings in this variable
    @FetchRequest(entity:Settings.entity(), sortDescriptors:[]) var settings: FetchedResults<Settings>
    ///environment variable of managedObjectContext that tracks changes to the instances of core data entities.
    @Environment(\.managedObjectContext) private var viewContext
    ///calendaryear
    var calenderYear: Int
    ///binding variable for odometer Start readings
    @Binding var odometerStart: Double
    ///binding variable for odometer Stop readings
    @Binding var odometerEnd: Double
    ///binding variable for reports array index.
    @Binding var reportIndex: Int?
    var body: some View {
        ///form to edit odometer settings.
        Form {
            ///section with title for odometer start.
            Section("Odometer readings on Jan 01, "+(String(calenderYear))) {
                ///textfield with odometer start binding variable as value and format set as a number
                TextField("Enter", value: $odometerStart, format: .number)
            }
            ///textfield with odometer stop binding variable as value and format set as,a number
            Section("Odometer readings on Dec 31, "+(String(calenderYear))) {
                TextField("Enter", value: $odometerEnd, format: .number)
            }
            ///form submit button
            Button {
                ///check if the report index is not nil else dismiss the view.
                guard let index = reportIndex else {
                    dismiss()
                    print("no index found")
                    return
                }
                ///if distance unit in settings is set to km
                if settings.first!.distanceUnit == "km" {
                    ///store the updated odometer start readings at the given index in the reports array.
                    reports[index].odometerStart = odometerStart
                    ///store the updated odometer stop readings at the given index in the reports array.
                    reports[index].odometerEnd = odometerEnd
                }
                ///if distance unit in settings is set to mi
                else {
                    ///store the updated odometer start readings at the given index in the reports array in miles.
                    reports[index].odometerStartMiles = odometerStart
                    ///store the updated odometer stop readings at the given index in the reports array in miles.
                    reports[index].odometerEndMiles = odometerEnd
                }
                ///save the view context
                AutoSummary.saveContext(viewContext: viewContext)
                ///dismiss this view.
                dismiss()
            }
            ///button label
            label: {
                Text("Save")
            }
        }
    }
}

#Preview {
    OdometerForm(calenderYear: 2023, odometerStart: .constant(0), odometerEnd: .constant(0), reportIndex: .constant(0))
}
