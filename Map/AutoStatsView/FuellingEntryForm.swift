//
//  FuellingEntryForm.swift
//  Map
//
//  Created by saj panchal on 2024-06-22.
//

import SwiftUI

struct FuellingEntryForm: View {
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(entity: Vehicle.entity(), sortDescriptors: []) var vehicles: FetchedResults<Vehicle>
    @StateObject var locationDatamanager: LocationDataManager
    
    @State var location = ""
    @State var amount = ""
    @State var cost = ""
    @State var date: Date = Date()
    @State var isTapped = false
    
    @Binding var showFuellingEntryform: Bool
    
    var yellowColor = Color(red:1.0, green: 0.80, blue: 0.0)
    var lightYellowColor = Color(red:0.938, green: 1.0, blue: 0.84)
    
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
                                let index = vehicles.firstIndex(where: {$0.uniqueID == vehicle.uniqueID})
                                
                                addFuellingEntry(for: vehicle, at: index)
                                                               
                                if  let i = index {
                                    resetTripData(at: i)
                                    calculateFuelCost(for: vehicle, at: i)
                                    calculateFuelEfficiency(for: vehicle, at: i)
                                }
                            }
                            isTapped = true
                            showFuellingEntryform = !isTextFieldEntryValid()
                        } label: {
                            FormButton(imageName: "plus.square.fill", text: "Add Entry", color: lightYellowColor)
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
    
    func addFuellingEntry(for vehicle: Vehicle, at index: Int?) {
        let fuelling = AutoFuelling(context: viewContext)
        fuelling.uniqueID = UUID()
        fuelling.cost = Double(cost) ?? 0
        fuelling.date = date
        fuelling.timeStamp = Date()
        fuelling.location = location
        fuelling.lasttrip = index != nil ? vehicles[index!].trip : 0.0
        fuelling.volume = Double(amount) ?? 0
        vehicle.addToFuellings(fuelling)
    }
    
    func resetTripData(at index: Int) {
        vehicles[index].fuelCost = 0
        locationDatamanager.trip = 0.00
        vehicles[index].trip = 0
    }
    func calculateFuelCost(for vehicle: Vehicle, at index: Int) {
        for fuel in vehicle.getFuellings {
            vehicles[index].fuelCost += fuel.cost
        }
    }
    func calculateFuelEfficiency(for vehicle: Vehicle, at index: Int) {
        let fuellings = vehicle.getFuellings.filter({$0.lasttrip != 0})
        var fuelVolume = 0.0
        var tripReadings = 0.0
        if !fuellings.isEmpty {
            for fuel in fuellings {
                fuelVolume += fuel.volume
                tripReadings += fuel.lasttrip
            }
            vehicles[index].fuelEfficiency = (tripReadings/fuelVolume)
            Vehicle.saveContext(viewContext: viewContext)
        }
    }
}


#Preview {
    FuellingEntryForm(locationDatamanager: LocationDataManager(), showFuellingEntryform: .constant(false))
}
