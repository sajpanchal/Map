//
//  FormButton.swift
//  Map
//
//  Created by saj panchal on 2024-07-24.
//

import SwiftUI

struct FormButton: View {
    var imageName: String
    var text: String
    var color: Color
    var body: some View {
        HStack {
            Spacer()
            Image(systemName: imageName)
                .foregroundStyle(color)
                .font(Font.system(size: 25))
            
            Text(text)
                .fontWeight(.black)
                .foregroundStyle(color)
            Spacer()
        }
        .frame(height: 40, alignment: .center)
    }
}

#Preview {
    FormButton(imageName: "", text: "", color: Color.clear)
}
