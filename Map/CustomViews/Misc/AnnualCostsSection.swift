//
//  AnnualCostsSection.swift
//  Map
//
//  Created by saj panchal on 2025-01-15.
//

import SwiftUI

struct AnnualCostsSection: View {
    var annualFuelCost: Double
    var annualServiceCost: Double
    var calenderYear: String
    var body: some View {
        Section {
                VStack {
                    HStack {
                        Text("Fuel Cost")
                        Spacer()
                        Text(annualFuelCost, format:.currency(code: Locale.current.currency?.identifier ?? "USD"))
                    }
                    .padding(.horizontal)
                    Divider()
                    HStack {
                        Text("Service Cost")
                        Spacer()
                        Text(annualServiceCost, format:.currency(code: Locale.current.currency?.identifier ?? "USD"))
                    }
                    .padding(.horizontal)
                }
        }
        header:  {
            Text("Annual Costs").fontWeight(.bold)
        }
        footer: {
            Text("(Based on Fuelling & Service records " + calenderYear + ")").fontWeight(.regular)
        }
    }
}

#Preview {
    AnnualCostsSection(annualFuelCost: 0.0, annualServiceCost: 0.0, calenderYear: "")
}
