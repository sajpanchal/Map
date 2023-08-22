//
//  ListView.swift
//  Map
//
//  Created by saj panchal on 2023-08-22.
//

import SwiftUI

struct ListView: View {
    @Binding var searchedLocations: [SearchedLocation]
    var body: some View {
        ForEach(searchedLocations) { suggestion in
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
        }
    }
}

struct ListView_Previews: PreviewProvider {
    static var previews: some View {
        ListView(searchedLocations: .constant([]))
    }
}
