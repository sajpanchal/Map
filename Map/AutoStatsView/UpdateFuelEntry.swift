//
//  UpdateFuelEntry.swift
//  Map
//
//  Created by saj panchal on 2024-07-28.
//

import SwiftUI

struct UpdateFuelEntry: View {
    @Environment(\.colorScheme) var bgMode: ColorScheme
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(entity: Vehicle.entity(), sortDescriptors: []) var vehicles: FetchedResults<Vehicle>
    @FetchRequest(entity: AutoFuelling.entity(), sortDescriptors: []) var fuelEntries: FetchedResults<AutoFuelling>
    @FetchRequest(entity: Settings.entity(), sortDescriptors: []) var settings: FetchedResults<Settings>
    @State private var location = ""
    @State private var amount = 0.0
    @State private var percentBeforeCharge = 0
    @State private var percentAfterCharge = 0
    @State private var cost = 0.0
    @State private var date: Date = Date()
    @State private var isTapped = false
    @State private var tripKm = 0.0
    @State private var tripMiles = 0.0
    @State private var showAlert = false
    @Binding var showFuelHistoryView: Bool
    var fuelEntry: AutoFuelling

    var body: some View {
        NavigationStack {
            ZStack {
                VStack {
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
                        
                        Section(header:Text("EV Battery charge in \(settings.first!.getFuelVolumeUnit)").fontWeight(.bold)) {
                            if settings.first!.getFuelVolumeUnit != "%" {
                                TextField("Enter Amount", value: $amount, format: .number)
                                    .keyboardType(.decimalPad)
                                    .onTapGesture {
                                        isTapped = false
                                    }
                                if amount == 0.0 && isTapped {
                                    Text("This field can not be empty!")
                                        .font(.caption2)
                                        .foregroundStyle(.red)
                                }
                                else if amount < 0 && isTapped {
                                    Text("Please enter the valid text entry!")
                                        .font(.caption2)
                                        .foregroundStyle(.red)
                                }
                            }
                            else {
                                ///fill volume in % of charge before start
                                TextField("Enter % before charge", value: $percentBeforeCharge, format: .number)
                                    .keyboardType(.numberPad)
                                ///on tap of the textfield
                                    .onTapGesture {
                                        isTapped = false
                                    }
                                ///if value is not number type and textfield is not active.
                                if (percentBeforeCharge >= 100 || percentBeforeCharge < 0) && isTapped {
                                    Text("Please enter the valid percentage value between 0-99%")
                                        .font(.caption2)
                                        .foregroundStyle(.red)
                                }
                                ///fill volume in % of charge after finish
                                TextField("Enter % after charge", value: $percentAfterCharge, format: .number)
                                    .keyboardType(.numberPad)
                                    .onTapGesture {
                                        isTapped = false
                                    }
                                ///if the variable is not set and textfield is not active.
                                if percentAfterCharge == 0 && isTapped {
                                    Text("This field can not be empty!")
                                        .font(.caption2)
                                        .foregroundStyle(.red)
                                }
                                ///if charging before is greater than charging after.
                                else if percentBeforeCharge >= percentAfterCharge {
                                    Text("charging percent before charging can't be more than or equal to after charging percent!")
                                        .font(.caption2)
                                        .foregroundStyle(.red)
                                }
                                ///if value is not number type and textfield is not active.
                                else if (percentAfterCharge > 100 || percentAfterCharge <= 0) && isTapped {
                                    Text("Please enter the valid percentage value between 1-100%.")
                                        .font(.caption2)
                                        .foregroundStyle(.red)
                                }
                            }
                            
                        }
                        Section(header:Text("Fuel Cost").fontWeight(.bold)) {
                            TextField("Enter Cost", value: $cost, format: .number)
                                .keyboardType(.decimalPad)
                                .onTapGesture {
                                    isTapped = false
                                }
                            if cost == 0.0 && isTapped {
                                Text("This field can not be empty!")
                                    .font(.caption2)
                                    .foregroundStyle(.red)
                            }
                            else if cost < 0 && isTapped {
                                Text("Please enter the valid text entry!")
                                    .font(.caption2)
                                    .foregroundStyle(.red)
                            }
                        }
                        ///textfield to update the trip distance
                        Section(header:Text("Trip Distance in \(settings.first!.getDistanceUnit)").fontWeight(.bold)) {
                            ///if the distance unit is in km
                            if settings.first!.distanceUnit == "km" {
                                ///show the textfield to enter trip in km
                                TextField("Enter Distance", value: $tripKm, format: .number)
                                    .onChange(of: tripKm) {
                                        ///on change of tripkm variable, update fuel entry lasttrip in km
                                        fuelEntry.lasttrip = tripKm
                                        ///on change of tripkm variable, update fuel entry lasttrip in miles
                                        fuelEntry.lastTripMiles = fuelEntry.lasttrip * 0.6214
                                    }
                                    .keyboardType(.decimalPad)
                                    .onTapGesture {
                                        ///on tap of the textfield clear the isTapped flag detecting the submit button tap.
                                        isTapped = false
                                    }
                               if tripKm <= 0 && isTapped {
                                    Text("Please enter the valid text entry!")
                                        .font(.caption2)
                                        .foregroundStyle(.red)
                                }
                            }
                            else {
                                TextField("Enter Distance", value: $tripMiles, format: .number)
                                    .keyboardType(.decimalPad)
                                    .onTapGesture {
                                        isTapped = false
                                    }
                               if tripMiles <= 0.0 && isTapped {
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
                                HStack {
                                    Spacer()
                                    Button {
                                        if isTextFieldEntryValid() {
                                            let index = vehicles.firstIndex(where: {$0.uniqueID == activeVehicle.uniqueID})
                                            
                                            addFuellingEntry(for: activeVehicle, at: index)
                                                                           
                                            if  let i = index {
                                                calculateFuelCost(for: activeVehicle, at: i)
                                                calculateFuelEfficiency(for: activeVehicle, at: i)
                                            }
                                            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                                showFuelHistoryView = false
                                            }
                                          
                                        }
                                        isTapped = true
                                     
                                    } label: {
                                        FormButton(imageName: "plus.square.fill", text: "Update Entry", color: Color(AppColors.yellow.rawValue))
                                    }
                                    .background(Color(AppColors.invertYellow.rawValue))
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
                }
                if showAlert {
                    AlertView(image: "fuelpump.circle.fill", headline: "Fuel Entry Updated!", bgcolor: Color(AppColors.invertYellow.rawValue), showAlert: $showAlert)
                }
            }
          
            .navigationTitle("Update Fuelling Entry")
            .navigationBarTitleDisplayMode(.inline)
        }
        .onAppear(perform: {
            ///location of the fuel entry
            location = fuelEntry.location ?? ""
            ///if the fuel unit is in litre
            if settings.first!.getFuelVolumeUnit == "Litre" {
                ///set the fuel amount field with the previously set value in a given fuel entry prop.
                amount = fuelEntry.litre != 0.0 ? fuelEntry.litre : fuelEntry.getVolumeLitre
            }
            ///if the fuel unit is in gallon
            else if settings.first!.getFuelVolumeUnit == "Gallon" {
                ///set the fuel amount field with the previously set value in a given fuel entry prop.
                amount = fuelEntry.gallon != 0.0 ? fuelEntry.gallon : fuelEntry.getVolumeGallons
            }
            ///if the fuel unit is in %
            else if settings.first!.getFuelVolumeUnit == "%" {
                ///set the fuel amount field with the previously set value in a given fuel entry prop.
                amount = fuelEntry.percent
                percentBeforeCharge = 0
                percentAfterCharge = Int(amount)
            }
            ///set the fuel cost field to previously set cost
            cost = fuelEntry.cost
            date = fuelEntry.date ?? Date()
            ///set tripkm field to string formatted trip recorded in fuel entry field
            tripKm = fuelEntry.lasttrip
            ///set tripMiles field to string formatted trip recorded in fuel entry field
            tripMiles = fuelEntry.lastTripMiles
        })
    }
    func isTextFieldEntryValid() -> Bool {
        if location.isEmpty || cost <= 0 || (percentAfterCharge <= 0 && percentBeforeCharge <= 0 && amount <= 0) || (tripKm <= 0 && tripMiles <= 0) {
            return false
        }
        if date > Date() {
            return false
        }
        
        if settings.first!.getFuelVolumeUnit == "%" && (percentAfterCharge > 100 || percentBeforeCharge >= 100 || percentAfterCharge < percentBeforeCharge || percentAfterCharge == percentBeforeCharge) {
            return false
        }
        return true
    }
    func addFuellingEntry(for vehicle: Vehicle, at index: Int?) {
        if let i = fuelEntries.firstIndex(where: {$0.uniqueID == fuelEntry.uniqueID && $0.vehicle == vehicle}) {           
            fuelEntries[i].cost = cost
            fuelEntries[i].date = date
            fuelEntries[i].timeStamp = Date()
            fuelEntries[i].location = location
            ///if the distance unit is in km.
            if settings.first!.getDistanceUnit == "km" {
                ///set the last trip in fuel entry entity record in km.
                fuelEntries[i].lasttrip = tripKm
                fuelEntries[i].lastTripMiles = fuelEntries[i].lasttrip * 0.6214
            }
            ///if the distance unit is in miles.
            else {
                ///set the last trip in fuel entry entity record in miles.
                fuelEntries[i].lastTripMiles = tripMiles
                fuelEntries[i].lasttrip = fuelEntries[i].lastTripMiles / 0.6214
            }
            ///if the fuel volume unit is in litre
            if settings.first!.getFuelVolumeUnit == "Litre" {
                ///set the fuel entry field litre property
                fuelEntries[i].litre = amount
                ///convert from litre to gallon and set the fuel entry field gallon property
                fuelEntries[i].gallon = fuelEntries[i].litre/3.785
            }
            ///if the fuel volume unit is in gallon
            else if settings.first!.getFuelVolumeUnit == "Gallon" {
                ///set the fuel entry field gallon property
                fuelEntries[i].gallon = amount
                ///convert from gallon to litre and set the fuel entry field litre property
                fuelEntries[i].litre = fuelEntries[i].gallon * 3.785
            }
            ///if the fuel volume unit is in %
            else if settings.first!.getFuelVolumeUnit == "%" {
                amount = Double(percentAfterCharge - percentBeforeCharge)
                ///set the fuel entry field % property
                fuelEntries[i].percent = amount
            }
        }
        Vehicle.saveContext(viewContext: viewContext)
        withAnimation(.easeIn(duration: 0.5)) {
            showAlert = true
        }
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
    UpdateFuelEntry(showFuelHistoryView: .constant(false), fuelEntry: AutoFuelling())
}
