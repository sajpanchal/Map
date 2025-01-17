//
//  ChartView.swift
//  Map
//
//  Created by saj panchal on 2024-12-27.
//

import SwiftUI
///module to implement charts in swiftui
import Charts

struct ChartView: View {
    ///enviroment variable to dismiss the current view.
    @Environment(\.dismiss) var dismiss
    ///viewContext is part of the core data stack that tracks the changes to instances of app's types
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(entity: Vehicle.entity(), sortDescriptors: []) var vehicles: FetchedResults<Vehicle>
    @FetchRequest(entity:Settings.entity(), sortDescriptors:[]) var settings: FetchedResults<Settings>
    @FetchRequest(entity: AutoSummary.entity(), sortDescriptors: []) var reports: FetchedResults<AutoSummary>
    ///enum type stores the kind of efficiency chart to show.
    @State var efficiencyChart: EfficiencyCharts = .travel
    ///enum type stores the kind of cost chart to show.
    @State var costChart: CostCharts = .fuel_Cost
    ///binding variable to show/hide this swiftui view.
    @Binding var showChartView: Bool
    var body: some View {
       
        NavigationStack {
            ///if settings has first instance
            if let thisSettings = settings.first {
                ///get the vehicle from vehicles entity which is active.
                if let vehicle = vehicles.first(where: {$0.isActive}) {
                    ///enclose the chart and its picker in a scrollview.
                    ScrollView {
                        ///picker with selection as binding value of the selection.
                        Picker("Show Chart For", selection: $efficiencyChart) {
                            ///picker content is a foreach loop of efficiency charts which is uniquely identifiable.
                            ForEach(EfficiencyCharts.allCases) { filter in
                                ///inside the loop is the text that show the rawvalue of the efficiency charts.
                                Text(filter.rawValue.capitalized)
                            }
                        }
                        ///segmeted picker modifier
                        .pickerStyle(.segmented)
                        .padding()
                        ///based on the efficiencychart selection switch case statement will display that chart.
                        switch efficiencyChart {
                            ///if fuel efficiency chart is selected.
                        case .fuel:
                            ///create a chart from all the reports belongs to the given vehicle
                            Chart(vehicle.getReports, id: \.objectID) {
                                ///if the fuel unit is set to litres in app settings.
                                if thisSettings.getFuelVolumeUnit == "Litre" {
                                    ///show bar chart with x axis showing calendar years and y axis showing litre of fuel consumed.
                                    BarMark(x: .value("Year", $0.getCalenderYear),  y: .value("Volume (L)", $0.litreConsumed))
                                }
                                ///if the fuel unit is set to gallons in app settings.
                                else if thisSettings.getFuelVolumeUnit == "Gallon" {
                                    ///show bar chart with x axis showing calendar years and y axis showing gallons of fuel consumed.
                                    BarMark(x: .value("Year", $0.getCalenderYear),  y: .value("Volume (Gl)", $0.gallonsConsumed))
                                }
                                ///if the fuel unit is set to % in app settings.
                                else {
                                    ///show bar chart with x axis showing calendar years and y axis showing kwh of fuel consumed.
                                    BarMark(x: .value("Year", $0.getCalenderYear),  y: .value("Volume (kwh)", $0.kwhConsumed))
                                }
                            }
                            .frame(height: 400)
                            .padding(.trailing,5)
                            .foregroundStyle(Color.yellow)
                            ///footer text
                            Text("Fuel consumption in " + (thisSettings.getFuelVolumeUnit == "%" ? "kwh" : thisSettings.getFuelVolumeUnit))
                                .fontWeight(.bold)
                                .foregroundStyle(Color.blue)
                                .padding(.bottom, 30)
                        ///if picker is set to show mileage chart
                        case .mileage:
                            ///create a chart from all the reports belongs to the given vehicle
                            Chart(vehicle.getReports, id: \.objectID) {
                                ///show the bar chart with x axis showing calendar year and y axis showing mileage in respective units.
                                BarMark(x: .value("Year", $0.getCalenderYear),  y: .value("Mileage in " + thisSettings.getFuelEfficiencyUnit, $0.annualMileage))
                            }
                            .padding(.trailing,5)
                            .frame(height: 400)
                            .foregroundStyle(Color.green)
                            ///footer text view.
                            Text("Mileage in " + thisSettings.getFuelEfficiencyUnit)
                                .fontWeight(.bold)
                                .foregroundStyle(Color.blue)
                                .padding(.bottom, 30)
                        ///if picker is set to show travel chart
                        case .travel:
                            ///create a chart from all the reports belongs to the given vehicle
                            Chart(vehicle.getReports, id: \.objectID) {
                                ///if the fuel mode is set to Gas in app settings.
                                if vehicle.getFuelMode == "Gas" {
                                    ///show bar chart with x axis showing calendar years and y axis showing travel distance in km or miles for gas engine mode.
                                    BarMark(x: .value("Year", $0.getCalenderYear),  y: .value("Travel in " + thisSettings.getDistanceUnit, (thisSettings.getDistanceUnit == "km" ? $0.annualTrip : $0.annualTripMiles)))
                                }
                                ///if the fuel mode is set to EV in app settings.
                                else if  vehicle.getFuelMode == "EV" {
                                    ///show bar chart with x axis showing calendar years and y axis showing travel distance in km or miles for EV engine mode.
                                    BarMark(x: .value("Year", $0.getCalenderYear),  y: .value("Travel in " + thisSettings.getDistanceUnit, (thisSettings.getDistanceUnit == "km" ? $0.annualTripEV : $0.annualTripEVMiles)))
                                }
                                ///if no settings found above
                                else {
                                    ///show bar chart with x axis showing calendar years and y axis showing travel distance in km or miles for default engine mode.
                                    BarMark(x: .value("Year", $0.getCalenderYear),  y: .value("Travel in " + thisSettings.getDistanceUnit, (thisSettings.getDistanceUnit == "km" ? $0.annualTrip : $0.annualTripMiles)))
                                }
                            }
                            .padding(.trailing,5)
                            .frame(height: 400)
                            .foregroundStyle(Color.purple)
                            ///footer text view.
                            Text("Travel in "  + thisSettings.getDistanceUnit)
                                .fontWeight(.bold)
                                .foregroundStyle(Color.blue)
                                .padding(.bottom, 30)
                        }
                        ///picker with selection as binding value of the selection.
                        Picker("Show Chart For", selection: $costChart) {
                            ///picker content is a foreach loop of cost charts which is uniquely identifiable.
                            ForEach(CostCharts.allCases) { filter in
                                ///inside the loop is the text that show the rawvalue of the cost charts.
                                Text(filter.rawValue.capitalized.replacingOccurrences(of: "_", with: " "))
                            }
                        }
                        .pickerStyle(.segmented)
                        .padding()
                        ///based on the cost chart selection switch case statement will display that chart.
                        switch costChart {
                        case .fuel_Cost:
                            ///create a chart from all the reports belongs to the given vehicle
                            Chart(vehicle.getReports, id: \.objectID) {
                                ///if the fuel mode is set to Gas in app settings.
                                if  vehicle.getFuelMode == "Gas" {
                                    ///show bar chart with x axis showing calendar years and y axis showing annual fuel cost for gas engine mode.
                                    BarMark(x: .value("Year", $0.getCalenderYear),  y: .value("Cost in " + (Locale.current.currency?.identifier ?? "$CAD") , $0.annualFuelCost))
                                }
                                ///if the fuel mode is set to EV in app settings.
                                else if vehicle.getFuelMode == "EV" {
                                    ///show bar chart with x axis showing calendar years and y axis showing annual fuel cost for EV engine mode.
                                    BarMark(x: .value("Year", $0.getCalenderYear),  y: .value("Cost in " + (Locale.current.currency?.identifier ?? "$CAD") , $0.annualfuelCostEV))
                                }
                                ///if no settings found above
                                else {
                                    ///show bar chart with x axis showing calendar years and y axis showing annual fuel cost for default engine mode.
                                    BarMark(x: .value("Year", $0.getCalenderYear),  y: .value("Cost in " + (Locale.current.currency?.identifier ?? "$CAD") , $0.annualFuelCost))
                                }
                               
                            }
                            .frame(height: 400)
                            .padding(.trailing,5)
                            .foregroundStyle(Color.orange)
                            ///footer text view.
                            Text("Fuel Cost in " + (Locale.current.currency?.identifier ?? "$CAD"))
                                .fontWeight(.bold)
                                .foregroundStyle(Color.blue)
                                .padding(.bottom, 30)
                            
                        case .service_Cost:
                            ///create a chart from all the reports belongs to the given vehicle
                            Chart(vehicle.getReports, id: \.objectID) {
                                ///if the fuel mode is set to Gas in app settings.
                                if vehicle.getFuelMode == "Gas" {
                                    ///show bar chart with x axis showing calendar years and y axis showing annual service cost for gas engine mode.
                                    BarMark(x: .value("Year", $0.getCalenderYear),  y: .value("Cost in " + (Locale.current.currency?.identifier ?? "$CAD"), $0.annualServiceCost))
                                }
                                ///if the fuel mode is set to EV in app settings.
                                else if vehicle.getFuelMode == "EV" {
                                    ///show bar chart with x axis showing calendar years and y axis showing annual service cost for EV engine mode.
                                    BarMark(x: .value("Year", $0.getCalenderYear),  y: .value("Cost in " + (Locale.current.currency?.identifier ?? "$CAD"), $0.annualServiceCostEV))
                                }
                                ///if no settings found above
                                else {
                                    ///show bar chart with x axis showing calendar years and y axis showing annual service cost for default engine mode.
                                    BarMark(x: .value("Year", $0.getCalenderYear),  y: .value("Cost in " + (Locale.current.currency?.identifier ?? "$CAD"), $0.annualServiceCost))
                                }
                            }
                            .frame(height: 400)
                            .padding(.trailing,5)
                            .foregroundStyle(Color.red)
                            ///footer text view.
                            Text("Service Cost in " + (Locale.current.currency?.identifier ?? "$CAD"))
                                .fontWeight(.bold)
                                .foregroundStyle(Color.blue)
                                .padding(.bottom, 30)
                        }
                        
                        
                    }
                    ///on appear of this swiftui view, this modifier will be called.
                    .onAppear {
                        ///get the first element of settings entity
                        guard let thisSettings = settings.first else {
                            return
                        }
                        ///call set fuel efficiency method for a given vehicle with all settings in AutoSummary to calculate the fuel efficiency in a set units for each year.
                        AutoSummary.setFuelEfficiency(viewContext: viewContext, vehicle: vehicle, settings: thisSettings)
                        
                    }
                    .navigationTitle("Charts")
                    
                    
                }
            }
        }
    }
}

#Preview {
    ChartView(showChartView: .constant(false))
}
