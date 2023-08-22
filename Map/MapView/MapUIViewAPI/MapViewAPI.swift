//
//  MapViewAPI.swift
//  Map
//
//  Created by saj panchal on 2023-08-19.
//

import Foundation
import MapKit

class MapViewAPI {
    //this method will accept the mapView, userLocation class instances. here mapView struct instance as inout parameter.
    //inout parameter allows us to make func parameter mutable i.e. we can change the value of the parameter in a function directly and
    //changes will be reflected outside the function after execution.
    static func setRegionIn(mapView: MKMapView, centeredAt userLocation: MKUserLocation, parent: inout MapView) {
        //when this function will be called for the very first time, the region property of our mapView struct will be nil.
        //so the code inside this if statement will be executed only one time.
        guard parent.region != nil else {
            //dispatchqueue is a class that handles the execution of tasks serially or concurrently on apps main/background threads.
            //here we are using a main (serial queue) thread and executing a code inside the block asynchronously in it.
            //that means the main thread is not going to wait until this code is executed and it will perform remaining tasks serially.
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
    
    static func resetLocationTracking(of mapView: MKMapView) {
        DispatchQueue.main.async {
            //undoing user tracking to none.
            mapView.setUserTrackingMode(.none, animated: true)
        }
    }
    
    static func getNavigationDirections() {
    
    }

}
