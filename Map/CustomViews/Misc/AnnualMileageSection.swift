//
//  AnnualMileageSection.swift
//  Map
//
//  Created by saj panchal on 2025-01-15.
//

import SwiftUI

struct AnnualMileageSection: View {
    var annualTrip: Double
    var distanceUnit: String
    var fuelConsumed: Double
    var fuelUnit: String
    var annualMileage: Double
    var efficiencyUnit: String
    var calendarYear: String
    var body: some View {
        Section {
                VStack {
                    HStack {
                        Text("Distance Travelled")
                        Spacer()
                        Text(String(format: "%.1f", annualTrip) + " " + distanceUnit)
                    }
                    .padding(.horizontal)
                    Divider()
                    HStack {
                        Text("Fuel Consumption")
                        Spacer()
                        Text(String(format: "%.1f", fuelConsumed)  + " " + fuelUnit)
                    }
                    .padding(.horizontal)
                    Divider()
                    HStack {
                        Text("Fuel Mileage")
                        Spacer()
                        Text(String(format: "%.2f", annualMileage))
                        Text(efficiencyUnit)
                    }
                    .padding(.horizontal)
                }
            
            
        }
        header: {
            Text("Annual Mileage Details").fontWeight(.bold)
        }
        footer: {
            Text("(Based on Fuelling records in " + calendarYear + ")").fontWeight(.regular)
        }
    }
}

#Preview {
    AnnualMileageSection(annualTrip: 0.0, distanceUnit: "", fuelConsumed: 0.0, fuelUnit: "", annualMileage: 0.0, efficiencyUnit: "", calendarYear: "")
}
