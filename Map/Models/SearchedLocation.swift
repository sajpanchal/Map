//
//  SearchedLocation.swift
//  Map
//
//  Created by saj panchal on 2023-08-22.
//

import Foundation
import MapKit
struct SearchedLocation: Identifiable {
    var name: String
    var subtitle: String
    var id: UUID = UUID()
    static func startLocalSearch(withSearchText searchedLocationText: String, inRegion mapRegion: MKCoordinateRegion) async -> [SearchedLocation] {
        var searchedLocations = [Self]()
        let searchRequest = MKLocalSearch.Request()
        
        searchRequest.region = mapRegion
        searchRequest.naturalLanguageQuery = searchedLocationText
        
        let request = MKLocalSearch(request: searchRequest)
        do {
            let response = try await request.start()
            for item in response.mapItems {
                if let name = item.name, let subtitle = item.placemark.title {
                    searchedLocations.append(Self(name: name, subtitle: subtitle))
                   
                }
            }
        }
        catch {
            print("search error:\(error.localizedDescription)")
        }
      

        return searchedLocations
    }
}
