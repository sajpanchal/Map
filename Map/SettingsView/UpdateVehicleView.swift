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
    ///state variable that stores vehicle odometer for textfield to display
    @State var odometer = "0"
    ///state variable that stores vehicle trip odometer for textfield to display
    @State var trip = "0.0"
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
                ///textfield to enter/update vehicle odometer numbers
                Section(header: Text("Vehicle Odometer").fontWeight(.bold)) {
                    TextField("Enter the odometer readings", text: $odometer)
                        .keyboardType(.numberPad)
                }
                ///textfield to enter/update vehicle trip odometer numbers
                Section(header: Text("Vehicle Trip").fontWeight(.bold)) {
                    TextField("Enter the Trip readings", text: $trip)
                        .keyboardType(.decimalPad)
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
                 
                if fuelMode == .Gas {
                    Section(header: Text("Fuel Volume Unit").fontWeight(.bold)) {
                        Picker("Select Unit", selection: $fuelUnit) {
                            ForEach(FuelUnit.allCases) { unit in
                                Text(unit.rawValue.capitalized)
                            }
                        }
                        .pickerStyle(.segmented)
                    }
                }
                if engineType == .Hybrid {
                    Section(header: Text("Fuel Mode").fontWeight(.bold)) {
                        Picker("Select Type", selection: $fuelMode) {
                            ForEach(FuelMode.allCases) { thisFuelType in
                                Text(thisFuelType.rawValue.capitalized)
                            }
                        }
                        .pickerStyle(.segmented)
                    }
                }
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
        vehicle.trip = Double(trip) ?? 0
        vehicle.fuelEngine = engineType.rawValue
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
        vehicleType = VehicleTypes(rawValue: vehicle.getType) ?? .Car
        vehicleMake = VehicleMake(rawValue: vehicle.getMake) ?? .AC
        vehicleModel = Model(rawValue: vehicle.getModel) ?? .ATS
        manufacturingYear = Int(vehicle.year)
        alphabet = Alphbets(rawValue: String(vehicleMake.rawValue.first ?? "A").uppercased()) ?? .A
        engineType = EngineType(rawValue: vehicle.getFuelEngine) ?? .Gas
        odometer = String(vehicle.odometer)
        trip = String(vehicle.trip)
        distanceUnit = DistanceUnit(rawValue: settings.getDistanceUnit) ?? .km
        fuelUnit = FuelUnit(rawValue: settings.getFuelVolumeUnit) ?? .Litre
        efficiencyUnitIndex = efficiencyUnits.firstIndex(where: {$0 == settings.fuelEfficiencyUnit}) ?? 0
    }
}

#Preview {
    UpdateVehicleView(locationDataManager: LocationDataManager(), showGarage: .constant(false), settings: Settings(), vehicle: (Vehicle()))
}
