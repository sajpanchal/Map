//
//  ContentView.swift
//  Map
//
//  Created by saj panchal on 2023-08-03.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        Map(trackLocation: false, isTracking: false)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
