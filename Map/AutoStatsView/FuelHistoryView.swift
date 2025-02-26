//
//  FuelHistoryView.swift
//  Map
//
//  Created by saj panchal on 2024-06-20.
//

import SwiftUI

struct FuelHistoryView: View {
    @FetchRequest(entity: Settings.entity(), sortDescriptors:[]) var settings: FetchedResults<Settings>
    @FetchRequest(entity: Vehicle.entity(), sortDescriptors:[]) var vehicles: FetchedResults<Vehicle>
    @FetchRequest(entity: AutoSummary.entity(), sortDescriptors: []) var reports: FetchedResults<AutoSummary>
    @Environment(\.colorScheme) var bgMode: ColorScheme
    @Environment(\.managedObjectContext) private var viewContext
    @Binding var showFuelHistoryView: Bool
    var vehicle: Vehicle
   
    var body: some View {
        NavigationStack {
            List {
                ForEach(vehicle.getFuellingDates.sorted(by: >), id: \.self) { thisDate in
                    
                    Section(header: Text(getString(from: thisDate)).fontWeight(.bold)) {
                        
                        if let thisSettings = vehicle.settings  {
                            ///get the fuel mode (gas or ev) from the saved settings for a selected vehicle.
                            if let fuelMode = vehicle.fuelMode {
                                ///iterate through the vehicle fuelling entries filtred by fuel mode (uniquely identified by its uniqueID) and display them in a list of navigation links.
                                ForEach(vehicle.getFuellings.filter({$0.fuelType == fuelMode}), id:\.self.uniqueID) { thisFuelEntry in
                                    if thisDate == thisFuelEntry.getShortDate {
                                        ///navigation list shows this fuel entry data as a label and a link to a form to update it on tap gesture.
                                        NavigationLink(destination: UpdateFuelEntry(showFuelHistoryView: $showFuelHistoryView ,fuelEntry: thisFuelEntry), label: {
                                            ///vertical stack enclosing fuel entry data in text.
                                            VStack {
                                                ///text to show date of fuelling
                                                Text(thisFuelEntry.getDateString)
                                                    .font(.system(size: 12))
                                                    .fontWeight(.black)
                                                    .foregroundStyle(bgMode == .dark ? Color(UIColor.systemGray2) : Color(UIColor.darkGray))
                                                Spacer()
                                                ///horizontal stack enclosing fuelling location, volume and cost.
                                                HStack {
                                                    /// fuel station location
                                                    VStack {
                                                        Text("Fuel Station")
                                                            .font(.system(size: 10, weight: .semibold))
                                                            .foregroundStyle(bgMode == .dark ? Color(UIColor.systemGray2) : Color(UIColor.darkGray))
                                                        Text(thisFuelEntry.location!)
                                                            .font(.system(size: 14, weight: .bold))
                                                            .foregroundStyle(Color(AppColors.invertBlueColor.rawValue))
                                                    }
                                                    Spacer()
                                                    ///fuel volume
                                                    VStack {
                                                        Text("Volume")
                                                            .font(.system(size: 12, weight: .semibold))
                                                            .foregroundStyle(bgMode == .dark ? Color(UIColor.systemGray2) : Color(UIColor.darkGray))
                                                        ///if unit is in litre
                                                        if thisSettings.fuelVolumeUnit == "Litre" {
                                                            Text(String(format:"%.2f",thisFuelEntry.litre) + " L")
                                                                .font(.system(size: 14, weight: .bold))
                                                                .foregroundStyle(Color(AppColors.invertYellow.rawValue))
                                                        }
                                                        ///if unit is in gallon
                                                        else if thisSettings.fuelVolumeUnit == "Gallon"  {
                                                            Text(String(format:"%.2f",thisFuelEntry.gallon) + " GL")
                                                                .font(.system(size: 14, weight: .bold))
                                                                .foregroundStyle(Color(AppColors.invertYellow.rawValue))
                                                        }
                                                        ///if unit is in percentage
                                                        else {
                                                            Text(String(format:"%.2f",thisFuelEntry.percent) + " %")
                                                                .font(.system(size: 14, weight: .bold))
                                                                .foregroundStyle(Color(AppColors.invertYellow.rawValue))
                                                        }
                                                    }
                                                    Spacer()
                                                    ///fuel cost
                                                    VStack {
                                                        Text("Cost")
                                                            .font(.system(size: 10, weight: .semibold))
                                                            .foregroundStyle(bgMode == .dark ? Color(UIColor.systemGray2) : Color(UIColor.darkGray))
                                                        Text("$" + String(format:"%.2f",thisFuelEntry.cost))
                                                            .font(.system(size: 14, weight: .bold))
                                                            .foregroundStyle(Color(AppColors.invertOrange.rawValue))
                                                    }
                                                }
                                                Spacer()
                                                ///trip summary
                                                HStack {
                                                    Text("Trip Summary")
                                                        .font(.system(size: 10, weight: .semibold))
                                                        .foregroundStyle(bgMode == .dark ? Color(UIColor.systemGray2) : Color(UIColor.darkGray))
                                                    ///if distance unit is in km
                                                    if thisSettings.getDistanceUnit == "km" {
                                                        Text(String(format:"%.2f",thisFuelEntry.lasttrip) + " km")
                                                            .font(.system(size: 14, weight: .bold))
                                                            .foregroundStyle(Color(AppColors.invertSky.rawValue))
                                                    }
                                                    ///if distance unit is in miles
                                                    else {
                                                        Text(String(format:"%.2f",thisFuelEntry.lastTripMiles) + " miles")
                                                            .font(.system(size: 14, weight: .bold))
                                                            .foregroundStyle(Color(AppColors.invertSky.rawValue))
                                                    }
                                                }
                                                Spacer()
                                                ///time stamp at a moment it was updated.
                                                Text("updated on: " + thisFuelEntry.getTimeStamp)
                                                    .font(.system(size: 8))
                                                    .foregroundStyle(bgMode == .dark ? Color(UIColor.systemGray2) : Color(UIColor.darkGray))
                                            }
                                            .padding(.vertical, 5)
                                        })
                                    }
                                    
                                }
                                ///on deletion
                                .onDelete { indexSet in
                                    guard let vehicleIndex = vehicles.firstIndex(of: vehicle) else {
                                        return
                                    }
                                    print("fuel mode is: \(fuelMode)")
                                    ///iterate through the indexsets where indexset will be single item array having the index of a selected list item.
                                    var calendarYear: Int?
                                    ///local variable to calulate and store accumulated fuel volume
                                    var accumulatedFuelVolume = 0.0
                                    ///local variable to calulate and store accumulated trip
                                    var accumulatedTrip = 0.0
                                    var amount = 0.0
                                    guard let i = Array(indexSet).first else {
                                        return
                                    }
                                    print("vehicle: ", vehicles[vehicleIndex].getVehicleText)
                                    
                                    ///get the fuelling entry at a given index.
                                    let thisfuellingEntry = vehicle.getFuellings.filter({$0.fuelType == fuelMode})[i]
                                    
                                    print("fuel type:", thisfuellingEntry.fuelType ?? "n/a")
                                    print(thisfuellingEntry.location ?? "n/a")
                                    print(thisfuellingEntry.cost)
                                    print(thisfuellingEntry.lasttrip)
                                    ///remove this entry from fuellings entity of a given vehicle
                                    if thisfuellingEntry.fuelType == fuelMode {
                                        vehicles[vehicleIndex].removeFromFuellings(thisfuellingEntry)
                                        calendarYear = thisfuellingEntry.getYearFromDate
                                        ///subtract the fuel cost of this entry from the total fuel cost.
                                        vehicles[vehicleIndex].fuelCost -= thisfuellingEntry.cost
                                        amount = thisfuellingEntry.percent
                                      
                                        ///save changes
                                        Vehicle.saveContext(viewContext: viewContext)
                                    }
                                    ///iterate through fuellings records of a vehicle entiry filtered by fuel mode (gas or ev).
                                    for fuelling in vehicle.getFuellings.filter({$0.fuelType == fuelMode}) {
                                        ///if fuel volume unit is in litre
                                        if thisSettings.getFuelVolumeUnit == "Litre" {
                                            ///calculate the accumulated fuel volume in litre
                                            accumulatedFuelVolume += fuelling.litre != 0 ? fuelling.litre : fuelling.getVolumeLitre
                                        }
                                        ///if fuel volume unit is in gallon
                                        else if thisSettings.getFuelVolumeUnit == "Gallon" {
                                            ///calculate the accumulated fuel volume in gallon
                                            accumulatedFuelVolume += fuelling.gallon != 0 ? fuelling.gallon : fuelling.getVolumeGallons
                                        }
                                        ///if fuel volume unit is in percentage
                                        else {
                                            ///calculate the accumulated fuel volume in form of amount of battery changed in %
                                            accumulatedFuelVolume += (vehicle.batteryCapacity * fuelling.percent)/100
                                        }
                                        ///if the distance unit is set to km
                                        if thisSettings.getDistanceUnit == "km" {
                                            ///calculate the accumulated vehicle trip in km
                                            accumulatedTrip += fuelling.lasttrip != 0 ? fuelling.lasttrip : fuelling.getLastTripKm
                                        }
                                        else {
                                            ///calculate the accumulated vehicle trip in miles
                                            accumulatedTrip += fuelling.lastTripMiles != 0 ? fuelling.lastTripMiles : fuelling.getLastTripMiles
                                        }
                                    }
                                    guard let year = calendarYear else {
                                        return
                                    }
                                    AutoSummary.accumulateFuellingsAndTravelSummary(viewContext: viewContext, in: thisSettings, for: vehicle, year: year, cost: vehicle.fuelCost, amount: amount)
                                    ///calculate the fuel efficiency by dividing accumulated trip by fuel volume.
                                    vehicles[vehicleIndex].fuelEfficiency = accumulatedTrip/accumulatedFuelVolume
                                    ///save changes.
                                    Vehicle.saveContext(viewContext: viewContext)
                                }
                            }
                        }
                    }
                   
                }
            }
            .navigationTitle("Fuelling History")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    func getString(from : Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
       return formatter.string(from: from)
 
    }
}

#Preview {
    FuelHistoryView(showFuelHistoryView: .constant(false), vehicle: Vehicle())
}
