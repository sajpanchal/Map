//
//  ExpandedDirectionsView.swift
//  Map
//
//  Created by saj panchal on 2023-12-10.
//

import SwiftUI

struct ExpandedDirectionsView: View {
    var stepInstructions: [(String, Double)]
   
   
    @Binding var showDirectionsList: Bool
    var body: some View {
        VStack {
            HStack {
                List(content: {
                    ForEach(stepInstructions,id:\.self.0, content: { stepInstruction in
                        HStack {
                            VStack {
                                if let image = getDirectionSign(for: stepInstruction.0) {
                                    Image(systemName: image)
                                        .font(.title)
                                        .fontWeight(.black)
                                        .padding(.top, 5)
                                }
                                Text(convertToString(from:stepInstruction.1))
                                    .padding(.bottom, 5)
                                    .font(.title2)
                                    .fontWeight(.black)
                            }
                            Spacer()
                            Text(stepInstruction.0)
                                .padding(10)
                                .font(.title3)
                            Spacer()
                        }
                    })
                })
                .onTapGesture {
                    withAnimation {
                        showDirectionsList.toggle()
                    }
                }
            }
          ExpandViewSymbol()
            .onTapGesture {
                withAnimation {
                    showDirectionsList.toggle()
                }
            }
        }
        .background(.black.gradient)
    }
    
   
}

#Preview {
    ExpandedDirectionsView(stepInstructions: [], showDirectionsList: .constant(false))
}
