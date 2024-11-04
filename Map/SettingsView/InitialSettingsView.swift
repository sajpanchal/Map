//
//  InitialSettingsView.swift
//  Map
//
//  Created by saj panchal on 2024-07-15.
//

import SwiftUI

struct InitialSettingsView: View {
    ///viewContext is the environment object of managed view context of core data stack.
    @Environment(\.managedObjectContext) private var viewContext
    ///state object that handles tasks of the location manger
    @StateObject var locationDataManager: LocationDataManager
    ///state variable that stores vehicle type enum value
    @State var vehicleType: VehicleTypes = .Car
    ///state variable that stores vehicle make enum value
    @State var vehicleMake: VehicleMake = .AC
    ///state variable that stores alphabets enum value
    @State var alphabet: Alphbets = .A
    ///state variable that stores vehicle model enum value
    @State var model: Model = .Ace
    ///state variable that stores vehicle manufacturing year.
    @State var year = (Calendar.current.dateComponents([.year], from: Date())).year ?? 1900
    ///state variable that stores the range of vehicle manufacturing year
    @State var yearRange = 1900..<((Calendar.current.dateComponents([.year], from: Date())).year ?? 1900) + 1
    ///state variable that stores vehicle engine type enum value
    @State var engineType = EngineType.Gas
    ///state variable stores the odometer readings value for the textfield
    @State var odometer = 0
    ///state variable stores the odometer readings value for the textfield
    @State var odometerMiles = 0
    ///state variable stores the trip odometer readings value for the textfield
    @State var trip = 0.0
    ///state variable stores the trip odometer readings value for the textfield
    @State var tripMiles = 0.0
    ///state variable stores the trip odometer readings value for the textfield
    @State var tripHybridEV = 0.0
    ///state variable stores the trip odometer readings value for the textfield
    @State var tripHybridEVMiles = 0.0
    ///state variable stores the distance unit enum value
    @State var distanceUnit: DistanceUnit = .km
    ///state variable stores the fuel unit enum value
    @State var fuelUnit: FuelUnit = .Litre
    ///state variable stores the fuel unit enum value
    @State var fuelMode: FuelMode = .Gas
    ///enum type to store the fuel unit.
    @State var batteryCapacity = 40.0
    ///array of fuel efficiencies.
    @State var efficiencyUnits = ["km/L", "L/100km", "miles/L","L/100Miles", "km/gl",  "gl/100km", "miles/gl", "gl/100miles", "km/kwh", "miles/kwh"]
    ///state variable stores the index of efficiencyUnits array
    @State var efficiencyUnitIndex = 0
    ///state variable to hide/show the add vehicle form view.
    @State var showAddVehicleForm = false
    ///state variable stores vehicle make in string format
    @State var textVehicleMake = ""
    ///state variable stores vehicle model in string format
    @State var textVehicleModel = ""
    
    var body: some View {
        NavigationStack {
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
                        .pickerStyle(.segmented)
                    }
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
                    Button {
                        ///on tap of the button, instantiate a vehicle entity object from the managed view context
                    let vehicle = Vehicle(context: viewContext)
                        ///add a new vehicle for this vehicle object created.
                    addVehicle(for: vehicle)
                        ///save the settings for this vehicle object created.
                    saveSettings(for: vehicle)
                    } label: {
                        ///button view ui.
                        FormButton(imageName: "gearshape.fill", text: "Save Settings", color: Color(AppColors.pink.rawValue))
                    }
                    .background(Color(AppColors.invertPink.rawValue))
                    .buttonStyle(BorderlessButtonStyle())
                    .cornerRadius(100)
                }
                .listRowBackground(Color.clear)
                .listRowInsets(EdgeInsets())
            }
            .navigationTitle("Settings")
        }
    }
    
    func addVehicle(for vehicle: Vehicle) {
        ///set unique id.
        vehicle.uniqueID = UUID()
        ///set model name string
        vehicle.model = model.rawValue
        ///set vehicle make string
        vehicle.make = vehicleMake.rawValue
        ///set vehicle manufacturing year.
        vehicle.year = Int16(year)
        ///set vehicle odometer in decimal format
        vehicle.odometer = Double(odometer)
        ///set vehicle odometer in decimal format
        vehicle.odometerMiles = Double(odometerMiles)
        if distanceUnit == .km {
            ///set vehicle trip odometer in decimal format
            vehicle.trip = trip
            ///set vehicle trip odometer in decimal format
            vehicle.tripMiles =  vehicle.trip * 0.6214
        }
        else {
            ///set vehicle trip odometer in decimal format
            vehicle.tripMiles = tripMiles
            ///set vehicle trip odometer in decimal format
            vehicle.trip = vehicle.tripMiles / 0.6214
        }
        if engineType == .Hybrid {
            if distanceUnit == .km {
                ///set vehicle trip odometer in decimal format
                vehicle.tripHybridEV = tripHybridEV
                ///set vehicle trip odometer in decimal format
                vehicle.tripHybridEVMiles =  vehicle.tripHybridEV * 0.6214
            }
            else {
                ///set vehicle trip odometer in decimal format
                vehicle.tripHybridEVMiles = tripHybridEVMiles
                ///set vehicle trip odometer in decimal format
                vehicle.tripHybridEV = vehicle.tripHybridEVMiles / 0.6214
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
        ///save the managed view context to the core data store with new changes.
        Vehicle.saveContext(viewContext: viewContext)
    }
    
    func saveSettings(for vehicle: Vehicle) {
        ///create a settings object from viewcontext's settings entity
        let settings = Settings(context: viewContext)
        ///assign a current vehicle that is active
        settings.vehicle = vehicle
        ///set the engine type in string format
        settings.autoEngineType = engineType.rawValue
        ///set the distance unit  in string format
        settings.distanceUnit = distanceUnit.rawValue
        ///set the fuel unit in string format
        settings.fuelVolumeUnit = fuelUnit.rawValue
        ///set the efficiency unit  in string format
        settings.fuelEfficiencyUnit = efficiencyUnits[efficiencyUnitIndex]
        ///save the managed view context to the core data store with new changes.
        Settings.saveContext(viewContext: viewContext)
    }
}

#Preview {
    InitialSettingsView(locationDataManager: LocationDataManager())
}
