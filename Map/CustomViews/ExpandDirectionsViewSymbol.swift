//
//  ExpandDirectionsViewSymbol.swift
//  Map
//
//  Created by saj panchal on 2024-05-27.
//

import SwiftUI

struct ExpandDirectionsViewSymbol: View {
    @Binding var showDirectionsList: Bool
    @Binding var nextInstruction: String
    var body: some View {
        VStack {
            if showDirectionsList {
                HStack {
                    Spacer()
                    Rectangle()
                        .frame(width: 30, height: 5)
                        .cornerRadius(5)
                     
                    Spacer()
                }
            }
            
//                HStack {
//                    if !showDirectionsList {
//                        Image(systemName: getDirectionSign(for: nextInstruction) ?? "")
//                        Text(nextInstruction)
//                            .lineLimit(1)
//                    }
//                   
//                
//            }
//                .padding(5)
//                
            
          
            //.frame(height: 30)
        }
     
    }
}

#Preview {
    ExpandDirectionsViewSymbol(showDirectionsList: .constant(false), nextInstruction: .constant(""))
}
