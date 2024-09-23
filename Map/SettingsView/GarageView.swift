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
    @State var vehicleTitle = ""
    ///binding flag to show/hide garageView.
    @Binding var showGarage: Bool
    var colors = [AppColors.invertRed.rawValue, AppColors.invertGreen.rawValue,AppColors.invertSky.rawValue,AppColors.invertYellow.rawValue, AppColors.invertPurple.rawValue, AppColors.invertOrange.rawValue]

    var body: some View {
        NavigationStack {
            ///show list of vehicles with its title and manufacturing year
            if let thisSettings = settings.first {
                List {
                    ForEach(vehicles, id: \.uniqueID) { thisVehicle in
                        NavigationLink(destination: UpdateVehicleView(locationDataManager: locationDataManager, showGarage: $showGarage, settings: thisSettings, vehicle: thisVehicle), label: {
                            VStack {
                                Text(thisVehicle.getVehicleText + " " + thisVehicle.getFuelEngine)
                                    .fontWeight(.bold)
                                    .font(Font.system(size: 18))
                                    .foregroundStyle(Color(colors[vehicles.firstIndex(where: {$0 == thisVehicle}) ?? 0]))
                                Text(thisVehicle.getYear)
                                    .fontWeight(.semibold)
                                    .font(Font.system(size: 14))
                                    .foregroundStyle(Color.gray)
                            }
                     })
                    }
                    ///on swipe left delete the given vehicle from the list
                    .onDelete(perform: { indexSet in
                        ///here indexSet is a set of indexes that to be deleted. in our case it will be only an array of one element.
                        for i in indexSet {
                            ///get the vehicle at a given indexset.
                            let vehicle = vehicles[i]
                            ///delete the vehicle from the viewcontext.
                            viewContext.delete(vehicle)
                            ///save the changes made to viewcontext in the core data store.
                            Vehicle.saveContext(viewContext: viewContext)
                        }
                    })
                }
                .onAppear(perform: {
                    print("garage view")
                })
                .padding(.top,20)
                .navigationTitle("Your Auto Garage")
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
}

#Preview {
    GarageView(locationDataManager: LocationDataManager(), showGarage: .constant(false))
}
