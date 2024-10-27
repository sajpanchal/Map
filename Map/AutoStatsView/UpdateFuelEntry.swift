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
    @State var location = ""
    @State var amount = ""
    @State var cost = ""
    @State var date: Date = Date()
    @State var isTapped = false
    @State var tripKm = ""
    @State var tripMiles = ""
    var fuelEntry: AutoFuelling

    var body: some View {
        NavigationStack {
            Form {
                Section(header:Text("Fuel Station").fontWeight(.bold)) {
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
                Section(header:Text("Fuel Volume in \(settings.first!.getFuelVolumeUnit)").fontWeight(.bold)) {
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
                ///textfield to update the trip distance
                Section(header:Text("Trip Distance in \(settings.first!.getDistanceUnit)").font(Font.system(size: 15))) {
                    ///if the distance unit is in km
                    if settings.first!.distanceUnit == "km" {
                        ///show the textfield to enter trip in km
                        TextField("Enter Distance", text: $tripKm)
                            .onChange(of: tripKm) {
                                ///on change of tripkm variable, update fuel entry lasttrip in km
                                fuelEntry.lasttrip = Double(tripKm) ?? 0
                                ///on change of tripkm variable, update fuel entry lasttrip in miles
                                fuelEntry.lastTripMiles = fuelEntry.lasttrip * 0.6214
                            }
                            .keyboardType(.decimalPad)
                            .onTapGesture {
                                ///on tap of the textfield clear the isTapped flag detecting the submit button tap.
                                isTapped = false
                            }
                        if tripKm.isEmpty && isTapped {
                            Text("This field can not be empty!")
                                .font(.caption2)
                                .foregroundStyle(.red)
                        }
                        else if Double(tripKm) == nil && isTapped {
                            Text("Please enter the valid text entry!")
                                .font(.caption2)
                                .foregroundStyle(.red)
                        }
                    }
                    else {
                        TextField("Enter Distance", text: $tripMiles)
                            .keyboardType(.decimalPad)
                            .onTapGesture {
                                isTapped = false
                            }
                        if tripMiles.isEmpty && isTapped {
                            Text("This field can not be empty!")
                                .font(.caption2)
                                .foregroundStyle(.red)
                        }
                        else if Double(tripKm) == nil && isTapped {
                            Text("Please enter the valid text entry!")
                                .font(.caption2)
                                .foregroundStyle(.red)
                        }
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
                if let activeVehicle = vehicles.first(where: {$0.isActive}) {
                    VStack {
                        Button {
                            if isTextFieldEntryValid() {
                                let index = vehicles.firstIndex(where: {$0.uniqueID == activeVehicle.uniqueID})
                                
                                addFuellingEntry(for: activeVehicle, at: index)
                                                               
                                if  let i = index {
                                    calculateFuelCost(for: activeVehicle, at: i)
                                    calculateFuelEfficiency(for: activeVehicle, at: i)
                                }
                            }
                            isTapped = true
                         
                        } label: {
                            FormButton(imageName: "plus.square.fill", text: "Update Entry", color: Color(AppColors.yellow.rawValue))
                        }
                        .background(Color(AppColors.invertYellow.rawValue))
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
            ///location of the fuel entry
            location = fuelEntry.location ?? ""
            ///if the fuel unit is in litre
            if settings.first!.getFuelVolumeUnit == "Litre" {
                ///set the fuel amount field with the previously set value in a given fuel entry prop.
                amount = fuelEntry.litre != 0.0 ? String(fuelEntry.litre) : String(fuelEntry.getVolumeLitre)
            }
            ///if the fuel unit is in gallon
            else if settings.first!.getFuelVolumeUnit == "Gallon" {
                ///set the fuel amount field with the previously set value in a given fuel entry prop.
                amount = fuelEntry.gallon != 0.0 ? String(fuelEntry.gallon) : String(fuelEntry.getVolumeGallons)
            }
            ///if the fuel unit is in %
            else if settings.first!.getFuelVolumeUnit == "%" {
                ///set the fuel amount field with the previously set value in a given fuel entry prop.
                amount = String(fuelEntry.percent)
            }
            ///set the fuel cost field to previously set cost
            cost = String(fuelEntry.cost)
            date = fuelEntry.date ?? Date()
            ///set tripkm field to string formatted trip recorded in fuel entry field
            tripKm = String(fuelEntry.lasttrip)
            ///set tripMiles field to string formatted trip recorded in fuel entry field
            tripMiles = String(fuelEntry.lastTripMiles)
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
            ///if the distance unit is in km.
            if settings.first!.getDistanceUnit == "km" {
                ///set the last trip in fuel entry entity record in km.
                fuelEntries[i].lasttrip = Double(tripKm) ?? 0.0
                fuelEntries[i].lastTripMiles = fuelEntries[i].lasttrip * 0.6214
            }
            ///if the distance unit is in miles.
            else {
                ///set the last trip in fuel entry entity record in miles.
                fuelEntries[i].lastTripMiles = Double(tripMiles) ?? 0.0
                fuelEntries[i].lasttrip = fuelEntries[i].lastTripMiles / 0.6214
            }
            ///if the fuel volume unit is in litre
            if settings.first!.getFuelVolumeUnit == "Litre" {
                ///set the fuel entry field litre property
                fuelEntries[i].litre = Double(amount) ?? 0
                ///convert from litre to gallon and set the fuel entry field gallon property
                fuelEntries[i].gallon = fuelEntries[i].litre/3.785
            }
            ///if the fuel volume unit is in gallon
            else if settings.first!.getFuelVolumeUnit == "Gallon" {
                ///set the fuel entry field gallon property
                fuelEntries[i].gallon = Double(amount) ?? 0
                ///convert from gallon to litre and set the fuel entry field litre property
                fuelEntries[i].litre = fuelEntries[i].gallon * 3.785
            }
            ///if the fuel volume unit is in %
            else if settings.first!.getFuelVolumeUnit == "%" {
                ///set the fuel entry field % property
                fuelEntries[i].percent = Double(amount) ?? 0
            }
        }
        Vehicle.saveContext(viewContext: viewContext)
    }
    
    func resetTripData(at index: Int) {
        vehicles[index].fuelCost = 0
    }
    
    func calculateFuelCost(for vehicle: Vehicle, at index: Int) {
        for fuel in vehicle.getFuellings {
            vehicles[index].fuelCost += fuel.cost
        }
    }
    
    func calculateFuelEfficiency(for vehicle: Vehicle, at index: Int) {
        let fuellings = vehicle.getFuellings.filter({$0.lasttrip != 0})
        var accumulatedFuelVolume = 0.0
        var accumulatedTripReadings = 0.0
        ///if the fuellings array is not empty
        if !fuellings.isEmpty {
            ///iterate through fuellings array
            for thisFuelEntry in fuellings {
                ///if the fuel volume unit is in litre
                if settings.first!.getFuelVolumeUnit == "Litre" {
                    ///accumulate the fuel volume in litre
                    accumulatedFuelVolume += thisFuelEntry.litre
                }
                ///if the fuel volume unit is in gallon
                else if settings.first!.getFuelVolumeUnit == "Gallon" {
                    ///accumulate the fuel volume in gallon
                    accumulatedFuelVolume += thisFuelEntry.gallon
                }
                ///accumulate the fuel volume in %
                else if settings.first?.getFuelVolumeUnit == "%" {
                    ///accumulate the fuel volume in %
                    accumulatedFuelVolume += ((vehicle.batteryCapacity * thisFuelEntry.percent)/100)
                }
                ///if the distance unit is in km.
                if settings.first!.distanceUnit == "km" {
                    ///accumulate the trip from trip odometers in km.
                    accumulatedTripReadings += thisFuelEntry.lasttrip
                }
                ///if the distance unit is in miles.
                else {
                    ///accumulate the trip from trip odometers in miles.
                    accumulatedTripReadings += thisFuelEntry.lastTripMiles
                }
              
            }
            ///calculate the fuel efficiency.
            vehicles[index].fuelEfficiency = (accumulatedTripReadings/accumulatedFuelVolume)
            Vehicle.saveContext(viewContext: viewContext)
        }
    }
}

#Preview {
    UpdateFuelEntry( fuelEntry: AutoFuelling())
}
