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
                Text("Dec 31, " + String(calenderYear))
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
