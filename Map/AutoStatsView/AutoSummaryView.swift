//
//  AutoSummaryView.swift
//  Map
//
//  Created by saj panchal on 2024-12-29.
//

import SwiftUI

struct AutoSummaryView: View {
    @FetchRequest(entity:Settings.entity(), sortDescriptors:[]) var settings: FetchedResults<Settings>
    @State var autoSummary: AutoSummary = AutoSummary()
    @State var odometerEnd: Double = 0.0
    @State var odometerStart: Double = 0.0
    @State var odometerEndMiles: Double = 0.0
    @State var odometerStartMiles: Double = 0.0
    @State var annualTrip: Double = 12.233445
    @State var fuelConsumed: Double = 0.0
    @State var annualMileage: Double = 0.0
    @State var annualFuelCost: Double = 0.0
    @State var annualServiceCost: Double = 0.0
    @State var annualTripEV: Double = 0.0
    @State var fuelConsumedEV: Double = 0.0
    @State var annualMileageEV: Double = 0.0
    @State var annualFuelCostEV: Double = 0.0
    @State var annualServiceCostEV: Double = 0.0
    @State var engineType: EngineType = .Hybrid
    @State var calenderYear: Int = 2024
    @State var reportIndex: Int?
    var currency = ""
    var body: some View {
       
            Group {
               
                HStack {
                    Spacer()
                    HStack {
                        Text("Honda Civic")
                        Text("2018")
                    }
                }
                .padding()
                
                List {
                    if settings.first!.distanceUnit == "km" {
                        Section {
                            NavigationLink {
                                OdometerForm(calenderYear: calenderYear, odometerStart: $odometerStart, odometerEnd: $odometerEnd, reportIndex: $reportIndex)
                                
                            } label : {
                                VStack {
                                    HStack {
                                        Text("Jan 01, " + String(calenderYear))
                                        Spacer()
                                        Text(String(format: "%.0f",odometerStart) + " km")
                                    }
                                    .padding(.horizontal)
                                    Divider()
                                    HStack {
                                        Text("Dec 31, " + String(calenderYear))
                                        Spacer()
                                        Text(String(format: "%.0f",odometerEnd) + " km")
                                    }
                                    .padding(.horizontal)
                                }
                            }
                            
                        }
                        header:  {
                            Text("Odometer Readings").fontWeight(.bold)
                        }
                    }
                    else {
                        Section {
                            NavigationLink {
                                OdometerForm(calenderYear: calenderYear, odometerStart: $odometerStartMiles, odometerEnd: $odometerEndMiles, reportIndex: $reportIndex)
                                
                            } label : {
                                VStack {
                                    HStack {
                                        Text("Jan 01, " + String(calenderYear))
                                        Spacer()
                                        Text(String(format: "%.0f",odometerStartMiles) + " mi")
                                    }
                                    .padding(.horizontal)
                                    Divider()
                                    HStack {
                                        Text("Dec 31, " + String(calenderYear))
                                        Spacer()
                                        Text(String(format: "%.0f",odometerEndMiles) + " mi")
                                    }
                                    .padding(.horizontal)
                                }
                            }
                            
                        }
                        header:  {
                            Text("Odometer Readings").fontWeight(.bold)
                        }
                    }
                    if engineType != .Hybrid {
                        Section {
                                             
                                VStack {
                                    HStack {
                                        Text("Distance Traveled")
                                        Spacer()
                                        Text(String(format: "%.1f",engineType == .Gas ? annualTrip: annualTripEV) + " " + settings.first!.getDistanceUnit)
                                    }
                                    .padding(.horizontal)
                                    Divider()
                                    HStack {
                                        Text("Fuel Consumption")
                                        Spacer()
                                        Text(String(format: "%.1f",engineType == .Gas ? fuelConsumed: fuelConsumedEV)  + " " + (engineType == .Gas ? settings.first!.getFuelVolumeUnit : "kwh"))
                                    }
                                    .padding(.horizontal)
                                    Divider()
                                    HStack {
                                        Text("Fuel Mileage")
                                        Spacer()
                                        Text(String(format: "%.2f",engineType == .Gas ? annualMileage: annualMileageEV))
                                        Text(settings.first!.getFuelEfficiencyUnit)
                                    }
                                    .padding(.horizontal)
                                }
                            
                            
                        }
                        header:  {
                            Text("Annual Mileage Details").fontWeight(.bold)
                        }
                        footer: {
                            Text("(Based on Fuelling records in " + autoSummary.getCalenderYear + ")").fontWeight(.regular)
                        }
                    }
                    else {
                       Section {
                                VStack {
                                    HStack {
                                        Text("Distance Travelled")
                                        Spacer()
                                        Text(String(format: "%.1f",annualTrip) + " " + settings.first!.getDistanceUnit)
                                    }
                                    .padding(.horizontal)
                                    Divider()
                                    HStack {
                                        Text("Fuel Consumption")
                                        Spacer()
                                        Text(String(format: "%.1f",fuelConsumed) + " " + (settings.first!.getFuelVolumeUnit == "%" ? "L" : settings.first!.getFuelVolumeUnit))
                                    }
                                    .padding(.horizontal)
                                    Divider()
                                    HStack {
                                        Text("Fuel Mileage")
                                        Spacer()
                                        Text(String(format: "%.2f",annualMileage) + " " + (settings.first!.getFuelVolumeUnit == "%" ? "km/L" : settings.first!.getFuelEfficiencyUnit))
                                    }
                                    .padding(.horizontal)
                                }
                            
                            
                        }
                        header:  {
                            Text("Annual Mileage Details").fontWeight(.bold)
                        }
                        footer: {
                            Text("(Based on Fuelling records " + autoSummary.getCalenderYear + ")").fontWeight(.regular)
                        }
                        Section {

                                VStack {
                                    HStack {
                                        Text("Distance Travelled")
                                        Spacer()
                                        Text(String(format: "%.1f",annualTripEV) + " " + settings.first!.getDistanceUnit)
                                    }
                                    .padding(.horizontal)
                                    Divider()
                                    HStack {
                                        Text("Fuel Consumption")
                                        Spacer()
                                        Text(String(format: "%.1f",fuelConsumedEV) + " kwh")
                                    }
                                    .padding(.horizontal)
                                    Divider()
                                    HStack {
                                        Text("Fuel Mileage")
                                        Spacer()
                                        Text(String(format: "%.2f",annualMileageEV) + " " + (settings.first!.getFuelVolumeUnit != "%" ? "km/kwh" :settings.first!.getFuelEfficiencyUnit))
                                    }
                                    .padding(.horizontal)
                                }
                            
                            
                        }
                        header:  {
                            Text("Annual Mileage Details").fontWeight(.bold)
                        }
                        footer: {
                            Text("(Based on Fuelling records " + autoSummary.getCalenderYear + ")").fontWeight(.regular)
                        }
                    }
                    if engineType != .Hybrid {
                        Section {
                                VStack {
                                    HStack {
                                        Text("Fuel Cost")
                                        Spacer()
                                        Text(engineType == .Gas ? annualFuelCost: annualFuelCostEV, format:.currency(code: Locale.current.currency?.identifier ?? "USD"))
                                    }
                                    .padding(.horizontal)
                                    Divider()
                                    HStack {
                                        Text("Service Cost")
                                        Spacer()
                                        Text(engineType == .Gas ? annualServiceCost : annualServiceCostEV, format:.currency(code: Locale.current.currency?.identifier ?? "USD"))
                                    }
                                    .padding(.horizontal)
                                   
                                }
                            
                        }
                        header:  {
                            Text("Annual Costs").fontWeight(.bold)
                        }
                        footer: {
                            Text("(Based on Fuelling & Service records " + autoSummary.getCalenderYear + ")").fontWeight(.regular)
                        }
                    }
                    else {
                        Section {
                                VStack {
                                    HStack {
                                        Text("Fuel Cost")
                                        Spacer()
                                        Text(annualFuelCost, format: .currency(code: Locale.current.currency?.identifier ?? "USD"))
                                    }
                                    .padding(.horizontal)
                                    Divider()
                                    HStack {
                                        Text("Service Cost")
                                        Spacer()
                                        Text(annualServiceCost, format: .currency(code: Locale.current.currency?.identifier ?? "USD"))
                                    }
                                    .padding(.horizontal)
                                }
                        }
                        header:  {
                            Text("Annual Costs").fontWeight(.bold)
                          
                        }
                        footer: {
                            Text("(Based on Fuelling & Service records " + autoSummary.getCalenderYear + ")").fontWeight(.regular)
                        }
                        Section {
                            
                            VStack {
                                HStack {
                                    Text("Fuel Cost")
                                    Spacer()
                                    Text(annualFuelCostEV, format: .currency(code: Locale.current.currency?.identifier ?? "USD"))
                                }
                                .padding(.horizontal)
                                Divider()
                                HStack {
                                    Text("Service Cost")
                                    Spacer()
                                    Text(annualServiceCostEV, format: .currency(code: Locale.current.currency?.identifier ?? "USD"))
                                }
                                .padding(.horizontal)
                            }
                        
                           
                        }
                        header:  {
                            Text("Annual Costs").fontWeight(.bold)
                          
                        }
                        footer: {
                            Text("(Based on Fuelling & Service records " + autoSummary.getCalenderYear + ")").fontWeight(.regular)
                        }
                    }
                  
                }
                .onAppear {
                
                    guard let thisSettings = settings.first else {
                        return
                    }
                   
                    engineType = EngineType(rawValue: thisSettings.getAutoEngineType) ?? .Gas
                    odometerStart = autoSummary.odometerStart
                    odometerEnd = autoSummary.odometerEnd
                    odometerStartMiles = autoSummary.odometerStartMiles
                    odometerEndMiles = autoSummary.odometerEndMiles
                    annualTrip = thisSettings.distanceUnit == "km" ? autoSummary.annualTrip : autoSummary.annualTripMiles
                    annualTripEV = thisSettings.distanceUnit == "km" ? autoSummary.annualTripEV : autoSummary.annualTripEVMiles
                    annualMileage = autoSummary.annualMileage
                    annualMileageEV = autoSummary.annualMileageEV
                    annualFuelCost = autoSummary.annualFuelCost
                    annualFuelCostEV = autoSummary.annualfuelCostEV
                    annualServiceCost = autoSummary.annualServiceCost
                    annualServiceCostEV = autoSummary.annualServiceCostEV
                    calenderYear = Int(autoSummary.calenderYear)
                    print("litre:\(autoSummary.litreConsumed)")
                    print("gallon:\(autoSummary.gallonsConsumed)")
                    if thisSettings.getFuelVolumeUnit == "Litre" {
                        fuelConsumed = autoSummary.litreConsumed
                    }
                    else if thisSettings.getFuelVolumeUnit == "Gallon" {
                        fuelConsumed = autoSummary.gallonsConsumed
                    }
                    else {
                        fuelConsumedEV = autoSummary.kwhConsumed
                    }
                      
                
                    
            
                      
                    
                }
                .navigationTitle(String(calenderYear) + " Summary")
            
        }
    }
}
#Preview {
    AutoSummaryView()
}
