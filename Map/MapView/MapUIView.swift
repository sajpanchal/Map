//
//  MapViewController.swift
//  Map
//
//  Created by saj panchal on 2023-08-03.
//

import Foundation
///module requires to use UIViewControllerRepresentable protocol
import SwiftUI
///module requires to use UIViewController and other UIKit ViewControllers, views and its methods, properties etc.
import UIKit
///module requires to use MapKit classes, structs and its methods/properties..
import MapKit

var skyColor = Color(red:0.031, green:0.739, blue:0.861)

///create a custom struct called MapView and conform it to UIViewRepresentable. this class is only responsible to display map and its accessories.
struct MapView: UIViewRepresentable {
    
    
    typealias UIViewType = MKMapView
    ///this property is bound to the tapped property of Map SwiftUI. it will be true when re-center button is pressed from Map SwiftUI.
    @Environment(\.managedObjectContext) private var viewContext
    @Binding var mapViewAction: MapViewAction
    ///this property holds the error codes that we have defined in enum type in Map SwiftUI file.
    @Binding var mapError: Errors
    ///this property is needed to set the map region centered to user's location when app is launched for the first time.
    @Binding var mapViewStatus: MapViewStatus
    ///this ist the state object of Map Swiftui view that is going to handle the location search
    @Binding var instruction: String
    @Binding var nextInstruction: String
    ///localSearch struct that is responsible for address/location search start, update or cancellation.
    @StateObject var localSearch: LocalSearch
    ///locationDataManager is an instance of a class that has a delegate of LocationManager and its methods.
    @StateObject var locationDataManager: LocationDataManager
    ///a variable from Map SwiftUI view that has the location of the next step.
    @Binding var nextStepLocation: CLLocation?
    ///distance of the next step from current user location
    @Binding var nextStepDistance: String
    ///travel time for a given route
    @Binding var routeTravelTime: String
    ///routeData is an array of RouteData struct type having MKRoute details
    @Binding var routeData: [RouteData]
    ///travel distance for a given route
    @Binding var routeDistance: String
    ///remaining distance from the destination during navigation
    @Binding var remainingDistance: String
    ///address of the destination
    @Binding var destination: String
    ///an array of tuple storing step instruction and distance between the steps.
    @Binding var stepInstructions: [(String, String)]
    ///temportily storing the region instance
    var region: MKCoordinateRegion?
    ///string to display the ETA for a given destination
    @Binding var ETA: String
    ///flag used to show/hide greetings view.
    @Binding var showGreetings: Bool
    ///flag used to determine if the routeSelection is tapped or not.
    @Binding var isRouteSelectTapped: Bool
    ///this variable holds the annotation object that is selected from the list of locations when user taps search nearby option.
    @Binding var tappedAnnotation: MKAnnotation?
    @Binding var timeInterval: Bool
    @State private var tripReset = false
    @State private var animated = true
    @FetchRequest(entity:Settings.entity(), sortDescriptors:[]) var setting: FetchedResults<Settings>
    @FetchRequest(entity: Vehicle.entity(), sortDescriptors: []) var vehicles: FetchedResults<Vehicle>
   
    ///this is the function that our MapView will execute the first time on its inception. this function will instantiate the Coordinator class with a copy of its parent object.
    func makeCoordinator() -> (Coordinator) {
        return Coordinator(self)
    }
    ///Coordinator is a class reponsible to communicate the behaviour of our UIKit/Appkit object and makes necessary changes to our swiftuiobjects. it enables us to do so by updating the properties of this class or executing UIKit/AppKit methods. here, we are making our cooridator a subclass of NSObject. We are also conforming to the MKMapViewDelegate protocol which enables us to use MKMapView methods that will be executed on updates to our MapView and CoreLocation data. Also, we are setting a property called parent as MapView type and setting its delegate as a coordinator object. So, when any of the event related to MapView occurs a delegator will detect those changes, a relevant function we have declared in the Delegator (Coordinator) will be executed. inside the methods, we make changes to our UIView based on the changes in associated data.
    class Coordinator: NSObject, MKMapViewDelegate, UIGestureRecognizerDelegate {
        ///setting MapView as its parent view
        var parent: MapView
        ///instatiate the MKMapView
        var mapView = MKMapView()
        ///object that recognizes single or multiple taps.
        var tapGestureRecognizer = UITapGestureRecognizer()
        ///flag that will determine whether mapview was tapped or not
        var isOverlayTapped = false
        
        init(_ parent: MapView) {
            ///setting a parent property as parent on initialization
            self.parent = parent
            super.init()
            ///add coordinator as a target to gesture recognizer and execute an action method on tap.
            self.tapGestureRecognizer.addTarget(self, action: #selector(handleTapGesture))
            ///set the delegate of the gesture recognizer as the coordinator object itself.
            self.tapGestureRecognizer.delegate = self
        }
        
        @objc func handleTapGesture() {
            ///get the given route title on tap of mapview that route
            guard let overlay = MapViewAPI.getTappedOvarlay(in: self.mapView, by: tapGestureRecognizer)
            else {
                return
            }
            ///hightlight the tapped overlay
            MapViewAPI.setTappedOverlay(in: self.mapView, having: overlay, parent: &self.parent)
            ///get the uuid in string format from a given overlay title
            let uuidText = MapViewAPI.getUUIDString(from: overlay.title)
            ///check if the given routeData array contatins the element having the uuid of the overlay that user has selected. if yes, then get the index of that element.
            guard let indexOfSelectedRoute = parent.routeData.firstIndex(where: { $0.uniqueString.contains(uuidText) }) else {
                return
            }
            ///get the index of the route that was previously selected
            if let indexOfPrevSelectedRoute = parent.routeData.firstIndex(where: {$0.tapped}) {
                ///reset the tapped property of the given route.
                parent.routeData[indexOfPrevSelectedRoute].tapped = false
            }
            ///set the tapped prop of a currenty selected route.
            parent.routeData[indexOfSelectedRoute].tapped = true
            
        }
        
        ///if mapView couldn't find the user location this function will be called.
        func mapView(_ mapView: MKMapView, didFailToLocateUserWithError error: Error) {
            ///we will handle the error by updating our enum type variable in Map SwiftUI. It will then print the error message in text field.
            parent.mapError = Errors.locationNotFound
        }
       ///this function will be called once the overlay is added to the mapview object
        func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
            ///get the renderer for a given overlay
            let renderer = MKPolylineRenderer(overlay: overlay)
            ///set the linewidth to 10
            renderer.lineWidth = 10
            ///if the renderer subtitle is the fastest route to the destination
            if renderer.polyline.subtitle == "fastest route" {
                ///set the stroke color to system blue
                renderer.strokeColor = UIColor(skyColor)
                ///set the transparency to lowest
                renderer.alpha = 1
                ///extract the route data from renderer title
                let routeData = renderer.polyline.title?.split(separator: ", ") ?? []
                ///set the travel time
                parent.routeTravelTime = String(routeData.first ?? "") + " mins"
                ///get the last element of route data
                if let distance = routeData.last {
                    ///convert the distance from string to number and get it in meters.
                    let number = Double(distance) ?? 0.0 * 100.0
                    ///format the distance in miles or km.
                    parent.routeDistance = MapViewAPI.distanceUnit == .miles ? MapViewAPI.convertToMiles(from: number) : String(distance) + " km"
                }
               
            }
            ///if route renderer is other than selected
            else {
                renderer.strokeColor = .systemGray
                renderer.alpha = 0.5
            }
            return renderer
        }
        
        ///this is the delegate method that will be called whenever user location will update
        @MainActor func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
            ///set the initial mapview region centered to current location
            MapViewAPI.setRegionIn(mapView: mapView, centeredAt: userLocation, parent: &parent)
            ///check what mapviewaction is to be performed
            switch parent.mapViewAction {
                ///map in idle mode.
                case .idle:
                    ///if status is not updated
                    if parent.mapViewStatus != .idle && parent.mapViewStatus != .notCentered {
                        ///reset the location tracking
                        if parent.localSearch.status != .localSearchCancelled {
                            MapViewAPI.resetLocationTracking(of: mapView, parent: &parent)
                            ///set the status to idle
                            parent.mapViewStatus = .idle
                        }
                      
                    }
                
                parent.handleLocationSearch(in: mapView, for: parent.localSearch.status)
                    break
                ///idle in showdirections  mode.
                case .idleInshowDirections:
                    ///reset the user tracking.
                guard parent.localSearch.suggestedLocations != nil else {
                    ///clear the entities from mapview
                    parent.clearEntities(from: mapView)
                    ///make the map view to go in idle mode
                    parent.mapViewAction = .idle
                    return
                }
                    mapView.setUserTrackingMode(.none, animated: true)
                ///if the route is tapped
                if parent.isRouteSelectTapped {
                 ///set the seleted route from the mapView and get the string from a given route with route travel time and distance info
                    let str = MapViewAPI.setSelectedRoute(for:mapView, with: parent.routeData) {}
                        ///format the travel time and store it in routeTravelTime
                    parent.routeTravelTime = str.0
                        ///format the route distance and store it in routeDistance
                    parent.routeDistance = str.1
                    }
                parent.isRouteSelectTapped = false
                ///idle in navigation mode.
                case .idleInNavigation:
                    parent.animated = false
                    parent.mapViewStatus = .inNavigationNotCentered
                ///set the animated flag to false so when user centers to current location it won't animate the re-centering of mapcamera operation to avoid consuming time.
                    break
                ///center to user location mode
                case.centerToUserLocation:
                    parent.mapViewStatus = .centeredToUserLocation
                    break
                ///in navigation mode, center to user location
                case .inNavigationCenterToUserLocation:
                    fallthrough
                ///navigation mode.
                case .navigate:
                ///get cam distance to be set based on the current speed.
                let camDistance = MapViewAPI.getCameraDistanceFromMapView(atSpeed: self.parent.locationDataManager.speed)
                ///set the camera region centered at user location and follow it with megnatic heading
                MapViewAPI.setCameraRegion(of: mapView, centeredAt: userLocation, userHeading: parent.locationDataManager.userHeading, animated: parent.animated, distance: camDistance)
                ///start navigate the user to destination
            
                    MapViewAPI.startNavigation(in: mapView, parent: &parent)
                ///when user is back in navigation mode keep the animation flag to true once camera is centerd.
                    parent.animated = true
                break
                ///show directions mode.
                case .showDirections:
                    ///if status is already updated skip this case.
                    guard let suggestedLocations = parent.localSearch.suggestedLocations else {
                        ///clear all entities from mapview.
                        parent.clearEntities(from: mapView)
                        ///make the mapview to go in idle mode.
                        self.parent.mapViewAction = .idle
                        return
                    }
                    parent.locationDataManager.enableGeocoding = true
                ///if status is not set to showing directions yet
                if parent.mapViewStatus != .showingDirections {
                    if parent.localSearch.status == .showingNearbyLocations {
                        mapView.removeAnnotations(mapView.annotations)
                        if let annotation = parent.tappedAnnotation {
                            mapView.addAnnotation(annotation)
                        }
                        ///get the navigation directions laid out from overlay renderer to map between user location and destination.
                        MapViewAPI.getNavigationDirections(in: mapView, from: mapView.userLocation.coordinate, to: parent.tappedAnnotation!.coordinate)
                    }
                    else {
                        ///get the navigation directions laid out from overlay renderer to map between user location and destination.
                        MapViewAPI.getNavigationDirections(in: mapView, from: mapView.userLocation.coordinate, to: suggestedLocations.first?.coordinate)
                    }
                }
               
                parent.mapViewStatus = .showingDirections
                ///if the routeData is empty and routes are laid upon the mapVIew.
                if parent.routeData.isEmpty && MapViewAPI.isRoutesrequestProcessed {
                    ///iterate through the routes
                    for route in MapViewAPI.routes {
                        ///extract the route travel time, distance, name and a uniue string from routes and append it to routeData along with unique id and tapped flag set/reset.
                        let distance = route.distance < 1000 ? (round(Double(route.distance)/50) * 50.0) : Double(route.distance/1000.0)
                        var distanceString = ""
                        ///if distance unit is in miles
                        if MapViewAPI.distanceUnit == .miles {
                            ///convert the distance to formated string in miles/ft
                            distanceString = MapViewAPI.convertToMiles(from: route.distance)
                        }
                        ///if distance unit is not in miles
                        else {
                            ///convert the distance to formated string in km/meters
                            distanceString = route.distance < 1000 ? String(format:"%.0f",distance) + " m" : String(format:"%.1f",distance) + " km"
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
                        parent.routeData.append(RouteData(id: UUID(),travelTime: ETA, distance: distanceString, title: route.name , tapped: MapViewAPI.routes.firstIndex(of: route) == (MapViewAPI.routes.count - 1) ? true : false, uniqueString: route.polyline.title ?? "n/a", hasTolls: route.hasTolls))
                    }
                }
                if parent.isRouteSelectTapped {
                    DispatchQueue.main.async { [self] in
                        let str = MapViewAPI.setSelectedRoute(for: mapView, with: parent.routeData, action: {})
                        ///format the travel time and store it in routeTravelTime
                        parent.routeTravelTime = str.0
                        ///format the route distance and store it in routeDistance
                        parent.routeDistance = str.1
                    }
                    parent.isRouteSelectTapped = false
                }
                    break
            }
        }
    }
    
    ///this function needs to be declared to be able to conform to UIViewRepresentable protocol
    ///this function will be called by SwiftUI when swiftUI is ready to display the MapView.
    func makeUIView(context: Context) -> MKMapView {
        ///setting our coordinator object as a delegate of mapView object. this will allow coordinator object to detect any changes in mapView object (data or view updates). based on these changes, any associated methods declared in coordinator will be executed. this way we can manipulate the data and deal with the user inteactions in mapviews.
        context.coordinator.mapView.delegate = context.coordinator
        ///this will show a blip where the user location is in the map. if we don't set this property, mapView won't be able to get location updates.
        context.coordinator.mapView.showsUserLocation = true
        ///add a gesture recognizer to coordinator.
        context.coordinator.mapView.addGestureRecognizer(context.coordinator.tapGestureRecognizer)
        ///return the mapview object.
        return context.coordinator.mapView
    }
    
    ///this method will be executed whenever our UIViewController is going to be updated.UIViewController will be updated when our swiftui view MapView will be updated. Mapview will be updated when our @observedObject / @StateObject is updated.
     func updateUIView(_ uiView: MKMapView, context: Context) {
        switch mapViewAction {
            ///map in idle mode.
            case .idle:
            DispatchQueue.main.async {
                self.routeData.removeAll()
            }
                ///if status is not updated
            if self.mapViewStatus != .idle && self.mapViewStatus != .notCentered {
                    DispatchQueue.main.async {
                        ///reset the location tracking
                        if self.localSearch.status != .localSearchCancelled {
                            MapViewAPI.resetLocationTracking(of: uiView, parent: &context.coordinator.parent)
                            uiView.animatedZoom(zoomRegion: MKCoordinateRegion(center: uiView.userLocation.coordinate, latitudinalMeters: 1000, longitudinalMeters: 1000), duration: TimeInterval(0.1))
                            ///set the status to idle
                            self.mapViewStatus = .idle
                            self.timeInterval = false
                        }
                       
                    }
                }
            self.handleLocationSearch(in: uiView, for: self.localSearch.status)
                break
            ///idle in showdirections  mode.
            case .idleInshowDirections:
                ///reset the user tracking.
                uiView.setUserTrackingMode(.none, animated: true)
            guard localSearch.suggestedLocations != nil else {
                DispatchQueue.main.async {
                    ///clear the entities from mapview
                    self.clearEntities(from: uiView)
                    ///make the map view to go in idle mode
                    self.mapViewAction = .idle
                 }
                return
            }
            ///if the route is tapped
            if isRouteSelectTapped {
                ///set the seleted route from the mapView and get the string from a given route with route travel time and distance info
                let str = MapViewAPI.setSelectedRoute(for: uiView, with: routeData) {
                }
                ///format the travel time and store it in routeTravelTime
                routeTravelTime = str.0
                ///format the route distance and store it in routeDistance
                routeDistance = str.1
            }
            isRouteSelectTapped = false
            break
            ///idle in navigation mode.
            case .idleInNavigation:
            if self.mapViewStatus == .inNavigationNotCentered {
                DispatchQueue.main.async {
                    self.animated = false
                }
            }
                break
            ///center to user location mode
            case.centerToUserLocation:
                 ///if the status is not updated
            if self.mapViewStatus != .centeredToUserLocation {                
                    DispatchQueue.main.async {
                        ///zoom the map to user location
                        uiView.animatedZoom(zoomRegion: MKCoordinateRegion(center: uiView.userLocation.coordinate, latitudinalMeters: 1000, longitudinalMeters: 1000), duration: TimeInterval(0.1))
                        self.mapViewStatus = .centeredToUserLocation
                    }
                }
            
            self.handleLocationSearch(in: uiView, for: self.localSearch.status)
                break
            ///in navigation mode center map to userlocation
            case .inNavigationCenterToUserLocation:
                if let heading = locationDataManager.userHeading {
                    ///get cam distance to be set based on the current speed.
                    let camDistance = MapViewAPI.getCameraDistanceFromMapView(atSpeed: self.locationDataManager.speed)
                    ///instantiate the MKMapCamera object with center as user location, distance (camera zooming to center),
                    ///pitch(camera angle) and camera heading set to user heading relative to  true north of camera.
                    MapViewAPI.setCameraRegion(of: uiView, centeredAt: uiView.userLocation, userHeading: heading, animated: animated, distance: camDistance)
                    
                }
              fallthrough
            
            ///start navigation
            case .navigate:
                ///if navigation is not updated.
                if mapViewStatus != .navigating {
                    ///get cam distance to be set based on the current speed.
                    let camDistance = MapViewAPI.getCameraDistanceFromMapView(atSpeed: self.locationDataManager.speed)
                     ///set the camera region centered to user location and follow it using heading updated.
                    MapViewAPI.setCameraRegion(of: uiView, centeredAt: uiView.userLocation, userHeading: self.locationDataManager.userHeading, animated: animated, distance: camDistance)
                    DispatchQueue.main.async {
                        self.timeInterval = true
                        ///navigate to the destination.
                        MapViewAPI.startNavigation(in: uiView, parent: &context.coordinator.parent)
                    }
                }
            ///get the last user location if available
            if let thisUserLocation = locationDataManager.lastUserlocation {
                ///if the speed is above 0 in m/s.
                if thisUserLocation.speed > 0 {
                    ///convert it to km/h
                    locationDataManager.speed = Int(thisUserLocation.speed * 3.6)
                }
                ///if the speed is 0 in m/s.
                else {
                    ///set it to 0.
                    locationDataManager.speed = 0
                }
            }
            ///get the last user location if not available
            else {
                ///set it to 0.
                locationDataManager.speed = 0
            }
                break
            ///show directions mode
            case .showDirections:
                ///show the directions for a given destination by drawing overlays.
            
                guard let suggestedLocations = localSearch.suggestedLocations else {
                    DispatchQueue.main.async {
                        ///clear the entities from mapview
                        self.clearEntities(from: uiView)
                        ///make the map view to go in idle mode
                        self.mapViewAction = .idle
                     }
                    return
                }
            
            DispatchQueue.main.async {
                self.locationDataManager.enableGeocoding = true
            }
            if mapViewStatus != .showingDirections {
                if localSearch.status == .showingNearbyLocations {
                   
                    uiView.removeAnnotations(uiView.annotations)
                    if let annotation = self.tappedAnnotation {
                        uiView.addAnnotation(annotation)
                    }
                   
                    ///get the navigation directions laid out from overlay renderer to map between user location and destination.
                    MapViewAPI.getNavigationDirections(in: uiView, from: uiView.userLocation.coordinate, to: self.tappedAnnotation!.coordinate)
                }
                else {
                    ///get the navigation directions laid out from overlay renderer to map between user location and destination.
                    MapViewAPI.getNavigationDirections(in: uiView, from: uiView.userLocation.coordinate, to: suggestedLocations.first?.coordinate)
                }
            }
           
            DispatchQueue.main.async { [self] in
                mapViewStatus = .showingDirections
                ///if the routeData is empty and routes are laid upon the mapVIew.
                if routeData.isEmpty && MapViewAPI.isRoutesrequestProcessed  {
                ///iterate through the routes
                for route in MapViewAPI.routes {
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
                    ///extract the route travel time, distance, name and a uniue string from routes and append it to routeData along with unique id and tapped flag set/reset.
                    routeData.append(RouteData(id: UUID(),travelTime: ETA, distance: MapViewAPI.distanceUnit == .miles ? MapViewAPI.convertToMiles(from: route.distance) : String(format:"%.1f",Double(route.distance/1000.0)) + " km", title: route.name, tapped: MapViewAPI.routes.firstIndex(of: route) == (MapViewAPI.routes.count - 1) ? true : false, uniqueString: route.polyline.title ?? "n/a", hasTolls: route.hasTolls))
                }
            }
            ///if the route is tapped
                if isRouteSelectTapped {
                    let str = MapViewAPI.setSelectedRoute(for: uiView, with: routeData) {
                        
                    }
                    ///format the travel time and store it in routeTravelTime
                    routeTravelTime = str.0
                    ///format the route distance and store it in routeDistance
                    routeDistance = str.1
                    }
                isRouteSelectTapped = false
            }
            break
        }
    }
}
///extension of MapView Struct
extension MapView {
    ///method to handle location search interface,
    func handleLocationSearch(in uiView: MKMapView, for status: LocalSearchStatus) {
        switch status {
        case .localSearchFailed:
            break
        case .locationUnselected:
           /// localSearch.suggestedLocations = nil
            if !uiView.overlays.isEmpty {
                DispatchQueue.main.async {
                    localSearch.suggestedLocations = nil
                    ///make sure there are no overlays while only destination is selected yet and not the directions requested.
                    uiView.removeOverlays(uiView.overlays)
                    uiView.removeAnnotations(uiView.annotations)
                    ///reset the flag.
                }
            }
            
            break
        case .localSearchCancelled:
            guard uiView.annotations.count > 1 else {
                return
            }
            DispatchQueue.main.async {
                self.localSearch.suggestedLocations = nil
                self.tappedAnnotation = nil
                self.mapViewAction = .idle
                self.mapViewStatus = .notCentered
                self.routeData.removeAll()
               ///remove the annotations
               uiView.removeAnnotations(uiView.annotations)
               ///remove the overlays
               uiView.removeOverlays(uiView.overlays)
           }
        case .localSearchInProgress:
            DispatchQueue.main.async {
                localSearch.suggestedLocations = nil
            }
            break
        case .localSearchResultsAppear:
            DispatchQueue.main.async {
                self.clearEntities(from: uiView)
            }
            break
        case .locationSelected:
            guard let locations = localSearch.suggestedLocations else {
                DispatchQueue.main.async {
                    ///make sure there are no overlays while only destination is selected yet and not the directions requested.
                    uiView.removeOverlays(uiView.overlays)
                    ///reset the flag.
                }
                break
            }
            guard let location = locations.first else {
                break
            }
            if uiView.annotations.count <= 1 {
                MapViewAPI.annotateLocation(in: uiView, at: location.coordinate, for: location)
            }
            if !uiView.overlays.isEmpty {
                DispatchQueue.main.async {
                    ///make sure there are no overlays while only destination is selected yet and not the directions requested.
                    uiView.removeOverlays(uiView.overlays)
                    ///reset the flag.
                }
            }
            
        case .showingNearbyLocations:
            guard let locations = localSearch.suggestedLocations else {
                return
            }
           
            if self.tappedAnnotation != nil {
                DispatchQueue.main.async {
                   uiView.animatedZoom(zoomRegion: MKCoordinateRegion(center: self.tappedAnnotation!.coordinate, latitudinalMeters: 1000, longitudinalMeters: 1000), duration: TimeInterval(0.1))
                }
            }
            else {
                for searchedLocation in locations {
                    MapViewAPI.annotateLocations(in: uiView, at: searchedLocation.coordinate, for: searchedLocation)
                }
            }
            if !uiView.overlays.isEmpty {
                DispatchQueue.main.async {
                    ///make sure there are no overlays while only destination is selected yet and not the directions requested.
                    uiView.removeOverlays(uiView.overlays)
                    ///reset the flag.
                }
            }
        case .searchBarActive:           
            break
        }
    }
    
    ///remove entities from map.
    func clearEntities(from mapView: MKMapView) {
        ///if overlays are present in the mapview
        if !mapView.overlays.isEmpty {
              ///remove the overlays
            mapView.removeOverlays(mapView.overlays)
        }
        ///if annotations are present in the mapview
        if mapView.annotations.count > 1 {
            ///remove the annotations.
            mapView.removeAnnotations(mapView.annotations)
        }
    }
}

extension MKMapView {
    func animatedZoom(zoomRegion:MKCoordinateRegion, duration:TimeInterval) {
        MKMapView.animate(withDuration: duration, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 10, options: UIView.AnimationOptions.curveEaseIn, animations: {
            self.setRegion(zoomRegion, animated: true)
            }, completion: nil)
    }    
}
