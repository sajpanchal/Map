//
//  MapInteractionsView.swift
//  Map
//
//  Created by saj panchal on 2023-12-10.
//

import SwiftUI
import CoreLocation
struct MapInteractionsView: View {
    @Binding var mapViewStatus: MapViewStatus
    @Binding var mapViewAction: MapViewAction
    @Binding var showSheet: Bool
    @StateObject var locationDataManager: LocationDataManager
    var destination: String
    var routeETA: String
    var routeDistance: String
    var distance: String
    @Binding var instruction: String
    @Binding var nextStepLocation: CLLocation?
    var body: some View {
        VStack(spacing: 0) {
            Spacer()
            ///custom buttons that is floating on our  if map is navigating but it is not centered to user location show the location button to center it on tap.
            if isMapInNavigationMode().0 && isMapInNavigationMode().1 == .inNavigationNotCentered {
                MapViewButton(imageName: "location.fill")
                    .gesture(TapGesture().onEnded(centerMapToUserLocation))
            }
            ///if map is not navigating show the circle button to center the map to user location whenever tapped.
            if !isMapInNavigationMode().0 && mapViewStatus != .showingDirections {
                MapViewButton(imageName: mapViewStatus == .centeredToUserLocation ? "circle.fill" : "circle")
                    .gesture(TapGesture().onEnded(centerMapToUserLocation))
            }
            if mapViewStatus == .navigating {
                Spacer()
                ExpandViewSymbol()
                    .onTapGesture {
                        withAnimation {
                            showSheet.toggle()
                        }
                        
                    }
                if showSheet {
                    HStack {
                        Spacer()
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
                    .background(.black)
                    .onTapGesture {
                        withAnimation {
                            showSheet.toggle()
                        }
                    }
                }
            }
            HStack {
                if mapViewStatus != .navigating {
                    Button(action: { mapViewAction = .showDirections; locationDataManager.throughfare = nil },
                           label: {
                        Text("Routes")
                            .frame(height: 60)
                            .foregroundStyle(.white)
                    }
                    )
                    .background(Color.blue)
                    .cornerRadius(10)
                    .padding(10)
                }
                Group {
                    Spacer()
                    VStack {
                        if mapViewStatus == .showingDirections {
                            Text(routeETA)
                            Text(routeDistance)
                        }
                        else if mapViewStatus == .navigating {
                            Text(distance)
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
                
                if mapViewStatus == .showingDirections || mapViewStatus == .navigating {
                    Button(action: updateUserTracking, label: {
                        isMapInNavigationMode().0 ?
                        Text("Stop")
                            .frame(height: 60)
                            .foregroundStyle(.white) :
                        Text("Navigate")
                            .frame(height: 60)
                            .foregroundStyle(.white)
                    })
                    .background(isMapInNavigationMode().0 ? .red : .blue)
                    .cornerRadius(10)
                    .padding(10)
                }
                
            }
            .background(.black)
        }
    }
    func isMapInNavigationMode() -> (Bool,MapViewStatus) {
        switch mapViewStatus {
        case .idle, .notCentered, .centeredToUserLocation, .showingDirections:
            return (false,mapViewStatus)
        case .navigating, .inNavigationCentered, .inNavigationNotCentered:
            return (true,mapViewStatus)
        }
    }
    func updateUserTracking() {
        print("user navigation tracking is available.")
        ///set mapViewAction to idle mode if status is navigating when button is pressed set mapViewAction to nagivate if status is not navigating when button is pressed.
        switch mapViewStatus {
        case .idle, .notCentered, .centeredToUserLocation, .showingDirections:
            locationDataManager.distance = 0.0
            mapViewAction = .navigate
            ///UIApplocation is the class that has a centralized control over the app. it has a property called shared that is a singleton instance of UIApplication itself. this instance has a property called isIdleTimerDisabled. which will decide if we want to turn off the phone screen after certain amount of time of inactivity in the app. we will set it to true so it will keep the screen alive when user tracking is on.
            UIApplication.shared.isIdleTimerDisabled = true
            break
        case .navigating, .inNavigationCentered, .inNavigationNotCentered:
            mapViewAction = .idle
            instruction = ""
            nextStepLocation = nil
            UIApplication.shared.isIdleTimerDisabled = false
            break
        }
    }
    func centerMapToUserLocation() {
        mapViewAction = isMapInNavigationMode().0 ? .inNavigationCenterToUserLocation : .centerToUserLocation
    }
 
}

#Preview {
    MapInteractionsView(mapViewStatus: .constant(.idle), mapViewAction: .constant(.idle), showSheet: .constant(false), locationDataManager: LocationDataManager(), destination: "", routeETA: "", routeDistance: "", distance: "", instruction: .constant(""), nextStepLocation: .constant(CLLocation()))
}
