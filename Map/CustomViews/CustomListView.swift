//
//  CustomListView.swift
//  Map
//
//  Created by saj panchal on 2024-07-24.
//

import SwiftUI

struct CustomListView: View {
    @Environment (\.colorScheme) var bgMode: ColorScheme
    var date: Date
    var text1: (String,String)
    var text2: (String, String)
    var text3: (String, String)
    var timeStamp: String
    var redColor = Color(red:0.861, green: 0.194, blue:0.0)
    var skyColor = Color(red:0.031, green:0.739, blue:0.861)
    var yellowColor = Color(red:0.975, green: 0.646, blue: 0.207)
    var greenColor = Color(red: 0.257, green: 0.756, blue: 0.346)
    var width: CGFloat
    var body: some View {
        Group {
            VStack {
                Text(date.formatted(date: .long, time: .omitted))
                    .font(.system(size: 15))
                    .fontWeight(.black)
                    .foregroundStyle(redColor)
                    Spacer()
                HStack {
                    VStack {
                        Text(text1.0)
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundStyle(bgMode == .dark ? Color(UIColor.systemGray2) : Color(UIColor.darkGray))
                        Text(text1.1)
                            .fontWeight(.bold)
                            .foregroundStyle(skyColor)
                    }
                    .frame(width: 100)
                    if !text2.1.isEmpty {
                        Spacer()
                        VStack {
                            Text(text2.0)
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundStyle(bgMode == .dark ? Color(UIColor.systemGray2) : Color(UIColor.darkGray))
                            Text(text2.1)
                                .fontWeight(.bold)
                                .foregroundStyle(yellowColor)
                        }
                    }
                   
                    
                    Spacer()
                    VStack {
                        Text(text3.0)
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundStyle(bgMode == .dark ? Color(UIColor.systemGray2) : Color(UIColor.darkGray))
                        Text(text3.1)
                            .fontWeight(.bold)
                            .foregroundStyle(greenColor)
                    }
                }
               Spacer()
                Text(timeStamp)
                    .font(.system(size: 8))
                    .foregroundStyle(bgMode == .dark ? Color(UIColor.systemGray2) : Color(UIColor.darkGray))
            }
            .padding(10)
                .frame(width:width - 30)
            Divider()
                .padding(.horizontal,20)
        }
    }
}

#Preview {
    CustomListView(date: Date(), text1: ("",""), text2: ("",""), text3: ("",""), timeStamp: "", width: 50)
}
