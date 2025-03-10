//
//  NewEntryStackView.swift
//  Map
//
//  Created by saj panchal on 2024-06-20.
//

import SwiftUI

struct NewEntryStackView: View {
    @Environment(\.colorScheme) var bgMode: ColorScheme
    var foregroundColor: Color
    var width: CGFloat
    var title: String
    var body: some View {
        Group {
            VStack {
                HStack {
                    ZStack {
                        Rectangle()
                            .frame(width: 30, height: 30)
                            .foregroundStyle(foregroundColor)
                        Image(systemName: "plus.square.fill")
                            .font(.system(size: 40))
                          
                    }
                    .shadow(color: bgMode == .dark ? Color(UIColor.darkGray) : .black, radius: 1, x: 1, y: 1)
                    Spacer()
                    Text(title)
                        .foregroundStyle(bgMode == .dark ? Color(UIColor.systemGray2) : Color(UIColor.darkGray))
                        .font(.system(size: 18, weight: .bold))
                    Spacer()
                }
            }
            .padding(10)
            .frame(width:width - 30)
            
            
            Divider()
                .padding(.horizontal,20)
        }
    }
}

#Preview {
    NewEntryStackView(foregroundColor: .clear, width: 0.0, title: "New Entry")
}
