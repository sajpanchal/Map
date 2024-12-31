//
//  OdometerForm.swift
//  Map
//
//  Created by saj panchal on 2024-12-29.
//

import SwiftUI

struct OdometerForm: View {
    @Environment(\.dismiss) var dismiss
    @FetchRequest(entity: AutoSummary.entity(), sortDescriptors: []) var reports: FetchedResults<AutoSummary>
    @FetchRequest(entity:Settings.entity(), sortDescriptors:[]) var settings: FetchedResults<Settings>
    @Environment(\.managedObjectContext) private var viewContext
    var calenderYear: Int
    @Binding var odometerStart: Double
    @Binding var odometerEnd: Double
    @Binding var reportIndex: Int?
    var body: some View {
       
            Form {
                Section("Odometer readings on Jan 01, "+(String(calenderYear))) {
                    TextField("Enter", value: $odometerStart, format: .number)
                }
                Section("Odometer readings on Dec 31, "+(String(calenderYear))) {
                    TextField("Enter", value: $odometerEnd, format: .number)
                }
                Button {
                    guard let index = reportIndex else {
                        dismiss()
                        return
                    }
                    if settings.first!.distanceUnit == "km" {
                        reports[index].odometerStart = odometerStart
                        reports[index].odometerEnd = odometerEnd
                    }
                    else {
                        reports[index].odometerStartMiles = odometerStart
                        reports[index].odometerEndMiles = odometerEnd
                    }
                    AutoSummary.saveContext(viewContext: viewContext)
                    dismiss()
                } label: {
                    Text("Save")
                }
            }
        
        
    }
}

#Preview {
    OdometerForm(calenderYear: 2023, odometerStart: .constant(0), odometerEnd: .constant(0), reportIndex: .constant(0))
}
