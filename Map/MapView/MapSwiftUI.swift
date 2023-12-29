//
//  MapView.swift
//  Map
//
//  Created by saj panchal on 2023-08-03.
//

import SwiftUI
import MapKit
//import AudioToolbox
//import AVFoundation

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
    @State var instruction: String = ""
    @State var nextStepLocation: CLLocation?
    @StateObject var localSearch = LocalSearch()
    @State var status: String = "-"
    @State var nextStepDistance: String = ""
    @State var routeTravelTime: String = ""
    @State var routeDistance: String = ""
    @State var remainingDistance: String = ""
    @State var destination = ""
    @State var showSheet = false
    @State var showDirectionsList = false
    @State var stepInstructions: [(String, Double)] = []
   // let synthesizer = AVSpeechSynthesizer()
    var body: some View {
        VStack {
        ///ZStack is going to render swiftUI views in Z axis (i.e. from bottom to top)
            if !isMapInNavigationMode(for: mapViewStatus).0 || isMapViewWaiting(to: .navigate, for: mapViewStatus, in: mapViewAction) {
                SearchFieldView(searchedLocationText: $searchedLocationText, region: locationDataManager.region, localSearch: localSearch)
                    .padding(.top, 10)
                    .background(.black)
                Spacer()
            }
            else if isMapInNavigationMode(for: mapViewStatus).0  {
                DirectionsView(directionSign: getDirectionSign(for: instruction), nextStepDistance: nextStepDistance, instruction: instruction, showDirectionsList: $showDirectionsList)
                  
                //Spacer()
            }
            ZStack {
            ///grouping mapview and its associated buttons
                Group() {
                ///calling our custom struct that will render UIView for us in swiftui. we are passing the user coordinates that we have accessed from CLLocationManager in our locationDataManager class. we are also passing the state variable called tapped that is bound to the MapView.when any state property is passed to a binding property of its child component, it must be wrapped using $ symbol in prefix. we always declare a binding propery in a child component of the associated property from its parent.once the value is bound, a child component can read and write that value and any changes will be reflected in parent side.
                    MapView(mapViewAction: $mapViewAction, mapError: $mapError, mapViewStatus: $mapViewStatus,  instruction: $instruction, localSearch: localSearch, locationDataManager: locationDataManager, nextStepLocation: $nextStepLocation, nextStepDistance: $nextStepDistance, routeTravelTime: $routeTravelTime, routeDistance: $routeDistance, remainingDistance: $remainingDistance, destination: $destination, stepInstructions: $stepInstructions)
                ///disable the mapview when track location button is tapped but tracking is not on yet.
                        .disabled(isMapViewWaiting(to: .navigate, for: mapViewStatus, in: mapViewAction))
                ///gesture is a view modifier that can call various intefaces such as DragGesture() to detect the user touch-drag gesture on a given view. each inteface as certain actions to perform. such as onChanged() or onEnded(). Here, drag gesture has onChanged() action that has an associated value holding various data such as location cooridates of starting and ending of touch-drag. we are passing a custom function as a name to onChanged() it will be executed on every change in drag action data. in this
                    .gesture(DragGesture().onChanged(dragGestureAction))
                }
                .opacity(isMapViewWaiting(to: .navigate, for: mapViewStatus, in: mapViewAction) ? 0.3 : 1.0)
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
                
              //  if localSearch.tappedLocation != nil {
                //navigation mode button to switch between navigation modes.
                MapInteractionsView(mapViewStatus: $mapViewStatus, mapViewAction: $mapViewAction, showSheet: $showSheet, locationDataManager: locationDataManager, localSearch: localSearch, destination: destination, routeTravelTime: $routeTravelTime, routeDistance: $routeDistance, remainingDistance: remainingDistance, instruction: $instruction, nextStepLocation: $nextStepLocation, stepInstructions: $stepInstructions)
                    if showDirectionsList {
                        ExpandedDirectionsView(stepInstructions: stepInstructions,  showDirectionsList: $showDirectionsList)
                    }
             //   }
                
                if !$localSearch.results.isEmpty {
                    ListView(localSearch: localSearch, searchedLocationText: $searchedLocationText)
                }
        }
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
                mapViewStatus = .inNavigationNotCentered
                mapViewAction = .idleInNavigation
            }
            else if mapViewStatus == .showingDirections || mapViewStatus == .showingDirectionsNotCentered {
                mapViewAction = .idleInshowDirections
               }
            else {
                mapViewStatus = .notCentered
                mapViewAction = .idle
            }
            
        }
        print("map is out of center: \(mapViewStatus)")
    }
        
  
//    func speech() {
//        if instruction.isEmpty {
//            return
//        }
//        let audioSession = AVAudioSession.sharedInstance()
//        do {
//            try audioSession.setCategory(AVAudioSession.Category.playback, options: AVAudioSession.CategoryOptions.mixWithOthers)
//        
//        }
//        catch {
//            print("error:\(error.localizedDescription)")
//        }
//            
//        let speech = "in \(nextStepDistance)," + instruction
//        synthesizer.speak(AVSpeechUtterance(string: speech))
//    }
}

struct Map_Previews: PreviewProvider {
    static var previews: some View {
        Map()
    }
}


