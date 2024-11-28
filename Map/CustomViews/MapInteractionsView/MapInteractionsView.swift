//
//  MapInteractionsView.swift
//  Map
//
//  Created by saj panchal on 2023-12-10.
//

import SwiftUI
import CoreLocation
import MapKit
import Combine
///this view is responsible to show and update the mapview buttons, alerts, and footer view with buttons.
struct MapInteractionsView: View {
    ///environment variable to get the color mode of the phone
    @Environment(\.colorScheme) var bgMode: ColorScheme
    ///bounded property to store map status
    @Binding var mapViewStatus: MapViewStatus
    ///bounded property to store map action to be performed
    @Binding var mapViewAction: MapViewAction
    ///bounded property to show or hide the footer expanded view
    @State private var showAddressView: Bool = false
    ///state object of Location manager to show the distance remaining from destination
    @StateObject var locationDataManager: LocationDataManager
    ///state object of local search to check if the destination location has been selected or not
    @StateObject var localSearch: LocalSearch
    ///this variable is going to store the address and name of the destination location.
    var destination: String
    ///bounded property to display the travel time of the selected route
    @Binding var routeTravelTime: String
    @Binding var routeData: [RouteData]
    ///bounded property to display the travel distance of the selected route
    @Binding var routeDistance: String

    ///variable that stores and displayes the distance remaining from the current location to destination
    var remainingDistance: String
    ///bounded property shows the latest instruction to head to the next step towards destination
    @Binding var instruction: String
    ///bounded property stores the location object of the next step.
    @Binding var nextStepLocation: CLLocation?
    ///bounded property stores an array of tuples with a list of instructions and its distances by each step.
    @Binding var stepInstructions: [(String, Double)]
    @Binding var ETA: String
    @Binding var isRouteSelectTapped: Bool
    @Binding var tappedAnnotation: MKAnnotation?
    @State private var height = 200.0
 //   var timer: Timer.TimerPublisher

//    var redRadialGradient = RadialGradient(gradient: Gradient(colors: [Color(red: 1, green: 0.4, blue: 0.0), Color(red: 1, green: 0.0, blue: 0.00)]), center: .center, startRadius: 1, endRadius: 50)
//    var blueRadialGradient = RadialGradient(gradient: Gradient(colors: [Color(red: 0.095, green: 0.716, blue: 0.941), Color(red: 0.092, green: 0.43, blue: 0.89)]), center: .center, startRadius: 1, endRadius: 50)
    var body: some View {
        ///enclose the map interaction views in a vstack and move them to the bottom of the screen.
        VStack(spacing: 0) {
           Spacer()
            ///custom buttons that is floating on our  if map is navigating but it is not centered to user location show the location button to center it on tap.
            if isMapInNavigationMode().0 && isMapInNavigationMode().1 == .inNavigationNotCentered {
                MapViewButton(imageName: "location.fill")
                    .gesture(TapGesture().onEnded(centerMapToUserLocation))
            }
            ///if map is not navigating show the circle button to center the map to user location whenever tapped.
            if !isMapInNavigationMode().0 && mapViewStatus != .showingDirections {
                MapViewButton(imageName: mapViewStatus == .centeredToUserLocation ? "circle" : "circle.fill")
                    .gesture(TapGesture().onEnded(centerMapToUserLocation))
            }
            ///if destination is selected this array won't be nil. so there has to be the footer needs to be displayed with the interation buttons for user to find routes and navigate.
            if localSearch.suggestedLocations != nil {
                ///enclose the footer view along with expanded view in a VStack
                InteractionFooterView(mapViewStatus: $mapViewStatus, mapViewAction: $mapViewAction, showAddressView: $showAddressView, destination: destination, locationDataManager: locationDataManager, localSearch: localSearch, routeTravelTime: $routeTravelTime, routeData: $routeData, routeDistance: $routeDistance, remainingDistance: remainingDistance, instruction: $instruction, nextStepLocation: $nextStepLocation, stepInstructions: $stepInstructions, ETA: $ETA, isRouteSelectTapped: $isRouteSelectTapped, tappedAnnotation: $tappedAnnotation, height: $height/*, timer: timer*/)
                .background(bgMode == .dark ? Color.black.gradient : Color.white.gradient)
            }
        }
    }
    
    ///method to determine if the map is in navigation mode or not.
    func isMapInNavigationMode() -> (Bool,MapViewStatus) {
        ///check the mapview status
        switch mapViewStatus {
            ///if any of the status are set which is not related to navigation mode then set the tuple with false result and send the actual status.
        case .idle, .notCentered, .centeredToUserLocation, .showingDirections, .showingDirectionsNotCentered:
            return (false,mapViewStatus)
            ///if any of the status are set which is related to navigation mode then set the tuple with true result and send the actual status.
        case .navigating, .inNavigationCentered, .inNavigationNotCentered:
            return (true,mapViewStatus)
        }
    }
    
    ///update the user location tracking
   
    ///mehtod to be called when user wants to center to the current location.
    func centerMapToUserLocation() {
        ///based on the map's status (navigating or not) center to the user location in that mode.
        mapViewAction = isMapInNavigationMode().0 ? .inNavigationCenterToUserLocation : .centerToUserLocation
    }
    ///method to update the routeData by setting/resetting  a tapped prop of each element based on the user selection of route
    func updateRouteData(for route: RouteData) {
        ///get the index of the given route that is selected by the user
        guard let indexOfSelectedRoute = routeData.firstIndex(of: route) else {
            return
        }
        ///get the index of the route that was previously selected
        if let indexOfPrevSelectedRoute = routeData.firstIndex(where: {$0.tapped}) {
            ///reset the tapped property of the given route.
            routeData[indexOfPrevSelectedRoute].tapped = false
        }
        ///set the tapped prop of a currenty selected route.
        routeData[indexOfSelectedRoute].tapped = true
    }
  
    
}

#Preview {

    MapInteractionsView(mapViewStatus: .constant(.idle), mapViewAction: .constant(.idle), locationDataManager: LocationDataManager(), localSearch: LocalSearch(), destination: "", routeTravelTime: .constant(""), routeData: .constant([]), routeDistance: .constant(""),remainingDistance: "", instruction: .constant(""), nextStepLocation: .constant(CLLocation()), stepInstructions: .constant([]), ETA: .constant(""), isRouteSelectTapped: .constant(false), tappedAnnotation: .constant(MKPointAnnotation())/*, timer: Timer.publish(every: 30, on: .main, in: .common)*/)
}


