//
//  MapProgressView.swift
//  Map
//
//  Created by saj panchal on 2023-08-18.
//

import SwiftUI

struct MapProgressView: View {
    var alertMessage: String = ""
    var body: some View {
        VStack {
            //indefinite progress view
            ProgressView()
            //associated alert to let know user to wait for a process to finish.
            Text(alertMessage)
                .fontWeight(.ultraLight) // modifier to define the font thickness/style
                .font(.caption) //modifier to define the font size
                .padding(5)
                .background(.thinMaterial)
                .cornerRadius(4)
              
            
        }
    }
}

struct MapProgressView_Previews: PreviewProvider {
    static var previews: some View {
        MapProgressView()
    }
}
