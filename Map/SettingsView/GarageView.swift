//
//  GarageView.swift
//  Map
//
//  Created by saj panchal on 2024-07-17.
//

import SwiftUI

struct GarageView: View {
    ///fetchrequest to get the records for vehicle entity sorted by vehicles not active first.
    @FetchRequest(entity:Vehicle.entity(), sortDescriptors:[NSSortDescriptor(keyPath: \Vehicle.isActive, ascending: false)]) var vehicles: FetchedResults<Vehicle>
    ///fetchrequest to get the settings entity records from the core data store.
    @FetchRequest(entity:Settings.entity(), sortDescriptors:[]) var settings: FetchedResults<Settings>
    ///environment object that gets the managedObjectContext of the core data stack.
    @Environment(\.managedObjectContext) private var viewContext
    ///location manager state object
    @StateObject var locationDataManager: LocationDataManager
    ///vehicle title state variable
    @State private var vehicleTitle = ""
    ///binding flag to show/hide garageView.
    @Binding var showGarage: Bool
    ///state variable to show or hide alert on deletion of any active vehicle
    @State private var showAlert = false
    var colors = [AppColors.invertRed.rawValue, AppColors.invertGreen.rawValue,AppColors.invertSky.rawValue,AppColors.invertYellow.rawValue, AppColors.invertPurple.rawValue, AppColors.invertOrange.rawValue, AppColors.invertGryColor.rawValue]

    var body: some View {
        NavigationStack {
            ///show list of vehicles with its title and manufacturing year
            if let activeVehicles = vehicles.first(where: {$0.isActive}) {
                if let thisSettings = activeVehicles.settings {
                    List {
                        ForEach(vehicles, id: \.uniqueID) { thisVehicle in
                            NavigationLink(destination: UpdateVehicleView(locationDataManager: locationDataManager, showGarage: $showGarage, settings: thisSettings, vehicle: thisVehicle), label: {
                                VStack {
                                    Text(thisVehicle.getVehicleText + " " + (thisVehicle.getFuelEngine != "Gas" ? thisVehicle.getFuelEngine : ""))
                                        .fontWeight(.bold)
                                        .font(Font.system(size: 18))
                                        .foregroundStyle(Color(colors[getColorIndex(for: vehicles.firstIndex(where: {$0 == thisVehicle}) ?? 0)]))
                                }
                         })
                        }
                       
                        ///on swipe left delete the given vehicle from the list
                        .onDelete(perform: { indexSet in
                            ///here indexSet is a set of indexes that to be deleted. in our case it will be only an array of one element.
                            for i in indexSet {
                                ///get the vehicle at a given indexset.
                                let vehicle = vehicles[i]
                               
                                if vehicles.first(where: {$0.isActive}) != vehicle {
                                    ///delete the vehicle from the viewcontext.
                                    viewContext.delete(vehicle)
                                    if let settings = settings.first(where: {$0.vehicle == vehicle}) {
                                        viewContext.delete(settings)
                                    }
                                  
                                    ///save the changes made to viewcontext in the core data store.
                                    Vehicle.saveContext(viewContext: viewContext)
                                }
                                else {
                                    showAlert = true
                                }
                              
                            }
                        })
                    }
                    .alert(isPresented: $showAlert) {
                        Alert(title: Text("Can't delete this Vehicle"), message: Text("Active vehicle can't be deleted! Please change the active vehicle first to delete this vehicle."), dismissButton: .default(Text("Okay")))
                    }
                    .padding(.top,20)
                    .navigationTitle("Your Auto Garage")
                    .navigationBarTitleDisplayMode(.inline)
                }
            }
          
            ///if settings object is found nil
            else {
                ///show error text.
                HStack {
                    Spacer()
                    Text("Something went wrong!")
                        .font(.headline)
                        .foregroundStyle(.gray)
                    Spacer()
                }
                .padding(40)
            }
        }
    }
    func getColorIndex(for index: Int) -> Int {
        var updatedIndex = index
        if index < colors.count {
            return index
        }
        else if index - colors.count >= colors.count {
            updatedIndex = getColorIndex(for: index - colors.count)
        }
        else {
            return  index - colors.count
        }
        return updatedIndex
        
    }
}

#Preview {
    GarageView(locationDataManager: LocationDataManager(), showGarage: .constant(false))
}
