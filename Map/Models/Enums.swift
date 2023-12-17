//
//  Enums.swift
//  Map
//
//  Created by saj panchal on 2023-08-25.
//

import Foundation

//enum type to be used to track the status of MapView
enum MapViewStatus {
    case navigating, centeredToUserLocation, inNavigationCentered, showingDirections, notCentered, inNavigationNotCentered, idle, showingDirectionsNotCentered
}
//enum type to be used to track the button actions of MapView
enum MapViewAction {
    case navigate, centerToUserLocation, inNavigationCenterToUserLocation, showDirections, idle, idleInNavigation, idleInshowDirections
}
//enumeration type definition to handle error. it is of string type so we can assign associated values to each enum case as strings.
enum Errors: String {
    case locationNotFound = "Sorry, your current location not found!"
    case headingNotFound = "Sorry, your current heading not found!"
    case locationNotVisible = "Sorry, your current location is not able to display on map!"
    case unKnownError = "Sorry, unknown error has occured!"
    case noError = " -- "
}
