//
//  MapView.swift
//  Map
//
//  Created by saj panchal on 2023-08-03.
//

import SwiftUI
//this view will observe the LocationDataManager and updates the MapViewController if data in Location
//Manager changes.
struct Map: View {
    //this will make our MapView update if any @published value in location manager changes.
    @StateObject var locationDataManager = LocationDataManager()
    //this is a state variable that will let mapview object know if the mapview is tapped with drag gesture with certain drag amount.
    @State var tapped: Bool
    var body: some View {
        VStack {
            //just a text field to see user' current location.
            Text("Last Updated Location: \(locationDataManager.userlocation?.coordinate.latitude.description ?? "n/a"), \(locationDataManager.userlocation?.coordinate.longitude.description ?? "n/a")")
            //calling our custom struct that will render UIView for us in swiftui.
            //we are passing the user coordinates that we have accessed from CLLocationManager in our locationDataManager class.
            //we are also passing the state variable called tapped that is bound to the MapView.
            //when any state property is passed to a binding property of its child component, it must be wrapped using $ symbol in prefix.
            //we always declare a binding propery in a child component of the associated property from its parent.
            //once the value is bound, a child component can read and write that value and any changes will be reflected in parent side.
            MapView(location: $locationDataManager.userlocation, tapped: $tapped)
            //gesture is a view modifier that can call various intefaces such as DragGesture() to detect the user touch-drag gesture on a
            //given view. each inteface as certain actions to perform. such as onChanged() or onEnded(). Here, drag gesture has onChanged()
            //action that has an associated value holding various data such as location cooridates of starting and ending of touch-drag.
            //we are passing a custom function as a name to onChanged() it will be executed on every change in drag action data. in this
            
                .gesture(DragGesture().onChanged(dragGestureAction))
            Button("Re-Center", action: {
                tapped = true
            })
        }
        
        
    }
    //custom function takes the DragGesture value.
    //custom function we calculate the distance of the drag from 2D cooridinates of starting and ennding points. then we check if the distance
    //is more than 10. if so, we undo the user-location re-center button tap.
    func dragGestureAction(value: DragGesture.Value) {
        let x = abs(value.location.x - value.startLocation.x)
        let y = abs(value.location.y - value.startLocation.y)
        let distance = sqrt((x*x)+(y*y))
        if distance > 10 {
            tapped = false
        }
    }
}

struct Map_Previews: PreviewProvider {
    static var previews: some View {
        Map(tapped: (false))
    }
}
