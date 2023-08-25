//
//  MapView.swift
//  Map
//
//  Created by saj panchal on 2023-08-03.
//

import SwiftUI
import MapKit

//this view will observe the LocationDataManager and updates the MapViewController if data in Location
//Manager changes.
struct Map: View {
    ///this will make our MapView update if any @published value in location manager changes.
    @StateObject var locationDataManager = LocationDataManager()
    /// this variable is used to store the status of our mapview. it is bound to our MapView file
    @State var mapViewStatus: MapViewStatus = .idle
    ///this variable is used to store the actions inputted by the user by tapping buttons or other gestures to mapView
    @State var mapViewAction: MapViewAction = .idle
    ///enum type variable declaration
    @State var mapError: Errors = .noError
    ///state variable for searchable text field to search for nearby locations in the map region
    @State var searchedLocationText: String = ""
    
    @State var isLocationSelected: Bool = false
    
    @StateObject var localSearch = LocalSearch()
    
    @State var isSearchCancelled: Bool = false
    
    var body: some View {
            VStack {
                SearchFieldView(searchedLocationText: $searchedLocationText, isSearchCancelled: $isSearchCancelled, isLocationSelected: $isLocationSelected, region: locationDataManager.region, localSearch: localSearch)
                ///ZStack is going to render swiftUI views in Z axis (i.e. from bottom to top)
                ZStack {
                    ///grouping mapview and its associated buttons
                    Group() {
                        ///calling our custom struct that will render UIView for us in swiftui. we are passing the user coordinates that we have accessed from CLLocationManager in our locationDataManager class. we are also passing the state variable called tapped that is bound to the MapView.when any state property is passed to a binding property of its child component, it must be wrapped using $ symbol in prefix. we always declare a binding propery in a child component of the associated property from its parent.once the value is bound, a child component can read and write that value and any changes will be reflected in parent side.
                        MapView(location: $locationDataManager.userlocation,mapViewAction: $mapViewAction, heading: $locationDataManager.userHeading, mapError: $mapError, mapViewStatus: $mapViewStatus)
                        ///disable the mapview when track location button is tapped but tracking is not on yet.
                            .disabled(isMapViewWaiting(to: .navigate))
                        ///gesture is a view modifier that can call various intefaces such as DragGesture() to detect the user touch-drag gesture on a given view. each inteface as certain actions to perform. such as onChanged() or onEnded(). Here, drag gesture has onChanged() action that has an associated value holding various data such as location cooridates of starting and ending of touch-drag. we are passing a custom function as a name to onChanged() it will be executed on every change in drag action data. in this
                            .gesture(DragGesture().onChanged(dragGestureAction))
                        ///custom buttons that is floating on our mapview. if map is navigating but it is not centered to user location show the location button to center it on tap.
                        if isMapInNavigationMode().0 && isMapInNavigationMode().1 == .inNavigationNotCentered {
                            MapViewButton(imageName: "location.fill")
                                .gesture(TapGesture().onEnded(centerMapToUserLocation))
                        }
                        ///if map is not navigating show the circle button to center the map to user location whenever tapped.
                        if !isMapInNavigationMode().0 {
                            MapViewButton(imageName: mapViewStatus == .centeredToUserLocation ? "circle.fill" : "circle")
                                .gesture(TapGesture().onEnded(centerMapToUserLocation))
                        }
                    }
                    .opacity(isMapViewWaiting(to: .navigate) ? 0.3 : 1.0)
                    
                    ///if mapview is not navigating but user has asked to navigate we will show a progessview to make user wait to complete the process.
                    if isMapViewWaiting(to: .navigate) {
                        MapProgressView(alertMessage: "Starting Tracking location! Please Wait...")                       
                    }
                    ///if mapview is waiting to center to the userlocation on button tap
                    else if isMapViewWaiting(to: .centerToUserLocation) {
                        ///show the progressview with a given string message
                        MapProgressView(alertMessage: "Centering Map to your location! Please Wait...")
                    }
                    ///if the mapview is waiting to get in idle mode
                    else if isMapViewWaiting(to: .idle) {
                        MapProgressView(alertMessage: "Stopping Tracking location! Please Wait...")
                    }
                    if !localSearch.searchedLocations.isEmpty {
                        ListView(localSearch: localSearch, searchedLocationText: $searchedLocationText, isLocationSelected: $isLocationSelected)
                    }
                }
                //navigation mode button to switch between navigation modes.
                Button(isMapInNavigationMode().0 ? "Stop location Tracking" : "Start Location Tracking", action: updateUserTracking)
                .foregroundColor(isMapInNavigationMode().0 ? .red : .blue)
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
            if isMapInNavigationMode().0 {
                mapViewStatus = .inNavigationNotCentered
                mapViewAction = .idleInNavigation
            }
            else {
                mapViewStatus = .notCentered
                mapViewAction = .idle
            }
            
        }
    }
    //a function to be called whenever the re-center icon on the mapView is tapped.
    func centerMapToUserLocation() {
        mapViewAction = isMapInNavigationMode().0 ? .inNavigationCenterToUserLocation : .centerToUserLocation
    }
    
    func isMapInNavigationMode() -> (Bool,MapViewStatus) {
        switch mapViewStatus {
        case .idle, .notCentered, .centeredToUserLocation:
            return (false,mapViewStatus)
        case .navigating, .inNavigationCentered, .inNavigationNotCentered:
            return (true,mapViewStatus)
        }
    }
    
    func updateUserTracking() {
        ///set mapViewAction to idle mode if status is navigating when button is pressed set mapViewAction to nagivate if status is not navigating when button is pressed.
        switch mapViewStatus {
        case .idle, .notCentered, .centeredToUserLocation:
            mapViewAction = .navigate
            ///UIApplocation is the class that has a centralized control over the app. it has a property called shared that is a singleton instance of UIApplication itself. this instance has a property called isIdleTimerDisabled. which will decide if we want to turn off the phone screen after certain amount of time of inactivity in the app. we will set it to true so it will keep the screen alive when user tracking is on.
            UIApplication.shared.isIdleTimerDisabled = true
            break
        case .navigating, .inNavigationCentered, .inNavigationNotCentered:
            mapViewAction = .idle
            UIApplication.shared.isIdleTimerDisabled = false
            break
        }
    }
    
    func isMapViewWaiting(to action: MapViewAction) -> Bool {
        switch action {
        case .navigate:
            return (mapViewStatus != .navigating && mapViewAction == .navigate)
        case .centerToUserLocation:
            return (mapViewStatus != .centeredToUserLocation && mapViewAction == .centerToUserLocation)
        case .inNavigationCenterToUserLocation:
            return (mapViewStatus != .inNavigationCentered && mapViewAction == .inNavigationCenterToUserLocation)
        case .idle:
            return (isMapInNavigationMode().0 && mapViewAction == .idle)
        case .idleInNavigation:
            return (mapViewStatus != .inNavigationNotCentered && mapViewAction == .idleInNavigation)
        
        }
    }
    
  
   
}





struct Map_Previews: PreviewProvider {
    static var previews: some View {
        Map()
    }
}


