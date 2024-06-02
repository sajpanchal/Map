//
//  ExpandViewSymbol.swift
//  Map
//
//  Created by saj panchal on 2023-12-10.
//

import SwiftUI

///this swiftuiview is responsible to show the expand symbol/sign
struct ExpandViewSymbol: View {
    var body: some View {
        HStack {
            Spacer()
            Rectangle()
                .frame(width: 30, height: 5)
                .cornerRadius(5)
             
            Spacer()
        }
        .frame(height: 20)
    }
}

#Preview {
    ExpandViewSymbol()
}
