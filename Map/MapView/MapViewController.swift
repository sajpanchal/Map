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


//create a custom struct called MapViewController and conform it to UIViewControllerRepresentable.
//this class is only responsible to display map and its accessories.
struct MapViewController: UIViewControllerRepresentable {
    typealias UIViewControllerType = UIViewController
    //this property holds the location coordinate values accessed from core location. it is passed by MapView.
    var location: CLLocation?
    //create an instance of UIViewController
    let viewController = UIViewController()
    //create an instance of MKMapView.
    let mapView = MKMapView()
    
    //this function needs to be declared to be able to conform to UIViewConrollerRepresentable protocl
    //this function will be called by SwiftUI when swiftUI is ready to display the MapView.
    func makeUIViewController(context: Context) -> UIViewController {
        //set a view inside a viewController as MKMapView instance.
        viewController.view = mapView
        
        //return that viewController.
        return viewController
    }
    
    //this method will be executed whenever our UIViewController is going to be updated.
    //UIViewController will be updated when our swiftui view MapView will be updated.
    //Mapview will be updated when our @observedObject / @StateObject is updated.
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
       //this will show the user location beacon in the app.
        mapView.showsUserLocation = true
      
        //create an instance for MKCoordinateSpan to be used to set as a rectangular region from the center of the map
        var mkCoordinateSpan =  MKCoordinateSpan()
        
        //if user location is available
        if let userLocation = location {
            //lower the degrees more zoomming to the map center
            mkCoordinateSpan.longitudeDelta = 0.05
            mkCoordinateSpan.latitudeDelta = 0.05
            
            //set the map region with instantiating MKCoordinateRegion
            mapView.region = MKCoordinateRegion(center: userLocation.coordinate, span: mkCoordinateSpan)
          //  mapView.camera.centerCoordinate = userLocation.coordinate
            mapView.userTrackingMode = .follow
            
            //update the UIView of ViewController with the updated mapView.
            uiViewController.view = mapView
        
        }
    }
    
    
    
    
    
    
}
