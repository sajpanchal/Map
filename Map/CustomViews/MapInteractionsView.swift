//
//  MapInteractionsView.swift
//  Map
//
//  Created by saj panchal on 2023-12-10.
//

import SwiftUI
import CoreLocation

///this view is responsible to show and update the mapview buttons, alerts, and footer view with buttons.
struct MapInteractionsView: View {
    
    ///bounded property to store map status
    @Binding var mapViewStatus: MapViewStatus
    ///bounded property to store map action to be performed
    @Binding var mapViewAction: MapViewAction
    ///bounded property to show or hide the footer expanded view
    @Binding var showSheet: Bool
    ///state object of Location manager to show the distance remaining from destination
    @StateObject var locationDataManager: LocationDataManager
    ///state object of local search to check if the destination location has been selected or not
    @StateObject var localSearch: LocalSearch
    ///this variable is going to store the address and name of the destination location.
    var destination: String
    ///bounded property to display the travel time of the selected route
    @Binding var routeTravelTime: String
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
                VStack {
                    ///if map is navigating
                    if mapViewStatus == .navigating {
                        ///show the expand symbol on top of the footer view.
                        ExpandViewSymbol()
                            .onTapGesture {
                                ///on tap of it toggle to flag to show/hide the expandedview.
                                withAnimation {
                                    showSheet.toggle()
                                }
                            }
                        ///if flag is true
                        if showSheet {
                            ///show the hstack that is displaying the expanded view with the destination address and title.
                            HStack {
                                Spacer()
                                ///showing the title and destination address and its name.
                                VStack {
                                    Text("Heading to destination")
                                        .font(.caption2)
                                        .fontWeight(.bold)
                                    Text(destination)
                                        .font(.caption2)
                                        .multilineTextAlignment(.center)
                                }
                                Spacer()
                            }
                            .onTapGesture {
                                ///if user taps on the expandedview itself, show/hide it.
                                withAnimation {
                                    showSheet.toggle()
                                }
                            }
                        }
                    }
                  ///footer view with buttons and distance and time information
                    HStack {
                        ///if map is not navigating but location is pinned i.e. selected by the user show the footer with only the button to find routes to the destination
                        if mapViewStatus != .navigating {
                            ///routes button. On tap of it change the map action to show directions and make the throughfare nil for it to update it when starting a navigation
                            Button(action: { mapViewAction = .showDirections; locationDataManager.throughfare = nil },
                                   label: {
                                ///button appearance
                                VStack {
                                    ///show image on top of the text with font styles and background set.
                                    Image(systemName: "arrow.triangle.swap")
                                        .font(.title)
                                        .fontWeight(.black)
                                        .foregroundStyle(Color.white)
                                    Text("Routes")
                                        .foregroundStyle(.white)
                                        .font(.caption2)
                                        .fontWeight(.bold)
                                }
                                .frame(width: 65, height: 65)
                            })
                            .background(.blue.gradient)
                            .cornerRadius(15)
                            .padding(5)
                        }
                        ///center portion of the footer view to show the numeric data related to the travel.
                        Group {
                            Spacer()
                            ///enclose the text in vstack
                            VStack {
                                ///if routes are showing up then show the travel time and distance for the selected route.
                                if mapViewStatus == .showingDirections {
                                    Text(routeTravelTime)
                                    Text(routeDistance)
                                }
                                ///if map is navigating then show the remaining distance from the current location to the destination.
                                else if mapViewStatus == .navigating {
                                    Text(remainingDistance)
                                        .font(.title2)
                                        .fontWeight(.black)
                                    Text("Remaining")
                                }
                            }
                            Spacer()
                        }
                        .onTapGesture {
                            withAnimation {
                                showSheet.toggle()
                            }
                        }
                        ///if map is showing directions or is already navigating, show the button to start/stop the navigation. ///button appearance will be changed based on whether the map is navigating or not
                        if mapViewStatus == .showingDirections || mapViewStatus == .navigating {
                            ///on tap of the button updateUserTracking method will be called. its background will change based on whether it is navigating or not.
                            Button(action: updateLocationTracking, label: {
                                ///if map is navigating
                                isMapInNavigationMode().0 ?
                                ///change the button appearance with stop text and xmark symbol
                                VStack {
                                    Image(systemName: "xmark")
                                        .font(.title)
                                        .fontWeight(.black)
                                        .foregroundStyle(Color.white)
                                    Text("Stop")
                                        .foregroundStyle(.white)
                                        .font(.caption2)
                                        .fontWeight(.bold)
                                }
                                .frame(width: 65, height: 65):
                                ///if it is not navigating then change the text with navigate and arrows symbol with blue background.
                                VStack {
                                    Image(systemName: "arrow.up.and.down.and.arrow.left.and.right")
                                        .font(.title)
                                        .fontWeight(.black)
                                        .foregroundStyle(Color.white)
                                    Text("Navigate")
                                        .foregroundStyle(.white)
                                        .font(.caption2)
                                        .fontWeight(.bold)
                                }
                                .frame(width: 65, height: 65)
                            })                           
                            .background(isMapInNavigationMode().0 ? Color.red.gradient : Color.blue.gradient)
                            .cornerRadius(15)
                            .padding(5)
                        }
                    }
                }
                .background(.black.gradient)
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
    func updateLocationTracking() {
        print("user navigation tracking is available.")
        switch mapViewStatus {
        ///set mapViewAction to navigate mode if status is not related to navigation when button is pressed.
        case .idle, .notCentered, .centeredToUserLocation, .showingDirections:
            ///make map to start navigation
            mapViewAction = .navigate
            ///UIApplocation is the class that has a centralized control over the app. it has a property called shared that is a singleton instance of UIApplication itself. this instance has a property called isIdleTimerDisabled. which will decide if we want to turn off the phone screen after certain amount of time of inactivity in the app. we will set it to true so it will keep the screen alive when user tracking is on.
            UIApplication.shared.isIdleTimerDisabled = true
            break
        ///set mapViewAction to idle mode if status is navigating when button is pressed.
        case .navigating, .inNavigationCentered, .inNavigationNotCentered:
            ///make map to switch to idle mode.
            mapViewAction = .idle
            ///clear the trave titme text
            self.routeTravelTime = ""
            ///clear the route distanc text
            routeDistance = ""
            ///keep the destination selected pinned to map.
            localSearch.isDestinationSelected = true
            ///remove all the instructions from the array that shows them in a listview.
            stepInstructions.removeAll()
            ///clear the instruction text
            instruction = ""
            ///make the next step location nil
            nextStepLocation = nil
            ///reseting the remainingDistance to nil
            locationDataManager.remainingDistance = nil
            UIApplication.shared.isIdleTimerDisabled = false
            break
        case .showingDirectionsNotCentered:
            UIApplication.shared.isIdleTimerDisabled = false
            break
        }
    }
    ///mehtod to be called when user wants to center to the current location.
    func centerMapToUserLocation() {
        ///based on the map's status (navigating or not) center to the user location in that mode.
        mapViewAction = isMapInNavigationMode().0 ? .inNavigationCenterToUserLocation : .centerToUserLocation
    }
   
 
}

#Preview {
    MapInteractionsView(mapViewStatus: .constant(.idle), mapViewAction: .constant(.idle), showSheet: .constant(false), locationDataManager: LocationDataManager(), localSearch: LocalSearch(), destination: "", routeTravelTime: .constant(""), routeDistance: .constant(""), remainingDistance: "", instruction: .constant(""), nextStepLocation: .constant(CLLocation()), stepInstructions: .constant([]))
}
