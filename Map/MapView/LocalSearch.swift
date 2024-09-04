//
//  SearchViewModel.swift
//  Map
//
//  Created by saj panchal on 2023-12-21.
//

import Foundation
import MapKit

///a class that is used to handle the searchfield related actions such as starting a location search, showing results, autocomplete location search, annotating selected location in map and cancellation.
class LocalSearch: NSObject, ObservableObject, MKLocalSearchCompleterDelegate {
    ///variable that will store the results of autocomplete location search suggestions.
    @Published var results: [AddressResult] = []
    ///the variable to be used as a query text for locationSearchCompleter.
    @Published var searchableText = ""
    ///an array that will store the locations for a desired place (matching with location name and address)
    @Published var suggestedLocations: [MKAnnotation]?
    ///flag to be set when search request is made and is still under process.
   // @Published var isSearchInProgress = false
    @Published var status: LocalSearchStatus = .localSearchCancelled
    ///an instance of MKLocalSearch to generate a search request.
    let request = MKLocalSearch.Request()
    
    ///this is the variable that is responsible for generating a list of complete location strings for the partial search
   private lazy var locationSearchCompleter: MKLocalSearchCompleter = {
        let completer = MKLocalSearchCompleter()
       ///set the LocalSearch object as its delegate so we can use MKLocalSearchCompleter methods in this class and it will be called whenever completer updates the results
        completer.delegate = self
        return completer
    }()
    ///starting a search operation for a typed string in the search field and setting up the region in the map within which the search will be covered.
    func startLocalSearch(withSearchText: String, inRegion: MKCoordinateRegion) {
        ///string typed for search
        searchableText = withSearchText
        ///if it is empty return the call to a function
        guard searchableText.isEmpty == false else { return }
        ///set the region for the search request object to search for.
        request.region = inRegion
        ///set the query fragment for search completer so it can generate the completed search results.
        locationSearchCompleter.queryFragment = searchableText
       
        }
    ///when search completer updates the array of completed search for a given searched text this method will be called.
    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        ///async task
        Task { @MainActor in
            ///completer has a results property that has the array of completion search results with location name and address. here we are mapping the reuslts to our AddressResults array that is going to be displayed in a listview of the search bar.
            results = completer.results.map{
                AddressResult(title: $0.title, subtitle: $0.subtitle)
            }
            ///if the subtitle of the address results are empty remove them from the list.
            results.removeAll(where: {
                $0.subtitle.isEmpty
            })
        }
    }

    ///method will be called when cancel button is tapped.
    func cancelLocationSearch() {
        ///create a request object
           let request = MKLocalSearch(request: request)
        ///cancel the search request.
            request.cancel()
        ///clear and make an array nil
           self.suggestedLocations = nil
        ///clear the adress results
           self.results.removeAll()
       }
    ///method will be called when any of the suggested address results are tapped from list.
    func getPlace(from address: AddressResult) {
      ///get the address title
        let title = address.title
        ///get the address subtitle
        let subTitle = address.subtitle
        if subTitle == "Search Nearby" {
            request.naturalLanguageQuery = title
        }
        else {
            ///set the natural language query to search for a location using its title and subtitle
            request.naturalLanguageQuery = subTitle.contains(title)
            ? subTitle : title + ", " + subTitle
        }
       
        ///asnc task
        Task {
            ///start the location search and get the response
            do {
                let response = try await MKLocalSearch(request: request).start()

                await MainActor.run {
                    ///response will be having mapItems which is having placemarks for each locations matched by location title and subtitle
                    self.suggestedLocations = response.mapItems.compactMap {
                        ///create an annotation object
                        let annotation = MKPointAnnotation()
                        ///assign the annotation object the coordinates of the mapitem placemark
                        annotation.coordinate = $0.placemark.coordinate
                        ///assign the annotation object a title of the placemark object to be displayed on map.
                        if let title = $0.placemark.title, let name = $0.name {
                            annotation.title = title.contains(name) ?  title : (name + "\n" + title)
                        }
                        ///set the flag false once response is processed.
                        status = subTitle == "Search Nearby" ? .showingNearbyLocations : .locationSelected
                        ///return the annotation object and append it to suggestedLocations array. (Usually for each response there will be only one mapItem matching with the title and subtitle.)
                        return annotation
                    }
                }
            }
            catch {
                status = .localSearchFailed
            }
            
        }
    }
    
   ///if there will be an error generated by locationSearchCompleter object.
    func completer(_ completer: MKLocalSearchCompleter, didFailWithError error: Error) {
        print(error)
        status = .localSearchFailed
    }
}
