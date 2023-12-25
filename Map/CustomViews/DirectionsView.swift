//
//  DirectionsView.swift
//  Map
//
//  Created by saj panchal on 2023-12-10.
//

import SwiftUI

struct DirectionsView: View {
    var directionSign: String
    var nextStepDistance: String
    var instruction: String
    @Binding var showDirectionsList: Bool
    var body: some View {
        VStack {
            HStack {
                VStack {
                    Image(systemName: directionSign)
                        .font(.title)
                        .fontWeight(.black)
                        .padding(.top, 5)
                    Text("\(nextStepDistance)")
                        .padding(.bottom, 5)
                        .font(.title2)
                        .fontWeight(.black)
                    
                }
                Spacer()
                if #available(iOS 17.0, *) {
                    Text(instruction)
                        .padding(10)
                        .font(.title3)
                     //   .background(.black)
                    //  .onAppear(perform: speech)
                    // .onChange(of: instruction, speech)
                } else {
                    Text(instruction)
                        .padding(10)
                        .font(.title3)
                    //    .background(.black)
                }
                
                Spacer()
            }
           // .background(.black.gradient)
            .onTapGesture {
                withAnimation {
                    showDirectionsList.toggle()
                }
            }
            if !showDirectionsList {
              ExpandViewSymbol()
                .onTapGesture {
                    withAnimation {
                        showDirectionsList.toggle()
                    }
                }
          
            }
           
           
        }
        .padding(.horizontal,10)
        .background(Color.black.gradient)
    }
}

#Preview {
    DirectionsView(directionSign: "", nextStepDistance: "", instruction: "", showDirectionsList: .constant(false))
}
