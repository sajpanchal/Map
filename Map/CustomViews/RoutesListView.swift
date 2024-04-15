//
//  RoutesListView.swift
//  Map
//
//  Created by saj panchal on 2024-04-11.
//

//import SwiftUI
//
//struct RoutesListView: View {
//    @Binding var routeData: [RouteData]
//    @Environment (\.colorScheme) var bgMode: ColorScheme
//    @Binding var isRouteSelectTapped: Bool
//    var body: some View {
//        ForEach(routeData.reversed(), id: \.id) { route in
//            ///enclose the content in HStack
//            HStack {
//                Spacer()
//                ///enclose the Text and HStack in VStack
//                VStack {
//                    ///show the travel time at the top
//                    Text(route.travelTime)
//                        .fontWeight(.semibold)
//                        .font(.title3)
//                    ///show the distane and title at the bottom enclosed in HStack
//                    HStack {
//                        Text(route.distance)
//                            .fontWeight(.light)
//                            .font(.footnote)
//                        Text("Via " + route.title)
//                            .fontWeight(.light)
//                            .font(.footnote)
//                    }
//                }
//                Spacer()
//                ///if the route is tapped show the button at the right space in the HStack
//                if route.tapped {
//                    ///on tap of the button updateUserTracking method will be called. its background will change based on whether it is navigating or not.
//                    Button(action: MapInteractionsView.updateLocationTracking, label: {
//                        ///if map is navigating
//                        isMapInNavigationMode().0 ?
//                        ///change the button appearance with stop text and xmark symbol
//                        NavigationButton(imageName: "xmark", title: "Stop") :
//                        ///if it is not navigating then change the text with navigate and arrows symbol with blue background.
//                        NavigationButton(imageName: "steeringwheel", title: "Go")
//                        
//                    })
//                    .background(isMapInNavigationMode().0 ? Color.red.gradient : Color.blue.gradient)
//                    .cornerRadius(15)
//                    .padding(5)
//                    
//                }
//                ///else hide it.
//                else {
//                    ///on tap of the button updateUserTracking method will be called. its background will change based on whether it is navigating or not.
//                    Button(action: MapInteractionsView.updateLocationTracking, label: {
//                        ///if map is navigating
//                        isMapInNavigationMode().0 ?
//                        ///change the button appearance with stop text and xmark symbol
//                        NavigationButton(imageName: "xmark", title: "Stop") :
//                        ///if it is not navigating then change the text with navigate and arrows symbol with blue background.
//                        NavigationButton(imageName: "arrow.up.and.down.and.arrow.left.and.right", title: "Navigate")
//                        
//                    })
//                    .background(isMapInNavigationMode().0 ? Color.red.gradient : Color.blue.gradient)
//                    .cornerRadius(15)
//                    .padding(5)
//                    .disabled(true)
//                    .hidden()
//                }
//               
//              
//            }
//            .background(bgMode == .dark ? Color.black.gradient : Color.white.gradient)
//            .overlay(Divider().background(bgMode == .dark ? Color.white : Color.black), alignment: .bottom)
//            .cornerRadius(10)
//           
//            .onTapGesture(perform: {
//                updateRouteData(for: route)
//                isRouteSelectTapped = true
//            })
//        }
//    }
//    func updateRouteData(for route: RouteData) {
//        ///get the index of the given route that is selected by the user
//        guard let indexOfSelectedRoute = routeData.firstIndex(of: route) else {
//            return
//        }
//        ///get the index of the route that was previously selected
//        if let indexOfPrevSelectedRoute = routeData.firstIndex(where: {$0.tapped}) {
//            ///reset the tapped property of the given route.
//            routeData[indexOfPrevSelectedRoute].tapped = false
//        }
//        ///set the tapped prop of a currenty selected route.
//        routeData[indexOfSelectedRoute].tapped = true
//    }
//}
//
//#Preview {
//    RoutesListView(routeData: .constant([]), isRouteSelectTapped: .constant(false))
//}
