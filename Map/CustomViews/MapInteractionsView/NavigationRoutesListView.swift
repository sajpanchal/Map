//
//  NavigationRoutesList.swift
//  Map
//
//  Created by saj panchal on 2024-06-08.
//

import SwiftUI
import CoreLocation

struct NavigationRoutesListView: View {
    ///environment variable to get the color mode of the phone
    @Environment (\.colorScheme) var bgMode: ColorScheme
    @Binding var routeData: [RouteData]
    @Binding var isRouteSelectTapped: Bool
    ///bounded property to store map status
    @Binding var mapViewStatus: MapViewStatus
    ///bounded property to store map action to be performed
    @Binding var mapViewAction: MapViewAction
    ///bounded property to display the travel time of the selected route
    @Binding var routeTravelTime: String
    ///bounded property to display the travel distance of the selected route
    @Binding var routeDistance: String
    ///state object of Location manager to show the distance remaining from destination
    @StateObject var locationDataManager: LocationDataManager
    ///state object of local search to check if the destination location has been selected or not
    @StateObject var localSearch: LocalSearch
    ///bounded property shows the latest instruction to head to the next step towards destination
    @Binding var instruction: String
    ///bounded property stores the location object of the next step.
    @Binding var nextStepLocation: CLLocation?
    ///bounded property stores an array of tuples with a list of instructions and its distances by each step.
    @Binding var stepInstructions: [(String, Double)]
//    var redRadialGradient = RadialGradient(gradient: Gradient(colors: [Color(AppColors.invertRed.rawValue), Color(AppColors.red.rawValue)]), center: .center, startRadius: 1, endRadius: 50)
//    var blueRadialGradient = RadialGradient(gradient: Gradient(colors: [Color(AppColors.invertSky.rawValue), Color(AppColors.sky.rawValue)]), center: .center, startRadius: 1, endRadius: 50)
//    var greenColor = Color(red: 0.257, green: 0.756, blue: 0.346)
//    var redColor = Color(red:0.861, green: 0.194, blue:0.0)
//    var skyColor = Color(red:0.031, green:0.739, blue:0.861)
    var body: some View {
        ForEach(routeData.reversed(), id: \.id) { route in
            ///enclose the content in HStack
            HStack {
                Spacer()
                ///enclose the Text and HStack in VStack
                VStack {
                    ///show the travel time at the top
                    Text(route.travelTime)
                        .fontWeight(.bold)
                        .font(Font.system(size: 25))
                        .foregroundStyle(Color(AppColors.invertGreen.rawValue))
                    ///show the distane and title at the bottom enclosed in HStack
                    HStack {
                        Text(route.distance)
                            .fontWeight(.bold)
                            .font(Font.system(size: 16))
                            .foregroundStyle(Color(AppColors.invertRed.rawValue))
                        Text("  via")
                            .fontWeight(.regular)
                            .font(Font.system(size: 16))
                            .foregroundStyle(Color(AppColors.invertSky.rawValue))
                        Text(route.title)
                            .fontWeight(.bold)
                            .font(Font.system(size: 16))
                            .foregroundStyle(Color(AppColors.invertSky.rawValue))
                    }
                }
                Spacer()
                ///if the route is tapped show the button at the right space in the HStack
                if route.tapped {
                    ///on tap of the button updateUserTracking method will be called. its background will change based on whether it is navigating or not.
                    Button(action: updateLocationTracking, label: {
                        ///if map is navigating
                        isMapInNavigationMode().0 ?
                        ///change the button appearance with stop text and xmark symbol
                        NavigationButton(imageName: "xmark", title: "Stop", foregroundColor: Color(AppColors.lightRed.rawValue)) :
                        ///if it is not navigating then change the text with navigate and arrows symbol with blue background.
                        NavigationButton(imageName: "steeringwheel", title: "Go", foregroundColor: Color(AppColors.lightSky.rawValue))
                        
                    })
                    .background(isMapInNavigationMode().0 ? Color(AppColors.darkRed.rawValue).gradient : Color(AppColors.darkSky.rawValue).gradient)
                    .cornerRadius(10)
                    .padding(0)
                    
                }
                ///else hide it.
                else {
                    ///on tap of the button updateUserTracking method will be called. its background will change based on whether it is navigating or not.
                    Button(action: updateLocationTracking, label: {
                        ///if map is navigating
                        isMapInNavigationMode().0 ?
                        ///change the button appearance with stop text and xmark symbol
                        NavigationButton(imageName: "xmark", title: "Stop", foregroundColor: Color(AppColors.lightRed.rawValue)) :
                        ///if it is not navigating then change the text with navigate and arrows symbol with blue background.
                        NavigationButton(imageName: "arrow.up.and.down.and.arrow.left.and.right", title: "Navigate", foregroundColor: Color(AppColors.lightSky.rawValue))
                        
                    })
                    .background(isMapInNavigationMode().0 ? Color(AppColors.darkRed.rawValue).gradient : Color(AppColors.darkSky.rawValue).gradient)
                    .cornerRadius(10)
                    .padding(0)
                    .disabled(true)
                    .hidden()
                }
               
              
            }
            .background(bgMode == .dark ? Color(uiColor: .darkGray) : Color(uiColor: .systemGray5))
            .overlay(Divider().background(bgMode == .dark ? Color(.lightGray) : Color(.gray)), alignment: .bottom)
            .cornerRadius(10)
           
            .onTapGesture(perform: {
                updateRouteData(for: route)
                isRouteSelectTapped = true
            })
           
        }
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
    ///update the user location tracking
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
            localSearch.status = .locationSelected
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
}

#Preview {
    NavigationRoutesListView(routeData: .constant([]), isRouteSelectTapped: .constant(false), mapViewStatus: .constant(.idle), mapViewAction: .constant(.idle), routeTravelTime: .constant(""), routeDistance: .constant(""), locationDataManager: LocationDataManager(), localSearch: LocalSearch(), instruction: .constant(""), nextStepLocation: .constant(CLLocation()), stepInstructions: .constant([]))
}
