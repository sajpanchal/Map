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
    @FetchRequest(entity: Settings.entity(), sortDescriptors: []) var settings: FetchedResults<Settings>
    @StateObject var locationDatamanager: LocationDataManager
    @State var location = ""
    ///state variable to store litre of fuel
    @State var litre = ""
    ///state variable to store litre of fuel
    @State var gallon = ""
    ///state variable to store the % of ev battery charged before charging it.
    @State var percentBeforeCharge = ""
    ///state variable to store the % of ev battery charged after charging it.
    @State var percentAfterCharge = ""
    @State var cost = ""
    @State var date: Date = Date()
    @State var isTapped = false
    @Binding var showFuellingEntryform: Bool
    
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
                ///fuel volume entry field
                Section(header:Text("Fuel Volume in \(settings.first!.getFuelVolumeUnit)").fontWeight(.bold)) {
                    ///if the fuel volume unit is set to litre
                    if settings.first!.getFuelVolumeUnit == "Litre" {
                        ///fill volume in litre
                        TextField("Enter Fuel Volume", text: $litre)
                            .keyboardType(.decimalPad)
                            ///on tap of the textfield
                            .onTapGesture {
                                isTapped = false
                            }
                        ///if the variable is not set and textfield is not active.
                        if litre.isEmpty && isTapped {
                            Text("This field can not be empty!")
                                .font(.caption2)
                                .foregroundStyle(.red)
                        }
                        ///if value is not number type and textfield is not active.
                        else if Double(litre) == nil && isTapped {
                            Text("Please enter the valid text entry!")
                                .font(.caption2)
                                .foregroundStyle(.red)
                        }
                    }
                    ///if the fuel volume unit is set to gallon
                    else if settings.first!.getFuelVolumeUnit == "Gallon" {
                        ///fill volume in gallon
                        TextField("Enter Fuel Volume", text: $gallon)
                            .keyboardType(.decimalPad)
                        ///on tap of the textfield
                            .onTapGesture {
                                isTapped = false
                            }
                        ///if the variable is not set and textfield is not active.
                        if gallon.isEmpty && isTapped {
                            Text("This field can not be empty!")
                                .font(.caption2)
                                .foregroundStyle(.red)
                        }
                        ///if value is not number type and textfield is not active.
                        else if Double(gallon) == nil && isTapped {
                            Text("Please enter the valid text entry!")
                                .font(.caption2)
                                .foregroundStyle(.red)
                        }
                    }
                    ///if the fuel volume unit is set to %.
                    else {
                        ///fill volume in % of charge before start
                        TextField("Enter % of battery Charge before starting charge", text: $percentBeforeCharge)
                            .keyboardType(.decimalPad)
                        ///on tap of the textfield
                            .onTapGesture {
                                isTapped = false
                            }
                        ///if the variable is not set and textfield is not active.
                        if percentBeforeCharge.isEmpty && isTapped {
                            Text("This field can not be empty!")
                                .font(.caption2)
                                .foregroundStyle(.red)
                        }
                        ///if value is not number type and textfield is not active.
                        else if Double(percentBeforeCharge) == nil && isTapped {
                            Text("Please enter the valid text entry!")
                                .font(.caption2)
                                .foregroundStyle(.red)
                        }
                        ///fill volume in % of charge after finish
                        TextField("Enter  % of battery Charge after finishing charge", text: $percentAfterCharge)
                            .keyboardType(.decimalPad)
                            .onTapGesture {
                                isTapped = false
                            }
                        ///if the variable is not set and textfield is not active.
                        if percentAfterCharge.isEmpty && isTapped {
                            Text("This field can not be empty!")
                                .font(.caption2)
                                .foregroundStyle(.red)
                        }
                        ///if value is not number type and textfield is not active.
                        else if Double(percentAfterCharge) == nil && isTapped {
                            Text("Please enter the valid text entry!")
                                .font(.caption2)
                                .foregroundStyle(.red)
                        }
                        ///if charging before is greater than charging after.
                        else if Double(percentBeforeCharge) ?? 0  >= Double(percentAfterCharge) ?? 1 {
                            Text("charing percent before charging can't be more than or equal to after charging percent!")
                                .font(.caption2)
                                .foregroundStyle(.red)
                        }
                    }
                }
                ///fuel cost entry field
                Section(header:Text("Fuel Cost").fontWeight(.bold)) {
                    TextField("Enter Cost", text: $cost)
                        .keyboardType(.decimalPad)
                        .onTapGesture {
                            isTapped = false
                        }
                    ///if the variable is not set and textfield is not active.
                    if cost.isEmpty && isTapped {
                        Text("This field can not be empty!")
                            .font(.caption2)
                            .foregroundStyle(.red)
                    }
                    ///if value is not number type and textfield is not active.
                    else if Double(cost) == nil && isTapped {
                        Text("Please enter the valid text entry!")
                            .font(.caption2)
                            .foregroundStyle(.red)
                    }
                }
                ///
                Section(header: Text("Date").fontWeight(.bold)) {
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
                            FormButton(imageName: "plus.square.fill", text: "Add Entry", color: Color(AppColors.yellow.rawValue))
                        }
                        .background(Color(AppColors.invertYellow.rawValue))
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
        if location.isEmpty || cost.isEmpty || (percentAfterCharge.isEmpty && percentBeforeCharge.isEmpty && litre.isEmpty && gallon.isEmpty) {
            return false
        }
        if (Double(percentAfterCharge) == nil && Double(percentBeforeCharge) == nil && Double(litre) == nil && Double(gallon) == nil) || Double(cost) == nil || Double(location) != nil {
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
        ///if the fuel engine is hybrid
        if vehicle.fuelEngine == "Hybrid" {
            ///if hyrid vehicle is currently set to gas engine mode
            if vehicle.getFuelMode == "Gas" {
                ///if distance unit is set in km.
                if settings.first!.distanceUnit == "Km" {
                    ///set the fuelling entry trip property with the given vehicle's dashboard trip. (in km)
                    fuelling.lasttrip = index != nil ? vehicles[index!].trip : 0.0
                    ///set the fuelling entry trip property with the given vehicle's dashboard trip. (in miles)
                    fuelling.lastTripMiles = fuelling.lasttrip * 0.6214
                }
                ///if distance unit is set in miles.
                else {
                    ///set the fuelling entry trip property with the given vehicle's dashboard trip. (in miles)
                    fuelling.lastTripMiles = index != nil ? vehicles[index!].tripMiles : 0.0
                    ///set the fuelling entry trip property with the given vehicle's dashboard trip. (in km)
                    fuelling.lasttrip = fuelling.lastTripMiles / 0.6214
                }
            }
            ///if hyrid vehicle is currently set to ev engine mode
            else {
                ///set the fuelling entry trip property with the given vehicle's dashboard trip. (in km)
                fuelling.lasttrip = index != nil ? vehicles[index!].tripHybridEV : 0.0
                ///set the fuelling entry trip property with the given vehicle's dashboard trip. (in miles)
                fuelling.lastTripMiles = index != nil ? vehicles[index!].tripHybridEVMiles : 0.0
            }
        }
        ///if fuel engine is not hybrid
        else {
            ///if distance unit is set in km.
            if settings.first!.distanceUnit == "Km" {
                ///set the fuelling entry trip property with the given vehicle's dashboard trip. (in km)
                fuelling.lasttrip = index != nil ? vehicles[index!].trip : 0.0
                ///set the fuelling entry trip property with the given vehicle's dashboard trip. (in miles)
                fuelling.lastTripMiles = fuelling.lasttrip * 0.6214
            }
            ///if distance unit is set in miles.
            else {
                ///set the fuelling entry trip property with the given vehicle's dashboard trip. (in miles)
                fuelling.lastTripMiles = index != nil ? vehicles[index!].tripMiles : 0.0
                ///set the fuelling entry trip property with the given vehicle's dashboard trip. (in km)
                fuelling.lasttrip = fuelling.lastTripMiles / 0.6214
            }
        }
        ///set the fuel type field to the set fuel mode for that vehicle (gas or EV)
        fuelling.fuelType = vehicle.getFuelMode
        ///check fuel volume unit
        switch settings.first!.getFuelVolumeUnit {
            ///if it is in litre update the litre prop
        case "Litre":
            fuelling.litre =  Double(litre) ?? 0
            ///if it is in gallon update the gallon prop
        case "Gallon":
            fuelling.gallon =  Double(gallon) ?? 0
            ///if it is in % update the % prop.
        case "%":
            fuelling.percent =  (Double(percentAfterCharge)  ?? 0) - (Double(percentBeforeCharge)  ?? 0)
        default:
            print(" ")
        }
        ///add a new entry to the given vehicle.
        vehicle.addToFuellings(fuelling)
    }
    
    ///reset the trip data at a given index of the vehicle
    func resetTripData(at index: Int) {
        ///reset the fuel cost
        vehicles[index].fuelCost = 0
        ///reset the trip in location manager.
        locationDatamanager.trip = 0.00
        ///if the fuel engine is hybrid
        if vehicles[index].fuelEngine == "Hybrid" {
            ///if the fuel mode is gas
            if vehicles[index].getFuelMode == "Gas" {
                ///reset trip in km
                vehicles[index].trip = 0
                ///reset trip in miles
                vehicles[index].tripMiles = 0
            }
            ///if the fuel mode is ev
            else {
                ///reset ev trip in km
                vehicles[index].tripHybridEV = 0
                ///reset ev trip in miles
                vehicles[index].tripHybridEVMiles = 0
            }
        }
        ///if engine is not hybrid
        else {
            ///reset trip in km
            vehicles[index].trip = 0
            ///reset trip in miles
            vehicles[index].tripMiles = 0
        }
    }
    
    ///function to calculate fuel cost in total
    func calculateFuelCost(for vehicle: Vehicle, at index: Int) {
        ///get a list of fuelling records of a given vehicle filtred by its fuel mode (gas or ev)
        let fuellings = vehicle.getFuellings.filter({$0.fuelType == vehicle.fuelMode})
        ///iterate through the fuelling records
        for thisFuelEntry in fuellings {
            ///accumulate the fuel cost
            vehicles[index].fuelCost += thisFuelEntry.cost
        }
    }
    
    ///function to calculate the fuel efficiency of a given vehicle from the fuelling history
    func calculateFuelEfficiency(for vehicle: Vehicle, at index: Int) {
        ///get the list of fuellings from the given vehicle filtered by fuelmode (gas or ev)
        let fuellings = vehicle.getFuellings.filter({$0.fuelType == vehicle.fuelMode})
        ///local variable to store the accumulated fuel volume.
        var accumulatedFuelVolume = 0.0
        ///local variable to store the accumulated trip readings.
        var accumulatedTripReadings = 0.0
        ///if the list of fuellings is not empty
        if !fuellings.isEmpty {
            ///iterate through the list of fuellings
            for thisFuelEntry in fuellings {
                ///if the fuel volume unit is set to litre
                if settings.first!.getFuelVolumeUnit == "Litre" {
                    ///accumulate the fuel volume in litre
                    accumulatedFuelVolume += thisFuelEntry.litre
                }
                ///if the fuel volume unit is set to gallon
                else if settings.first!.getFuelVolumeUnit == "Gallon" {
                    ///accumulate the fuel volume in gallon
                    accumulatedFuelVolume += thisFuelEntry.gallon
                }
                ///if the fuel volume unit is set to %
                else if settings.first?.getFuelVolumeUnit == "%" {
                    ///accumulate the fuel volume in %
                    accumulatedFuelVolume += ((vehicle.batteryCapacity * thisFuelEntry.percent)/100)
                }
                ///if the distance unit is in km
                if settings.first?.distanceUnit == "Km" {
                    ///accumulate the trip odometer in km
                    accumulatedTripReadings += thisFuelEntry.lasttrip
                }
                ///if the distance unit is in miles
                else {
                    ///accumulate the trip odometer in miles
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
    FuellingEntryForm(locationDatamanager: LocationDataManager(), showFuellingEntryform: .constant(false))
}
