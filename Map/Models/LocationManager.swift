//
//  LocationManager.swift
//  Map
//
//  Created by saj panchal on 2023-08-04.
//
import CoreData
import Foundation
import CoreLocation
import MapKit
import SwiftUI
///custom Location manager class that inherits NSObject class and CLlocationManageDelegate protocol. this class also conforms to ObservableObject type-alias. it means that this instance will be obsered by swiftui view  for any changes in data associated with it. to make it possible we just have to type-alias it as @ObservedObject. we have to do it as we as interfacing between structs and classes. structs are value types and classes are reference type LocationDataManager is responsible to handle user location authorization, gather all the user location data and track user data.
class LocationDataManager: NSObject, CLLocationManagerDelegate, ObservableObject {
    ///locationManager object is instantiated in a class
    var locationManager = CLLocationManager()
    @FetchRequest(entity:Vehicle.entity(), sortDescriptors:[]) var vehicles: FetchedResults<Vehicle>
    ///this is a object property that will reflect the user location authorization status. it is set as a type-alieas @published. which makes updates to swiftui if this object is used in that swiftui view.
    ///property storing userlocation
    @Published var userlocation: CLLocation?
    ///property storing user heading relative to magnetic north.
    @Published var userHeading: CLHeading?
    ///region instance for setting up the visible region in the map with centered location and zoom level configured based on needs.
    @Published var region: MKCoordinateRegion = MKCoordinateRegion()
    ///remaining distance from the userlocation to the destination while in navigation
    @Published var remainingDistance: CLLocationDistance?
    ///speed of the user
    var viewContext = CoreDataStack.shared.persistantContainer.viewContext
    @Published var speed: Int = 0
    ///throughfare i.e. street name of the current location received by reverse geocoding.
    @Published var throughfare: String?
    ///flag to be used for enabling and disabling the reverse geocoding
    @Published var enableGeocoding = true
    @Published var distance: CLLocationDistance = 0.0
    @Published var distanceText: String = "0.0 km"
    @Published var odometer: CLLocationDistance = 0.0
    @Published var trip: CLLocationDistance = 0.0
    var results: [Vehicle] = []
    var index: Int?
    ///overriding the initializer of NSObject class
    override init() {
        ///execute the parent class initializer first
        super.init()
        ///set the LocationDataManager object as a delegate of locationManager object.when we set This class object as a delegate to the locationManage object, if there are any change in CLLocationManager,it will be reflected in LocationDataManager automatically.
        locationManager.delegate = self
        locationManager.pausesLocationUpdatesAutomatically = false
        do {
            self.results = try viewContext.fetch(NSFetchRequest(entityName: "Vehicle")) as [Vehicle]
            self.index = self.results.firstIndex(where: {$0.isActive})
            for i in results {
                print(i.type)
                print(i.odometer)
                
            }
        }
        catch {
            print("error")
        }
        locationManager.allowsBackgroundLocationUpdates = true
        locationManager.showsBackgroundLocationIndicator = true
    }
    
    ///before we setup this method we have to setup a key-value pair in info.plist file of our project. this will be a privacy key that will pop up an alert when this app is launched asking user whether to allow this app to access user location. if so corelocation will be instantiated. delegate mathod to be executed when user updates their authorization status
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        ///this method is passing our locationManager parameter in this body for use. checking the authorizationStatus property of our manager object which holds the status of user location access
        switch manager.authorizationStatus {
            ///this status means user has selected to allow location access when app is in use
            case .authorizedWhenInUse:
            ///this will request one-time location update of the current user location.
                manager.startUpdatingLocation()
            ///setting the desired accuracy for location tracking to best available for navigation
                manager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
            ///udating the user heading with respect to magnetic north
                manager.startUpdatingHeading()
                break
            ///this status means user don't want app to track location
            case .restricted:
                break
            ///this status means user don't want app to track location
            case .denied:
                break
            ///this status means user has not given any input.
            case .notDetermined:
                ///if the user didn't give any input, make a request to access location when app is in use.
                manager.requestWhenInUseAuthorization()
                break
            default:
                break
        }
    }
    
    ///this method will be called whenever a new user location is available.
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        ///if the lastlocation is nil assign it the last user location
        if userlocation == nil {
            userlocation = locations.first
        }
        ///if the troughfare is nil and user location is available
        if (self.throughfare == nil && self.userlocation != nil) || enableGeocoding {
            ///task is a struct type of swift that allows execution of the code asynchronously
            Task(operation: {
                ///request the reverse geocoding for current location and it will return the placemarks for this location
                if let placemarks = try? await CLGeocoder().reverseGeocodeLocation(self.userlocation!) {
                    ///get the first placemark from an array
                    if let placemark = placemarks.first {
                        ///retrieve the thoroughfare for that placemark. which will be a street name.
                        await MainActor.run {
                            self.throughfare = placemark.thoroughfare
                        }
                    }
                }
            })
        }
        ///if locations array is not nil and has the first location of the user, get the last user location, also check if the remainingDistance is not nil
        if let lastUserLocation = locations.last {
         ///check if the distance updated is greater than 0.01 meters and make sure distance is greater than 0.
            if  self.userlocation!.distance(from: lastUserLocation)/1000 >= 0.05 {
                print("manager:",self.trip)
                ///subtract the remaining distance from it self by the distance travelled by the user.
///                remainingDistance! -= (userlocation!.distance(from: lastUserLocation)/1000)
                ///update the lastLocation variable with the latest user location recevied by location manager.
                ///
                self.distance = self.userlocation!.distance(from: lastUserLocation)/1000
              
                self.distanceText = String(format: "%.1f",self.distance)
                if let i = index {
                    self.results[i].odometer += self.userlocation!.distance(from: lastUserLocation)/1000
                    self.results[i].trip += self.userlocation!.distance(from: lastUserLocation)/1000
                    print(self.results[i].odometer)
                        Vehicle.saveContext(viewContext: viewContext)
                            
                        
                }
                
                userlocation = lastUserLocation
            }
            else {
                self.distance = 0.0
            }
            ///calculate the speed of the user
            self.speed = Int(self.userlocation!.speed * 3.6)
            ///set the region of the map with a center at last user coordinates and zoomed to 1000 meters.
            region = MKCoordinateRegion(center: lastUserLocation.coordinate, latitudinalMeters: 1000, longitudinalMeters: 1000)
        }
    }
    
    ///get the latest user heading.from location manager.
    func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        self.userHeading = newHeading
    }
    ///this method will be called whenever core location fails to access user location
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Error: \(error.localizedDescription)")
    }
}
