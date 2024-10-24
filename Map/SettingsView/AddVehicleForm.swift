//
//  AddVehicleForm.swift
//  Map
//
//  Created by saj panchal on 2024-07-02.
//

import SwiftUI

struct AddVehicleForm: View {
    ///view context is the object of core data persistance container that tracks changes made to core data model data.
    @Environment(\.managedObjectContext) private var viewContext
    ///fetchrequest will request the records of vehicle entity and stores it in array form as a result. Here, it has the sort descriptors  with one element that asks to sort an array with vehicles active comes last in order.
    @FetchRequest(entity:Vehicle.entity(), sortDescriptors:[NSSortDescriptor(keyPath: \Vehicle.isActive, ascending: false)]) var vehicles: FetchedResults<Vehicle>
    @FetchRequest(entity: Settings.entity(), sortDescriptors:[]) var settings: FetchedResults<Settings>
    ///state variable stores vehicletype enum
    @State var vehicleType: VehicleTypes = .Car
    ///state variable stores vehiclemake enum
    @State var vehicleMake: VehicleMake = .AC
    ///state variable stores vehicle make in string format
    @State var textVehicleMake = ""
    ///state variable stores vehicle model in string format
    @State var textVehicleModel = ""
    ///state variable stores alphabet enum type.
    @State var alphabet: Alphbets = .A
    ///state variable stores model enum type.
    @State var model: Model = .Ace
    ///state variable stores vehicle manufacturing year as Int type
    @State var year = (Calendar.current.dateComponents([.year], from: Date())).year ?? 1900
    ///state variable stores vehicle year range as Range type
    @State var yearRange = 1900..<((Calendar.current.dateComponents([.year], from: Date())).year ?? 1900) + 1
    ///state variable stores engineType enum value
    @State var engineType = EngineType.Gas
    ///state variable stores the battery capacity
    @State var batteryCapacity = "40.0"
    ///state variable to store odometer value (km) in string format for textfield to display/update.
    @State var odometer = "0"
    ///state variable to store odometer value (miles) in string format for textfield to display/update.
    @State var odometerMiles = "0"
    ///state variable to store trip odometer (km) value in string format for textfield to display/update.
    @State var trip = "0.0"
    ///state variable to store trip odometer (miles) value in string format for textfield to display/update.
    @State var tripMiles = "0.0"
    ///state variable to store trip odometer for hybrid EV engine (km)  value in string format for textfield to display/update.
    @State var tripHybridEV = "0.0"
    ///state variable to store trip odometer for hybrid EV engine (miles) value in string format for textfield to display/update.
    @State var tripHybridEVMiles = "0.0"
    ///binding variable that updates this view on change of vehicle data type values.
    @Binding var vehicle: Vehicle
    ///binding variable that shows/hides  this view on change of bool value.
    @Binding var showAddVehicleForm: Bool
    ///state object that controls location manager tasks.
    @StateObject var locationDataManager: LocationDataManager
       
    var body: some View {
        NavigationStack {
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
                        TextField("Enter battery capacity in kwh", text: $batteryCapacity)
                            .keyboardType(.decimalPad)
                    }
                }
                if settings.first!.distanceUnit == "km" {
                    ///textfield to enter/update vehicle odometer readings
                    Section("Vehicle Odometer (in Km)") {
                        TextField("Enter the odometer readings", text: $odometer)
                            .onChange(of: odometer) {
                                if let odometerDouble = Double(odometer) {
                                    odometerMiles = String(odometerDouble * 0.62)
                                }
                            }
                            .keyboardType(.numberPad)
                    }
                }
                else {
                    ///textfield for setting vehicle odometer readings
                    Section("Vehicle Odometer (in Miles)") {
                        TextField("Enter the odometer readings", text: $odometerMiles)
                            .onChange(of: odometerMiles) {
                                if let odometerMilesDouble = Double(odometerMiles) {
                                    odometer = String(odometerMilesDouble / 0.62)
                                }
                            }
                            .keyboardType(.numberPad)
                    }
                }
                
                ///textfield for setting vehicle trip odometer readings
                if engineType != .Hybrid {
                    if settings.first!.distanceUnit == "km" {
                        Section("Vehicle Trip (in Km)") {
                            TextField("Enter the Trip readings", text: $trip)
                          
                                .onChange(of: trip) {
                                    if let tripDouble = Double(trip) {
                                        tripMiles = String(tripDouble * 0.62)
                                    }
                                }
                                .keyboardType(.decimalPad)
                        }
                    }
                    else {
                        Section("Vehicle Trip (in Miles") {
                            TextField("Enter the Trip readings", text: $tripMiles)
                                .onChange(of: tripMiles) {
                                    if let tripMilesDouble = Double(tripMiles) {
                                        trip = String(tripMilesDouble / 0.62)
                                    }
                                }
                                .keyboardType(.decimalPad)
                        }
                    }
                }
                else {
                    if settings.first!.distanceUnit == "km" {
                        Section("Vehicle Trip for Gas Engine (in Km)") {
                            TextField("Enter the Trip readings", text: $trip)
                                .onChange(of: trip) {
                                    if let tripDouble = Double(trip) {
                                        tripMiles = String(tripDouble * 0.62)
                                    }
                                }
                                .keyboardType(.decimalPad)
                        }
                    }
                    else {
                        Section("Vehicle Trip for Gas Engine (in Miles)") {
                            TextField("Enter the Trip readings", text: $tripMiles)
                                .onChange(of: tripMiles) {
                                    if let tripMilesDouble = Double(tripMiles) {
                                        trip = String(tripMilesDouble / 0.62)
                                    }
                                   
                                }
                                .keyboardType(.decimalPad)
                        }
                    }
                    if settings.first!.distanceUnit == "km" {
                        Section("Vehicle Trip for EV Engine (in Km)") {
                            TextField("Enter the Trip readings", text: $tripHybridEV)
                                .onChange(of: tripHybridEV) {
                                    if let tripDouble = Double(tripHybridEV) {
                                        tripHybridEVMiles = String(tripDouble * 0.62)
                                    }
                                }
                                .keyboardType(.decimalPad)
                        }
                    }
                    else {
                        Section("Vehicle Trip for EV Engine (in Miles)") {
                            TextField("Enter the Trip readings", text: $tripHybridEVMiles)
                                .onChange(of: tripHybridEVMiles) {
                                    if let tripMilesDouble = Double(tripHybridEVMiles) {
                                        tripHybridEV = String(tripMilesDouble / 0.62)
                                    }
                                }
                                .keyboardType(.decimalPad)
                        }
                    }
                }
                ///form submit button
                VStack {
                    Button {
                        ///on tap of the button call function to add a new vehicle.
                       addVehicle()
                    } label: {
                        ///appearnce of the button
                        FormButton(imageName: "car.fill", text: "Add Vehicle", color: Color(AppColors.green.rawValue))
                    }
                    .background(Color(AppColors.invertGreen.rawValue))
                    .buttonStyle(BorderlessButtonStyle())
                    .cornerRadius(100)
                }
                .listRowBackground(Color.clear)
                .listRowInsets(EdgeInsets())
            }
            ///on appear of this form
            .onAppear {
                ///update textfield with the initial vehicle make
                textVehicleMake = vehicleMake.rawValue.replacingOccurrences(of: "_", with: " ")
                ///update textfield with the initial vehicle model
                textVehicleModel = model.rawValue.replacingOccurrences(of: "_", with: " ")
            }
            .navigationTitle("Add New Vehicle")
        }
    }
    func addVehicle() {
        ///create an instance of Vehicle entity
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
        if engineType != .Gas {
            newVehicle.batteryCapacity = Double(batteryCapacity) ?? 40
        }
      
        ///set vehicle as not active
        newVehicle.isActive = false
        ///set vehicle year
        newVehicle.year = Int16(year)
        ///set vehicle odometer
        newVehicle.odometer = Double(odometer) ?? 0.0
        ///set vehicle odometer
        newVehicle.odometerMiles = Double(odometerMiles) ?? 0.0
        ///set vehicle trip odometer
        if settings.first!.distanceUnit == "km" {
            newVehicle.trip = Double(trip) ?? 0.0
            newVehicle.tripMiles =   newVehicle.trip * 0.62
        }
        else {
            newVehicle.tripMiles = Double(tripMiles) ?? 0.0
            newVehicle.trip = newVehicle.tripMiles / 0.62
        }
      
        if engineType == .Hybrid {
            if settings.first!.distanceUnit == "km" {
                ///set vehicle trip odometer
                newVehicle.tripHybridEV = Double(tripHybridEV) ?? 0.0
                newVehicle.tripHybridEVMiles = newVehicle.tripHybridEV * 0.62
            }
            else {
                ///set vehicle trip odometer
                newVehicle.tripHybridEVMiles = Double(tripHybridEVMiles) ?? 0.0
                newVehicle.tripHybridEV = newVehicle.tripHybridEVMiles / 0.62
            }
           
        }
        
        ///continue if any active vehicle is found
        guard let activeVehicle = vehicles.first(where: {$0.isActive}) else {
            return
        }
        ///set the state variable as active vehicle
        vehicle = activeVehicle
        ///append the fetched result with a new vehicle.
        locationDataManager.results.append(newVehicle)
        ///save the context after new vehicle is set.
        Vehicle.saveContext(viewContext: viewContext)
        ///hide the vehicle form
        showAddVehicleForm = false
    }
}

#Preview {
    AddVehicleForm(vehicle: .constant(Vehicle()), showAddVehicleForm: .constant(false), locationDataManager: LocationDataManager())
}
