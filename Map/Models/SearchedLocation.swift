//
//  SearchedLocation.swift
//  Map
//
//  Created by saj panchal on 2023-08-22.
//

import Foundation
import MapKit

class LocalSearch: ObservableObject {
    @Published var searchedLocations: [SearchedLocation] = []
    @Published var tappedLocation: MKAnnotation?
    var searchRequest = MKLocalSearch.Request()
     func startLocalSearch(withSearchText searchedLocationText: String, inRegion mapRegion: MKCoordinateRegion) {
        
        
        searchRequest.region = mapRegion
        searchRequest.naturalLanguageQuery = searchedLocationText
        
        let request = MKLocalSearch(request: searchRequest)
         if !request.isSearching {
             request.start { (response, error) in
                 guard let response = response  else {
                     print("search error:\(error?.localizedDescription ?? "n/a")")
                     request.cancel()
                     return
                 }
                 self.searchedLocations = response.mapItems.map(SearchedLocation.init)
              //   print(self.searchedLocations)
             }
         }
           
    }
    func cancelLocationSearch() {
        let request = MKLocalSearch(request: searchRequest)
        request.cancel()
      //  self.tappedLocation = nil
        self.searchedLocations.removeAll()
    }
}
struct SearchedLocation: Identifiable {
    var mapItem: MKMapItem
    init(mapItem: MKMapItem) {
        self.mapItem = mapItem
    }
    var name: String {
        mapItem.name ?? "n/a"
    }
    var subtitle: String {
        mapItem.placemark.title ?? "n/a"
    }
    var annotation: MKAnnotation {
        let pointAnnotation = MKPointAnnotation()
        pointAnnotation.coordinate = mapItem.placemark.coordinate
        pointAnnotation.title = name + "\n" + subtitle
        return pointAnnotation
    }
    var id: UUID = UUID()
   
}
