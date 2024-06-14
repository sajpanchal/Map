//
//  AddressView.swift
//  Map
//
//  Created by saj panchal on 2024-06-14.
//

import SwiftUI

struct AddressView: View {
    var destination: String
    var body: some View {
        ///show the hstack that is displaying the expanded view with the destination address and title.
        HStack {
            Spacer()
            ///showing the title and destination address and its name.
            VStack {
                //Text(MapViewAPI.comment)
                Text("Heading to destination")
                    .font(.caption2)
                    .fontWeight(.bold)
                Text(destination)
                    .font(.caption2)
                    .multilineTextAlignment(.center)
            }
            Spacer()
        }
    }
}

#Preview {
    AddressView(destination: "")
}
