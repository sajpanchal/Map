//
//  AlertView.swift
//  Map
//
//  Created by saj panchal on 2024-12-23.
//

import SwiftUI

struct AlertView: View {
    let image: String
    let headline: String
    let bgcolor: Color
    @Binding var showAlert: Bool
   
    var body: some View {
        VStack {
            VStack {
                Image(systemName:image)
                    .font(Font.system(size: 45))
                    .foregroundStyle(.background)
                Text(headline)
                    .font(Font.system(size: 16, weight: .black))
                    .foregroundStyle(.background)
            }
            .padding(5)
     
        }
        .frame(width: 270, height: 120)
        .background(bgcolor)
        .cornerRadius(10)
        .shadow(color: .gray, radius: 1, x: 1, y: 1)
        .transition(.opacity)
        let _ = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: false) { (timer) in
                withAnimation(.easeIn(duration: 0.5)) {
                        showAlert = false
                        print("on Appear: \(showAlert)")
                }
            }
    }
}

#Preview {
    AlertView(image: "checkmark.icloud" , headline: "Changes Saved!",bgcolor: .green, showAlert: .constant(false))
}
