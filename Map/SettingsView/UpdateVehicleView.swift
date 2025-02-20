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
    @FetchRequest(entity: Vehicle.entity(), sortDescriptors: []) var vehicles: FetchedResults<Vehicle>
    @FetchRequest(entity:Settings.entity(), sortDescriptors:[]) var settingsEntity: FetchedResults<Settings>
    @FetchRequest(entity: AutoSummary.entity(), sortDescriptors: []) var reports: FetchedResults<AutoSummary>
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
    ///state variable stores vehicle make in string format
    @State private var textVehicleMake = ""
    ///state variable stores vehicle model in string format
    @State private var textVehicleModel = ""
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
                        ///textfield to enter vehicle make
                        Section("Vehicle Make") {
                            TextField("Enter/Select your vehicle make", text: $textVehicleMake)
                            if textVehicleMake.isEmpty {
                                Text("vehicle make can not be empty!")
                                    .font(.caption2)
                                    .foregroundStyle(.red)
                            }
                        }
                        
                        ///picker to select vehicle make alphabetically
                        Section("") {
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
                                    ///update the textfield with the selected vehicle make from the picker in string format.
                                    textVehicleMake = thisMake.rawValue.replacingOccurrences(of: "_", with: " ")
                                    
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
                                    print("on change of make")
                                    vehicleModel = vehicleMake.models.first ?? .Other
                                    ///update the vehicle make text with formated vehicle make string
                                    textVehicleMake = vehicleMake.rawValue.replacingOccurrences(of: "_", with: " ")
                                    ///update the vehicle model text with formated vehicle model string
                                    textVehicleModel = vehicleModel.rawValue.replacingOccurrences(of: "_", with: " ")
                                }
                                .pickerStyle(.wheel)
                            }
                        }
                        ///textfeid to store desired or selected vehicle model.
                        Section("Vehicle Model") {
                            TextField("Enter/Select your vehicle model", text: $textVehicleModel)
                            if textVehicleModel.isEmpty {
                                Text("vehicle model can not be empty!")
                                    .font(.caption2)
                                    .foregroundStyle(.red)
                            }
                        }
                       
                        ///picker to select vehicle model
                        Section("") {
                            Picker("Select model", selection: $vehicleModel) {
                                ForEach(vehicleMake.models, id: \.id) { vehicleModel in
                                    Text(vehicleModel.rawValue.replacingOccurrences(of: "_", with: " "))
                                }
                            }
                            ///on change of vehicle model ID.
                            .onChange(of: vehicleModel.id) {
                                print("on change of model")
                                ///update the textfield with given model formated text.
                                textVehicleModel = vehicleModel.rawValue.replacingOccurrences(of: "_", with: " ")
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
                                    ///if settings have fuel unit set to %
                                    if settings.getFuelVolumeUnit == "%" {
                                        ///update the fuel unit to litre
                                        fuelUnit = .Litre
                                    }
                                    ///if fuel unit is up to date in the settings
                                    else {
                                        ///get the settings fuel unit
                                        fuelUnit =  FuelUnit(rawValue: settings.getFuelVolumeUnit) ?? .Litre
                                    }
                                  
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
                                        Text(thisFuelType.rawValue)
                                    }
                                }
                                .onAppear(perform: {
                                    fuelMode = FuelMode(rawValue:vehicle.getFuelMode) ?? .Gas
                                })
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
                                        ///on appear of this picker set the efficiency unit index to 0 if previous index is multiple of 2 or 1.
                                        .onAppear(perform: {
                                            efficiencyUnitIndex = efficiencyUnitIndex.isMultiple(of: 2) ? 0 : 1
                                        })
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
                                        ///on appear of this picker set the efficiency unit index to 0 if previous index is multiple of 2 or 1.
                                        .onAppear(perform: {
                                            efficiencyUnitIndex = efficiencyUnitIndex.isMultiple(of: 2) ? 2 : 3
                                        })
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
                                        ///on appear of this picker set the efficiency unit index to 0 if previous index is multiple of 2 or 1.
                                        .onAppear(perform: {
                                            efficiencyUnitIndex = efficiencyUnitIndex.isMultiple(of: 2) ? 4 : 5
                                        })
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
                                        ///on appear of this picker set the efficiency unit index to 0 if previous index is multiple of 2 or 1.
                                        .onAppear(perform: {
                                            efficiencyUnitIndex = efficiencyUnitIndex.isMultiple(of: 2) ? 6 : 7
                                        })
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
                                ///on appear of this picker set the efficiency unit index to 0 if previous index is multiple of 2 or 1.
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
                                ///on appear of this picker set the efficiency unit index to 0 if previous index is multiple of 2 or 1.
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
                                    if !textVehicleMake.isEmpty && !textVehicleModel.isEmpty {
                                        guard let index = vehicles.firstIndex(of: vehicle) else {
                                            return
                                        }
                                        Vehicle.updateVehicle(viewContext: viewContext, vehicleIndex: index) {
                                            VehicleModel(vehicleType: vehicleType.rawValue, vehicleMake: vehicleMake.rawValue, model: vehicleModel.rawValue, year: manufacturingYear, engineType: engineType.rawValue, batteryCapacity: batteryCapacity, odometer: Double(odometer), odometerMiles: Double(odometerMiles), trip: trip, tripMiles: tripMiles, tripHybridEV: tripHybridEV, tripHybridEVMiles: tripHybridEVMiles, fuelMode: fuelMode.rawValue)
                                        }
                                        Settings.updateSettings(viewContext: viewContext, for: vehicles[index]) {
                                            SettingsModel(autoEngineType: engineType.rawValue, distanceUnit: distanceUnit.rawValue, fuelEfficiencyUnit: efficiencyUnits[efficiencyUnitIndex], fuelVolumeUnit: fuelUnit.rawValue, avoidHighways: false , avoidTolls: false)
                                        }
                                        let calendarYear = Calendar.current.component(.year, from: Date())
                                        guard let reportIndex = reports.firstIndex(where: {$0.vehicle == vehicle && $0.calenderYear == Int16(calendarYear)}) else {
                                            return
                                        }
                                        print("report Index: ", reportIndex)
                                        AutoSummary.updateReport(viewContext: viewContext, for: vehicle, year: calendarYear, odometer: odometer, odometerMiles: odometerMiles)
//                                        updateVehicle(with: vehicle)
//                                         print("------------Vehicle Added--------------")
                                        print("Name: ",vehicle.getVehicleText)
                                        print("trip: ",vehicle.trip)
                                        print("trip miles: ",vehicle.tripMiles)
                                        print("fuel mode: ",vehicle.fuelMode ?? "n/a")
                                        print("trip EV: ",vehicle.tripHybridEV)
                                        print("trip EV miles: ",vehicle.tripHybridEVMiles)
                                        print("odometer: ",vehicle.odometer)
                                        print("odometer Miles: ",vehicle.odometerMiles)
                                        print("battery: ",vehicle.batteryCapacity)
                                        print("fuel engine: ",vehicle.fuelEngine ?? "n/a")
                                        print("is active: ",vehicle.isActive)
                                        print("odometer Miles: ",vehicle.year)
                                        print("------------Vehicle Settings--------------")
                                        print(vehicle.settings ?? "n/a")
                                        print("------------Vehicle Summary--------------")
                                        print("year: ", reports[reportIndex].calenderYear)
                                        print("odometer Start: ", reports[reportIndex].odometerStart)
                                        print("odometer End: ", reports[reportIndex].odometerEnd)
                                        print("odometer Start Miles: ", reports[reportIndex].odometerStartMiles)
                                        print("odometer End Miles: ", reports[reportIndex].odometerEndMiles)
                                        print("Vehicle: ", reports[reportIndex].vehicle?.getVehicleText ?? "n/a")
                                        print("annual fuel cost: ", reports[reportIndex].annualFuelCost)
                                        print("annual trip: ", reports[reportIndex].annualTrip)
                                        print("annual trip EV: ", reports[reportIndex].annualTripEV)
                                        print("annual trip EV Miles ", reports[reportIndex].annualTripEVMiles)
                                        print("annual trip Miles ", reports[reportIndex].annualTripMiles)
                                        print("kwh: ", reports[reportIndex].kwhConsumed)
                                        print("Litre: ", reports[reportIndex].litreConsumed)
                                        print("Gallons: ", reports[reportIndex].gallonsConsumed)
                                        print("Service Cost: ", reports[reportIndex].annualServiceCost)
                                        print("Service Cost EV: ", reports[reportIndex].annualServiceCostEV)
                                        print("Fuel Cost: ", reports[reportIndex].annualfuelCostEV)
                                        print("Mileage: ", reports[reportIndex].annualMileage)
                                        print("Mileage EV: ", reports[reportIndex].annualMileageEV)
                                        
                                        
//                                        saveSettings(for: vehicle)
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                            showGarage = false
                                        }
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
    
    ///method to update vehicle in the core data stack
   /* func updateVehicle(with vehicle: Vehicle) {
        
        ///get the calendar year for the reports
        let calendarYear = Calendar.current.component(.year, from: Date())
        ///get the index of the current vehicle in vehicles entity
        guard let vIndex = vehicles.firstIndex(of: vehicle) else {
            print("vehicle index not found")
            return
        }
        ///set the vehicle model to new model input
        vehicles[vIndex].model = textVehicleModel
        ///set the vehicle make to new make input
        vehicles[vIndex].make = textVehicleMake
        ///set the vehicle year to new year input
        vehicles[vIndex].year = Int16(manufacturingYear)
        ///set the vehicle odometer to new odometer input
        vehicles[vIndex].odometer = Double(odometer)
        ///set the vehicle odometer to new odometer input in miles
        vehicles[vIndex].odometerMiles = Double(odometerMiles)
       
        ///get the report corresponding to a given vehicle and having a current calendar year
        if let index = reports.firstIndex(where: {$0.vehicle == vehicle && $0.calenderYear == Int16(calendarYear)}) {
            reports[index].odometerEnd = Double(odometer)
            reports[index].odometerEndMiles = Double(odometerMiles)
            ///if the odometer start is greater than odometer end after the change in odometer of a given vehicle
            if reports[index].odometerStart > reports[index].odometerEnd {
                ///set the odometer start value to same as odometer end.
                reports[index].odometerStart = Double(odometer)
            }
            ///if the odometer start is greater than odometer end after the change in odometer of a given vehicle
            if reports[index].odometerStartMiles > reports[index].odometerEndMiles {
                ///set the odometer start value to same as odometer end.
                reports[index].odometerStartMiles = Double(odometerMiles)
            }
        }
        ///if no reports were found
        else {
            ///create a new report for a given vehicle and calendar year.
            AutoSummary.createNewReport(viewContext: viewContext, in: settings, for: vehicle, year: calendarYear)
        }
       ///if the engine type is hybrid
        if engineType == .Hybrid {
            ///update the hybrid EV trip (in km)
            vehicles[vIndex].tripHybridEV = tripHybridEV
            vehicles[vIndex].tripHybridEVMiles = tripHybridEVMiles
        }
        ///update vehicle trip (in miles) with new values
        vehicles[vIndex].tripMiles = tripMiles
        ///update vehicle trip (in km) with new values
        vehicles[vIndex].trip = trip
        ///save the engine type in vehicle object. (Gas, EV, Hybrid)
        vehicles[vIndex].fuelEngine = engineType.rawValue
        ///if engine type is not gas set the battery capacity of the EV engine
        if engineType != .Gas {
            vehicles[vIndex].batteryCapacity = batteryCapacity
        }
        ///save the vehicle type (Car, Truck, SUV)
        vehicles[vIndex].type = vehicleType.rawValue
      
        Vehicle.saveContext(viewContext: viewContext)
    }*/
    
    ///method to save vehicle settings
    /*func saveSettings(for vehicle: Vehicle) {
        guard let index = vehicles.firstIndex(of: vehicle) else {
            return
        }
        vehicles[index].settings?.distanceUnit = distanceUnit.rawValue
        vehicles[index].settings?.autoEngineType = engineType.rawValue
        vehicles[index].settings?.fuelVolumeUnit = fuelUnit.rawValue
        vehicles[index].settings?.fuelEfficiencyUnit = efficiencyUnits[efficiencyUnitIndex]
        vehicles[index].settings?.vehicle = vehicle
        Settings.saveContext(viewContext: viewContext)
        withAnimation(.easeIn(duration: 0.5)) {
            showAlert = true
        }
    }*/
    
    func fillForm() {
        ///set the vehicle type fetched from the selected vehicle
        vehicleType = VehicleTypes(rawValue: vehicle.getType) ?? .Car
        ///set the vehicle make fetched from the selected vehicle
        vehicleMake = VehicleMake(rawValue: vehicle.getMake) ?? .AC
        ///fill the vehicle make text field with a selected vehicle make
        textVehicleMake = vehicle.getMake
       ///if vehicle model is found in model enum
        if let model = Model(rawValue: vehicle.getModel) {
            ///set the vehicle model fetched from the selected vehicle
            vehicleModel = model
            ///set the vehicle model text with the selected vehicle model
            textVehicleModel = vehicle.getModel
        }
        ///if vehicle model is other than in a list of enum values.
        else {
            ///set the vehicle model text with the selected vehicle model
            textVehicleModel = vehicle.getModel
        }
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
//        print("Update vehicle form: \(vehicle.getFuelMode)")
//        print(FuelMode(rawValue: vehicle.getFuelMode))
        fuelMode = FuelMode(rawValue: vehicle.getFuelMode) ?? .Gas
//        print(fuelMode)
        efficiencyUnitIndex = efficiencyUnits.firstIndex(where: {$0 == settings.fuelEfficiencyUnit}) ?? 0
    }
}

#Preview {
    UpdateVehicleView(locationDataManager: LocationDataManager(), showGarage: .constant(false), settings: Settings(), vehicle: (Vehicle()))
}
