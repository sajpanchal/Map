//
//  MapSwiftUIButton.swift
//  Map
//
//  Created by saj panchal on 2023-08-18.
//

import SwiftUI

struct MapViewButton: View {
    var imageName: String = ""
    
    var body: some View {
        //this is the button to start tracking the user location. when it is tapped, MapView will start tracking the user location by
        //instantiating the mapView camera with its associated properties.
        VStack {
            Spacer()
            HStack {
                Spacer()
                ZStack {
                    Rectangle()
                        .frame(width: 60, height: 60)
                        .foregroundColor(.gray)
                        .cornerRadius(10)
                    Image(systemName: imageName)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 35, height: 35)
                        .foregroundColor(.white)
                }
                
            }
            .padding(10)
        }
        .padding(20)
         
    }
}

struct MapViewButton_Previews: PreviewProvider {
    static var previews: some View {
        MapViewButton()
    }
}
