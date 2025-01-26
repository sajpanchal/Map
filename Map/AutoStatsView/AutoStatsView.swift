//
//  StatsView.swift
//  Map
//
//  Created by saj panchal on 2024-06-16.
//

import SwiftUI

struct AutoStatsView: View {
    @Environment(\.colorScheme) var bgMode: ColorScheme
    @Environment(\.managedObjectContext) private var viewContext
    @StateObject var locationDataManager: LocationDataManager
    @FetchRequest(entity: Vehicle.entity(), sortDescriptors: []) var vehicles: FetchedResults<Vehicle>
    @FetchRequest(entity: Settings.entity(), sortDescriptors:[]) var settings: FetchedResults<Settings>
    @FetchRequest(entity: AutoSummary.entity(), sortDescriptors:[]) var reports: FetchedResults<AutoSummary>
    let rows = [GridItem(spacing: 10, alignment: .topLeading), GridItem(spacing: 10, alignment: .topLeading), GridItem(spacing: 10, alignment: .topLeading)]
    @State private var showFuelHistoryView = false
    @State private var showServiceHistoryView = false
    @State private var showFuellingEntryform = false
    @State private var showServiceEntryForm = false
    @State private var efficiency: Double = 0
    @State private var showAutoSummary = false
    @State private var showChartView = false
    @State private var showOdometerAlert = false
    @State private var odometerStart = 0.0
    @State private var odometerEnd = 0.0
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
                                DashGridItemView(title: "ODOMETER", foreGroundColor: Color(AppColors.invertPurple.rawValue), backGroundColor: Color(AppColors.purple.rawValue), numericText: settings.first!.getDistanceUnit == "km" ? numberFormatter.string(for: vehicle.odometer) ?? "--" : numberFormatter.string(for: vehicle.odometerMiles) ?? "--", unitText: settings.first?.getDistanceUnit ?? "", geometricSize: geo.size)
                                  
                                ///get the first fuelling entry from fuellings array of this vehicle filtered by the current fuel mode.
                                if let fuellingEntry = vehicle.getFuellings.filter({$0.fuelType == vehicle.fuelMode}).first {
                                    ///if fuel unit is in litre show value in litre
                                    if settings.first!.getFuelVolumeUnit == "Litre" {
                                        DashGridItemView(title: "LAST FUELLING", foreGroundColor: Color(AppColors.invertYellow.rawValue), backGroundColor: Color(AppColors.yellow.rawValue), numericText: deciNumberFormatter.string(for: fuellingEntry.litre != 0 ? fuellingEntry.litre : fuellingEntry.getVolumeLitre) ?? "--", unitText: settings.first?.getFuelVolumeUnit ?? "", geometricSize: geo.size)
                                    }
                                    ///if fuel unit is in gallon show value in gallon
                                    else if settings.first!.getFuelVolumeUnit == "Gallon" {
                                        DashGridItemView(title: "LAST FUELLING", foreGroundColor: Color(AppColors.invertYellow.rawValue), backGroundColor: Color(AppColors.yellow.rawValue), numericText: deciNumberFormatter.string(for: fuellingEntry.gallon != 0 ? fuellingEntry.gallon : fuellingEntry.getVolumeGallons) ?? "--", unitText: settings.first?.getFuelVolumeUnit ?? "", geometricSize: geo.size)
                                    }
                                    ///if fuel unit is in percent show value in percent
                                    else {
                                        DashGridItemView(title: "LAST FUELLING", foreGroundColor: Color(AppColors.invertYellow.rawValue), backGroundColor: Color(AppColors.yellow.rawValue), numericText: deciNumberFormatter.string(for: fuellingEntry.percent) ?? "--" , unitText: settings.first?.getFuelVolumeUnit ?? "", geometricSize: geo.size)
                                    }
                                }
                                ///if no records found keep it empty
                                else {
                                    DashGridItemView(title: "LAST FUELLING", foreGroundColor: Color(AppColors.invertYellow.rawValue), backGroundColor: Color(AppColors.yellow.rawValue), numericText: "--" , unitText: settings.first?.getFuelVolumeUnit ?? "", geometricSize: geo.size)
                                }
                                DashGridItemView(title: "FUEL COST", foreGroundColor: Color(AppColors.invertOrange.rawValue), backGroundColor: Color(AppColors.orange.rawValue), numericText: currencyFormatter.string(for: vehicle.getfuelCost) ?? "--", unitText: currentYear, geometricSize: geo.size)
                                ///if the fuel engine is hybrid
                                if vehicle.fuelEngine == "Hybrid" {
                                    ///if fuel mode is set the gas engine mode, show the trips for gas mode
                                    if vehicle.fuelMode == "Gas" {
                                        DashGridItemView(title: "TRIP SINCE FUELLING", foreGroundColor: Color(AppColors.invertSky.rawValue), backGroundColor: Color(AppColors.sky.rawValue), numericText: settings.first!.getDistanceUnit == "km" ?
                                                         deciNumberFormatter.string(for: vehicle.trip) ?? "--" :  deciNumberFormatter.string(for: vehicle.tripMiles) ?? "--", unitText: settings.first?.getDistanceUnit ?? "", geometricSize: geo.size)
                                    }
                                    ///if fuel mode is set the EV engine mode, show the trips for EV mode
                                    else {
                                        DashGridItemView(title: "TRIP SINCE FUELLING", foreGroundColor: Color(AppColors.invertSky.rawValue), backGroundColor: Color(AppColors.sky.rawValue), numericText: settings.first!.getDistanceUnit == "km" ?
                                                         deciNumberFormatter.string(for: vehicle.tripHybridEV) ?? "--" :  deciNumberFormatter.string(for: vehicle.tripHybridEVMiles) ?? "--", unitText: settings.first?.getDistanceUnit ?? "", geometricSize: geo.size)
                                    }
                                }
                                ///if the fuel engine is not hybrid show the trip in given distance format.
                                else {
                                    DashGridItemView(title: "TRIP SINCE FUELLING", foreGroundColor: Color(AppColors.invertSky.rawValue), backGroundColor: Color(AppColors.sky.rawValue), numericText: settings.first!.getDistanceUnit == "km" ?
                                                     deciNumberFormatter.string(for: vehicle.trip) ?? "--" :  deciNumberFormatter.string(for: vehicle.tripMiles) ?? "--", unitText: settings.first?.getDistanceUnit ?? "", geometricSize: geo.size)
                                }
                                DashGridItemView(title: "MILEAGE", foreGroundColor: Color(AppColors.invertGreen.rawValue), backGroundColor:Color(AppColors.green.rawValue), numericText: deciNumberFormatter.string(for: efficiency) ?? "--", unitText: settings.first?.getFuelEfficiencyUnit ?? "", geometricSize: geo.size)
                                DashGridItemView(title: "SERVICE COST", foreGroundColor: Color(AppColors.invertRed.rawValue)    , backGroundColor: Color(AppColors.red.rawValue), numericText: currencyFormatter.string(for: vehicle.getServiceCost) ?? "--",  unitText: currentYear, geometricSize: geo.size)
                            }
                            .onAppear {
                                efficiency = getFuelEfficiency()
                            }
                            .onChange(of: showFuellingEntryform) {
                                efficiency = getFuelEfficiency()
                            }
                            .onChange(of: showFuelHistoryView) {
                                efficiency = getFuelEfficiency()
                            }
                            ///tappable headerview to show the autoSummaryList view
                            CustomHeaderView(signImage: "steeringwheel", title: "Summary Archives")
                            ///on tap toggle the showAutoSummary flag
                            .onTapGesture {
                                showAutoSummary.toggle()
                            }
                            ///this modifier will be called whenever showAutoSummary flag changes and if it is true it will present the swiftuiView on top of the current view.
                            .sheet(isPresented: $showAutoSummary, content: {
                                AutoSummaryList(locationDataManager: locationDataManager)
                            })
                            ///tappable headerview to show the Chart  view
                            CustomHeaderView(signImage: "chart.bar.xaxis.ascending", title: "Summary Charts")
                            ///on tap toggle the showChartView flag
                            .onTapGesture {
                                showChartView.toggle()
                            }
                            ///this modifier will be called whenever showAutoSummary flag changes and if it is true it will present the swiftuiView on top of the current view.
                            .sheet(isPresented: $showChartView, content: {
                                ChartView(showChartView: $showChartView)
                            })
                        }
                        header: {
                            Text("Dashboard")
                                .font(.title2)
                                .fontWeight(.bold)
                                .padding(.top, 15)
                        }
                        .padding(10)
                        .onAppear {
                        }
                    }
                    
                    if let vehicle = vehicles.first(where:{$0.isActive}) {
                        Section {
                            ScrollView {
                                NewEntryStackView(foregroundColor: Color(AppColors.yellow.rawValue), width: geo.size.width, title: "New Fuel Entry")
                                    .foregroundStyle(Color(AppColors.invertYellow.rawValue))
                                .onTapGesture {
                                    showFuellingEntryform.toggle()
                                }
                                .sheet(isPresented: $showFuellingEntryform, content: {
                                    FuellingEntryForm(locationDatamanager: LocationDataManager(), showFuellingEntryform: $showFuellingEntryform)
                                })
                                ForEach(vehicle.getFuellings.filter({$0.fuelType == vehicle.fuelMode}), id:\.self.uniqueID) { fuelData in
                                    if vehicle.getFuellings.filter({$0.fuelType == vehicle.fuelMode}).firstIndex(of: fuelData)! <= 2 {
                                        if settings.first!.getFuelVolumeUnit == "Litre" {
                                            CustomListView(date: fuelData.getDateString, text1: ("Fuel Station",fuelData.location!), text2:("Volume", (String(format:"%.2f",fuelData.litre != 0.0 ? fuelData.litre : fuelData.getVolumeLitre) + "L")), text3: ("Cost","$" + String(format:"%.2f",fuelData.cost)), text4: settings.first!.getDistanceUnit == "km" ? String(format:"%.1f", fuelData.lasttrip) + " km" : String(format:"%.1f", fuelData.getLastTripMiles) + " miles" , timeStamp: "Updated on: " + fuelData.getTimeStamp, fuelEntry: true, width: geo.size.width)
                                        }
                                        else if settings.first!.getFuelVolumeUnit == "Gallon" {
                                            CustomListView(date: fuelData.getDateString, text1: ("Fuel Station",fuelData.location!), text2:("Volume", (String(format:"%.2f",fuelData.gallon != 0.0 ? fuelData.gallon : fuelData.getVolumeGallons) + "GL")), text3: ("Cost","$" + String(format:"%.2f",fuelData.cost)), text4: settings.first!.getDistanceUnit == "km" ? String(format:"%.1f", fuelData.lasttrip) + " km" : String(format:"%.1f", fuelData.getLastTripMiles) + " miles" , timeStamp: "Updated on: " + fuelData.getTimeStamp, fuelEntry: true, width: geo.size.width)
                                        }
                                        else  {
                                            CustomListView(date: fuelData.getDateString, text1: ("Fuel Station",fuelData.location!), text2:("Volume", (String(format:"%.2f",fuelData.percent) + "%")), text3: ("Cost","$" + String(format:"%.2f",fuelData.cost)), text4: settings.first!.getDistanceUnit == "km" ? String(format:"%.1f", fuelData.lasttrip) + " km" : String(format:"%.1f", fuelData.getLastTripMiles) + " miles" , timeStamp: "Updated on: " + fuelData.getTimeStamp, fuelEntry: true, width: geo.size.width)
                                        }
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
                                    .shadow(color: bgMode == .dark ? Color(UIColor.darkGray) : .black, radius: 1, x: 1, y: 1)
                                    .sheet(isPresented: $showFuelHistoryView, content: {
                                        FuelHistoryView(showFuelHistoryView: $showFuelHistoryView, vehicle: vehicle)
                                    })
                                }
                            }
                        }
        
                        Section {
                            ScrollView {
                                NewEntryStackView(foregroundColor: Color(AppColors.red.rawValue), width: geo.size.width, title: "New Service Entry")
                                    .foregroundStyle(Color(AppColors.invertRed.rawValue))
                                .onTapGesture {
                                    showServiceEntryForm.toggle()
                                }
                                .sheet(isPresented: $showServiceEntryForm, content: {
                                    ServiceEntryForm(showServiceEntryForm: $showServiceEntryForm)
                                })
                                ForEach(vehicle.getServices, id: \.self.uniqueID) { autoService in
                                    if vehicle.getServices.firstIndex(of: autoService)! <= 2 {
                                        CustomListView(date: autoService.getDateString, text1: ("Auto Shop",autoService.location!), text2: ("",""), text3: ("Cost","$" + String(format:"%.2f",autoService.cost)), text4: "", timeStamp: "Updated on: " + autoService.getTimeStamp, fuelEntry: false, width: geo.size.width)
                                    }
                                }
                            }
                            .frame(width:geo.size.width - 20, height: geo.size.height/1.5)
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
                                    .shadow(color: bgMode == .dark ? Color(UIColor.darkGray)  : .black, radius: 1, x: 1, y: 1)
                                    .sheet(isPresented: $showServiceHistoryView, content: {
                                        ServiceHistoryView(showServiceHistoryView: $showServiceHistoryView, vehicle: vehicle)
                                    })
                                }
                            }
                        }
                    }
                }
                
                
                .frame(width: geo.size.width, height: geo.size.height - 40)
              
                .navigationTitle("Auto Summary")
                
            
            }
            .onAppear {
                print("on Appear")
                guard let thisVehicle = vehicles.first(where: {$0.isActive}) else {
                    return
                }
                
                print("vehicle: ", thisVehicle.getVehicleText)
                guard let thisAutoSummary = reports.first(where: {$0.vehicle == thisVehicle && $0.getCalenderYear == currentYear}) else {
                    return
                }
                
                print("Summary year: ", thisAutoSummary.calenderYear)
                print("Summary Odometer: ", thisAutoSummary.odometerStart)
                if thisAutoSummary.odometerStart == 0.0 {
                    showOdometerAlert = true
                }
                else {
                    showOdometerAlert = false
                }
                
            }
            .alert("Set Vehicle Odometer", isPresented: $showOdometerAlert) {
                TextField("Odometer Start Readings", value: $odometerStart, format: .number)
                
                Button("OK", action: setOdometer)
                Button("Cancel", role: .cancel) {}
               
            } message: {
                HStack {
                    Text("What was it On Jan 01, " + currentYear + "?")
                    Text("in " + settings.first!.getDistanceUnit)
                }
            }
        }
    }
    
    func setOdometer() {
        guard let thisSettings = settings.first else {
            return
        }
        guard let thisVehicle = vehicles.first(where: {$0.isActive}) else {
            return
        }
        guard let index = reports.firstIndex(where: {$0.vehicle == thisVehicle && $0.getCalenderYear == currentYear}) else {
            return
        }
        
        if odometerStart == 0.0 {
            odometerStart = 0.1
        }
                    
        if thisSettings.getDistanceUnit == "km" {
            reports[index].odometerStart = odometerStart
            reports[index].odometerStartMiles = odometerStart / 1.609
            print("in km: ", reports[index].odometerStart)
        }
        else {
            reports[index].odometerStartMiles = odometerStart
            reports[index].odometerStart = odometerStart * 1.609
            print("in mi: ", reports[index].odometerStartMiles)
        }
        AutoSummary.saveContext(viewContext: viewContext)
      
    }
    
    ///function to get the vehicle fuel efficiency
    func getFuelEfficiency() -> Double {
        ///get the first vehicle from entity of vehicles which is currently active.
        guard let vehicle = vehicles.first(where: {$0.isActive}) else {
            return 0
        }
        ///get the first settings object from settings entity
        guard let setting = settings.first else {
            return 0
        }
        ///local variable to calculate accumulated vehicle trips
        var accumulatedTrip = 0.0
        ///local variable to calculate accumulated fuel volume
        var accumulatedFuelVolume = 0.0
        ///iterate through the fuelling entries filtered by vehicle fuel mode (gas or ev)
        for fuelling in vehicle.getFuellings.filter({$0.fuelType == vehicle.fuelMode}) {
            ///if the distance unit is set to km
            if setting.distanceUnit == "km" {
                ///caculate the trip total in km
                accumulatedTrip += fuelling.lasttrip != 0 ? fuelling.lasttrip : fuelling.getLastTripKm
            }
            ///if the distance unit is set to miles
            else if setting.distanceUnit == "miles" {
                ///calculate the trip total in miles. if trip in miles is 0 then get it converted from trip in km.
                accumulatedTrip += fuelling.lastTripMiles != 0 ?  fuelling.lastTripMiles :  fuelling.getLastTripMiles
            }
            ///if the fuel volume is set to litre
            if setting.getFuelVolumeUnit == "Litre" {
                ///calculate the fuelling volume total in litre
                accumulatedFuelVolume += fuelling.litre != 0 ? fuelling.litre : fuelling.getVolumeLitre
            }
            ///if the fuel volume is set to gallon
            else if setting.getFuelVolumeUnit == "Gallon" {
                ///calculate the fuelling volume total in gallon
                accumulatedFuelVolume += fuelling.gallon != 0 ? fuelling.gallon : fuelling.getVolumeGallons
            }
            ///if the fuel volume  unit is set to percentage
            else {
                ///calculate the fuel volume in  % of  battery charged.
                accumulatedFuelVolume += (fuelling.percent * vehicle.batteryCapacity)/100
            }
            
        }
        ///now calcuate the fuel efficiency from the accumulated trip divided by fuel volume.
        vehicle.fuelEfficiency = accumulatedTrip/accumulatedFuelVolume
        if let efficiencyUnit = settings.first!.fuelEfficiencyUnit {
            if efficiencyUnit == "L/100km" || efficiencyUnit == "L/100miles" || efficiencyUnit == "gl/100km" || efficiencyUnit == "gl/100miles" {
                vehicle.fuelEfficiency = 100/vehicle.fuelEfficiency
            }
        }
      ///return the value.
        return vehicle.fuelEfficiency

    }
    
    func isFuellingDataEmpty() -> Bool {
        guard let thisVehicle = vehicles.first(where: {$0.isActive}) else {
            return false
        }
         let fuellings = thisVehicle.getFuellings.filter({Calendar.current.component(.year, from: $0.getShortDate) == Int(currentYear)})
        
        if fuellings.isEmpty {
            return true
        }
        else {
            return false
        }
    }
    
    func resetSummaryFields(in autoSummary: AutoSummary) {
        autoSummary.annualTrip = 0
        autoSummary.annualTripMiles = 0
        autoSummary.litreConsumed = 0
        autoSummary.gallonsConsumed = 0
        autoSummary.annualMileage = 0
        autoSummary.annualFuelCost = 0
        autoSummary.annualTripEV  = 0
        autoSummary.annualTripEVMiles  = 0
        autoSummary.kwhConsumed = 0
        autoSummary.annualMileageEV = 0
        autoSummary.annualfuelCostEV = 0
        autoSummary.annualServiceCost = 0
        autoSummary.annualServiceCostEV = 0
    }
}

#Preview {
    AutoStatsView(locationDataManager: LocationDataManager())
}
