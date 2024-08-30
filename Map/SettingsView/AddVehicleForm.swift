//
//  AddVehicleForm.swift
//  Map
//
//  Created by saj panchal on 2024-07-02.
//

import SwiftUI

struct AddVehicleForm: View {
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(entity:Vehicle.entity(), sortDescriptors:[NSSortDescriptor(keyPath: \Vehicle.isActive, ascending: false)]) var vehicles: FetchedResults<Vehicle>
    @State var vehicleType: VehicleTypes = .Car
    @State var vehicleMake: VehicleMake = .AC
    @State var textVehicleMake = ""
    @State var textVehicleModel = ""
    @State var alphabet: Alphbets = .A
    @State var model: Model = .Ace
    @State var year = (Calendar.current.dateComponents([.year], from: Date())).year!
    @State var index = 0
    @State var range = 1900..<(Calendar.current.dateComponents([.year], from: Date())).year! + 1
    @State var fuelType = FuelTypes.Gas
    @State var odometer = "0"
    @State var trip = "0.0"
    @Binding var vehicle: Vehicle
    @Binding var showAddVehicleForm: Bool
    @StateObject var locationDataManager: LocationDataManager
    
       
    var body: some View {
        NavigationStack {
            Form {
                Section("Vehicle Type") {
                    Picker("Select Type", selection: $vehicleType) {
                        ForEach(VehicleTypes.allCases) { thisVehicleType in
                            Text(thisVehicleType.rawValue)
                        }
                    }
                }
                Section("Vehicle Make") {
                    TextField("Enter/Select your vehicle make", text: $textVehicleMake)
                }
                Section("") {
                    HStack {
                        Picker("Select Make", selection: $alphabet) {
                            ForEach(Alphbets.allCases) { thisAlphabet in
                                Text(thisAlphabet.rawValue)
                            }
                        }
                        .frame(width: 40)
                        .onChange(of:$alphabet.id) {
                            model = alphabet.makes.first!.models.first!
                            vehicleMake = alphabet.makes.first!
                            textVehicleMake = vehicleMake.rawValue.replacingOccurrences(of: "_", with: " ")
                        }
                        .pickerStyle(.wheel)
                        Picker("", selection:$vehicleMake) {
                            ForEach(alphabet.makes) { make in
                                Text(make.rawValue.replacingOccurrences(of: "_", with: " "))
                            }
                        }
                        .onChange(of: $vehicleMake.id) {
                            textVehicleMake = vehicleMake.rawValue.replacingOccurrences(of: "_", with: " ")
                            textVehicleModel = vehicleMake.models.first!.rawValue.replacingOccurrences(of: "_", with: " ")
                        }
                        .pickerStyle(.wheel)
                    }
                }
                Section("Vehicle Model") {
                    TextField("Enter/Select your vehicle model", text: $textVehicleModel)
                }
                Section("") {
                    Picker("Select Model", selection: $model) {
                        ForEach(vehicleMake.models, id: \.id) {thisModel in
                            Text(thisModel.rawValue.replacingOccurrences(of: "_", with: " "))
                        }
                    }
                    .onChange(of: model.id) {
                        textVehicleModel = model.rawValue.replacingOccurrences(of: "_", with: " ")
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
                        ForEach(FuelTypes.allCases) { thisFuelType in
                            Text(thisFuelType.rawValue.replacingOccurrences(of: "_", with: " "))
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
                VStack {
                    Button {
                       addVehicle()
                    } label: {
                        FormButton(imageName: "car.fill", text: "Add Vehicle", color: Color(AppColors.green.rawValue))
                    }
                    .background(Color(AppColors.invertGreen.rawValue))
                    .buttonStyle(BorderlessButtonStyle())
                    .cornerRadius(100)
                }
                .listRowBackground(Color.clear)
                .listRowInsets(EdgeInsets())
            }
            .onAppear {
                textVehicleMake = vehicleMake.rawValue.replacingOccurrences(of: "_", with: " ")
                textVehicleModel = model.rawValue.replacingOccurrences(of: "_", with: " ")
            }
            .navigationTitle("Add New Vehicle")
        }
    }
    func addVehicle() {
        let newVehicle = Vehicle(context: viewContext)
        newVehicle.uniqueID = UUID()
        newVehicle.fuelEngine = fuelType.rawValue
        newVehicle.make = textVehicleMake
        newVehicle.model = textVehicleModel
        newVehicle.type = vehicleType.rawValue
        newVehicle.isActive = false
        newVehicle.year = Int16(year)
        newVehicle.odometer = Double(odometer) ?? 0
        newVehicle.trip = Double(trip) ?? 0
        
        showAddVehicleForm = false
        vehicle = vehicles.first(where: {$0.isActive}) ?? Vehicle()
        locationDataManager.results.append(vehicle)
        Vehicle.saveContext(viewContext: viewContext)
    }
}

#Preview {
    AddVehicleForm(vehicle: .constant(Vehicle()), showAddVehicleForm: .constant(false), locationDataManager: LocationDataManager())
}
