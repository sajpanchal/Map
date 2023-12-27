//
//  SearchFieldView.swift
//  Map
//
//  Created by saj panchal on 2023-08-25.
//

import SwiftUI
import MapKit
struct SearchFieldView: View {
    @Binding var searchedLocationText: String
    @FocusState var enableSearchFieldFocus: Bool
    var region: MKCoordinateRegion
    @StateObject var localSearch: LocalSearch
   
   
    var body: some View {
        HStack {
            HStack {
                Image(systemName: "magnifyingglass")
                    .padding(.leading, 5)
                TextField("Search for a location", text: $searchedLocationText)
                    .focused($enableSearchFieldFocus)
                    //when the text in a searchable field changes this method will be called and it will perform a method put inside perform parameter.
                    .onChange(of: searchedLocationText) {
                        handleLocationSearch(forUserInput: searchedLocationText)
                    }
                    .onTapGesture(perform: prepareSearchfield)
            }
            .frame(height: 40)
            .background(.ultraThinMaterial)
            .cornerRadius(5)
            .padding(5)
            if enableSearchFieldFocus {
                Button("Cancel", action: clearSearchfield)
                .background(.clear)
                .disabled(false)
            }
            else {
                Button("Cancel", action: clearSearchfield)
                .background(.clear)
                .hidden()
                .disabled(true)
            }
        }
    }
    
    func handleLocationSearch(forUserInput text:String) {
        ///if location is selected or search is cancelled
        guard !localSearch.isDestinationSelected && !localSearch.isSearchCancelled else {
           ///un-focus the search field
            enableSearchFieldFocus = false
            if localSearch.isDestinationSelected {
            }
            ///stop the location search
            localSearch.cancelLocationSearch()
            ///and return from a function
            return
        }
        ///if search is on then keep the search field in focus
        enableSearchFieldFocus = true
        ///keep calling the startLocalsearch() of observable object localSearch with its searchLocations array as observed property. this will update Map swiftUI view on every change in searchLocations.
        localSearch.startLocalSearch(withSearchText: text, inRegion: region)
       
    }
    ///when searchfield is tapped this function will be executed.
    func prepareSearchfield() {
        ///location is not selected when we are starting a search.
        localSearch.isDestinationSelected = false
        ///this variable is a focusstate type, this is going to be passed to focus() modifier of our searchfield and is responsible to enable and disable the focus.
        enableSearchFieldFocus = true
        ///this variable shows and hides the cancel button
        localSearch.isSearchCancelled = false
    }
    ///when cancel button is tapped
    func clearSearchfield() {
        ///clear the text from searchfield
        searchedLocationText = ""
        ///cancel the search operations
        localSearch.isSearchCancelled = true
        localSearch.suggestedLocations = nil
        localSearch.isDestinationSelected = false
        ///un-focus the search field.
        enableSearchFieldFocus = false
    }    
}

struct SearchFieldView_Previews: PreviewProvider {
    static var previews: some View {
        SearchFieldView(searchedLocationText: .constant(""), region: MKCoordinateRegion(), localSearch: LocalSearch())
    }
}
