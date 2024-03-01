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
    ///flag to determine if user is out of thoroughfare or not
    static var isUserOutofThoroughFare: Bool = false
    ///flag to determine if timer is ON or OFF.
    static var isTimerOn = false
    ///variable to store the timer occurances in 1 sec interval.
    static var time = 0
    ///timer instance.
    static var timer: Timer?
    ///flag to determine if path is out of camera of the map.
    static var isUserOutofPath: Bool = false
    static var i = ""

    ///this method will accept the mapView, userLocation class instances. here mapView struct instance as inout parameter. inout parameter allows us to make func parameter mutable i.e. we can change the value of the parameter in a function directly and changes will be reflected outside the function after execution.
    static func setRegionIn(mapView: MKMapView, centeredAt userLocation: MKUserLocation, parent: inout MapView) {
        ///when this function will be called for the very first time, the region property of our mapView struct will be nil.
        ///so the code inside this if statement will be executed only one time.
        guard parent.region != nil else {
            ///dispatchqueue is a class that handles the execution of tasks serially or concurrently on apps main/background threads.here we are using a main (serial queue) thread and executing a code inside the block asynchronously in it. that means the main thread is not going to wait until this code is executed and it will perform remaining tasks serially.
            DispatchQueue.main.async {
                //set the mapView region centered to user location with 1000 meters of visible region around it.
                mapView.region = MKCoordinateRegion(center: userLocation.coordinate, latitudinalMeters: 1000, longitudinalMeters: 1000)
            }
                //assign this region to our parent region.
                parent.region = mapView.region
            return
        }
    }
    
    ///this method is used for instantiating map camera and configuring the same
    static func setCameraRegion(of mapView: MKMapView, centeredAt userLocation: MKUserLocation, userHeading: CLHeading?) {
        guard let heading = userHeading else {
            ///instantiate the MKMapCamera object with center as user location, distance (camera zooming to center), pitch(camera angle) and camera heading set to user heading relative to  true north of camera.
            return
        }
        ///instantiate the camera with center to user location and following its heading directions.
        let camera = MKMapCamera(lookingAtCenter: userLocation.coordinate, fromDistance: 600, pitch: 40, heading: heading.magneticHeading)
        
        DispatchQueue.main.async {
            ///set the mapview camera to our defined object.
            mapView.setCamera(camera, animated: true)
            mapView.showsScale = true
        }
    }
    
    ///function to untrack user location
    static func resetLocationTracking(of mapView: MKMapView, parent: inout MapView) {
        ///clear the instruction field that displays next step instruction on the DirectionsView.
        parent.instruction = ""
        ///empty the array that displays entire list of step instructions in the DirectionsView's expanded view
        parent.stepInstructions.removeAll()
        ///set the distance prop on locationdatamanager to nil on reset. distance field is used to showing remaining distance
        if parent.locationDataManager.remainingDistance != nil {
            parent.locationDataManager.remainingDistance = nil
        }
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
        mapView.addAnnotation(annotation)
        ///check if the mapview centered to the searched location or not
        if mapView.centerCoordinate.latitude != annotation.coordinate.latitude && mapView.centerCoordinate.longitude != annotation.coordinate.longitude {
            ///if not centred, centre the mapview to searched location.
            mapView.animatedZoom(zoomRegion: MKCoordinateRegion(center: annotation.coordinate, latitudinalMeters: 1000, longitudinalMeters: 1000), duration: TimeInterval(0.1))
        }
    }
    
    ///this function will send the route directions request between the two locations annotated in the mapview
    static func getNavigationDirections(in uiView: MKMapView, from source: CLLocationCoordinate2D, to destination: CLLocationCoordinate2D?) {
        ///if there are no overlays associated with the mapview return the function call.
        if !uiView.overlays.isEmpty {
            return
        }
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
            let sortedRoutes = response.routes.sorted(by: {
                $0.expectedTravelTime > $1.expectedTravelTime
            })
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
            uiView.setVisibleMapRect(uiView.overlays.first!.boundingMapRect, edgePadding: UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5), animated: true)
        })
    }
    
    ///method used for starting map navigation and updating the related components based on location updates.
    static func startNavigation(in mapView:MKMapView, parent: inout MapView)   {
        if parent.instruction.contains("destination") {
            if let userLocation = mapView.userLocation.location, let stepLocation = parent.nextStepLocation {
                if userLocation.distance(from: stepLocation) <= 20 {
                    print("arrived")
                    parent.showGreetings = true
                    parent.localSearch.suggestedLocations = nil
                    parent.mapViewAction = .idle
                    ///keep the destination selected pinned to map.
                    parent.localSearch.isDestinationSelected = true
                    ///remove all the instructions from the array that shows them in a listview.
                    parent.stepInstructions.removeAll()
                    ///clear the instruction text
                    parent.instruction = ""
                    ///make the next step location nil
                    parent.nextStepLocation = nil
                    ///reseting the remainingDistance to nil
                    parent.locationDataManager.remainingDistance = nil
                    UIApplication.shared.isIdleTimerDisabled = false
                    parent.mapViewAction = .centerToUserLocation
                    resetLocationTracking(of: mapView, parent: &parent)
                    return
                }
            }
        }
      ///redundantly setting up mapview status to navigating mode to make sure no misteps.
         parent.mapViewStatus = .navigating
        ///method that will get the ETA to the given destintion coordinates.
        getETA(to: parent.localSearch.suggestedLocations!.first!.coordinate, in: &parent, with: mapView)
         ///if there is any route available then get the first one otherwise exit the fuction.
         guard let route = getSelectedRoute(for: mapView) else {
             return
        }
         ///if stepinstructions array is empty
        if parent.stepInstructions.isEmpty {
            ///iterate through all the steps in a given route
            for step in route.steps {
                ///skip the appending if instruction is empty
                if !step.instructions.isEmpty {
                    ///append the instruction string and distance from current step to that step for which the instruction is being displayed to our array.
                    parent.stepInstructions.append((step.instructions, step.distance))
                }
            }
        }
         /// set routeETA field with expected travel time extracted from a given route.
        parent.routeTravelTime = String(format:"%.0f",(route.expectedTravelTime/60)) + " mins"
         ///initiating props on first execution
         initiateProps(route: route, parent: &parent)
         ///get the address of the destination
        let destination = parent.localSearch.suggestedLocations?.first?.title
         ///format the remaining distance to be displayed in km
        parent.remainingDistance = String(format:"%.1f", parent.locationDataManager.remainingDistance ?? Double(route.distance/1000.0)) + " km"
         ///set the destination field of mapview struct
        parent.destination = (destination ?? "") ?? ""
         ///setting the routeDistance property with km format for display
        parent.routeDistance = String(format:"%.1f",Double(route.distance/1000.0)) + " km"
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
             if userLocation.distance(from: stepLocation) > 50 && step.polyline.subtitle != "regionExited" && stepIndex == 0 {
                 ///label the current step as exited by user.
                 step.polyline.subtitle = "regionExited"
                 ///get the first step and its index
                 if let firstStep = route.steps.first(where: {!$0.instructions.isEmpty}), let firstIndex = route.steps.firstIndex(of: firstStep) {
                     ///update the step instructions
                     updateStepInstructions(step: firstStep, instruction: firstStep.instructions, parent: &parent, stepIndex: firstIndex)
                 }
             }
             ///if the user location is near 15 m of any of the given step points, update to that step instructions and make nextIndex set to the next step index.
             if nextIndex == stepIndex && pointsArray[stepIndex].contains(where: { $0.distance(to: userPoint) < 10})  {
                 ///this is the variable that will help user navigating by getting advanced hint to start over.
                 let via = route.polyline.title?.split(separator: ", ")
                 ///update the step instructions for display
                 updateStepInstructions(step: step, instruction: (step.instructions == "" ? "Starting at \(parent.locationDataManager.throughfare ?? "your location") towards \(String(via?[1] ?? ""))" : step.instructions), parent: &parent, stepIndex: stepIndex)
                 break
             }
             ///if the expected next step is not found nearby but there is a step point found to be nearby and it wasn't marked as exited
             else if pointsArray[stepIndex].contains(where: {$0.distance(to: userPoint) < 15}) && step.polyline.subtitle != "regionExited" {
                 let via = route.polyline.title?.split(separator: ", ")
                 ///update the step instructions for display
                 updateStepInstructions(step: step, instruction: (step.instructions == "" ? "Starting at \(parent.locationDataManager.throughfare ?? "your location") towards \(String(via?[1] ?? ""))" : step.instructions), parent: &parent, stepIndex: stepIndex)
                 break
             }
         }
         ///now calculate the distance from the next step location to user location
         if let nextStepLocation = parent.nextStepLocation, let userLocation = mapView.userLocation.location {
             calculateDistance(from: nextStepLocation, to: userLocation, parent: &parent)
         }
        ///method that will determine if user is out or route or not.
        isUserLocationOutOfRoute(in: parent)
        ///method that will determine if user is out of thoroughfare or not.
        isUserOutOfThoroghfare(for: route, parent: &parent, in: mapView)
        /// if user is out of route or thoroughfare
        if isUserOutofRoute || isUserOutofThoroughFare || isPathOutofMapCamera(in: route, of: mapView, at: nextIndex, parent: parent) {
            ///set the instruction set to be displayed with a warning text.
            parent.instruction = "Re-calculating the route..."
            parent.locationDataManager.throughfare = nil
            ///method to perform re-routing to the current destination.
            reRoutetoDestination(in: mapView, from: parent.locationDataManager.userlocation!.coordinate, to: parent.localSearch.suggestedLocations!.first!.coordinate, parent: &parent)
        }
        ///transfer the ETA string to parent that is MapView for the display.
        parent.ETA = self.ETA ?? "--"
        ///update the remainingDistance prop of locationDataManager instance with the latest change.
        parent.locationDataManager.remainingDistance = (remainingDistance ?? route.distance)/1000
    }
        
    ///function that handles overlay tap events
    static func getTappedOvarlay(in mapView: MKMapView, by tapGestureRecognizer: UITapGestureRecognizer) -> MKOverlay? {
        ///get the tapped location in the mapview as CGPoint format
        let tapLocation = tapGestureRecognizer.location(in: mapView)
        ///canvert the tapped CGPoint to 2D coordinates.
        let tapCoordinates =  mapView.convert(tapLocation, toCoordinateFrom: mapView)
        ///interate through the overlays
        for overlay in mapView.overlays.reversed() {
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
                    renderer.strokeColor = .systemBlue
                    ///set the transperancy to lowest
                    renderer.alpha = 1
                    ///title of the polyline was set before with route distance and estimated travel time. here routedata will be extracting them and put them separately in an array.
                    let routeData = renderer.polyline.title?.split(separator: ", ") ?? []
                    ///format the travel time and store it in routeTravelTime
                    parent.routeTravelTime = String(routeData.first!) + " mins"
                    ///format the route distance and store it in routeDistance
                    parent.routeDistance = String(routeData.last!) + " km"
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
        isTimerOn = false
        time = 0
        isUserOutofPath = false
        isUserOutofRoute = false
        isUserOutofThoroughFare = false
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
             let via = route.polyline.title?.split(separator: ", ")
             ///initate the instruction for the first step to be displayed with the current location street name and the next one.
             thoroughfare = "Starting at \(parent.locationDataManager.throughfare ?? "your location") towards \(via?[1] ?? "")"
             parent.instruction = "Starting at \(parent.locationDataManager.throughfare ?? "your location") towards \(via?[1] ?? "")"
         }
        ///get the initial distance remaining to destination from user location. that is route distance.
         if parent.locationDataManager.remainingDistance == nil {
               parent.locationDataManager.remainingDistance = Double(route.distance/1000.0)
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
    static func updateStepInstructions(step: MKRoute.Step, instruction: String, parent: inout MapView, stepIndex: Int) {
        previousStepDistance = nil
        ///get the next step location
        parent.nextStepLocation = CLLocation(latitude: step.polyline.coordinate.latitude, longitude: step.polyline.coordinate.longitude)
        ///update the swiftui instruction display with the latest instruction received from next step
        parent.instruction = instruction
        ///remove the previously exited steps from the step instruction array that displays list of future instruction in expanded view.
        parent.stepInstructions.removeAll(where: { $0.0 == instruction})
        ///mark the step polyline subtitle as region exited.
        nextIndex = stepIndex + 1
        ///mark the current step as region exited.
        step.polyline.subtitle = "regionExited"
        ///flag enable geocoding to false.
        parent.locationDataManager.enableGeocoding = false
    }
    
    ///method to calculate the distance from userlocation to next step.
    static func calculateDistance(from nextStepLocation:CLLocation, to userLocation: CLLocation, parent: inout MapView) {
        ///get the raw distance from userlocation to next step location
        let nextStepDistance = userLocation.distance(from: nextStepLocation)
        ///convert the distance in Integer format which is divided by 10.
        var intNextStepDistance = (Int(nextStepDistance)/10) * 10
        ///if the distance is less than 15 then set it to 0.
        intNextStepDistance = intNextStepDistance < 10 ? 0 : intNextStepDistance
        ///format the distance in meters if less than 1000 or in km otherwise.
        parent.nextStepDistance = nextStepDistance < 1000 ? String(intNextStepDistance) + " m" : String(format:"%.1f",(nextStepDistance/1000)) + " km"
    }
    
    ///method that will get the ETA to the given destination
    static func getETA(to destination: CLLocationCoordinate2D, in parent: inout MapView, with mapView: MKMapView) {
        ///create an instance of Request that is a property of MKDirections Object.
        let request = MKDirections.Request()
        ///set the source of the request as the current userlocation
        request.source =  MKMapItem(placemark: MKPlacemark(coordinate: parent.locationDataManager.userlocation!.coordinate))
        ///set the destination of the request as the destination set by the user
        request.destination = MKMapItem(placemark: MKPlacemark(coordinate: destination))
        ///set the transport type as automobile
        request.transportType = .automobile
        ///create an instance of MKDirections with the configured request object
        let directions = MKDirections(request: request)
        ///async task will execute the code non-sequentially. so if the code inside is taking time if will execute the other code and when the code is having a response it will be executed at that time.
        Task {
            ///call the async method of directions called calculateETA to get the ETA for our request and if response is found store it in reponse constant otherwise return the function call.
            guard let response = try? await directions.calculateETA() else {
                return                
            }
            guard let placemarks = try? await CLGeocoder().reverseGeocodeLocation(mapView.userLocation.location!) else {
                thoroughfare = "n/a"
                return
            }
            ///the following code is enclosed in MainActor.run method which will execute the code in mainactor's (locationmanager(didupdate:) method) thread.
            await MainActor.run {
                ///get the distance from current user location to the destination and store it in remainingDistance
                if let thoroughfare = placemarks.first?.thoroughfare {
                    self.thoroughfare = thoroughfare
                }
                else {
                    thoroughfare = "not found"
                }
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
        latestStepDistance = parent.nextStepDistance.split(separator: " ").last == "km" ? (latestStepDistance * 1000) :  latestStepDistance
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
            changeInStepDistance = latestStepDistance - previousStepDistance!
            ///if the change in distance is equal to greater than preset update the previusStepDistance with latest one.
            if abs(changeInStepDistance!) >= changePreset {
                previousStepDistance = latestStepDistance
            }
            ///if the change in distance is more than or equal to change preset, flag the userOutOfRoute to true.
            isUserOutofRoute = (changeInStepDistance! >= changePreset) ? true : false
        }
        return
    }
    
    ///method to perform re-routing operation
    static func reRoutetoDestination(in uiView: MKMapView, from source: CLLocationCoordinate2D, to destination: CLLocationCoordinate2D?, parent: inout MapView) {
       ///set nextIndex to 0.
        nextIndex = 0
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
        request.requestsAlternateRoutes = false
        ///set the transport type as automobile as default.
        request.transportType = .automobile
        ///create a directions object from our request now.
        let directions = MKDirections(request: request)
        ///remove all entries from stepInstructions array
        parent.stepInstructions.removeAll()
        ///async function to calculate the routes from information provided by request object of directions object.
        Task {
            ///calculate the route for a given directions object and check if there is a response
            guard let response = try? await directions.calculate() else {
                return
            }
            ///if response is there check if there is atleast one route available in the response object.
            guard let route = response.routes.first else {
                return
            }
            ///remove all previously fetched routes from the routes array
            routes.removeAll()
            ///add the latest route to the first index of an array.
            routes.append(route)
            ///iterate through the sorted routes.
            if let route = self.routes.first {
                ///get the polyline object from current route
                let polyline = route.polyline
                let title = polyline.title
                polyline.title = "\(Int(route.expectedTravelTime/60)), \(title ?? "n/a"), \(UUID()), \(String(format:"%.1f",route.distance/1000.0))"
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
        }
    }
    
    ///method to check if the user is out of thoroghfare
    static func isUserOutOfThoroghfare(for route: MKRoute, parent: inout MapView, in mapView: MKMapView) {
        ///instantiate the variable to store the current stepIndex
        var stepIndex = 0
        if thoroughfare == "n/a" || thoroughfare == "not found" {
            stopTimer()
            return
        }
        ///find the index of the step from steps array where current instruction on display matches with its instruction.
        if let index = route.steps.firstIndex(where: {
            $0.instructions == parent.instruction
        }) {
            ///deduct the index by 1 so we get the instruction belongs to the current thoroghfare of the user location.
             stepIndex = index - 1
            ///if the instruction contains the thoroughfare
            if route.steps[stepIndex].instructions.contains(thoroughfare)  {
                ///stop the timer
                stopTimer()
                i = "instruction text matches with last instruction at --> \(stepIndex)"
                ///return the function call.
                return
            }
            ///if the instruction at the given stepIndex is found empty in steps array of a given route
            else if route.steps[stepIndex].instructions.isEmpty {
                ///get the title of the route polyline separated in an array. title is actully the street name from where the route is starting towards destination.
                let via = route.polyline.title?.split(separator: ", ")
                ///create a string with initial instruction for the starting point of the route.
                let initialInstruction = "Starting at \(parent.locationDataManager.throughfare ?? "your location") towards \(via?[1] ?? "")"
                ///if the initial instruction has the given thoroughfare
                if initialInstruction.contains(thoroughfare) {
                    i = "instruction text matches with the empty display --> \(stepIndex)"
                    //stop the timer and return the function call
                    stopTimer()
                    return
                }
                
                }
                ///if no conditions were met, continue
                else {
                    if let point = userPoint {
                        if pointsArray[stepIndex].contains(where: {$0.distance(to: point) <= 10}) {
                            i = "point is nearby --> \(stepIndex)"
                             stopTimer()
                             return
                    }
                  
                }
            }
        }
        ///if no index is found, check if the instruction is the first one where user is starting the journey.
        else if parent.instruction.contains(thoroughfare) {
            i = "instruction text matches with the display --> \(stepIndex)"
            ///stop the timer and return the function call
            stopTimer()
            return
        }
        else {
            if let point = userPoint {
                if pointsArray[stepIndex].contains(where: {$0.distance(to: point) <= 10}) {
                    i = "point is nearby --> \(stepIndex)"
                    stopTimer()
                    return
                }
            }
            
        }
       
        ///if instruction doesn't have a current thoroughfare and speed is more than 25
        if parent.locationDataManager.speed >= 25 {
            i = "instruction didn't match --> \(stepIndex)"
            ///if time is not on
            if !self.isTimerOn {
                ///start the timer and continue
                startTimer()
            }
            
        }
        ///once time gets past 5secs
        if self.time > 5  {
            ///set the flag to true to indicate user is out of thoroughfare.
            isUserOutofThoroughFare = true
        }
        
    }
    
    static func isPathOutofMapCamera(in route: MKRoute, of mapView: MKMapView, at nextIndex: Int, parent: MapView) -> Bool {
        ///if mapview is not centered to userlocation set the out of path flag to false
        if parent.mapViewStatus == .inNavigationNotCentered {
            isUserOutofPath = false
            return isUserOutofPath
        }
        var stepIndex = 0
        ///if nextIndex is less than 1
        if nextIndex < 1 {
            ///set the stepIndex to 0.
            stepIndex = 0
        }
        ///otherwise set the stepIndex to the one before nextIndex
        else {
            stepIndex = nextIndex - 1
        }
        ///if the stepPoints are fetched for current step
        if isStepPointsFetched[stepIndex] {
            ///iterate over all points in a given points of step
            for point in pointsArray[stepIndex] {
                ///if the given point is within the visible map rectangle.
                if mapView.visibleMapRect.contains(point) {
                    isUserOutofPath = false
                    return isUserOutofPath
                }
            }
            ///if loop is exited with no matches return the true flag.
            isUserOutofPath = true
        }
         ///if no points are fetched yet, return false
        return isUserOutofPath
    }
    
    ///start timer function
    static func startTimer() {
        ///instantiate scheduled timer with 1sec repeating interval  and a block of code to set timer flag and increment time
        DispatchQueue.main.async {
            timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true, block: { timer in
                   isTimerOn = true
                   time += 1
               })
        }
    }
    
    ///stop timer function
    static func stopTimer() {
        ///if timer is not nil
        if timer != nil {
            ///invalidate timet
            self.timer!.invalidate()
        }
        ///make timer nil.
        self.timer = nil
        ///reset the falg
        isUserOutofThoroughFare = false
        ///reset the timer
        time = 0
        ///flag timer on to false
        isTimerOn = false
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
}

