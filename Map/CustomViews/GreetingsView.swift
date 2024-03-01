//
//  GreetingsView.swift
//  Map
//
//  Created by saj panchal on 2024-02-29.
//

import SwiftUI

struct GreetingsView: View {
    @Binding var showGreetings: Bool
    @Binding var destination: String
    var body: some View {
        VStack {
            Text("You have arrived at:")
                .fontWeight(.light) // modifier to define the font thickness/style
                .font(.footnote) //modifier to define the font size
            Text(destination)
                .fontWeight(.light) // modifier to define the font thickness/style
                .font(.footnote) //modifier to define the font size
              //  .foregroundStyle(Color.gray)
            Button(action: {
                showGreetings = false
            }, label: {
                Text("OK")
            })
            .buttonStyle(.automatic)
        }
        .padding(5)
        .background(.thinMaterial)
        .cornerRadius(10)
    }
}

#Preview {
    GreetingsView(showGreetings: .constant(false), destination: .constant(""))
}
