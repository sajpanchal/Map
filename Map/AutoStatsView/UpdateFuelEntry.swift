//
//  UpdateFuelEntry.swift
//  Map
//
//  Created by saj panchal on 2024-07-28.
//

import SwiftUI

struct UpdateFuelEntry: View {
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(entity: Vehicle.entity(), sortDescriptors: []) var vehicles: FetchedResults<Vehicle>
    @FetchRequest(entity: AutoFuelling.entity(), sortDescriptors: []) var fuelEntries: FetchedResults<AutoFuelling>
    @FetchRequest(entity: Settings.entity(), sortDescriptors: []) var settings: FetchedResults<Settings>
    //@StateObject var locationDatamanager: LocationDataManager
    
    @State var location = ""
    @State var amount = ""
    @State var cost = ""
    @State var date: Date = Date()
    @State var isTapped = false
    var fuelEntry: AutoFuelling

    
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
                Section(header:Text("Fuel Volume in \(settings.first!.getFuelVolumeUnit):").font(Font.system(size: 15))) {
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
                         
                        } label: {
                            FormButton(imageName: "plus.square.fill", text: "Update Entry", color: lightYellowColor)
                        }
                        .background(yellowColor)
                        .buttonStyle(BorderlessButtonStyle())
                        .cornerRadius(100)
                    }
                    .listRowBackground(Color.clear)
                    .listRowInsets(EdgeInsets())
                }
            }
            .navigationTitle("Update Fuelling Entry")
        }
        .onAppear(perform: {
            location = fuelEntry.location ?? ""
            amount = settings.first!.getFuelVolumeUnit == "Litre" ? String(fuelEntry.volume) : String(fuelEntry.volume * 0.264)
            cost = String(fuelEntry.cost)
            date = fuelEntry.date ?? Date()
        })
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
        if let i = fuelEntries.firstIndex(where: {$0.uniqueID == fuelEntry.uniqueID && $0.vehicle == vehicle}) {           
            fuelEntries[i].cost = Double(cost) ?? 0
            fuelEntries[i].date = date
            fuelEntries[i].timeStamp = Date()
            fuelEntries[i].location = location
            fuelEntries[i].lasttrip = index != nil ? vehicles[index!].trip : 0.0
            
            fuelEntries[i].volume = settings.first!.getFuelVolumeUnit == "Litre" ? Double(amount) ?? 0 : (Double(amount) ?? 0) * 0.264
        }
       // AutoFuelling.
        Vehicle.saveContext(viewContext: viewContext)
        
    }
    
    func resetTripData(at index: Int) {
        vehicles[index].fuelCost = 0
       // locationDatamanager.trip = 0.00
        //vehicles[index].trip = 0
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
    UpdateFuelEntry( fuelEntry: AutoFuelling())
}
