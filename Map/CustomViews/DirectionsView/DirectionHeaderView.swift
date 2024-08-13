//
//  DirectionsView.swift
//  Map
//
//  Created by saj panchal on 2023-12-10.
//

import SwiftUI

///a view responsible to show the direction signs along with the instruction text on top of the screen while navigating.
struct DirectionHeaderView: View {
    ///environment variable to get the color mode of the phone
    @Environment (\.colorScheme) var bgMode: ColorScheme
    ///variable that stores the image name for various direction signs.
    var directionSign: String?
    ///stores distance from the next step in string format.
    var nextStepDistance: String
    ///stores the instruction string.
    var instruction: String
    var skyColor = Color(red:0.031, green:0.739, blue:0.861)
    var lightSkyColor = Color(red:0.657, green:0.961, blue: 1.0)
    var redColor = Color(red:0.861, green: 0.194, blue:0.0)
    var lightRedColor = Color(red:1.0, green:0.654, blue:0.663)
    ///flag that is bound to MapSwiftUI. it is set when user taps on this view to see the expanded directions list view.
    @Binding var showDirectionsList: Bool
    @Binding var height: CGFloat
    var body: some View {
        VStack {
            ///enclosing the directions and instruction view in horizontal stack.
            HStack {
                ///shows direction sign and next step distance below it.
                VStack {
                    ///if directionSign is not empty show the image.
                    if let directionSign = directionSign {
                        Image(systemName: directionSign)
                            .font(.title)
                            .fontWeight(.black)
                            .padding(.top, 5)
                            .foregroundStyle(.gray)
                        
                    }
                    ///show the distance from next step
                    if !instruction.contains("Re-calculating the route...") {
                        Text("\(nextStepDistance)")
                            .padding(.bottom, 5)
                            .font(.title2)
                            .fontWeight(.black)
                            .foregroundStyle(redColor)
                    }
                    
                }
                ///add a space between directions and instruction stacks.
                Spacer()
                    ///showing the instruction in a text format
                    Text(instruction)
                        .padding(10)
                        .font(.title3)
                        .fontWeight(.black)
                        .foregroundStyle(.gray)
                ///add a spacer to the right of the instruction view.
                Spacer()
            }
            if !showDirectionsList {
                ExpandViewSymbol()
            }
        }
        .padding(.horizontal,10)
        ///apply the black gradient to entire view.
        .background(bgMode == .dark ? Color.black.gradient : Color.white.gradient)
    }
}

#Preview {
    DirectionHeaderView(directionSign: "", nextStepDistance: "", instruction: "", showDirectionsList: .constant(false), height: .constant(0))
}
