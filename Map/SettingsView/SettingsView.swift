//
//  SettingsView.swift
//  Map
//
//  Created by saj panchal on 2024-06-16.
//

import SwiftUI

struct SettingsView: View {

    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(entity:Settings.entity(), sortDescriptors:[]) var setting: FetchedResults<Settings>
    @FetchRequest(entity:Vehicle.entity(), sortDescriptors:[NSSortDescriptor(keyPath: \Vehicle.isActive, ascending: false)]) var vehicles: FetchedResults<Vehicle>
    @StateObject var locationDataManager: LocationDataManager
    @State var vIndex = 0
    @State var vehicle: Vehicle = Vehicle()
    @State var fuelType: FuelTypes = .Gas
    @State var distanceMode: DistanceModes = .km
    @State var fuelMode: FuelModes = .Litre
    @State var efficiencyModes = ["km/L", "L/100km", "miles/L","L/100Miles", "km/gl",  "gl/100km", "miles/gl", "gl/100miles", "km/kwh", "miles/kwh"]
    @State var efficiencyMode = 0
    @State var showAddVehicleForm = false
    @State var carText = ""
    @State var showGarage = false
 
    var body: some View {
        NavigationStack {
            Form {
                Button(action: {
                    showGarage = true
                }, label: {
                    HStack {
                        Image(systemName: "door.garage.double.bay.closed")
                            .foregroundStyle(.invertBlu)
                            .font(Font.system(size: 25))
                        Spacer()
                        Text("Open My Garage")
                            .font(.system(size: 20, weight: .bold))
                        Spacer()
                        
                    }})
                .sheet(isPresented: $showGarage,  content: {GarageView(locationDataManager: locationDataManager, showGarage: $showGarage)})
             
                    Picker(selection: $vehicle) {
                        List {
                            ForEach(vehicles, id: \.uniqueID) { thisVehicle in
                                VStack {
                                    Text(thisVehicle.getVehicleText + " " + thisVehicle.getFuelEngine).tag(thisVehicle)
                                        .fontWeight(.bold)
                                        .font(Font.system(size: 18))
                                        .foregroundStyle(Color(AppColors.invertBlueColor.rawValue))
                                    
                                    Text(thisVehicle.getYear).tag(thisVehicle)
                                        .fontWeight(.semibold)
                                        .font(Font.system(size: 14))
                                        .foregroundStyle(Color.gray)
                                }
                                .tag(thisVehicle)
                            }
                        }
                    }
            label: {
                Text("Vehicle Selection")
                    .fontWeight(.bold)
            }
                    .onChange(of: vehicle) {
                        fuelType = FuelTypes(rawValue: vehicle.fuelEngine ?? "Gas") ?? .Gas
                    }
                    .pickerStyle(.inline)
                
            
                Section(header: Text("Distance Unit").fontWeight(.bold)) {
                    Picker("Select Unit", selection: $distanceMode) {
                        ForEach(DistanceModes.allCases) { thisDistanceUnit in
                            Text(thisDistanceUnit.rawValue.capitalized)
                        }
                    }
                    .pickerStyle(.segmented)
                }
                if !vehicles.isEmpty {
                    if fuelType == .Gas && (vehicles[vIndex].getFuelEngine == "Gas" || vehicles[vIndex].getFuelEngine == "Hybrid") {
                        Section(header: Text("Fuel Volume Unit").fontWeight(.bold)) {
                            Picker("Select Unit", selection: $fuelMode) {
                                ForEach(FuelModes.allCases) { thisVolumeUnit in
                                    Text(thisVolumeUnit.rawValue.capitalized)
                                }
                            }
                            .pickerStyle(.segmented)
                        }
                    }
                    if fuelType == .Gas && (vehicles[vIndex].getFuelEngine == "Gas" || vehicles[vIndex].getFuelEngine == "Hybrid"){
                        Section(header: Text("Fuel Efficiency Unit").fontWeight(.bold)) {
                            if fuelMode == .Litre {
                                if distanceMode == .km {
                                    Picker("Select Unit", selection: $efficiencyMode) {
                                        ForEach(efficiencyModes.indices, id: \.self) { index in
                                            if index < 2 {
                                                Text(efficiencyModes[index])
                                            }
                                        }
                                    }
                                    .onAppear(perform: {
                                        efficiencyMode = efficiencyMode.isMultiple(of: 2) ? 0 : 1
                                    })
                                    .pickerStyle(.segmented)
                                }
                                else {
                                    Picker("Select Unit", selection: $efficiencyMode) {
                                        ForEach(efficiencyModes.indices, id: \.self) { index in
                                            if index > 1 && index < 4 {
                                                Text(efficiencyModes[index])
                                            }
                                        }
                                    }
                                    .onAppear(perform: {
                                        efficiencyMode = efficiencyMode.isMultiple(of: 2) ? 2 : 3
                                    })
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
                                    .onAppear(perform: {
                                        efficiencyMode = efficiencyMode.isMultiple(of: 2) ? 4 : 5
                                    })
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
                                    .onAppear(perform: {
                                        efficiencyMode = efficiencyMode.isMultiple(of: 2) ? 6 : 7
                                    })
                                    .pickerStyle(.segmented)
                                }
                            }
                        }
                    }
                }
                VStack {
                    Button {
                        updateActiveVehicle()
                        saveSettings()
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
            .tint(Color(AppColors.invertBlueColor.rawValue))
            .navigationTitle("Settings")
            .toolbar {
                Button {
                    showAddVehicleForm.toggle()
                }
            label: {
             AddCarImage()             
            }
            .sheet(isPresented: $showAddVehicleForm, content: {
                AddVehicleForm(vehicle: $vehicle, showAddVehicleForm: $showAddVehicleForm, locationDataManager: locationDataManager)
            })
            .padding(.top, 10)
            }
        }
        .onAppear{
            getActiveVehicle()
            loadSettings()
        }
    }
    
    func getActiveVehicle() {
        print("get active vehicle")
        if let object = setting.first {
            if let v = object.vehicle {
                vehicle = v
            }
        }
        if vehicle.make != nil {
            locationDataManager.odometer = vehicle.odometer
            locationDataManager.trip = vehicle.trip
        }
        if vehicles.first(where: {$0.isActive}) != nil {
            vIndex = vehicles.firstIndex(where: {$0.isActive})!
            vehicle = vehicles.first(where: {$0.isActive})!
        }
       
    }
    func loadSettings() {
        if setting.first != nil {           
            efficiencyMode = efficiencyModes.firstIndex(of: setting.first!.getFuelEfficiencyUnit) ?? 0
            distanceMode = DistanceModes(rawValue: setting.first!.getDistanceUnit) ?? .km
            fuelMode = FuelModes(rawValue: setting.first!.getFuelVolumeUnit) ?? .Litre
            fuelType = FuelTypes(rawValue: setting.first!.getAutoEngineType) ??  .Gas
        }
    }
    
    func saveSettings() {
        if setting.first != nil {
            setting.first?.fuelEfficiencyUnit =  efficiencyModes[efficiencyMode]
            setting.first?.distanceUnit = distanceMode.rawValue
            setting.first?.fuelVolumeUnit = fuelMode.rawValue
            setting.first?.autoEngineType = fuelType.rawValue
            setting.first?.vehicle = vehicle
            Settings.saveContext(viewContext: viewContext)
        }
    }
    
    func updateActiveVehicle() {
        if !vehicles.isEmpty {
            for i in vehicles.indices {
                if vehicles[i] != vehicle {
                    vehicles[i].isActive = false
                }
                else {
                    vehicles[i].isActive = true
                }                
            }
//            print("update settings")
//            print("vehicle[\(vehicles.firstIndex(of: vehicle))]: \(vehicle.getVehicleText)")
            locationDataManager.vehicle = vehicle
            locationDataManager.odometer = vehicle.odometer
            locationDataManager.trip = vehicle.trip
            Vehicle.saveContext(viewContext: viewContext)
        }
        else {
//            print("no vehicles added yet")
        }
    }
}

#Preview {
    SettingsView(locationDataManager: LocationDataManager())
}
