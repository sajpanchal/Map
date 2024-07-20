//
//  FuellingEntryForm.swift
//  Map
//
//  Created by saj panchal on 2024-06-22.
//

import SwiftUI

struct FuellingEntryForm: View {
   // @Binding var fuelDataHistory: [FuelData]
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(entity: Vehicle.entity(), sortDescriptors: []) var vehicles: FetchedResults<Vehicle>
    @StateObject var locationDatamanager: LocationDataManager
//    @Binding var vehicle: AutoVehicle?
//    @Binding var vehicles: [AutoVehicle]
    @State var location = ""
    @State var amount = ""
    @State var cost = ""
    @State var date: Date = Date()
    @Binding var showFuellingEntryform: Bool
    @State var isTapped = false
  
    var yellowColor = Color(red:0.975, green: 0.646, blue: 0.207)
    //var lightYellowColor = Color(red:0.975, green: 0.918, blue: 0.647)
    var lightYellowColor = Color(red:0.938, green: 1.0, blue: 0.781)
    var body: some View {
        NavigationStack {
            Form {
                Section(header:Text("Fuel Station:").font(Font.system(size: 15))) {
                    TextField("Enter Location", text:$location)
                        .onTapGesture {
                            isTapped = false
                        }
                       
                    if location.isEmpty && isTapped {
                        Text("location field can not be empty!")
                            .font(.caption2)
                            .foregroundStyle(.red)
                    }
                    else if Double(location) != nil && isTapped {
                        Text("Please enter the valid text entry!")
                            .font(.caption2)
                            .foregroundStyle(.red)
                    }
                }
              
                Section(header:Text("Fuel Volume in Litre:").font(Font.system(size: 15))) {
                    TextField("Enter Amount", text: $amount)
                        .keyboardType(.decimalPad)
                        .onTapGesture {
                            isTapped = false
                        }
                    if amount.isEmpty && isTapped {
                        Text("This field can not be empty!")
                            .font(.caption2)
                            .foregroundStyle(.red)
                    }
                    else if Double(amount) == nil && isTapped {
                        Text("Please enter the valid text entry!")
                            .font(.caption2)
                            .foregroundStyle(.red)
                    }
                }
                Section(header:Text("Fuel Cost:").font(Font.system(size: 15))) {
                    TextField("Enter Cost", text: $cost)
                        .keyboardType(.decimalPad)
                        .onTapGesture {
                            isTapped = false
                        }
                    if cost.isEmpty && isTapped {
                        Text("This field can not be empty!")
                            .font(.caption2)
                            .foregroundStyle(.red)
                    }
                    else if Double(cost) == nil && isTapped {
                        Text("Please enter the valid text entry!")
                            .font(.caption2)
                            .foregroundStyle(.red)
                    }
                }
                Section(header: Text("Date:").font(Font.system(size: 15))) {
                    DatePicker("Fuelling Day", selection: $date, displayedComponents:[.date])
                      
                    if date > Date() {
                        Text("Future date is not acceptable!")
                            .font(.caption2)
                            .foregroundStyle(.red)
                    }
                }
                if let vehicle = vehicles.first(where: {$0.isActive}) {
                    VStack {
                        Button {
                            if isTextFieldEntryValid() {
                                let fuelling = AutoFuelling(context: viewContext)
                                fuelling.uniqueID = UUID()
                                fuelling.cost = Double(cost) ?? 0
                                fuelling.date = date
                                fuelling.timeStamp = Date()
                                fuelling.location = location
                                fuelling.volume = Double(amount) ?? 0
                                vehicle.addToFuellings(fuelling)
                                if  let i = vehicles.firstIndex(where: {$0.uniqueID == vehicle.uniqueID}) {
                                    //vehicles[i]
                                    vehicles[i].fuelCost = 0
                                    locationDatamanager.trip = 0.00
                                   
                                    vehicles[i].trip = 0
                                    print("trip:",  locationDatamanager.trip)
                                    print("odometer:", vehicles[i].odometer)
                                    for fuel in vehicle.getFuellings {
                                        vehicles[i].fuelCost += fuel.cost
                                      
                                      
                                    
                                        print("fuel cost = \(vehicles[i].fuelCost)")
                                    }
                                    Vehicle.saveContext(viewContext: viewContext)
                                    print("updated:", vehicles[i].odometer, vehicles[i].trip)
                                }
                               
                               
                            }
                           
                            isTapped = true
                          
                         showFuellingEntryform = !isTextFieldEntryValid()
                        } label: {
                            HStack {
                                Spacer()
                                Image(systemName: "plus.square.fill")
                                    .foregroundStyle(lightYellowColor)
                                    .font(Font.system(size: 25))
                                
                                Text("Add Entry")
                                  
                                    .foregroundStyle(lightYellowColor)
                                Spacer()
                            }
                            .frame(height: 40, alignment: .center)
                        }
                        .background(yellowColor)
                        .buttonStyle(BorderlessButtonStyle())
                        .cornerRadius(100)
                    }
                    .listRowBackground(Color.clear)
                    .listRowInsets(EdgeInsets())
                }
              
                      
            }
            .navigationTitle("Add Fuelling Entry")
    
           
        }
       
    }
    func isTextFieldEntryValid() -> Bool {
        if location.isEmpty || amount.isEmpty || cost.isEmpty {
            return false
        }
        if Double(amount) == nil || Double(cost) == nil || Double(location) != nil {
            return false
        }
        if date > Date() {
            return false
        }
        
        return true
    }
    
}


#Preview {
   // FuellingEntryForm(vehicle: .constant(AutoVehicle(isActive: false, serviceHistory: [], fuelHistory: [])), showFuellingEntryform: .constant(false))
    FuellingEntryForm(locationDatamanager: LocationDataManager(), showFuellingEntryform: .constant(false))
}
