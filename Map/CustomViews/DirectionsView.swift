//
//  DirectionsView.swift
//  Map
//
//  Created by saj panchal on 2023-12-10.
//

import SwiftUI

///a view responsible to show the direction signs along with the instruction text on top of the screen while navigating.
struct DirectionsView: View {
    ///environment variable to get the color mode of the phone
    @Environment (\.colorScheme) var bgMode: ColorScheme
    ///variable that stores the image name for various direction signs.
    var directionSign: String?
    ///stores distance from the next step in string format.
    var nextStepDistance: String
    ///stores the instruction string.
    var instruction: String
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
                    }
                    ///show the distance from next step
                    if !instruction.contains("Re-calculating the route...") {
                        Text("\(nextStepDistance)")
                            .padding(.bottom, 5)
                            .font(.title2)
                            .fontWeight(.black)
                    }
                    
                }
                ///add a space between directions and instruction stacks.
                Spacer()
                    ///showing the instruction in a text format
                    Text(instruction)
                        .padding(10)
                        .font(.title3)
                ///add a spacer to the right of the instruction view.
                Spacer()
            }
            /// on tap of the horizontal stack (Directions + instructions)
//            .onTapGesture {
//                ///with animation toggle the flag to hide or show the expanded directions list view.
//                withAnimation {
//                    showDirectionsList.toggle()
//                }
//            }
            ///if flag is false i.e. directions list view is hidden add the symbol view to the bottom of the Hstack.
            //if !showDirectionsList {
                ///show the symbol for expandable view.
            //  ExpandViewSymbol()
//                .onTapGesture {
//                    withAnimation {
//                        showDirectionsList.toggle()
//                    }
//                }
            //}
        }
        .padding(.horizontal,10)
        ///apply the black gradient to entire view.
        .background(bgMode == .dark ? Color.black.gradient : Color.white.gradient)
//        .gesture(DragGesture().onChanged { value in
//            if value.translation.height >= 0 {
//                height =  min(value.translation.height, UIScreen.main.bounds.height)
//            }
//            else {
//                if height >= 0 {
//                    height = UIScreen.main.bounds.height + value.translation.height - 100
//                }
//            }
//            }
//            .onEnded { value in
//              //  showDirectionsList = true
//                if height > 0 {
//                    showDirectionsList = true
//                  
//                }
//                
//                else {
//                    height = 0
//                    showDirectionsList = false
//                }
//                if abs(value.translation.height) > 100 {
//                    height = UIScreen.main.bounds.height
//                }
//                else {
//                    height = 0
//                    showDirectionsList = false
//                }
//            })
    }
}

#Preview {
    DirectionsView(directionSign: "", nextStepDistance: "", instruction: "", showDirectionsList: .constant(false), height: .constant(0))
}
