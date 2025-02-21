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
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(entity: Vehicle.entity(), sortDescriptors: []) var vehicles: FetchedResults<Vehicle>
    @FetchRequest(entity: AutoSummary.entity(), sortDescriptors: []) var reports: FetchedResults<AutoSummary>
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
    //@State var reportIndex: Int?
    var currency = ""
    
    var body: some View {
        ///grouping the entire view
        VStack {
            if let activeVehicle = vehicles.first(where: {$0.isActive}) {
                if let thisSettings = activeVehicle.settings {
            Group {
                ///Horizontal stack displays text view aligned to the right.
                HStack {
                    Spacer()
                    ///text view displays current vehicle title.
                    VStack {
                        Text((activeVehicle.getVehicleText) + "\n" + (activeVehicle.getFuelEngine == "Gas" ? "" : (activeVehicle.getFuelEngine)))
                                    .fontWeight(.bold)
                                    .font(.system(size: 16))
                                    .multilineTextAlignment(.trailing)
                    }
                }
                .padding()
                
                ///list view enclosing the sections.
                List {
                    ///if the settings have the distance unit set to km
                    if thisSettings.distanceUnit == "km" {
                        ///section with header for odometer readings display label and navigation link
                        Section {
                            ///navigation link to the odometerForm swiftuiview to update start and end odometer of a given year
                            NavigationLink {
                                if let vehicleIndex = vehicles.firstIndex(where: {$0 == activeVehicle}) {
                                    OdometerForm(calenderYear: calenderYear, distanceUnit: thisSettings.getDistanceUnit, odometerStart: $odometerStart, odometerEnd: $odometerEnd, vehicleIndex: vehicleIndex)
                                }
                            }
                            ///navigation link label to display the odometer start and end readings.
                            label : {
                                OdometerFormLabel(calenderYear: calenderYear, odometerStart: odometerStart, odometerEnd: odometerEnd, unit: "km")
                                    .onAppear(perform: updateVehicleOdometer)
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
                                if let vehicleIndex = vehicles.firstIndex(where: {$0 == activeVehicle}) {
                                    OdometerForm(calenderYear: calenderYear, distanceUnit: thisSettings.getDistanceUnit, odometerStart: $odometerStart, odometerEnd: $odometerEnd, vehicleIndex: vehicleIndex)
                                }
                            }
                            ///navigation link label to display the odometer start and end readings.
                            label : {
                                OdometerFormLabel(calenderYear: calenderYear, odometerStart: odometerStartMiles, odometerEnd: odometerEndMiles, unit: "mi")
                                    .onAppear(perform: updateVehicleOdometer)
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
                        AnnualMileageSection(annualTrip: engineType == .Gas ? annualTrip : annualTripEV, distanceUnit: thisSettings.getDistanceUnit, fuelConsumed: engineType == .Gas ? fuelConsumed: fuelConsumedEV, fuelUnit: engineType == .Gas ? thisSettings.getFuelVolumeUnit : "kwh", annualMileage: engineType == .Gas ? annualMileage : annualMileageEV, efficiencyUnit: thisSettings.getFuelEfficiencyUnit, calendarYear: autoSummary.getCalenderYear)
                    }
                    ///if engine type is hybrid
                    else {
                        ///show annual mileage section view to show mileage data for gas engine based on the settings of the vehicle.
                        AnnualMileageSection(annualTrip: annualTrip, distanceUnit: thisSettings.getDistanceUnit, fuelConsumed: fuelConsumed, fuelUnit: thisSettings.getFuelVolumeUnit == "%" ? "L" : thisSettings.getFuelVolumeUnit, annualMileage: annualMileage, efficiencyUnit: thisSettings.getFuelVolumeUnit == "%" ? "km/L" : thisSettings.getFuelEfficiencyUnit, calendarYear: autoSummary.getCalenderYear)
                        ///show annual mileage section view to show mileage data for EV engine based on the settings of the vehicle.
                        AnnualMileageSection(annualTrip: annualTripEV, distanceUnit: thisSettings.getDistanceUnit, fuelConsumed: fuelConsumedEV, fuelUnit: "kwh", annualMileage: annualMileageEV, efficiencyUnit: thisSettings.getFuelVolumeUnit != "%" ? "km/kwh" :thisSettings.getFuelEfficiencyUnit, calendarYear: autoSummary.getCalenderYear)
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
                    updateVehicleOdometer()
                    ///call method to fill up the form with data gathered from autosummary of a given vehicle in a given year.
                    fillUpForm()
                    
                }
                .navigationTitle(String(calenderYear) + " Summary")
                .navigationBarTitleDisplayMode(.inline)
        }
                }
            }
        }
           
    }
    func updateVehicleOdometer() {
        guard let activeVehicle = vehicles.first(where: {$0.isActive}) else {
            return
        }
        guard let summaryIndex = reports.firstIndex(where: {$0.vehicle == activeVehicle && $0.calenderYear == Int16(calenderYear)}) else {
            return
        }
        guard let thisSettings = activeVehicle.settings else {
            return
        }       
        if calenderYear == Calendar.current.component(.year, from: Date()) {
            reports[summaryIndex].odometerEnd = activeVehicle.odometer
            reports[summaryIndex].odometerEndMiles = activeVehicle.odometerMiles
        }
        AutoSummary.saveContext(viewContext: viewContext)
        if thisSettings.getDistanceUnit == "km" {
            odometerEnd = reports[summaryIndex].odometerEnd
        }
        else {
            odometerEndMiles = reports[summaryIndex].odometerEndMiles
        }
        
    }
    ///method to fill up the form with data gathered from autosummary of a given vehicle in a given year.
    func fillUpForm() {
        guard let activeVehicle = vehicles.first(where: {$0.isActive}) else {
            return
        }
        ///get the first instance of the settings entity.
        guard let thisSettings = activeVehicle.settings else {
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
