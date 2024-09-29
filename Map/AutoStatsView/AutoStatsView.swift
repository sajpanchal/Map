//
//  StatsView.swift
//  Map
//
//  Created by saj panchal on 2024-06-16.
//

import SwiftUI

struct AutoStatsView: View {
    @Environment (\.colorScheme) var bgMode: ColorScheme
    @Environment(\.managedObjectContext) private var viewContext
    @StateObject var locationDataManager: LocationDataManager
    @FetchRequest(entity: Vehicle.entity(), sortDescriptors: []) var vehicles: FetchedResults<Vehicle>
    @FetchRequest(entity: Settings.entity(), sortDescriptors:[]) var settings: FetchedResults<Settings>
    let rows = [GridItem(spacing: 10, alignment: .topLeading), GridItem(spacing: 10, alignment: .topLeading), GridItem(spacing: 10, alignment: .topLeading)]
    @State var showFuelHistoryView = false
    @State var showServiceHistoryView = false
    @State var showFuellingEntryform = false
    @State var showServiceEntryForm = false
    
  
    let currentYear: String = {
        let components = DateComponents()
        if let year = Calendar.current.dateComponents([.year], from: Date()).year {
            return String(year)
        }
        else {
            return ""
        }
       
    }()
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
                        Section {
                            LazyHGrid(rows: rows) {
                                DashGridItemView(title: "ODOMETER", foreGroundColor: Color(AppColors.invertPurple.rawValue), backGroundColor: Color(AppColors.purple.rawValue), numericText: settings.first!.getDistanceUnit == "km" ? numberFormatter.string(for: vehicle.odometer) ?? "--" : numberFormatter.string(for: vehicle.getOdometerMiles) ?? "--", unitText: settings.first?.getDistanceUnit ?? "", geometricSize: geo.size)
                                DashGridItemView(title: "LAST FUELLING", foreGroundColor: Color(AppColors.invertYellow.rawValue), backGroundColor: Color(AppColors.yellow.rawValue), numericText: deciNumberFormatter.string(for: vehicle.getFuellings.first?.volume ?? 0) ?? "--", unitText: settings.first?.getFuelVolumeUnit ?? "", geometricSize: geo.size)
                                DashGridItemView(title: "FUEL COST", foreGroundColor: Color(AppColors.invertOrange.rawValue), backGroundColor: Color(AppColors.orange.rawValue), numericText: currencyFormatter.string(for: vehicle.getfuelCost) ?? "--", unitText: currentYear, geometricSize: geo.size)
                                DashGridItemView(title: "TRIP SINCE FUELLING", foreGroundColor: Color(AppColors.invertSky.rawValue), backGroundColor: Color(AppColors.sky.rawValue), numericText: settings.first!.getDistanceUnit == "km" ?
                                                 deciNumberFormatter.string(for: vehicle.trip) ?? "--" :  deciNumberFormatter.string(for: vehicle.getTripMiles) ?? "--", unitText: settings.first?.getDistanceUnit ?? "", geometricSize: geo.size)
                                DashGridItemView(title: "MILEAGE", foreGroundColor: Color(AppColors.invertGreen.rawValue), backGroundColor:Color(AppColors.green.rawValue), numericText: deciNumberFormatter.string(for: getFuelEfficiency(efficiency: vehicle.fuelEfficiency)) ?? "--", unitText: settings.first?.getFuelEfficiencyUnit ?? "", geometricSize: geo.size)
                                DashGridItemView(title: "SERVICE COST", foreGroundColor: Color(AppColors.invertRed.rawValue)    , backGroundColor: Color(AppColors.red.rawValue), numericText: currencyFormatter.string(for: vehicle.getServiceCost) ?? "--",  unitText: currentYear, geometricSize: geo.size)
                            }
                        }
                       //
                    header: {
                        Text("Dashboard")
                            .font(.title2)
                            .fontWeight(.bold)
                            .padding(.top, 15)
                    }
                    .padding(10)
                    }
                 
                    if let vehicle = vehicles.first(where:{$0.isActive}) {
                        Section {
                            ScrollView {
                                NewEntryStackView(foregroundColor: Color(AppColors.yellow.rawValue), width: geo.size.width)
                                    .foregroundStyle(Color(AppColors.invertYellow.rawValue))
                                .onTapGesture {
                                    showFuellingEntryform.toggle()
                                }
                                .sheet(isPresented: $showFuellingEntryform, content: {
                                    FuellingEntryForm(locationDatamanager: LocationDataManager(), showFuellingEntryform: $showFuellingEntryform)
                                })
                                ForEach(vehicle.getFuellings, id:\.self.uniqueID) { fuelData in
                                    if vehicle.getFuellings.firstIndex(of: fuelData)! <= 2 {
                                        CustomListView(date: fuelData.date!, text1: ("Fuel Station",fuelData.location!), text2:("Volume", settings.first!.getFuelVolumeUnit == "Litre" ? (String(format:"%.2f",fuelData.volume) + "L") : (String(format:"%.2f",fuelData.getVolumeGallons) + "GL")), text3: ("Cost","$" + String(format:"%.2f",fuelData.cost)), text4: settings.first!.getDistanceUnit == "km" ? String(format:"%.1f", fuelData.lasttrip) + " km" : String(format:"%.1f", fuelData.getLastTripMiles) + " miles" , timeStamp: "Updated on: " + fuelData.getTimeStamp, fuelEntry: true, width: geo.size.width)
                                    }
                                }
                            }
                            .frame(width:geo.size.width - 20,height: geo.size.height/1.25)
                        }
                    header: {
                            VStack {
                                HStack(spacing: 0) {
                                    Text("Fuelling History")
                                        .font(.title2)
                                        .fontWeight(.bold)
                                    Spacer()
                                }
                                HStack(spacing: 0) {
                                    Spacer()
                                    Button(action: {
                                        showFuelHistoryView.toggle()
                                    }, label: { Text("View More").font(.system(size: 12)).fontWeight(.bold).padding(10).foregroundStyle(Color(AppColors.yellow.rawValue))})
                                    .background(Color(AppColors.invertYellow.rawValue))
                                    .buttonStyle(BorderlessButtonStyle())
                                    .cornerRadius(10)
                                    .sheet(isPresented: $showFuelHistoryView, content: {
                                        FuelHistoryView(vehicle: vehicle)
                                    })
                                }
                            }
                        }
        
                        Section {
                            ScrollView {
                                NewEntryStackView(foregroundColor: Color(AppColors.red.rawValue), width: geo.size.width)
                                    .foregroundStyle(Color(AppColors.invertRed.rawValue))
                                .onTapGesture {
                                    showServiceEntryForm.toggle()
                                }
                                .sheet(isPresented: $showServiceEntryForm, content: {
                                    ServiceEntryForm(showServiceEntryForm: $showServiceEntryForm)
                                })
                                ForEach(vehicle.getServices, id: \.self.uniqueID) { autoService in
                                    if vehicle.getServices.firstIndex(of: autoService)! <= 2 {
                                        CustomListView(date: autoService.date!, text1: ("Auto Shop",autoService.location!), text2: ("",""), text3: ("Cost","$" + String(format:"%.2f",autoService.cost)), text4: "", timeStamp: "Updated on: " + autoService.getTimeStamp, fuelEntry: false, width: geo.size.width)
                                    }
                                }
                            }
                            .frame(width:geo.size.width - 20,height: geo.size.height/1.5)
                        }
                    header: {
                            VStack {
                                HStack(spacing: 0) {
                                    Text("Service History")
                                        .font(.title2)
                                        .fontWeight(.bold)
                                    Spacer()
                                }
                                HStack(spacing: 0) {
                                    Spacer()
                                    Button(action: {
                                        showServiceHistoryView.toggle()
                                    }, label: {Text("View More").font(.system(size: 12)).fontWeight(.bold).padding(10).foregroundStyle(Color(AppColors.red.rawValue))})
                                    .background(Color(AppColors.invertRed.rawValue))
                                    .buttonStyle(BorderlessButtonStyle())
                                    .cornerRadius(10)
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
