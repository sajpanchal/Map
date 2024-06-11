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
    var redRadialGradient = RadialGradient(gradient: Gradient(colors: [Color(red: 0.095, green: 0.716, blue: 0.941), Color(red: 0.092, green: 0.43, blue: 0.89)]), center: .center, startRadius: 1, endRadius: 50)
    var body: some View {
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
                        })
                    Spacer()
                    Button(action: { tappedAnnotation = suggestion; mapViewAction = .showDirections; locationDataManager.throughfare = nil },
                           label: { NavigationButton(imageName: "arrow.triangle.swap", title: "Routes")})
                    .buttonStyle(.plain)
                    .background(redRadialGradient)
                    .cornerRadius(10)
                }
            }           
        }
    }
}

#Preview {
    NearbyLocationsListView(localSearch: LocalSearch(), locationDataManager: LocationDataManager(), mapViewAction: .constant(.idle), tappedAnnotation: .constant(MKPointAnnotation()), height: .constant(0.0))
}
