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
    ///this is the state property of Map SwiftUI view that will be true when user has tapped to a destination in a search field results.
    @Binding var isLocationSelected: Bool
    ///this is the state property of the Map SwiftUI view that will be true when user has cleared the search field.
    @Binding var isSearchCancelled: Bool
    ///this ist the state object of Map Swiftui view that is going to handle the location search
    @Binding var instruction: String
    @StateObject var localSearch: LocalSearch
    @StateObject var locationDataManager: LocationDataManager
    @Binding var nextStepLocation: CLLocation?
    @Binding var nextStepDistance: String
    @Binding var status: String
    @Binding var routeETA: String
    @Binding var routeDistance: String
    @Binding var distance: String
    @Binding var destination: String
    @Binding var stepInstructions: [(String, Double)]
    var region: MKCoordinateRegion?


    ///this is the function that our MapView will execute the first time on its inception. this function will instantiate the Coordinator class with a copy of its parent object.
    func makeCoordinator() -> (Coordinator) {
        print("make coordinator")
        return Coordinator(self)
    }
    ///Coordinator is a class reponsible to communicate the behaviour of our UIKit/Appkit object and makes necessary changes to our swiftuiobjects. it enables us to do so by updating the properties of this class or executing UIKit/AppKit methods. here, we are making our cooridator a subclass of NSObject. We are also conforming to the MKMapViewDelegate protocol which enables us to use MKMapView methods that will be executed on updates to our MapView and CoreLocation data. Also, we are setting a property called parent as MapView type and setting its delegate as a coordinator object. So, when any of the event related to MapView occurs a delegator will detect those changes, a relevant function we have declared in the Delegator (Coordinator) will be executed. inside the methods, we make changes to our UIView based on the changes in associated data.
    class Coordinator: NSObject, MKMapViewDelegate, UIGestureRecognizerDelegate {
        //setting MapView as its parent view
        var parent: MapView
        var mapView = MKMapView()
        var tapGestureRecognizer = UITapGestureRecognizer()
        var isOverlayTapped = false
        init(_ parent: MapView) {
            //setting a parent property as parent on initialization
            self.parent = parent
            super.init()
            self.tapGestureRecognizer.addTarget(self, action: #selector(handleTapGesture))
            self.tapGestureRecognizer.delegate = self
        }
    
        @objc func handleTapGesture() {
            let result = MapViewAPI.isOvarlayTapped(in: self.mapView, by: tapGestureRecognizer)
            isOverlayTapped = result.0
            let title = result.1
            if !isOverlayTapped {
            print("not tapped")
            }
            else {
                MapViewAPI.setTappedOverlay(in: self.mapView, having: title, parent: &self.parent)
            }
        }
        
        ///if mapView couldn't find the user location this function will be called.
        func mapView(_ mapView: MKMapView, didFailToLocateUserWithError error: Error) {
            ///we will handle the error by updating our enum type variable in Map SwiftUI. It will then print the error message in text field.
            parent.mapError = Errors.locationNotFound
        }
        
       ///this function will be called once the overlay is added to the mapview object
        func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {

            let renderer = MKPolylineRenderer(overlay: overlay)
            
            renderer.lineWidth = 10
            
                if renderer.polyline.subtitle == "fastest route" {
                        renderer.strokeColor = .systemBlue
                    renderer.alpha = 1
                    let routeData = renderer.polyline.title?.split(separator: ", ") ?? []
                    parent.routeETA = String(routeData.first ?? "") + " mins"
                    parent.routeDistance = String(routeData.last ?? "") + " km"
                }
                else {
                        renderer.strokeColor = .systemGray
                    renderer.alpha = 0.5
                }
            
            return renderer
            
        }
     
        
        ///this is the delegate method that will be called whenever user location will update
        @MainActor func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
            MapViewAPI.setRegionIn(mapView: mapView, centeredAt: userLocation, parent: &parent)
            
            switch parent.mapViewAction {
                case .idle:
                if parent.mapViewStatus != .idle {
                    MapViewAPI.resetLocationTracking(of: mapView, parent: &parent)
                    parent.routeETA = ""
                    parent.routeDistance = ""
                    parent.mapViewStatus = .idle
                }
                guard let searchedLocation = parent.localSearch.tappedLocation else {
                    if !mapView.overlays.isEmpty {
                        print("removing overlays")
                        mapView.removeOverlays(mapView.overlays)
                    }
                    if !mapView.annotations.isEmpty && parent.localSearch.searchableText.isEmpty {
                        print("removing annotations!")
                        mapView.removeAnnotations(mapView.annotations)
                    }
                    return
                }
                parent.searchLocationInterface(in: mapView, for: searchedLocation.first!) {
                }
               
                
                    break
                case .idleInshowDirections:
                print("idleInshowDirections!")
                    mapView.setUserTrackingMode(.none, animated: true)
                case .idleInNavigation:
                print("idleInNavigation!")
                    parent.mapViewStatus = .inNavigationNotCentered
                    break
                case.centerToUserLocation:
                print("centerToUserLocation!")
                    parent.mapViewStatus = .centeredToUserLocation
                    break
                case .inNavigationCenterToUserLocation:
                print("inNavigationCenterToUserLocation!")
                    fallthrough
                case .navigate:
                print("navigate!")
               // parent.mapViewStatus = .navigating
                    MapViewAPI.setCameraRegion(of: mapView, centeredAt: userLocation, userHeading: parent.locationDataManager.userHeading)
                    MapViewAPI.startNavigation(in: mapView, parent: &parent)
                    ///if user heading is not nil
                if parent.locationDataManager.userHeading != nil {
                       
                    }
                    ///if heading is found nil
                    else {
                        ///handle the error by updating enum variable in Map SwiftUI.
                        parent.mapError = .headingNotFound
                    }
                
                break
            case .showDirections:
                print("showDirections!")
                if parent.mapViewStatus == .showingDirections {
                    break
                }
               
                
                if parent.isSearchCancelled {
                    mapView.removeAnnotations(mapView.annotations)
                    mapView.removeOverlays(mapView.overlays)
                    parent.localSearch.tappedLocation = nil
                    self.parent.mapViewAction = .idle
                    print("idle mode is back")
                }
                else {
                    mapView.showAnnotations(mapView.annotations, animated: true)
                    MapViewAPI.getNavigationDirections(in: mapView, from: mapView.userLocation.coordinate, to: parent.localSearch.tappedLocation?.first?.coordinate)
                   
                }
                parent.mapViewStatus = .showingDirections
                break
            }
        }
    }
    
    ///this function needs to be declared to be able to conform to UIViewRepresentable protocol
    ///this function will be called by SwiftUI when swiftUI is ready to display the MapView.
    func makeUIView(context: Context) -> MKMapView {
        print("make map view")
        //create an instance of MKMapView.
       // let mapView = MKMapView()
        ///setting our coordinator object as a delegate of mapView object. this will allow coordinator object to detect any changes in mapView object (data or view updates). based on these changes, any associated methods declared in coordinator will be executed. this way we can manipulate the data and deal with the user inteactions in mapviews.
        context.coordinator.mapView.delegate = context.coordinator
        ///this will show a blip where the user location is in the map. if we don't set this property, mapView won't be able to get location updates.
        context.coordinator.mapView.showsUserLocation = true
        
        context.coordinator.mapView.addGestureRecognizer(context.coordinator.tapGestureRecognizer)
        ///return the mapview object.
        return context.coordinator.mapView
    }
    
    ///this method will be executed whenever our UIViewController is going to be updated.UIViewController will be updated when our swiftui view MapView will be updated. Mapview will be updated when our @observedObject / @StateObject is updated.
    func updateUIView(_ uiView: MKMapView, context: Context) {
        switch mapViewAction {
            case .idle:
            if self.mapViewStatus != .idle {
                DispatchQueue.main.async {
                MapViewAPI.resetLocationTracking(of: uiView, parent: &context.coordinator.parent)
               
                    self.routeETA = ""
                    self.routeDistance = ""
                    self.mapViewStatus = .idle
                }
                
            }
            guard let searchedLocation = self.localSearch.tappedLocation else {
                DispatchQueue.main.async {
                    if !uiView.overlays.isEmpty {
                        print("removing overlays")
                        uiView.removeOverlays(uiView.overlays)
                    }
                    if !uiView.annotations.isEmpty && self.localSearch.searchableText.isEmpty {
                        print("removing annotations!")
                        uiView.removeAnnotations(uiView.annotations)
                    }
                }
                
                return
            }
            self.searchLocationInterface(in: uiView, for: searchedLocation.first!) {
            }
                break
            case .idleInshowDirections:
            print("idleInshowDirections")
                uiView.setUserTrackingMode(.none, animated: true)
            break
            case .idleInNavigation:
                //mapViewStatus = .inNavigationNotCentered
            print("idleInNavigation")
                break
            case.centerToUserLocation:
            print("centerToUserLocation")
            if let searchedLocation = localSearch.tappedLocation {
                searchLocationInterface(in: uiView, for: searchedLocation.first!) {
                        DispatchQueue.main.async {
                          
                        }
                    }
                }
            else {
                DispatchQueue.main.async {
                    if uiView.annotations.isEmpty {
                        uiView.removeAnnotations(uiView.annotations)
                    }
                    if !uiView.overlays.isEmpty {
                        uiView.removeOverlays(uiView.overlays)
                    }
                   
                }
            }
            if self.mapViewStatus != .centeredToUserLocation {
                DispatchQueue.main.async {
                    uiView.animatedZoom(zoomRegion: MKCoordinateRegion(center: uiView.userLocation.coordinate, latitudinalMeters: 1000, longitudinalMeters: 1000), duration: TimeInterval(0.1))
                    self.mapViewStatus = .centeredToUserLocation
                }
            }
                break
            case .inNavigationCenterToUserLocation:
            print("inNavigationCenterToUserLocation")
                if let heading = locationDataManager.userHeading {
                    //instantiate the MKMapCamera object with center as user location, distance (camera zooming to center),
                    //pitch(camera angle) and camera heading set to user heading relative to  true north of camera.
                    MapViewAPI.setCameraRegion(of: uiView, centeredAt: uiView.userLocation, userHeading: heading)
                }
               break
            case .navigate:
            print("navigate")
            if mapViewStatus != .navigating {
                
              
                print("navigating from update UIView.")
                MapViewAPI.setCameraRegion(of: uiView, centeredAt: uiView.userLocation, userHeading: self.locationDataManager.userHeading)
                DispatchQueue.main.async {
                    MapViewAPI.startNavigation(in: uiView, parent: &context.coordinator.parent)
                }
              
                
             
            }
                break
            case .showDirections:
          
              //  parent.mapViewStatus = .showingDirections
            print("showdirections")
                if isSearchCancelled {
                    print("search cancelled....")
                    uiView.removeAnnotations(uiView.annotations)
                    uiView.removeOverlays(uiView.overlays)
                   
                   
                     DispatchQueue.main.async {
                         localSearch.tappedLocation = nil
                         self.mapViewAction = .idle
                     print("idle mode is back")
                     }
                    break
                }
                else {
                    DispatchQueue.main.async {
                        self.isLocationSelected = true
                    }
                   
                    MapViewAPI.getNavigationDirections(in: uiView, from: uiView.userLocation.coordinate, to: localSearch.tappedLocation?.first?.coordinate)
                    uiView.showAnnotations(uiView.annotations, animated: true)
                }
                break
        }
    }
}

extension MapView {
    func searchLocationInterface(in uiView: MKMapView, for searchedLocation: MKAnnotation, action: () -> ()) {
        if self.isLocationSelected {
            print("location is selected")
            MapViewAPI.annotateLocation(in: uiView, at: searchedLocation.coordinate, for: searchedLocation)
            DispatchQueue.main.async {
                uiView.removeOverlays(uiView.overlays)
                self.isLocationSelected = false
            }
           
            
        }
        else if isSearchCancelled {
            print("location cancelled")
            DispatchQueue.main.async {
                uiView.removeAnnotations(uiView.annotations)
                uiView.removeOverlays(uiView.overlays)
            }
           
          
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
