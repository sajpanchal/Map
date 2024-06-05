//
//  ExpandedDirectionsView.swift
//  Map
//
//  Created by saj panchal on 2023-12-10.
//

import SwiftUI

///this swiftui view is responsible for showing the expanded list view with next steps instructions.
struct ExpandedDirectionsView: View {
    ///environment variable to get the current color mode of the phone
    @Environment (\.colorScheme) var bgMode: ColorScheme
    ///a variable stores an array of tuple types with each pair having a step instructions and distance from current step.
    var stepInstructions: [(String, Double)]
    ///bounded property that is used to show or hide this view.
    @Binding var showDirectionsList: Bool
    @Binding var height: CGFloat
    @Binding var nextInstruction: String
    var body: some View {
        ///
        VStack {
            ///enclosing the listview in hstack.
            HStack {
                ///list view for an array of step instructions
                List(content: {
                    ///iterate through stepInstructions tuple array where each instruction string is unique
                    ForEach(stepInstructions,id:\.self.0, content: { stepInstruction in
                        ///for each tuple in the array display the instruction with signs and distance in this hstack
                        HStack {
                            ///to the left show the sign with the distance in the bottom of it.
                            VStack {
                                ///check if there is an image i.e. directions sign  available for a given step substring.
                                if let image = getDirectionSign(for: stepInstruction.0) {
                                    Image(systemName: image)
                                        .font(.title)
                                        .fontWeight(.black)
                                        .padding(.top, 5)
                                }
                                ///convert the distance to string and do proper formating and display the returned string.
                                Text(convertToString(from:stepInstruction.1))
                                    .padding(.bottom, 5)
                                    .font(.title2)
                                    .fontWeight(.black)
                            }
                            Spacer()
                            ///display the instruction string.
                            Text(stepInstruction.0)
                                .padding(10)
                                .font(.title3)
                            Spacer()
                        }
                    })
                   
                })
           
                ///when this listview is tapped anywhere, hide it by toggling the flag with animation
                .onTapGesture {
                    withAnimation {
                        showDirectionsList = true
                    }
                }
            }
            ///add a expand symbol at the bottom of it.
            if showDirectionsList {
                ExpandDirectionsViewSymbol(showDirectionsList: $showDirectionsList, nextInstruction: $nextInstruction)
                Spacer()
            }
           
               // .background(Color.gray)
         
        }
        .background(bgMode == .dark ? Color.black : Color.white)
        .gesture(DragGesture().onChanged { value in
                withAnimation {
                    if value.translation.height >= 0 {
                            height =  min(value.translation.height, UIScreen.main.bounds.height)
                    }
                    else {
                        if height >= 0 {
                                height = UIScreen.main.bounds.height + value.translation.height - 100
                        }
                    }
                }
            }
            .onEnded { value in
                withAnimation {
                if height >= 0 {
                    showDirectionsList = true                  
                }
                else {
                    height = 0
                    showDirectionsList = false
                }
                if value.translation.height > 150 {
                        height = UIScreen.main.bounds.height - 100
                }
                else if value.translation.height < -100 {
                    height = 0
                    showDirectionsList = false
                }
                }
            })
    }
}

#Preview {
    ExpandedDirectionsView(stepInstructions: [], showDirectionsList: .constant(false), height: .constant(0), nextInstruction: .constant(""))
}
