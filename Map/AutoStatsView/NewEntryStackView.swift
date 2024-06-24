//
//  NewEntryStackView.swift
//  Map
//
//  Created by saj panchal on 2024-06-20.
//

import SwiftUI

struct NewEntryStackView: View {
    var width: CGFloat
    var body: some View {
        Group {
            VStack {
                HStack {
                    Image(systemName: "plus.square.fill")
                        .font(.system(size: 40))
                    Spacer()
                    Text("New Entry")
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
    NewEntryStackView(width: 0.0)
}
