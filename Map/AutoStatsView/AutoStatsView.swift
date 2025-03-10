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
    @State private var odometerTextfield = 0.0
   
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
                if let vehicle = vehicles.first(where: {$0.isActive}) {
                    if let thisSettings = vehicle.settings {
                        List {                            
                            Section {
                                LazyHGrid(rows: rows) {
                                    DashGridItemView(title: "ODOMETER", foreGroundColor: Color(AppColors.invertPurple.rawValue), backGroundColor: Color(AppColors.purple.rawValue), numericText: thisSettings.getDistanceUnit == "km" ? numberFormatter.string(for: vehicle.odometer) ?? "--" : numberFormatter.string(for: vehicle.odometerMiles) ?? "--", unitText: thisSettings.getDistanceUnit, geometricSize: geo.size)
                                    
                                    ///get the first fuelling entry from fuellings array of this vehicle filtered by the current fuel mode.
                                    if let fuellingEntry = vehicle.getFuellings.filter({$0.fuelType == vehicle.fuelMode}).first {
                                        ///if fuel unit is in litre show value in litre
                                        if thisSettings.getFuelVolumeUnit == "Litre" {
                                            DashGridItemView(title: "LAST FUELLING", foreGroundColor: Color(AppColors.invertYellow.rawValue), backGroundColor: Color(AppColors.yellow.rawValue), numericText: deciNumberFormatter.string(for: fuellingEntry.litre != 0 ? fuellingEntry.litre : fuellingEntry.getVolumeLitre) ?? "--", unitText: thisSettings.getFuelVolumeUnit, geometricSize: geo.size)
                                        }
                                        ///if fuel unit is in gallon show value in gallon
                                        else if thisSettings.getFuelVolumeUnit == "Gallon" {
                                            DashGridItemView(title: "LAST FUELLING", foreGroundColor: Color(AppColors.invertYellow.rawValue), backGroundColor: Color(AppColors.yellow.rawValue), numericText: deciNumberFormatter.string(for: fuellingEntry.gallon != 0 ? fuellingEntry.gallon : fuellingEntry.getVolumeGallons) ?? "--", unitText: thisSettings.getFuelVolumeUnit, geometricSize: geo.size)
                                        }
                                        ///if fuel unit is in percent show value in percent
                                        else {
                                            DashGridItemView(title: "LAST FUELLING", foreGroundColor: Color(AppColors.invertYellow.rawValue), backGroundColor: Color(AppColors.yellow.rawValue), numericText: deciNumberFormatter.string(for: fuellingEntry.percent) ?? "--" , unitText: thisSettings.getFuelVolumeUnit, geometricSize: geo.size)
                                        }
                                    }
                                    ///if no records found keep it empty
                                    else {
                                        DashGridItemView(title: "LAST FUELLING", foreGroundColor: Color(AppColors.invertYellow.rawValue), backGroundColor: Color(AppColors.yellow.rawValue), numericText: "--" , unitText: thisSettings.getFuelVolumeUnit, geometricSize: geo.size)
                                    }
                                    DashGridItemView(title: "FUEL COST", foreGroundColor: Color(AppColors.invertOrange.rawValue), backGroundColor: Color(AppColors.orange.rawValue), numericText: currencyFormatter.string(for: vehicle.getfuelCost) ?? "--", unitText: currentYear, geometricSize: geo.size)
                                    ///if the fuel engine is hybrid
                                    if vehicle.fuelEngine == "Hybrid" {
                                        ///if fuel mode is set the gas engine mode, show the trips for gas mode
                                        if vehicle.fuelMode == "Gas" {
                                            DashGridItemView(title: "TRIP SINCE FUELLING", foreGroundColor: Color(AppColors.invertSky.rawValue), backGroundColor: Color(AppColors.sky.rawValue), numericText: thisSettings.getDistanceUnit == "km" ?
                                                             deciNumberFormatter.string(for: vehicle.trip) ?? "--" :  deciNumberFormatter.string(for: vehicle.tripMiles) ?? "--", unitText: thisSettings.getDistanceUnit, geometricSize: geo.size)
                                        }
                                        ///if fuel mode is set the EV engine mode, show the trips for EV mode
                                        else {
                                            DashGridItemView(title: "TRIP SINCE FUELLING", foreGroundColor: Color(AppColors.invertSky.rawValue), backGroundColor: Color(AppColors.sky.rawValue), numericText: thisSettings.getDistanceUnit == "km" ?
                                                             deciNumberFormatter.string(for: vehicle.tripHybridEV) ?? "--" :  deciNumberFormatter.string(for: vehicle.tripHybridEVMiles) ?? "--", unitText: thisSettings.getDistanceUnit, geometricSize: geo.size)
                                        }
                                    }
                                    ///if the fuel engine is not hybrid show the trip in given distance format.
                                    else {
                                        DashGridItemView(title: "TRIP SINCE FUELLING", foreGroundColor: Color(AppColors.invertSky.rawValue), backGroundColor: Color(AppColors.sky.rawValue), numericText: thisSettings.getDistanceUnit == "km" ?
                                                         deciNumberFormatter.string(for: vehicle.trip) ?? "--" :  deciNumberFormatter.string(for: vehicle.tripMiles) ?? "--", unitText: thisSettings.getDistanceUnit, geometricSize: geo.size)
                                    }
                                    DashGridItemView(title: "MILEAGE", foreGroundColor: Color(AppColors.invertGreen.rawValue), backGroundColor:Color(AppColors.green.rawValue), numericText: deciNumberFormatter.string(for: efficiency) ?? "--", unitText: thisSettings.getFuelEfficiencyUnit, geometricSize: geo.size)
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
                                            if thisSettings.getFuelVolumeUnit == "Litre" {
                                                CustomListView(date: fuelData.getDateString, text1: ("Fuel Station",fuelData.location!), text2:("Volume", (String(format:"%.2f",fuelData.litre != 0.0 ? fuelData.litre : fuelData.getVolumeLitre) + "L")), text3: ("Cost","$" + String(format:"%.2f",fuelData.cost)), text4: thisSettings.getDistanceUnit == "km" ? String(format:"%.1f", fuelData.lasttrip) + " km" : String(format:"%.1f", fuelData.getLastTripMiles) + " miles" , timeStamp: "Updated on: " + fuelData.getTimeStamp, fuelEntry: true, width: geo.size.width)
                                            }
                                            else if thisSettings.getFuelVolumeUnit == "Gallon" {
                                                CustomListView(date: fuelData.getDateString, text1: ("Fuel Station",fuelData.location!), text2:("Volume", (String(format:"%.2f",fuelData.gallon != 0.0 ? fuelData.gallon : fuelData.getVolumeGallons) + "GL")), text3: ("Cost","$" + String(format:"%.2f",fuelData.cost)), text4: thisSettings.getDistanceUnit == "km" ? String(format:"%.1f", fuelData.lasttrip) + " km" : String(format:"%.1f", fuelData.getLastTripMiles) + " miles" , timeStamp: "Updated on: " + fuelData.getTimeStamp, fuelEntry: true, width: geo.size.width)
                                            }
                                            else  {
                                                CustomListView(date: fuelData.getDateString, text1: ("Fuel Station",fuelData.location!), text2:("Volume", (String(format:"%.2f",fuelData.percent) + "%")), text3: ("Cost","$" + String(format:"%.2f",fuelData.cost)), text4: thisSettings.getDistanceUnit == "km" ? String(format:"%.1f", fuelData.lasttrip) + " km" : String(format:"%.1f", fuelData.getLastTripMiles) + " miles" , timeStamp: "Updated on: " + fuelData.getTimeStamp, fuelEntry: true, width: geo.size.width)
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
                        .frame(width: geo.size.width, height: geo.size.height - 40)
                        .navigationTitle("Auto Summary")
                    }
                }
                
                
              
              
              
                
            
            }
            ///on appear of this swiftui view
            .onAppear {
                print("on Appear")
                ///get the active vehicle from the vehicles entity list
                guard let thisVehicle = vehicles.first(where: {$0.isActive}) else {
                    return
                }
                print("vehicle: ", thisVehicle.getVehicleText)
                ///if vehicle odometer is set to 0.
                if thisVehicle.odometer < 1 || thisVehicle.odometerMiles < 1 {
                    ///set this flag to show the alert view
                    showOdometerAlert = true
                }
                ///if vehicle odometer is greater than 0.
                else {
                    ///don't show the alert view.
                    showOdometerAlert = false
                }
            }
            ///modifier to show the alert with a headline and boolean variable to show/hide alert.
            .alert("Set Vehicle Odometer", isPresented: $showOdometerAlert) {
                ///body of the alert modifier to set its appearance
                ///show the text field to enter the odometer value to set it for a given vehicle
                TextField("Odometer Readings", value: $odometerTextfield, format: .number)
                ///Ok button. On tap of it, execute setOdometer function
                Button("OK", action: setOdometer)
                ///Cancel button. On tap of it, do nothing
                Button("Cancel", role: .cancel) {}
               
            }
            ///message parameter of the alert will show the subheadline.
            message: {
                ///show the textfield with message.
                Text("Please set your odometer to the latest from vehicle dashboard.")
            }
        }
    }
    
    ///function to set odometer
    func setOdometer() {
        
        ///get the vehicle index from the vehicles entity list which is currently active.
        guard let index = vehicles.firstIndex(where: {$0.isActive}) else {
            return
        }
        ///get the first element from the settings.
        guard let thisSettings = vehicles[index].settings else {
            return
        }
        ///get the report index from the reports where report belongs to the given vehicle and a current year.
        guard let reportIndex = reports.firstIndex(where: {$0.vehicle == vehicles[index] && $0.getCalenderYear == currentYear }) else {
            return
        }
        ///if the distance unit is set to km in settings tab
        if thisSettings.getDistanceUnit == "km" {
            ///set the vehicle odometer in km.
            vehicles[index].odometer = odometerTextfield
            ///convert from km to miles and set the vehicle odometer.
            vehicles[index].odometerMiles = odometerTextfield / 1.609
            ///set the odometer end in km in report's current year of a current vehicle
            reports[reportIndex].odometerEnd = odometerTextfield
            ///convert from km to miles and set the odometer end in km in report's current year of a current vehicle
            reports[reportIndex].odometerEndMiles = odometerTextfield / 1.609
        }
        ///if the distance unit is set to miles in settings tab
        else {
            ///set the vehicle odometer in miles.
            vehicles[index].odometerMiles = odometerTextfield
            ///convert from miles to km and set the vehicle odometer.
            vehicles[index].odometer = odometerTextfield * 1.609
            ///set the odometer end in km  in report's current year of a current vehicle
            reports[reportIndex].odometerEndMiles = odometerTextfield
            ///convert from miles to km and set the odometer end in km in report's current year of a current vehicle
            reports[reportIndex].odometerEnd = odometerTextfield * 1.609
        }
        ///save the changes in core data viewcontext.
        AutoSummary.saveContext(viewContext: viewContext)
      
    }
    
    ///function to get the vehicle fuel efficiency
    func getFuelEfficiency() -> Double {
        ///get the first vehicle from entity of vehicles which is currently active.
        guard let vehicle = vehicles.first(where: {$0.isActive}) else {
            return 0
        }
        ///get the first settings object from settings entity
        guard let thisSettings = vehicle.settings else {
            return 0
        }
        ///local variable to calculate accumulated vehicle trips
        var accumulatedTrip = 0.0
        ///local variable to calculate accumulated fuel volume
        var accumulatedFuelVolume = 0.0
        ///iterate through the fuelling entries filtered by vehicle fuel mode (gas or ev)
        for fuelling in vehicle.getFuellings.filter({$0.fuelType == vehicle.fuelMode}) {
            ///if the distance unit is set to km
            if thisSettings.distanceUnit == "km" {
                ///caculate the trip total in km
                accumulatedTrip += fuelling.lasttrip != 0 ? fuelling.lasttrip : fuelling.getLastTripKm
            }
            ///if the distance unit is set to miles
            else if thisSettings.distanceUnit == "miles" {
                ///calculate the trip total in miles. if trip in miles is 0 then get it converted from trip in km.
                accumulatedTrip += fuelling.lastTripMiles != 0 ?  fuelling.lastTripMiles :  fuelling.getLastTripMiles
            }
            ///if the fuel volume is set to litre
            if thisSettings.getFuelVolumeUnit == "Litre" {
                ///calculate the fuelling volume total in litre
                accumulatedFuelVolume += fuelling.litre != 0 ? fuelling.litre : fuelling.getVolumeLitre
            }
            ///if the fuel volume is set to gallon
            else if thisSettings.getFuelVolumeUnit == "Gallon" {
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
        if let efficiencyUnit = thisSettings.fuelEfficiencyUnit {
            if efficiencyUnit == "L/100km" || efficiencyUnit == "L/100miles" || efficiencyUnit == "gl/100km" || efficiencyUnit == "gl/100miles" {
                vehicle.fuelEfficiency = 100/vehicle.fuelEfficiency
            }
        }
      ///return the value.
        return vehicle.fuelEfficiency

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
