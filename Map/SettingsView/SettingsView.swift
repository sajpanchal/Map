//
//  SettingsView.swift
//  Map
//
//  Created by saj panchal on 2024-06-16.
//

import SwiftUI

struct SettingsView: View {
    @Environment(\.colorScheme) var bgMode: ColorScheme
    @Environment(\.managedObjectContext) private var viewContext
    ///Fetch request to get the records from the Settings entity.
    @FetchRequest(entity:Settings.entity(), sortDescriptors:[]) var settings: FetchedResults<Settings>
    ///Fetch request to get the records from the vehicles entity in descending order which is currently active.
    @FetchRequest(entity:Vehicle.entity(), sortDescriptors:[NSSortDescriptor(keyPath: \Vehicle.isActive, ascending: false)]) var vehicles: FetchedResults<Vehicle>
    ///Location Data manager object.
    @StateObject var locationDataManager: LocationDataManager
    ///Index of the vehicle objects array
    @State private var vehicleIndex = 0
    ///instaintiate the empty vehicle object to prevent picker view to throw error.
    @State private var vehicle: Vehicle = Vehicle()
    ///enum type to store engine type of vehicle
    @State private var engineType: EngineType = .Gas
    ///enum type to store fuel mode  of vehicle
    @State private var fuelMode: FuelMode = .Gas
    ///enum type to store the distance unit
    @State private var distanceUnit: DistanceUnit = .km
    ///enum type to store the fuel unit.
    @State private var fuelUnit: FuelUnit = .Litre
    ///efficiency units array
    @State private var efficiencyUnits = ["km/L", "L/100km", "miles/L","L/100miles", "km/gl",  "gl/100km", "miles/gl", "gl/100miles", "km/kwh", "miles/kwh"]
    ///efficiency unit index
    @State private var efficiencyUnitIndex = 0
    ///flag to show/hide add vehicle form
    @State private var showAddVehicleForm = false
    ///flag to show the auto garage view.
    @State private var showGarage = false
    ///flag to show if preference is set to avoid highways
    @State private var avoidHighways = false
    ///flag to show if preference is set to avoid tolls
    @State private var avoidTolls = false
    ///flag to show/hide alert view.
    @State private var showAlert = false
    ///index of the vehicles list.
    @State private var vehiclesListIndex: Int = 0
    ///create an array of vehicleData to be displayed in the picker view from vehicles.
    var vehiclesList: [VehicleData] {
        return vehicles.map({VehicleData(uniqueID: $0.uniqueID, text: $0.getVehicleText, engineType: $0.getFuelEngine)})
    }
    ///array of colors
    let colors = [AppColors.invertGryColor.rawValue,AppColors.invertPink.rawValue, AppColors.invertGreen.rawValue,AppColors.invertSky.rawValue,AppColors.invertYellow.rawValue, AppColors.invertPurple.rawValue, AppColors.invertOrange.rawValue]
   
    var body: some View {
            NavigationStack {
                ZStack {
                    VStack {
                        Form {
                            ///button to access the garage screen
                            VStack {
                                HStack {
                                    Spacer()
                                    Button(action: {
                                        showGarage = true
                                    }, label: {
                                        FormButton(imageName:  "door.garage.double.bay.closed", text: "My Garage", color: Color(AppColors.red.rawValue))
                                        })
                                    .background(Color(AppColors.invertRed.rawValue))
                                    .tint(Color(AppColors.invertRed.rawValue))
                                    .buttonStyle(BorderlessButtonStyle())
                                    .cornerRadius(100)
                                    .shadow(color: bgMode == .dark ? .gray : .black, radius: 1, x: 1, y: 1)
                                    ///if the button is tapped the flag will be set and it will show the content which is garageview.
                                    .sheet(isPresented: $showGarage,  content: {
                                        GarageView(locationDataManager: locationDataManager, showGarage: $showGarage)
                                    })
                                    Spacer()
                                }
                            }
                            .listRowInsets(EdgeInsets())
                            .listRowBackground(Color.clear)
                            
                            Section(header: Text("Current Vehicle Selection").fontWeight(.bold)) {
                                ///picker for vehicles.
                                Picker(selection: $vehiclesListIndex) {
                                        ///iterate through the all vehicles uniquely identified by itself
                                    ForEach(0..<vehiclesList.count, id: \.self) { index in
                                        Text(vehiclesList[index].text + " " + (vehiclesList[index].engineType != "Gas" ? vehiclesList[index].engineType : ""))
                                                        .multilineTextAlignment(.leading)
                                                        .fontWeight(.bold)
                                                        .font(Font.system(size: 18))
                                                        .foregroundStyle(Color(colors[getColorIndex(for:index)]))
                                                        .padding(10)
                                                        .tag(vehiclesList[index].uniqueID)
                                        }
                                }
                                ///creater the label of the picker with a pre-defined text
                                label: {
                                    Text("Vehicle")
                                        .font(Font.system(size: 18))
                                }
                                .onAppear(perform: {
                                    print("Picker")
                                })
                            ///on change of the vehicle selection update the settings
                                .onChange(of: vehiclesListIndex) {
                                    ///get the vehicle from vehicles entity where uniqueID matches with the selected vehicle from picker view.
                                    guard let selectedVehicle = vehicles.first(where: {$0.uniqueID == vehiclesList[vehiclesListIndex].uniqueID}) else {
                                       return
                                    }
                                    print("on change of vehicle index")
                                    ///set the vehicle prop as selected vehicle.
                                    vehicle = selectedVehicle
                                    ///call load settings method.
                                    loadSettings()
                                    ///set the engine type prop to whatever selected vehicle is set.
                                    engineType = EngineType(rawValue: vehicle.fuelEngine ?? "Gas") ?? .Gas
                                    ///set the engine type prop to whatever selected vehicle is set.
                                    fuelMode = FuelMode(rawValue: vehicle.fuelMode ?? "Gas") ?? .Gas
                                }
                                .pickerStyle(.navigationLink)
                            }
                            ///section for navigation preferences
                            Section(header: Text("Navigation Preferences").fontWeight(.bold)) {
                                ///toggle switch to avoid tolls
                                Toggle("Avoid Tolls", isOn: $avoidTolls)
                                ///toggle switch to avoid highways
                                Toggle("Avoid Highways", isOn: $avoidHighways)
                            }
                            ///picker for selecting distnace unit
                            Section(header: Text("Distance Unit").fontWeight(.bold)) {
                                Picker("Select Unit", selection: $distanceUnit) {
                                    ForEach(DistanceUnit.allCases) { thisDistanceUnit in
                                        Text(thisDistanceUnit.rawValue.capitalized)
                                    }
                                }
                                .pickerStyle(.segmented)
                            }
                            ///if fuel engine is hybrid type
                            if engineType == .Hybrid {
                                ///show picker to select engine mode
                                Section(header: Text("Engine Type").fontWeight(.bold)) {
                                    Picker("Select Type", selection: $fuelMode) {
                                        ForEach(FuelMode.allCases) { thisFuelType in
                                            Text(thisFuelType.rawValue.capitalized)
                                        }
                                    }
                                    ///on change of fuel mode
                                    .onChange(of: fuelMode) {
                                        ///if fuel mode is set to EV
                                        if fuelMode == .EV {
                                            ///set fuel unit to percent
                                            fuelUnit = .Percent
                                        }
                                        else {
                                            fuelUnit = .Litre
                                        }
                                    }
                                    .pickerStyle(.segmented)
                                }
                            }
                            ///if vehciles record is not empty
                            if !vehicles.isEmpty {
                                ///if the vehicle type is gas or hybrid
                                if fuelMode == .Gas {
                                    ///picker for fuel unit selection
                                    Section(header: Text("Fuel Volume Unit").fontWeight(.bold)) {
                                        Picker("Select Unit", selection: $fuelUnit) {
                                            ForEach(FuelUnit.allCases) { thisVolumeUnit in
                                                ///if fuel unit is not percent
                                                if thisVolumeUnit != .Percent {
                                                    Text(thisVolumeUnit.rawValue.capitalized)
                                                }
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
                                else {
                                    ///picker for fuel unit selection
                                    Section(header: Text("Fuel Volume Unit").fontWeight(.bold)) {
                                        Picker("Select Unit", selection: $fuelUnit) {
                                            ForEach(FuelUnit.allCases) { thisVolumeUnit in
                                                ///if the fuel unit is percent
                                                if thisVolumeUnit == .Percent {
                                                    Text(thisVolumeUnit.rawValue.capitalized)
                                                }
                                            }
                                        }
                                        .pickerStyle(.segmented)
                                    }
                                    ///section to select the fuel efficiency unit.
                                    Section(header: Text("Fuel Efficiency Unit").fontWeight(.bold)) {
                                        ///if the distance unit is in km.
                                        if distanceUnit == .km {
                                            ///show units for km
                                            Picker("Select Unit", selection: $efficiencyUnitIndex) {
                                                ForEach(efficiencyUnits.indices, id: \.self) { index in
                                                    if index == 8 {
                                                        Text(efficiencyUnits[index])
                                                    }
                                                }
                                            }
                                            ///on appear of this picker set the efficiency unit index to 0 if previous index is multiple of 2 or 1.
                                            .onAppear(perform: {
                                                efficiencyUnitIndex = 8
                                            })
                                            .pickerStyle(.segmented)
                                        }
                                        ///if the distance unit is in miles
                                        else {
                                            ///show units for miles
                                            Picker("Select Unit", selection: $efficiencyUnitIndex) {
                                                ForEach(efficiencyUnits.indices, id: \.self) {index in
                                                    if index == 9 {
                                                        Text(efficiencyUnits[index])
                                                    }
                                                }
                                            }
                                            ///on appear of this picker set the efficiency unit index to 0 if previous index is multiple of 2 or 1.
                                            .onAppear(perform: {
                                                
                                                efficiencyUnitIndex = 9
                                            })
                                            .pickerStyle(.segmented)
                                    }
                                    }
                                }
                            }
                            ///vstack enclosing the form submit button
                            VStack {
                                HStack {
                                    Spacer()
                                    Button {
                                       
                                        ///on tap update the active vehicle
                                        updateActiveVehicle()
                                        ///on tap save settings
                                        saveSettings()
                                        ///set the vehicleListIndex the index of the selected vehicle from an array of list.
                                        vehiclesListIndex = vehiclesList.firstIndex(where: {$0.uniqueID == vehicle.uniqueID}) ?? 0
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
                            ///remove the list row color of the form
                            .listRowBackground(Color.clear)
                            ///apply the insets up to the edge of the screen.
                            .listRowInsets(EdgeInsets())
                        }
                    }
                    if showAlert {
                        AlertView(image: "checkmark.icloud", headline: "settings saved!", bgcolor: Color(AppColors.invertBlueColor.rawValue), showAlert: $showAlert)
                    }
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
            .onChange(of: showGarage) {
                print("on change")
                getActiveVehicle()
                ///call a method to load settings.
                loadSettings()
            }
        ///on appear get the active vehicle and load the latest settings.
        .onAppear {
            print("On appear of settings")
            ///call a method to get the active vehicle
            getActiveVehicle()
            ///call a method to load settings.
            loadSettings()            
        }
    }
    
    ///method to get the currently active vehicle from the core data entities.
    func getActiveVehicle() {
        ///if there is any active vehicle set in the entities
        guard let activeVehicle = vehicles.first(where: {$0.isActive}) else {
            return
        }
       
        ///get the index of the active vehicle
        if let activeVehicleIndex = vehicles.firstIndex(where: {$0.isActive}) {
            ///assign the index to state variable
            vehicleIndex = activeVehicleIndex
            ///assign the active vehicle to state variable
            vehicle = activeVehicle
            ///set the vehicleListIndex the index of the selected vehicle from an array of list.
            vehiclesListIndex = vehiclesList.firstIndex(where: {$0.uniqueID == vehicle.uniqueID}) ?? 0
        }
        ///update the odometer of the location manager with the odometer of the currently active vehicle
        locationDataManager.odometer = vehicle.odometer
        ///update the odometer of the location manager with the odometer of the currently active vehicle
        locationDataManager.odometerMiles = vehicle.odometerMiles
         ///update the trip odometer of the location manager with the trip odometer of the currently active vehicle
        guard let vehicleSettings = vehicle.settings else {
            return
        }
        if vehicleSettings.distanceUnit == "km" {
            locationDataManager.trip = vehicle.trip
            locationDataManager.tripMiles =  locationDataManager.trip * 0.6214
        }
        else {
            locationDataManager.tripMiles = vehicle.tripMiles
            locationDataManager.trip = vehicle.trip / 0.6214
        }
    }
    
    ///method to load the latest saved settings from the system
    func loadSettings() {
        print("load settings")
        print(vehicle.getVehicleText)
        print(vehicle.settings ?? "n/a")
        ///get the setting object from settings entity if available
        guard let thisSettings = vehicle.settings  else {
            print("no settings found")
            return
        }
            ///assign the efficiency unit index of a set unit from the array to state variable
            efficiencyUnitIndex = efficiencyUnits.firstIndex(of: thisSettings.getFuelEfficiencyUnit) ?? 0
            ///get the enum value of the corresponding distance unit saved in the settings and assign it to the state variable
            distanceUnit = DistanceUnit(rawValue: thisSettings.getDistanceUnit) ?? .km
            print("fuel mode: ", vehicle.getFuelMode)
            print("fuel unit: ", thisSettings.getFuelVolumeUnit)
            ///if vehicle fuel mode is set to EV
            if vehicle.getFuelMode == "EV" {
                ///update the fuelUnit prop to percent
                fuelUnit = .Percent
                ///update the fuelMode prop to EV
                fuelMode = .EV
            }
            ///if vehicle fuel mode is set to Gas
            else {
                ///if the settings have fuel volume set to % change it to Litre otherwise get the unit set from the settings object.
                fuelUnit = thisSettings.getFuelVolumeUnit != "%" ? FuelUnit(rawValue: thisSettings.getFuelVolumeUnit) ?? .Litre : .Litre
                ///update the fuelMode prop to Gas
                fuelMode = .Gas
            }
            ///get the enum value of the engine type of the corresponding engine type saved in the settings and assign it to the state variable
            engineType = EngineType(rawValue: vehicle.getFuelEngine) ?? .Gas
            ///update the avoidHighways preferences to whatever is in the settings object
            avoidHighways = thisSettings.avoidHighways
            ///update the avoidTolls preferences to whatever is in the settings object
            avoidTolls = thisSettings.avoidTolls
        
    }
    
    ///method to save settings
    func saveSettings() {
        print(fuelUnit)
        print(fuelMode)
        print(efficiencyUnits)
        if vehicle.settings == nil {
            let settings = Settings(context: viewContext)
            settings.avoidHighways = avoidHighways
            ///update the settings for avoid toll preference
            settings.avoidTolls = avoidTolls
            ///store the efficiency unit from the array
            settings.fuelEfficiencyUnit =  efficiencyUnits[efficiencyUnitIndex]
            ///store the distance unit from  enum's string value
            settings.distanceUnit = distanceUnit.rawValue
            ///set the distance unit for MapView API.
            MapViewAPI.distanceUnit = distanceUnit
            ///store the fuel unit from  enum's string value
            settings.fuelVolumeUnit = fuelUnit.rawValue
            ///store the engine type from  enum's string value
            settings.autoEngineType = engineType.rawValue
            ///store the currently active vehicle object from state varaible
            settings.vehicle = vehicle
            guard let vIndex = vehicles.firstIndex(of: vehicle) else {
                return
               
            }
            vehicles[vIndex].settings = settings
            ///save the records to the entity to the viewcontext parent store.
            Settings.saveContext(viewContext: viewContext)
        }
        ///if the first element of the settings entity is not nil
        else {
            ///update the settings for avoid highway preference
            vehicle.settings!.avoidHighways = avoidHighways
            ///update the settings for avoid toll preference
            vehicle.settings!.avoidTolls = avoidTolls
            ///store the efficiency unit from the array
            vehicle.settings!.fuelEfficiencyUnit =  efficiencyUnits[efficiencyUnitIndex]
            ///store the distance unit from  enum's string value
            vehicle.settings!.distanceUnit = distanceUnit.rawValue
            ///set the distance unit for MapView API.
            MapViewAPI.distanceUnit = distanceUnit
            ///store the fuel unit from  enum's string value
            vehicle.settings!.fuelVolumeUnit = fuelUnit.rawValue
            ///store the engine type from  enum's string value
            vehicle.settings!.autoEngineType = engineType.rawValue
            ///store the currently active vehicle object from state varaible
            vehicle.settings!.vehicle = vehicle
            ///if the vehicle is hybrid type
            if vehicle.fuelEngine == "Hybrid" {
                ///update the vehicle fule mode to whatever is there in the fuelMode props
                vehicle.fuelMode = fuelMode.rawValue
            }
            ///if the vehicle is EV type
            else if vehicle.fuelEngine == "EV" {
                ///update the vehicle fule mode to EV
                vehicle.fuelMode = "EV"
            }
            ///if the vehicle is Gas type
            else {
                ///update the vehicle fule mode to Gas
                vehicle.fuelMode = "Gas"
            }
            guard let vIndex = vehicles.firstIndex(of: vehicle) else {
                return
               
            }
            vehicles[vIndex].settings = vehicle.settings!
            ///save the records to the entity to the viewcontext parent store.
            Settings.saveContext(viewContext: viewContext)
            ///withAnimation method will change state variable with animation for a given time duration
            withAnimation(.easeIn(duration: 0.5)) {
                showAlert = true
            }
        }
    }
    
    ///method to get the index of the colors array
    func getColorIndex(for index: Int) -> Int {
        ///set the updated Index value with the index value received from function call or recursive call.
        var updatedIndex = index
       ///if the index is within the array bounds
        if index < colors.count {
            ///return the index value and exit function.
            return index
        }
        ///if the difference between the index number and array size is out of array bounds
        else if index - colors.count >= colors.count {
            ///call the function again and get the updated index from the diffrerence
            updatedIndex = getColorIndex(for: index - colors.count)
        }
        ///if the difference is within the array bounds
        else {
            ///return the difference as the index number
            return  index - colors.count
        }
        return updatedIndex
        
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
                vehicles[index].fuelMode = fuelMode.rawValue
            }
        }
        ///get the index of the vehicle which is active
        guard let i = vehicles.firstIndex(where: {$0.isActive})  else {
            return
        }
        ///if fuel engine is hybrid type and fuel mode is not set the gas type
        if vehicles[i].fuelEngine == "Hybrid" && vehicles[i].fuelMode != "Gas" {
            ///set the hybrid EV engine trip odometers
            ///if distance unit is km
            if distanceUnit == .km {
                ///trip hybrid EV in miles
                vehicles[i].tripHybridEVMiles = vehicle.tripHybridEV * 0.6214
            }
            else {
                ///trip hybrid EV in km
                vehicles[i].tripHybridEV = vehicle.tripHybridEVMiles / 0.6214
            }
        }
        ///if fuel engine is not hybrid or if hybrid but gas type
        else {
            ///if distance unit is set to km
            if distanceUnit == .km {
                ///trip in miles
                vehicles[i].tripMiles = vehicle.trip * 0.6214
            }
            else {
                ///trip in km
                vehicles[i].trip = vehicle.tripMiles / 0.6214
            }
        }
        
        ///set the active vehicle as location manager's vehicle
        locationDataManager.vehicle = vehicle
        ///set the active vehicle's odometer as location manager's odometer
        locationDataManager.odometer = vehicle.odometer
        guard let thisSettings = vehicles[i].settings else {
            return
        }
        ///set the active vehicle's trip odometer as location manager's trip odometer based on set unit
        if thisSettings.distanceUnit == "km" {
            ///trip in km
            locationDataManager.trip = vehicle.trip
            ///trip in miles
            locationDataManager.tripMiles =  locationDataManager.trip * 0.6214
        }
        else {
            ///trip in miles
            locationDataManager.tripMiles = vehicle.tripMiles
            ///trip in km
            locationDataManager.trip = locationDataManager.tripMiles / 0.6214
        }
        ///save the changes to the entities of the viewcontext to the parent store.
        Vehicle.saveContext(viewContext: viewContext)
                        
    }
}

#Preview {
    SettingsView(locationDataManager: LocationDataManager())
}
