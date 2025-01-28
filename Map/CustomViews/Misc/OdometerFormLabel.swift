//
//  OdometerFormLabel.swift
//  Map
//
//  Created by saj panchal on 2025-01-15.
//

import SwiftUI

struct OdometerFormLabel: View {
    var calenderYear: Int
    var odometerStart: Double
    var odometerEnd: Double
    var unit: String
    ///computed property will compute the code and return the processed result as its value.
    var todaysDate: String {
        ///get todays date
        let date = Date()
        ///get the year component from today's date.
        let year = Calendar.current.component(.year, from: date)
        ///if today's date is not greater than the calenderYear to which odometer summary is requested
        if year <= calenderYear {
            ///format the date in abbreviated date format (Jan 01, 2025) with time omitted.
            let today = date.formatted(date: .abbreviated, time: .omitted)
           /// return the formatted date
            return today
        }
        ///if today's date belongs to next year or so on.
        else {
            ///return the last date of a given year as date string.
            return "Dec 31, " + String(calenderYear)
        }
    }
    var body: some View {
        VStack {
            HStack {
                Text("Jan 01, " + String(calenderYear))
                Spacer()
                Text(String(format: "%.0f",odometerStart) + " " + unit)
            }
            .padding(.horizontal)
            Divider()
            HStack {
                Text(todaysDate)
                Spacer()
                Text(String(format: "%.0f",odometerEnd) + " " + unit)
            }
            .padding(.horizontal)
        }
    }
}

#Preview {
    OdometerFormLabel(calenderYear: 2025, odometerStart: 0, odometerEnd: 0, unit: "n/a")
}
