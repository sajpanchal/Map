//
//  MapSwiftUIAPI.swift
//  Map
//
//  Created by saj panchal on 2023-12-10.
//

import Foundation

func getDirectionSign(for step: String) -> String {
    let instruction = step.lowercased()

    if instruction.contains("turn left") {
        return "arrow.turn.up.left"
    }
    else if instruction.contains("turn right")
    {
        return "arrow.turn.up.right"
    }
    else if instruction.contains("slight left") {
        return "arrow.turn.left.up"
    }
    else if instruction.contains("slight right") {
        return "arrow.turn.right.up"
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
        return "location.north.line"
    }
    else if instruction.contains("arrive") || instruction.contains("arrived") {
        return "mappin.and.ellipse"
    }
    else if instruction.contains("destination") {
        return "mappin.and.ellipse"
    }
    return ""
}

func convertToString(from number: Double) -> String {
    var num = number
    if num >= 1000 {
       num = number/1000
        return String(format:"%.1f", num) + " km"
    }
    else {
       let num = Int(number)
        return String(num) + " m"
    }
}

func isMapViewWaiting(to action: MapViewAction, for status: MapViewStatus, in actualAction: MapViewAction) -> Bool {
    switch action {
    case .navigate:
        return (status != .navigating && actualAction == .navigate)
    case .centerToUserLocation:
        return (status != .centeredToUserLocation && actualAction == .centerToUserLocation)
    case .inNavigationCenterToUserLocation:
        return (status != .inNavigationCentered && actualAction == .inNavigationCenterToUserLocation)
    case .idle:
        return (isMapInNavigationMode(for: status).0 && actualAction == .idle)
    case .idleInNavigation:
        return (status != .inNavigationNotCentered && actualAction == .idleInNavigation)
    case .showDirections:
        return (status != .showingDirections && actualAction == .showDirections)
    case .idleInshowDirections:
        return (status != .showingDirectionsNotCentered && actualAction == .idleInshowDirections)
    
    }
}

func isMapInNavigationMode(for status: MapViewStatus) -> (Bool,MapViewStatus) {
    switch status {
    case .idle, .notCentered, .centeredToUserLocation, .showingDirections, .showingDirectionsNotCentered:
        return (false,status)
    case .navigating, .inNavigationCentered, .inNavigationNotCentered:
        return (true,status)
    }
}


