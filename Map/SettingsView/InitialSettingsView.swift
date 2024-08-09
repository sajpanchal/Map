//
//  InitialSettingsView.swift
//  Map
//
//  Created by saj panchal on 2024-07-15.
//

import SwiftUI

struct InitialSettingsView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @StateObject var locationDataManager: LocationDataManager
    @State var vehicleType: VehicleTypes = .Car
    @State var vehicleMake: VehicleMake = .AC
    @State var alphabet: Alphbets = .A
    @State var model: Model = .Ace
    @State var year = (Calendar.current.dateComponents([.year], from: Date())).year!
    @State var index = 0
    @State var range = 1900..<(Calendar.current.dateComponents([.year], from: Date())).year! + 1
    @State var fuelType = FuelTypes.Gas
    @State var odometer = "0"
    @State var trip = "0.0"
    @State var vIndex = 0   
    @State var settings: Settings?
    @State var distanceMode: DistanceModes = .km
    @State var fuelMode: FuelModes = .Litre
    @State var efficiencyModes = ["km/L", "L/100km", "miles/L","L/100Miles", "km/gl",  "gl/100km", "miles/gl", "gl/100miles", "km/kwh", "miles/kwh"]
    @State var efficiencyMode = 0
    @State var showAddVehicleForm = false
    var skyColor = Color(red:0.031, green:0.739, blue:0.861)
    var lightSkyColor = Color(red:0.657, green:0.961, blue: 1.0)
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Vehicle Type") {
                    Picker("Select Type", selection: $vehicleType) {
                        ForEach(VehicleTypes.allCases) { type in
                            Text(type.rawValue)
                        }
                    }
                }
                Section("Vehicle Make") {
                    HStack {
                        Picker("Select Make", selection: $alphabet) {
                            ForEach(Alphbets.allCases) { alpha in
                                Text(alpha.rawValue)
                            }
                        }
                        .onChange(of:$alphabet.id) {
                            model = alphabet.makes.first!.models.first!
                            vehicleMake = alphabet.makes.first!
                        }
                        .pickerStyle(.wheel)
                        Picker("", selection:$vehicleMake) {
                            ForEach(alphabet.makes) { make in
                                Text(make.rawValue)
                            }
                        }
                        .pickerStyle(.wheel)
                    }
                }
                Section("Vehicle Model") {
                    Picker("Select Model", selection: $model) {
                        ForEach(vehicleMake.models, id: \.id) { model in
                            Text(model.rawValue.replacingOccurrences(of: "_", with: " "))
                        }
                    }                   
                    .pickerStyle(.wheel)
                }
                Section("Manufacuring Year") {
                    Picker("Select Year", selection: $year) {
                        ForEach(range.reversed(), id: \.self) { i in
                            Text(String(i))
                        }
                    }
                    .pickerStyle(.wheel)
                }
                Section("Fuel Engine Type") {
                    Picker("Select Type", selection:$fuelType) {
                        ForEach(FuelTypes.allCases) { type in
                            Text(type.rawValue)
                        }
                    }
                    .pickerStyle(.segmented)
                }
                Section("Vehicle Odometer") {
                    TextField("Enter the odometer readings", text: $odometer)
                        .keyboardType(.numberPad)
                }
                Section("Vehicle Trip") {
                    TextField("Enter the Trip readings", text: $trip)
                        .keyboardType(.decimalPad)
                }
                Section(header: Text("Fuel Type")) {
                    Picker("Fuel", selection: $fuelType) {
                        ForEach(FuelTypes.allCases) { type in
                            Text(type.rawValue.capitalized)
                        }
                    }
                    .pickerStyle(.segmented)
                }
                Section(header: Text("Distance Unit")) {
                    Picker("Select Unit", selection: $distanceMode) {
                        ForEach(DistanceModes.allCases) { unit in
                            Text(unit.rawValue.capitalized)
                        }
                    }
                    .pickerStyle(.segmented)
                }
                if fuelType == .Gas {
                    Section(header: Text("Fuel Volume Unit")) {
                        Picker("Select Unit", selection: $fuelMode) {
                            ForEach(FuelModes.allCases) { unit in
                                Text(unit.rawValue.capitalized)
                            }
                        }
                        .pickerStyle(.segmented)
                    }
                }
                if fuelType == .Gas {
                    Section(header: Text("Fuel Efficiency Unit")) {
                        if fuelMode == .Litre {
                            if distanceMode == .km {
                                Picker("Select Unit", selection: $efficiencyMode) {
                                    ForEach(efficiencyModes.indices, id: \.self) {index in
                                        if index < 2 {
                                            Text(efficiencyModes[index])
                                        }
                                    }
                                }
                                .pickerStyle(.segmented)
                            }
                            else {
                                Picker("Select Unit", selection: $efficiencyMode) {
                                    ForEach(efficiencyModes.indices, id: \.self) {index in
                                        if index > 1 && index < 4 {
                                            Text(efficiencyModes[index])
                                        }
                                    }
                                }
                                .pickerStyle(.segmented)
                            }
                        }
                        else if fuelMode == .Gallon {
                            if distanceMode == .km {
                                Picker("Select Unit", selection: $efficiencyMode) {
                                    ForEach(efficiencyModes.indices, id: \.self) { index in
                                        if index > 3 && index < 6 {
                                            Text(efficiencyModes[index])
                                        }
                                    }
                                }
                                .pickerStyle(.segmented)
                            }
                            else {
                                Picker("Select Unit", selection: $efficiencyMode) {
                                    ForEach(efficiencyModes.indices, id: \.self) {index in
                                        if index > 5 && index < 8 {
                                            Text(efficiencyModes[index])
                                        }
                                    }
                                }
                                .pickerStyle(.segmented)
                            }
                        }
                    }
                }
                VStack {
                    Button {
                    let vehicle = Vehicle(context: viewContext)
                    addVehicle(for: vehicle)
                    saveSettings(for: vehicle)                      
                    } label: {
                        FormButton(imageName: "gearshape.fill", text: "Save Settings", color: lightSkyColor)
                    }
                    .background(skyColor)
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
        vehicle.uniqueID = UUID()
        vehicle.model = model.rawValue
        vehicle.make = vehicleMake.rawValue
        vehicle.year = Int16(year)
        vehicle.odometer = Double(odometer) ?? 0
        vehicle.trip = Double(trip) ?? 0
        vehicle.fuelEngine = fuelType.rawValue
        vehicle.type = vehicleType.rawValue
        vehicle.isActive = true
        Vehicle.saveContext(viewContext: viewContext)
    }
    
    func saveSettings(for vehicle: Vehicle) {
        let settings = Settings(context: viewContext)
        settings.vehicle = vehicle
        settings.autoEngineType = fuelType.rawValue
        settings.distanceUnit = distanceMode.rawValue
        settings.fuelVolumeUnit = fuelMode.rawValue
        settings.fuelEfficiencyUnit = efficiencyModes[efficiencyMode]
        Settings.saveContext(viewContext: viewContext)
    }
}

#Preview {
    InitialSettingsView(locationDataManager: LocationDataManager())
}
