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
    /// array to detect if the given step has points fetched by the function call or not.
    static var isStepPointsFetched: [Bool] = []
    ///an array stores the MKMapPoints of each steps.
    static var points: [UnsafeMutablePointer<MKMapPoint>] = []
    /// MKMapPoint of user location
    static var userPoint:MKMapPoint?
    ///length of points array
    static var length: [Int] = []
    ///points array of points
    static var pointsArray: [UnsafeBufferPointer<MKMapPoint>] = []
    
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
            //instantiate the MKMapCamera object with center as user location, distance (camera zooming to center),
            //pitch(camera angle) and camera heading set to user heading relative to  true north of camera.
            return
        }
        ///instantiate the camera with center to user location and following its heading directions.
        let camera = MKMapCamera(lookingAtCenter: userLocation.coordinate, fromDistance: 500, pitch: 0, heading: heading.magneticHeading)
        
        DispatchQueue.main.async {
            //set the mapview camera to our defined object.
            mapView.setCamera(camera, animated: true)
            
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
                print(error?.localizedDescription ?? "")
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
      ///redundantly setting up mapview status to navigating mode to make sure no misteps.
         parent.mapViewStatus = .navigating
        ///if there are more than 1 overlays, find the one that is desired.
        if mapView.overlays.count > 1 {
            getDesiredRouteAndOvarlay(for: mapView)
        }
         ///if there is any route available then get the first one otherwise exit the fuction.
         guard let route = routes.first else {
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
             if nextIndex == stepIndex && pointsArray[stepIndex].contains(where: { $0.distance(to: userPoint) < 15})  {
                 ///this is the variable that will help user navigating by getting advanced hint to start over.
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
    }
    
    ///method to get the overlay that has been set or tapped.
    static func getDesiredRouteAndOvarlay(for mapView: MKMapView) {
        ///make sure the mapview overlays array has atleast one overlay
        if mapView.overlays.first != nil {
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
            if let overlay = mapView.overlays.first {
                ///get the renderer for a given overlay
                let renderer = MKPolylineRenderer(overlay: overlay)
                ///remove all overlays where the polyline object of the renderer is not the one that the tapped/set route has.
                routes.removeAll(where: {
                     !$0.polyline.isEqual(renderer.polyline)
                })
            }
        }
    }
    
    ///method to set the initial values to the properties of MapViewAPI
   static func initiateProps(route: MKRoute ,parent: inout MapView) {
        ///if instruction field is empty, add the initial step instruction
         if parent.instruction.isEmpty {
             ///get the title of the route polyline separated in an array. title is actully the street name from where the route is starting towards destination.
             let via = route.polyline.title?.split(separator: ", ")
             ///initate the instruction for the first step to be displayed with the current location street name and the next one.
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
            pointsArray.append(UnsafeBufferPointer(start: point, count: length < 5 ? length : 5))
        }
        ///set the flag in the array to indicate the points for a given step is already fetched.
        isStepPointsFetched[stepIndex] = true
    }
    
    ///method used for updating the step instructons on change of step.
    static func updateStepInstructions(step: MKRoute.Step, instruction: String, parent: inout MapView, stepIndex: Int) {
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
}

