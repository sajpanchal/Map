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
    var settings: Settings
    @State var distanceMode: DistanceModes = .km
    @State var fuelMode: FuelModes = .Litre
    @State var efficiencyModes = ["km/L", "L/100km", "miles/L","L/100Miles", "km/gl",  "gl/100km", "miles/gl", "gl/100miles", "km/kwh", "miles/kwh"]
    @State var efficiencyMode = 0
    @State var showAddVehicleForm = false
    var vehicle: Vehicle
    var skyColor = Color(red:0.031, green:0.739, blue:0.861)
    var lightSkyColor = Color(red:0.657, green:0.961, blue: 1.0)
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


                    Section(header: Text("Fuel Type")) {
                     
                            Picker("Fuel", selection: $fuelType) {
                                ForEach(FuelTypes.allCases) { type in
                                    Text(type.rawValue.capitalized)
                                }
                            }
                            .pickerStyle(.segmented)
                }
               
                
                Section(header: Text("Distance Unit")) {
                    Picker("Select Unit", selection: $distanceMode) {
                        ForEach(DistanceModes.allCases) { unit in
                            Text(unit.rawValue.capitalized)
                        }
                    }
                    .pickerStyle(.segmented)
                }
                 
                    if fuelType == .Gas {
                        Section(header: Text("Fuel Volume Unit")) {
                            Picker("Select Unit", selection: $fuelMode) {
                                ForEach(FuelModes.allCases) { unit in
                                    Text(unit.rawValue.capitalized)
                                }
                            }
                            .pickerStyle(.segmented)
                        }
                    }
                    if fuelType == .Gas {
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
                
               
              
                VStack {
                    Button {
                       //updateActiveVehicle()
                    let settings = Settings(context: viewContext)
                        
                        vehicle.model = model.rawValue
                        vehicle.make = vehicleMake.rawValue
                        vehicle.year = Int16(year)
                        vehicle.odometer = Double(odometer) ?? 0
                        vehicle.trip = Double(trip) ?? 0
                        vehicle.fuelEngine = fuelType.rawValue
                        vehicle.type = vehicleType.rawValue
                        //vehicle.isActive = true
                         
                        settings.vehicle = vehicle
                        settings.autoEngineType = fuelType.rawValue
                        settings.distanceUnit = distanceMode.rawValue
                        settings.fuelVolumeUnit = fuelMode.rawValue
                        settings.fuelEfficiencyUnit = efficiencyModes[efficiencyMode]
                        Settings.saveContext(viewContext: viewContext)
                        Vehicle.saveContext(viewContext: viewContext)
                        
                    } label: {
                        HStack {
                            Spacer()
                            Image(systemName: "gear.fill")
                                .foregroundStyle(lightSkyColor)
                                .font(Font.system(size: 25))
                            
                            Text("Save Settings")
                                .fontWeight(.black)
                            
                                .foregroundStyle(lightSkyColor)
                            Spacer()
                        }
                        .frame(height: 40, alignment: .center)
                    }
                    .background(skyColor)
                    .buttonStyle(BorderlessButtonStyle())
                    .cornerRadius(100)
                }
                .listRowBackground(Color.clear)
                .listRowInsets(EdgeInsets())
                
            }
            
            .navigationTitle("Update Settings")
         /*   .toolbar {
                Button {
                    showAddVehicleForm.toggle()
                }
              
            label: {
                ZStack {
                    Image(systemName: "car.fill")
                        .font(Font.system(size:30))

                    VStack {
                        HStack {
                            ZStack {
                                Circle()
                                 
                                    .foregroundStyle(Color(UIColor.systemBackground))
                                  
                                Image(systemName:"plus.circle.fill")
                                    .font(Font.system(size:14))
                                    .fontWeight(.black)
                            }
                           
                                                           
                            Rectangle()
                                .foregroundStyle(.clear)
                        }
                        HStack {
                            Rectangle()
                                .foregroundStyle(.clear)
                            
                            Rectangle()
                                .foregroundStyle(.clear)
                        }
                    }
                                   
                }
                //.padding(10)
            }
            .sheet(isPresented: $showAddVehicleForm, content: {
              //  AddVehicleForm(vehicles: $vehicles)
            })
            .padding(.top, 10)
            }*/
        }
        .onAppear {
            vehicleType = VehicleTypes(rawValue: vehicle.getType) ?? .Car
            vehicleMake = VehicleMake(rawValue: vehicle.getMake) ?? .AC
            model = Model(rawValue: vehicle.getModel) ?? .ATS
            year = Int(vehicle.year)
            alphabet = Alphbets(rawValue: String(vehicleMake.rawValue.first ?? "A").uppercased()) ?? .A
            fuelType = FuelTypes(rawValue: vehicle.getFuelEngine) ?? .Gas
            odometer = String(vehicle.odometer)
            trip = String(vehicle.trip)
            distanceMode = DistanceModes(rawValue: settings.getDistanceUnit) ?? .km
            fuelMode = FuelModes(rawValue: settings.getFuelVolumeUnit) ?? .Litre
            efficiencyMode = efficiencyModes.firstIndex(where: {$0 == settings.fuelEfficiencyUnit}) ?? 0
            
        }
    }
}

#Preview {
    UpdateVehicleView(locationDataManager: LocationDataManager(), settings: Settings(), vehicle: (Vehicle()))
}
