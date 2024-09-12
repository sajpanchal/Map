//
//  updateVehicleView.swift
//  Map
//
//  Created by saj panchal on 2024-07-17.
//

import SwiftUI

struct UpdateVehicleView: View {
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
    @Environment(\.managedObjectContext) private var viewContext
    @State var vIndex = 0
    @StateObject var locationDataManager: LocationDataManager
  
    @State var distanceUnit: DistanceUnit = .km
    @State var fuelUnit: FuelUnit = .Litre
    @State var efficiencyModes = ["km/L", "L/100km", "miles/L","L/100Miles", "km/gl",  "gl/100km", "miles/gl", "gl/100miles", "km/kwh", "miles/kwh"]
    @State var efficiencyMode = 0
    @State var showAddVehicleForm = false
    @Binding var showGarage: Bool
    var settings: Settings
    var vehicle: Vehicle
    
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
                        .onChange(of: vehicleMake) {
                            model = vehicleMake.models.first ?? .Other
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
                    Picker("Select Unit", selection: $distanceUnit) {
                        ForEach(DistanceUnit.allCases) { unit in
                            Text(unit.rawValue.capitalized)
                        }
                    }
                    .pickerStyle(.segmented)
                }
                 
                if fuelType == .Gas {
                    Section(header: Text("Fuel Volume Unit")) {
                        Picker("Select Unit", selection: $fuelUnit) {
                            ForEach(FuelUnit.allCases) { unit in
                                Text(unit.rawValue.capitalized)
                            }
                        }
                        .pickerStyle(.segmented)
                    }
                }
                if fuelType == .Gas {
                    Section(header: Text("Fuel Efficiency Unit")) {
                        if fuelUnit == .Litre {
                            if distanceUnit == .km {
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
                        else if fuelUnit == .Gallon {
                            if distanceUnit == .km {
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
        settings.distanceUnit = distanceUnit.rawValue
        settings.fuelVolumeUnit = fuelUnit.rawValue
        settings.fuelEfficiencyUnit = efficiencyModes[efficiencyMode]
        Settings.saveContext(viewContext: viewContext)
    }
    func fillForm() {
        vehicleType = VehicleTypes(rawValue: vehicle.getType) ?? .Car
        vehicleMake = VehicleMake(rawValue: vehicle.getMake) ?? .AC
        model = Model(rawValue: vehicle.getModel) ?? .ATS
        year = Int(vehicle.year)
        alphabet = Alphbets(rawValue: String(vehicleMake.rawValue.first ?? "A").uppercased()) ?? .A
        fuelType = FuelTypes(rawValue: vehicle.getFuelEngine) ?? .Gas
        odometer = String(vehicle.odometer)
        trip = String(vehicle.trip)
        distanceUnit = DistanceUnit(rawValue: settings.getDistanceUnit) ?? .km
        fuelUnit = FuelUnit(rawValue: settings.getFuelVolumeUnit) ?? .Litre
        efficiencyMode = efficiencyModes.firstIndex(where: {$0 == settings.fuelEfficiencyUnit}) ?? 0
    }
}

#Preview {
    UpdateVehicleView(locationDataManager: LocationDataManager(), showGarage: .constant(false), settings: Settings(), vehicle: (Vehicle()))
}
