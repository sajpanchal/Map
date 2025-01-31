//
//  SearchFieldView.swift
//  Map
//
//  Created by saj panchal on 2023-08-25.
//

import SwiftUI
import MapKit

///swiftui view that gets the location search input from the user
struct SearchFieldView: View {
    ///bounded variable that gets the string input from the search field
    @Binding var searchedLocationText: String
    ///this is the variable that will be updated when the search field is typed or tapped.
    @FocusState var enableSearchFieldFocus: Bool
    ///setting the region boundry of the map for search
    var region: MKCoordinateRegion
    ///state object for handling local search events
    @StateObject var localSearch: LocalSearch
   
    var body: some View {
        ///
        HStack {
            ///search sign and textfield enclosed in a stack.
            HStack {
                Image(systemName: "magnifyingglass")
                    .padding(.leading, 5)
                ///this is the text field where user types the location search string
                TextField("Search for a location", text: $searchedLocationText)
                    .focused($enableSearchFieldFocus)
                    .onChange(of: enableSearchFieldFocus) {
                        if enableSearchFieldFocus {
                            localSearch.status = .searchBarActive
                        }
                        else {
                        
                        }
                    }
                ///when the text in a searchable field changes this method will be called and it will perform a method put inside perform parameter.
                .onChange(of: searchedLocationText) {
                    ///this method will initiate or terminate the location search.
                    self.handleLocationSearch(forUserInput: searchedLocationText)
                    print("on change")
                }
                .onSubmit {
                    print("return key tapped: \(searchedLocationText)")
                    ///start a local search with a given search text in a given region.
                    localSearch.startLocalSearch(withSearchText: searchedLocationText, inRegion: region)
                    ///
                    localSearch.startLocalSearch(withSearchText: searchedLocationText + " ", inRegion: region)
                    ///update the localSearch status to in progess
                    localSearch.status = .localSearchInProgress
                    ///asynchronous code to be executed after 0.5 secs.
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        ///get the first element from a local search results generated from a searched text
                        if let result = localSearch.results.first {
                            searchedLocationText = result.title
                            ///from a result get the location (MKAnnotation)
                            localSearch.getPlace(from: result)
                            ///update the status to showing nearby locations
                            localSearch.status = .showingNearbyLocations
                            ///disable the search field focus.
                            enableSearchFieldFocus = false
                        }
                        else {
                            print("no results found")
                        }
                    }
                }
            ///on tap it will call a method to prepare searchfield.
            .onTapGesture(perform: prepareSearchfield)
            }
            .frame(height: 40)
            .background(.ultraThinMaterial)
            .cornerRadius(5)
            .padding(5)
            ///if the search field is focused.
            if enableSearchFieldFocus {
                ///show the cancel button for user to cancel the search.
                Button("Cancel", action: clearSearchfield)
                .background(.clear)
                .disabled(false)
            }
            else {
                ///if not focus keep it hidden and disabled.
                Button("Cancel", action: clearSearchfield)
                .background(.clear)
                .hidden()
                .disabled(true)
            }
        }
    }
    
    ///method to start or stp the location search
    func handleLocationSearch(forUserInput text:String) {
        ///if location is selected or search is cancelled
        guard localSearch.status == .searchBarActive || localSearch.status == .localSearchResultsAppear || localSearch.status == .localSearchInProgress || localSearch.status == .localSearchFailed || localSearch.status == .locationUnselected  else {
            ///un-focus the search field
            enableSearchFieldFocus = false
            ///stop the location search
            localSearch.cancelLocationSearch()
            ///and return from a function
            return
        }
        ///keep calling the startLocalsearch() of observable object localSearch with its searchLocations array as observed property. this will update Map swiftUI view on every change in searchLocations.
        localSearch.startLocalSearch(withSearchText: text, inRegion: region)
        enableSearchFieldFocus = localSearch.status != .locationSelected  ? true : false
    }
    
    ///when searchfield is tapped this function will be executed.
    func prepareSearchfield() {
        ///location is not selected when we are starting a search
        DispatchQueue.main.async {
            localSearch.status = .searchBarActive
            ///this variable is a focusstate type, this is going to be passed to focus() modifier of our searchfield and is responsible to enable and disable the focus.
            enableSearchFieldFocus = true
        }
    }
    
    ///when cancel button is tapped
    func clearSearchfield() {
        ///clear the text from searchfield
        searchedLocationText = ""
        ///cancel the search operations
        localSearch.status = .localSearchCancelled
        ///make the locations array nil
        localSearch.suggestedLocations = nil
        ///un-focus the search field.
        enableSearchFieldFocus = false
        print("cleared Search")
    }
}

struct SearchFieldView_Previews: PreviewProvider {
    static var previews: some View {
        SearchFieldView(searchedLocationText: .constant(""), region: MKCoordinateRegion(), localSearch: LocalSearch())
    }
}
