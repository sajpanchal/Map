//
//  ListView.swift
//  Map
//
//  Created by saj panchal on 2023-08-22.
//

import SwiftUI

///this swiftui view is responsible for showing up the list of suggested addresses when user is typing any address string in the searchfield.
struct AddressListView: View {
    ///local search object that handles the search queries/
    @StateObject var localSearch: LocalSearch
    ///bounded string that stores the searched string getting from the searchfield input
    @Binding var searchedLocationText: String
   
    var body: some View {
        ///list view
        List {
            ///this loop will iterate for each result in the results array of localSearch object which is unique. and from it we will display the results seperated by its title and subtitle in a VStack
            ForEach(localSearch.results, id:\.self.id) { suggestion in
                ///enclose the hstack in vstack
                VStack {
                    ///display the result title
                    HStack {
                        Text("\(suggestion.title)")
                            .font(.body)
                            .fontWeight(.bold)
                        Spacer()
                    }
                    ///display the result subtitle.
                    HStack {
                        Text(" \(suggestion.subtitle)")
                            .font(.caption)
                            .fontWeight(.ultraLight)
                        Spacer()
                    }
                }
                ///on tap of this list item the code in the braces will be executed to get that location in the map
                .onTapGesture {
                    ///set the flag to true to indicate search for the locations is in progress.
                    localSearch.status = .localSearchInProgress
                    ///this method will pin the given location in the map.
                    localSearch.getPlace(from: suggestion)
                    ///replace the partial searched text with the complete title received from selected location
                    searchedLocationText = (searchedLocationText == suggestion.title) ? (suggestion.title + " ") : suggestion.title
                    ///set the flag true to indicate that destination has been selected.
                   
                }
            }
        }
        .onAppear(perform:  {
            ///on appearance of listview
            DispatchQueue.main.async {
                ///set the flag to true to indicate listview is on display
                localSearch.status = .localSearchResultsAppear
            }
        })
    }
}

struct ListView_Previews: PreviewProvider {
    static var previews: some View {
        AddressListView(localSearch: LocalSearch(), searchedLocationText: .constant(""))
    }
}
