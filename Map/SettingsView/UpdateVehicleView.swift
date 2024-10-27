//
//  updateVehicleView.swift
//  Map
//
//  Created by saj panchal on 2024-07-17.
//

import SwiftUI

struct UpdateVehicleView: View {
    ///environment object that represents core data store's managed object context which tracks the changes made in entities.
    @Environment(\.managedObjectContext) private var viewContext
    ///state variable that stores vehicle type in enum format
    @State var vehicleType: VehicleTypes = .Car
    ///state variable that stores vehicle make in enum format
    @State var vehicleMake: VehicleMake = .AC
    ///state variable that stores alphabets in enum format
    @State var alphabet: Alphbets = .A
    ///state variable that stores vehicle vehicleModel in enum format
    @State var vehicleModel: Model = .Ace
    ///state variable that stores vehicle manufacturing manufacturingYear.
    @State var manufacturingYear = (Calendar.current.dateComponents([.year], from: Date())).year ?? 1900
    ///state variable that stores vehicle manufacturing year range for picker
    @State var manufacturingYearRange = 1900..<((Calendar.current.dateComponents([.year], from: Date())).year ?? 1900) + 1
    ///state variable that stores vehicle engine tyoe
    @State var engineType = EngineType.Gas
    ///enum type to store fuel mode  of vehicle
    @State var fuelMode: FuelMode = .Gas
    ///state variable to store battery capacity
    @State var batteryCapacity = "40.0"
    ///state variable that stores vehicle odometer for textfield to display
    @State var odometer = "0"
    ///state variable that stores vehicle odometer for textfield to display
    @State var odometerMiles = "0"
    ///state variable that stores vehicle trip odometer for textfield to display
    @State var trip = "0.0"
    ///state variable that stores vehicle trip odometer (miles) for textfield to display
    @State var tripMiles = "0.0"
    ///state variable that stores vehicle trip odometer (EV) for textfield to display
    @State var tripHybridEV = "0.0"
    ///state variable that stores vehicle trip odometer (EV in miles) )for textfield to display
    @State var tripHybridEVMiles = "0.0"
    ///state object that represents location data manager which is handling the location manager operations.
    @StateObject var locationDataManager: LocationDataManager
    ///state variable stores distance unit as enum type
    @State var distanceUnit: DistanceUnit = .km
    ///state variable stores fuel unit as enum type
    @State var fuelUnit: FuelUnit = .Litre
    ///array of vehicle efficiency units.
    @State var efficiencyUnits = ["km/L", "L/100km", "miles/L", "L/100Miles", "km/gl", "gl/100km", "miles/gl", "gl/100miles", "km/kwh", "miles/kwh"]
    ///index of vehicle efficiency units array
    @State var efficiencyUnitIndex = 0
    ///flag to show/hide add vehicle form
    @State var showAddVehicleForm = false
    ///flag to show/hide garage view
    @Binding var showGarage: Bool
    ///variable that stores settings object of core data
    var settings: Settings
    ///variable that stores vehicle object of core data
    var vehicle: Vehicle
    
    var body: some View {
        NavigationStack {
            ///form to update vehicle details
            Form {
                ///picker to select vehicle type
                Section(header: Text("Vehicle Type").fontWeight(.bold)) {
                    Picker("Select Type", selection: $vehicleType) {
                        ForEach(VehicleTypes.allCases) { type in
                            Text(type.rawValue)
                        }
                    }
                }
                ///picker to select vehicle make alphabetically
                Section(header: Text("Vehicle Make").fontWeight(.bold)) {
                    HStack {
                        Picker("Select Make", selection: $alphabet) {
                            ForEach(Alphbets.allCases) { alpha in
                                Text(alpha.rawValue)
                            }
                        }
                        ///on change of alphabet ID
                        .onChange(of:alphabet.id) {
                            ///continue only if for a given aphabet, first vehicle make is not nil
                            guard let thisMake = alphabet.makes.first else {
                                return
                            }
                            ///set the selected make as initial vehicle make
                            vehicleMake = thisMake
                            ///continue only if for a given make, , first vehicle model is not nil
                            guard let thisModel = thisMake.models.first else {
                                return
                            }
                            ///set the selected make as initial vehicle model
                            vehicleModel = thisModel
                        }
                        .pickerStyle(.wheel)
                        ///picker for vehicle make
                        Picker("", selection:$vehicleMake) {
                            ForEach(alphabet.makes) { make in
                                Text(make.rawValue)
                            }
                        }
                        ///on change of vehicle make
                        .onChange(of: vehicleMake) {
                            vehicleModel = vehicleMake.models.first ?? .Other
                        }
                        .pickerStyle(.wheel)
                    }
                }
                ///picker to select vehicle model
                Section(header: Text("Vehicle model").fontWeight(.bold)) {
                    Picker("Select model", selection: $vehicleModel) {
                        ForEach(vehicleMake.models, id: \.id) { vehicleModel in
                            Text(vehicleModel.rawValue.replacingOccurrences(of: "_", with: " "))
                        }                        
                    }
                    .pickerStyle(.wheel)
                }
                ///picker to select vehicle manufacturing year
                Section(header: Text("Vehicle Manufacuring year").fontWeight(.bold)) {
                    Picker("Select year", selection: $manufacturingYear) {
                        ForEach(manufacturingYearRange.reversed(), id: \.self) { i in
                            Text(String(i))
                        }
                    }
                    .pickerStyle(.wheel)
                }
                ///picker to select fuel engine type
                Section(header: Text("Fuel Engine Type").fontWeight(.bold)) {
                    Picker("Select Type", selection:$engineType) {
                        ForEach(EngineType.allCases) { type in
                            Text(type.rawValue)
                        }
                    }
                    .onChange(of: engineType.id) {
                        fuelMode = (engineType == .EV) ? .EV : .Gas
                    }
                    .pickerStyle(.segmented)
                }
                ///picker to select distance unit
                Section(header: Text("Distance Unit").fontWeight(.bold)) {
                    Picker("Select Unit", selection: $distanceUnit) {
                        ForEach(DistanceUnit.allCases) { unit in
                            Text(unit.rawValue.capitalized)
                        }
                    }
                    
                    .pickerStyle(.segmented)
                }
                ///textfield to enter battery capacity in case engine type is EV
                if engineType != .Gas {
                    Section(header: Text("EV Battery Capacity in KWh").fontWeight(.bold)) {
                        TextField("Enter battery capacity in kwh", text: $batteryCapacity)
                            .keyboardType(.decimalPad)
                    }
                }
                ///if distance unit is km
                if distanceUnit == .km {
                    ///textfield to enter/update vehicle odometer readings
                    Section("Vehicle Odometer (in Km)") {
                        TextField("Enter the odometer readings", text: $odometer)
                            .onChange(of: odometer) {
                                if let odometerDouble = Double(odometer) {
                                    odometerMiles = String(odometerDouble * 0.6214)
                                }
                            }
                            .keyboardType(.numberPad)
                    }
                }
                else {
                    ///textfield for setting vehicle odometer readings
                    Section("Vehicle Odometer (in Miles)") {
                        TextField("Enter the odometer readings", text: $odometerMiles)
                            .onChange(of: odometerMiles) {
                                if let odometerMilesDouble = Double(odometerMiles) {
                                    odometer = String(odometerMilesDouble / 0.6214)
                                }
                            }
                            .keyboardType(.numberPad)
                    }
                }
                ///if engine type is not hybrid
                if engineType != .Hybrid {
                    if distanceUnit == .km {
                        ///textfield to enter/update vehicle trip odometer numbers
                        Section(header: Text("Vehicle Trip (in Km)").fontWeight(.bold)) {
                            TextField("Enter the Trip readings", text: $trip)
                                .onChange(of: trip) {
                                    if let tripDouble = Double(trip) {
                                        tripMiles = String(tripDouble * 0.6214)
                                    }
                                }
                                .keyboardType(.decimalPad)
                        }
                    }
                    else {
                        ///textfield to enter/update vehicle trip odometer numbers
                        Section(header: Text("Vehicle Trip (in Miles)").fontWeight(.bold)) {
                            TextField("Enter the Trip readings", text: $tripMiles)
                                .onChange(of: tripMiles) {
                                    if let tripMilesDouble = Double(tripMiles) {
                                        trip = String(tripMilesDouble / 0.6214)
                                    }
                                }
                                .keyboardType(.decimalPad)
                        }
                    }
                }
                ///if engine type is hybrid
                else {
                    if distanceUnit == .km {
                        ///textfield to enter/update vehicle trip odometer in km
                        Section(header: Text("Vehicle Trip for Gas Engine (in Km)").fontWeight(.bold)) {
                            TextField("Enter the Trip readings", text: $trip)
                                .onChange(of: trip) {
                                    print("changed trip: \(trip)")
                                    if let tripDouble = Double(trip) {
                                        tripMiles = String(tripDouble * 0.6214)
                                        print("tripMiles:\(tripMiles)")
                                    }
                                   
                                }
                                .keyboardType(.decimalPad)
                        }
                    }
                    else {
                        ///textfield to enter/update vehicle trip odometer in miles
                        Section(header: Text("Vehicle Trip for Gas Engine (in Miles)").fontWeight(.bold)) {
                            TextField("Enter the Trip readings", text: $tripMiles)
                                .onChange(of: tripMiles) {
                                    if let tripMilesDouble = Double(tripMiles) {
                                        trip = String(tripMilesDouble / 0.6214)
                                    }
                                }
                                .keyboardType(.decimalPad)
                        }
                    }
                    ///if distance unit is km, set vehicle trip odometer
                    if distanceUnit == .km {
                        ///textfield to enter/update vehicle trip odometer in km
                        Section(header: Text("Vehicle Trip for EV Engine (in Km)").fontWeight(.bold)) {
                            TextField("Enter the Trip readings", text: $tripHybridEV)
                                .onChange(of: tripHybridEV) {
                                    if let tripDouble = Double(tripHybridEV) {
                                        tripHybridEVMiles = String(tripDouble * 0.6214)
                                    }
                                }
                                .keyboardType(.decimalPad)
                        }
                    }
                    else {
                        ///textfield to enter/update vehicle trip odometer in miles
                        Section(header: Text("Vehicle Trip for EV Engine (in Miles)").fontWeight(.bold)) {
                            TextField("Enter the Trip readings", text: $tripHybridEVMiles)
                                .onChange(of: tripHybridEVMiles) {
                                    if let tripMilesDouble = Double(tripHybridEVMiles) {
                                        tripHybridEV = String(tripMilesDouble / 0.6214)
                                    }
                                }
                                .keyboardType(.decimalPad)
                        }
                    }
                }
                ///if the fuel mode is set to gas engine
                if fuelMode == .Gas {
                    ///picker to select the fule volume unit
                    Section(header: Text("Fuel Volume Unit").fontWeight(.bold)) {
                        Picker("Select Unit", selection: $fuelUnit) {
                            ForEach(FuelUnit.allCases) { unit in
                                if unit != .Percent {
                                    Text(unit.rawValue.capitalized)
                                }
                               
                            }
                        }
                        ///on appear update the fuel unit which is already saved in settings
                        .onAppear(perform: {
                            fuelUnit =  FuelUnit(rawValue: settings.getFuelVolumeUnit) ?? .Litre
                        })
                        
                        .pickerStyle(.segmented)
                    }
                }
                ///else if fuel mode is set to EV
                else {
                    Section(header: Text("Fuel Volume Unit").fontWeight(.bold)) {
                        Picker("Select Unit", selection: $fuelUnit) {
                            ///show only the units to be used by EV.
                            ForEach(FuelUnit.allCases) { unit in
                                if unit == .Percent {
                                    Text(unit.rawValue.capitalized)
                                }
                            }
                        }
                        .onAppear(perform: {
                            fuelUnit = .Percent
                        })
                        .pickerStyle(.segmented)
                    }
                }
                ///if engine type is hybrid show picker view to select fuel mode (gas/EV)
                if engineType == .Hybrid {
                    ///picker to select fuel mode
                    Section(header: Text("Fuel Mode").fontWeight(.bold)) {
                        Picker("Select Type", selection: $fuelMode) {
                            ForEach(FuelMode.allCases) { thisFuelType in
                                Text(thisFuelType.rawValue.capitalized)
                            }
                        }
                        .pickerStyle(.segmented)
                    }
                }
                ///if fuel mode is gas show fuel efficiency units
                if fuelMode == .Gas {
                    Section(header: Text("Fuel Efficiency Unit").fontWeight(.bold)) {
                        if fuelUnit == .Litre {
                            if distanceUnit == .km {
                                Picker("Select Unit", selection: $efficiencyUnitIndex) {
                                    ForEach(efficiencyUnits.indices, id: \.self) {index in
                                        if index < 2 {
                                            Text(efficiencyUnits[index])
                                        }
                                    }
                                }
                                .pickerStyle(.segmented)
                            }
                            else {
                                Picker("Select Unit", selection: $efficiencyUnitIndex) {
                                    ForEach(efficiencyUnits.indices, id: \.self) {index in
                                        if index > 1 && index < 4 {
                                            Text(efficiencyUnits[index])
                                        }
                                    }
                                }
                                .pickerStyle(.segmented)
                            }
                        }
                        else if fuelUnit == .Gallon {
                            if distanceUnit == .km {
                                Picker("Select Unit", selection: $efficiencyUnitIndex) {
                                    ForEach(efficiencyUnits.indices, id: \.self) { index in
                                        if index > 3 && index < 6 {
                                            Text(efficiencyUnits[index])
                                        }
                                    }
                                }
                                .pickerStyle(.segmented)
                            }
                            else {
                                Picker("Select Unit", selection: $efficiencyUnitIndex) {
                                    ForEach(efficiencyUnits.indices, id: \.self) {index in
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
                else {
                    if distanceUnit == .km {
                        Picker("Select Unit", selection: $efficiencyUnitIndex) {
                            ForEach(efficiencyUnits.indices, id: \.self) { index in
                                if index == 8 {
                                    Text(efficiencyUnits[index])
                                }
                            }
                        }
                        .onAppear {
                            efficiencyUnitIndex = 8
                        }
                        .pickerStyle(.segmented)
                    }
                    else {
                        Picker("Select Unit", selection: $efficiencyUnitIndex) {
                            ForEach(efficiencyUnits.indices, id: \.self) { index in
                                if index == 9 {
                                    Text(efficiencyUnits[index])
                                }
                            }
                        }
                        .onAppear {
                            efficiencyUnitIndex = 9
                        }
                        .pickerStyle(.segmented)
                    }
                }
                             
                VStack {
                    Button {
                        addVehicle(for: vehicle)
                        saveSettings(for: vehicle)
                        showGarage = false
                    } label: {
                        FormButton(imageName: "gearshape.fill", text: "Save Settings", color: Color(AppColors.blueColor.rawValue))
                    }
                    .background(Color(AppColors.invertBlueColor.rawValue))
                    .buttonStyle(BorderlessButtonStyle())
                    .cornerRadius(100)
                }
                .listRowBackground(Color.clear)
                .listRowInsets(EdgeInsets())
                
            }
            
            .navigationTitle("Update Settings")
         
        }
        .onAppear {           
            print("update vehicle view")
            fillForm()
        }
    }
    func addVehicle(for vehicle: Vehicle) {
        
        vehicle.uniqueID = UUID()
        vehicle.model = vehicleModel.rawValue
        vehicle.make = vehicleMake.rawValue
        vehicle.year = Int16(manufacturingYear)
        vehicle.odometer = Double(odometer) ?? 0
        vehicle.odometerMiles = Double(odometerMiles) ?? 0
       ///if the engine type is hybrid
        if engineType == .Hybrid {
            ///update the hybrid EV trip (in km)
            vehicle.tripHybridEV = Double(tripHybridEV) ?? 0
            vehicle.tripHybridEVMiles = Double(tripHybridEVMiles) ?? 0
            
        }
        ///update vehicle trip (in miles) with new values
        vehicle.tripMiles = Double(tripMiles) ?? 0
        ///update vehicle trip (in km) with new values
        vehicle.trip = Double(trip) ?? 0
        ///save the engine type in vehicle object. (Gas, EV, Hybrid)
        vehicle.fuelEngine = engineType.rawValue
        ///if engine type is not gas set the battery capacity of the EV engine
        if engineType != .Gas {
            vehicle.batteryCapacity = Double(batteryCapacity) ?? 40
        }
        ///save the vehicle type (Car, Truck, SUV)
        vehicle.type = vehicleType.rawValue
        vehicle.isActive = true
        Vehicle.saveContext(viewContext: viewContext)
    }
    func saveSettings(for vehicle: Vehicle) {
        let settings = Settings(context: viewContext)
        settings.vehicle = vehicle
        settings.autoEngineType = engineType.rawValue
        settings.distanceUnit = distanceUnit.rawValue
        settings.fuelVolumeUnit = fuelUnit.rawValue
        settings.fuelEfficiencyUnit = efficiencyUnits[efficiencyUnitIndex]
        Settings.saveContext(viewContext: viewContext)
    }
    
    func fillForm() {
        ///set the vehicle type fetched from the selected vehicle
        vehicleType = VehicleTypes(rawValue: vehicle.getType) ?? .Car
        ///set the vehicle make fetched from the selected vehicle
        vehicleMake = VehicleMake(rawValue: vehicle.getMake) ?? .AC
        ///set the vehicle model fetched from the selected vehicle
        vehicleModel = Model(rawValue: vehicle.getModel) ?? .ATS
        ///set the vehicle manufacturing year fetched from the selected vehicle
        manufacturingYear = Int(vehicle.year)
        ///set the alphbet to sort vehicle makes fetched from the selected vehicle
        alphabet = Alphbets(rawValue: String(vehicleMake.rawValue.first ?? "A").uppercased()) ?? .A
        engineType = EngineType(rawValue: vehicle.getFuelEngine) ?? .Gas
        odometer = String(vehicle.odometer)
        odometerMiles = String(vehicle.odometerMiles)
        ///if engine type is not gas
        if engineType != .Gas {
            ///update the vehicle battery capacity field
            batteryCapacity = vehicle.getBatteryCapacity
        }
        ///update the vehicle trip (in km) value fetched from the selected vehicle
        trip = String(vehicle.trip)
        ///update the vehicle trip (in miles) value fetched from the selected vehicle
        tripMiles = String(vehicle.tripMiles)
        ///if the engine type is set to hybrid
        if engineType == .Hybrid {
            ///update the vehicle trip (in km) value fetched from the selected vehicle
            tripHybridEV = String(vehicle.tripHybridEV)
            ///update the vehicle trip (in miles) value fetched from the selected vehicle
            tripHybridEVMiles = String(vehicle.tripHybridEVMiles)
        }
        distanceUnit = DistanceUnit(rawValue: settings.getDistanceUnit) ?? .km
        fuelUnit = FuelUnit(rawValue: settings.getFuelVolumeUnit) ?? .Litre
        efficiencyUnitIndex = efficiencyUnits.firstIndex(where: {$0 == settings.fuelEfficiencyUnit}) ?? 0
    }
}

#Preview {
    UpdateVehicleView(locationDataManager: LocationDataManager(), showGarage: .constant(false), settings: Settings(), vehicle: (Vehicle()))
}
