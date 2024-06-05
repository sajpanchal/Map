//
//  MapInteractionsView.swift
//  Map
//
//  Created by saj panchal on 2023-12-10.
//

import SwiftUI
import CoreLocation
import MapKit

///this view is responsible to show and update the mapview buttons, alerts, and footer view with buttons.
struct MapInteractionsView: View {
    ///environment variable to get the color mode of the phone
    @Environment (\.colorScheme) var bgMode: ColorScheme
    ///bounded property to store map status
    @Binding var mapViewStatus: MapViewStatus
    ///bounded property to store map action to be performed
    @Binding var mapViewAction: MapViewAction
    ///bounded property to show or hide the footer expanded view
    @Binding var showAddressView: Bool
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
    @State var height = 200.0
    @State var addressViewHeight: CGFloat = 0
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
                            .gesture(DragGesture().onChanged {
                                value in
                               
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
                                .onEnded { value in
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
                            })
                        ///if flag is true
                        if showAddressView {
                            ///show the hstack that is displaying the expanded view with the destination address and title.
                            HStack {
                                Spacer()
                                ///showing the title and destination address and its name.
                                VStack {
                                    Text(MapViewAPI.comment)
                                    Text("Heading to destination")
                                        .font(.caption2)
                                        .fontWeight(.bold)
                                    Text(destination)
                                        .font(.caption2)
                                        .multilineTextAlignment(.center)
                                }
                                Spacer()
                            }
                            .frame(height: addressViewHeight)
                            .gesture(DragGesture().onChanged {
                                value in
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
                        .onEnded { value in
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
                        })
                        }
                    }
                  ///footer view with buttons and distance and time information
                    HStack {
                        ///if map is not navigating but location is pinned i.e. selected by the user show the footer with only the button to find routes to the destination
                        if mapViewStatus != .navigating && mapViewStatus != .showingDirections && localSearch.status == .locationSelected {
                            ///routes button. On tap of it change the map action to show directions and make the throughfare nil for it to update it when starting a navigation
                            Button(action: { mapViewAction = .showDirections; locationDataManager.throughfare = nil },
                                   label: { NavigationButton(imageName: "arrow.triangle.swap", title: "Routes")})
                            .background(RadialGradient(gradient: Gradient(colors: [Color(red: 0.095, green: 0.716, blue: 0.941), Color(red: 0.092, green: 0.43, blue: 0.89)]), center: .center, startRadius: 1, endRadius: 50))
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
                                        ForEach(routeData.reversed(), id: \.id) { route in
                                            ///enclose the content in HStack
                                            HStack {
                                                Spacer()
                                                ///enclose the Text and HStack in VStack
                                                VStack {
                                                    ///show the travel time at the top
                                                    Text(route.travelTime)
                                                        .fontWeight(.semibold)
                                                        .font(.title3)
                                                    ///show the distane and title at the bottom enclosed in HStack
                                                    HStack {
                                                        Text(route.distance)
                                                            .fontWeight(.light)
                                                            .font(.footnote)
                                                        Text("Via " + route.title)
                                                            .fontWeight(.light)
                                                            .font(.footnote)
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
                                                        NavigationButton(imageName: "xmark", title: "Stop") :
                                                        ///if it is not navigating then change the text with navigate and arrows symbol with blue background.
                                                        NavigationButton(imageName: "steeringwheel", title: "Go")
                                                        
                                                    })
                                                    .background(isMapInNavigationMode().0 ? RadialGradient(gradient: Gradient(colors: [Color(red: 1, green: 0.4, blue: 0.0), Color(red: 1, green: 0.0, blue: 0.00)]), center: .center, startRadius: 1, endRadius: 50) :  RadialGradient(gradient: Gradient(colors: [Color(red: 0.095, green: 0.716, blue: 0.941), Color(red: 0.092, green: 0.43, blue: 0.89)]), center: .center, startRadius: 1, endRadius: 50))
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
                                                        NavigationButton(imageName: "xmark", title: "Stop") :
                                                        ///if it is not navigating then change the text with navigate and arrows symbol with blue background.
                                                        NavigationButton(imageName: "arrow.up.and.down.and.arrow.left.and.right", title: "Navigate")
                                                        
                                                    })
                                                    .background(isMapInNavigationMode().0 ? RadialGradient(gradient: Gradient(colors: [Color(red: 1, green: 0.4, blue: 0.0), Color(red: 1, green: 0.0, blue: 0.00)]), center: .center, startRadius: 1, endRadius: 50) :  RadialGradient(gradient: Gradient(colors: [Color(red: 0.095, green: 0.716, blue: 0.941), Color(red: 0.092, green: 0.43, blue: 0.89)]), center: .center, startRadius: 1, endRadius: 50))
                                                    .cornerRadius(10)
                                                    .padding(0)
                                                    .disabled(true)
                                                    .hidden()
                                                }
                                               
                                              
                                            }
                                            .background(bgMode == .dark ? Color(.darkGray) : Color(.lightGray))
                                            .overlay(Divider().background(bgMode == .dark ? Color(.lightGray) : Color(.darkGray)), alignment: .bottom)
                                            .cornerRadius(10)
                                           
                                            .onTapGesture(perform: {
                                                updateRouteData(for: route)
                                                isRouteSelectTapped = true
                                            })
                                           
                                        }
                                }
                                ///if map is navigating then show the remaining distance from the current location to the destination.
                                else if mapViewStatus == .navigating {
                                    ///enclose the ETA texts in HStack
                                    HStack {
                                        ///add as spacer on left side of the hstack
                                        Spacer()
                                        ///enclose the remaining Distance text with its subtitle in VStack.
                                        VStack {
                                            Text(remainingDistance)
                                                .font(.title2)
                                                .fontWeight(.black)
                                            Text("Remains")
                                                .foregroundStyle(.gray)
                                        }
                                        ///add a spacer after the vstack
                                        Spacer()
                                        ///enclose the ETA text with its subtitle in VStack
                                        VStack {
                                            Text(ETA)
                                                .font(.title2)
                                                .fontWeight(.black)
                                            Text("Arrival")
                                                .foregroundStyle(.gray)
                                        }
                                        ///add a spacer after the vstack
                                        Spacer()
                                    }
                                    .gesture(DragGesture().onChanged {
                                        value in
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
                                        .onEnded {value in
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
                                    )
                                }
                                else if localSearch.status == .showingNearbyLocations {
                                    ExpandViewSymbol()
                                    List {
                                        ForEach(localSearch.suggestedLocations!, id: \.title) { suggestion in
                                            HStack {
                                                VStack {
                                                    HStack {
                                                        Text(suggestion.title!!.split(separator: "\n").first!)
                                                            .font(.caption)
                                                            .fontWeight(.black)
                                                        Spacer()
                                                    }
                                                  
                                                    Text(suggestion.title!!.split(separator: "\n").last!)
                                                        .font(.caption2)
                                                        .foregroundStyle(.gray)
                                                }
                                                    .onTapGesture(perform: {
                                                     tappedAnnotation = suggestion
                                                        height = 200.0
                                                     //   mapViewAction = .showDirections; locationDataManager.throughfare = nil
                                                    })
                                                Spacer()
                                                Button(action: { tappedAnnotation = suggestion; mapViewAction = .showDirections; locationDataManager.throughfare = nil },
                                                       label: { NavigationButton(imageName: "arrow.triangle.swap", title: "Routes")})
                                                .buttonStyle(.plain)
                                                .background(RadialGradient(gradient: Gradient(colors: [Color(red: 0.095, green: 0.716, blue: 0.941), Color(red: 0.092, green: 0.43, blue: 0.89)]), center: .center, startRadius: 1, endRadius: 50))
                                                .cornerRadius(10)
                                               // .padding(5)
                                            }
                                        }
                                       
                                    }
                                    .frame(height: height)
                                }
                            }
                            .gesture(DragGesture().onChanged { value in
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
                               print(height)
                            }
                                .onEnded{ value in
                                    DispatchQueue.main.async {
                                        if height < 200 {
                                            height = 200
                                        }
                                        else if height > 400 {
                                            height = 400
                                        }
                                    }
                                   
                                    print(height)
                                })
                            Spacer()
                        }
                        .onTapGesture {
                            withAnimation {
                                showAddressView.toggle()
                            }
                        }
                        ///if map is showing directions or is already navigating, show the button to start/stop the navigation. ///button appearance will be changed based on whether the map is navigating or not
                        if mapViewStatus == .navigating {
                            ///on tap of the button updateUserTracking method will be called. its background will change based on whether it is navigating or not.
                            Button(action: updateLocationTracking, label: {
                                ///if map is navigating
                                isMapInNavigationMode().0 ?
                                ///change the button appearance with stop text and xmark symbol
                                NavigationButton(imageName: "xmark", title: "Stop") :
                                ///if it is not navigating then change the text with navigate and arrows symbol with blue background.
                                NavigationButton(imageName: "arrow.up.and.down.and.arrow.left.and.right", title: "Navigate")
                            })                           
                            .background(isMapInNavigationMode().0 ? RadialGradient(gradient: Gradient(colors: [Color(red: 1, green: 0.4, blue: 0.0), Color(red: 1, green: 0.0, blue: 0.00)]), center: .center, startRadius: 1, endRadius: 50) :  RadialGradient(gradient: Gradient(colors: [Color(red: 0.095, green: 0.716, blue: 0.941), Color(red: 0.092, green: 0.43, blue: 0.89)]), center: .center, startRadius: 1, endRadius: 50))
                            .cornerRadius(15)
                            .padding(5)
                        }
                      
                    }
                }
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
    MapInteractionsView(mapViewStatus: .constant(.idle), mapViewAction: .constant(.idle), showAddressView: .constant(false), locationDataManager: LocationDataManager(), localSearch: LocalSearch(), destination: "", routeTravelTime: .constant(""), routeData: .constant([]), routeDistance: .constant(""), remainingDistance: "", instruction: .constant(""), nextStepLocation: .constant(CLLocation()), stepInstructions: .constant([]), ETA: .constant(""), isRouteSelectTapped: .constant(false), tappedAnnotation: .constant(MKPointAnnotation()))
}


