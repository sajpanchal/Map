//
//  NetworkAlertView.swift
//  Map
//
//  Created by saj panchal on 2024-09-06.
//

import SwiftUI

struct NetworkAlertView: View {
    @Environment (\.colorScheme) var bgMode: ColorScheme
    var body: some View {
        HStack {
            Spacer()
            VStack {
                HStack {
                    Image(systemName: "network.slash")
                        .foregroundStyle(.invertRd)
                        .font(.system(size: 30))
                    Text("No Network!")
                        .font(.system(size: 30))
                        .foregroundStyle(.gray)
                }
                 Text("Please check your network connection or try again.")
                     .foregroundStyle(.gray)
                     .font(.caption)
            }
           
            Spacer()
        }
        .padding(.vertical,40)
        
        .background(bgMode == .dark ? Color.black : Color.white)
     
    }
}

#Preview {
    NetworkAlertView()
}
