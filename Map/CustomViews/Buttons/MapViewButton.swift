//
//  MapSwiftUIButton.swift
//  Map
//
//  Created by saj panchal on 2023-08-18.
//

import SwiftUI

///custom buttons to be used  for MapView
struct MapViewButton: View {
    @FetchRequest(entity: Vehicle.entity(), sortDescriptors: []) var vehicles: FetchedResults<Vehicle>
    ///systemname of the image to be displayed on the button
    @Environment(\.colorScheme) var bgMode: ColorScheme
    var imageName: String = ""
    var speed: Int = 0
  //  @ObservedObject var locationDataManager: LocationDataManager
    var body: some View {
        ///enclose the hstack in vstack with a spacer above so the button view will stay at the bottom of the screen.
        VStack {
            Spacer()
            ///enclose the zstack in HStack with a spacer to the left so the button view will appear with right alignment.
            HStack {
                Spacer()
                ///Stack that adds one view on top of the other (from top to bottom it adds views above each)
                ZStack {
                    ///add a rectangle shape as a background view for the button
                    Rectangle()
                        .frame(width: 50, height: 50)
                        .foregroundStyle(Color(UIColor.systemGray3))
                        .cornerRadius(10)
                        .shadow(color: .black, radius: 1, x: 1, y: 1)
                    ///if the image name is circle or circle with fill
                    if imageName == "circle" || imageName == "circle.fill" {
                        ///add a circle with gray gradiant on top of a rectangle.
                        Circle()
                            .frame(width: 30, height: 30)
                            .foregroundStyle(Color.white)
                    }
                    ///if no image name is received
                    if imageName == "" {
                        ///get the first instance of settings.
                        if let activeVehicle = vehicles.first(where: {$0.isActive}) {
                            if let thisSettings = activeVehicle.settings {
                                ///vertical stack.
                                VStack {
                                    ///if the distance unit is in km show speed in km/h otherwise show it in mi/h.
                                    Text(thisSettings.getDistanceUnit == "km" ? String(speed) : String(Int(Double(speed)/1.609)))
                                        .multilineTextAlignment(.center)
                                        .fontWeight(.semibold)
                                        .font(.system(size: 25))
                                        .foregroundStyle(bgMode == .dark ? .white : .black)
                                    ///if the distance unit is in km show display unit km/h otherwise mi/h.
                                    Text(thisSettings.getDistanceUnit == "km" ? "km/h" : "mi/h")
                                        .font(.system(size: 12))
                                        .foregroundStyle(bgMode == .dark ? .white : .black)
                                }
                            }
                        }
                       
                    }
                    else {
                        ///add an image to be displayed
                        Image(systemName: imageName == "circle" || imageName == "circle.fill" ? "circle.fill" : imageName)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 20, height: 20)
                        ///set its color to blue gradient if image is having a circle filled otherwise set the gray geadient.
                            .foregroundStyle(imageName == "circle" || imageName == "location" ? Color.blue : Color.white)
                    }
                  
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
