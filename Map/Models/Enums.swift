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

enum LocalSearchStatus {
    case locationSelected
    case localSearchInProgress
    case localSearchCancelled
    case localSearchResultsAppear
    case showingNearbyLocations
    case searchBarActive
}

enum FuelTypes: String, CaseIterable, Identifiable  {
    case gas
    case EV
    var id: Self {
        self
    }
}
enum DistanceModes: String, CaseIterable, Identifiable  {
    case km
    case miles
    var id: Self {
        self
    }
}
enum FuelModes: String, CaseIterable, Identifiable  {
    case litre
    case gallon
    var id: Self {
        self
    }
}
enum EfficiencyModesL: String, CaseIterable, Identifiable  {
    case kmpl = "km/L"
    case mpl = "miles/L"

    
    var id: Self {
        self
    }
}
enum EfficiencyModesL2: String, CaseIterable, Identifiable  {
  
    case lp100km = "L/100km"
    case lp100m = "L/100miles"
    
    var id: Self {
        self
    }
}

enum EfficiencyModesG: String, CaseIterable, Identifiable  {
    case kmpg = "km/gl"
    case mpg = "miles/gl"
    case gp100km = "gl/100km"
    case gp100m = "gl/100miles"
    var id: Self {
        self
    }
}
enum EfficiencyModesG2: String, CaseIterable, Identifiable  {
    
    case gp100km = "gl/100km"
    case gp100m = "gl/100miles"
    var id: Self {
        self
    }
}
