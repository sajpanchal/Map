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
    @Environment (\.colorScheme) var bgMode: ColorScheme
    var body: some View {
        GridRow {
            VStack {
                Text(title)
                    .fontWeight(.semibold)
                    .font(.system(size: 15))
                    .foregroundStyle(.gray)
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
                //.background(backGroundColor.gradient)
                .background(bgMode == .dark ? Color(UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1.0)) : Color(UIColor(red: 0.96, green: 0.96, blue: 0.96, alpha: 1.0)))
                .cornerRadius(10)
            }
        }
    }
}

#Preview {
    DashGridItemView(title: "", foreGroundColor: Color.clear, backGroundColor: Color.clear, numericText: "", unitText: "", geometricSize: CGSize())
}
