//
//  SearchProgressView.swift
//  Map
//
//  Created by saj panchal on 2024-09-06.
//

import SwiftUI

struct SearchProgressView: View {
    @Environment(\.colorScheme) var bgMode: ColorScheme
    var body: some View {
        HStack {
            Spacer()
            Text("Showing search results... please wait!")
                .foregroundStyle(.gray)
                .font(.caption)
            Spacer()
        }
        .padding(.vertical,40)
        .background(bgMode == .dark ? Color.black : Color.white)
    }
}

#Preview {
    SearchProgressView()
}
