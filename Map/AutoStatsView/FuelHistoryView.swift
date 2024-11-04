//
//  FuelHistoryView.swift
//  Map
//
//  Created by saj panchal on 2024-06-20.
//

import SwiftUI

struct FuelHistoryView: View {
    @FetchRequest(entity: Settings.entity(), sortDescriptors:[]) var settings: FetchedResults<Settings>
    @Environment(\.colorScheme) var bgMode: ColorScheme
    @Environment(\.managedObjectContext) private var viewContext
    @Binding var showFuelHistoryView: Bool
    var vehicle: Vehicle
    var body: some View {
        NavigationStack {
            List {
                ///get the fuel mode (gas or ev) from the saved settings for a selected vehicle.
                if let fuelMode = settings.first?.vehicle?.fuelMode {
                    ///iterate through the vehicle fuelling entries filtred by fuel mode (uniquely identified by its uniqueID) and display them in a list of navigation links.
                    ForEach(vehicle.getFuellings.filter({$0.fuelType == fuelMode}), id:\.self.uniqueID) { thisFuelEntry in
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
                                        if settings.first!.fuelVolumeUnit == "Litre" {
                                            Text(String(format:"%.2f",thisFuelEntry.litre) + " L")
                                                .font(.system(size: 14, weight: .bold))
                                                .foregroundStyle(Color(AppColors.invertYellow.rawValue))
                                        }
                                        ///if unit is in gallon
                                        else if settings.first!.fuelVolumeUnit == "Gallon"  {
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
                                    if settings.first!.getDistanceUnit == "km" {
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
                    ///on deletion
                    .onDelete { indexSet in
                        ///iterate through the indexsets where indexset will be single item array having the index of a selected list item.
                        for i in indexSet {
                            ///get the fuelling entry at a given index.
                            let thisfuellingEntry = vehicle.getFuellings[i]
                            ///remove this entry from fuellings entity of a given vehicle
                            vehicle.removeFromFuellings(thisfuellingEntry)
                            ///subtract the fuel cost of this entry from the total fuel cost.
                            vehicle.fuelCost -= thisfuellingEntry.cost
                            ///save changes
                            Vehicle.saveContext(viewContext: viewContext)
                        }
                        ///local variable to calulate and store accumulated fuel volume
                        var accumulatedFuelVolume = 0.0
                        ///local variable to calulate and store accumulated trip
                        var accumulatedTrip = 0.0
                        ///iterate through fuellings records of a vehicle entiry filtered by fuel mode (gas or ev).
                        for fuelling in vehicle.getFuellings.filter({$0.fuelType == fuelMode}) {
                            ///if fuel volume unit is in litre
                            if settings.first!.getFuelVolumeUnit == "Litre" {
                                ///calculate the accumulated fuel volume in litre
                                accumulatedFuelVolume += fuelling.litre != 0 ? fuelling.litre : fuelling.getVolumeLitre
                            }
                            ///if fuel volume unit is in gallon
                            else if settings.first!.getFuelVolumeUnit == "Gallon" {
                                ///calculate the accumulated fuel volume in gallon
                                accumulatedFuelVolume += fuelling.gallon != 0 ? fuelling.gallon : fuelling.getVolumeGallons
                            }
                            ///if fuel volume unit is in percentage
                            else {
                                ///calculate the accumulated fuel volume in form of amount of battery changed in %
                                accumulatedFuelVolume += (vehicle.batteryCapacity * fuelling.percent)/100
                            }
                            ///if the distance unit is set to km
                            if settings.first!.getDistanceUnit == "km" {
                                ///calculate the accumulated vehicle trip in km
                                accumulatedTrip += fuelling.lasttrip != 0 ? fuelling.lasttrip : fuelling.getLastTripKm
                            }
                            else {
                                ///calculate the accumulated vehicle trip in miles
                                accumulatedTrip += fuelling.lastTripMiles != 0 ? fuelling.lastTripMiles : fuelling.getLastTripMiles
                            }
                        }
                        ///calculate the fuel efficiency by dividing accumulated trip by fuel volume.
                        vehicle.fuelEfficiency = accumulatedTrip/accumulatedFuelVolume
                        ///save changes.
                        Vehicle.saveContext(viewContext: viewContext)
                    }
                }
            }
            .navigationTitle("Fuelling History")
        }
    }
}

#Preview {
    FuelHistoryView(showFuelHistoryView: .constant(false), vehicle: Vehicle())
}
