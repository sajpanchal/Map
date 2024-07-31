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
    @FetchRequest(entity:Vehicle.entity(), sortDescriptors:[]) var vehicles: FetchedResults<Vehicle>
    @StateObject var locationDataManager: LocationDataManager
    @State var vIndex = 0
    @State var vehicle: Vehicle?
    @State var fuelType: FuelTypes = .Gas
    @State var distanceMode: DistanceModes = .km
    @State var fuelMode: FuelModes = .Litre
    @State var efficiencyModes = ["km/L", "L/100km", "miles/L","L/100Miles", "km/gl",  "gl/100km", "miles/gl", "gl/100miles", "km/kwh", "miles/kwh"]
    @State var efficiencyMode = 0
    @State var showAddVehicleForm = false
    @State var carText = ""
    var skyColor = Color(red:0.031, green:0.739, blue:0.861)
    var lightSkyColor = Color(red:0.657, green:0.961, blue: 1.0)
 
    var body: some View {
        NavigationStack {
            Form {
                NavigationLink("Go to Your Garage", destination: GarageView(locationDataManager: locationDataManager))
                Section(header:Text("Vehicle Selection")) {
                    Picker("Select Vehicle", selection: $vIndex) {
                        List {
                            ForEach(vehicles.indices, id: \.self) { v in
                              VehicleListItem(v: v)
                            }
                        }
                    }
                    .onChange(of: vIndex) {
                        fuelType = FuelTypes(rawValue: vehicles[vIndex].getFuelEngine) ?? .Gas
                    }
                    .pickerStyle(.inline)
                }
                if !vehicles.isEmpty {
                    Section(header: Text("Fuel Type")) {
                        if vehicles[vIndex].getFuelEngine != "Hybrid" {
                            Picker("Select type", selection: $fuelType) {
                                Text(vehicles[vIndex].getFuelEngine)
                            }
                        }
                        else {
                            Picker("Fuel", selection: $fuelType) {
                                ForEach(FuelTypes.allCases) { type in
                                    Text(type.rawValue.capitalized)
                                }
                            }
                            .pickerStyle(.segmented)
                        }
                    }
                }
                Section(header: Text("Distance Unit")) {
                    Picker("Select Unit", selection: $distanceMode) {
                        ForEach(DistanceModes.allCases) { unit in
                            Text(unit.rawValue.capitalized)
                        }
                    }
                    .pickerStyle(.segmented)
                }
                if !vehicles.isEmpty {
                    if fuelType == .Gas && (vehicles[vIndex].getFuelEngine == "Gas" || vehicles[vIndex].getFuelEngine == "Hybrid") {
                        Section(header: Text("Fuel Volume Unit")) {
                            Picker("Select Unit", selection: $fuelMode) {
                                ForEach(FuelModes.allCases) { unit in
                                    Text(unit.rawValue.capitalized)
                                }
                            }
                            .pickerStyle(.segmented)
                        }
                    }
                    if fuelType == .Gas && (vehicles[vIndex].getFuelEngine == "Gas" || vehicles[vIndex].getFuelEngine == "Hybrid"){
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
                }
                VStack {
                    Button {
                       updateActiveVehicle()
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
            .toolbar {
                Button {
                    showAddVehicleForm.toggle()
                }
            label: {
             AddCarImage()             
            }
            .sheet(isPresented: $showAddVehicleForm, content: {
                AddVehicleForm(showAddVehicleForm: $showAddVehicleForm)
            })
            .padding(.top, 10)
            }
        }
        .onAppear{
            getActiveVehicle()
        }
    }
    
    func getActiveVehicle() {
        if let object = setting.first {
            if let v = object.vehicle {
                vehicle = v
            }
        }
        if let object = vehicle {
            locationDataManager.odometer = object.odometer
            locationDataManager.trip = object.trip
        }
        vIndex = vehicles.firstIndex(where: {$0.isActive}) ?? vIndex
    }
    
    func updateActiveVehicle() {
        if !vehicles.isEmpty {
            for i in vehicles.indices {
                if i != vIndex {
                    vehicles[i].isActive = false
                }
                else {
                    vehicles[i].isActive = true
                    vehicle = vehicles[i]
                    locationDataManager.index = i
                    locationDataManager.odometer = vehicles[i].odometer
                    locationDataManager.trip = vehicles[i].trip
                }                
            }
            Vehicle.saveContext(viewContext: viewContext)
          
        }
        else {
            print("no vehicles added yet")
        }
    }
        
}

#Preview {
    SettingsView(locationDataManager: LocationDataManager())
}
