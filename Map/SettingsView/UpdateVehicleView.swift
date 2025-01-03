//
//  updateVehicleView.swift
//  Map
//
//  Created by saj panchal on 2024-07-17.
//

import SwiftUI

struct UpdateVehicleView: View {
    @Environment(\.colorScheme) var bgMode: ColorScheme
    ///environment object that represents core data store's managed object context which tracks the changes made in entities.
    @Environment(\.managedObjectContext) private var viewContext
    ///state variable that stores vehicle type in enum format
    @State private var vehicleType: VehicleTypes = .Car
    ///state variable that stores vehicle make in enum format
    @State private var vehicleMake: VehicleMake = .AC
    ///state variable that stores alphabets in enum format
    @State private var alphabet: Alphbets = .A
    ///state variable that stores vehicle vehicleModel in enum format
    @State private var vehicleModel: Model = .Ace
    ///state variable that stores vehicle manufacturing manufacturingYear.
    @State private var manufacturingYear = (Calendar.current.dateComponents([.year], from: Date())).year ?? 1900
    ///state variable that stores vehicle manufacturing year range for picker
    @State private var manufacturingYearRange = 1900..<((Calendar.current.dateComponents([.year], from: Date())).year ?? 1900) + 1
    ///state variable that stores vehicle engine tyoe
    @State private var engineType = EngineType.Gas
    ///enum type to store fuel mode  of vehicle
    @State private var fuelMode: FuelMode = .Gas
    ///state variable to store battery capacity
    @State private var batteryCapacity = 40.0
    ///state variable that stores vehicle odometer for textfield to display
    @State private var odometer = 0
    ///state variable that stores vehicle odometer for textfield to display
    @State private var odometerMiles = 0
    ///state variable that stores vehicle trip odometer for textfield to display
    @State private var trip = 0.0
    ///state variable that stores vehicle trip odometer (miles) for textfield to display
    @State private var tripMiles = 0.0
    ///state variable that stores vehicle trip odometer (EV) for textfield to display
    @State private var tripHybridEV = 0.0
    ///state variable that stores vehicle trip odometer (EV in miles) )for textfield to display
    @State private var tripHybridEVMiles = 0.0
    ///state object that represents location data manager which is handling the location manager operations.
    @StateObject var locationDataManager: LocationDataManager
    ///state variable stores distance unit as enum type
    @State private var distanceUnit: DistanceUnit = .km
    ///state variable stores fuel unit as enum type
    @State private var fuelUnit: FuelUnit = .Litre
    ///array of vehicle efficiency units.
    @State private var efficiencyUnits = ["km/L", "L/100km", "miles/L", "L/100Miles", "km/gl", "gl/100km", "miles/gl", "gl/100miles", "km/kwh", "miles/kwh"]
    ///index of vehicle efficiency units array
    @State private var efficiencyUnitIndex = 0
    ///flag to show/hide add vehicle form
    @State private var showAddVehicleForm = false
    ///flag to show/hide garage view
    @Binding var showGarage: Bool
    ///variable that stores settings object of core data
    var settings: Settings
    ///variable that stores vehicle object of core data
    var vehicle: Vehicle
    @State private var showAlert = false
    var body: some View {
        NavigationStack {
            ZStack {
                VStack {
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
                                TextField("Enter battery capacity in kwh", value: $batteryCapacity, format: .number)
                                    .keyboardType(.decimalPad)
                            }
                        }
                        ///if distance unit is km
                        if distanceUnit == .km {
                            ///textfield to enter/update vehicle odometer readings
                            Section("Vehicle Odometer (in Km)") {
                                TextField("Enter the odometer readings", value: $odometer, format: .number)
                                    .onChange(of: odometer) {
                                        let odometerDouble = Double(odometer)
                                        odometerMiles = Int(odometerDouble * 0.6214)
                                    }
                                    .keyboardType(.numberPad)
                            }
                        }
                        else {
                            ///textfield for setting vehicle odometer readings
                            Section("Vehicle Odometer (in Miles)") {
                                TextField("Enter the odometer readings", value: $odometerMiles, format: .number)
                                    .onChange(of: odometerMiles) {
                                        let odometerMilesDouble = Double(odometerMiles)
                                        odometer = Int(odometerMilesDouble / 0.6214)
                                    }
                                    .keyboardType(.numberPad)
                            }
                        }
                        ///if engine type is not hybrid
                        if engineType != .Hybrid {
                            if distanceUnit == .km {
                                ///textfield to enter/update vehicle trip odometer numbers
                                Section(header: Text("Vehicle Trip (in Km)").fontWeight(.bold)) {
                                    TextField("Enter the Trip readings", value: $trip, format: .number)
                                        .onChange(of: trip) {
                                            let tripDouble = Double(trip)
                                            tripMiles = tripDouble * 0.6214
                                        }
                                        .keyboardType(.decimalPad)
                                }
                            }
                            else {
                                ///textfield to enter/update vehicle trip odometer numbers
                                Section(header: Text("Vehicle Trip (in Miles)").fontWeight(.bold)) {
                                    TextField("Enter the Trip readings", value: $tripMiles, format: .number)
                                        .onChange(of: tripMiles) {
                                            let tripMilesDouble = Double(tripMiles)
                                            trip = tripMilesDouble / 0.6214
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
                                    TextField("Enter the Trip readings", value: $trip, format: .number)
                                        .onChange(of: trip) {
                                            let tripDouble = Double(trip)
                                            tripMiles = tripDouble * 0.6214
                                        }
                                        .keyboardType(.decimalPad)
                                }
                            }
                            else {
                                ///textfield to enter/update vehicle trip odometer in miles
                                Section(header: Text("Vehicle Trip for Gas Engine (in Miles)").fontWeight(.bold)) {
                                    TextField("Enter the Trip readings", value: $tripMiles, format: .number)
                                        .onChange(of: tripMiles) {
                                            let tripMilesDouble = Double(tripMiles)
                                            trip = tripMilesDouble / 0.6214
                                        }
                                        .keyboardType(.decimalPad)
                                }
                            }
                            ///if distance unit is km, set vehicle trip odometer
                            if distanceUnit == .km {
                                ///textfield to enter/update vehicle trip odometer in km
                                Section(header: Text("Vehicle Trip for EV Engine (in Km)").fontWeight(.bold)) {
                                    TextField("Enter the Trip readings", value: $tripHybridEV, format: .number)
                                        .onChange(of: tripHybridEV) {
                                            let tripDouble = Double(tripHybridEV)
                                            tripHybridEVMiles = tripDouble * 0.6214
                                        }
                                        .keyboardType(.decimalPad)
                                }
                            }
                            else {
                                ///textfield to enter/update vehicle trip odometer in miles
                                Section(header: Text("Vehicle Trip for EV Engine (in Miles)").fontWeight(.bold)) {
                                    TextField("Enter the Trip readings", value: $tripHybridEVMiles, format: .number)
                                        .onChange(of: tripHybridEVMiles) {
                                            let tripMilesDouble = Double(tripHybridEVMiles)
                                            tripHybridEV = tripMilesDouble / 0.6214
                                            
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
                            HStack {
                                Spacer()
                                Button {
                                    addVehicle(for: vehicle)
                                    saveSettings(for: vehicle)
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                        showGarage = false
                                    }
                                } label: {
                                    FormButton(imageName: "gearshape.fill", text: "Save Settings", color: Color(AppColors.blueColor.rawValue))
                                }
                                .background(Color(AppColors.invertBlueColor.rawValue))
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
                    AlertView(image: "car.circle.fill", headline: "Vehicle Updated!", bgcolor: Color(AppColors.invertBlueColor.rawValue), showAlert: $showAlert)
                }
            }
            
           
            
            .navigationTitle("Update Settings")
            .navigationBarTitleDisplayMode(.inline)
         
        }
        .onAppear {           
           
            fillForm()
        }
    }
    func addVehicle(for vehicle: Vehicle) {
        
        vehicle.uniqueID = UUID()
        vehicle.model = vehicleModel.rawValue
        vehicle.make = vehicleMake.rawValue
        vehicle.year = Int16(manufacturingYear)
        vehicle.odometer = Double(odometer)
        vehicle.odometerMiles = Double(odometerMiles)
       ///if the engine type is hybrid
        if engineType == .Hybrid {
            ///update the hybrid EV trip (in km)
            vehicle.tripHybridEV = tripHybridEV
            vehicle.tripHybridEVMiles = tripHybridEVMiles
            
        }
        ///update vehicle trip (in miles) with new values
        vehicle.tripMiles = tripMiles
        ///update vehicle trip (in km) with new values
        vehicle.trip = trip
        ///save the engine type in vehicle object. (Gas, EV, Hybrid)
        vehicle.fuelEngine = engineType.rawValue
        ///if engine type is not gas set the battery capacity of the EV engine
        if engineType != .Gas {
            vehicle.batteryCapacity = batteryCapacity
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
        withAnimation(.easeIn(duration: 0.5)) {
            showAlert = true
        }
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
        odometer = Int(vehicle.odometer)
        odometerMiles = Int(vehicle.odometerMiles)
        ///if engine type is not gas
        if engineType != .Gas {
            ///update the vehicle battery capacity field
            batteryCapacity = vehicle.getBatteryCapacity
        }
        ///update the vehicle trip (in km) value fetched from the selected vehicle
        trip = vehicle.trip
        ///update the vehicle trip (in miles) value fetched from the selected vehicle
        tripMiles = vehicle.tripMiles
        ///if the engine type is set to hybrid
        if engineType == .Hybrid {
            ///update the vehicle trip (in km) value fetched from the selected vehicle
            tripHybridEV = vehicle.tripHybridEV
            ///update the vehicle trip (in miles) value fetched from the selected vehicle
            tripHybridEVMiles = vehicle.tripHybridEVMiles
        }
        distanceUnit = DistanceUnit(rawValue: settings.getDistanceUnit) ?? .km
        fuelUnit = FuelUnit(rawValue: settings.getFuelVolumeUnit) ?? .Litre
        efficiencyUnitIndex = efficiencyUnits.firstIndex(where: {$0 == settings.fuelEfficiencyUnit}) ?? 0
    }
}

#Preview {
    UpdateVehicleView(locationDataManager: LocationDataManager(), showGarage: .constant(false), settings: Settings(), vehicle: (Vehicle()))
}
