//
//  AddVehicleForm.swift
//  Map
//
//  Created by saj panchal on 2024-07-02.
//

import SwiftUI

struct AddVehicleForm: View {
    @Environment(\.managedObjectContext) private var viewContext
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
    var greenColor = Color(red: 0.257, green: 0.756, blue: 0.346)
    var lightGreenColor = Color(red: 0.723, green: 1.0, blue: 0.856)
    @State var vehicle: AutoVehicle?
   
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
                            print(model)
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
                    .onChange(of: model) {
                        // model = vehicleMake.models[index].rawValue
                        print(model)
                        for j in vehicleMake.models {
                            print(index," = ", j )
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
                    .onChange(of:year) {
                        print(index)
                        print(year)
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
                VStack {
                    Button {
                       
                       addVehicle()
                      
                   
                    } label: {
                        HStack {
                            Spacer()
                            Image(systemName: "car.fill")
                                .foregroundStyle(lightGreenColor)
                                .font(Font.system(size: 25))
                            
                            Text("Add Vehicle")
                              
                                .foregroundStyle(lightGreenColor)
                            Spacer()
                        }
                        .frame(height: 40, alignment: .center)
                    }
                    .background(greenColor)
                    .buttonStyle(BorderlessButtonStyle())
                    .cornerRadius(100)
                }
                .listRowBackground(Color.clear)
                .listRowInsets(EdgeInsets())
            }
            .navigationTitle("Add New Vehicle")
        }
    }
    func addVehicle() {
        let vehicle = Vehicle(context: viewContext)
        vehicle.uniqueID = UUID()
        vehicle.fuelEngine = fuelType.rawValue
        vehicle.make = vehicleMake.rawValue.replacingOccurrences(of: "_", with: " ")
        vehicle.model = model.rawValue.replacingOccurrences(of: "_", with: " ")
        vehicle.type = vehicleType.rawValue
        vehicle.isActive = false
        vehicle.year = Int16(year)
        vehicle.odometer = Double(odometer) ?? 0
        vehicle.trip = Double(trip) ?? 0
     
        Vehicle.saveContext(viewContext: viewContext)
    }
}

#Preview {
    AddVehicleForm()
}
