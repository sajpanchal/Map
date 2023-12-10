//
//  ListView.swift
//  Map
//
//  Created by saj panchal on 2023-08-22.
//

import SwiftUI

struct ListView: View {
   
    
    @StateObject var localSearch: LocalSearch
    @Binding var searchedLocationText: String
    @Binding var isLocationSelected: Bool
    var body: some View {
        List {
            Spacer()
            ForEach(localSearch.searchedLocations, id:\.self.id) { suggestion in
                VStack {
                    HStack {
                        Text("\(suggestion.name)")
                            .font(.body)
                            .fontWeight(.bold)
                        Spacer()
                    }
                    HStack {
                        Text(" \(suggestion.subtitle)")
                            .font(.caption)
                            .fontWeight(.ultraLight)
                        Spacer()
                    }
                }
                .onTapGesture {
                    localSearch.tappedLocation = suggestion.annotation
                    searchedLocationText = (searchedLocationText == suggestion.name) ? (suggestion.name + " ") : suggestion.name
                    isLocationSelected = true
                   // localSearch.c.removeAll()
                    print("tapped list item")
               
                }
            }
        }
     
      
    }
}

struct ListView_Previews: PreviewProvider {
    static var previews: some View {
        ListView(localSearch: LocalSearch(), searchedLocationText: .constant(""), isLocationSelected: .constant(false))
    }
}
