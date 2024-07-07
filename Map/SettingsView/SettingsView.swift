//
//  SettingsView.swift
//  Map
//
//  Created by saj panchal on 2024-06-16.
//

import SwiftUI

struct SettingsView: View {
    @State var vIndex = 0
    @State var vehicles = [Vehicle(make: "Honda", model: "civic", year: "2018", fuelType: "Gas", image: "car.fill"), Vehicle(make: "Toyota", model: "corolla", year: "2021", fuelType: "EV", image: "car.fill"),Vehicle(make: "Kia", model: "Optima", year: "2023", fuelType: "Hybrid", image: "car.fill")]
    @State var fuelType: FuelTypes = .Gas
    @State var distanceMode: DistanceModes = .km
    @State var fuelMode: FuelModes = .Litre
    @State var efficiencyModes = ["km/L", "L/100km", "miles/L","L/100Miles", "km/gl",  "gl/100km", "miles/gl", "gl/100miles", "km/kwh", "miles/kwh"]
    @State var efficiencyMode = 0
    @State var showAddVehicleForm = false
    var skyColor = Color(red:0.031, green:0.739, blue:0.861)
    var lightSkyColor = Color(red:0.657, green:0.961, blue: 1.0)

    var body: some View {
        NavigationStack {
            Form {
                
                Section(header:Text("Vehicle Selection")) {
                    Picker("Select Vehicle", selection: $vIndex) {
                        ForEach(vehicles.indices, id: \.self) { v in
                            HStack {
                                Image(systemName: "car.fill")
                                Spacer()
                                HStack {
                                    Text(vehicles[v].make!)
                                    Text(vehicles[v].model!)
                                    Text(vehicles[v].year!)
                                    Text(vehicles[v].fuelType!)
                                }
                                Spacer()
                            }
                        }
                    }
                    .pickerStyle(.inline)
                }
                
                Section(header: Text("Fuel Type")) {
                    if vehicles[vIndex].fuelType! != "Hybrid" {
                        Picker("Select type", selection: $fuelType) {
                            Text(vehicles[vIndex].fuelType!)
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
                
                Section(header: Text("Distance Unit")) {
                    Picker("Select Unit", selection: $distanceMode) {
                        ForEach(DistanceModes.allCases) { unit in
                            Text(unit.rawValue.capitalized)
                        }
                    }
                    .pickerStyle(.segmented)
                }
                
                if fuelType == .Gas && (vehicles[vIndex].fuelType == "Gas" || vehicles[vIndex].fuelType == "Hybrid") {
                    Section(header: Text("Fuel Volume Unit")) {
                        Picker("Select Unit", selection: $fuelMode) {
                            ForEach(FuelModes.allCases) { unit in
                                Text(unit.rawValue.capitalized)
                            }
                        }
                        .pickerStyle(.segmented)
                    }
                }
                if fuelType == .Gas && (vehicles[vIndex].fuelType == "Gas" || vehicles[vIndex].fuelType == "Hybrid"){
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
            
            .navigationTitle("Settings")
            .toolbar {
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
                AddVehicleForm()
            })
            .padding(.top, 10)
            }
        }
       
    }
}

#Preview {
    SettingsView()
}
