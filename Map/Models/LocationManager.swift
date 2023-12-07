//
//  LocationManager.swift
//  Map
//
//  Created by saj panchal on 2023-08-04.
//

import Foundation
import CoreLocation
import MapKit
//custom Location manager class that inherits NSObject class and CLlocationManageDelegate protocol
//this class also conforms to ObservableObject type-alias. it means that this instance will be obsered by swiftui view
// for any changes in data associated with it. to make it possible we just have to type-alias it as @ObservedObject.
//we have to do it as we as interfacing between structs and classes. structs are value types and classes are reference type

//LocationDataManager is responsible to handle user location authorization, gather all the user location data and track user data.

class LocationDataManager: NSObject, CLLocationManagerDelegate, ObservableObject {
    
    //locationManager object is instantiated in a class
    var locationManager = CLLocationManager()
    
    //this is a object property that will reflect the user location authorization status
    //it is set as a type-alieas @published. which makes updates to swiftui if this object is used in that swiftui view.
    @Published var userlocation: CLLocation?
    @Published var userHeading: CLHeading?
    @Published var region: MKCoordinateRegion = MKCoordinateRegion()
    @Published var overlayRegion: CLRegion?
    @Published var distance: CLLocationDistance?
    var lastLocation: CLLocation?
    @Published var speed: CLLocationSpeed = 0.0
    @Published var throughfare: String?
    @Published var enableGeocoding = true
    //overriding the initializer of NSObject class
    override init() {
        //execute the parent class initializer first
        super.init()
        //set the LocationDataManager object as a delegate of locationManager object.
        //when we set This class object as a delegate to the locationManage object, if there are any change in CLLocationManager,
        //it will be reflected in LocationDataManager automatically.
        locationManager.delegate = self
     
        
    }
    
    //before we setup this method we have to setup a key-value pair in info.plist file of our project.
    //this will be a privacy key that will pop up an alert when this app is launched asking user whether to allow
    //this app to access user location. if so corelocation will be instantiated.
    //delegate mathod to be executed when user updates their authorization status
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        //this method is passing our locationManager parameter in this body for use.
        //checking the authorizationStatus property of our manager object which holds the status of user location access
        switch manager.authorizationStatus {
            //this status means user has selected to allow location access when app is in use
            case .authorizedWhenInUse:
            //this will request one-time location update of the current user location.
                manager.startUpdatingLocation()
                manager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
                manager.startUpdatingHeading()
             //   manager.headingFilter = kCLHeadingFilterNone
                break
        
            //this status means user don't want app to track location
            case .restricted:
                break
            
            case .denied:
                break
            
            //this status means user has not given any input.
            case .notDetermined:
                //if the user didn't give any input, make a request to access location when app is in use.
                manager.requestWhenInUseAuthorization()
                break
            
            default:
                break
        }
    }
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        print("User entered to region: \(region.identifier)")
    }
    
    //this method will be called whenever a new user location is available.
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print("location udpated...")
        if lastLocation == nil {
            lastLocation = locations.first
        }
        self.userlocation =  locations.last
        if self.throughfare == nil && self.userlocation != nil {
            ///task is a struck type of swift that allows execution of the code asynchronously
            Task(operation: {
                print("geocoding first time")
                    if let placemarks = try? await CLGeocoder().reverseGeocodeLocation(self.userlocation!) {
                        if let placemark = placemarks.first {
                            DispatchQueue.main.async {
                                self.throughfare = placemark.thoroughfare
                            }
                            print("through fare is:\(self.throughfare ?? "")")
                        }
                    }
                
                
            })
          
        }
        //if locations array is not nil and has the first location of the user, get the first user location
        if let lastUserLocation = locations.last, var distance = distance {
            //update the userLocation property with the first user location accessed by CLLocationManager in locations array.
            if  lastLocation!.distance(from: lastUserLocation)/1000 >= 0.01 && distance > 0.0 {
                self.distance = self.distance! - (lastLocation!.distance(from: lastUserLocation)/1000)
                print("Distance: \(self.distance!/1000)")
                lastLocation = lastUserLocation
            }
            else if distance == 0.0 {
                self.distance = nil
            }
            self.userlocation = lastUserLocation
            
            self.speed = self.userlocation!.speed * 3.6
            
            region = MKCoordinateRegion(center: lastUserLocation.coordinate, latitudinalMeters: 1000, longitudinalMeters: 1000)
            
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        self.userHeading = newHeading
    }
    //this method will be called whenever core location fails to access user location
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Error: \(error.localizedDescription)")
    }
    
   
    
    
}
