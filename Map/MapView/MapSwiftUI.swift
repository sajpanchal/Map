//
//  MapView.swift
//  Map
//
//  Created by saj panchal on 2023-08-03.
//

import SwiftUI
import MapKit

///this view will observe the LocationDataManager and updates the MapViewController if data in Location Manager changes.
struct Map: View {
    @FetchRequest(entity: Settings.entity(), sortDescriptors:[]) var settings: FetchedResults<Settings>
    @FetchRequest(entity: Vehicle.entity(), sortDescriptors:[]) var vehicles: FetchedResults<Vehicle>
    
    @Environment(\.managedObjectContext) private var viewContext
    ////environment variable to get the color mode of the phone
    @Environment(\.colorScheme) var bgMode: ColorScheme
    ///this will make our MapView update if any @published value in location manager changes.
    @StateObject var locationDataManager: LocationDataManager
    @StateObject var speechViewModel = SpeechViewModel()
    /// this variable is used to store the status of our mapview. it is bound to our MapView file
    @State private var mapViewStatus: MapViewStatus = .idle
    ///this variable is used to store the actions inputted by the user by tapping buttons or other gestures to mapView
    @State private var mapViewAction: MapViewAction = .idle
    ///enum type variable declaration
    @State private var mapError: Errors = .noError
    ///state variable for searchable text field to search for nearby locations in the map region
    @State private var searchedLocationText: String = ""
    ///state variable to store the current instruction to display in the directions view.
    @State private var instruction: String = ""
    @State private var nextInstruction: String = ""
    ///sending this variable to other swiftui views such as MapView and MapInterationView.
    @State private var nextStepLocation: CLLocation?
    ///localSearch object is instantiated on rendering this view.
    @StateObject var localSearch: LocalSearch
    ///state variable storing the next step distance to be displayed in the directions view.
    @State private var nextStepDistance: String = ""
    ///variable to show the selected route's travel time.
    @State private var routeTravelTime: String = ""
    ///array of RouteData
    @State private var routeData: [RouteData] = []
    ///variable to show the selected route's distance.
    @State private var routeDistance: String = ""
    ///variable to show the distance remaining from the destination while in navigation.
    @State private var remainingDistance: String = ""
    ///variable to show the destination address in the expanded view.
    @State private var destination = ""
    ///flag to show/hide the directions list view.
    @State private var showDirectionsList = false
    ///binding this variable of array type to ExpendedDirectionsView.
    @State private var stepInstructions: [(String, String)] = []
    ///binding thi variable that diplays the arrival time to the destination.
    @State private var ETA: String = ""
    ///flag used to show/hide greetings view.
    @State private var showGreetings: Bool = false
    ///flag used to determine if the routeSelection is tapped or not.
    @State private var isRouteSelectTapped: Bool = false
    @State private var tappedAnnoation: MKAnnotation?
    @State private var timer = Timer.publish(every: 5, on: .main, in: .common).autoconnect()
    @State private var timeInterval = true

    var body: some View {
 
            ///ZStack is going to render swiftUI views in Z axis (i.e. from bottom to top)
                ZStack {
                ///grouping mapview and its associated buttons
                    Group() {
                    ///calling our custom struct that will render UIView for us in swiftui. we are passing the user coordinates that we have accessed from CLLocationManager in our locationDataManager class. we are also passing the state variable called tapped that is bound to the MapView.when any state property is passed to a binding property of its child component, it must be wrapped using $ symbol in prefix. we always declare a binding propery in a child component of the associated property from its parent.once the value is bound, a child component can read and write that value and any changes will be reflected in parent side.
                        MapView(mapViewAction: $mapViewAction, mapError: $mapError, mapViewStatus: $mapViewStatus,  instruction: $instruction, nextInstruction: $nextInstruction, localSearch: localSearch, locationDataManager: locationDataManager, nextStepLocation: $nextStepLocation, nextStepDistance: $nextStepDistance, routeTravelTime: $routeTravelTime, routeData: $routeData,  routeDistance: $routeDistance, remainingDistance: $remainingDistance, destination: $destination, stepInstructions: $stepInstructions, ETA: $ETA, showGreetings: $showGreetings, isRouteSelectTapped: $isRouteSelectTapped, tappedAnnotation: $tappedAnnoation, timeInterval: $timeInterval)
                            .onReceive(timer, perform: { time in
                                timeInterval.toggle()
                                
                            })
                    ///disable the mapview when track location button is tapped but tracking is not on yet.
                            .disabled(isMapViewWaiting(to: .navigate, for: mapViewStatus, in: mapViewAction))
                    ///gesture is a view modifier that can call various intefaces such as DragGesture() to detect the user touch-drag gesture on a given view. each inteface as certain actions to perform. such as onChanged() or onEnded(). Here, drag gesture has onChanged() action that has an associated value holding various data such as location cooridates of starting and ending of touch-drag. we are passing a custom function as a name to onChanged() it will be executed on every change in drag action data. in this
                            .simultaneousGesture(DragGesture().onChanged(dragGestureAction).onEnded(dragGestureAction))
                    }
                    .opacity(isMapViewWaiting(to: .navigate, for: mapViewStatus, in: mapViewAction) ? 0.3 : 1.0)
                    if !isMapInNavigationMode(for: mapViewStatus).0 || isMapViewWaiting(to: .navigate, for: mapViewStatus, in: mapViewAction) {
                        VStack(spacing: 0) {
                                SearchFieldView(searchedLocationText: $searchedLocationText, region: locationDataManager.region, localSearch: localSearch)
                                    .padding(.top, 10)
                                    .background(bgMode == .dark ? Color.black : Color.white)
                                ///if search results are avialable, show them in the listview on top of everything in zstack view.
                                if !$localSearch.results.isEmpty && localSearch.status != .localSearchCancelled && localSearch.status != .locationSelected && localSearch.status != .showingNearbyLocations  {
                                    AddressListView(localSearch: localSearch, searchedLocationText: $searchedLocationText)
                                }
                                else if localSearch.status == .localSearchInProgress && $localSearch.results.isEmpty {
                                     SearchProgressView()
                                }
                                else if localSearch.status == .localSearchFailed {
                                   NetworkAlertView()
                                }
                            Spacer()
                        }
                        
                    }
                    else if isMapInNavigationMode(for: mapViewStatus).0  {
                        DirectionsView(instruction: $instruction, nextStepDistance: $nextStepDistance, showDirectionsList: $showDirectionsList, nextInstruction: $nextInstruction, stepInstructions: $stepInstructions, locationDataManager: locationDataManager, speechViewModel: speechViewModel)
                    }
                    if showGreetings {
                        GreetingsView(showGreetings: $showGreetings, destination: $destination)
                    }
                ///if mapview is not navigating but user has asked to navigate we will show a progessview to make user wait to complete the process.
                    if isMapViewWaiting(to: .navigate, for: mapViewStatus, in: mapViewAction) {
                        MapProgressView(alertMessage: "Starting Tracking location! Please Wait...")
                    }
                ///if mapview is waiting to center to the userlocation on button tap
                    else if isMapViewWaiting(to: .centerToUserLocation, for: mapViewStatus, in: mapViewAction) {
                    ///show the progressview with a given string message
                        MapProgressView(alertMessage: "Centering Map to your location! Please Wait...")
                    }
                ///if the mapview is waiting to get in idle mode
                    else if isMapViewWaiting(to: .idle, for: mapViewStatus, in: mapViewAction) {
                        MapProgressView(alertMessage: "Stopping Tracking location! Please Wait...")
                    }
                    else if isMapViewWaiting(to: .showDirections, for: mapViewStatus, in: mapViewAction) {
                        MapProgressView(alertMessage: "Routing directions! Please Wait...")
                    }
                    if !showDirectionsList {
                        ///this view is reponsible to show the map interation buttons and the bottom stack with route info and navigation related buttons on top of MapView.
                        MapInteractionsView(mapViewStatus: $mapViewStatus, mapViewAction: $mapViewAction, locationDataManager: locationDataManager, localSearch: localSearch, speechViewModel: speechViewModel, destination: destination, routeTravelTime: $routeTravelTime, routeData: $routeData, routeDistance: $routeDistance, remainingDistance: remainingDistance, instruction: $instruction, nextStepLocation: $nextStepLocation, stepInstructions: $stepInstructions, ETA: $ETA, isRouteSelectTapped: $isRouteSelectTapped, tappedAnnotation: $tappedAnnoation)
                    }
            }
                .onAppear {
                    print("Settings Length: ", settings.count)
//                    if let vehicle = vehicles.first {
//                        viewContext.delete(vehicle)
//                        
//                    }
//                    if let setting = settings.first {
//                        viewContext.delete(setting)
//                    }
//                    Vehicle.saveContext(viewContext: viewContext)
//                   
                    for setting in settings {
                        print(setting.vehicle?.getVehicleText ?? "n/a")
                        print(setting.autoEngineType ?? "n/a")
                    }
                    print("--------------------------")

                    guard let newVehicle = vehicles.first(where: {$0.isActive}) else {
                        print("no active vehicle")
                        return
                    }
                    print("------------Vehicle Added--------------")
                    print("Name: ",newVehicle.getVehicleText)
                    print("trip: ",newVehicle.trip)
                    print("trip miles: ",newVehicle.tripMiles)
                    print("fuel mode: ",newVehicle.fuelMode ?? "n/a")
                    print("trip EV: ",newVehicle.tripHybridEV)
                    print("trip EV miles: ",newVehicle.tripHybridEVMiles)
                    print("odometer: ",newVehicle.odometer)
                    print("odometer Miles: ",newVehicle.odometerMiles)
                    print("battery: ",newVehicle.batteryCapacity)
                    print("fuel engine: ",newVehicle.fuelEngine ?? "n/a")
                    print("is active: ",newVehicle.isActive)
                    print("odometer Miles: ",newVehicle.year)
                    print("------------Vehicle Settings--------------")
                    print(newVehicle.settings ?? "n/a")
                    print("------------Vehicle Summary--------------")
                    print("summary count: ",newVehicle.getReports.count)
                    print("summary count: ",newVehicle.getReports.first?.annualTrip ?? "n/a")
                
                    
                    
                    guard let thisSettings = newVehicle.settings  else {
                    return
                    }
                    if let thisDistanceUnit = DistanceUnit(rawValue: thisSettings.getDistanceUnit) {
                        MapViewAPI.distanceUnit = thisDistanceUnit
                    }
                       
                    print("Vehicle: ", thisSettings.vehicle ?? "n/a")
                    print("Distance Unit: ",(thisSettings.getDistanceUnit))
                    print("fuel Unit: \(thisSettings.getFuelVolumeUnit)")
                    print("Engine type: \(thisSettings.getAutoEngineType)")
                    print("fuel Mode: ", (thisSettings.vehicle?.getFuelMode) ?? "n/a")
                    MapViewAPI.avoidHighways = thisSettings.avoidHighways
                    MapViewAPI.avoidTolls = thisSettings.avoidTolls
                    print("OnAppear()")
                    print("avoid tolls: \( MapViewAPI.avoidTolls)")
                    print("avoid highways: \( MapViewAPI.avoidHighways)")
                }
}
    ///custom function takes the DragGesture value. custom function we calculate the distance of the drag from 2D cooridinates of starting and ennding points. then we check if the distance is more than 10. if so, we undo the user-location re-center button tap.
    func dragGestureAction(value: DragGesture.Value) {
        ///get the distance of the user drag in x direction by measuring a difference between starting point and ending point in x direction
        let x = abs(value.location.x - value.startLocation.x)
        ///get the distance of the user drag in y direction by measuring a difference between starting point and ending point in y direction
        let y = abs(value.location.y - value.startLocation.y)
        ///measure the distance of the drag in 2D space.
        let distance = sqrt((x*x)+(y*y))
        ///if the drag distance is more than 10.0 update the mapview status
        if distance > 10 {
            ///if map navigation is on and user dragged mapview
            if isMapInNavigationMode(for: mapViewStatus).0 {
                ///set the status that map is not centered in navigation mode.
                mapViewStatus = .inNavigationNotCentered
                ///make map to perform idleInNavigation action.
                mapViewAction = .idleInNavigation
               
            }
            ///if map is showing directions and if map is not centered.
            else if mapViewStatus == .showingDirections || mapViewStatus == .showingDirectionsNotCentered {
                ///keep the map be in idle while showing directions
                mapViewAction = .idleInshowDirections
            }
            ///if map is not navigating or showing directions
            else {
                ///set the status to not centered
                mapViewStatus = .notCentered
                ///make map to go in idle mode
                mapViewAction = .idle
            }
        }
    }  

}

struct Map_Previews: PreviewProvider {
    static var previews: some View {
        Map(locationDataManager: LocationDataManager(), localSearch: LocalSearch())
    }
}


