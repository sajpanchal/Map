//
//  SettingsView.swift
//  Map
//
//  Created by saj panchal on 2024-06-16.
//

import SwiftUI

struct SettingsView: View {

    @Environment(\.managedObjectContext) private var viewContext
    ///Fetch request to get the records from the Settings entity.
    @FetchRequest(entity:Settings.entity(), sortDescriptors:[]) var settings: FetchedResults<Settings>
    ///Fetch request to get the records from the vehicles entity in descending order which is currently active.
    @FetchRequest(entity:Vehicle.entity(), sortDescriptors:[NSSortDescriptor(keyPath: \Vehicle.isActive, ascending: false)]) var vehicles: FetchedResults<Vehicle>
    ///Location Data manager object.
    @StateObject var locationDataManager: LocationDataManager
    ///Index of the vehicle objects array
    @State var vehicleIndex = 0
    ///instaintiate the empty vehicle object to prevent picker view to throw error.
    @State var vehicle: Vehicle = Vehicle()
    ///enum type to store fuel type of vehicle
    @State var fuelType: FuelTypes = .Gas
    ///enum type to store the distance unit
    @State var distanceUnit: DistanceUnit = .km
    ///enum type to store the fuel unit.
    @State var fuelUnit: FuelUnit = .Litre
    ///efficiency units array
    @State var efficiencyUnits = ["km/L", "L/100km", "miles/L","L/100Miles", "km/gl",  "gl/100km", "miles/gl", "gl/100miles", "km/kwh", "miles/kwh"]
    ///efficiency unit index
    @State var efficiencyUnitIndex = 0
    ///flag to show/hide add vehicle form
    @State var showAddVehicleForm = false
    ///flag to show the auto garage view.
    @State var showGarage = false
 
    var body: some View {
    
        NavigationStack {
            Form {
                ///button to access the garage screen
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
                ///if the button is tapped the flag will be set and it will show the content which is garageview.
                .sheet(isPresented: $showGarage,  content: {GarageView(locationDataManager: locationDataManager, showGarage: $showGarage)})
                    ///picker for vehicles.
                    Picker(selection: $vehicle) {
                        ///iist of vehciles
                        List {
                            ///iterate through the all vehicles uniquely identified by this ID.
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
                                ///assign a unique tag to this view for a given vehicle so it can be identified on tap.
                                .tag(thisVehicle)
                            }
                        }
                    }
                    ///creater the label of the picker with a pre-defined text
                    label: {
                        Text("Vehicle Selection")
                            .fontWeight(.bold)
                    }
                ///on change of the vehicle selection change the fuel type value
                    .onChange(of: vehicle) {
                        fuelType = FuelTypes(rawValue: vehicle.fuelEngine ?? "Gas") ?? .Gas
                    }
                    .pickerStyle(.inline)
                ///picker for selecting distnace unit
                Section(header: Text("Distance Unit").fontWeight(.bold)) {
                    Picker("Select Unit", selection: $distanceUnit) {
                        ForEach(DistanceUnit.allCases) { thisDistanceUnit in
                            Text(thisDistanceUnit.rawValue.capitalized)
                        }
                    }
                    .pickerStyle(.segmented)
                }
                ///if vehciles record is not empty
                if !vehicles.isEmpty {
                    ///if the vehicle type is gas or hybrid
                    if fuelType == .Gas && (vehicles[vehicleIndex].getFuelEngine == "Gas" || vehicles[vehicleIndex].getFuelEngine == "Hybrid") {
                        ///picker for fuel unit selection
                        Section(header: Text("Fuel Volume Unit").fontWeight(.bold)) {
                            Picker("Select Unit", selection: $fuelUnit) {
                                ForEach(FuelUnit.allCases) { thisVolumeUnit in
                                    Text(thisVolumeUnit.rawValue.capitalized)
                                }
                            }
                            .pickerStyle(.segmented)
                        }
                        ///picker for fuel efficiency unit selection
                        Section(header: Text("Fuel Efficiency Unit").fontWeight(.bold)) {
                            ///if fuel unit is selected to litre
                            if fuelUnit == .Litre {
                                ///if the distance unit is selected to km
                                if distanceUnit == .km {
                                    ///show picker with options having an efficiency combination of  km and litre
                                    Picker("Select Unit", selection: $efficiencyUnitIndex) {
                                        ForEach(efficiencyUnits.indices, id: \.self) { index in
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
                                ///if the distance unit is in miltes
                                else {
                                    Picker("Select Unit", selection: $efficiencyUnitIndex) {
                                        ForEach(efficiencyUnits.indices, id: \.self) { index in
                                            if index > 1 && index < 4 {
                                                Text(efficiencyUnits[index])
                                            }
                                        }
                                    }
                                    ///on appear of this picker set the efficiency unit index to 2 if previous index is multiple of 2 or 3.
                                    .onAppear(perform: {
                                        efficiencyUnitIndex = efficiencyUnitIndex.isMultiple(of: 2) ? 2 : 3
                                    })
                                    .pickerStyle(.segmented)
                                }
                            }
                            ///if fuel unit is selected to gallon
                            else if fuelUnit == .Gallon {
                                ///if the distance unit is selected to km
                                if distanceUnit == .km {
                                    Picker("Select Unit", selection: $efficiencyUnitIndex) {
                                        ForEach(efficiencyUnits.indices, id: \.self) { index in
                                            if index > 3 && index < 6 {
                                                Text(efficiencyUnits[index])
                                            }
                                        }
                                    }
                                    ///on appear of this picker set the efficiency unit index to 2 if previous index is multiple of 4 or 5.
                                    .onAppear(perform: {
                                        efficiencyUnitIndex = efficiencyUnitIndex.isMultiple(of: 2) ? 4 : 5
                                    })
                                    .pickerStyle(.segmented)
                                }
                                ///if the distance unit is selected to miles
                                else {
                                    Picker("Select Unit", selection: $efficiencyUnitIndex) {
                                        ForEach(efficiencyUnits.indices, id: \.self) {index in
                                            if index > 5 && index < 8 {
                                                Text(efficiencyUnits[index])
                                            }
                                        }
                                    }
                                    ///on appear of this picker set the efficiency unit index to 2 if previous index is multiple of 6 or 7.
                                    .onAppear(perform: {
                                        efficiencyUnitIndex = efficiencyUnitIndex.isMultiple(of: 2) ? 6 : 7
                                    })
                                    .pickerStyle(.segmented)
                                }
                            }
                        }
                    }
                }
                ///vstack enclosing the form submit button
                VStack {
                    Button {
                        ///on tap update the active vehicle
                        updateActiveVehicle()
                        ///on tap save settings
                        saveSettings()
                    } label: {
                        FormButton(imageName: "gearshape.fill", text: "Save Settings", color: Color(AppColors.blueColor.rawValue))
                    }
                    .background(Color(AppColors.invertBlueColor.rawValue))
                    .buttonStyle(BorderlessButtonStyle())
                    .cornerRadius(100)
                }
                ///remove the list row color of the form
                .listRowBackground(Color.clear)
                ///apply the insets up to the edge of the screen.
                .listRowInsets(EdgeInsets())
            }
            ///apply the tint color the the view.
            .tint(Color(AppColors.invertBlueColor.rawValue))
            .navigationTitle("Settings")
            ///create a form toolbar to be appear on top right corner and add a button to it.
            .toolbar {
                Button {
                    showAddVehicleForm.toggle()
                }
                label: {
                 AddCarImage()
                }
                ///on tap of the button, flag will be true and content (AddVehicleForm) will appear.
                .sheet(isPresented: $showAddVehicleForm, content: {
                    AddVehicleForm(vehicle: $vehicle, showAddVehicleForm: $showAddVehicleForm, locationDataManager: locationDataManager)
                })
                .padding(.top, 10)
            }
        }
        ///on appear get the active vehicle and load the latest settings.
        .onAppear{
            getActiveVehicle()
            loadSettings()
        }
    }
    
    ///method to get the currently active vehicle from the core data entities.
    func getActiveVehicle() {
        ///if there is any active vehicle set in the entities
        if let activeVehicle = vehicles.first(where: {$0.isActive}) {
            ///get the index of the active vehicle
            if let activeVehicleIndex = vehicles.firstIndex(where: {$0.isActive}) {
                ///assign the index to state variable
                vehicleIndex = activeVehicleIndex
                ///assign the active vehicle to state variable
                vehicle = activeVehicle
            }
        }
        ///if no active vehicle found
        else {
            ///get the first settings object from entities if available
            guard let thisSetting = settings.first else {
                return
            }
            ///get the first vehicle from the settings object if available
            guard let thisVehicle = thisSetting.vehicle else {
            return
            }
            ///assign the fetched vehicle to the state varaible vehicle
            vehicle = thisVehicle
        }
        ///update the odometer of the location manager with the odometer of the currently active vehicle
        locationDataManager.odometer = vehicle.odometer
        /// ///update the trip odometer of the location manager with the trip odometer of the currently active vehicle
        locationDataManager.trip = vehicle.trip
    }
    
    ///method to load the latest saved settings from the system
    func loadSettings() {
        ///get the setting object from settings entity if available
        if let thisSetting = settings.first {
            ///assign the efficiency unit index of a set unit from the array to state variable
            efficiencyUnitIndex = efficiencyUnits.firstIndex(of: thisSetting.getFuelEfficiencyUnit) ?? 0
            ///get the enum value of the corresponding distance unit saved in the settings and assign it to the state variable
            distanceUnit = DistanceUnit(rawValue: thisSetting.getDistanceUnit) ?? .km
            ///get the enum value of the fuel volume unit of the corresponding fuel unit saved in the settings and assign it to the state variable
            fuelUnit = FuelUnit(rawValue: thisSetting.getFuelVolumeUnit) ?? .Litre
            ///get the enum value of the engine type of the corresponding engine type saved in the settings and assign it to the state variable
            fuelType = FuelTypes(rawValue: thisSetting.getAutoEngineType) ?? .Gas
        }
    }
    
    ///method to save settings
    func saveSettings() {
        ///if the first element of the settings entity is not nil
        if settings.first != nil {
            ///store the efficiency unit from the array
            settings.first?.fuelEfficiencyUnit =  efficiencyUnits[efficiencyUnitIndex]
            ///store the distance unit from  enum's string value
            settings.first?.distanceUnit = distanceUnit.rawValue
            ///store the fuel unit from  enum's string value
            settings.first?.fuelVolumeUnit = fuelUnit.rawValue
            ///store the engine type from  enum's string value
            settings.first?.autoEngineType = fuelType.rawValue
            ///store the currently active vehicle object from state varaible
            settings.first?.vehicle = vehicle
            ///save the records to the entity to the viewcontext parent store.
            Settings.saveContext(viewContext: viewContext)
        }
    }
    
    ///method the update the active vehicle and save changes.
    func updateActiveVehicle() {
        ///return the function call if vehicles entity is empty
        guard !vehicles.isEmpty else {
            return
        }
        ///iterate through all the indexes of the vehicles array
        for index in vehicles.indices {
            ///if the given vehicle at a given index is not the vehicle currenty active
            if vehicles[index] != vehicle {
                ///set that vehicle as not active
                vehicles[index].isActive = false
            }
            ///if the given vehicle at a given index is the vehicle currenty active
            else {
                ///set that vehicle as active
                vehicles[index].isActive = true
            }
        }
        ///set the active vehicle as location manager's vehicle
        locationDataManager.vehicle = vehicle
        ///set the active vehicle's odometer as location manager's odometer
        locationDataManager.odometer = vehicle.odometer
        ///set the active vehicle's trip odometer as location manager's trip odometer
        locationDataManager.trip = vehicle.trip
        ///save the changes to the entities of the viewcontext to the parent store.
        Vehicle.saveContext(viewContext: viewContext)
                        
    }
}

#Preview {
    SettingsView(locationDataManager: LocationDataManager())
}
