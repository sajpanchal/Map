//
//  StatsView.swift
//  Map
//
//  Created by saj panchal on 2024-06-16.
//

import SwiftUI

struct AutoStatsView: View {
    @Environment (\.colorScheme) var bgMode: ColorScheme
    @StateObject var locationDataManager: LocationDataManager
    @FetchRequest(entity: Vehicle.entity(), sortDescriptors: []) var vehicles: FetchedResults<Vehicle>
    @FetchRequest(entity: Settings.entity(), sortDescriptors:[]) var settings: FetchedResults<Settings>
    let rows = [GridItem(spacing: 10, alignment: .topLeading), GridItem(spacing: 10, alignment: .topLeading), GridItem(spacing: 10, alignment: .topLeading)]
    @State var showFuelHistoryView = false
    @State var showServiceHistoryView = false
    @State var showFuellingEntryform = false
    @State var showServiceEntryForm = false
  
    var redColor = Color(red:0.861, green: 0.194, blue:0.0)
    var lightRedColor = Color(red:1.0, green:0.654, blue:0.663)
    
    var greenColor = Color(red: 0.257, green: 0.756, blue: 0.346)
    var lightGreenColor = Color(red: 0.723, green: 1.0, blue: 0.856)
    
    var orangeColor = Color(red: 0.975, green: 0.505, blue: 0.076)
    var lightOrangeColor = Color(red: 1.0, green: 0.85, blue: 0.7)
    
    var skyColor = Color(red:0.031, green:0.739, blue:0.861)
    var lightSkyColor = Color(red:0.657, green:0.961, blue: 1.0)
    
    var yellowColor = Color(red:1.0, green: 0.80, blue: 0.0)
    var lightYellowColor = Color(red:0.938, green: 1.0, blue: 0.84)
    
    var purpleColor = Color(red: 0.396, green: 0.381, blue: 0.905)
    var lightPurpleColor = Color(red:0.725,green:0.721, blue:1.0)
    
    let dateFomatter = DateFormatter()
    let numberFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
               formatter.numberStyle = .decimal
               formatter.maximumFractionDigits = 0
        return formatter

    }()
    let deciNumberFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
               formatter.numberStyle = .decimal
               formatter.maximumFractionDigits = 2
        return formatter

    }()
    let currencyFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
               formatter.numberStyle = .currency
         formatter.locale = .current
               formatter.maximumFractionDigits = 2
        return formatter

    }()
    
    var body: some View {
        GeometryReader { geo in
            NavigationStack {
                List {
                    if let vehicle = vehicles.first(where: {$0.isActive}) {
                        Section("Dashboard") {
                            LazyHGrid(rows: rows) {
                                DashGridItemView(title: "ODOMETER", foreGroundColor: purpleColor, backGroundColor: lightPurpleColor, numericText: settings.first!.getDistanceUnit == "km" ? numberFormatter.string(for: vehicle.odometer) ?? "--" : numberFormatter.string(for: vehicle.getOdometerMiles) ?? "--", unitText: settings.first?.getDistanceUnit ?? "", geometricSize: geo.size)
                                DashGridItemView(title: "LAST FUELLING", foreGroundColor: yellowColor, backGroundColor: lightYellowColor, numericText: deciNumberFormatter.string(for: vehicle.getFuellings.first?.volume ?? 0) ?? "--", unitText: settings.first?.getFuelVolumeUnit ?? "", geometricSize: geo.size)
                                DashGridItemView(title: "FUEL COST", foreGroundColor: orangeColor, backGroundColor: lightOrangeColor, numericText: currencyFormatter.string(for: vehicle.fuelCost) ?? "--", unitText: "Year 2024", geometricSize: geo.size)
                                DashGridItemView(title: "TRIP SINCE FUELLING", foreGroundColor: skyColor, backGroundColor: lightSkyColor, numericText: settings.first!.getDistanceUnit == "km" ?
                                                 deciNumberFormatter.string(for: vehicle.trip) ?? "--" :  deciNumberFormatter.string(for: vehicle.getTripMiles) ?? "--", unitText: settings.first?.getDistanceUnit ?? "", geometricSize: geo.size)
                                DashGridItemView(title: "MILEAGE", foreGroundColor: greenColor, backGroundColor: lightGreenColor, numericText: deciNumberFormatter.string(for: getFuelEfficiency(efficiency: vehicle.fuelEfficiency)) ?? "--", unitText: settings.first?.getFuelEfficiencyUnit ?? "", geometricSize: geo.size)
                                DashGridItemView(title: "REPAIR COST", foreGroundColor: redColor    , backGroundColor: lightRedColor, numericText: currencyFormatter.string(for: vehicle.serviceCost) ?? "--",  unitText: "Year 2024", geometricSize: geo.size)
                            }
                        }
                        .padding(10)
                    }
                 
                    if let vehicle = vehicles.first(where:{$0.isActive}) {
                        Section {
                            ScrollView {
                                NewEntryStackView(width: geo.size.width)
                                .onTapGesture {
                                    showFuellingEntryform.toggle()
                                }
                                .sheet(isPresented: $showFuellingEntryform, content: {
                                    FuellingEntryForm(locationDatamanager: LocationDataManager(), showFuellingEntryform: $showFuellingEntryform)
                                })
                                ForEach(vehicle.getFuellings, id:\.self.uniqueID) { fuelData in
                                    if vehicle.getFuellings.firstIndex(of: fuelData)! <= 2 {
                                        CustomListView(date: fuelData.date!, text1: ("Fuel Station",fuelData.location!), text2:("Volume", settings.first!.getFuelVolumeUnit == "Litre" ? (String(format:"%.2f",fuelData.volume) + "L") : (String(format:"%.2f",fuelData.getVolumeGallons) + "GL")), text3: ("Cost","$" + String(format:"%.2f",fuelData.cost)), text4: settings.first!.getDistanceUnit == "km" ? String(format:"%.1f", fuelData.lasttrip) + " km" : String(format:"%.1f", fuelData.getLastTripMiles) + " miles" , timeStamp: "Updated on: " + fuelData.getTimeStamp, width: geo.size.width)
                                    }
                                }
                            }
                            .frame(width:geo.size.width - 20,height: geo.size.height/1.25)
                        }
                    header: {
                            VStack {
                                HStack(spacing: 0) {
                                    Text("Fuelling History")
                                    Spacer()
                                }
                                HStack(spacing: 0) {
                                    Spacer()
                                    Button(action: {
                                        showFuelHistoryView.toggle()
                                    }, label: {Text("View More").font(.system(size: 12))})
                                    .sheet(isPresented: $showFuelHistoryView, content: {
                                        FuelHistoryView(vehicle: vehicle)
                                    })
                                }
                            }
                        }
        
                        Section {
                            ScrollView {
                                NewEntryStackView(width: geo.size.width)
                                .onTapGesture {
                                    showServiceEntryForm.toggle()
                                }
                                .sheet(isPresented: $showServiceEntryForm, content: {
                                    ServiceEntryForm(showServiceEntryForm: $showServiceEntryForm)
                                })
                                ForEach(vehicle.getServices, id: \.self.uniqueID) { autoService in
                                    if vehicle.getServices.firstIndex(of: autoService)! <= 2 {
                                        CustomListView(date: autoService.date!, text1: ("Auto Shop",autoService.location!), text2: ("",""), text3: ("Cost","$" + String(format:"%.2f",autoService.cost)), text4: "", timeStamp: "Updated on: " + autoService.getTimeStamp, width: geo.size.width)
                                    }
                                }
                            }
                            .frame(width:geo.size.width - 20,height: geo.size.height/1.5)
                        }
                    header: {
                            VStack {
                                HStack(spacing: 0) {
                                    Text("Service History")
                                    Spacer()
                                }
                                HStack(spacing: 0) {
                                    Spacer()
                                    Button(action: {
                                        showServiceHistoryView.toggle()
                                    }, label: {Text("View More").font(.system(size: 12))})
                                    .sheet(isPresented: $showServiceHistoryView, content: {
                                        ServiceHistoryView(vehicle: vehicle)
                                    })
                                }
                            }
                        }
                    }
                }
                .frame(width: geo.size.width, height: geo.size.height - 40)
                .navigationTitle("Auto Summary")
            }
        }
    }
    
    func getFuelEfficiency(efficiency: Double) -> Double {
        switch settings.first!.fuelEfficiencyUnit {
        case "km/L":
            return efficiency
        case "L/100km":
            return 100/efficiency
        case "miles/L":
            return 0.62 * efficiency
        case "L/100Miles":
            return 100/(0.62 * efficiency)
        case "km/gl":
            return efficiency * 3.785
        case "miles/gl":
            return efficiency * 2.352
        case "gl/100km":
            return efficiency * 26.417
        case "gl/100miles":
            return (100/efficiency) * (0.2641/0.6213)
        case "km/kwh":
            return 0
        case "miles/kwh":
            return 0
        default:
            return 0
        }
    }
}

#Preview {
    AutoStatsView(locationDataManager: LocationDataManager())
}
