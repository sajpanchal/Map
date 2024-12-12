//
//  InteractionFooterView.swift
//  Map
//
//  Created by saj panchal on 2024-06-14.
//
import Combine
import SwiftUI
import CoreLocation
import MapKit
struct InteractionFooterView: View {
    ///bounded property to store map status
    @Binding var mapViewStatus: MapViewStatus
    ///bounded property to store map action to be performed
    @Binding var mapViewAction: MapViewAction
    ///bounded property to show or hide the footer expanded view
    @Binding var showAddressView: Bool
    ///this variable is going to store the address and name of the destination location.
    var destination: String
    @State private var addressViewHeight: CGFloat = 0
    ///state object of Location manager to show the distance remaining from destination
    @StateObject var locationDataManager: LocationDataManager
    ///state object of local search to check if the destination location has been selected or not
    @StateObject var localSearch: LocalSearch
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
    @Binding var stepInstructions: [(String, String)]
    @Binding var ETA: String
    @Binding var isRouteSelectTapped: Bool
    @Binding var tappedAnnotation: MKAnnotation?
    @Binding var height: Double

    var body: some View {
        VStack {
            ///if map is navigating
            if mapViewStatus == .navigating || mapViewStatus == .inNavigationNotCentered {
                ///show the expand symbol on top of the footer view.
                ExpandViewSymbol()
                    .gesture(
                        DragGesture()
                            .onChanged(expandedDestinationInfoViewDragChanged)
                            .onEnded(expandedDestinationInfoViewDragChanged)
                    )
                ///if flag is true
                if showAddressView {
                  AddressView(destination: destination)
                    .frame(height: addressViewHeight)
                    .gesture(
                        DragGesture()
                            .onChanged(expandedDestinationInfoViewDragChanged)
                            .onEnded(expandedDestinationInfoViewDragChanged)
                    )
                }
            }
          ///footer view with buttons and distance and time information
            HStack {
                ///if map is not navigating but location is pinned i.e. selected by the user show the footer with only the button to find routes to the destination
                if mapViewStatus != .inNavigationNotCentered && mapViewStatus != .navigating && mapViewStatus != .showingDirections && localSearch.status == .locationSelected {
                    ///routes button. On tap of it change the map action to show directions and make the throughfare nil for it to update it when starting a navigation
                    Button(action: { mapViewAction = .showDirections; locationDataManager.throughfare = nil },
                           label: { NavigationButton(imageName: "arrow.triangle.swap", title: "Routes", foregroundColor: Color(AppColors.lightSky.rawValue), size: 50)})
                    .background(Color(AppColors.darkSky.rawValue).gradient)
                    .cornerRadius(15)
                    .padding(5)
                }
                ///center portion of the footer view to show the numeric data related to the travel.
                Group {
                   Spacer()
                    ///enclose the text in vstack
                    VStack(spacing: 0) {
                        ///if routes are showing up then show the travel time and distance for the selected route.
                        if mapViewStatus == .showingDirections {
                            ///for each routeData element create a HStack showing the route travel time, distance, title and navigate button
                            NavigationRoutesListView( routeData: $routeData, isRouteSelectTapped: $isRouteSelectTapped, mapViewStatus: $mapViewStatus, mapViewAction: $mapViewAction, routeTravelTime: $routeTravelTime, routeDistance: $routeDistance, locationDataManager: locationDataManager, localSearch: localSearch, instruction: $instruction, nextStepLocation: $nextStepLocation, stepInstructions: $stepInstructions)
                        }
                        ///if map is navigating then show the remaining distance from the current location to the destination.
                        else if mapViewStatus == .navigating || mapViewStatus == .inNavigationNotCentered {
                            ///enclose the ETA texts in HStack
                            RouteETAStackView(showAddressView: $showAddressView, destination: destination, ETA: $ETA, addressViewHeight: $addressViewHeight/*, timer: time*/, remainingDistance: remainingDistance)
                        }
                        else if localSearch.status == .showingNearbyLocations {
                            ExpandViewSymbol()
                            NearbyLocationsListView(localSearch: localSearch, locationDataManager: locationDataManager, mapViewAction: $mapViewAction, tappedAnnotation: $tappedAnnotation, height: $height)
                                .frame(height: height)
                        }
                    }
                    .gesture(
                        DragGesture()
                            .onChanged(destinationInfoViewDragChanged)
                            .onEnded(destinationInfoViewDragEnded)
                    )
                    Spacer()
                }
                .onTapGesture {
                    withAnimation {
                        showAddressView.toggle()
                    }
                }
                ///if map is showing directions or is already navigating, show the button to start/stop the navigation. ///button appearance will be changed based on whether the map is navigating or not
                if mapViewStatus == .navigating || mapViewStatus == .inNavigationNotCentered {
                    ///on tap of the button updateUserTracking method will be called. its background will change based on whether it is navigating or not.
                    Button(action: updateLocationTracking, label: {
                        ///if map is navigating
                        isMapInNavigationMode().0 ?
                        ///change the button appearance with stop text and xmark symbol
                        NavigationButton(imageName: "xmark", title: "Stop", foregroundColor: Color(AppColors.lightRed.rawValue), size: 50) :
                        ///if it is not navigating then change the text with navigate and arrows symbol with blue background.
                        NavigationButton(imageName: "arrow.up.and.down.and.arrow.left.and.right", title: "Navigate", foregroundColor: Color(AppColors.lightSky.rawValue), size: 50)
                    })
                    .background(isMapInNavigationMode().0 ? Color(AppColors.darkRed.rawValue).gradient : Color(AppColors.darkSky.rawValue).gradient)
                    .cornerRadius(15)
                    .padding(5)
                }
              
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
    func expandedDestinationInfoViewDragChanged(value: DragGesture.Value) {
        withAnimation {
            if value.translation.height < 0  && abs(value.translation.height) > 10 {
                showAddressView = true
                addressViewHeight = min(80, abs(value.translation.height))
            }
            else if value.translation.height >= 0 && abs(value.translation.height) > 10 {
                addressViewHeight = abs(value.translation.height) <= 80 ?  80 - value.translation.height : 0
                if addressViewHeight <= 5 {
                    showAddressView = false
                }
            }
        }
    }
    
      func destinationInfoViewDragChanged(value: DragGesture.Value) {
          DispatchQueue.main.async {
              if height >= 200 && height <= 400 {
                  height = height - value.translation.height
              }
              else if height < 200 {
                  height = 200
              }
              else if height > 400 {
                  height = 400
              }
          }
      }
      func destinationInfoViewDragEnded(value: DragGesture.Value) {
          DispatchQueue.main.async {
              if height < 200 {
                  height = 200
              }
              else if height > 400 {
                  height = 400
              }
          }
      }
    func updateLocationTracking() {
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
            localSearch.status = .locationUnselected
            localSearch.results.removeAll()
            ///remove all the instructions from the array that shows them in a listview.
            stepInstructions.removeAll()
            ///clear the instruction text
            instruction = ""
            ///make the next step location nil
            nextStepLocation = nil
            ///reseting the remainingDistance to nil
          //  locationDataManager.remainingDistance = nil
            UIApplication.shared.isIdleTimerDisabled = false
            break
        case .showingDirectionsNotCentered:
            UIApplication.shared.isIdleTimerDisabled = false
            break
        }
    }
}

#Preview {
    InteractionFooterView(mapViewStatus: .constant(.idle), mapViewAction: .constant(.idle), showAddressView: .constant(false), destination: "", locationDataManager: LocationDataManager(), localSearch: LocalSearch(), routeTravelTime: .constant(""), routeData: .constant([]), routeDistance: .constant(""), remainingDistance: "", instruction: .constant(""), nextStepLocation: .constant(CLLocation()), stepInstructions: .constant([]), ETA: .constant(""), isRouteSelectTapped: .constant(false), tappedAnnotation: .constant(MKPointAnnotation()), height: .constant(0.0)/*, timer: Timer.publish(every: 30, on: .main, in: .common)*/)
}
