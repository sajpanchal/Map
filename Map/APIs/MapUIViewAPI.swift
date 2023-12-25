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
        parent.stepInstructions.removeAll()
        if parent.locationDataManager.distance != nil {
            parent.locationDataManager.distance = nil
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
                  
                }
                ///if the direction request doesn't get a response, handle the error.
                else {
                    print(error?.localizedDescription ?? "")
                }
            })
//            directions.calculate(completionHandler: { (response, error) in
//      
            
        }
    }
    
     static func startNavigation(in mapView:MKMapView, parent: inout MapView)   {
        var index = 0
         parent.mapViewStatus = .navigating
        
         print("starting navigation \(parent.isLocationSelected), \(parent.isSearchCancelled)")
        ///if there are more than 1 overlays, find the one that is desired.
        if mapView.overlays.count > 1 {
            getDesiredRouteAndOvarlay(for: mapView)
           
        }
        if let route = routes.first {
           
          
            if parent.stepInstructions.isEmpty {
                for step in route.steps {
                    print("step instruction: \(step.instructions)")
                    if !step.instructions.isEmpty {
                        
                            parent.stepInstructions.append((step.instructions, step.distance))
                      //  print("list step instruction: \(parent.stepInstructions.last)")
                        
                      
                    }
                }
            }
            
            parent.routeETA = String(format:"%.0f",(route.expectedTravelTime/60)) + " mins"
            if parent.locationDataManager.distance == nil {
                parent.locationDataManager.distance = Double(route.distance/1000.0)
                let destination = parent.localSearch.tappedLocation?.first?.title
                parent.distance = String(format:"%.1f", parent.locationDataManager.distance!) + " km"
                parent.destination = (destination ?? "") ?? ""
            }
            else {
                let destination = parent.localSearch.tappedLocation?.first?.title
                parent.distance = String(format:"%.1f", parent.locationDataManager.distance!) + " km"
                parent.destination = (destination ?? "") ?? ""
            }
            parent.routeDistance = String(format:"%.1f",Double(route.distance/1000.0)) + " km"
            ///initiating props on first execution
            initiateProps(route: route, parent: &parent)
           
            ///iterate through the route steps
            for step in route.steps {
           
                ///get the index of the given step and if it is found continue...
                if let stepIndex = route.steps.firstIndex(of: step) {
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
                    if let userPoint = userPoint, let userLocation = mapView.userLocation.location {
                        ///get the step location
                        let stepLocation = CLLocation(latitude: step.polyline.coordinate.latitude, longitude: step.polyline.coordinate.longitude)
                        
                        ///if the user location is 50 m or more from this step and yet it is not set exited and it is the starting point update to the step 1 instructions only
                        if userLocation.distance(from: stepLocation) > 50 && step.polyline.subtitle != "regionExited" && stepIndex == 0 {
                            step.polyline.subtitle = "regionExited"
                            if let firstStep = route.steps.first(where: {!$0.instructions.isEmpty}), let firstIndex = route.steps.firstIndex(of: firstStep) {
                                updateStepInstructions(step: firstStep, instruction: firstStep.instructions, parent: &parent, stepIndex: firstIndex)
                            }
                            
                        }
                        ///if the user location is near 15 m of any of the given step points, update to that step instructions and make nextIndex set to the next step index.
                        if nextIndex == stepIndex && pointsArray[stepIndex].contains(where: { $0.distance(to: userPoint) < 15})  {
                            let via = route.polyline.title?.split(separator: ", ")
                         
                            updateStepInstructions(step: step, instruction: (step.instructions == "" ? "Starting at \(parent.locationDataManager.throughfare ?? "your location") towards \(String(via?[1] ?? ""))" : step.instructions), parent: &parent, stepIndex: stepIndex)
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
   
    }
        
    ///function that handles overlay tap events
    static func isOvarlayTapped(in mapView: MKMapView, by tapGestureRecognizer: UITapGestureRecognizer) -> (Bool,String) {
 
        ///get the tapped location in the mapview as CGPoint format
        let tapLocation = tapGestureRecognizer.location(in: mapView)
        ///initiate the tap flag to false
        var isOverlayTapped = false
        ///canvert the tapped CGPoint to 2D coordinates.
        let tapCoordinates =  mapView.convert(tapLocation, toCoordinateFrom: mapView)
        ///a variable storing the title of the polyline
        var title = ""
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
                title = renderer.polyline.title ?? ""
              
            }
        }
        ///if title is not empty set the flag
        isOverlayTapped = (title == "") ? false : true
        return (isOverlayTapped, title)
    }
    static func setTappedOverlay(in mapView: MKMapView, having title: String, parent: inout MapView) {
        var index = 0
        var counter = 0
        for overlay in mapView.overlays {
            let renderer = mapView.renderer(for: overlay) as? MKPolylineRenderer
            if let renderer = renderer {
                if title == renderer.polyline.title {
                    renderer.strokeColor = .systemBlue
                    renderer.alpha = 1
                    let routeData = renderer.polyline.title?.split(separator: ", ") ?? []
                    
                    parent.routeETA = String(routeData.first!) + " mins"
                    parent.routeDistance = String(routeData.last!) + " km"
                    index = counter
                }
                else {
                    renderer.strokeColor = .systemGray
                    renderer.alpha = 0.5
                }
             counter += 1
            }
     
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
            mapView.removeOverlays(mapView.overlays.filter({
                if let renderer = mapView.renderer(for: $0) {
                    return renderer.alpha != 1
                }
                else {
                    return false
                }
                
                
            }))
            ///get the renderer for the given overlay
            ///i
            if let overlay = mapView.overlays.first {
                let renderer = MKPolylineRenderer(overlay: overlay)
                routes.removeAll(where: {
                 
                    return !$0.polyline.isEqual(renderer.polyline)
                    
                })
            }
            
            
            ///remove all routes where polyline title is not matching with the title of the renderer's polyline.
            
        
        }
       
    }
    
   static func initiateProps(route: MKRoute ,parent: inout MapView) {
        ///if instruction field is empty, add the initial step instruction
         if parent.instruction.isEmpty {
             let via = route.polyline.title?.split(separator: ", ")
             
             parent.instruction = "Starting at \(parent.locationDataManager.throughfare ?? "your location") towards \(via?[1] ?? "")"
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
        
        if let point = points.last, let length = length.last {
            pointsArray.append(UnsafeBufferPointer(start: point, count: length < 5 ? length : 5))
 
        }
       
            isStepPointsFetched[stepIndex] = true
        
       
    }
    
    static func updateStepInstructions(step: MKRoute.Step, instruction: String, parent: inout MapView, stepIndex: Int) {
     //   let instruction = (step.instructions == "" ? "Starting at \(parent.locationDataManager.throughfare ?? "your location")" : step.instructions)
        parent.nextStepLocation = CLLocation(latitude: step.polyline.coordinate.latitude, longitude: step.polyline.coordinate.longitude)
            ///update the swiftui instruction display with the latest instruction received from next step
        parent.instruction = instruction
        parent.stepInstructions.removeAll(where: { $0.0 == instruction})
            ///mark the step polyline subtitle as region exited.
        nextIndex = stepIndex + 1
        parent.status = "Step #\(nextIndex) is next."
        step.polyline.subtitle = "regionExited"
        parent.locationDataManager.enableGeocoding = false
    }
    
    static func calculateDistance(from nextStepLocation:CLLocation, to userLocation: CLLocation, parent: inout MapView) {
        let nextStepDistance = userLocation.distance(from: nextStepLocation)
        var intNextStepDistance = (Int(nextStepDistance)/10) * 10
        ///if the distance is less than 15 then set it to 0.
        intNextStepDistance = intNextStepDistance < 10 ? 0 : intNextStepDistance
        parent.nextStepDistance = nextStepDistance < 1000 ? String(intNextStepDistance) + " m" : String(format:"%.1f",(nextStepDistance/1000)) + " km"
    }
}

