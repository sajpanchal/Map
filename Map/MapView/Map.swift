//
//  MapView.swift
//  Map
//
//  Created by saj panchal on 2023-08-03.
//

import SwiftUI
//this view will observe the LocationDataManager and updates the MapViewController if data in Location
//Manager changes.
struct Map: View {
    //this will make our MapView update if any @published value in location manager changes.
    @StateObject var locationDataManager = LocationDataManager()
    //this is a state variable that will let mapview object know if the track location btn is pressed.
    enum MapViewStatus {
        case navigating
        case centeredToUserLocation
        case inNavigationCentered
        case notCentered
        case inNavigationNotCentered
        case idle
    }
    enum MapViewAction {
        case navigate
        case centerToUserLocation
        case inNavigationCenterToUserLocation
        case idle
    }
    @State var mapViewStatus: MapViewStatus = .idle
    
    @State var mapViewAction: MapViewAction = .idle
    //enumeration type definition to handle error. it conforms to Error protocol so we can access error description
    enum Errors: String {
        case locationNotFound = "Sorry, your current location not found!"
        case headingNotFound = "Sorry, your current heading not found!"
        case locationNotVisible = "Sorry, your current location is not able to display on map!"
        case unKnownError = "Sorry, unknown error has occured!"
        case noError = " -- "
    }
    //enum type variable declaration
    @State var mapError: Errors = .noError
    
    var body: some View {
        VStack {
            //just a text field to detect error.
            Text("Errors: \(mapError.rawValue)")
                .padding(3)
            //calling our custom struct that will render UIView for us in swiftui.
            //we are passing the user coordinates that we have accessed from CLLocationManager in our locationDataManager class.
            //we are also passing the state variable called tapped that is bound to the MapView.
            //when any state property is passed to a binding property of its child component, it must be wrapped using $ symbol in prefix.
            //we always declare a binding propery in a child component of the associated property from its parent.
            //once the value is bound, a child component can read and write that value and any changes will be reflected in parent side.
            ZStack {
                MapView(location: $locationDataManager.userlocation,mapViewAction: $mapViewAction, heading: $locationDataManager.userHeading, mapError: $mapError, mapViewStatus: $mapViewStatus)
                //disable the mapview when track location button is tapped but tracking is not on yet.
                    .disabled(mapViewStatus != .navigating && mapViewAction == .navigate)
                //gesture is a view modifier that can call various intefaces such as DragGesture() to detect the user touch-drag gesture on a
                //given view. each inteface as certain actions to perform. such as onChanged() or onEnded(). Here, drag gesture has onChanged()
                //action that has an associated value holding various data such as location cooridates of starting and ending of touch-drag.
                //we are passing a custom function as a name to onChanged() it will be executed on every change in drag action data. in this
                    .gesture(DragGesture().onChanged(dragGestureAction))
                //this is the button to start tracking the user location. when it is tapped, MapView will start tracking the user location by
                //instantiating the mapView camera with its associated properties.
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        MapViewButton(imageName: mapViewStatus == .centeredToUserLocation ? "location.fill" : "location")
                            .gesture(TapGesture()
                                .onEnded(centerMapToUserLocation))                                                            
                    }
                    .padding(10)
                }
                .padding(20)
            }
      
            Button((mapViewStatus != .navigating && mapViewAction == .navigate) ? "Please Wait..." : "Track Location", action: {
                //set trackLocation variable to true
                mapViewAction = .navigate
                //UIApplocation is the class that has a centralized control over the app.
                //it has a property called shared that is a singleton instance of UIApplication itself.
                //this instance has a property called isIdleTimerDisabled.
                //which will decide if we want to turn off the phone screen after certain amount of time of inactivity in the app.
                //we will set it to true so it will keep the screen alive when user tracking is on.
                UIApplication.shared.isIdleTimerDisabled = true
                
            })
            .foregroundColor(mapViewAction == .navigate ? .gray : .blue)
            //disable this button while the location tracking is on.
            .disabled(mapViewAction == .navigate)
        }
        
        
    }
    //custom function takes the DragGesture value.
    //custom function we calculate the distance of the drag from 2D cooridinates of starting and ennding points. then we check if the distance
    //is more than 10. if so, we undo the user-location re-center button tap.
    func dragGestureAction(value: DragGesture.Value) {
        let x = abs(value.location.x - value.startLocation.x)
        let y = abs(value.location.y - value.startLocation.y)
        let distance = sqrt((x*x)+(y*y))
        if distance > 10 {
            //turn off the tracking
            mapViewStatus = .notCentered
            mapViewAction = .idle
            //enable the idle Timer.
            UIApplication.shared.isIdleTimerDisabled = false
        }
    }
    //a function to be called whenever the re-center icon on the mapView is tapped.
    func centerMapToUserLocation() {
        mapViewAction = .centerToUserLocation
    }
}



struct Map_Previews: PreviewProvider {
    static var previews: some View {
        Map()
    }
}

struct MapViewButton: View {
    var imageName: String = ""
    var body: some View {
            ZStack {
                Rectangle()
                    .frame(width: 60, height: 60)
                    .foregroundColor(.gray)
                    .cornerRadius(10)
                Image(systemName: imageName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 35, height: 35)
                    .foregroundColor(.white)
            }
    }
}
