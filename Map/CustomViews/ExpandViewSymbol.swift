//
//  ExpandViewSymbol.swift
//  Map
//
//  Created by saj panchal on 2023-12-10.
//

import SwiftUI

struct ExpandViewSymbol: View {
    var body: some View {
        HStack {
            Spacer()
            Rectangle()
                .frame(width: 30, height: 5)
                .cornerRadius(5)
            Spacer()
        }
        .padding(5)
       // .background(.black)
    }
}
#Preview {
    ExpandViewSymbol()
}
