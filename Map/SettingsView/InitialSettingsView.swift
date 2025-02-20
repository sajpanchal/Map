//
//  InitialSettingsView.swift
//  Map
//
//  Created by saj panchal on 2024-07-15.
//

import SwiftUI

struct InitialSettingsView: View {
    @Environment(\.colorScheme) var bgMode: ColorScheme
    ///viewContext is the environment object of managed view context of core data stack.
    @Environment(\.managedObjectContext) private var viewContext
    ///state object that handles tasks of the location manger
    @StateObject var locationDataManager: LocationDataManager
    ///state variable that stores vehicle type enum value
    @State private var vehicleType: VehicleTypes = .Car
    ///state variable that stores vehicle make enum value
    @State private var vehicleMake: VehicleMake = .AC
    ///state variable that stores alphabets enum value
    @State private var alphabet: Alphbets = .A
    ///state variable that stores vehicle model enum value
    @State private var model: Model = .Ace
    ///state variable that stores vehicle manufacturing year.
    @State private var year = (Calendar.current.dateComponents([.year], from: Date())).year ?? 1900
    @State private var calendarYear = (Calendar.current.dateComponents([.year], from: Date())).year
    ///state variable that stores the range of vehicle manufacturing year
    @State private var yearRange = 1900..<((Calendar.current.dateComponents([.year], from: Date())).year ?? 1900) + 1
    ///state variable that stores vehicle engine type enum value
    @State private var engineType = EngineType.Gas
    ///state variable stores the odometer readings value for the textfield
    @State private var odometer = 0
    ///state variable stores the odometer readings value for the textfield
    @State private var odometerMiles = 0
    ///state variable stores the trip odometer readings value for the textfield
    @State private var trip = 0.0
    ///state variable stores the trip odometer readings value for the textfield
    @State private var tripMiles = 0.0
    ///state variable stores the trip odometer readings value for the textfield
    @State private var tripHybridEV = 0.0
    ///state variable stores the trip odometer readings value for the textfield
    @State private var tripHybridEVMiles = 0.0
    ///state variable stores the distance unit enum value
    @State private var distanceUnit: DistanceUnit = .km
    ///state variable stores the fuel unit enum value
    @State private var fuelUnit: FuelUnit = .Litre
    ///state variable stores the fuel unit enum value
    @State private var fuelMode: FuelMode = .Gas
    ///enum type to store the fuel unit.
    @State private var batteryCapacity = 40.0
    ///array of fuel efficiencies.
    @State private var efficiencyUnits = ["km/L", "L/100km", "miles/L","L/100Miles", "km/gl",  "gl/100km", "miles/gl", "gl/100miles", "km/kwh", "miles/kwh"]
    ///state variable stores the index of efficiencyUnits array
    @State private var efficiencyUnitIndex = 0
    ///state variable to hide/show the add vehicle form view.
    @State private var showAddVehicleForm = false
    ///state variable stores vehicle make in string format
    @State private var textVehicleMake = ""
    ///state variable stores vehicle model in string format
    @State private var textVehicleModel = ""
    ///state variable to decide whether to avoid highways or not
    @State private var avoidHighways = false
    ///state variable to decide whether to avoid tolls or not
    @State private var avoidTolls = false
    @State private var showAlert = false
    @Binding var isInitialized: Bool
    var body: some View {
        NavigationStack {
            ZStack {
                VStack {
                    ///initial settings form view
                    Form {
                        ///picker for vehicle type selection.
                        Section("Vehicle Type") {
                            Picker("Select Type", selection: $vehicleType) {
                                ForEach(VehicleTypes.allCases) { thisVehicleType in
                                    Text(thisVehicleType.rawValue)
                                }
                            }
                        }
                        ///textfield to enter vehicle make
                        Section("Vehicle Make") {
                            TextField("Enter/Select your vehicle make", text: $textVehicleMake)
                        }
                        if textVehicleMake.isEmpty {
                            Text("vehicle make can not be empty!")
                                .font(.caption2)
                                .foregroundStyle(.red)
                        }
                        ///picker for vehicle make selection.
                        Section("") {
                            HStack {
                                Picker("Select Make", selection: $alphabet) {
                                    ForEach(Alphbets.allCases) { thisAlphabet in
                                        Text(thisAlphabet.rawValue)
                                    }
                                }
                                ///on change of alphabet
                                .onChange(of:$alphabet.id) {
                                    ///continue if for the given alphabet's first vehicle make is not nil
                                    guard let thisVehicleMake = alphabet.makes.first else {
                                        return
                                    }
                                    ///set the first make of the alphabet on selection
                                    vehicleMake = thisVehicleMake
                                    
                                    ///continue if for the given vehicle make's first vehicle model is not nil
                                    guard let thisVehicleModel = thisVehicleMake.models.first else {
                                        return
                                    }
                                    ///set the first model of the vehicle make on selection
                                    model = thisVehicleModel
                                    ///update the textfield of vehicle make with the formated text.
                                    textVehicleMake = vehicleMake.rawValue.replacingOccurrences(of: "_", with: " ")
                                   
                                }
                                .pickerStyle(.wheel)
                                ///picke for vehicle make selection
                                Picker("", selection:$vehicleMake) {
                                    ForEach(alphabet.makes) { make in
                                        Text(make.rawValue)
                                    }
                                }
                                ///on change of vehicle make ID
                                .onChange(of: $vehicleMake.id) {
                                    ///update the vehicle make text with formated vehicle make string
                                    textVehicleMake = vehicleMake.rawValue.replacingOccurrences(of: "_", with: " ")
                                    ///check if the first model of vehicle make is available
                                    guard let thisVehicleModel = vehicleMake.models.first else {
                                        return
                                    }
                                    ///store the formated model text to textfield
                                    textVehicleModel = thisVehicleModel.rawValue.replacingOccurrences(of: "_", with: " ")
                                }
                                .pickerStyle(.wheel)
                            }
                        }
                        ///textfeid to store desired or selected vehicle model.
                        Section("Vehicle Model") {
                            TextField("Enter/Select your vehicle model", text: $textVehicleModel)
                        }
                        if textVehicleModel.isEmpty {
                            Text("vehicle model can not be empty!")
                                .font(.caption2)
                                .foregroundStyle(.red)
                        }
                        ///picker for vehicle model selection
                        Section("") {
                            Picker("Select Model", selection: $model) {
                                ForEach(vehicleMake.models, id: \.id) { thisModel in
                                    Text(thisModel.rawValue.replacingOccurrences(of: "_", with: " "))
                                }
                            }
                            ///on change of vehicle model ID.
                            .onChange(of: model.id) {
                                ///update the textfield with given model formated text.
                                textVehicleModel = model.rawValue.replacingOccurrences(of: "_", with: " ")
                            }
                            .pickerStyle(.wheel)
                        }
                        ///picke for vehicle manufacturing year.
                        Section("Manufacuring Year") {
                            Picker("Select Year", selection: $year) {
                                ForEach(yearRange.reversed(), id: \.self) { i in
                                    Text(String(i))
                                }
                            }
                            .pickerStyle(.wheel)
                        }
                        ///picker for vehicle fuel engine type
                        Section("Fuel Engine Type") {
                            Picker("Select Type", selection:$engineType) {
                                ForEach(EngineType.allCases) { thisFuelType in
                                    Text(thisFuelType.rawValue)
                                }
                            }
                            .pickerStyle(.segmented)
                        }
                        .onChange(of: engineType) {
                            if engineType != .Hybrid {
                                fuelMode = FuelMode(rawValue: engineType.rawValue) ?? .Gas
                            }
                                
                            
                        }
                        .onChange(of: fuelMode) {
                            if fuelMode == .EV {
                                fuelUnit = .Percent
                            }
                            else {
                                fuelUnit = .Litre
                            }
                        }
                        if engineType != .Gas {
                            Section(header: Text("EV Battery Capacity in KWh").fontWeight(.bold)) {
                                TextField("Enter battery capacity in kwh", value: $batteryCapacity, format: .number)
                                    .keyboardType(.decimalPad)
                            }
                        }
                        if engineType == .Hybrid {
                            ///picker for vehicle fuel engine type
                            Section("Fuel Mode") {
                                Picker("Select Mode", selection:$fuelMode) {
                                    ForEach(FuelMode.allCases) { thisFuelMode in
                                        Text(thisFuelMode.rawValue)
                                    }
                                }
                                .onChange(of: fuelMode) {
                                    if fuelMode == .EV {
                                        fuelUnit = .Percent
                                    }
                                    else {
                                        fuelUnit = .Litre
                                    }
                                }
                                .pickerStyle(.segmented)
                            }
                        }
                        ///section for navigation preferences
                        Section(header: Text("Navigation Preferences").fontWeight(.bold)) {
                            ///toggle switch to avoid tolls
                            Toggle("Avoid Tolls", isOn: $avoidTolls)
                            ///toggle switch to avoid highways
                            Toggle("Avoid Highways", isOn: $avoidHighways)
                        }
                        ///picker for vehicle distance unit selection
                        Section(header: Text("Distance Unit")) {
                            Picker("Select Unit", selection: $distanceUnit) {
                                ForEach(DistanceUnit.allCases) { thisDistanceUnit in
                                    Text(thisDistanceUnit.rawValue.capitalized)
                                }
                            }
                            .pickerStyle(.segmented)
                        }

                            if distanceUnit == .km {
                                ///textfield to enter/update vehicle odometer readings
                                Section("Vehicle Odometer (in Km)") {
                                    TextField("Enter the odometer readings", value: $odometer, format: .number)
                                    ///on change of odometer
                                        .onChange(of: odometer) {
                                            ///convert the odometer in km to miles
                                            let odometerDouble = Double(odometer)
                                            odometerMiles = Int(odometerDouble * 0.6214)
                                        }
                                        .keyboardType(.numberPad)
                                }
                                ///textfield to enter/update vehicle trip odometer readings
                                Section("Vehicle Trip (in Km)") {
                                    TextField("Enter the Trip readings", value: $trip, format: .number)
                                    ///on change of trip
                                        .onChange(of: trip) {
                                            ///convert the trip in km to miles
                                            let tripDouble = Double(trip)
                                            tripMiles = tripDouble * 0.6214
                                        }
                                        .keyboardType(.decimalPad)
                                }
                                if engineType == .Hybrid {
                                    ///textfield to enter/update vehicle trip odometer readings
                                    Section("Vehicle Trip for EV mode (in Km)") {
                                        TextField("Enter the Trip readings", value: $tripHybridEV, format: .number)
                                        ///on change of trip
                                            .onChange(of: tripHybridEV) {
                                                ///convert the trip in km to miles
                                                let tripDouble = Double(tripHybridEV)
                                                tripHybridEVMiles = tripDouble * 0.6214
                                            }
                                            .keyboardType(.decimalPad)
                                    }
                                }
                            }
                            else {
                                ///textfield to enter/update vehicle odometer readings
                                Section("Vehicle Odometer (in Miles)") {
                                    TextField("Enter the odometer readings", value: $odometerMiles, format: .number)
                                    ///on change of odometerMiles
                                        .onChange(of: odometerMiles) {
                                            ///convert the odometer in miles to km.
                                            let odometerMilesDouble = Double(odometerMiles)
                                            odometer = Int(odometerMilesDouble / 0.6214)
                                        }
                                        .keyboardType(.numberPad)
                                }
                                ///textfield to enter/update vehicle trip odometer readings
                                Section("Vehicle Trip (in Miles)") {
                                    TextField("Enter the Trip readings", value: $tripMiles, format: .number)
                                    ///on change of tripMiles
                                        .onChange(of: tripMiles) {
                                            ///convert the trip in miles to km.
                                            let tripMilesDouble = Double(tripMiles)
                                            trip = tripMilesDouble / 0.6214
                                        }
                                        .keyboardType(.decimalPad)
                                }
                                if engineType == .Hybrid {
                                    ///textfield to enter/update vehicle trip odometer readings
                                    Section("Vehicle Trip for EV mode (in Miles)") {
                                        TextField("Enter the Trip readings", value: $tripHybridEVMiles, format: .number)
                                        ///on change of tripMiles
                                            .onChange(of: tripHybridEVMiles) {
                                                ///convert the trip in miles to km.
                                                let tripMilesDouble = Double(tripHybridEVMiles)
                                                tripHybridEV = tripMilesDouble / 0.6214
                                            }
                                            .keyboardType(.decimalPad)
                                    }
                                }
                            }
                        ///if engine type of the vehicle is gas type
                        if fuelMode == .Gas {
                            ///picker for fuel volume unit selection
                            Section(header: Text("Fuel Volume Unit")) {
                                Picker("Select Unit", selection: $fuelUnit) {
                                    ForEach(FuelUnit.allCases) { thisFuelMode in
                                        if thisFuelMode != .Percent {
                                            Text(thisFuelMode.rawValue.capitalized)
                                        }
                                    }
                                }
                                .pickerStyle(.segmented)
                            }
                        }
                        ///if fuel mode is EV
                        else {
                            ///picker for fuel volume unit selection
                            Section(header: Text("Fuel Volume Unit")) {
                                Picker("Select Unit", selection: $fuelUnit) {
                                    ForEach(FuelUnit.allCases) { thisFuelMode in
                                        if thisFuelMode == .Percent {
                                            Text(thisFuelMode.rawValue.capitalized)
                                        }
                                     
                                    }
                                }
                                .pickerStyle(.segmented)
                            }
                        }
                        ///if engine type of the vehicle is gas or hybrid.
                        if fuelMode == .Gas {
                            ///picker for efficiency unit selection
                            Section(header: Text("Fuel Efficiency Unit")) {
                                ///check if the fuel unit is set to liter
                                if fuelUnit == .Litre {
                                    ///if the distance unit is set to km.
                                    if distanceUnit == .km {
                                        ///picker to select fuel efficiency unit
                                        Picker("Select Unit", selection: $efficiencyUnitIndex) {
                                            ForEach(efficiencyUnits.indices, id: \.self) { index in
                                                ///if fuel index is 0 or 1.
                                                if index < 2 {
                                                    Text(efficiencyUnits[index])
                                                }
                                            }
                                        }
                                        ///on appear of this picker set the efficiency unit index to 0 if previous index is multiple of 2 or 1.
                                        .onAppear(perform: {
                                            efficiencyUnitIndex = efficiencyUnitIndex.isMultiple(of: 2) ? 0 : 1
                                        })
                                        .pickerStyle(.segmented)
                                    }
                                    ///if distance unit is in miles
                                    else {
                                        ///picker to select fuel efficiency unit
                                        Picker("Select Unit", selection: $efficiencyUnitIndex) {
                                            ForEach(efficiencyUnits.indices, id: \.self) { index in
                                                ///if fuel index is 2 or 3.
                                                if index > 1 && index < 4 {
                                                    Text(efficiencyUnits[index])
                                                }
                                            }
                                        }
                                        ///on appear of this picker set the efficiency unit index to 0 if previous index is multiple of 2 or 1.
                                        .onAppear(perform: {
                                            efficiencyUnitIndex = efficiencyUnitIndex.isMultiple(of: 2) ? 2 : 3
                                        })
                                        .pickerStyle(.segmented)
                                    }
                                }
                                ///if fuel unit is in gallons
                                else if fuelUnit == .Gallon {
                                    ///if distance unit is in km
                                    if distanceUnit == .km {
                                        Picker("Select Unit", selection: $efficiencyUnitIndex) {
                                            ForEach(efficiencyUnits.indices, id: \.self) { index in
                                                ///if fuel index is 4 or 5.
                                                if index > 3 && index < 6 {
                                                    Text(efficiencyUnits[index])
                                                }
                                            }
                                        }
                                        ///on appear of this picker set the efficiency unit index to 0 if previous index is multiple of 2 or 1.
                                        .onAppear(perform: {
                                            efficiencyUnitIndex = efficiencyUnitIndex.isMultiple(of: 2) ? 4 : 5
                                        })
                                        .pickerStyle(.segmented)
                                    }
                                    ///if distance unit is in miles
                                    else {
                                        Picker("Select Unit", selection: $efficiencyUnitIndex) {
                                            ForEach(efficiencyUnits.indices, id: \.self) { index in
                                                ///if fuel index is 6 or 7.
                                                if index > 5 && index < 8 {
                                                    Text(efficiencyUnits[index])
                                                }
                                            }
                                        }
                                        ///on appear of this picker set the efficiency unit index to 0 if previous index is multiple of 2 or 1.
                                        .onAppear(perform: {
                                            efficiencyUnitIndex = efficiencyUnitIndex.isMultiple(of: 2) ? 6 : 7
                                        })
                                        .pickerStyle(.segmented)
                                    }
                                }
                            }
                        }
                        ///if the engine type of the vehicle is electric
                        else {
                            ///picke for selecting fuel efficiency
                            Section(header: Text("Fuel Efficiency Unit")) {
                                ///if the distance unit is in km.
                                if distanceUnit == .km {
                                    Picker("Select Unit", selection: $efficiencyUnitIndex) {
                                        ForEach(efficiencyUnits.indices, id: \.self) { index in
                                            ///if the efficiency unit index is at 8
                                            if index == 8 {
                                                Text(efficiencyUnits[index])
                                            }
                                        }
                                    }
                                    ///on appear of the picker set the index to 8 for picker item to be selected predefined.
                                    .onAppear(perform: {
                                        efficiencyUnitIndex = 8
                                    })
                                    .pickerStyle(.segmented)
                                }
                                ///if the distance unit is in miles.
                                else {
                                    Picker("Select Unit", selection: $efficiencyUnitIndex) {
                                        ForEach(efficiencyUnits.indices, id: \.self) { index in
                                            ///if the efficiency unit index is at 9
                                            if index == 9 {
                                                Text(efficiencyUnits[index])
                                            }
                                        }
                                    }
                                    ///on appear of the picker set the index to 9 for picker item to be selected predefined.
                                    .onAppear(perform: {
                                        efficiencyUnitIndex = 9
                                    })
                                    .pickerStyle(.segmented)
                                }
                            }
                        }
                        ///vstack enclosing the form submit button view.
                        VStack {
                            HStack {
                                Spacer()
                                Button {
                                    if !textVehicleMake.isEmpty && !textVehicleModel.isEmpty {
                                        ///on tap of the button, instantiate a vehicle entity object from the managed view context
                                        guard let vehicle = Vehicle.AddNewVehicle(viewContext: viewContext , getModel: {
                                            VehicleModel(vehicleType: vehicleType.rawValue, vehicleMake: vehicleMake.rawValue, model: textVehicleModel, year: year, engineType: engineType.rawValue, batteryCapacity: batteryCapacity, odometer: Double(odometer), odometerMiles: Double(odometerMiles), trip: trip, tripMiles: tripMiles, tripHybridEV: tripHybridEV, tripHybridEVMiles: tripHybridEVMiles,fuelMode: fuelMode.rawValue)
                                        }) else {
                                            return
                                        }
                                        ///add a new vehicle for this vehicle object created.
                                        let newSettings = Settings.createNewSettings(viewContext: viewContext, for: vehicle, getModel: {
                                            SettingsModel(autoEngineType: engineType.rawValue, distanceUnit: distanceUnit.rawValue, fuelEfficiencyUnit: efficiencyUnits[efficiencyUnitIndex], fuelVolumeUnit: fuelUnit.rawValue, avoidHighways: avoidHighways, avoidTolls: avoidTolls)
                                        })
                                        createSummary(in: newSettings, for: vehicle)
                                        print("------------Vehicle Added--------------")
                                        print("Name: ",vehicle.getVehicleText)
                                        print("trip: ",vehicle.trip)
                                        print("trip miles: ",vehicle.tripMiles)
                                        print("fuel mode: ",vehicle.fuelMode ?? "n/a")
                                        print("trip EV: ",vehicle.tripHybridEV)
                                        print("trip EV miles: ",vehicle.tripHybridEVMiles)
                                        print("odometer: ",vehicle.odometer)
                                        print("odometer Miles: ",vehicle.odometerMiles)
                                        print("battery: ",vehicle.batteryCapacity)
                                        print("fuel engine: ",vehicle.fuelEngine ?? "n/a")
                                        print("is active: ",vehicle.isActive)
                                        print("odometer Miles: ",vehicle.year)
                                        print("------------Vehicle Settings--------------")
                                        print(vehicle.settings ?? "n/a")
                                        print("------------Vehicle Summary--------------")
                                        print("summary count: ",vehicle.getReports.count)
                                        print("summary count: ",vehicle.getReports.first ?? "n/a")
                                        withAnimation(.easeIn(duration: 0.5)) {
                                            showAlert = true
                                            isInitialized = true
                                        }
                                        ///save the settings for this vehicle object created.
                                       // saveSettings(for: vehicle)
                                    }
                                } label: {
                                    ///button view ui.
                                    FormButton(imageName: "gearshape.fill", text: "Save Settings", color: Color(AppColors.pink.rawValue))
                                }
                                .background(Color(AppColors.invertPink.rawValue))
                                .buttonStyle(BorderlessButtonStyle())
                                .cornerRadius(100)
                                .shadow(color: bgMode == .dark ? .gray : .black, radius: 1, x: 1, y: 1)
                                Spacer()
                            }
                     
                        }
                        .listRowBackground(Color.clear)
                        .listRowInsets(EdgeInsets())
                    }
                }
                if showAlert {
                    AlertView(image: "checkmark.icloud", headline: "Settings Saved!", bgcolor: Color(AppColors.invertBlueColor.rawValue), showAlert: $showAlert)
                }
            }
          
           
            .onAppear {
                ///update textfield with the initial vehicle make
                textVehicleMake = vehicleMake.rawValue.replacingOccurrences(of: "_", with: " ")
                ///update textfield with the initial vehicle model
                textVehicleModel = model.rawValue.replacingOccurrences(of: "_", with: " ")
            }
            .navigationTitle("Settings")
        }
    }
    func createSummary(in newSettings: Settings, for newVehicle: Vehicle) {
        if let calYear = calendarYear {
            AutoSummary.createNewReport(viewContext: viewContext, in: newSettings, for: newVehicle, year: calYear)
        }
    }
   /* func addVehicle(for vehicle: Vehicle) {
        ///get the current year from calender.
        let calendaryear =  Calendar.current.component(.year, from: Date())
        ///instantiate autosummary object
        let autoSummary = AutoSummary(context: viewContext)
        ///save the calender year in autosummary
        autoSummary.calenderYear = Int16(calendaryear)
        ///set unique id.
        vehicle.uniqueID = UUID()
        ///set model name string
        vehicle.model = textVehicleModel
        ///set vehicle make string
        vehicle.make = textVehicleMake
        ///set vehicle manufacturing year.
        vehicle.year = Int16(year)
        ///set vehicle odometer in decimal format
        vehicle.odometer = Double(odometer)
        ///set autosummary odometer start to set odometer
        autoSummary.odometerStart = Double(odometer)
        ///set autosummary odometer end to set odometer
        autoSummary.odometerEnd = Double(odometer)
        ///set vehicle odometer in decimal format
        vehicle.odometerMiles = Double(odometerMiles)
        ///set autosummary odometer end to set odometer in miles.
        autoSummary.odometerStartMiles = Double(odometerMiles)
        ///set autosummary odometer end to set odometer in miles.
        autoSummary.odometerEndMiles = Double(odometerMiles)
        if distanceUnit == .km {
            ///set vehicle trip odometer in decimal format
            vehicle.trip = trip
            autoSummary.annualTrip = trip
            ///set vehicle trip odometer in decimal format
            vehicle.tripMiles =  vehicle.trip * 0.6214
            autoSummary.annualTripMiles =  vehicle.trip * 0.6214
        }
        else {
            ///set vehicle trip odometer in decimal format
            vehicle.tripMiles = tripMiles
            autoSummary.annualTripMiles = tripMiles
            ///set vehicle trip odometer in decimal format
            vehicle.trip = vehicle.tripMiles / 0.6214
            autoSummary.annualTrip =  vehicle.tripMiles / 0.6214
        }
        if engineType == .Hybrid {
            if distanceUnit == .km {
                ///set vehicle trip odometer in decimal format
                vehicle.tripHybridEV = tripHybridEV
                autoSummary.annualTripEV = tripHybridEV
                ///set vehicle trip odometer in decimal format
                vehicle.tripHybridEVMiles =  vehicle.tripHybridEV * 0.6214
                autoSummary.annualTripEVMiles = vehicle.tripHybridEV * 0.6214
            }
            else {
                ///set vehicle trip odometer in decimal format
                vehicle.tripHybridEVMiles = tripHybridEVMiles
                autoSummary.annualTripEVMiles = tripHybridEVMiles
                ///set vehicle trip odometer in decimal format
                vehicle.tripHybridEV = vehicle.tripHybridEVMiles / 0.6214
                autoSummary.annualTripEV = vehicle.tripHybridEVMiles / 0.6214
            }
        }

        ///set vehicle fuel engine type in string format
        vehicle.fuelEngine = engineType.rawValue
        //
        if engineType != .Gas {
            vehicle.batteryCapacity = batteryCapacity
        }
       
        ///set vehicle type in string format
        vehicle.type = vehicleType.rawValue
        ///set vehicle as active vehicle as it is the only vehicle available initially.
        vehicle.isActive = true
        vehicle.fuelMode = fuelMode.rawValue
        vehicle.addToReports(autoSummary)
        ///save the managed view context to the core data store with new changes.
       
    }*/
    
   /* func saveSettings(for vehicle: Vehicle) {
        ///create a settings object from viewcontext's settings entity
        let settings = Settings(context: viewContext)
        ///update the preferences for highways
        settings.avoidHighways = avoidHighways
        ///update the preferences for tolls
        settings.avoidTolls = avoidTolls
        ///assign a current vehicle that is active
        settings.vehicle = vehicle
        ///set the engine type in string format
        settings.autoEngineType = engineType.rawValue
        ///set the distance unit  in string format
        settings.distanceUnit = distanceUnit.rawValue
        ///set the initial distance unit for the MapView API.
        MapViewAPI.distanceUnit = distanceUnit
        ///set the fuel unit in string format
        settings.fuelVolumeUnit = fuelUnit.rawValue
        ///set the efficiency unit  in string format
        settings.fuelEfficiencyUnit = efficiencyUnits[efficiencyUnitIndex]
        vehicle.settings = settings
        ///save the managed view context to the core data store with new changes.
        Settings.saveContext(viewContext: viewContext)
        Vehicle.saveContext(viewContext: viewContext)
        withAnimation(.easeIn(duration: 0.5)) {
            showAlert = true
        }
    }*/
}

#Preview {
    InitialSettingsView(locationDataManager: LocationDataManager(), isInitialized: .constant(false))
}
