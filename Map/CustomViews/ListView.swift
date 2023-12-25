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
            ForEach(localSearch.results, id:\.self.id) { suggestion in
                VStack {
                    HStack {
                        Text("\(suggestion.title)")
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
                    localSearch.getPlace(from: suggestion)
                    searchedLocationText = (searchedLocationText == suggestion.title) ? (suggestion.title + " ") : suggestion.title
                    isLocationSelected = true
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
