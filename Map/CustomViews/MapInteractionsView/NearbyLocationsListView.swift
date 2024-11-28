//
//  NearbyLocationsListView.swift
//  Map
//
//  Created by saj panchal on 2024-06-08.
//

import SwiftUI
import MapKit
struct NearbyLocationsListView: View {
    ///state object of local search to check if the destination location has been selected or not
    @StateObject var localSearch: LocalSearch
    ///state object of Location manager to show the distance remaining from destination
    @StateObject var locationDataManager: LocationDataManager
    ///bounded property to store map action to be performed
    @Binding var mapViewAction: MapViewAction
    @Binding var tappedAnnotation: MKAnnotation?
    @Binding var height: Double
    @State private var selection: String = ""
 
    var body: some View {
        if let locations = localSearch.suggestedLocations {
            ScrollView {
                ForEach(locations, id: \.title) { suggestion in
                     VStack {
                         HStack {
                             VStack {
                                 HStack {
                                     Text(suggestion.title!!.split(separator: "\n").first!)
                                         .font(.caption)
                                         .fontWeight(.black)
                                     Spacer()
                                 }
                                 HStack {
                                     Text(suggestion.title!!.split(separator: "\n").last!)
                                         .font(.caption2)
                                         .foregroundStyle(.gray)
                                     Spacer()
                                 }
                             }
                           
                             
                             Spacer()
                             Button(action: { tappedAnnotation = suggestion; mapViewAction = .showDirections; locationDataManager.throughfare = nil; },
                                    label: { NavigationButton(imageName: "arrow.triangle.swap", title: "Routes", foregroundColor: Color(AppColors.lightSky.rawValue), size: 60)})
                             .buttonStyle(.plain)
                             .background(Color(AppColors.darkSky.rawValue))
                             .cornerRadius(10)
                         }
                         .padding(15)
                         .background()
                         .cornerRadius(10)
                         .tag(suggestion.hash)
                         .onTapGesture {                            
                             DispatchQueue.main.async {
                                 tappedAnnotation = suggestion
                             }
                             height = 200.0
                         }
                         Divider()
                     }
                     .tag(suggestion.hash)
                }
            }
        }
        else {
            Text("Sorry")
        }
    }
}

#Preview {
    NearbyLocationsListView(localSearch: LocalSearch(), locationDataManager: LocationDataManager(), mapViewAction: .constant(.idle), tappedAnnotation: .constant(MKPointAnnotation()), height: .constant(0.0))
}
