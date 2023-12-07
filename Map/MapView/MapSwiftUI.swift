//
//  MapView.swift
//  Map
//
//  Created by saj panchal on 2023-08-03.
//

import SwiftUI
import MapKit
import AudioToolbox
import AVFoundation

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
    @State var instruction: String = ""
    @State var nextStepLocation: CLLocation?
    @StateObject var localSearch = LocalSearch()
    @State var status: String = "-"
    @State var isSearchCancelled: Bool = false
    @State var nextStepDistance: String = ""
    @State var routeETA: String = ""
    @State var routeDistance: String = ""
    @State var distance: String = ""
    @State var destination = ""
    @State var showSheet = false
   // let synthesizer = AVSpeechSynthesizer()
    var body: some View {
            VStack {
                if !isMapInNavigationMode().0 || isMapViewWaiting(to: .navigate) {
                    SearchFieldView(searchedLocationText: $searchedLocationText, isSearchCancelled: $isSearchCancelled, isLocationSelected: $isLocationSelected, region: locationDataManager.region, localSearch: localSearch)
                }
                else if isMapInNavigationMode().0  {
                    HStack {
                        VStack {
                            Image(systemName: getDirectionSign(for: instruction))
                                .font(.title)
                                .fontWeight(.black)
                                .padding(.top, 5)
                            Text("\(nextStepDistance)")
                                .padding(.bottom, 5)
                                .font(.title2)
                                .fontWeight(.black)
                            
                        }
                        Spacer()
                        if #available(iOS 17.0, *) {
                        Text(instruction)
                            .padding(10)
                            .font(.title3)
                          //  .onAppear(perform: speech)
                           // .onChange(of: instruction, speech)
                            } else {
                                Text(instruction)
                                    .padding(10)
                                    .font(.title3)
                            }
                           
                        Spacer()
                    }
                  
                }
                ///ZStack is going to render swiftUI views in Z axis (i.e. from bottom to top)
                ZStack {
                    ///grouping mapview and its associated buttons
                    Group() {
                        ///calling our custom struct that will render UIView for us in swiftui. we are passing the user coordinates that we have accessed from CLLocationManager in our locationDataManager class. we are also passing the state variable called tapped that is bound to the MapView.when any state property is passed to a binding property of its child component, it must be wrapped using $ symbol in prefix. we always declare a binding propery in a child component of the associated property from its parent.once the value is bound, a child component can read and write that value and any changes will be reflected in parent side.
                        MapView(mapViewAction: $mapViewAction, mapError: $mapError, mapViewStatus: $mapViewStatus, isLocationSelected: $isLocationSelected, isSearchCancelled: $isSearchCancelled, instruction: $instruction, localSearch: localSearch, locationDataManager: locationDataManager, nextStepLocation: $nextStepLocation, nextStepDistance: $nextStepDistance, status: $status, routeETA: $routeETA, routeDistance: $routeDistance, distance: $distance, destination: $destination)
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
                        if !isMapInNavigationMode().0 && mapViewStatus != .showingDirections {
                            MapViewButton(imageName: mapViewStatus == .centeredToUserLocation ? "circle.fill" : "circle")
                                .gesture(TapGesture().onEnded(centerMapToUserLocation))
                        }
                    }
                    .opacity(isMapViewWaiting(to: .navigate) ? 0.3 : 1.0)
                    
                    ///if mapview is not navigating but user has asked to navigate we will show a progessview to make user wait to complete the process.
                    if isMapViewWaiting(to: .navigate) {
                       // MapProgressView(alertMessage: "Starting Tracking location! Please Wait...")                       
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
                    else if isMapViewWaiting(to: .showDirections) {
                        MapProgressView(alertMessage: "Routing directions! Please Wait...")
                    }
                    if !localSearch.searchedLocations.isEmpty {
                        ListView(localSearch: localSearch, searchedLocationText: $searchedLocationText, isLocationSelected: $isLocationSelected)
                    }
                }
                if localSearch.tappedLocation != nil {
                    //navigation mode button to switch between navigation modes.
                    VStack {
                        if mapViewStatus == .navigating {
                            HStack {
                                Spacer()
                                Rectangle()
                                    .frame(width: 60, height: 5)
                                    .cornerRadius(5)
                                Spacer()
                            }
                            .padding(1)
                            
                            .onTapGesture {
                                withAnimation {
                                    showSheet.toggle()
                                }
                                
                            }
                            if showSheet {
                                HStack {
                                    VStack {
                                        Text("Heading to destination")
                                            .font(.caption2)
                                            .fontWeight(.bold)
                                        Text(destination)
                                            .font(.caption2)
                                            .multilineTextAlignment(.center)
                                    }
                                   
                                }
                                .onTapGesture {
                                    withAnimation {
                                        showSheet.toggle()
                                    }
                                    
                                }
                               
                            }
                        
                       
                        }
                          
                        HStack {
                            if mapViewStatus != .navigating {
                                Button(action: { mapViewAction = .showDirections; locationDataManager.throughfare = nil },
                                       label: {
                                                Text("Routes")
                                                    .frame(height: 60)
                                                   
                                                    .foregroundStyle(.white)
                                        }
                                )
                               
                                .background(Color.blue)
                                .cornerRadius(10)
                            }
                            Spacer()
                            VStack {
                                if mapViewStatus == .showingDirections {
                                    Text(routeETA)
                                    Text(routeDistance)
                                }
                                else if mapViewStatus == .navigating {
                                    Text(distance)
                                        .font(.title2)
                                        .fontWeight(.black)
                                    Text("Remaining")
                                }
                                
                            }
                            Spacer()
                            if mapViewStatus == .showingDirections || mapViewStatus == .navigating {
                                Button(action: updateUserTracking, label: {
                                    isMapInNavigationMode().0 ? 
                                        Text("Stop")
                                            .frame(height: 60)
                                            .foregroundStyle(.white) : 
                                        Text("Navigate")
                                            .frame(height: 60)
                                            .foregroundStyle(.white)
                                })
                                .background(isMapInNavigationMode().0 ? .red : .blue)
                                .cornerRadius(10)
                            }
                          
                        }
                        
                      
                       
                    }
                 
               
                  
                }
            
            }
    }
    ///custom function takes the DragGesture value. custom function we calculate the distance of the drag from 2D cooridinates of starting and ennding points. then we check if the distance is more than 10. if so, we undo the user-location re-center button tap.
    func dragGestureAction(value: DragGesture.Value) {
        if mapViewStatus == .showingDirections {
            return
        }
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
            if isLocationSelected {
                isLocationSelected = false
            }
        }
        print("map is out of center: \(mapViewStatus)")
    }
    //a function to be called whenever the re-center icon on the mapView is tapped.
    func centerMapToUserLocation() {
        mapViewAction = isMapInNavigationMode().0 ? .inNavigationCenterToUserLocation : .centerToUserLocation
    }
    
    func isMapInNavigationMode() -> (Bool,MapViewStatus) {
        switch mapViewStatus {
        case .idle, .notCentered, .centeredToUserLocation, .showingDirections:
            return (false,mapViewStatus)
        case .navigating, .inNavigationCentered, .inNavigationNotCentered:
            return (true,mapViewStatus)
        }
    }
    
    func updateUserTracking() {
        print("user navigation tracking is available.")
        ///set mapViewAction to idle mode if status is navigating when button is pressed set mapViewAction to nagivate if status is not navigating when button is pressed.
        switch mapViewStatus {
        case .idle, .notCentered, .centeredToUserLocation, .showingDirections:
            locationDataManager.distance = 0.0
            mapViewAction = .navigate
            ///UIApplocation is the class that has a centralized control over the app. it has a property called shared that is a singleton instance of UIApplication itself. this instance has a property called isIdleTimerDisabled. which will decide if we want to turn off the phone screen after certain amount of time of inactivity in the app. we will set it to true so it will keep the screen alive when user tracking is on.
            UIApplication.shared.isIdleTimerDisabled = true
            break
        case .navigating, .inNavigationCentered, .inNavigationNotCentered:
            mapViewAction = .idle
            instruction = ""
            nextStepLocation = nil
            UIApplication.shared.isIdleTimerDisabled = false
            break
        }
    }
    func getDirectionSign(for: String) -> String {
        let instruction = instruction.lowercased()
        if instruction.contains("turn left") {
            return "arrow.turn.up.left"
        }
        else if instruction.contains("turn right")
        {
            return "arrow.turn.up.right"
        }
        else if instruction.contains("slight left") {
            return "arrow.turn.left.up"
        }
        else if instruction.contains("slight right") {
            return "arrow.turn.right.up"
        }
        else if instruction.contains("keep right") {
            return "rectangle.righthalf.inset.filled.arrow.right"
        }
        else if instruction.contains("keep left") {
            return "rectangle.lefthalf.inset.filled.arrow.left"
        }
        else if instruction.contains("continue") {
            return "arrow.up"
        }
        else if instruction.contains("first exit") {
            return "1.circle"
        }
        else if instruction.contains("second exit") {
            return "2.circle"
        }
        else if instruction.contains("third exit") {
            return "3.circle"
        }
        else if instruction.contains("make a u-turn"){
            return "arrow.uturn.down"
        }
        else if instruction.contains("fourth exit") {
         return "4.circle"
        }
        else if instruction.contains("exit") {
            return "arrow.up.right"
        }
        else if instruction.contains("starting at")
        {
            return "location.north.line"
        }
        else if instruction.contains("arrive") || instruction.contains("arrived") {
            return "mappin.and.ellipse"
        }
        else if instruction.contains("destination") {
            return "mappin.and.ellipse"
        }
        return ""
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
        case .showDirections:
            return (mapViewStatus != .showingDirections && mapViewAction == .showDirections)
        
        }
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


