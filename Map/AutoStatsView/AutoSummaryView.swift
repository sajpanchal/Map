//
//  AutoSummaryView.swift
//  Map
//
//  Created by saj panchal on 2024-12-29.
//

import SwiftUI

struct AutoSummaryView: View {
    ///environment variable dismiss is used to dismiss this SwitUIView  on execution
    @Environment(\.dismiss) var dismiss
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
    ///index number of the autosummary report.
    @State var reportIndex: Int?
    var currency = ""
    
    var body: some View {
        ///grouping the entire view
            Group {
                ///Horizontal stack displays text view aligned to the right.
                HStack {
                    Spacer()
                    ///text view displays current vehicle title.
                    VStack {
                        if let thisSettings = settings.first {
                            Text((thisSettings.vehicle?.getVehicleText ?? "N/A") + "\n" + (thisSettings.vehicle?.getFuelEngine == "Gas" ? "" : (thisSettings.vehicle?.getFuelEngine ?? "")))
                                .fontWeight(.bold)
                                .font(.system(size: 16))
                                .multilineTextAlignment(.trailing)
                        }
                    }
                }
                .padding()
                
                ///list view enclosing the sections.
                List {
                    ///if the settings have the distance unit set to km
                    if settings.first!.distanceUnit == "km" {
                        ///section with header for odometer readings display label and navigation link
                        Section {
                            ///navigation link to the odometerForm swiftuiview to update start and end odometer of a given year
                            NavigationLink {
                                OdometerForm(calenderYear: calenderYear, odometerStart: $odometerStart, odometerEnd: $odometerEnd, reportIndex: $reportIndex)                                
                            }
                            ///navigation link label to display the odometer start and end readings.
                            label : {
                                OdometerFormLabel(calenderYear: calenderYear, odometerStart: odometerStart, odometerEnd: odometerEnd, unit: "km")
                            }
                        }
                        ///Section header with text view to show heading title.
                        header:  {
                            Text("Odometer Readings").fontWeight(.bold)
                        }
                    }
                    ///if the settings have the distance unit set to mi
                    else {
                        ///section with header for odometer readings display label and navigation link
                        Section {
                            ///navigation link to the odometerForm swiftuiview to update start and end odometer of a given year
                            NavigationLink {
                                ///navigation link label to display the odometer start and end readings.
                                OdometerForm(calenderYear: calenderYear, odometerStart: $odometerStartMiles, odometerEnd: $odometerEndMiles, reportIndex: $reportIndex)
                            }
                            ///navigation link label to display the odometer start and end readings.
                            label : {
                                OdometerFormLabel(calenderYear: calenderYear, odometerStart: odometerStartMiles, odometerEnd: odometerEndMiles, unit: "mi")
                            }
                        }
                        ///Section header with text view to show heading title.
                        header:  {
                            Text("Odometer Readings").fontWeight(.bold)
                        }
                    }
                    ///if engine type is other then hybrid
                    if engineType != .Hybrid {
                        ///show annual mileage section view to show mileage data for either gas or EV engine based on the settings of the vehicle.
                        AnnualMileageSection(annualTrip: engineType == .Gas ? annualTrip: annualTripEV, distanceUnit: settings.first!.getDistanceUnit, fuelConsumed: engineType == .Gas ? fuelConsumed: fuelConsumedEV, fuelUnit: engineType == .Gas ? settings.first!.getFuelVolumeUnit : "kwh", annualMileage: engineType == .Gas ? annualMileage: annualMileageEV, efficiencyUnit: settings.first!.getFuelEfficiencyUnit, calendarYear: autoSummary.getCalenderYear)
                    }
                    ///if engine type is hybrid
                    else {
                        ///show annual mileage section view to show mileage data for gas engine based on the settings of the vehicle.
                        AnnualMileageSection(annualTrip: annualTrip, distanceUnit: settings.first!.getDistanceUnit, fuelConsumed: fuelConsumed, fuelUnit: settings.first!.getFuelVolumeUnit == "%" ? "L" : settings.first!.getFuelVolumeUnit, annualMileage: annualMileage, efficiencyUnit: settings.first!.getFuelVolumeUnit == "%" ? "km/L" : settings.first!.getFuelEfficiencyUnit, calendarYear: autoSummary.getCalenderYear)
                        ///show annual mileage section view to show mileage data for EV engine based on the settings of the vehicle.
                        AnnualMileageSection(annualTrip: annualTripEV, distanceUnit: settings.first!.getDistanceUnit, fuelConsumed: fuelConsumedEV, fuelUnit: "kwh", annualMileage: annualMileageEV, efficiencyUnit: settings.first!.getFuelVolumeUnit != "%" ? "km/kwh" :settings.first!.getFuelEfficiencyUnit, calendarYear: autoSummary.getCalenderYear)
                    }
                    ///if engine type is other then hybrid
                    if engineType != .Hybrid {
                        ///show annual cost section view to show cost data for Gas or EV engine based on the settings of the vehicle.
                        AnnualCostsSection(annualFuelCost: engineType == .Gas ? annualFuelCost: annualFuelCostEV, annualServiceCost: engineType == .Gas ? annualServiceCost : annualServiceCostEV, calenderYear: autoSummary.getCalenderYear)
                    }
                    ///if engine type is hybrid
                    else {
                        ///show annual mileage section view to show cost data for Gas and EV engine.
                        AnnualCostsSectionHybrid(annualFuelCost: annualFuelCost, annualFuelCostEV: annualFuelCostEV, calenderYear: autoSummary.getCalenderYear, annualServiceCost: annualServiceCost)
                    }
                }
                ///on appear of this swiftui view execute this modifier.
                .onAppear {
                    ///call method to fill up the form with data gathered from autosummary of a given vehicle in a given year.
                    fillUpForm()
                }
                .navigationTitle(String(calenderYear) + " Summary")
                .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    ///method to fill up the form with data gathered from autosummary of a given vehicle in a given year.
    func fillUpForm() {
        ///get the first instance of the settings entity.
        guard let thisSettings = settings.first else {
            return
        }
        
        ///get the engine type from the settings or keep it to default value of gas
        engineType = EngineType(rawValue: thisSettings.getAutoEngineType) ?? .Gas
        ///get the odometer start value from autosummary to variable
        odometerStart = autoSummary.odometerStart
        ///get the odometer end value from autosummary to variable
        odometerEnd = autoSummary.odometerEnd
        ///get the odometer start value from autosummary to variable in miles.
        odometerStartMiles = autoSummary.odometerStartMiles
        ///get the odometer end value from autosummary to variable in miles.
        odometerEndMiles = autoSummary.odometerEndMiles
        ///get annual trip value from autosummary to variable in km or miles based on the distance unit in the settings.
        annualTrip = thisSettings.distanceUnit == "km" ? autoSummary.annualTrip : autoSummary.annualTripMiles
        ///get annual  EV trip value from autosummary to variable in km or miles based on the distance unit in the settings.
        annualTripEV = thisSettings.distanceUnit == "km" ? autoSummary.annualTripEV : autoSummary.annualTripEVMiles
        ///get the mileage value from autosummary to variable
        annualMileage = autoSummary.annualMileage
        ///get the EV mileage value from autosummary to variable
        annualMileageEV = autoSummary.annualMileageEV
        ///get the fuel cost from autosummary to variable
        annualFuelCost = autoSummary.annualFuelCost
        ///get the EV fuel cost from autosummary to variable
        annualFuelCostEV = autoSummary.annualfuelCostEV
        ///get the service cost from autosummary to variable
        annualServiceCost = autoSummary.annualServiceCost
        ///get the EV service cost from autosummary to variable
        annualServiceCostEV = autoSummary.annualServiceCostEV
        ///get the Calender year from autosummary to variable
        calenderYear = Int(autoSummary.calenderYear)
        ///if the fuel volume unit is in litre
        if thisSettings.getFuelVolumeUnit == "Litre" {
            ///get the litre of fuel consumed from autosummary to variable
            fuelConsumed = autoSummary.litreConsumed
            ///get the kwh of fuel consumed from autosummary to variable
            fuelConsumedEV = autoSummary.kwhConsumed
        }
        ///if the fuel volume unit is in gallon
        else if thisSettings.getFuelVolumeUnit == "Gallon" {
            ///get the gallon of fuel consumed from autosummary to variable
            fuelConsumed = autoSummary.gallonsConsumed
            ///get the kwh of fuel consumed from autosummary to variable
            fuelConsumedEV = autoSummary.kwhConsumed
        }
        ///if the fuel volume unit is in %
        else if thisSettings.getFuelVolumeUnit == "%" {
            ///get the litre of fuel consumed from autosummary to variable
            fuelConsumed = autoSummary.litreConsumed
            ///get the kwh of fuel consumed from autosummary to variable
            fuelConsumedEV = autoSummary.kwhConsumed
        }
    }
}
#Preview {
    AutoSummaryView()
}
