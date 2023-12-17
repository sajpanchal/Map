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
                        .frame(width: 50, height: 50)
                        .foregroundStyle(Color.white.gradient)
                        .cornerRadius(10)
                    if imageName == "circle" || imageName == "circle.fill" {
                        Circle()
                            .frame(width: 30, height: 30)
                            .foregroundStyle(Color.gray.gradient)
                    }
                    
                    Image(systemName: imageName)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 25, height: 25)
                        .foregroundStyle(imageName == "circle.fill" ? Color.blue.gradient : Color.gray.gradient)
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
