//
//  CustomHeaderView.swift
//  Map
//
//  Created by saj panchal on 2025-01-24.
//

import SwiftUI

struct CustomHeaderView: View {
    @Environment(\.colorScheme) var bgMode: ColorScheme
    var signImage: String
    var title: String
    var body: some View {
        ///tappable HStack to show the autoSummaryList view
        HStack {
            ZStack {
                Rectangle()
                    .frame(width: 30, height: 30)
                    .cornerRadius(5)
                    .foregroundStyle(.gray)
                Image(systemName: signImage)
                    .foregroundStyle(bgMode == .dark ? .black : .white)
            }
            Text(title)
                .fontWeight(.bold)
                .foregroundStyle(.gray)
            Spacer()
            Image(systemName:"chevron.up")
                .font(Font.system(size: 14))
                .fontWeight(.semibold)
                .foregroundStyle(.gray)
        }
    }
}

#Preview {
    CustomHeaderView(signImage: "", title: "")
}
