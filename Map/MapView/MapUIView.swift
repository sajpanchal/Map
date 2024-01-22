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



///create a custom struct called MapView and conform it to UIViewRepresentable. this class is only responsible to display map and its accessories.
struct MapView: UIViewRepresentable {
    typealias UIViewType = MKMapView
    ///this property holds the location coordinate values accessed from core location. it is passed by Map SwiftUI.
  //  @Binding var location: CLLocation?
    ///this property is bound to the tapped property of Map SwiftUI. it will be true when re-center button is pressed from Map SwiftUI.
    @Binding var mapViewAction: MapViewAction
    ///this property holds the user's current heading data accessed from core location. it is passed by Map SwiftUI
//    @Binding var heading: CLHeading?
    ///this property holds the error codes that we have defined in enum type in Map SwiftUI file.
    @Binding var mapError: Errors
    ///this property is needed to set the map region centered to user's location when app is launched for the first time.
    @Binding var mapViewStatus: MapViewStatus
    ///this ist the state object of Map Swiftui view that is going to handle the location search
    @Binding var instruction: String
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
    ///travel distance for a given route
    @Binding var routeDistance: String
    ///remaining distance from the destination during navigation
    @Binding var remainingDistance: String
    ///address of the destination
    @Binding var destination: String
    ///an array of tuple storing step instruction and distance between the steps.
    @Binding var stepInstructions: [(String, Double)]
    ///temportily storing the region instance
    var region: MKCoordinateRegion?
    ///string to display the ETA for a given destination
    @Binding var ETA: String


    ///this is the function that our MapView will execute the first time on its inception. this function will instantiate the Coordinator class with a copy of its parent object.
    func makeCoordinator() -> (Coordinator) {
        print("make coordinator")
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
                renderer.strokeColor = .systemBlue
                ///set the transparency to lowest
                renderer.alpha = 1
                ///extract the route data from renderer title
                let routeData = renderer.polyline.title?.split(separator: ", ") ?? []
                ///set the travel time
                parent.routeTravelTime = String(routeData.first ?? "") + " mins"
                ///set the distance
                parent.routeDistance = String(routeData.last ?? "") + " km"
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
                    if parent.mapViewStatus != .idle {
                        ///reset the location tracking
                        MapViewAPI.resetLocationTracking(of: mapView, parent: &parent)
                        ///set the status to idle
                        parent.mapViewStatus = .idle
                    }
                    ///check if the localsearch object has a list of tappedLocations
                    guard let searchedLocation = parent.localSearch.suggestedLocations else {
                        ///clear entities from mapview
                        parent.clearEntities(from: mapView)
                        return
                    }
                    ///check if there is any action from searchfield and make necessary updates.
                    parent.searchLocationInterface(in: mapView, for: searchedLocation.first!)
                    break
                
                ///idle in showdirections  mode.
                case .idleInshowDirections:
                    print("idleInshowDirections!")
                    ///reset the user tracking.
                    mapView.setUserTrackingMode(.none, animated: true)
                
                ///idle in navigation mode.
                case .idleInNavigation:
                    print("idleInNavigation!")
                    parent.mapViewStatus = .inNavigationNotCentered
                    break
                
                ///center to user location mode
                case.centerToUserLocation:
                print("centerToUserLocation!")
                    parent.mapViewStatus = .centeredToUserLocation
                    break
                
                ///in navigation mode, center to user location
                case .inNavigationCenterToUserLocation:
                    print("inNavigationCenterToUserLocation!")
                    fallthrough
                
                ///navigation mode.
                case .navigate:
                   // print("navigate!")
                ///set the camera region centered at user location and follow it with megnatic heading
                    MapViewAPI.setCameraRegion(of: mapView, centeredAt: userLocation, userHeading: parent.locationDataManager.userHeading)
                ///start navigate the user to destination
                    MapViewAPI.startNavigation(in: mapView, parent: &parent)
                break
                
                ///show directions mode.
                case .showDirections:
                    print("showDirections!")
                    ///if status is already updated skip this case.
                    if parent.mapViewStatus == .showingDirections {
                        break
                    }
                    guard let suggestedLocations = parent.localSearch.suggestedLocations else {
                        ///clear all entities from mapview.
                        parent.clearEntities(from: mapView)
                        ///make the mapview to go in idle mode.
                        self.parent.mapViewAction = .idle
                        print("idle mode is back")
                        return
                    }
                    ///get the navigation directions laid out from overlay renderer to map between user location and destination.
                    MapViewAPI.getNavigationDirections(in: mapView, from: mapView.userLocation.coordinate, to: suggestedLocations.first?.coordinate)
                    
                    parent.mapViewStatus = .showingDirections
                    break
            }
        }
    }
    
    ///this function needs to be declared to be able to conform to UIViewRepresentable protocol
    ///this function will be called by SwiftUI when swiftUI is ready to display the MapView.
    func makeUIView(context: Context) -> MKMapView {
        print("make map view")
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
                ///if status is not updated
                if self.mapViewStatus != .idle {
                    DispatchQueue.main.async {
                        ///reset the location tracking
                        MapViewAPI.resetLocationTracking(of: uiView, parent: &context.coordinator.parent)
                        ///set the status to idle
                        self.mapViewStatus = .idle
                    }
                }
                ///check if the localsearch object has a list of tappedLocations
                guard let searchedLocation = self.localSearch.suggestedLocations else {
                    DispatchQueue.main.async {
                        ///clear entities from mapview
                        self.clearEntities(from: uiView)
                    }
                    return
                }
                ///check if there is any action from searchfield and make necessary updates.
                    self.searchLocationInterface(in: uiView, for: searchedLocation.first!)
                break
            
            ///idle in showdirections  mode.
            case .idleInshowDirections:
                print("idleInshowDirections")
                ///reset the user tracking.
                uiView.setUserTrackingMode(.none, animated: true)
            break
            
            ///idle in navigation mode.
            case .idleInNavigation:
                print("idleInNavigation")
                break
            
            ///center to user location mode
            case.centerToUserLocation:
                print("centerToUserLocation")
                ///if the status is not updated
                if self.mapViewStatus != .centeredToUserLocation {
                    DispatchQueue.main.async {
                        ///zoom the map to user location
                        uiView.animatedZoom(zoomRegion: MKCoordinateRegion(center: uiView.userLocation.coordinate, latitudinalMeters: 1000, longitudinalMeters: 1000), duration: TimeInterval(0.1))
                        self.mapViewStatus = .centeredToUserLocation
                    }
                }
                ///check if the localsearch object has a list of tappedLocations
                guard let searchedLocation = self.localSearch.suggestedLocations else {
                    DispatchQueue.main.async {
                        ///clear entities from mapview
                        self.clearEntities(from: uiView)
                    }
                    return
                }
                ///check if there is any action from searchfield and make necessary updates.
                    self.searchLocationInterface(in: uiView, for: searchedLocation.first!)
                break
            
            ///in navigation mode center map to userlocation
            case .inNavigationCenterToUserLocation:
                print("inNavigationCenterToUserLocation")
                if let heading = locationDataManager.userHeading {
                    ///instantiate the MKMapCamera object with center as user location, distance (camera zooming to center),
                    ///pitch(camera angle) and camera heading set to user heading relative to  true north of camera.
                    MapViewAPI.setCameraRegion(of: uiView, centeredAt: uiView.userLocation, userHeading: heading)
                }
               break
            
            ///start navigation
            case .navigate:
                //print("navigate")
                ///if navigation is not updated.
                if mapViewStatus != .navigating {
                    print("navigating from update UIView.")
                    ///set the camera region centered to user location and follow it using heading updated.
                    MapViewAPI.setCameraRegion(of: uiView, centeredAt: uiView.userLocation, userHeading: self.locationDataManager.userHeading)
                    DispatchQueue.main.async {
                        ///navigate to the destination.
                        MapViewAPI.startNavigation(in: uiView, parent: &context.coordinator.parent)
                    }
                }
                break
            
            ///show directions mode
            case .showDirections:
                print("showdirections")
                ///show the directions for a given destination by drawing overlays.
                guard let suggestedLocations = localSearch.suggestedLocations else {
                    DispatchQueue.main.async {
                        ///clear the entities from mapview
                        self.clearEntities(from: uiView)
                        ///make the map view to go in idle mode
                        self.mapViewAction = .idle
                        print("idle mode is back")
                    }
                    return
                }
                 MapViewAPI.getNavigationDirections(in: uiView, from: uiView.userLocation.coordinate, to: suggestedLocations.first?.coordinate)
               
                break
        }
    }
}
///extension of MapView Struct
extension MapView {
    ///method to handle location search interface,
    func searchLocationInterface(in uiView: MKMapView, for searchedLocation: MKAnnotation) {
        ///if the destination is selected
        if self.localSearch.isDestinationSelected {
            print("location is selected")
            ///annotate the location on the map and center the map to it.
            MapViewAPI.annotateLocation(in: uiView, at: searchedLocation.coordinate, for: searchedLocation)
            
            DispatchQueue.main.async {
                ///make sure there are no overlays while only destination is selected yet and not the directions requested.
                uiView.removeOverlays(uiView.overlays)
                ///reset the flag.
                self.localSearch.isDestinationSelected = false
            }
        }
        ///if search is cancelled.
        else if localSearch.isSearchCancelled {
            print("location cancelled")
            DispatchQueue.main.async {
                ///remove the annotations
                uiView.removeAnnotations(uiView.annotations)
                ///remove the overlays
                uiView.removeOverlays(uiView.overlays)
            }
        }
    }
    ///remove entities from map.
    func clearEntities(from mapView: MKMapView) {
        ///if overlays are present in the mapview
        if !mapView.overlays.isEmpty {
            print("removing overlays")
            ///remove the overlays
            mapView.removeOverlays(mapView.overlays)
        }
        ///if annotations are present in the mapview
        if !mapView.annotations.isEmpty  {
            print("removing annotations!")
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
