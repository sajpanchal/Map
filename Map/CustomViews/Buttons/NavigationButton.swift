//
//  MapInteractionsButton.swift
//  Map
//
//  Created by saj panchal on 2024-01-05.
//

import SwiftUI

struct NavigationButton: View {
    var imageName: String
    var title: String
    var foregroundColor: Color
    var body: some View {
        ///button appearance
        VStack {
            ///show image on top of the text with font styles and background set.
            Image(systemName: imageName)
                .font(.title)
                .fontWeight(.black)
                .foregroundStyle(foregroundColor)
            Text(title)
                .foregroundStyle(foregroundColor)
                .font(.caption2)
                .fontWeight(.bold)
        }
        .frame(width: 50, height: 50)
    }
}

#Preview {
    NavigationButton(imageName: "", title: "", foregroundColor: .clear)
}
