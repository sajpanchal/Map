//
//  AddVehicleForm.swift
//  Map
//
//  Created by saj panchal on 2024-07-02.
//

import SwiftUI

struct AddVehicleForm: View {
    @Environment(\.colorScheme) var bgMode: ColorScheme
    ///view context is the object of core data persistance container that tracks changes made to core data model data.
    @Environment(\.managedObjectContext) private var viewContext
    ///fetchrequest will request the records of vehicle entity and stores it in array form as a result. Here, it has the sort descriptors  with one element that asks to sort an array with vehicles active comes last in order.
    @FetchRequest(entity:Vehicle.entity(), sortDescriptors:[NSSortDescriptor(keyPath: \Vehicle.isActive, ascending: false)]) var vehicles: FetchedResults<Vehicle>
    @FetchRequest(entity: Settings.entity(), sortDescriptors:[]) var settings: FetchedResults<Settings>
    ///state variable stores vehicletype enum
    @State private var vehicleType: VehicleTypes = .Car
    ///state variable stores vehiclemake enum
    @State private var vehicleMake: VehicleMake = .AC
    ///state variable stores vehicle make in string format
    @State private var textVehicleMake = ""
    ///state variable stores vehicle model in string format
    @State private var textVehicleModel = ""
    ///state variable stores alphabet enum type.
    @State private var alphabet: Alphbets = .A
    ///state variable stores model enum type.
    @State private var model: Model = .Ace
    ///state variable stores vehicle manufacturing year as Int type
    @State private var year = (Calendar.current.dateComponents([.year], from: Date())).year ?? 1900
    ///state variable stores vehicle year range as Range type
    @State private var yearRange = 1900..<((Calendar.current.dateComponents([.year], from: Date())).year ?? 1900) + 1
    ///state variable stores engineType enum value
    @State private var engineType = EngineType.Gas
    ///state variable stores the battery capacity
    @State private var batteryCapacity = 40.0
    ///state variable to store odometer value (km) in string format for textfield to display/update.
    @State private var odometer = 0
    ///state variable to store odometer value (miles) in string format for textfield to display/update.
    @State private var odometerMiles = 0
    ///state variable to store trip odometer (km) value in string format for textfield to display/update.
    @State private var trip = 0.0
    ///state variable to store trip odometer (miles) value in string format for textfield to display/update.
    @State private var tripMiles = 0.0
    ///state variable to store trip odometer for hybrid EV engine (km)  value in string format for textfield to display/update.
    @State private var tripHybridEV = 0.0
    ///state variable to store trip odometer for hybrid EV engine (miles) value in string format for textfield to display/update.
    @State private var tripHybridEVMiles = 0.0
    ///binding variable that updates this view on change of vehicle data type values.
    @Binding var vehicle: Vehicle
    ///binding variable that shows/hides  this view on change of bool value.
    @Binding var showAddVehicleForm: Bool
    ///state object that controls location manager tasks.
    @StateObject var locationDataManager: LocationDataManager
       @State private var showAlert = false
    var body: some View {
        NavigationStack {
            ZStack {
                VStack {
                    ///form to add a new vehicle.
                    Form {
                        ///picker to select vehicle type
                        Section("Vehicle Type") {
                            Picker("Select Type", selection: $vehicleType) {
                                ForEach(VehicleTypes.allCases) { thisVehicleType in
                                    Text(thisVehicleType.rawValue)
                                }
                            }
                        }
                        ///textfield to enter vehicle make
                        Section("Vehicle Make") {
                            TextField("Enter/Select your vehicle make", text: $textVehicleMake)
                        }
                        if textVehicleMake.isEmpty {
                            Text("vehicle make can not be empty!")
                                .font(.caption2)
                                .foregroundStyle(.red)
                        }
                        ///picker to select vehicle make from the list.
                        Section("") {
                            HStack {
                                Picker("Select Make", selection: $alphabet) {
                                    ForEach(Alphbets.allCases) { thisAlphabet in
                                        Text(thisAlphabet.rawValue)
                                    }
                                }
                                .frame(width: 40)
                                ///on change of alphabet ID.
                                .onChange(of:alphabet.id) {
                                    ///check if the given alphabet has the first make.
                                    guard let thisVehicleMake = alphabet.makes.first else {
                                        return
                                    }
                                    ///check if the given make has the first model.
                                    guard let thisVehicleModel = thisVehicleMake.models.first else {
                                        return
                                    }
                                    ///update the model value with the given aphabet's first make's first model
                                    model = thisVehicleModel
                                    ///update the vehicle make with the given model's first make
                                    vehicleMake = thisVehicleMake
                                    ///update the textfield of vehicle make with the formated text.
                                    textVehicleMake = vehicleMake.rawValue.replacingOccurrences(of: "_", with: " ")
                                }
                                .pickerStyle(.wheel)
                                ///picker for vehicle make
                                Picker("", selection:$vehicleMake) {
                                    ForEach(alphabet.makes) { thisVehicleMake in
                                        Text(thisVehicleMake.rawValue.replacingOccurrences(of: "_", with: " "))
                                    }
                                }
                                ///on change of vehicle make ID
                                .onChange(of: vehicleMake.id) {
                                    ///update the vehicle make text with formated vehicle make string
                                    textVehicleMake = vehicleMake.rawValue.replacingOccurrences(of: "_", with: " ")
                                    ///check if the first model of vehicle make is available
                                    guard let thisVehicleModel = vehicleMake.models.first else {
                                        return
                                    }
                                    ///store the formated model text to textfield
                                    textVehicleModel = thisVehicleModel.rawValue.replacingOccurrences(of: "_", with: " ")
                                }
                                .pickerStyle(.wheel)
                            }
                        }
                        ///textfeid to store desired or selected vehicle model.
                        Section("Vehicle Model") {
                            TextField("Enter/Select your vehicle model", text: $textVehicleModel)
                        }
                        if textVehicleModel.isEmpty {
                            Text("vehicle model can not be empty!")
                                .font(.caption2)
                                .foregroundStyle(.red)
                        }
                        ///picler for vehicle model selection
                        Section("") {
                            Picker("Select Model", selection: $model) {
                                ForEach(vehicleMake.models, id: \.id) {thisModel in
                                    Text(thisModel.rawValue.replacingOccurrences(of: "_", with: " "))
                                }
                            }
                            ///on change of vehicle model ID.
                            .onChange(of: model.id) {
                                ///update the textfield with given model formated text.
                                textVehicleModel = model.rawValue.replacingOccurrences(of: "_", with: " ")
                            }
                            .pickerStyle(.wheel)
                        }
                        ///picker for vehicle manufacturing year.
                        Section("Manufacuring Year") {
                            Picker("Select Year", selection: $year) {
                                ForEach(yearRange.reversed(), id: \.self) { i in
                                    Text(String(i))
                                }
                            }
                            .pickerStyle(.wheel)
                        }
                        ///picker for vehicle fuel engine type
                        Section("Fuel Engine Type") {
                            Picker("Select Type", selection:$engineType) {
                                ForEach(EngineType.allCases) { thisFuelType in
                                    Text(thisFuelType.rawValue.replacingOccurrences(of: "_", with: " "))
                                }
                            }
                            .pickerStyle(.segmented)
                        }
                        ///if engine type is not gas engine
                        if engineType != .Gas {
                            Section(header: Text("EV Battery Capacity in KWh").fontWeight(.bold)) {
                                TextField("Enter battery capacity in kwh", value: $batteryCapacity, format: .number)
                                    .keyboardType(.decimalPad)
                            }
                        }
                        if settings.first!.distanceUnit == "km" {
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
                        
                        ///textfield for setting vehicle trip odometer readings
                        if engineType != .Hybrid {
                            if settings.first!.distanceUnit == "km" {
                                Section("Vehicle Trip (in Km)") {
                                    TextField("Enter the Trip readings", value: $trip, format: .number)
                                        .onChange(of: trip) {
                                            let tripDouble = Double(trip)
                                            tripMiles = tripDouble * 0.6214
                                        }
                                        .keyboardType(.decimalPad)
                                }
                            }
                            else {
                                Section("Vehicle Trip (in Miles)") {
                                    TextField("Enter the Trip readings", value: $tripMiles, format: .number)
                                        .onChange(of: tripMiles) {
                                            let tripMilesDouble = Double(tripMiles)
                                            trip = tripMilesDouble / 0.6214
                                        }
                                        .keyboardType(.decimalPad)
                                }
                            }
                        }
                        else {
                            if settings.first!.distanceUnit == "km" {
                                Section("Vehicle Trip for Gas Engine (in Km)") {
                                    TextField("Enter the Trip readings", value: $trip, format: .number)
                                        .onChange(of: trip) {
                                            let tripDouble = Double(trip)
                                            tripMiles = tripDouble * 0.6214
                                        }
                                        .keyboardType(.decimalPad)
                                }
                            }
                            else {
                                Section("Vehicle Trip for Gas Engine (in Miles)") {
                                    TextField("Enter the Trip readings", value: $tripMiles, format: .number)
                                        .onChange(of: tripMiles) {
                                            let tripMilesDouble = Double(tripMiles)
                                            trip = tripMilesDouble / 0.6214
                                        }
                                        .keyboardType(.decimalPad)
                                }
                            }
                            if settings.first!.distanceUnit == "km" {
                                Section("Vehicle Trip for EV Engine (in Km)") {
                                    TextField("Enter the Trip readings", value: $tripHybridEV, format: .number)
                                        .onChange(of: tripHybridEV) {
                                            let tripDouble = Double(tripHybridEV)
                                            tripHybridEVMiles = tripDouble * 0.6214
                                        }
                                        .keyboardType(.decimalPad)
                                }
                            }
                            else {
                                Section("Vehicle Trip for EV Engine (in Miles)") {
                                    TextField("Enter the Trip readings", value: $tripHybridEVMiles, format: .number)
                                        .onChange(of: tripHybridEVMiles) {
                                            let tripMilesDouble = Double(tripHybridEVMiles)
                                            tripHybridEV = tripMilesDouble / 0.6214
                                        }
                                        .keyboardType(.decimalPad)
                                }
                            }
                        }
                        ///form submit button
                        VStack {
                            HStack {
                                Spacer()
                                Button {
                                    if !textVehicleMake.isEmpty && !textVehicleModel.isEmpty {
                                        ///on tap of the button call function to add a new vehicle.
                                       addVehicle()
                                    }
                                   
                                } label: {
                                    ///appearnce of the button
                                    FormButton(imageName: "car.fill", text: "Add Vehicle", color: Color(AppColors.green.rawValue))
                                }
                                .background(Color(AppColors.invertGreen.rawValue))
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
                    AlertView(image: "car.circle.fill", headline: "Vehicle Added!", bgcolor: Color(AppColors.invertGreen.rawValue), showAlert: $showAlert)
                }
            }
            
          
            ///on appear of this form
            .onAppear {
                ///update textfield with the initial vehicle make
                textVehicleMake = vehicleMake.rawValue.replacingOccurrences(of: "_", with: " ")
                ///update textfield with the initial vehicle model
                textVehicleModel = model.rawValue.replacingOccurrences(of: "_", with: " ")
            }
            .navigationTitle("Add New Vehicle")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    func addVehicle() {
        ///create an instance of Vehicle entity
        let autoSummary = AutoSummary(context: viewContext)
        ///get the current calendarYear from the Calendar object and set its value.
        let calendarYear = Calendar.current.component(.year, from: Date())
        ///set the calendar year of the autoSummary object.
        autoSummary.calenderYear = Int16(calendarYear)
        ///create a new vehicle from coredata context
        let newVehicle = Vehicle(context: viewContext)
        ///set new UUID
        newVehicle.uniqueID = UUID()
        ///set vehicle fuel type
        newVehicle.fuelEngine = engineType.rawValue
        ///set vehicle make
        newVehicle.make = textVehicleMake
        ///set vehicle model
        newVehicle.model = textVehicleModel
        ///set vehicle type
        newVehicle.type = vehicleType.rawValue
        ///if vehicle engine is other than Gas type
        if engineType != .Gas {
            ///set the batteryCapacity prop of the vehicle object.
            newVehicle.batteryCapacity = batteryCapacity
        }
        ///set vehicle as not active
        newVehicle.isActive = false
        ///set vehicle year
        newVehicle.year = Int16(year)
        ///set vehicle odometer
        newVehicle.odometer = Double(odometer)
        ///set vehicle odometer as odometer start of autoSummary
        autoSummary.odometerStart = Double(odometer)
        ///set vehicle odometer
        newVehicle.odometerMiles = Double(odometerMiles)
        ///set vehicle odometer as odometer start of autoSummary in miles
        autoSummary.odometerStartMiles = Double(odometerMiles)
        ///set vehicle trip odometer in km mode
        if settings.first!.distanceUnit == "km" {
            ///set new vehicle's trip odometer as trip inputed
            newVehicle.trip = trip
            ///set autoSummary annualtrip as trip inputted
            autoSummary.annualTrip = trip
            ///set new vehicle's trip odometer converted in miles
            newVehicle.tripMiles = newVehicle.trip * 0.6214
            ///set autoSummary annualtrip converted in miles
            autoSummary.annualTripMiles = newVehicle.trip * 0.6214
        }
        ///set vehicle trip odometer in mi mode
        else {
            ///set new vehicle's trip odometer as trip inputed
            newVehicle.tripMiles = tripMiles
            ///set autoSummary annualtrip as trip inputted
            autoSummary.annualTripMiles = tripMiles
            ///set new vehicle's trip odometer converted in km
            newVehicle.trip = newVehicle.tripMiles / 0.6214
            ///set autoSummary annualtrip converted in km
            autoSummary.annualTrip = newVehicle.tripMiles / 0.6214
        }
        ///if engine type is hybrid set EV props
        if engineType == .Hybrid {
            if settings.first!.distanceUnit == "km" {
                //set vehicle trip odometer
                newVehicle.tripHybridEV = tripHybridEV
                autoSummary.annualTripEV = tripHybridEV
                newVehicle.tripHybridEVMiles = newVehicle.tripHybridEV * 0.6214
                autoSummary.annualTripEVMiles =  newVehicle.tripHybridEV * 0.6214
            }
            else {
                ///set vehicle trip odometer
                newVehicle.tripHybridEVMiles = tripHybridEVMiles
                autoSummary.annualTripEVMiles =  newVehicle.tripHybridEVMiles
                newVehicle.tripHybridEV = newVehicle.tripHybridEVMiles / 0.6214
                autoSummary.annualTripEV = newVehicle.tripHybridEVMiles / 0.6214
            }
           
        }
        ///add new report to the newVehicle.
        newVehicle.addToReports(autoSummary)
        ///continue if any active vehicle is found
        guard let activeVehicle = vehicles.first(where: {$0.isActive}) else {
            return
        }
        ///set the state variable as active vehicle
        vehicle = activeVehicle
        ///append the fetched result with a new vehicle.
        locationDataManager.results.append(newVehicle)
        withAnimation(.easeIn(duration: 0.5)) {
            showAlert = true
        }
      
        ///save the context after new vehicle is set.
        Vehicle.saveContext(viewContext: viewContext)
        ///hide the vehicle form
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            showAddVehicleForm = false
        }
    }
}

#Preview {
    AddVehicleForm(vehicle: .constant(Vehicle()), showAddVehicleForm: .constant(false), locationDataManager: LocationDataManager())
}
