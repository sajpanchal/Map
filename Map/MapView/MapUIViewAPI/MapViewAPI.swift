//
//  MapViewAPI.swift
//  Map
//
//  Created by saj panchal on 2023-08-19.
//

import Foundation
import MapKit

class MapViewAPI {
  
    static var routes: [MKRoute] = []
    static var nextIndex = 0
    static var isStepPointsFetched: [Bool] = []
    static var points: [UnsafeMutablePointer<MKMapPoint>] = []
    static var userPoint:MKMapPoint?
    static var length: [Int] = []
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
        parent.instruction = ""
        isStepPointsFetched.removeAll()
        points = []
        userPoint = nil
        length = []
        pointsArray = []
        nextIndex = 0
//        for ovarlay in mapView.overlays {
//            if ovarlay is MKCircle {
//                mapView.removeOverlay(ovarlay)
//            }
//        }
        if parent.locationDataManager.throughfare != nil {
            parent.locationDataManager.throughfare = nil
        }
        
        print("reseting tracking")
        DispatchQueue.main.async {
            //undoing user tracking to none.
          
            mapView.setUserTrackingMode(.none, animated: true)
        }
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
            print("centered mapview to searched location")
        }
    }
    ///this function will send the route directions request between the two locations annotated in the mapview
    static func getNavigationDirections(in uiView: MKMapView, from source: CLLocationCoordinate2D, to destination: CLLocationCoordinate2D?) {
        ///if there are no overlays associated with the mapview return the function call.
//        points = nil
//        stepsPoints = []
        nextIndex = 0
        isStepPointsFetched.removeAll()
        points = []
        userPoint = nil
        length = []
        pointsArray = []
//        for ovarlay in uiView.overlays {
//            if ovarlay is MKCircle {
//                uiView.removeOverlay(ovarlay)
//            }
//        }
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
                print("Showing directions")
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
                }
                ///if the direction request doesn't get a response, handle the error.
                else {
                    print(error!.localizedDescription)
                }
            })
           
        }
    }
    

    static func startNavigation(in mapView:MKMapView, parent: inout MapView)   {
        
        mapView.removeOverlays(mapView.overlays.dropLast())
        let renderer = MKPolylineRenderer(overlay: mapView.overlays.first(where: {$0 is MKPolyline})!)
           
        routes.removeAll(where: {
            $0.polyline.title != renderer.polyline.title
        })
        
        var instruction = ""
       
 
        if parent.instruction.isEmpty {
            parent.instruction = "Starting at \(parent.locationDataManager.throughfare ?? "your location") "
        }
        var index = 0
        
        if parent.nextStepLocation == nil && routes.first!.steps.count >= 2 {
            parent.nextStepLocation = CLLocation(latitude: routes.first!.steps[0].polyline.coordinate.latitude, longitude: routes.first!.steps[0].polyline.coordinate.longitude)
        }
        
        if routes.first == nil {
            return
        }

        if isStepPointsFetched.isEmpty {
            for _ in routes.first!.steps {
                isStepPointsFetched.append(false)
            }
            print("buffer size is:\(isStepPointsFetched.count)")
        }
        
        
        for step in routes.first!.steps {
            //print(routes.first!.steps.firstIndex(of: step)!)
            let stepIndex = routes.first!.steps.firstIndex(of: step)!
            print("step index is:\(stepIndex)")
//            print("Step #\(nextIndex) is coming up!")
//            print("Step #\(nextIndex): \(step.instructions)")
            var dist = 0.0
            let stepLocation = CLLocation(latitude: step.polyline.coordinate.latitude, longitude: step.polyline.coordinate.longitude)
            ///calculate the distance from userlocation to current step
            let stepDistance = mapView.userLocation.location!.distance(from: stepLocation)
            let overlayRegion = MKCircle(center: step.polyline.coordinate, radius: 20)
            
          
            userPoint = MKMapPoint(mapView.userLocation.coordinate)
            
            if !isStepPointsFetched[stepIndex] {
              
                points.append(step.polyline.points())
                length.append(step.polyline.pointCount)
                pointsArray.append(UnsafeBufferPointer(start: points[stepIndex], count: length[stepIndex] < 5 ? length[stepIndex] : 5))
                isStepPointsFetched[stepIndex] = true
                print("isStepPointsFetched[\(stepIndex)] = \(isStepPointsFetched[stepIndex])")
                
            }
            
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
            ///if the user is out of step region but was inside the region before i.e. didn't exited even after the exit.
            
            if nextIndex == routes.first!.steps.firstIndex(of: step)! && pointsArray[stepIndex].contains(where: { dist = ($0.distance(to: userPoint!)); return $0.distance(to: userPoint!) < 15})  {

              
                instruction = (step.instructions == "" ? "Starting at \(parent.locationDataManager.throughfare ?? "your location")" : step.instructions)
                parent.nextStepLocation = CLLocation(latitude: step.polyline.coordinate.latitude, longitude: step.polyline.coordinate.longitude)
                    ///update the swiftui instruction display with the latest instruction received from next step
                parent.instruction = instruction
                    ///mark the step polyline subtitle as region exited.
                nextIndex = stepIndex + 1
                parent.status = "Step #\(nextIndex) is next."
                step.polyline.subtitle = "regionExited"
                break
                }
            index += 1
        }

        ///now calculate the distance from the next step location to user location
        if let nextStepLocation = parent.nextStepLocation {
            let nextStepDistance = mapView.userLocation.location!.distance(from: nextStepLocation)
            var intNextStepDistance = (Int(nextStepDistance)/10) * 10
            ///if the distance is less than 15 then set it to 0.
            intNextStepDistance = intNextStepDistance < 10 ? 0 : intNextStepDistance
            parent.nextStepDistance = nextStepDistance < 1000 ? String(intNextStepDistance) + " m" : String(format:"%.1f",(nextStepDistance/1000)) + " km"
        }

    }
        
    ///function that handles overlay tap events
    static func isOvarlayTapped(in mapView: MKMapView, by tapGestureRecognizer: UITapGestureRecognizer) -> (Bool,String) {
        let tapLocation = tapGestureRecognizer.location(in: mapView)
        var isOverlayTapped = false
        print("tapped on a mapview")
        let tapCoordinates =  mapView.convert(tapLocation, toCoordinateFrom: mapView)
        print("tap coorindates: \(tapCoordinates)")
        var title = ""
        for overlay in mapView.overlays.reversed() {
            let renderer = mapView.renderer(for: overlay) as! MKPolylineRenderer
            let mapPoint = MKMapPoint(tapCoordinates)
            let rendererPoint = renderer.point(for: mapPoint)
            print("title is : \(renderer.polyline.title!)")
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
