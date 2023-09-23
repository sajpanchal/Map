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
    
    static func annotateLocation(in mapView: MKMapView ,at coordinates: CLLocationCoordinate2D, for annotation: MKAnnotation) {
        mapView.addAnnotation(annotation)
        if mapView.centerCoordinate.latitude != annotation.coordinate.latitude && mapView.centerCoordinate.longitude != annotation.coordinate.longitude {
            mapView.animatedZoom(zoomRegion: MKCoordinateRegion(center: annotation.coordinate, latitudinalMeters: 1000, longitudinalMeters: 1000), duration: TimeInterval(0.1))
            print("centeredd to user location")
        }
    }
    
    static func getNavigationDirections(in uiView: MKMapView, from source: CLLocationCoordinate2D, to destination: CLLocationCoordinate2D?) {
        ///create an instance of MKDirections request to request the directions.
        let request = MKDirections.Request()
        ///if distination is not nil
        if let destination = destination {
            ///set the request source/destination property as a mapitem we get from source/destination location coorinates.
            request.source = MKMapItem(placemark:  MKPlacemark(coordinate: source))
            request.destination = MKMapItem(placemark: MKPlacemark(coordinate: destination))
            request.requestsAlternateRoutes = true
            request.transportType = .automobile
            
            ///create a directions object from our request now.
            let directions = MKDirections(request: request)
            ///async function to calculate the routes from information provided by request object of directions object.
            directions.calculate(completionHandler: { (response, error) in
                ///if response is received
                print("Showing directions")
                if let response = response {
                    uiView.removeOverlays(uiView.overlays)
                    ///get a polyline object from the first route.
                    let sortedRoutes = response.routes.sorted(by: {
                        $0.expectedTravelTime > $1.expectedTravelTime
                    })
                    var index = sortedRoutes.count
                    for route in sortedRoutes {
                        let polyline = route.polyline
                        index -= 1
                        if index == 0 {
                            polyline.subtitle = "fastest route"
                        }                                              
                        ///add the polyline received from the route as an overlay to be displayed in mapview.
                        print("route eta: \(route.expectedTravelTime)")
                        uiView.addOverlay(polyline)
                    }
                }
                else {
                    print(error!.localizedDescription)
                }
            })
        }
    }
    
    static func isOvarlayTapped(in mapView: MKMapView, by tapGestureRecognizer: UITapGestureRecognizer) -> (Bool,String) {
        let tapLocation = tapGestureRecognizer.location(in: mapView)
        var isOverlayTapped = false
        print("tapped on a mapview")
        let tapCoordinates =  mapView.convert(tapLocation, toCoordinateFrom: mapView)
        print("tap coorindates: \(tapCoordinates)")
        var title = ""
        for overlay in mapView.overlays.reversed() {
            let renderer = mapView.renderer(for: overlay) as! MKPolylineRenderer
            let mapPoint = MKMapPoint(tapCoordinates)
            let rendererPoint = renderer.point(for: mapPoint)
            print("title is : \(renderer.polyline.title!)")
            if renderer.path.contains(rendererPoint) {
                title = renderer.polyline.title!
                print("tap is on the polyline")
            }
        }
        isOverlayTapped = (title == "") ? false : true
        return (isOverlayTapped, title)
    }
    static func setTappedOverlay(in mapView: MKMapView, having title: String) {
        var index = 0
        var counter = 0
        for overlay in mapView.overlays {
            let renderer = mapView.renderer(for: overlay) as! MKPolylineRenderer
            if title == renderer.polyline.title {
                renderer.strokeColor = .systemBlue
                index = counter
            }
            else {
                renderer.strokeColor = .systemGray
            }
         counter += 1
        }
            mapView.exchangeOverlay(at: index, withOverlayAt: (mapView.overlays.count - 1))
        counter = 0
    }
}
