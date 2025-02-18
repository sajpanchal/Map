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
import CloudKit
///custom Location manager class that inherits NSObject class and CLlocationManageDelegate protocol. this class also conforms to ObservableObject type-alias. it means that this instance will be obsered by swiftui view  for any changes in data associated with it. to make it possible we just have to type-alias it as @ObservedObject. we have to do it as we as interfacing between structs and classes. structs are value types and classes are reference type LocationDataManager is responsible to handle user location authorization, gather all the user location data and track user data.
class LocationDataManager: NSObject, CLLocationManagerDelegate, ObservableObject {
    ///locationManager object is instantiated in a class
    var locationManager = CLLocationManager()
    @FetchRequest(entity:Vehicle.entity(), sortDescriptors:[NSSortDescriptor(keyPath: \Vehicle.isActive, ascending: false)]) var vehicles: FetchedResults<Vehicle>
    ///this is a object property that will reflect the user location authorization status. it is set as a type-alieas @published. which makes updates to swiftui if this object is used in that swiftui view.
    ///property storing userlocation
    var userlocation: CLLocation?
    ///latest user location from locations array of core location
    var lastUserlocation: CLLocation?
    ///property storing user heading relative to magnetic north.
    var userHeading: CLHeading?
    ///region instance for setting up the visible region in the map with centered location and zoom level configured based on needs.
    @Published var region: MKCoordinateRegion = MKCoordinateRegion()
    ///speed of the user
    var viewContext = CoreDataStack.shared.persistantContainer.viewContext
    var speed: Int = 0
    ///throughfare i.e. street name of the current location received by reverse geocoding.
    var throughfare: String?
    ///flag to be used for enabling and disabling the reverse geocoding
    var enableGeocoding = true
    var distance: CLLocationDistance = 0.0
    var distanceText: String = "0.0 km"
    var odometer: CLLocationDistance = 0.0
    ///local variable to store odometer in miles
    var odometerMiles: CLLocationDistance = 0.0
    var trip: CLLocationDistance = 0.0
    ///local variable to store trip odometer in miles.
    var tripMiles: CLLocationDistance = 0.0
    var results: [Vehicle] = []
    ///settings array.
    var settings: [Settings] = []
    var index: Int?
    var vehicle: Vehicle?
    ///overriding the initializer of NSObject class
    override init() {
        ///execute the parent class initializer first
        super.init()
        ///set the LocationDataManager object as a delegate of locationManager object.when we set This class object as a delegate to the locationManage object, if there are any change in CLLocationManager,it will be reflected in LocationDataManager automatically.
        locationManager.delegate = self
        locationManager.pausesLocationUpdatesAutomatically = false
        do {
            ///fetch request to get vehicles
            let vehiclesFetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Vehicle")
            ///fetch request to get settings
            let settingsFetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Settings")
            ///sort the fetched result of the vehicles by active vehicle at last.
            vehiclesFetchRequest.sortDescriptors = [NSSortDescriptor(key: "isActive", ascending: false)]
            ///fetch the vehicles using fetched request from viewcontext.
            self.results = try viewContext.fetch(vehiclesFetchRequest) as? [Vehicle] ?? []
            ///fetch the settings using fetched request from viewcontext.
            self.settings = try viewContext.fetch(settingsFetchRequest) as? [Settings] ?? []
            ///viewContext.
            self.index = self.results.firstIndex(where: {$0.isActive})
            if let activeIndex = self.index {
                self.vehicle = results[activeIndex]
            }
        }
        catch {
            print(error.localizedDescription)
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
        guard let thisUserLocation = userlocation else {
            return
        }
        ///get the last location from locations array.
        lastUserlocation = locations.last
        ///if locations array is not nil and has the first location of the user, get the last user location, also check if the remainingDistance is not nil
        if let lastLocation = lastUserlocation {
         ///check if the distance updated is greater than 0.01 meters and make sure distance is greater than 0.
            if thisUserLocation.distance(from: lastLocation)/1000 >= 0.01 {
                ///update the lastLocation variable with the latest user location recevied by location manager.
                self.distance = thisUserLocation.distance(from: lastLocation)/1000
                self.distanceText = String(format: "%.1f",self.distance)
                ///if the vehicle is not nil
                if let activeVehicle = vehicle {
                    ///if active vehicle is found in settings
                    if settings.contains(where: {$0.vehicle == activeVehicle}) {
                    }
                    ///if no vehicle is found
                    else {
                        do {
                            ///re create the fetch request
                            let settingsFetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Settings")
                          ///fetch the settings again.
                            self.settings = try viewContext.fetch(settingsFetchRequest) as? [Settings] ?? []
                        }
                        catch {
                            print("error")
                        }
                    }
                    ///if the index of the active vehicle is found
                    if let i = results.firstIndex(of: activeVehicle) {
                        ///start updating the odometer of the active vehicle in km.
                        self.results[i].odometer += thisUserLocation.distance(from: lastLocation)/1000
                        ///start updating the odometer of the active vehicle in miles.
                        self.results[i].odometerMiles =  self.results[i].odometer * 0.6214
                        ///start updating the trip odometer of the active vehicle in km.
                        self.results[i].trip += thisUserLocation.distance(from: lastLocation)/1000
                        ///start updating the trip odometer of the active vehicle in miles.
                        self.results[i].tripMiles = self.results[i].trip * 0.6214
                        ///save view context
                        Vehicle.saveContext(viewContext: viewContext)
                    }
                    ///if no index is found
                    else {
                        do {
                            ///create a fetach request again.
                            let vehiclesFetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Vehicle")
                            ///sort the fetch results by vehicle active to the last.
                            vehiclesFetchRequest.sortDescriptors = [NSSortDescriptor(key: "isActive", ascending: false)]
                            ///fetch the results from the viewcontext.
                            self.results = try viewContext.fetch(vehiclesFetchRequest) as? [Vehicle] ?? []
                           ///get the index of the active vehicle
                            self.index = self.results.firstIndex(where: {$0.isActive})
                            
                        }
                        catch {
                            print(error.localizedDescription)
                        }
                    }
                }
                userlocation = lastLocation
            }
            else {
                self.distance = 0.0
            }
            ///calculate the speed of the user
            if lastLocation.speed >= 0 {
                self.speed = Int(lastLocation.speed * 3.6)
            }
            else {
                self.speed = 0
            }         
            ///set the region of the map with a center at last user coordinates and zoomed to 1000 meters.
            region = MKCoordinateRegion(center: lastLocation.coordinate, latitudinalMeters: 1000, longitudinalMeters: 1000)
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
