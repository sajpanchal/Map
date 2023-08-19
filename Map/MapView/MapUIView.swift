//
//  MapViewController.swift
//  Map
//
//  Created by saj panchal on 2023-08-03.
//

import Foundation
//module requires to use UIViewControllerRepresentable protocol
import SwiftUI
//module requires to use UIViewController and other UIKit ViewControllers, views and its methods, properties etc.
import UIKit
//module requires to use MapKit classes, structs and its methods/properties..
import MapKit


//create a custom struct called MapView and conform it to UIViewRepresentable.
//this class is only responsible to display map and its accessories.
struct MapView: UIViewRepresentable {
    typealias UIViewType = MKMapView
    //this property holds the location coordinate values accessed from core location. it is passed by Map SwiftUI.
    @Binding var location: CLLocation?
    //this property is bound to the tapped property of Map SwiftUI. it will be true when re-center button is pressed from Map SwiftUI.
    @Binding var mapViewAction: MapViewAction
    //this property holds the user's current heading data accessed from core location. it is passed by Map SwiftUI
    @Binding var heading: CLHeading?
    //this property holds the error codes that we have defined in enum type in Map SwiftUI file.
    @Binding var mapError: Errors
    //this property is needed to set the map region centered to user's location when app is launched for the first time.
    @Binding var mapViewStatus: MapViewStatus
    var region: MKCoordinateRegion?
    //this is the function that our MapView will execute the first time on its inception.
    //this function will instantiate the Coordinator class with a copy of its parent object.
    func makeCoordinator() -> (Coordinator) {
        print("make coordinator")
        return Coordinator(self)
    }
    //Coordinator is a class reponsible to communicate the behaviour of our UIKit/Appkit object and makes necessary changes to our swiftui
    //objects. it enables us to do so by updating the properties of this class or executing UIKit/AppKit methods.
    //here, we are making our cooridator a subclass of NSObject. We are also conforming to the MKMapViewDelegate protocol which enables us to
    //use MKMapView methods that will be executed on updates to our MapView and CoreLocation data.
    //Also, we are setting a property called parent as MapView type and setting its delegate as a coordinator object. So, when any of the
    //event related to MapView occurs a delegator will detect those changes, a relevant function we have declared in the Delegator
    //(Coordinator) will be executed. inside the methods, we make changes to our UIView based on the changes in associated data.
    class Coordinator: NSObject, MKMapViewDelegate {
        //setting MapView as its parent view
        var parent: MapView
        
        init(_ parent: MapView) {
            //setting a parent property as parent on initialization
            self.parent = parent
        }
        //if mapView couldn't find the user location this function will be called.
        func mapView(_ mapView: MKMapView, didFailToLocateUserWithError error: Error) {
            //we will handle the error by updating our enum type variable in Map SwiftUI. It will then print the error message in text field.
            parent.mapError = Errors.locationNotFound
        }
        
        //this is the delegate method that will be called whenever user location will update
        func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
            MapViewAPI.setRegionIn(mapView: mapView, centeredAt: userLocation, parent: &parent)
                
            // if the track location button is tapped
            switch parent.mapViewAction {
                case .idle:
                    parent.mapViewStatus = .idle
                    break
                case .idleInNavigation:
                    parent.mapViewStatus = .inNavigationNotCentered
                    break
                case.centerToUserLocation:
                    parent.mapViewStatus = .centeredToUserLocation
                    break
                case .inNavigationCenterToUserLocation:
                    fallthrough
                case .navigate:
                //if user heading is not nil
                    MapViewAPI.setCameraRegion(of: mapView, centeredAt: userLocation, userHeading: parent.heading)
                    if parent.heading != nil {
                        parent.mapViewStatus = .navigating
                    }
                    //if heading is found nil
                    else {
                        //handle the error by updating enum variable in Map SwiftUI.
                        parent.mapError = .headingNotFound
                    }
                break
            }
        }
    }
    
    
    //this function needs to be declared to be able to conform to UIViewRepresentable protocol
    //this function will be called by SwiftUI when swiftUI is ready to display the MapView.
    func makeUIView(context: Context) -> MKMapView {
        print("make map view")
        //create an instance of MKMapView.
        let mapView = MKMapView()
        //setting our coordinator object as a delegate of mapView object.
        //this will allow coordinator object to detect any changes in mapView object (data or view updates).
        //based on these changes, any associated methods declared in coordinator will be executed.
        //this way we can manipulate the data and deal with the user inteactions in mapviews.
        mapView.delegate = context.coordinator
        //this will show a blip where the user location is in the map.
        //if we don't set this property, mapView won't be able to get location updates.
        mapView.showsUserLocation = true
        //return the mapview object.
        return mapView
    }
    
    //this method will be executed whenever our UIViewController is going to be updated.
    //UIViewController will be updated when our swiftui view MapView will be updated.
    //Mapview will be updated when our @observedObject / @StateObject is updated.
    func updateUIView(_ uiView: MKMapView, context: Context) {
    print("updating map view")
       
    switch mapViewAction {
    case .idle:
        MapViewAPI.resetLocationTracking(of: uiView)
        break
    case .idleInNavigation:
        break
    case.centerToUserLocation:
            uiView.animatedZoom(zoomRegion: MKCoordinateRegion(center: uiView.userLocation.coordinate, latitudinalMeters: 1000, longitudinalMeters: 1000), duration: TimeInterval(0.1))
        print("map is centered!")
        break
    case .inNavigationCenterToUserLocation:
        if let heading = heading {
            //instantiate the MKMapCamera object with center as user location, distance (camera zooming to center),
            //pitch(camera angle) and camera heading set to user heading relative to  true north of camera.
            MapViewAPI.setCameraRegion(of: uiView, centeredAt: uiView.userLocation, userHeading: heading)
        }
       break
 
    case .navigate:
        break
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
