//
//  MapSwiftUIAPI.swift
//  Map
//
//  Created by saj panchal on 2023-12-10.
//

import Foundation

///function to get the image/sign name based on the instruction content.
func getDirectionSign(for step: String) -> String? {
    ///convert the instruction to lowercase.
    let instruction = step.lowercased()
    ///checking if the instruction contains a given substring
    if instruction.contains("turn left") {
        ///returning the system name for the sign image to be displayed with instruction.
        return "arrow.turn.up.left"
    }
    else if instruction.contains("turn right")
    {
        return "arrow.turn.up.right"
    }
    else if instruction.contains("slight left") {
        return "arrow.up.left"
    }
    else if instruction.contains("slight right") {
        return "arrow.up.right"
    }
    else if instruction.contains("sharp left") {
        return "arrow.down.left"
    }
    else if instruction.contains("sharp right") {
        return "arrow.down.right"
    }
    else if instruction.contains("keep right") {
        return "rectangle.righthalf.inset.filled.arrow.right"
    }
    else if instruction.contains("keep left") {
        return "rectangle.lefthalf.inset.filled.arrow.left"
    }
    else if instruction.contains("continue") {
        return "arrow.up"
    }
    else if instruction.contains("first exit") {
        return "1.circle"
    }
    else if instruction.contains("second exit") {
        return "2.circle"
    }
    else if instruction.contains("third exit") {
        return "3.circle"
    }
    else if instruction.contains("make a u-turn"){
        return "arrow.uturn.down"
    }
    else if instruction.contains("fourth exit") {
     return "4.circle"
    }
    else if instruction.contains("exit") {
        return "arrow.up.right"
    }
    else if instruction.contains("starting at")
    {
        return "car.rear.road.lane.dashed"
    }
    else if instruction.contains("arrive") || instruction.contains("arrived") {
        return "mappin.and.ellipse"
    }
    else if instruction.contains("re-calculating the route...") {
        return "exclamationmark.triangle"
    }
    else if instruction.contains("Arrive at the destination") || instruction.contains("    ") {
        return "arcade.stick"
    }
    else if instruction.contains("destination is on your right") || instruction.contains("   ") {
        return "arcade.stick.and.arrow.right"
    }
    else if instruction.contains("destination is on your left") ||  instruction.contains("  "){
        return "arcade.stick.and.arrow.left"
    }
    ///if there is no match then return nil
    else if instruction.contains("re-calculating the route..."){
        return "exclamationmark.triangle"
    }
    else {
        return ""
    }
   
}

///function to convert a number to string and format it.
func convertToString(from number: Double) -> String {
    ///create a variable from a given number
    var num = number
    ///if number is 1000 or above
    if num >= 1000 {
        ///divide it to 1000 to convert from meters to km.
        num = number/1000
        ///return the string with formatting it to show upto 1 digit after decimal points and appending km sign.
        return String(format:"%.1f", num) + " km"
    }
    ///otherwise, if it is less than 1000
    else {
        ///convert the double to integer
       let num = Int(number)
        ///convert it to string and append meter sign. return it.
        return String(num) + " m"
    }
}

///function to check if the mapview is waiting to update the status after action is triggered for the same.
func isMapViewWaiting(to action: MapViewAction, for status: MapViewStatus, in actualAction: MapViewAction) -> Bool {
    ///check what status the action is having.
    switch action {
        ///checking for navigate action
    case .navigate:
        ///check if the status is not updated to navigating and when the actual action is navigate right now.
        return (status != .navigating && actualAction == .navigate)
        ///checking for center to user location action
    case .centerToUserLocation:
        ///check if the status is not yet centered to user location when actual action is center to user location
        return (status != .centeredToUserLocation && actualAction == .centerToUserLocation)
        ///checking for in navigation center to user location action
    case .inNavigationCenterToUserLocation:
        ///check if the status is not yet inNavigationCenteredToUserLocation  when actual action is inNavigationCenterToUserLocation
        return (status != .inNavigationCentered && actualAction == .inNavigationCenterToUserLocation)
        ///checking for idle action
    case .idle:
        ///check if the status is not yet out of navigation mode  when actual action is idle
        return (isMapInNavigationMode(for: status).0 && actualAction == .idle)
        ///checking for idle in navigation action
    case .idleInNavigation:
        ///check if the status is not yet inNavigationNotCentered when actual action is idleInNavigation
        return (status != .inNavigationNotCentered && actualAction == .idleInNavigation)
        ///checking for show directions action
    case .showDirections:
        ///check if the status is not yet showingDirections when actual action is showDirections
        return (status != .showingDirections && actualAction == .showDirections)
        ///checking for idleInShowDirections action
    case .idleInshowDirections:
        ///check if the status is not yet showingDirectionsNotCentered when actual action is idleInshowDirections
        return (status != .showingDirectionsNotCentered && actualAction == .idleInshowDirections)
    }
}

///fuction to check if map is in navigation mode or not
func isMapInNavigationMode(for status: MapViewStatus) -> (Bool,MapViewStatus) {
    ///check for the status
    switch status {
        ///if any of these cases are true then return the tuple with false result (to show it is not in navigation mode) and return the actual status too.
    case .idle, .notCentered, .centeredToUserLocation, .showingDirections, .showingDirectionsNotCentered:
        return (false,status)
        ///if any of these cases are true then return the tuple with true result (to show it is in navigation mode) and return the actual status too.
    case .navigating, .inNavigationCentered, .inNavigationNotCentered:
        return (true,status)
    }
}


