//
//  ChartView.swift
//  Map
//
//  Created by saj panchal on 2024-12-27.
//

import SwiftUI
import Charts
struct ChartView: View {
    @FetchRequest(entity: Vehicle.entity(), sortDescriptors: []) var vehicles: FetchedResults<Vehicle>
    @FetchRequest(entity:Settings.entity(), sortDescriptors:[]) var settings: FetchedResults<Settings>
    @State var efficiencyChart: EfficiencyCharts = .fuel
    @State var costChart: CostCharts = .fuel_Cost
    var body: some View {
        NavigationStack {
            if let thisSettings = settings.first {
                if let vehicle = vehicles.first(where: {$0.isActive}) {
                    ScrollView {
                        
                        Picker("Show Chart For", selection: $efficiencyChart) {
                            ForEach(EfficiencyCharts.allCases) { filter in
                                Text(filter.rawValue.capitalized)
                            }
                        }
                        .pickerStyle(.segmented)
                        .padding()
                        switch efficiencyChart {
                        case .fuel:
                            Chart(vehicle.getReports, id: \.objectID) {
                                if thisSettings.getFuelVolumeUnit == "Litre" {
                                    BarMark(x: .value("Year", $0.getCalenderYear),  y: .value("Volume (L)", $0.litreConsumed))
                                }
                                else if thisSettings.getFuelVolumeUnit == "Gallon" {
                                    BarMark(x: .value("Year", $0.getCalenderYear),  y: .value("Volume (Gl)", $0.gallonsConsumed))
                                }
                                else {
                                    BarMark(x: .value("Year", $0.getCalenderYear),  y: .value("Volume (kwh)", $0.kwhConsumed))
                                }
                            }
                            .frame(height: 400)
                            .padding(.trailing,5)
                            .foregroundStyle(Color.yellow)
                            Text("Fuel consumption in " + (thisSettings.getFuelVolumeUnit == "%" ? "kwh" : thisSettings.getFuelVolumeUnit))
                                .fontWeight(.bold)
                                .foregroundStyle(Color.blue)
                                .padding(.bottom, 30)
                            
                            
                        case .mileage:
                            
                            Chart(vehicle.getReports, id: \.objectID) {
                                BarMark(x: .value("Year", $0.getCalenderYear),  y: .value("Mileage in " + thisSettings.getFuelEfficiencyUnit, $0.annualMileage))
                            }
                            .padding(.trailing,5)
                            .frame(height: 400)
                            .foregroundStyle(Color.green)
                            Text("Mileage in " + thisSettings.getFuelEfficiencyUnit)
                                .fontWeight(.bold)
                                .foregroundStyle(Color.blue)
                                .padding(.bottom, 30)
                            
                        case .travel:
                            Chart(vehicle.getReports, id: \.objectID) {
                                if vehicle.getFuelMode == "Gas" {
                                    BarMark(x: .value("Year", $0.getCalenderYear),  y: .value("Travel in " + thisSettings.getDistanceUnit, (thisSettings.getDistanceUnit == "km" ? $0.annualTrip : $0.annualTripMiles)))
                                }
                                else if  vehicle.getFuelMode == "EV" {
                                    BarMark(x: .value("Year", $0.getCalenderYear),  y: .value("Travel in " + thisSettings.getDistanceUnit, (thisSettings.getDistanceUnit == "km" ? $0.annualTripEV : $0.annualTripEVMiles)))
                                }
                                else {
                                    BarMark(x: .value("Year", $0.getCalenderYear),  y: .value("Travel in " + thisSettings.getDistanceUnit, (thisSettings.getDistanceUnit == "km" ? $0.annualTrip : $0.annualTripMiles)))
                                }
                            }
                            .padding(.trailing,5)
                            .frame(height: 400)
                            .foregroundStyle(Color.purple)
                            
                            
                            Text("Travel in "  + thisSettings.getDistanceUnit)
                                .fontWeight(.bold)
                                .foregroundStyle(Color.blue)
                                .padding(.bottom, 30)
                        }
                        
                        Picker("Show Chart For", selection: $costChart) {
                            ForEach(CostCharts.allCases) { filter in
                                Text(filter.rawValue.capitalized.replacingOccurrences(of: "_", with: " "))
                            }
                        }
                        .pickerStyle(.segmented)
                        .padding()
                        switch costChart {
                        case .fuel_Cost:
                            Chart(vehicle.getReports, id: \.objectID) {
                                if  vehicle.getFuelMode == "Gas" {
                                    BarMark(x: .value("Year", $0.getCalenderYear),  y: .value("Cost in " + (Locale.current.currency?.identifier ?? "$CAD") , $0.annualFuelCost))
                                }
                                else if vehicle.getFuelMode == "EV" {
                                    BarMark(x: .value("Year", $0.getCalenderYear),  y: .value("Cost in " + (Locale.current.currency?.identifier ?? "$CAD") , $0.annualfuelCostEV))
                                }
                                else {
                                    BarMark(x: .value("Year", $0.getCalenderYear),  y: .value("Cost in " + (Locale.current.currency?.identifier ?? "$CAD") , $0.annualFuelCost))
                                }
                               
                            }
                            .frame(height: 400)
                            .padding(.trailing,5)
                            .foregroundStyle(Color.orange)
                            Text("Fuel Cost in " + (Locale.current.currency?.identifier ?? "$CAD"))
                                .fontWeight(.bold)
                                .foregroundStyle(Color.blue)
                                .padding(.bottom, 30)
                            
                        case .service_Cost:
                            Chart(vehicle.getReports, id: \.objectID) {
                                if vehicle.getFuelMode == "Gas" {
                                    BarMark(x: .value("Year", $0.getCalenderYear),  y: .value("Cost in " + (Locale.current.currency?.identifier ?? "$CAD"), $0.annualServiceCost))
                                }
                                else if vehicle.getFuelMode == "EV" {
                                    BarMark(x: .value("Year", $0.getCalenderYear),  y: .value("Cost in " + (Locale.current.currency?.identifier ?? "$CAD"), $0.annualServiceCostEV))
                                }
                                else {
                                    BarMark(x: .value("Year", $0.getCalenderYear),  y: .value("Cost in " + (Locale.current.currency?.identifier ?? "$CAD"), $0.annualServiceCost))
                                }
                            }
                            .frame(height: 400)
                            .padding(.trailing,5)
                            .foregroundStyle(Color.red)
                            Text("Service Cost in " + (Locale.current.currency?.identifier ?? "$CAD"))
                                .fontWeight(.bold)
                                .foregroundStyle(Color.blue)
                                .padding(.bottom, 30)
                        }
                        
                        
                    }
                    .onAppear {
                        print(vehicle.getFuelMode)
                    }
                    .navigationTitle("Charts")
                    
                    
                }
            }
        }
    }
}

#Preview {
    ChartView()
}
