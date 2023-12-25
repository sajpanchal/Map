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
    @StateObject var localSearch: LocalSearch
    var destination: String
    var routeETA: String
    var routeDistance: String
    var distance: String
    @Binding var instruction: String
    @Binding var nextStepLocation: CLLocation?
    @Binding var stepInstructions: [(String, Double)]
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
                MapViewButton(imageName: mapViewStatus == .centeredToUserLocation ? "circle" : "circle.fill")
                    .gesture(TapGesture().onEnded(centerMapToUserLocation))
            }
            if localSearch.tappedLocation != nil {
                VStack {
                    if mapViewStatus == .navigating {
                  
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
                          //  .background(.black)
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
                                VStack {
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
                            }
                            )
                            .background(.blue.gradient)
                            .cornerRadius(15)
                            .padding(5)
                           
                      
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
    
    func isMapInNavigationMode() -> (Bool,MapViewStatus) {
        switch mapViewStatus {
        case .idle, .notCentered, .centeredToUserLocation, .showingDirections, .showingDirectionsNotCentered:
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
         
            stepInstructions.removeAll()
            instruction = ""
            nextStepLocation = nil
           
            UIApplication.shared.isIdleTimerDisabled = false
            break
        case .showingDirectionsNotCentered:
            UIApplication.shared.isIdleTimerDisabled = false
            break
        }
    }
    func centerMapToUserLocation() {
        mapViewAction = isMapInNavigationMode().0 ? .inNavigationCenterToUserLocation : .centerToUserLocation
    }
   
 
}

#Preview {
    MapInteractionsView(mapViewStatus: .constant(.idle), mapViewAction: .constant(.idle), showSheet: .constant(false), locationDataManager: LocationDataManager(), localSearch: LocalSearch(), destination: "", routeETA: "", routeDistance: "", distance: "", instruction: .constant(""), nextStepLocation: .constant(CLLocation()), stepInstructions: .constant([]))
}
