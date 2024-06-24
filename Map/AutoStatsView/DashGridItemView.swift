//
//  DashGridItemView.swift
//  Map
//
//  Created by saj panchal on 2024-06-21.
//

import SwiftUI

struct DashGridItemView: View {
    var title: String
    var foreGroundColor: Color
    var backGroundColor: Color
    var numericText: String
    var unitText: String
    var geometricSize: CGSize
    var body: some View {
        GridRow {
            VStack {
                Text(title)
                    .fontWeight(.semibold)
                    .font(.system(size: 15))
                    .foregroundStyle(foreGroundColor)
                VStack {
                    Text(numericText)
                        .fontWeight(.bold)
                        .font(.system(size: 20))
                        .foregroundStyle(foreGroundColor)
                    Text(unitText)
                        .fontWeight(.medium)
                        .font(.system(size: 16))
                        .foregroundStyle(foreGroundColor)
                     
                }
                .frame(width: (geometricSize.width/2 - 30), height: (geometricSize.width/3) - 60)
                .background(backGroundColor.gradient)
                .cornerRadius(10)
            }
        }
    }
}

#Preview {
    DashGridItemView(title: "", foreGroundColor: Color.clear, backGroundColor: Color.clear, numericText: "", unitText: "", geometricSize: CGSize())
}
