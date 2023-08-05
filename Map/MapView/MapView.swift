//
//  MapView.swift
//  Map
//
//  Created by saj panchal on 2023-08-03.
//

import SwiftUI
//this view will observe the LocationDataManager and updates the MapViewController if data in Location
//Manager changes.
struct MapView: View {
    //this will make our MapView update if any @published value in location manager changes.
    @StateObject var locationDataManager = LocationDataManager()
    var body: some View {
        VStack {
            Text("Last Updated Location: \(locationDataManager.userlocation?.coordinate.latitude.description ?? "n/a"), \(locationDataManager.userlocation?.coordinate.longitude.description ?? "n/a")")
            //calling our custom struct that will render UIViewController for us in swiftui.
            //we are passing the user coordinates that we have accessed from CLLocationManager in our locationDataManager class.
            MapViewController(location: locationDataManager.userlocation)
            
        }
        
        
    }
}

struct MapView_Previews: PreviewProvider {
    static var previews: some View {
        MapView()
    }
}
