//
//  DirectionsView.swift
//  Map
//
//  Created by saj panchal on 2024-06-12.
//

import SwiftUI
import AVFoundation
struct DirectionsView: View {
    ////environment variable to get the color mode of the phone
    @Environment(\.colorScheme) var bgMode: ColorScheme
    @Binding var instruction: String
    @Binding var nextStepDistance: String
    @Binding var showDirectionsList: Bool
    @State private var expandedDirectionsViewHeight: CGFloat = 0
    @Binding var nextInstruction: String
    @Binding var stepInstructions: [(String, String)]
    ///locationDataManager is an instance of a class that has a delegate of LocationManager and its methods.
    @StateObject var locationDataManager: LocationDataManager
    @StateObject var speechViewModel: SpeechViewModel
    var body: some View {
        VStack(spacing: 0) {
            VStack(spacing: 0) {
                DirectionHeaderView(directionSign: getDirectionSign(for: instruction), nextStepDistance: nextStepDistance, instruction: instruction, showDirectionsList: $showDirectionsList, height: $expandedDirectionsViewHeight, locationDataManager: locationDataManager, speechViewModel: speechViewModel)
                    .gesture(DragGesture().onChanged(directionViewDragChanged)
                        .onEnded(directionViewDragEnded))
                ZStack {
                    HStack {
                        Spacer()
                            Image(systemName: getDirectionSign(for: nextInstruction) ?? "")
                            .foregroundStyle(.gray)
                            Text(nextInstruction)
                                .lineLimit(1)
                                .fontWeight(.black)
                                .foregroundStyle(.gray)
                        Spacer()
                                                                                           
                    }
                    .padding(10)
                    .background(bgMode == .dark ? Color(UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1.0)) : Color(UIColor.systemGray5))
                    DirectionsListView(stepInstructions: stepInstructions, showDirectionsList: $showDirectionsList, height: $expandedDirectionsViewHeight, nextInstruction: $nextInstruction)
                        .frame(height: expandedDirectionsViewHeight <= 100 ? 0 : expandedDirectionsViewHeight , alignment: .leading)
                }
            }
            Spacer()
        }
    }
    func directionViewDragChanged(value: DragGesture.Value) {
        withAnimation {
            if value.translation.height >= 0 {
                expandedDirectionsViewHeight =  min(value.translation.height, UIScreen.main.bounds.height)
            }
            else {
                if expandedDirectionsViewHeight >= 0 {
                    expandedDirectionsViewHeight = UIScreen.main.bounds.height + value.translation.height - 100
                }
            }
        }
    }
    func directionViewDragEnded(value: DragGesture.Value) {
        
                  withAnimation {
                      if expandedDirectionsViewHeight >= 0 {
                          showDirectionsList = true
                      }
                      else {
                          expandedDirectionsViewHeight = 0
                          showDirectionsList = false
                      }
                      if value.translation.height > 150 {
                          expandedDirectionsViewHeight = UIScreen.main.bounds.height - 100
                      }
                      else if value.translation.height < -100 {
                          expandedDirectionsViewHeight = 0
                          showDirectionsList = false
                      }
                  }
    }
}

#Preview {
    DirectionsView(instruction: .constant(""), nextStepDistance: .constant(""), showDirectionsList: .constant(false), nextInstruction: .constant(""), stepInstructions: .constant([]), locationDataManager: LocationDataManager(), speechViewModel: SpeechViewModel())
}
