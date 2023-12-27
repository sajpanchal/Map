//
//  SearchViewModel.swift
//  Map
//
//  Created by saj panchal on 2023-12-21.
//

import Foundation

import MapKit
class LocalSearch: NSObject, ObservableObject, MKLocalSearchCompleterDelegate {
    @Published var results: [AddressResult] = []
    @Published var searchableText = ""
    @Published var isSearchCancelled = false
    @Published var isDestinationSelected = false
    @Published var suggestedLocations: [MKAnnotation]?
    let request = MKLocalSearch.Request()
    
   private lazy var locationSearchCompleter: MKLocalSearchCompleter = {
        let completer = MKLocalSearchCompleter()
        completer.delegate = self
        return completer
    }()
    
    func startLocalSearch(withSearchText: String, inRegion: MKCoordinateRegion) {
        searchableText = withSearchText
            guard searchableText.isEmpty == false else { return }
        request.region = inRegion
        print("startLocalSearch")
        locationSearchCompleter.queryFragment = searchableText
       
        }
    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        Task { @MainActor in
            results = completer.results.map{
                AddressResult(title: $0.title, subtitle: $0.subtitle)
            }
            results.removeAll(where: {
                $0.subtitle.isEmpty
            })
        }
    }
    func cancelLocationSearch() {
           let request = MKLocalSearch(request: request)
            request.cancel()
           self.suggestedLocations = nil
           self.results.removeAll()
       }
    func getPlace(from address: AddressResult) {
      
        let title = address.title
        let subTitle = address.subtitle
        
        request.naturalLanguageQuery = subTitle.contains(title)
        ? subTitle : title + ", " + subTitle
        
        Task {
            let response = try await MKLocalSearch(request: request).start()
            await MainActor.run {
                self.suggestedLocations = response.mapItems.map {
                    let annotation = MKPointAnnotation()
                    annotation.coordinate = $0.placemark.coordinate
                    if let title = $0.placemark.title, let name = $0.name {
                        annotation.title = title.contains(name) ?  title : (name + "\n" + title)
                    }
              
                    return annotation
                }
                
              
            }
        }
    }
   
    func completer(_ completer: MKLocalSearchCompleter, didFailWithError error: Error) {
        print(error)
    }
    
}
