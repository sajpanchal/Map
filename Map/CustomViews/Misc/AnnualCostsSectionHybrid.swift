//
//  AnnualCostsSectionHybrid.swift
//  Map
//
//  Created by saj panchal on 2025-01-15.
//

import SwiftUI

struct AnnualCostsSectionHybrid: View {
    var annualFuelCost: Double
    var annualFuelCostEV: Double
    var calenderYear: String
    var annualServiceCost: Double
   
    var body: some View {
        Section {
                VStack {
                    HStack {
                        Text("Fuel Cost")
                        Spacer()
                        Text(annualFuelCost, format: .currency(code: Locale.current.currency?.identifier ?? "USD"))
                    }
                    .padding(.horizontal)
                }
        }
        header:  {
            Text("Annual Fuel Costs").fontWeight(.bold)
          
        }
        footer: {
            Text("(Based on Fuelling records " + calenderYear + ")").fontWeight(.regular)
        }
        Section {
            VStack {
                HStack {
                    Text("Fuel Cost")
                    Spacer()
                    Text(annualFuelCostEV, format: .currency(code: Locale.current.currency?.identifier ?? "USD"))
                }
                .padding(.horizontal)
               
            }
        }
        header:  {
            Text("Annual Fuel Costs (EV Mode)").fontWeight(.bold)
        }
        footer: {
            Text("(Based on Fuelling records " + calenderYear + ")").fontWeight(.regular)
        }
        Section {
            HStack {
                Text("Service Cost")
                Spacer()
                Text(annualServiceCost, format: .currency(code: Locale.current.currency?.identifier ?? "USD"))
            }
            .padding(.horizontal)
        }
        header:  {
            Text("Annual Service Costs").fontWeight(.bold)
        }
        footer: {
            Text("(Based on Service records " + calenderYear + ")").fontWeight(.regular)
        }
    }
}

#Preview {
    AnnualCostsSectionHybrid(annualFuelCost: 0.0, annualFuelCostEV: 0.0, calenderYear: "", annualServiceCost: 0.0)
}
