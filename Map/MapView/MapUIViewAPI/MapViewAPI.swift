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
    
    static func setCameraRegion(of mapView: MKMapView, centeredAt userLocation: MKUserLocation, userHeading: CLHeading?) {
        guard userHeading == nil else {
            //instantiate the MKMapCamera object with center as user location, distance (camera zooming to center),
            //pitch(camera angle) and camera heading set to user heading relative to  true north of camera.
            let camera = MKMapCamera(lookingAtCenter: userLocation.coordinate, fromDistance: 500, pitch: 0, heading: userHeading!.magneticHeading)
            
            DispatchQueue.main.async {
                //set the mapview camera to our defined object.
                mapView.setCamera(camera, animated: true)
            }
            return
        }
        
    }
    ///function to untrack user location
    static func resetLocationTracking(of mapView: MKMapView, parent: inout MapView) {
        ///clear the instruction field
     
            parent.instruction = ""
        
        ///reset the properties of this instance class
        resetProps()

        ///if the throghfare is not nil make it nil on reset.
        if parent.locationDataManager.throughfare != nil {
            parent.locationDataManager.throughfare = nil
        }
        
     
        DispatchQueue.main.async {
            ///undoing user tracking to none.
            mapView.setUserTrackingMode(.none, animated: true)
        }
        print("reset location tracking.")
    }
   
    ///function to annotate a location the user has searched in the search bar.
    static func annotateLocation(in mapView: MKMapView ,at coordinates: CLLocationCoordinate2D, for annotation: MKAnnotation) {
        ///create a point annotation object.
        let userAnnotation = MKPointAnnotation()
        ///set its coordinate as userlocation coordinates.
        userAnnotation.coordinate = mapView.userLocation.coordinate
        ///set its title as userlocation title.
        userAnnotation.title = mapView.userLocation.title!
        ///add user location as a first annotation in the mapview.
        mapView.addAnnotation(userAnnotation)
        ///add the search location received from UIViewRepresentable (mapview) as a second mapview annotation.
        mapView.addAnnotation(annotation)
        ///check if the mapview centered to the searched location or not
        if mapView.centerCoordinate.latitude != annotation.coordinate.latitude && mapView.centerCoordinate.longitude != annotation.coordinate.longitude {
            ///if not centred, centre the mapview to searched location.
            mapView.animatedZoom(zoomRegion: MKCoordinateRegion(center: annotation.coordinate, latitudinalMeters: 1000, longitudinalMeters: 1000), duration: TimeInterval(0.1))
            print("map is centered to user location.")
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
        if let destination = destination {
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
                if let response = response {
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
                        ///if this is the last route it must be having a shortest travel time
                        if index == 0 {
                            ///set the polyline subtitle as fastest route to identify it in later uses.
                            polyline.subtitle = "fastest route"
                        }                                              
                        ///add the polyline received from the route as an overlay to be displayed in mapview.
                        uiView.addOverlay(polyline)
                    }
                    print("showing routing directions on map.")
                }
                ///if the direction request doesn't get a response, handle the error.
                else {
                    print(error!.localizedDescription)
                }
            })
        }
    }
    
     static func startNavigation(in mapView:MKMapView, parent: inout MapView)   {
        var index = 0

        ///if there are more than 1 overlays, find the one that is desired.
        if mapView.overlays.count > 1 {
            getDesiredRouteAndOvarlay(for: mapView)
        }
        if let route = routes.first {
            
            ///initiating props on first execution
            initiateProps(route: route, parent: &parent)
            
            ///iterate through the route steps
            for step in route.steps {
             
                ///get the index of the given step and if it is found continue...
                if let stepIndex = route.steps.firstIndex(of: step) {
                    ///set the user location as user point to calculate distance from step polyline points.
                    userPoint = MKMapPoint(mapView.userLocation.coordinate)
                    ///if array isStepPointsFetched going out of index, add a new element to the last index.
                    if isStepPointsFetched.count <= stepIndex {
                        isStepPointsFetched.append(false)
                    }
                    ///if for the given step index, array element is FALSE (i.e. is not fetched) update the props of the class instance
                    if !isStepPointsFetched[stepIndex] {
                        ///update the props for a given step at a given index.
                        updateProps(for: step, at: stepIndex, mapView: mapView)
                    }
                    ///if userpoint is not nil
                    if let userPoint = userPoint {
                        ///get the step location
                        let stepLocation = CLLocation(latitude: step.polyline.coordinate.latitude, longitude: step.polyline.coordinate.longitude)
                        
                        ///if the user location is 50 m or more from this step and yet it is not set exited and it is the starting point update to the step 1 instructions only
                        if mapView.userLocation.location!.distance(from: stepLocation) > 50 && step.polyline.subtitle != "regionExited" && stepIndex == 0 {
                            step.polyline.subtitle = "regionExited"
                            updateStepInstructions(step: route.steps[1], instruction: route.steps[1].instructions, parent: &parent, stepIndex: 1)
                        }
                        ///if the user location is near 15 m of any of the given step points, update to that step instructions and make nextIndex set to the next step index.
                        if nextIndex == stepIndex && pointsArray[stepIndex].contains(where: { $0.distance(to: userPoint) < 15})  {
                            updateStepInstructions(step: step, instruction: (step.instructions == "" ? "Starting at \(parent.locationDataManager.throughfare ?? "your location")" : step.instructions), parent: &parent, stepIndex: stepIndex)
                            break
                            }
                        index += 1
                    }

                }
                
            }
            
            ///now calculate the distance from the next step location to user location
            if let nextStepLocation = parent.nextStepLocation, let userLocation = mapView.userLocation.location {
                calculateDistance(from: nextStepLocation, to: userLocation, parent: &parent)
            }
        }
        
        print("map is in navigation mode.")
    }
        
    ///function that handles overlay tap events
    static func isOvarlayTapped(in mapView: MKMapView, by tapGestureRecognizer: UITapGestureRecognizer) -> (Bool,String) {
        print("tapped on a mapview")
        let tapLocation = tapGestureRecognizer.location(in: mapView)
        var isOverlayTapped = false
        let tapCoordinates =  mapView.convert(tapLocation, toCoordinateFrom: mapView)
        print("tap coorindates: \(tapCoordinates)")
        var title = ""
        for overlay in mapView.overlays.reversed() {
            let renderer = mapView.renderer(for: overlay) as! MKPolylineRenderer
            let mapPoint = MKMapPoint(tapCoordinates)
            let rendererPoint = renderer.point(for: mapPoint)
            if renderer.path.contains(rendererPoint) {
                title = renderer.polyline.title!
                print("tap is on the polyline")
            }
        }
        isOverlayTapped = (title == "") ? false : true
        return (isOverlayTapped, title)
    }
    static func setTappedOverlay(in mapView: MKMapView, having title: String) {
        var index = 0
        var counter = 0
        for overlay in mapView.overlays {
            let renderer = mapView.renderer(for: overlay) as! MKPolylineRenderer
            if title == renderer.polyline.title {
                renderer.strokeColor = .systemBlue
                index = counter
            }
            else {
                renderer.strokeColor = .systemGray
            }
         counter += 1
        }
            mapView.exchangeOverlay(at: index, withOverlayAt: (mapView.overlays.count - 1))
        counter = 0
    }
}


extension MapViewAPI {
    static func resetProps() {
        isStepPointsFetched.removeAll()
        points = []
        userPoint = nil
        length = []
        pointsArray = []
        nextIndex = 0
    }
    
    static func getDesiredRouteAndOvarlay(for mapView: MKMapView) {
        if mapView.overlays.first != nil {
            ///remove all exept the selected (i.e. first overlay) from map view
            mapView.removeOverlays(mapView.overlays.dropLast())
            ///get the renderer for the given overlay
            let renderer = MKPolylineRenderer(overlay: mapView.overlays.last!)
            
            ///remove all routes where polyline title is not matching with the title of the renderer's polyline.
            routes.removeAll(where: {
                $0.polyline.title != renderer.polyline.title
            })
        }
       
    }
    
   static func initiateProps(route: MKRoute ,parent: inout MapView) {
        ///if instruction field is empty, add the initial step instruction
         if parent.instruction.isEmpty {
             parent.instruction = "Starting at \(parent.locationDataManager.throughfare ?? "your location") "
         }
        ///if the nextStep location is not available, get the location of the first step.
         if parent.nextStepLocation == nil {
             if let firstStep = route.steps.first {
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
    static func updateProps(for step: MKRoute.Step, at stepIndex: Int, mapView: MKMapView) {
        points.append(step.polyline.points())
        length.append(step.polyline.pointCount)
        print("points index:\(points.last)")
        print("length index:\(length.last)")
        if let point = points.last, let length = length.last {
            pointsArray.append(UnsafeBufferPointer(start: point, count: length < 5 ? length : 5))
            print("pointsArray count:\(pointsArray.count))")
        }
        
//        pointsArray.append(UnsafeBufferPointer(start: points[stepIndex], count: length[stepIndex]))
        isStepPointsFetched[stepIndex] = true
    }
    
    static func updateStepInstructions(step: MKRoute.Step, instruction: String, parent: inout MapView, stepIndex: Int) {
     //   let instruction = (step.instructions == "" ? "Starting at \(parent.locationDataManager.throughfare ?? "your location")" : step.instructions)
        parent.nextStepLocation = CLLocation(latitude: step.polyline.coordinate.latitude, longitude: step.polyline.coordinate.longitude)
            ///update the swiftui instruction display with the latest instruction received from next step
        parent.instruction = instruction
            ///mark the step polyline subtitle as region exited.
        nextIndex = stepIndex + 1
        parent.status = "Step #\(nextIndex) is next."
        step.polyline.subtitle = "regionExited"
    }
    
    static func calculateDistance(from nextStepLocation:CLLocation, to userLocation: CLLocation, parent: inout MapView) {
        let nextStepDistance = userLocation.distance(from: nextStepLocation)
        var intNextStepDistance = (Int(nextStepDistance)/10) * 10
        ///if the distance is less than 15 then set it to 0.
        intNextStepDistance = intNextStepDistance < 10 ? 0 : intNextStepDistance
        parent.nextStepDistance = nextStepDistance < 1000 ? String(intNextStepDistance) + " m" : String(format:"%.1f",(nextStepDistance/1000)) + " km"
    }
}


///prepare the first instruction with the value pointing to next step location
//       if  routes.first == nil {
 
//        if let route = routes.first!.steps.first(where: {!$0.instructions.isEmpty}) {
//            let index = routes.first!.steps.firstIndex(where: {!$0.instructions.isEmpty})
//                instruction = "Step #\(index!) " + route.instructions
//                parent.instruction = instruction
//            }
//            if route.steps[0].instructions.isEmpty {
//                parent.instruction = "Starting at \(parent.locationDataManager.throughfare!)"
//                    print("instruction: ",instruction)
//            }
   
//        }

///get the step from routes where user location has entered to.
//        let step = routes.first!.steps.first(where: { step in
//            let location = CLLocation(latitude: step.polyline.coordinate.latitude, longitude: step.polyline.coordinate.longitude)
//            let distance = mapView.userLocation.location!.distance(from: location)
//            if distance < 50 && step.polyline.subtitle != "regionExited" {
//                return true
//            }
//            else {
//                return false
//            }
//        })
//        if let step = step {
//            print("USER HAS ENTERED TO STEP: \(step.instructions)")
//            let index = routes.first!.steps.firstIndex(of: step)
//
//            if let index = index {
//                if (index + 1) < routes.first!.steps.count {
//                    let nextStep = routes.first!.steps[index + 1]
//                    instruction = nextStep.instructions
//                    let nextLocation = CLLocation(latitude: nextStep.polyline.coordinate.latitude, longitude: nextStep.polyline.coordinate.longitude)
//                    var regionDistance = mapView.userLocation.location!.distance(from: nextLocation)
//                    regionDistance = regionDistance < 20 ? 0 : regionDistance
//                    parent.regionDistance = regionDistance < 1000 ? String(Int(regionDistance)) + " m" : String(format:"%.1f",regionDistance/1000) + " km"
//                }
//                else {
//                    instruction = "You have arrived!"
//                }
//            }
//            let location = CLLocation(latitude: step.polyline.coordinate.latitude, longitude: step.polyline.coordinate.longitude)
//            let distance = mapView.userLocation.location!.distance(from: location)
//
//            print("Distance is \(parent.regionDistance)")
//            if distance < 20 {
//                parent.enteredToRegion = true
//            }
//            if distance > 20 && parent.enteredToRegion {
//                parent.instruction = instruction
//                parent.enteredToRegion = false
//                routes.first!.steps[index!].polyline.subtitle = "regionExited"
//            }
//        }

///create step points for each steps
//        var i = 0
//
//        for step in routes.first!.steps {
//            print("step#\(i) point counts: \(step.polyline.pointCount)")
//            if userPoint == nil {
//                userPoint = MKMapPoint(mapView.userLocation.coordinate)
//            }
//
//
//            if stepsPoints.count != routes.first!.steps.count {
//                print("creating points for step#\(i)")
//                points =  step.polyline.points()
//
//                let length = step.polyline.pointCount
//
//                stepsPoints.append(UnsafeBufferPointer(start: points, count: length < 10 ? length : 10))
//
//                for point in stepsPoints[i] {
//                    print("step\(i) points:",point.coordinate)
//                    let annotation = MKPointAnnotation()
//                    annotation.coordinate = point.coordinate
//                    mapView.addAnnotation(annotation)
//                }
//            }
//            i += 1
//        }


//            for point in pointsArray {
//
//                let annotation = MKPointAnnotation()
//                annotation.coordinate = point.coordinate
//                mapView.addAnnotation(annotation)
//            }
           ///get the location coordinates of the current step
           
          
//            if stepDistance < 50 && step.polyline.subtitle != "regionExited" {
//                parent.status = "Step #\(nextIndex) is under 60 m."
//                print("on step #\(nextIndex)")
//                ///if the next index is less than the last index of steps array load the next step location and instruction
//                if nextIndex <= routes.first!.steps.count - 1 {
//                    ///set the local instruction variable as a next step's instruction
//                    instruction = "Step #\(nextIndex) " + routes.first!.steps[nextIndex].instructions
//                    print("NEXT STEP IS: \(instruction)")
//                    ///get the next step location in a local variable once user has entered to the current step region
//                }
//                ///if this is the last step
//                else {
//                    ///set the instruction to indicate user has arrived
//                    instruction = "you have arrived"
//                }
//                ///if user has entered to the step region within 20 meter radius
//                if stepDistance < 20 {
//                    ///set it as entered to the region
//                    parent.status = "Step #\(nextIndex) entered"
//                    step.polyline.subtitle = "enteredToRegion"
//                    print("user entered to this region? : \(parent.enteredToRegion)")
//                }
//                ///if user has exited the step region of 20 meter radius and it was entered into it before
//                if stepDistance > 20 && step.polyline.subtitle == "enteredToRegion" {
//                    parent.status = "Step #\(nextIndex) exited"
//                    parent.nextStepLocation = CLLocation(latitude: routes.first!.steps[nextIndex].polyline.coordinate.latitude, longitude: routes.first!.steps[nextIndex].polyline.coordinate.longitude)
//                    ///update the swiftui instruction display with the latest instruction received from next step
//                    parent.instruction = instruction
//                    ///mark the step polyline subtitle as region exited.
//                    step.polyline.subtitle = "regionExited"
//                    print("user exited to this region")
//                }
//            }


