//
//  MapViewAPI.swift
//  Map
//
//  Created by saj panchal on 2023-08-19.
//

import Foundation
import MapKit

class MapViewAPI {
    ///static prop to extract an array of route received from directions request.
    static var routes: [MKRoute] = []
    ///next index of the step in route's steps array elements
    static var nextIndex = 0
    static var nextInstructionIndex = 0
    ///array to detect if the given step has points fetched by the function call or not.
    static var isStepPointsFetched: [Bool] = []
    ///an array stores the MKMapPoints of each steps.
    static var points: [UnsafeMutablePointer<MKMapPoint>] = []
    ///MKMapPoint of user location
    static var userPoint:MKMapPoint?
    ///length of points array
    static var length: [Int] = []
    ///points array of points
    static var pointsArray: [UnsafeBufferPointer<MKMapPoint>] = []
    ///variable that stores Estimated Time of Arrival in a string format
    static var ETA: String?
    ///variable that stores the remaining distance from the destination
    static var remainingDistance: CLLocationDistance?
    ///change in distance travelled by user towards the next Step Location
    static var changeInStepDistance: Double?
    ///previously recoded distance from next step location
    static var previousStepDistance: Double?
    ///storing thoroughfare in text format
    static var thoroughfare: String = ""
    ///flag to determine if user is out of route or not.
    static var isUserOutofRoute: Bool = false
    ///flag to determine if path is out of camera of the map.
    static var isUserOutofPath: Bool = false
    ///flag to determine if the MKDirections request is completed successully with overlays rendered in the map.
    static var isRoutesrequestProcessed: Bool = false
    ///array to store the rendered route polyline points at a given step.
    static var polylinePoints: [PolylinePoint] = []
    ///flag to determine if the rerouting was already performed.
    static var reRouted = false
    ///static variable to store the distance unit.
    static var distanceUnit: DistanceUnit = .km
    ///static variable to show whether user prefers to avoid highways or not
    static var avoidHighways: Bool = false
    ///static variable to show whether user prefers to avoid tolls or not
    static var avoidTolls: Bool = false
    ///static variable to show whether request failed to show any routes.
    static var noRoutesFound: Bool = false
    ///this method will accept the mapView, userLocation class instances. here mapView struct instance as inout parameter. inout parameter allows us to make func parameter mutable i.e. we can change the value of the parameter in a function directly and changes will be reflected outside the function after execution.
    static func setRegionIn(mapView: MKMapView, centeredAt userLocation: MKUserLocation, parent: inout MapView) {
        ///when this function will be called for the very first time, the region property of our mapView struct will be nil.
        ///so the code inside this if statement will be executed only one time.
        guard parent.region != nil else {
            ///dispatchqueue is a class that handles the execution of tasks serially or concurrently on apps main/background threads.here we are using a main (serial queue) thread and executing a code inside the block asynchronously in it. that means the main thread is not going to wait until this code is executed and it will perform remaining tasks serially.
            DispatchQueue.main.async {
                ///set the mapView region centered to user location with 1000 meters of visible region around it.
                mapView.region = MKCoordinateRegion(center: userLocation.coordinate, latitudinalMeters: 1000, longitudinalMeters: 1000)
            }
                ///assign this region to our parent region.
                parent.region = mapView.region
            return
        }
    }
    
    ///this method is used for instantiating map camera and configuring the same
    static func setCameraRegion(of mapView: MKMapView, centeredAt userLocation: MKUserLocation, userHeading: CLHeading?, animated: Bool, distance: CLLocationDistance) {
        guard let heading = userHeading else {
            ///instantiate the MKMapCamera object with center as user location, distance (camera zooming to center), pitch(camera angle) and camera heading set to user heading relative to  true north of camera.
            return
        }
        ///instantiate the camera with center to user location and following its heading directions.
        let camera = MKMapCamera(lookingAtCenter: userLocation.coordinate, fromDistance: distance, pitch: 40, heading: heading.magneticHeading)
        print(camera.centerCoordinateDistance)
      
        DispatchQueue.main.async {
            ///set the mapview camera to our defined object.
            mapView.setCamera(camera, animated: animated)
            mapView.showsScale = true
        }
    }
    ///method to get the mapView camera distance from mapview based on device speed
    static func getCameraDistanceFromMapView(atSpeed speed: Int) -> CLLocationDistance {
        ///create a core location distance (in meters) variable with 600 meter set as inital value
        var distance: CLLocationDistance = 600
        ///switch case statement
        switch speed {
            /// if speed is between 0-50
        case 0...50:
            ///set the distance to 600
            distance = 600
            /// if speed is between 41-60
        case 51...60:
            ///set the distance to 800
            distance = 800
            /// if speed is between 61-80
        case 61...80:
            ///set the distance to 1000
            distance = 1000
            /// if speed is between 81-120
        case 81...120:
            ///set the distance to 2000
            distance = 2000
            /// if speed is above 120
        default:
            ///set the distance to 2000
            distance = 2000
        }
        return distance
    }
    ///function to untrack user location
    static func resetLocationTracking(of mapView: MKMapView, parent: inout MapView) {
        ///clear the instruction field that displays next step instruction on the DirectionsView.
        parent.instruction = ""
        ///empty out the routeData array.
        parent.routeData = []
        ///make tapped annotation nil
        parent.tappedAnnotation = nil
        ///empty the array that displays entire list of step instructions in the DirectionsView's expanded view
        parent.stepInstructions.removeAll()
        ///set the distance prop on locationdatamanager to nil on reset. distance field is used to showing remaining distance
//        if parent.locationDataManager.remainingDistance != nil {
//            parent.locationDataManager.remainingDistance = nil
//        }
        ///reset the properties of this instance class
        resetProps()
        DispatchQueue.main.async {
            ///undoing user tracking to none.
            mapView.setUserTrackingMode(.none, animated: true)
        }
    }
   
    ///function to annotate a location the user has searched in the search bar.
    static func annotateLocation(in mapView: MKMapView ,at coordinates: CLLocationCoordinate2D, for annotation: MKAnnotation) {
        ///add the search location received from UIViewRepresentable (mapview) as a second mapview annotation.       
        guard mapView.annotations.contains(where: {$0.coordinate.latitude != annotation.coordinate.latitude && $0.coordinate.longitude != annotation.coordinate.longitude}) else {
            return
        }
        mapView.addAnnotation(annotation)
        ///check if the mapview centered to the searched location or not
        if mapView.centerCoordinate.latitude != annotation.coordinate.latitude && mapView.centerCoordinate.longitude != annotation.coordinate.longitude {
            ///if not centred, centre the mapview to searched location.
            mapView.animatedZoom(zoomRegion: MKCoordinateRegion(center: annotation.coordinate, latitudinalMeters: 1000, longitudinalMeters: 1000), duration: TimeInterval(0.1))
        }
    }
    static func annotateLocations(in mapView: MKMapView ,at coordinates: CLLocationCoordinate2D, for annotation: MKAnnotation) {
        ///add the search location received from UIViewRepresentable (mapview) as a second mapview annotation.
        mapView.addAnnotation(annotation)
        ///check if the mapview centered to the searched location or not
        
        mapView.animatedZoom(zoomRegion: MKCoordinateRegion(center: mapView.userLocation.coordinate, latitudinalMeters: 10000, longitudinalMeters: 10000), duration: TimeInterval(0.1))
        
    }
    
    ///this function will send the route directions request between the two locations annotated in the mapview
    static func getNavigationDirections(in uiView: MKMapView, from source: CLLocationCoordinate2D, to destination: CLLocationCoordinate2D?) {
        ///if there are no overlays associated with the mapview return the function call.
        if !uiView.overlays.isEmpty {
            return
        }
        
        ///initially set the flag to false before requesting the directions
        isRoutesrequestProcessed = false
        ///create an instance of MKDirections request to request the directions.
        let request = MKDirections.Request()
        ///if distination is not nil
        guard let destination = destination else {
        return
        }
        print("GetDirections()")
        print("avoid tolls: \(avoidTolls)")
        print("avoid highways: \(avoidHighways)")
        print("-----------------------")
        ///set the source point of request as a placemark of user location
        request.source = MKMapItem(placemark: MKPlacemark(coordinate: source))
        ///set the destination of the request as a placemark of searched location
        request.destination = MKMapItem(placemark: MKPlacemark(coordinate: destination))
        ///set the request for alternate routes between 2 places to true to get more than one routes.
        request.requestsAlternateRoutes = true
        ///set the highway preference for the direction request based on the user's preference.
        request.highwayPreference = avoidHighways ? .avoid : .any
        ///set the toll preference for the direction request based on the user's preference.
        request.tollPreference = avoidTolls ? .avoid : .any
        print("request toll:\(request.tollPreference.rawValue)")
        ///set the transport type as automobile as default.
        request.transportType = .automobile
        ///create a directions object from our request now.
        let directions = MKDirections(request: request)
        ///async function to calculate the routes from information provided by request object of directions object.
        directions.calculate(completionHandler: { (response, error) in
            ///if response is received
            guard let response = response else {
                return
            }
            ///remove all overalys from mapview.
             uiView.removeOverlays(uiView.overlays)
            ///sort the routes recieved from the response with longer travel time first.
            var sortedRoutes = response.routes.sorted(by: {
                $0.expectedTravelTime > $1.expectedTravelTime
            })
            ///if avoiding tolls
            if avoidTolls {
                ///remove all routes that have tolls.
                sortedRoutes.removeAll(where: {$0.hasTolls})
            }
            ///if avoiding highways
            if avoidHighways {
                ///remove all routes that have highways.
                sortedRoutes.removeAll(where: {$0.hasHighways})
            }
            ///set the routes property of MapViewAPI with sorted routes
            routes = sortedRoutes
            ///create a variable to store the array size.
            var index = sortedRoutes.count
            ///iterate through the sorted routes.
            for route in sortedRoutes {
                ///get the polyline object from current route
                let polyline = route.polyline
                index -= 1
                let title = polyline.title
                polyline.title = "\(Int(route.expectedTravelTime/60)), \(title ?? "n/a"), \(UUID()), \(String(format:"%.1f",route.distance/1000.0))"
                ///if this is the last route it must be having a shortest travel time
                if index == 0 {
                    ///set the polyline subtitle as fastest route to identify it in later uses.
                    polyline.subtitle = "fastest route"
                }
                ///add the polyline received from the route as an overlay to be displayed in mapview.
               uiView.addOverlay(polyline)
            }
            
            if let thisOverlay = uiView.overlays.first {
                uiView.setVisibleMapRect(thisOverlay.boundingMapRect, edgePadding: UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5), animated: true)
                ///set the flag at the end of the request executions
                  isRoutesrequestProcessed = true
                print("Direction request complete")
            }
            
       
        })
    }
    
    ///method used for starting map navigation and updating the related components based on location updates.
    static func startNavigation(in mapView: MKMapView, parent: inout MapView)   {
        ///empty out the routeData array.
        parent.routeData = []
        ///set the flag being used to determine if the any of the routes were tapped.
        parent.isRouteSelectTapped = false
        ///if a given instruction contains word destination
        let trimmedDest = parent.destination.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedInst = parent.instruction.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmedDest.contains(trimmedInst) {
            ///if userlocation and next stepLocation is available
            if let userLocation = mapView.userLocation.location, let stepLocation = parent.nextStepLocation {
              
                ///if the distance between user and next step is less than 5 m.
                if userLocation.distance(from: stepLocation) <= 10 {
                    ///show the greeting message
                    parent.showGreetings = true
                    ///make suggested locations array nil
                    parent.localSearch.suggestedLocations = nil
                    ///make mapview action to go in idle mode.
                    parent.mapViewAction = .idle
                    ///keep the destination selected pinned to map.
                    parent.localSearch.status = .locationSelected
                    ///remove all the instructions from the array that shows them in a listview.
                    parent.stepInstructions.removeAll()
                    ///clear the instruction text
                    parent.instruction = ""
                    ///make the next step location nil
                    parent.nextStepLocation = nil
                    ///reseting the remainingDistance to nil
//                    parent.locationDataManager.remainingDistance = nil
                    ///enable the idelTimer used to trigger the screen sleep time once user has arrived to the destination
                    UIApplication.shared.isIdleTimerDisabled = false
                    ///make sure that map action is to center to the userlocation to exit the navigation mod.e
                    parent.mapViewAction = .centerToUserLocation
                    ///execute the resetLocationTracking method to peform the idle mode.
                    resetLocationTracking(of: mapView, parent: &parent)
                    return
                }
            }
        }
        ///redundantly setting up mapview status to navigating mode to make sure no misteps.
        parent.mapViewStatus = .navigating
        ///method that will get the ETA to the given destintion coordinates.
        guard let targetLocation = parent.tappedAnnotation != nil ? parent.tappedAnnotation : parent.localSearch.suggestedLocations?.first else {
          return
        }
        if parent.tappedAnnotation != nil {
            
        }
      
        if parent.timeInterval == true {
            getETA(to: targetLocation.coordinate, in: &parent, with: mapView)
        }
      
        ///if there is any route available then get the first one otherwise exit the fuction.
        guard let route = getSelectedRoute(for: mapView) else {
            if !noRoutesFound {
                parent.instruction = "Re-calculating the route..."
                return
            }
            if avoidHighways {
                parent.instruction = "No routes available! Seems like you are already on highway or there are only highway available and you have preferences to avoid them! Try changing your preferences."
              
            }
            if avoidTolls {
                parent.instruction = "No routes available! Seems like you are already on toll route or there are only toll routes available and you have preferences to avoid them! Try changing your preferences."
            }
            else if avoidTolls && avoidHighways {
                parent.instruction = "No routes available! Seems like you are already on highway or toll route ,or there are only toll routes available and you have preferences to avoid them! Try changing your preferences."
            }
            else {
                parent.instruction = "No routes available! Please search again!"
            }
            print("no routes selected!")
           
            return
        }
        ///if stepinstructions array is empty
        if parent.stepInstructions.isEmpty {
            ///iterate through all the steps in a given route
            for step in route.steps {
                ///skip the appending if instruction is empty
                if !step.instructions.isEmpty {
                    ///format the distance in string with a given distance unit annotation.
                    let formattedDistance = distanceUnit == .miles ? convertToMiles(from: step.distance) : getFormattedDistance(from: step.distance)
                    ///append the instruction string and distance from current step to that step for which the instruction is being displayed to our array.
                    parent.stepInstructions.append((step.instructions, formattedDistance))
                }
            }
        }
        var ETA = ""
        if route.expectedTravelTime < 3600 {
            ETA =  String(format:"%.0f",(route.expectedTravelTime/60)) + " mins"
        }
        else {
            var mins = (route.expectedTravelTime)/60.0
            let hr = (mins/60)
            mins = mins.truncatingRemainder(dividingBy: 60)
            ETA = String(format:"%.0f", hr) + " hr" + " " + String(format:"%.0f", mins) + " mins"
        }
        /// set routeETA field with expected travel time extracted from a given route.
        parent.routeTravelTime = ETA
        ///initiating props on first execution
        initiateProps(route: route, parent: &parent)
        ///format the remaining distance to be displayed in km/ meters or miles/ft
        ///if remainingDistance is available
        if let distance = remainingDistance {
            ///if the distance unit is in miles
            if distanceUnit == .miles {
                ///convert the distance to miles with string formated text and distance unit symbol
                parent.remainingDistance = convertToMilesETA(from: distance)
            }
            else {
                ///if distance is less than 1000 m
                if distance < 1000 {
                    ///show the distance in meters format
                    parent.remainingDistance = String(format:"%.0f", distance) + " m"
                }
                ///if distance is more than or equal to 1000 m
                else {
                    ///show the distance in km format.
                    parent.remainingDistance = String(format:"%.1f", Double(distance/1000.0)) + " km"
                }
            }
        }
                
        ///set the destination field of mapview struct
        parent.destination = (targetLocation.title ?? "") ?? ""
        ///setting the routeDistance property with km/miles format for display
        parent.routeDistance = distanceUnit == .miles ? convertToMiles(from: route.distance) : String(format:"%.1f",Double(route.distance/1000.0)) + " km"
        ///iterate through the route steps
        for step in route.steps {
      
            ///get the index of the given step and if it is found continue...
            guard let stepIndex = route.steps.firstIndex(of: step) else {
                return
            }
            ///set the user location as user point to calculate distance from step polyline points.
            userPoint = MKMapPoint(mapView.userLocation.coordinate)
            ///if array isStepPointsFetched going out of index, add a new element to the last index.
            while isStepPointsFetched.count <= stepIndex {
                isStepPointsFetched.append(false)
            }
            ///if for the given step index, array element is FALSE (i.e. is not fetched) update the props of the class instance
            if !isStepPointsFetched[stepIndex] && isStepPointsFetched.count > stepIndex {
                ///update the props for a given step at a given index.
                updateProps(for: step, at: stepIndex, mapView: mapView)
            }
            ///if userpoint is not nil
            guard let userPoint = userPoint, let userLocation = mapView.userLocation.location else {
                return
            }
            ///get the step location
            let stepLocation = CLLocation(latitude: step.polyline.coordinate.latitude, longitude: step.polyline.coordinate.longitude)
            ///if the user location is 50 m or more from this step and yet it is not set exited and it is the starting point update to the step 1 instructions only
            if userLocation.distance(from: stepLocation) >= 20 && step.polyline.subtitle != "regionExited" && stepIndex == 0 {
                ///label the current step as exited by user.
                step.polyline.subtitle = "regionExited"
                ///get the first step and its index
                if let firstStep = route.steps.first(where: {!$0.instructions.isEmpty}), let firstIndex = route.steps.firstIndex(of: firstStep) {
                    ///update the step instructions
                    updateStepInstructions(step: firstStep, instruction: firstStep.instructions, parent: &parent, stepIndex: firstIndex, mapView: mapView)
                    updateNextStepInstruction(parent: &parent, route: route, at: firstIndex)
                
                }
               
            }
            ///if the user location is near 15 m of any of the given step points, update to that step instructions and make nextIndex set to the next step index.
            if nextIndex == stepIndex && pointsArray[stepIndex].contains(where: { $0.distance(to: userPoint) < 10})  {
                if let routePolylineText = route.polyline.title?.split(separator: ", "), step.instructions == "" {
                    
                    if routePolylineText.count >= 2 {
                        let streetName = routePolylineText[1]
                        if streetName == "-" || streetName == "n/a" {
                            thoroughfare = "Starting at \(parent.locationDataManager.throughfare ?? "your location")"
                           
                        }
                        else {
                            ///initate the instruction for the first step to be displayed with the current location street name and the next one.
                            thoroughfare = "Starting at \(parent.locationDataManager.throughfare ?? "your location") towards \(streetName)"
                           
                        }
                    }
                    
                }
                ///update the step instructions for display
                updateStepInstructions(step: step, instruction: (step.instructions == "" ? thoroughfare : step.instructions), parent: &parent, stepIndex: stepIndex, mapView: mapView)
                updateNextStepInstruction(parent: &parent, route: route, at: stepIndex)
                break
            }
            ///if the expected next step is not found nearby but there is a step point found to be nearby and it wasn't marked as exited
            else if pointsArray[stepIndex].contains(where: {$0.distance(to: userPoint) < 15}) && step.polyline.subtitle != "regionExited" {
                if let routePolylineText = route.polyline.title?.split(separator: ", "), step.instructions == "" {
                    
                    if routePolylineText.count >= 2 {
                        let streetName = routePolylineText[1]
                        if streetName == "-" || streetName == "n/a" {
                            thoroughfare = "Starting at \(parent.locationDataManager.throughfare ?? "your location")"
                           
                        }
                        else {
                            ///initate the instruction for the first step to be displayed with the current location street name and the next one.
                            thoroughfare = "Starting at \(parent.locationDataManager.throughfare ?? "your location") towards \(streetName)"
                        }
                    }
                    
                }
                ///update the step instructions for display
                updateStepInstructions(step: step, instruction: (step.instructions == "" ? thoroughfare : step.instructions), parent: &parent, stepIndex: stepIndex, mapView: mapView)
                updateNextStepInstruction(parent: &parent, route: route, at: stepIndex)

                break
            }
        }
        ///check if the user is out of path or not
        isUserLocationOutOfRoute(in: mapView, for: nextIndex - 1, with: &parent)
         ///now calculate the distance from the next step location to user location
         if let nextStepLocation = parent.nextStepLocation, let userLocation = mapView.userLocation.location {
             calculateDistance(from: nextStepLocation, to: userLocation, parent: &parent)
         }
        ///method that will determine if user is out or route or not.
        isUserLocationOutOfRoute(in: parent)
        /// if user is out of route or thoroughfare
        if isUserOutofRoute {
            ///set the instruction set to be displayed with a warning text.
            parent.instruction = noRoutesFound ? "No routes available! Please change your route preferences if you want more options." : "Re-calculating the route..."
            ///make throroughfare nil
            parent.locationDataManager.throughfare = nil
            ///method to perform re-routing to the current destination.
            if let userLocation = parent.locationDataManager.userlocation {
                reRoutetoDestination(in: mapView, from: userLocation.coordinate, to: targetLocation.coordinate, parent: &parent)
            }
        }
        ///transfer the ETA string to parent that is MapView for the display.
        parent.ETA = self.ETA ?? "--"
        ///update the remainingDistance prop of locationDataManager instance with the latest change.
//        parent.locationDataManager.remainingDistance = (remainingDistance ?? route.distance)/1000
    }
        
    ///function that handles overlay tap events
    static func getTappedOvarlay(in mapView: MKMapView, by tapGestureRecognizer: UITapGestureRecognizer) -> MKOverlay? {
        ///get the tapped location in the mapview as CGPoint format
        let tapLocation = tapGestureRecognizer.location(in: mapView)
        ///canvert the tapped CGPoint to 2D coordinates.
        let tapCoordinates =  mapView.convert(tapLocation, toCoordinateFrom: mapView)
        ///interate through the overlays
        for overlay in mapView.overlays.shuffled() {
            ///get the renderer of a given overaly
            let renderer = mapView.renderer(for: overlay) as! MKPolylineRenderer
            ///convert the tapped coordinates into MKMapPoint format
            let mapPoint = MKMapPoint(tapCoordinates)
            ///return the CGPoint corrosponding to the tapped point
            let rendererPoint = renderer.point(for: mapPoint)
            ///check if the tapped point falls into the render points
            if renderer.path.contains(rendererPoint) {
                ///if yes, set the title as render polyline title.
               return overlay
            }
        }
        return nil
    }
    
    ///method to sort the tapped overlay/route from mapview overlays.
    static func setTappedOverlay(in mapView: MKMapView, having overlay: MKOverlay, parent: inout MapView) {
        ///index of the overlay in mapview overlays array
        var index = 0
        ///counter that will count the iterations of for loop
        var counter = 0
        ///iterate through overlays of mapview
        for thisOverlay in mapView.overlays {
            ///get the renderer object for a given overlay of mapview.
            let renderer = mapView.renderer(for: thisOverlay) as? MKPolylineRenderer
            ///make sure renderer object is not nil
            if let renderer = renderer {
                ///get the title of the render polyline object
                if overlay.isEqual(thisOverlay) {
                    ///set the stroke color to blue
                    renderer.strokeColor = UIColor(skyColor)
                    ///set the transperancy to lowest
                    renderer.alpha = 1
                    ///title of the polyline was set before with route distance and estimated travel time. here routedata will be extracting them and put them separately in an array.
                    let routeData = renderer.polyline.title?.split(separator: ", ") ?? []
                    ///format the travel time and store it in routeTravelTime
                    parent.routeTravelTime = String(routeData.first!) + " mins"
                    ///format the route distance and store it in routeDistance
                    if let dist = routeData.last {
                        ///get the distance string converted to numeric format and get the distance in meters.
                        let number = Double(dist) ?? 0.0 * 100.0
                        ///store the total distance from user to the destination in miles or km.
                        parent.routeDistance = distanceUnit == .miles ? convertToMiles(from: number) : dist + " km"
                    }
                    ///get the index of a given route
                    index = counter
                }
                ///if title of the render is not matching with a requested title
                else {
                    ///make the stroke color gray
                    renderer.strokeColor = .systemGray
                    ///keep the trasparency to 50%
                    renderer.alpha = 0.5
                }
                ///increment the counter
                counter += 1
            }
        }
        ///exchange the overlay with the index that was tapped to the overlay with the last index of an array to make it stand out on top of all.
        mapView.exchangeOverlay(at: index, withOverlayAt: (mapView.overlays.count - 1))
        ///reset the counter on exit from the for loop.
        counter = 0
    }
}

///extension of MapViewAPI class.
extension MapViewAPI {
    ///reset the properties of MapViewAPI
    static func resetProps() {
        isStepPointsFetched.removeAll()
        points = []
        userPoint = nil
        length = []
        pointsArray = []
        nextIndex = 0
        previousStepDistance = nil
        changeInStepDistance = nil
        isUserOutofPath = false
        isUserOutofRoute = false
        nextInstructionIndex = 0
        polylinePoints.removeAll()
        noRoutesFound = false
       
    }
    
    ///method to get the overlay that has been set or tapped.
    static func getSelectedRoute(for mapView: MKMapView) -> MKRoute? {
        ///remove all exept the selected (i.e. first overlay) from map view
        mapView.removeOverlays(mapView.overlays.filter({
            ///filter the array with only those overlays with renderer having 50% transperancy.
            if let renderer = mapView.renderer(for: $0) {
                return renderer.alpha != 1
            }
            else {
                return false
            }
        }))
        ///get the renderer for the given overlay
        guard let overlay = mapView.overlays.first else {
            return nil
        }
        ///get the renderer for a given overlay
        let renderer = MKPolylineRenderer(overlay: overlay)
        ///remove all overlays where the polyline object of the renderer is not the one that the tapped/set route has.
        routes.removeAll(where: {
             !$0.polyline.isEqual(renderer.polyline)
        })
        return routes.first
        
    }
    
    ///method to set the initial values to the properties of MapViewAPI
   static func initiateProps(route: MKRoute ,parent: inout MapView) {
        ///if instruction field is empty, add the initial step instruction
         if parent.instruction.isEmpty {
             ///get the title of the route polyline separated in an array. title is actully the street name from where the route is starting towards destination.
             if let routePolylineText = route.polyline.title?.split(separator: ", ") {
                 
                 if routePolylineText.count >= 2 {
                     let streetName = routePolylineText[1]
                     if streetName == "-" || streetName == "n/a" {
                         thoroughfare = "Starting at \(parent.locationDataManager.throughfare ?? "your location")"
                         parent.instruction = "Starting at \(parent.locationDataManager.throughfare ?? "your location")"
                     }
                     else {
                         ///initate the instruction for the first step to be displayed with the current location street name and the next one.
                         thoroughfare = "Starting at \(parent.locationDataManager.throughfare ?? "your location") towards \(streetName)"
                         parent.instruction = "Starting at \(parent.locationDataManager.throughfare ?? "your location") towards \(streetName)"
                     }
                 }
                 
             }
         }
       
        ///if the nextStep location is not available, get the location of the first step.
         if parent.nextStepLocation == nil {
             ///get the first step from the steps array
             if let firstStep = route.steps.first {
                 ///get the location of the first step
                 parent.nextStepLocation = CLLocation(latitude: firstStep.polyline.coordinate.latitude, longitude: firstStep.polyline.coordinate.longitude)
             }
         }
         ///if the array of stepPointsfetched is empty (i.e. there are no points fetched for any steps)
         if isStepPointsFetched.isEmpty {
             ///set all array element as false
             for _ in route.steps {
                 isStepPointsFetched.append(false)
             }
         }
    }
    
    ///method to update the properties for each step change
    static func updateProps(for step: MKRoute.Step, at stepIndex: Int, mapView: MKMapView) {
        ///get all the points for a given step and add it to the points array
        points.append(step.polyline.points())
        ///get the size of the points and store them in length array
        length.append(step.polyline.pointCount)
        ///get the last set of points from points array and the length of the same.
        if let point = points.last, let length = length.last {
            ///append the set the point and length of the set to points array
            pointsArray.append(UnsafeBufferPointer(start: point, count: length))
        }
        ///set the flag in the array to indicate the points for a given step is already fetched.
        isStepPointsFetched[stepIndex] = true
    }
    
    ///method used for updating the step instructons on change of step.
    static func updateStepInstructions(step: MKRoute.Step, instruction: String, parent: inout MapView, stepIndex: Int, mapView: MKMapView) {
        previousStepDistance = nil
        ///get the next step location
        parent.nextStepLocation = CLLocation(latitude: step.polyline.coordinate.latitude, longitude: step.polyline.coordinate.longitude)
        ///update the swiftui instruction display with the latest instruction received from next step
        parent.instruction = instruction
        nextInstructionIndex = stepIndex + 1
        ///remove the previously exited steps from the step instruction array that displays list of future instruction in expanded view.
        parent.stepInstructions.removeAll(where: { $0.0 == instruction})
        ///mark the step polyline subtitle as region exited.
        nextIndex = stepIndex + 1
        ///mark the current step as region exited.
        step.polyline.subtitle = "regionExited"
        ///flag enable geocoding to false.
        parent.locationDataManager.enableGeocoding = false
        ///remove all the points from an array
        polylinePoints.removeAll()
    }
    static func updateNextStepInstruction(parent: inout MapView, route: MKRoute, at index: Int) {
        var nextInstruction = ""
        nextInstructionIndex = index + 1
        if  nextInstructionIndex < route.steps.count  {
             nextInstruction = route.steps[nextInstructionIndex].instructions
            
        }
        else {
             nextInstruction = ""
        }
        parent.nextInstruction = nextInstruction
    }
    ///method to calculate the distance from userlocation to next step.
    static func calculateDistance(from nextStepLocation:CLLocation, to userLocation: CLLocation, parent: inout MapView) {
        ///get the raw distance from userlocation to next step location
        let nextStepDistance = userLocation.distance(from: nextStepLocation)
        ///divide the step distance by 10 and round up the result from decimal number to integer (near to 0 if less than 0.5 or  away if not) and multiply with 10 to get mutiples of 10.
        let roundedDistance = round(nextStepDistance / 10) * 10.0
        var intNextStepDistance = Int(roundedDistance)
        ///if the distance is less than 15 then set it to 0.
        intNextStepDistance = intNextStepDistance < 10 ? 0 : intNextStepDistance
        if distanceUnit == .miles {
            ///format the distance in miles/ft
            parent.nextStepDistance = convertToMilesETA(from: nextStepDistance)
        }
        else {
            ///format the distance in meters if less than 1000 or in km otherwise.
            parent.nextStepDistance = nextStepDistance < 1000 ? String(intNextStepDistance) + " m" : String(format:"%.1f",(nextStepDistance/1000)) + " km"
        }
        
        if parent.instruction.contains("destination") {
            if let shortAddress = parent.destination.split(separator: ",").first {
                if parent.instruction.contains("destination is on your left") {
                    parent.instruction = String(shortAddress) + "  "
                }
                else if parent.instruction.contains("destination is on your right") {
                        parent.instruction = String(shortAddress) + "   "
                }
                else {
                    parent.instruction =  String(shortAddress) + "    "
                }
            }
            else {
                parent.instruction = parent.destination
            }
        }
    }
    
    ///method that will get the ETA to the given destination
    static func getETA(to destination: CLLocationCoordinate2D, in parent: inout MapView, with mapView: MKMapView) {
        ///create an instance of Request that is a property of MKDirections Object.
        let request = MKDirections.Request()
        ///set the source of the request as the current userlocation
        guard let userLocation =  parent.locationDataManager.userlocation else {
            return
        }
        request.source =  MKMapItem(placemark: MKPlacemark(coordinate: userLocation.coordinate))
        ///set the destination of the request as the destination set by the user
        request.destination = MKMapItem(placemark: MKPlacemark(coordinate: destination))
        ///set the transport type as automobile
        request.transportType = .automobile
        ///create an instance of MKDirections with the configured request object
        let directions = MKDirections(request: request)
        ///once directions request is sent, turn the timer to off to stop sending more getETA reuquests.
        parent.timeInterval = false
        ///async task will execute the code non-sequentially. so if the code inside is taking time if will execute the other code and when the code is having a response it will be executed at that time.
        Task {
            ///call the async method of directions called calculateETA to get the ETA for our request and if response is found store it in reponse constant otherwise return the function call.
            guard let response = try? await directions.calculateETA() else {
                return
            }
           
            ///the following code is enclosed in MainActor.run method which will execute the code in mainactor's (locationmanager(didupdate:) method) thread.
            await MainActor.run {
                ///get the distance from current user location to the destination and store it in remainingDistance
                remainingDistance = response.distance
                ///get the expectedArrivalDate to the destination
                let ETA = response.expectedArrivalDate
                ///create a current user's calender object
                let calender = Calendar.current
                ///call the component method with hour component to return hour component from arrival date object.
                let hour = calender.component(.hour, from: ETA)
                ///format the hour from 24 hr to 12 hr and convert it to string
                var hourStr = hour <= 12 ? String(hour) : String(hour - 12)
                ///if hour is 0 with 12.
                if hour == 0 {
                    ///replace 0 iw
                    hourStr = "12"
                }
                ///call the calender component mehod to get minute component from arrival date.
                let minutes = calender.component(.minute, from: ETA)
                ///format the minutes in  string with 2 digits  number.
                let minutesStr = minutes > 9 ? String(minutes) : "0" + String(minutes)
                ///set the period constant pm if hour is past 11 in the morning otherwise am.
                let period = hour > 11 ? " pm" : " am"
                ///now store the eta in standard 12 hr time format in ETA string.
                self.ETA = hourStr + ":" + minutesStr + period
            }
        }
    }
    
    ///method to determine if user is out of its set route
    static func isUserLocationOutOfRoute(in parent: MapView) {
        ///extract the sub string that is holding the next step distance from the nextStepDistance variable.
        guard let latestStepDistanceString = parent.nextStepDistance.split(separator: " ").first else {
            ///if it is not found set the flag false and return function call.
            isUserOutofRoute = false
            return
        }
        ///convert the string to double and if it is found store it in a latestStepDistance variable
        guard var latestStepDistance = Double(latestStepDistanceString) else {
            ///if it is not found set the flag false and return function call.
            isUserOutofRoute = false
            return
        }
        ///if step distance is in km format, convert it to meters format.
        if distanceUnit == .miles {
            ///convert the latest distance from miles to meters or from ft to meters.
            latestStepDistance = parent.nextStepDistance.split(separator: " ").last == "mi" ? (latestStepDistance * 1609) : latestStepDistance/3.281
        }
        else {
            latestStepDistance = parent.nextStepDistance.split(separator: " ").last == "km" ? (latestStepDistance * 1000) : latestStepDistance
        }
        ///if previously recorded step distance is nil
        if previousStepDistance == nil {
            ///set the latest available step distance as previous step distance.
            previousStepDistance = latestStepDistance
            ///set change in step distance to 0.
            changeInStepDistance = 0
            ///set the flag to false.
            isUserOutofRoute = false
        }
        ///if previous distance is not nil
        else {
            ///get the change in distance preset number from a function based on user speed.
            let changePreset = setChangePreset(parent: parent)
            ///calculate the change in step distance
            if let prevDist = previousStepDistance  {
                changeInStepDistance = latestStepDistance - prevDist
            }
            if let change = changeInStepDistance  {
                ///if the change in distance is equal to greater than preset update the previusStepDistance with latest one.
                if abs(change) >= changePreset {
                    previousStepDistance = latestStepDistance
                }
                ///if the change in distance is more than or equal to change preset, flag the userOutOfRoute to true.
                isUserOutofRoute = (change >= changePreset) ? true : false
            }
        }
        return
    }
    
    ///method to perform re-routing operation
    static func reRoutetoDestination(in uiView: MKMapView, from source: CLLocationCoordinate2D, to destination: CLLocationCoordinate2D?, parent: inout MapView) {
       ///set nextIndex to 0.
        nextIndex = 0
        parent.nextInstruction = ""
        nextInstructionIndex = 0
        ///reset all static properties of the given class.
        resetProps()
        ///remove all the step instructions to be displayed in expandable list view.
        parent.stepInstructions.removeAll()
        ///create an instance of MKDirections request to request the directions.
        let request = MKDirections.Request()
        ///if distination is not nil
      
        guard let destination = destination else {
        return
        }
        ///set the source point of request as a placemark of user location
        request.source = MKMapItem(placemark: MKPlacemark(coordinate: source))
        ///set the destination of the request as a placemark of searched location
        request.destination = MKMapItem(placemark: MKPlacemark(coordinate: destination))
        ///set the request for alternate routes between 2 places to true to get more than one routes.
        request.requestsAlternateRoutes = true
        ///set the highway preference of the direction request based on user preferences
        request.highwayPreference = avoidHighways ? .avoid : .any
        ///set the toll preference of the direction request based on user preferences
        request.tollPreference = avoidTolls ? .avoid : .any
        ///set the transport type as automobile as default.
        request.transportType = .automobile
        ///create a directions object from our request now.
        let directions = MKDirections(request: request)
        ///remove all entries from stepInstructions array
        parent.stepInstructions.removeAll()
        ///async function to calculate the routes from information provided by request object of directions object.
        Task {
            print("inside the task")
            ///calculate the route for a given directions object and check if there is a response
            guard let response = try? await directions.calculate() else {
                print("unable to calculate directions.")
                return
            }
            print("response is available")
            ///if response is there check if there is atleast one route available in the response object.
            let thisroutes = response.routes.filter({avoidTolls ? !$0.hasTolls : ($0.transportType == .automobile)})
            ///remove all previously fetched routes from the routes array
            routes.removeAll()
            if thisroutes.isEmpty {
                print("thisroutes is empty.")
                noRoutesFound = true
                return
            }
            ///add the latest route to the first index of an array.
            for route in thisroutes {
                routes.append(route)
            }
           
            ///iterate through the sorted routes.
            if let route = self.routes.first(where: {avoidHighways ? !$0.hasHighways: ($0.transportType == .automobile)}) {
                print("re-routed route has tolls? \(route.hasTolls)")
                print("re-routed route has highways? \(route.hasHighways)")
                ///get the polyline object from current route
                let polyline = route.polyline
                let title = polyline.title
                polyline.title = "\(Int(route.expectedTravelTime/60)), \(title ?? "-"), \(UUID()), \(String(format:"%.1f",route.distance/1000.0))"
                ///if this is the last route it must be having a shortest travel time
                ///set the polyline subtitle as fastest route to identify it in later uses.
                polyline.subtitle = "fastest route"
                ///add the polyline received from the route as an overlay to be displayed in mapview.
                await MainActor.run {
                    ///remove all overalys from mapview.
                    uiView.removeOverlays(uiView.overlays)
                    ///sort the routes recieved from the response with longer travel time first.
                    uiView.addOverlay(polyline)
                }
            }
            else {
                print("routes array is empty")
                noRoutesFound = true
                return
            }
        }
        
        reRouted = true
    }

    ///method to set the distance change preset based on user speed.
    static func setChangePreset(parent: MapView) -> Double {
        switch parent.locationDataManager.speed {
        case 0...30:
            return 20
        case 31...50:
            return 30
        case 51...70:
            return 50
        case 71...2000:
            return 120
        default:
            return 20
        }
    }
    ///method to set the selected route from the rendered overlays when user taps on one of the stacks corrosponding the that route.
    static func setSelectedRoute(for mapView: MKMapView, with routeData: [RouteData], action: () -> Void) -> (String, String) {
        ///routeTravelTime string used to store the travel time in minutes.
        var routeTravelTime = ""
        ///format the route distance and store it in routeDistance
        var routeDistance = ""
        ///get the first element from routeData array where the element is tapped and return the uniqueString from that element.
        guard let title = routeData.first(where: {$0.tapped})?.uniqueString else {
            return ("", "")
        }
        ///split the unique string seperated by comma and create an array of strings
        let titleArray = title.split(separator: ", ")
        ///get the overlay from the mapView overlays array where the UUID rendered from the routeData element is matching in the string content.
        guard let overlay = mapView.overlays.first(where: {$0.title!!.contains(titleArray[1])}) else {
            return ("", "")
        }
   
        ///counter that will count the iterations of for loop
        var counter = 0
       // let renderer = MKPolylineRenderer(overlay: overlay)
        for thisOverlay in mapView.overlays {
            ///get the renderer object for a given overlay of mapview.
            let renderer = mapView.renderer(for: thisOverlay) as? MKPolylineRenderer
            ///make sure renderer object is not nil
            if let renderer = renderer {
                ///get the title of the render polyline object
                if overlay.title == thisOverlay.title {
                  
                    ///set the stroke color to blue
                    DispatchQueue.main.async {
                        renderer.strokeColor = UIColor(skyColor)
                        ///set the transperancy to lowest
                        renderer.alpha = 1
                    }
                  
                    ///title of the polyline was set before with route distance and estimated travel time. here routedata will be extracting them and put them separately in an array.
                    let routeData = renderer.polyline.title?.split(separator: ", ") ?? []
                    if let travelTime = routeData.first {
                        routeTravelTime = String(travelTime) + " mins"
                    }
                    ///if the route data has last element available
                    if let distance = routeData.last {
                        ///convert the string distance to number and get it in meters.
                        let number = Double(distance) ?? 0.0 * 100.0
                        ///format the route distance and store it in routeDistance
                        routeDistance = distanceUnit == .miles ? convertToMiles(from: number) : (distance) + " km"
                    }
                }
                ///if title of the render is not matching with a requested title
                else {
                    DispatchQueue.main.async {
                        ///make the stroke color gray
                        renderer.strokeColor = .systemGray
                        ///keep the trasparency to 50%
                        renderer.alpha = 0.5
                    }
                }
                ///increment the counter
                counter += 1
            }
        }
        ///return the routeDistance and routeTravelTime string to the method.
        return (routeTravelTime, routeDistance)
    }
    
    static func getUUIDString(from text: String??) -> String {
        guard let str = text else {
            return ""
        }
        guard let s = str else {
          return ""
        }
        let id = s.split(separator: ", ")
      return String(id[1])
    }
    
    static func getDivider(for size: Int) -> Double {
        switch size {
        case 0...3:
            return 1
        case 4...20:
            return 2
        case 21...40:
            return 3
        case 41...60:
            return 4
        case 61...100:
            return 5
        default:
            return 6
        }
    }
    
    static func isUserLocationOutOfRoute(in mapView : MKMapView, for currentStep: Int, with parent: inout MapView) {
        var arr: [MKMapPoint] = []
        if currentStep >= 0 && !pointsArray.isEmpty {
             arr = convert(count: pointsArray[currentStep].count, data: pointsArray[currentStep])
        }
        
    
        ///if the user point and pointsarray is available and curent step 0 or above.
        if let userPoint = userPoint, currentStep >= 0, !pointsArray.isEmpty, let stepDistance = arr.sorted(by: {$0.distance(to: userPoint) > $1.distance(to: userPoint)}).first {
            ///set the range preset for a given point in route overlay to detect the exit from it by the user.
            let exitPreset = setPreset(parent: parent, stepDistance: stepDistance.distance(to: userPoint), size: pointsArray[currentStep].count).0
            ///set the range preset for a given point in route overlay to check for user entry/exit once user enters into its range.
            let rangePreset = setPreset(parent: parent, stepDistance: stepDistance.distance(to: userPoint), size: pointsArray[currentStep].count).1
            ///set the preset for the change in distance from userlocation to a point of interest. this preset is used to determine if the user is getting close-to/away-from the point.
            let changeInDistancePreset = setPreset(parent: parent, stepDistance: stepDistance.distance(to: userPoint), size: pointsArray[currentStep].count).2
                      
            ///if the polylinePoints array is empty.
            if polylinePoints.isEmpty {
                ///iterate through the points in a pointsArray in a given step index
                for element in pointsArray[currentStep] {
                    ///move all points to PolylinePoints array type.
                    polylinePoints.append(PolylinePoint(point: element))
                }
                ///an array of deleted polyline points.
                var deletedPoints: [PolylinePoint] = []
                ///iterate through the polylinePoints.
                for element in polylinePoints {
                    ///filter all the points from polylinePoints where they are within preset distance/range from a given point.
                    let pointsWithinPresetRange = polylinePoints.filter({$0.point.distance(to: element.point) != 0  && (abs($0.point.distance(to: userPoint) - element.point.distance(to: userPoint)) <= rangePreset)})
                    ///check if the deletedPoints array contains an element of interest. if not execute the code inside.
                    if !deletedPoints.contains(where: {$0.point.distance(to: element.point) == 0}) {
                        ///for all points found within a preset range.
                            for p in pointsWithinPresetRange {
                                ///remove points from polyline points which are found in a given array
                                polylinePoints.removeAll(where: {$0.point.distance(to: userPoint) == p.point.distance(to: userPoint) && $0.point.distance(to: element.point) != 0})
                            }
                        ///move the deleted Points in a deletedPoints array.
                            deletedPoints = pointsWithinPresetRange
                        }
                }
                ///remove all points from polylinePoints array where distance from userPoint is within rangePreset.
                polylinePoints.removeAll(where: {$0.point.distance(to: userPoint) <= rangePreset})
                //comment = "Step #\(currentStep) | pts fetched | \(polylinePoints.count)"
            }
            ///if array is not empty
            else {
                ///if the point in polyline points is within a range of userLocation
                if let index = polylinePoints.firstIndex(where: {$0.point.distance(to: userPoint) <= rangePreset}) {
                    //comment = "Step #\(currentStep) | found pt | \(polylinePoints.count)"
                    ///if point is not yet entered by the user and it is within a range
                    if polylinePoints[index].point.distance(to: userPoint) <= exitPreset && !polylinePoints[index].isPointEntered {
                        ///mark that point as entered
                        polylinePoints[index].isPointEntered = true
                      // comment = "Step #\(currentStep) | entered pt | \(polylinePoints.count)"
                    }
                    ///if the point was already maked as entered and is now out or exit range
                    if polylinePoints[index].point.distance(to: userPoint) >= exitPreset && polylinePoints[index].isPointEntered {
                        ///mark it as exited.
                        polylinePoints[index].isPointExited = true
                        //comment = "Step #\(currentStep) | exited pt | \(polylinePoints.count)"
                    }
                }
                ///else if point is outside the range of the userLocation.
                else if let index = polylinePoints.firstIndex(where: {$0.point.distance(to: userPoint) > rangePreset}) {
                    ///if the given point which is outside the range was maked as entered
                    if !polylinePoints[index].isPointEntered {
                        ///set the current distance from the userpoint to itself
                        polylinePoints[index].currentDistance = Int(polylinePoints[index].point.distance(to: userPoint))
                        ///check if the previously recorded distance is nil
                        if polylinePoints[index].prevDistance == nil {
                            ///if so, set it the same as current distance.
                            polylinePoints[index].prevDistance = Int(polylinePoints[index].point.distance(to: userPoint))
                        }
                        ///if current distance and previous distance is available.
                        if let currentDist = polylinePoints[index].currentDistance, let prevDist = polylinePoints[index].prevDistance {
                            ///check if the diffrence is above preset and is positive, then re-route
                            if currentDist - prevDist >= Int(changeInDistancePreset)  {
                                ///
                               // comment = "re-route"
                                ///clear instructions
                                parent.instruction = "Re-calculating the route..."
                                ///remove all points
                                polylinePoints.removeAll()
                                ///remove all annotations.
                              ///  mapView.removeAnnotations(mapView.annotations)
                                ///method to perform re-routing to the current destination.
                                let targetLocation = parent.tappedAnnotation != nil ? parent.tappedAnnotation?.coordinate : parent.localSearch.suggestedLocations?.first?.coordinate
                                if let userLocation = parent.locationDataManager.userlocation {
                                    reRoutetoDestination(in: mapView, from: userLocation.coordinate, to: targetLocation, parent: &parent)
                                }
                               
                                return
                            }
                         //   comment = "Step #\(currentStep) | dist = \(currentDist - prevDist)) | \(polylinePoints.count)"
                            ///if the absolute difference between current and previous distance is more than preset
                            if abs(currentDist - prevDist) >= Int(changeInDistancePreset) {
                                ///transfer the current distance to prev distance
                                polylinePoints[index].prevDistance = currentDist
                            }
                        }
                    }
                }
                ///if the polylinepoints are more than one
                if polylinePoints.count > 1 {
                    ///remove all points that are either exited by the user or entered before and are now more than 20 m away.
                    polylinePoints.removeAll(where: {$0.isPointExited || ($0.isPointEntered && $0.point.distance(to: userPoint) > 20)})
                }
            }
        }
    }
    static func setPreset(parent: MapView, stepDistance: Double, size: Int) -> (Double, Double, Double) {
        switch abs(parent.locationDataManager.speed) {
        case 0...60:
            switch stepDistance {
            case 0...50:
                return (10, 20, 10)
            case 51...100:
                return size > 8 ? (15, 30, 15) : (10, 20, 10)
            case 101...200:
                return size > 10 ? (20, 50, 20) : (20, 30, 20)
            case 201...400:
                return size > 15 ? (25, 60, 20): (20, 50, 20)
            case 401...1000:
                return size > 30 ? (25, 80, 20) : (25, 60, 20)
            default:
                return (60, 120, 20)
            }
        case 61...200:
            return (60, 120, 40)
        default:
            return (60, 120, 40)
        }
    }
    static func convert(count: Int, data: UnsafeBufferPointer<MKMapPoint>) -> [MKMapPoint] {
        var arr: [MKMapPoint] = []
        for x in data {
            arr.append(x)
        }
        return arr
    }
    static func getFormattedDistance(from distance: CLLocationDistance) -> String {
        if distance > 1000 {
            ///convert distance from meters to km
            let km = distance/1000
            ///round up the double to whole number
            let roundedDistance = round((km * 10.0) / 5) * 0.5
            ///check if the diffence between the decimal and integer is not 0.5
            if abs(roundedDistance - Double(Int(roundedDistance))) != 0.5 {
                ///convert whole double to integer if it is not a decimal
                let wholeDistance = Int(roundedDistance)
                return String(wholeDistance) + " km"
            }
            ///if it is decimal number send the rounded number
            else {
                let wholeDistance = roundedDistance
                return String(wholeDistance) + " km"
            }
        }
        ///if step instruction distance is not containing km sign.
        else {
            let roundedDistance = round(distance/50) * 50.0
            let wholeDistance = Int(roundedDistance)
            return String(wholeDistance) + " m"
        }
    }
    static func convertToMiles(from distance: CLLocationDistance) -> String {
        ///if the distance is greater than 320 m.
        if distance > 320 {
            ///convert to km
            let km = distance/1000
            ///convert to miles
            let miles = km/1.609
            ///if distances is greater than 1 miles
            if miles > 1.0 {
                ///round up the distance with precision of +-0.5 miles
                let roundedMiles = round((miles * 10.0) / 5) * 0.5
                ///check if the rounded miles is a whole number or not
                if abs(roundedMiles - Double(Int(roundedMiles))) != 0.5 {
                    ///if it is not a whole number convert it to a whole number
                    let wholeDistance = Int(roundedMiles)
                    return String(wholeDistance) + " mi"
                }
                ///if it is a whole number
                else {
                    ///get the number and format the string.
                    let wholeDistance = roundedMiles
                    return String(wholeDistance) + " mi"
                }
            }
            ///if miles distance is  more than 1.0 simply return the decimal value.
            else {
                return String(format: "%.1f", miles) + " mi"
            }
        }
        ///if distance is less than 320 meters.
        else {
            ///convert distance to feet.
            let ft = distance * 3.281
            ///round up the feet with precision of +-10 feets
            let wholeFt = round(ft / 10) * 10.0
            ///check if the rounded number is in multiples of 0.5 or not
            if abs(wholeFt - Double(Int(wholeFt))) != 0.5 {
                ///if not, convert it to whole number
                let wholeDistance = Int(wholeFt)
                ///convert it to string with unit annotation
                return String(wholeDistance) + " ft"
            }
            else {
                ///get the whole number
                let wholeDistance = wholeFt
                ///convert it to string with unit annotation
                return String(wholeDistance) + " ft"
            }
        }
    }
    
    static func convertToMilesETA(from distance: CLLocationDistance) -> String {
        ///if the distance is greater than 320 m.
        if distance > 320 {
            ///convert to km
            let km = distance/1000
            ///convert to miles
            let miles = km/1.609
            ///format distance to decimal with 0.1 mi precison and unit annotation.
            return String(format: "%.1f", miles) + " mi"
        }
        else {
            ///convert distance to feet.
            let ft = distance * 3.281
            ///round up the feet with precision of +-10 feets
            let wholeFt = round(ft / 10) * 10.0
            ///check if the rounded number is in multiples of 0.5 or not
            if abs(wholeFt - Double(Int(wholeFt))) != 0.5 {
                ///if not, convert it to whole number
                let wholeDistance = Int(wholeFt)
                ///convert it to string with unit annotation
                return String(wholeDistance) + " ft"
            }
            else {
                ///get the whole number
                let wholeDistance = wholeFt
                ///convert it to string with unit annotation
                return String(wholeDistance) + " ft"
            }
        }
    }
}


