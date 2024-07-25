//
//  AddCarImage.swift
//  Map
//
//  Created by saj panchal on 2024-07-24.
//

import SwiftUI

struct AddCarImage: View {
    var body: some View {
        ZStack {
            Image(systemName: "car.fill")
                .font(Font.system(size:30))

            VStack {
                HStack {
                    ZStack {
                        Circle()
                         
                            .foregroundStyle(Color(UIColor.systemBackground))
                          
                        Image(systemName:"plus.circle.fill")
                            .font(Font.system(size:14))
                            .fontWeight(.black)
                    }
                   
                                                   
                    Rectangle()
                        .foregroundStyle(.clear)
                }
                HStack {
                    Rectangle()
                        .foregroundStyle(.clear)
                    
                    Rectangle()
                        .foregroundStyle(.clear)
                }
            }
                           
        }
    }
}

#Preview {
    AddCarImage()
}
